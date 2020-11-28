unit CleApiReceiver;

interface

uses
  Classes, SysUtils,

  CleQuoteBroker,  CleFunds, CleParsers,

  CleAccounts, CleOrders, CleSymbols, ClePositions,

  ApiPacket, ApiConsts
  ;

type

  TApiReceiver = class
  private
    FParser: TParser;
    function CheckError( stData : string ): boolean;
    function ParseOrderNo( stNo : string ) : integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ParseAccount( stData : string );
    procedure ParsePrice( iSize: integer; stData : string );
    procedure ParseReqHoga( iCount : integer; stData : string );
    procedure ParseHoga( iSize: integer; stData : string );
    procedure ParseChartData( stData : string );

    procedure ParseActiveOrder( iEnd, iCount: integer; stData : string );
    procedure ParsePosition( iEnd, iCount: integer;  stData : string );
    procedure ParseDeposit( iTag, iCount :integer; stData : string);
    procedure ParseAbleQty( stData : string );

    procedure ParseOrderAck( iTrCode: integer; strData: string);
    procedure ParseOrder(  iSize : integer; strData: string );
    procedure ParseOrderFill(  iSize : integer; strData: string );

    procedure ParseNotice( iTag, iDiv :integer; stData : string);

    property Parser : TParser read FParser;

  end;

var
  gReceiver : TApiReceiver;

implementation

uses
  GAppEnv , GleLib, GleTypes, GleConsts, CleKrxSymbols, Ticks,
  Math , Dialogs

  ;

{ TApiReceiver }

function TApiReceiver.CheckError(stData: string): boolean;
var
  vErr : PErrorData;
  stRjt: string;
begin
  Result := true;

  vErr  :=  PErrorData( stData );
  stRjt := trim( string( vErr.Header.ErrorCode ));

  if ( stRjt = '' ) or ( stRjt = '0000') then
    Exit
  else begin
    //gEnv.ErrString  := Format('%s:%s', [ stRjt , trim(string( vErr.ErrorMsg )) ]);
    //gEnv.EnvLog( WIN_ERR, gEnv.ErrString );
    gLog.Add( lkError,'', stRjt, trim(string( vErr.ErrorMsg ))) ;
    //gEnv.SetAppStatus( asError );
    Result := false;
  end;
end;

constructor TApiReceiver.Create;
begin
  gReceiver := self;
  FParser:= TParser.Create( [Chr(9)]);  // 탭
end;

destructor TApiReceiver.Destroy;
begin
  FParser.Free;
  gReceiver := nil;
  inherited;
end;



procedure TApiReceiver.ParseAbleQty(stData: string);
var
  vData : POutAbleQty;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  aSymbol : TSymbol;
  aPosition, aTmpPos: TPosition;
  I: Integer;

begin
  if Length( stData ) < Len_OutAccountFillSub then Exit;
  if not CheckError( stData ) then
    Exit;

  vData := POutAbleQty( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( vData.Account)));
  if aInvest = nil then Exit;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindFrmSeq( StrToInt( trim( string( vData.Header.WindowID ))));
  if aSymbol = nil then Exit;

  aPosition := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol );
  if aPosition = nil then
    aPosition := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );

  aPosition.AbleQty := StrToInt(trim(string(vData.Ord_q)));

  // 가상계좌 포지션에도 주문가능수 셋팅
  for I := 0 to aInvest.Accounts.Count - 1 do
  begin
    aAcnt := aInvest.Accounts.Accounts[i];
    aTmpPos := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
    if aTmpPos <> nil then
    begin
      aTmpPos.ReqAbleQty  := true;
      aTmpPos.AbleQty     := aPosition.AbleQty;
      gEnv.Engine.TradeBroker.PositionEvent( aTmpPos );
    end;
  end;

  
end;

procedure TApiReceiver.ParseAccount(stData: string);
var
  iCnt : integer;
begin
  if stData = '' then Exit;            

  try
    iCnt  := FParser.Parse( stData );
    if iCnt <= 0 then Exit;
    gEnv.Engine.TradeCore.Investors.New2(  FParser[0], FParser[1], FParser[2]  );
  except
    gLog.Add( lkError, '','ParseAccount', Format('%d : %s', [ iCnt, stData ]) );
  end;

end;

procedure TApiReceiver.ParseActiveOrder( iEnd, iCount: integer; stData : string );

var
  aMain : POutAccountFill;
  i, iStart, iCnt : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  stID, stTmp, stTime, stSub, stCode : string;
  iRemainQty, iFillQty, iCnlQty, iModQty, iOrderQty, iTmp , iSide : integer;
  iOrderNo, iOriginNo : int64;
  aTicket  : TorderTicket;
  dPrice   : Double;
  aOrder   : TOrder;
  pcValue  : TPriceControl;
  tmValue  : TTimeToMarket;
  bChange : boolean;
  dtAcptTime : TDateTime;
  aSub : POutAccountFillSub;
  aInvest : TInvestor;
begin

  // 데이터 순서
  {
    종합계좌번호, 계좌상품번호, 해외파생주문번호,  상품코드,  해외파생원주문번호  4
    주문그룹번호,  주문일자,  매도매수구분코드, 해외파생주문가격,    주문수량     9
    정정수량,   취소수량,   체결수량,  잔여수량,  가격조건구분코드                14
    체결조건구분코드, 차지정가격, 평균체결가격 , 현재가격,  매체구분코드,         19
    주문구분코드,  주문상태구분코드,  주문번호,  접수시각,  현체결시각             24
     , 지접수시각,  현지체결시각, 통화코드                              28
  }

  if ( iCount = 0 ) or ( stData = '' ) then Exit;

  try
    FParser.Clear;

    iCnt  := FParser.Parse( stData );
    if iCount <> iCnt then Exit;

    stCode := Format('%s-%s', [ trim( FParser[0]), trim(FParser[1]) ]);

    aInvest := gEnv.Engine.TradeCore.Investors.Find( stCode );
    if (aInvest = nil) or ( aInvest.RceAccount = nil ) then Exit;
    aAccount  := aInvest.RceAccount;

    aInvest.ActOrdQueried := true;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( Trim(FParser[3]) );
    if aSymbol = nil then Exit;

    gEnv.EnvLog( WIN_PACKET, Format('ActiveOrder:%s', [ stData])  );

    iOrderNo  := ParseOrderNo( trim( FParser[2]));
    iOriginNo := ParseOrderNo( trim( FParser[4]));
    // 수량..
    iOrderQty  := StrToIntDef( trim( FParser[9] ),0);
    iModQty  := StrToIntDef( trim( FParser[10] ), 0);
    iCnlQty  := StrToIntDef( trim( FParser[11] ), 0);
    iFillQty := StrToIntDef( trim( FParser[12] ), 0);
    iRemainQty := StrToIntDef( trim( FParser[13] ),0);

    aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
    if aOrder = nil then
    begin
      //stID := trim( FParser[22]);
      if ( FParser[7] = 'B') then
        iSide := 1
      else
        iSide := -1;
      // 잔여수량

      // 가격조건구분코드
      case FParser[14][1] of
        '1' : pcValue := pcLimit;
        '2' : pcValue := pcMarket;
        '3' : ;
        '4' : ;
      end;

      case FParser[15][1] of
        '1' : tmValue  := tmFAS;
        '2' : tmValue  := tmFOK;
        '3' : tmValue  := tmIOC;
        '4' ,
        '5' : tmValue  := tmGTC;
        '6' : tmValue  := tmGTD;
      end;

      dPrice  := StrToFloat( trim( FParser[8] ));
      // 미접수 주문에서도 찾는다..
      aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
        dPrice, iSide, iOrderQty );

      if aOrder = nil then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewRecoveryOrder( gEnv.ConConfig.UserID,
                                                                    aAccount,
                                                                    aSymbol,
                                                                    iSide,  iOrderQty,
                                                                    pcValue,
                                                                    dPrice,
                                                                    tmValue,
                                                                    aTicket,
                                                                    iOrderNo
                                                                    );
      end;

      if aOrder <> nil then
      begin
        stTime  := Trim( FParser[25] );
        if stTime = '' then
          dtAcptTime  := now
        else
        dtAcptTime  := Date + EncodeTime( StrToInt( Copy( stTime, 1, 2 )),
                                          StrToInt( Copy( stTime, 3, 2 )),
                                          StrToInt( Copy( stTime, 5, 2 )), 0);
        aOrder.SetQty( iOrderQty, iRemainQty, iFillQty, iModQty, iCnlQty);
        aOrder.HanaOrderNo  := trim( FParser[2] );
        case FParser[21][1] of
          '0','1','5' : {aOrder.SrvAcpt;}
            gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, '');
          '6' : {aOrder.Accept( dtAcptTime ); }
            gEnv.Engine.TradeBroker.Accept( aOrder, true, '', dtAcptTime );
        end;
      end;

    end else
    begin
      bChange := false;
      // 상태 비교
      // 수량 비교..
      if (aOrder.ActiveQty <> iRemainQty) then begin
        aOrder.SetQty( iOrderQty, iRemainQty, iFillQty, iModQty, iCnlQty);
        bChange := true;
      end;

      if aOrder.State <> osActive then begin
        aOrder.MakeActive;
        bChange := true;
      end;

      if bChange then
        gEnv.Engine.TradeBroker.UpdateOrd( aOrder, ORDER_ACCEPTED );

    end;

    if aOrder <> nil then
      aOrder.IsRecover := true;

    if (iEnd = 100) and ( aInvest <> nil ) then
    begin
      gEnv.Engine.TradeCore.Orders.CheckActiveOrder( aInvest );
      //gEnv.Engine.RMS.OnTrade( aInvest, ORDER_ACCEPTED );
    end;

  except
  end;
end;


procedure TApiReceiver.ParseChartData(stData: string);
  var
    pMain : POutChartData;
    pSub  : POutChartDataSub;
    aSymbol : TSymbol;
    iHour, i, iCount, iMMIndex, iNextMMIndex,iStart, iMin : integer;
    stSub, stTmp : string;
    bAddTerm  : boolean;
    aQuote : TQuote;
    dtDate, dtTime : TDateTime;
    aItem  : TSTermItem;
    wHH, wMM, wSS, wCC : word;
begin

  if Length( stData ) < Len_OutChartData then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  POutChartData( stData );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( string( pMain.FullCode )));
  if (aSymbol = nil )  then  Exit;
  if aSymbol.Quote = nil then Exit;
  
  iCount  := StrToIntDef( trim( string( pMain.DayCnt)), 0);
  {
  gEnv.EnvLog( WIN_TEST, Format('%s : 전일종가 (%.*n) -> %d ',[
    trim(string( pMain.Today)), aSymbol.Spec.Precision, StrToFloat( trim( string( pMain.PrevLast ))),
    icount]));
 }
  aQuote  := aSymbol.Quote as TQuote;

  //bAddTerm := true;
  iMin := StrToInt( trim( string( pMain.Summary ))) ;

  for I := 0 to iCount - 1 do
  begin
    iStart  := i* Len_OutChartDataSub + (Len_OutChartData + 1);
    stSub := Copy( stData, iStart ,  Len_OutChartDataSub );
    pSub  := POutChartDataSub( stSub );
    //gEnv.EnvLog( WIN_TEST, Format('PosSub(%d):%s',[ i, stSub]));

    stTmp   := trim(string( pSub.Date ));
    dtDate  := EncodeDate( StrToInt(Copy(stTmp,1,4)), // year
                            StrToInt(Copy(stTmp,5,2)), // mon
                            StrToInt(Copy(stTmp,7,2))); // day

    stTmp   := trim(string( pSub.Time ));
    dtTime  := dtDate
               + EncodeTime(StrToInt(Copy(stTmp,1,2)), // hour
                            StrToInt(Copy(stTmp,4,2)), // min
                            StrToInt(Copy(stTmp,7,2)), // sec
                            0 ); // msec};

    aItem := aQuote.Terms.New( dtTime );
    aItem.O := StrToFloat( trim(string( pSub.OpenPrice )));
    aItem.H := StrToFloat( trim( string( pSub.HighPrice )));
    aItem.L := StrToFloat( trim( string( pSub.LowPrice )));
    aItem.C := StrToFloat( trim( string( pSub.ClosePrice )));

    DecodeTime(dtTime, wHH, wMM, wSS, wCC);
    iMMIndex := (wHH )*60 + wMM;
    aItem.MMIndex := (iMMIndex div iMin) * iMin;
    iNextMMIndex := aItem.MMIndex + iMin;
    iHour := iNextMMIndex div 60;
    if iHour >= 24 then iHour := 0;    
    aItem.LastTime := Floor(dtTime) + EncodeTime(iHour,
                                                     iNextMMIndex mod 60,
                                                     0, 0);
                 {
    gEnv.EnvLog( WIN_TEST, Format('Term(%d): %s->%s , %.*n, %.*n, %.*n, %.*n',
      [ i, FormatDateTime('yyyy:mm:dd hh-nn-ss', aItem.StartTime),
          FormatDateTime('yyyy:mm:dd hh-nn-ss', aItem.LastTime ),
        aSymbol.Spec.Precision, aItem.O,  aSymbol.Spec.Precision, aItem.H,
        aSymbol.Spec.Precision, aItem.L,  aSymbol.Spec.Precision, aItem.C  ]));
            }
  end;

  if (i > 0) then
  begin
    if iMin = 60 then
      aQuote.CalceATRValue;
    if (iMin = 5) or ( iMin = 1) then
      aQuote.Terms.CalcePrevATR;
    aQuote.UpdateChart( iMin );
  end;

end;

procedure TApiReceiver.ParsePosition( iEnd, iCount: integer; stData : string );
  var
    pMain : POutAccountPos;
    pSub  : POutAccountPosSub;
    aInvest : TInvestor;
    aAcnt, tmpAcnt : TAccount;
    aSymbol : TSymbol;
    i, iSide, iCnt, iStart, iVolume : integer;
    dOpenPL, dOpenAmt, dAvgPrice, dPrice, dTmp : double;
    stTmp, stSub : string;
    aInvestPos, aPos, tmpPos : TPosition;
    j: Integer;
    tmpList : TList;
    aFund : TFund;
    aFundPos : TFundPosition ;
begin

  //  종합계좌번호, 대체종합계좌번호, 계좌상품번호 , 상품코드 , 상품명
  //  해외파생매도매수구분코드, 미결제약정수량,  매매평균단가, 청산가능수량, 주문잔여수량
  //  해외파생현재가격, 해외파생평가손익금액, 환산승수,  해외파생선물옵션구분코드, 통화코드
  //  가격소수점이하길이,  표시가격, 영업일자

  if ( iCount = 0 ) or ( stData = '' ) then Exit;

  try
    FParser.Clear;
    iCnt := FParser.Parse( stData );
    if iCount = iCnt then
    begin

      stTmp  := Trim(FParser[0]) + '-' + Trim( FParser[2] );
      aInvest := gEnv.Engine.TradeCore.Investors.Find( stTmp );
      if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
      aAcnt := aInvest.RceAccount;
      aInvest.PosQueried := true;

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( Trim( FParser[3] ) );
      if aSymbol = nil then Exit;

      if trim(FParser[5]) = 'B' then
        iSide := 1
      else
        iSide := -1;

      iVolume   := StrToInt( trim( FParser[6] ));
      dAvgPrice := StrToFloat( trim( FParser[7]));
      //stTmp  := Format('%.*f', [ aSymbol.Spec.Precision, dAvgPrice ]);
      //dAvgPrice := StrToFloatDef( stTmp , 0 );
      //dOpenPL   := StrToFloat( trim( string( pSub.Open_pl )));
      dOpenAmt  := StrToFloat( trim( FParser[11]));
      dPrice    := StrToFloat( trim( FParser[10] ));

      aPos := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
      if aPos = nil then
      begin
        aPos := gEnv.Engine.TradeCore.Positions.New(aAcnt, aSymbol);
        gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_NEW);
      end;

      aPos.SetPosition( iVolume * iSide, dAvgPrice, 0);
      aPos.TradeAmt := dOpenAmt;
      aPos.CaclOpePL( dPrice);

      if aSymbol.Quote <> nil then
        gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
          aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler );

      aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol);
      if aInvestPos = nil then begin
        aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );
        //gEnv.Engine.TradeBroker.PositionEvent( aInvestPos, POSITION_NEW);
      end;

      if aInvestPos <> nil then
      begin
        aInvestPos.SetPosition(iVolume * iSide, dAvgPrice,0);
        aInvestPos.TradeAmt := dOpenAmt;
        aInvestPos.CaclOpePL( dPrice);
      end;

      gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_UPDATE);
      // fund poistion
      aFund := gEnv.Engine.TradeCore.Funds.Find( aAcnt );
      if aFund <> nil then
      begin
        aFundPos  := gEnv.Engine.TradeCore.FundPositions.Find( aFund, aSymbol  );
        if aFundPos = nil then begin
          aFundPos := gEnv.Engine.TradeCore.FundPositions.New( aFund, aSymbol);
          gEnv.Engine.TradeBroker.PositionEvent( aFundPos, FPOSITION_NEW );
        end;

        if not aFundPos.Positions.FindPosition( aPos ) then
          aFundPos.Positions.Add( aPos );

        aFundPos.RecoveryPos( aPos.Volume, aPos.AvgPrice);
        gEnv.Engine.TradeBroker.PositionEvent( aFundPos, FPOSITION_UPDATE );
      end;
    end;

    if aPos <> nil then aPos.IsRecover := true;
    if aInvestPos <> nil then aInvestPos.IsRecover := true;

    //if aFundPos <> nil then aFundPos.IsRecover := true;

    if ( iEnd = 100 ) and ( aInvest <> nil )  then
    begin
      if aAcnt <> nil then      
        gEnv.Engine.TradeCore.Positions.CheckHavePosition( aAcnt );
      gEnv.Engine.TradeCore.InvestorPositions.CheckHavePosition( aInvest );
      //gEnv.Engine.RMS.OnTrade( aInvest, POSITION_NEW );
    end;


  finally
  end;

end;

procedure TApiReceiver.ParseDeposit( iTag, iCount :integer; stData : string );

  var

    aInvest : TInvestor;
    aAcnt : TAccount;
    aSymbol : TSymbol;
    i, iCnt : integer;
    dFee, dFixedPL : double;
    aInvestPos, aPos : TPosition;
    aParse : TParser;
    stCode : string;
    aType  : TDepositType;
begin
  {
  계좌번호, 상품번호,  통화코드, 평가위탁, 주문증거금,    4
  유지증거금, 개시(위탁)증거금,  추가증거금, 환전가능, 주문가능금액,  9
  증거금부족( 원화대용), 청산손익,  수수료, 평가손익, 당일현금         14
  미수금, 환율
  }

  if ( iCount = 0 ) or ( stData = '' ) or ( iTag = -1 ) then
  begin
    if stData <> '' then
    begin
      aInvest := gEnv.Engine.TradeCore.Investors.Find( Trim(stData) );
      if aInvest <> nil then
        aInvest.IsSucc := false
    end;

    Exit;
  end;

  try
    try
      aParse  := TParser.Create( [ Chr(9) ]);
      iCnt    := aParse.Parse( stData );

      if iCnt = iCount  then
      begin
        stCode  := Trim(aParse[0]) + '-' + Trim( aParse[1] );
        aInvest := gEnv.Engine.TradeCore.Investors.Find( stCode );
        if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
        aAcnt := aInvest.RceAccount;
        stCode := Trim( aParse[2] ) ;
        if stCode = 'USD' then
          aType := dtUSD
        else if stCode = 'TOT' then
          aType := dtWON
        else
          Exit;

        dFixedPL := StrToFloatDef( trim( aParse[11] ),0);
        dFee     := StrToFloatDef( trim( aParse[12] ),0);

        aInvest.RecoverFees[aType]  := dFee;
        aInvest.SetFixedPL( aType, dFixedPL );

        aAcnt.RecoverFees[aType]    := dFee;
        aAcnt.SetFixedPL( aType ,dFixedPl );
        /////////////////////////////
        aInvest.ExchangeRate[aType] := StrToFloatDef( trim( aParse[16] ), 1);
        aInvest.Deposit[aType]   := StrToFloatDef( trim( aParse[14] ), 0);
        aInvest.WonDaeAmt[aType] := StrToFloatDef( trim(aParse[15] ), 0);
        aInvest.OpenPL[aType]    := StrToFloatDef( trim( aParse[13]), 0);
        aInvest.UnBackAmt[aType] := StrToFloatDef( trim( aParse[15]), 0); // 미수금

        //aInvest.UnBackAmt[aType] := StrToFloatDef( trim( aParse[10]), 0);
        aInvest.DepositOTE[aType]  := StrToFloatDef( trim( aParse[3]), 0);
        aInvest.TrustMargin[aType] := StrToFloatDef( trim(aParse[6] ), 0);
        aInvest.HoldMargin[aType]  := StrToFloatDef( trim(aParse[5] ), 0);
        aInvest.OrderMargin[aType] := StrToFloatDef( trim( aParse[4]), 0);

        aInvest.AddMargin[aType]   := StrToFloatDef( trim(aParse[7] ), 0);
        aInvest.OrderAbleAmt[aType]:= StrToFloatDef( trim(aParse[9] ), 0);

        // 일괄 조회를 위해 구분의 필요성이 있다..
        if (not aInvest.IsInit) and ( not gEnv.RecoveryEnd ) then
          aInvest.IsInit  := true;

        aInvest.IsSucc := true;
        gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );
        //gEnv.Engine.RMS.OnTrade( aInvest, ACCOUNT_DEPOSIT );

      end;

    except
    end;
  finally
    aParse.Free;
  end;


end;

procedure TApiReceiver.ParseReqHoga( iCount : integer;  stData: string);
var
  aSymbol : TSymbol;
  stCode, stTime: string;
  aParse : TParser;
  i, ia, ib, iCnt   : integer;
  aQuote : TQuote;
begin

  try
    try
      aParse  := TParser.Create( [ Chr(9) ]);
      iCnt    := aParse.Parse( stData );

      if iCnt = iCount then
      begin
        stCode  := Trim( aParse[0] );
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode);

        if aSymbol = nil then Exit;

        aSymbol.Last    := StrToFloat( trim( aParse[1] ));
        aSymbol.DayOpen := StrToFloat( trim( aParse[2] ));
        aSymbol.DayHigh := StrToFloat( trim( aParse[3]));
        aSymbol.DayLow  := StrToFloat( trim( aParse[4]));

        if aSymbol.Quote <> nil then
          with (aSymbol.Quote as TQuote) do
          begin
            ia := 5;
            ib := 20;
            for i := 0 to Asks.Size - 1 do
            begin
              Asks[i].Price  := StrToFloat( trim(string( aParse[ ia + i] )));
              Asks[i].Volume := StrToInt( trim(string( aParse[ ia + 5 + i] )));
              Asks[i].Cnt    := StrToInt( trim(string( aParse[ ia + 10+ i] )));

              Bids[i].Price  := StrToFloat( trim(string( aParse[ib + i] )));
              Bids[i].Volume := StrToInt( trim(string( aParse[ib + 5 + i] )));
              Bids[i].Cnt    := StrToInt( trim(string( aParse[ib + 10+ i] )));
            end;
            UpdateCustom( now );
          end;
      end;

    except
    end;
  finally
    aParse.Free;
  end;


end;

procedure TApiReceiver.ParseHoga( iSize: integer; stData: string);
var
  vData : PAutoSymbolHoga;
  aQuote: TQuote;
  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin

  if Length( stData ) < Len_AutoSymbolHoga then Exit;

  vData := PAutoSymbolHoga( stData );
  aQuote  := gEnv.Engine.QuoteBroker.Find( Trim(string(vData.PRDT_CD)) );
  if aQuote = nil then Exit;

  stTime  := string( vData.KQUOTE_TIME );

  try

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloat( trim(string( vData.Asks[i].Price )));
      aQuote.Asks[i].Volume := StrToInt( trim(string( vData.Asks[i].Volume )));
      aQuote.Asks[i].Cnt    := StrToInt( trim(string( vData.Asks[i].Cnt )));

      aQuote.Bids[i].Price  := StrToFloat( trim(string( vData.Bids[i].Price )));
      aQuote.Bids[i].Volume := StrToInt( trim(string( vData.Bids[i].Volume )));
      aQuote.Bids[i].Cnt    := StrToInt( trim(string( vData.Bids[i].Cnt )));
    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.ASKSIZE )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.BIDSIZE )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.ASKCNT )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.BIDCNT )));
    dtQuote  := Date
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,3,2)), // min
                            StrToInt(Copy(stTime,5,2)), // sec
                            0 ); // msec}

    aQuote.Update(dtQuote);
  except
  end;

end;

procedure TApiReceiver.ParseNotice(iTag, iDiv: integer; stData: string);
var
  aType : TCommNoticeType;
  bRes  : boolean;
begin

  gLog.Add( lkApplication, '','ParseNotice', Format('%d : %s', [ iTag, stDAta]) );

  aType :=  TCommNoticeType( iTag );

  case aType of
    Connected: ;
    Connecting: ;
    Closed: ;
    Closing: ;
    ReconnectRequest:
      begin
        gEnv.ErrString  := stData ;
        gEnv.SetAppStatus( asError );
      end ;
    ConnectFail:
      begin
        gEnv.ErrString  := stData + '잠시 후 다시 연결해주세요';
        gEnv.SetAppStatus( asError );
      end ;
    NotifyMultiLogin:
      begin
        if iDiv = 1 then
        begin
          bRes :=  MessageDlgLE( gEnv.Main,
          stData+ #13+#10 + '다중접속 됨 연결 해제하시겠습니까? ',
          mtConfirmation, [mbOK, mbCancel]) = 1;

          if bRes then gEnv.Main.Close;
        end
        else
          ShowMessageLE(  nil , stData   );
      end ;
    NotifyEmergency:
      gLog.Add( lkWarning, '','', stData);
  end;

end;

procedure TApiReceiver.ParsePrice( iSize: integer; stData: string);
var
  vData : PAutoSymbolPrice;
  aQuote: TQuote;
  aSale: TTimeNSale;
  dtQuote : TDAteTime;
  stTime  : string;
  askPrice : double;
begin
  if Length( stData ) < Len_AutoSymbolPrice then Exit;

  try
    vData := PAutoSymbolPrice( stData );

    aQuote  := gEnv.Engine.QuoteBroker.Find( trim( string(vData.PRDT_CD)) );
    if aQuote = nil then Exit;

    stTime  := string( vData.KTRADE_TIME );
    dtQuote  := Date
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,3,2)), // min
                              StrToInt(Copy(stTime,5,2)), // sec
                              0 ); // msec}

    aQuote.DailyVolume  := StrToInt64( trim(string(vData.ACVOL_1 )));

    aSale := aQuote.Sales.New;
    aSale.LocalTime := now;
    aSale.Volume  := StrToInt64( trim(string( vData.TRDVOL_1 )));
    aSale.Price   := StrToFloat( trim(string( vData.TRDPRC_1 )));
    aSale.DayVolume := aQuote.DailyVolume;
    //aSale.DayAmount := aQuote.DailyAmount;
    aSale.Time  := dtQuote;

    if  vData.TRDVOL_1_CLR = '+' then
      aSale.Side := 1
    else
      aSale.Side := -1;

    aQuote.Open := StrToFloat( trim(string( vData.OPEN_PRC )));
    aQuote.High := StrToFloat( trim(string( vData.HIGH_1 ))) ;
    aQuote.Low  := StrToFloat( trim(string( vData.LOW_1 )));
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToFloat( trim(string( vData.NETCHNG_1 )));

    //if vData.NETCHNG_1_CLR = '-' then
    //  aQuote.Change := aQuote.Change * -1;

    aQuote.Update(dtQuote);

  except
  end;

end;

procedure TApiReceiver.ParseOrderAck(iTrCode: integer; strData: string);
  var
    aOrder : TOrder;
    iCnt, iLocalNo , iOrderNo : integer;
    stOrdNo, stRjt : string;
    aInvestor : TInvestor;
    aSymbol   : TSymbol;
begin
    //gEnv.EnvLog( WIN_PACKET, Format('Order_%d:%s', [  iTrCode, strData  ]) );
  if ( iTrCode = 0 ) or ( strData = '' ) then Exit;

  try
    FParser.Clear;

    iCnt  := FParser.Parse( strData );
    if iCnt <> iTrCode then Exit;

    //iLocalNo  := StrToInt( trim( FParser[0] ));
    iLocalNo  := StrToInt( trim( FParser[1] ));
    stRjt     := trim( FParser[2] );
    aOrder    := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder2( iLocalNo );

    if aOrder = nil then begin
      gEnv.EnvLog( WIN_ORD, Format('Not Found LocalNo(%d) order : %s, %s', [
           iLocalNo, stRjt, strData  ]) );
      //
      Exit;
    end;

    if( stRjt = '' ) or ( stRjt = '0000') then
    begin
      stOrdNo   := trim( FParser[0]);
      iOrderNo  := ParseOrderNo( stOrdNo);
      aOrder.HanaOrderNo  := stOrdNo;
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjt );
    end
    else begin
      gEnv.Engine.TradeBroker.SrvReject( aOrder, stRjt, trim( FParser[3] ) );
    end;

  except
  end;

end;

procedure TApiReceiver.ParseOrderFill(iSize: integer; strData: string);

  var
    bOutOrd : boolean;
    vData : PAutoOrderPacket;
    stRjtCode, stTmp, stSub, stCode : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    i, i2, iSide, iStart, iOrderQty, iCount, iConfirmedQty , iAbleQty: integer;
    dtTime : TDateTime;
    bConfirmed: Boolean;

    bAccepted : boolean;
    aOrder, aTarget  : TOrder;
    aTicket : TOrderTicket;
    aResult : TOrderResult;

    pcValue: TPriceControl;
    otValue: TOrderType;
    tmValue: TTimeToMarket;
    dPrice, dFilledPrice : double;
begin

  if Length(strData ) < Len_AutoOrderPacket then Exit;

  try

    vData := PAutoOrderPacket( strData );

    stCode  := Format('%s-%s', [ trim( string( vData.cano )), trim( string( vData.apno)) ]);
    aInvest := gEnv.Engine.TradeCore.Investors.Find( stCode );
    if aInvest = nil then Exit;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(vData.prdt_cd)));
    if aSymbol = nil then Exit;

    //iOrderNo  := StrToInt64Def( trim(string(vData.odrv_odno )),0);
    iOrderNo  := ParseOrderNo( trim(string(vData.odrv_odno )));

    // '2' 일때는 체결수량  '3,4,5,6' 일때는..확인수량..
    iConfirmedQty := StrToIntDef( trim(string( vData.cncs_qnt_ctns )), 0);
    //stRjtCode := trim( string( vData.Header.ErrorCode ));
    //bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000') or (stRjtcode = ''))  ;

    stTmp  := trim( string( vData.cncs_tm ));
    dtTime :=  Date +
                    EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                               StrToIntDef(Copy(stTmp,3,2),0),
                               StrToIntDef(Copy(stTmp,5,2),0),
                               StrToIntDef(Copy(stTmp,7,2),0)*10);

    iAbleQty  := 0;// StrToInTDef(trim(string( vData.Ordp_q )),0);

    aAccount  := aInvest.RceAccount;
    aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);

    i := StrToInt( trim( string( vData.ordr_stts_dcd )));
    case i of
      0 : stTmp := '대기주문';
      1 : stTmp := '승인대기';
      2 : stTmp := '1차조건대기';
      3 : stTmp := '2차조건대기';
      4 : stTmp := '전송요청대기';
      5 : stTmp := '전송완료';
      6 : stTmp := '정상접수';
      7 : stTmp := '접수거부';
      8 : stTmp := '전송실패';
      9 : stTmp := 'OMS취소';
    end;

    i2  := StrToInt( trim( string( vData.rltm_dpch_dcd)));

    case i2 of
      1 : stSub := '주문확인';
      2 : stSub := '체결확인';
      3 : stSub := '미결제';
      4 : stSub := '개별미결제';
      5 : stSub := '미체결';
    end;

    // 주문로그
    gEnv.EnvLog( WIN_ORD,
      Format('체결 %s(%s)  %-15.15s(%d), %-10.10s(%d) - 주문번호(%d) 수량(%s)  체결 (%s) 잔여(%s) ', [
        vData.odrv_ordr_tp_dcd , string(vData.rltm_dpch_prcs_dcd), stTmp, i, stSub, i2,
        iOrderNo,
        trim(string( vData.ordr_qnt_ctns) ),  trim(string( vData.cncs_qnt_ctns)), trim(string( vData.ordr_rmn_qnt_ctns))
         ])
      );
    bOutOrd := false;
    // 외부 주문이란 애기
    if (aOrder = nil) then
    begin
      bOutOrd := true;

      //gEnv.EnvLog( WIN_ORD,      Format('외부 주문 !!'        );
      // 파싱...............
      //iOriginNo := StrToInt64Def( string(vData.odrv_or_odno ),0);
      iOriginNo := ParseOrderNo(  trim(string(vData.odrv_or_odno )));
      if vData.odrv_sell_buy_dcd = 'B' then
        iSide := 1
      else
        iSide := -1;
      dPrice   := StrToFloatDef( trim(string( vData.odrv_ordr_prc_ctns )), 0);

      case vDAta.odrv_prc_dcd of
        '1' : pcValue := pcLimit;
        '2' : pcValue := pcMarket;
        '3' : ;
        '4' : ;
      end;

      case vData.cncs_cnd_dcd of
        '1' : tmValue  := tmFAS;
        '2' : tmValue  := tmFOK;
        '3' : tmValue  := tmIOC;
        '4' ,
        '5' : tmValue  := tmGTC;
        '6' : tmValue  := tmGTD;
      end;

      iOrderQty  := StrToIntDef( trim(string( vData.ordr_qnt_ctns )), 0);

      aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
        dPrice, iSide, iOrderQty );

      if aOrder = nil then
      begin
        gEnv.EnvLog( WIN_ORD, '체결 외부주문..!!!');
        // 주문 생성...............
        if otValue in [otChange, otCancel] then
        begin
          aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iOriginNo);
          if aTarget = nil then
          begin
            gEnv.Engine.TradeBroker.ForwardAccepts.New(aAccount, aSymbol, iOriginNo, iOrderNo, iOrderQty,
                                                    dPrice, otValue, pcValue, bAccepted,
                                                    stRjtCode, dtTime);

            Exit;
          end;
        end;

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        aOrder  := nil;
        case otValue of
          otNormal:
            begin
              aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                      gEnv.ConConfig.UserID, aAccount, aSymbol, iSide * iOrderQty, pcValue, dPrice,
                      tmValue, aTicket);
            end;
          otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx(
                      aTarget, iOrderQty, pcValue, dPrice, tmValue, aTicket);
          otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorderEx(
                      aTarget, iOrderQty, aTicket);
        end;
      end else
        genv.EnvLog( WIN_ORD, Format('주문역전 - (%d)%s ',[ iOrderNo, aOrder.Represent2 ])         );
      if aOrder = nil then Exit;
      // 서버접수 처리.....................
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      aOrder.HanaOrderNo  := trim(string(vData.odrv_odno ));
    end;

    dFilledPrice  := StrToFloat( trim( string( vData.odrv_cncs_prc_ctns )));
    aResult := gEnv.Engine.TradeCore.OrderResults.New(
              aInvest, aSymbol, iOrderNo, orFilled, dtTime,
              StrToInt( trim(string( vData.odrv_cncs_no ))) , '',iConfirmedQty,
              dFilledPrice, dtTime);
    gEnv.Engine.TradeBroker.Fill( aResult, dtTime,iAbleQty);

  except
  end;
end;

function TApiReceiver.ParseOrderNo(stNo: string): integer;
var
  iLen : integer;
begin
  Result := 0;
  if stNo = '' then Exit;
  if Length( stNo ) < 9 then Exit;  
  Result    :=  StrToInt( Copy( stNo, 9, Length( stNo ) - 8 ) );
end;

procedure TApiReceiver.ParseOrder( iSize : integer; strData: string);
  var
    bOutOrd : boolean;
    vData : PAutoOrderResponse;
    stRjtCode, stTmp, stSub, stCode : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    iRemQty, iCnlQty, iModQty, i, i2, iSide, iStart, iOrderQty, iCount, iConfirmedQty , iAbleQty: integer;
    dtTime : TDateTime;
    bConfirmed: Boolean;

    bAccepted : boolean;
    aOrder, aTarget  : TOrder;
    aTicket : TOrderTicket;
    aResult : TOrderResult;

    pcValue: TPriceControl;
    otValue: TOrderType;
    tmValue: TTimeToMarket;
    dPrice, dFilledPrice : double;
begin

  if Length(strData ) < Len_AutoOrderResponse then Exit;

  try

    vData := PAutoOrderResponse( strData );

    stCode  := Format('%s-%s', [ trim( string( vData.cano )), trim( string( vData.apno)) ]);
    aInvest := gEnv.Engine.TradeCore.Investors.Find( stCode );
    if aInvest = nil then Exit;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(vData.prdt_cd)));
    if aSymbol = nil then Exit;

    //iOrderNo  := StrToInt64Def( trim(string(vData.odrv_odno )),0);
    iOrderNo  := ParseOrderNo( trim(string(vData.odrv_odno )));
    iOriginNo := ParseOrderNo(  trim(string(vData.odrv_or_odno )));
    //stRjtCode := trim( string( vData.Header.ErrorCode ));
    //bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000') or (stRjtcode = ''))  ;

    stTmp  := trim( string( vData.acpl_acpt_tm ));
    dtTime :=  Date +
                    EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                               StrToIntDef(Copy(stTmp,3,2),0),
                               StrToIntDef(Copy(stTmp,5,2),0),
                               StrToIntDef(Copy(stTmp,7,2),0)*10);

    //iAbleQty  :=  StrToInTDef(trim(string( vData.Ordp_q )),0);

    aAccount  := aInvest.RceAccount;
    aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);

    i := StrToInt( trim( string( vData.ordr_stts_dcd )));
    case i of
      0 : stTmp := '대기주문';
      1 : stTmp := '승인대기';
      2 : stTmp := '1차조건대기';
      3 : stTmp := '2차조건대기';
      4 : stTmp := '전송요청대기';
      5 : stTmp := '전송완료';
      6 : stTmp := '정상접수';
      7 : stTmp := '접수거부';
      8 : stTmp := '전송실패';
      9 : stTmp := 'OMS취소';
    end;

    i2  := StrToInt( trim( string( vData.rltm_dpch_dcd)));

    case i2 of
      1 : stSub := '주문확인';
      2 : stSub := '체결확인';
      3 : stSub := '미결제';
      4 : stSub := '개별미결제';
      5 : stSub := '미체결';
    end;

    iOrderQty := StrToIntDef( trim(string( vData.ordr_qnt_ctns )), 0);
    iModQty   := StrToIntDef( trim(string( vData.rvse_qnt_ctns )), 0);
    iCnlQty   := StrToIntDef( trim(string( vData.cncl_qnt_ctns )), 0);
    iRemQty   := StrToIntDef( trim(string( vData.ordr_rmn_qnt_ctns )), 0);
    // 주문로그
    gEnv.EnvLog( WIN_ORD,
      Format('접수 %s(%s)  %-15.15s(%d), %-10.10s(%d) - 주문번호(%d) 원주문(%d) 수량( %d, %d, %d)  체결 (%s) 잔여(%d) 체합(%s) %s', [
        vData.odrv_ordr_tp_dcd , string(vData.rltm_dpch_prcs_dcd), stTmp, i, stSub, i2,
        iOrderNo,  iOriginNo,   iOrderQty,iModQty,  iCnlQty,
        trim(string( vData.cncs_qnt_ctns)), iRemQty, trim(string( vData.cncs_qnt_smm_ctns )) ,
        trim(string( vData.odrv_ordr_prc_ctns ))
         ])
      );
    bOutOrd := false;
    // 외부 주문이란 애기
    if (aOrder = nil) then
    begin
      bOutOrd := true;

      //gEnv.EnvLog( WIN_ORD,      Format('외부 주문 !!'        );
      // 파싱...............
      //iOriginNo := StrToInt64Def( trim(string(vData.odrv_or_odno )),0);

      if vData.odrv_sell_buy_dcd = 'B' then
        iSide := 1
      else
        iSide := -1;
      dPrice   := StrToFloatDef( trim(string( vData.odrv_ordr_prc_ctns )), 0);

      case vDAta.odrv_prc_dcd of
        '1' : pcValue := pcLimit;
        '2' : pcValue := pcMarket;
        '3' : ;
        '4' : ;
      end;

      case vData.cncs_cnd_dcd of
        '1' : tmValue  := tmFAS;
        '2' : tmValue  := tmFOK;
        '3' : tmValue  := tmIOC;
        '4' ,
        '5' : tmValue  := tmGTC;
        '6' : tmValue  := tmGTD;
      end;
      {
      // 주문 구분
      신규주문          :  N - 주문수량 > 0,  정정수량 = 0, 취소수량 = 0   잔여수량 = 주문수량

      정정주문의 원주문 :  M - 주문수량 > 0,  정정수량 > 0, 취소수량 = 0   잔여수량 = 주문수량 - 정정수량 ( 0 이됨 )
      정정주문 확인     :  M - 주문수량 > 0,  정정수량 = 0, 취소수량 = 0   잔여수량 = 주문수량

      취소주문의 원주문 :  N(M) - 주문수량 > 0,  정정수량 = 0, 취소수량 > 0   잔여수량 = 주문수량 - 취소수량 ( 0 이됨 )
      취소주문 확인     :    C  - 주문수량 > 0,  정정수량 = 0, 취소수량 > 0   잔여수량 = 주문수량 - 취소수량 ( 0 이됨 )
      }

      case vData.odrv_ordr_tp_dcd of
        'N' : otValue := otNormal;
        'M' : if ( iOrderQty > 0 ) and ( iModQty > 0 ) then otValue := otNormal       // 정정주문의 원주문...
              else if ( iOrderQty > 0 ) and ( iCnlQty > 0 ) then otValue := otNormal  // 취소주문의 원주문;
              else begin
                otValue   := otChange;                                                // 정정확인
                iConfirmedQty := iModQty;
              end;
        'C' : begin otValue := otCancel;  iConfirmedQty  := iCnlQty; end;
      end;

      if vData.odrv_ordr_tp_dcd = 'C' then
        dPrice := 0;

      aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
        dPrice, iSide, iOrderQty, otValue );

      if aOrder = nil then
      begin
        gEnv.EnvLog( WIN_ORD, '외부주문..!!!');
        // 주문 생성...............
        if otValue in [otChange, otCancel] then
        begin
          aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iOriginNo);
          if aTarget = nil then
          begin
            gEnv.Engine.TradeBroker.ForwardAccepts.New(aAccount, aSymbol, iOriginNo, iOrderNo, iOrderQty,
                                                    dPrice, otValue, pcValue, bAccepted,
                                                    stRjtCode, dtTime);
            gEnv.EnvLog( WIN_ORD, '원주문 찾지 못함');
            Exit;
          end;
        end;

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( self );
        aOrder  := nil;
        case otValue of
          otNormal:
            begin
              aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                      gEnv.ConConfig.UserID, aAccount, aSymbol, iSide * iOrderQty, pcValue, dPrice,
                      tmValue, aTicket);
            end;
          otChange: aOrder := gEnv.Engine.TradeCore.Orders.NewChangeOrderEx(
                      aTarget, iOrderQty, pcValue, dPrice, tmValue, aTicket);
          otCancel: aOrder := gEnv.Engine.TradeCore.Orders.NewCancelorderEx(
                      aTarget, iOrderQty, aTicket);
        end;
      end else
        genv.EnvLog( WIN_ORD, Format('주문역전 - (%d)%s ',[ iOrderNo, aOrder.Represent2 ])         );
      if aOrder = nil then Exit;
      // 서버접수 처리.....................
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      aOrder.HanaOrderNo  := trim(string(vData.odrv_odno ));
      aOrder.OwnOrder     := false;
    end;
    //.......
    case vData.ordr_stts_dcd of
      '0'     : if aOrder <> nil then gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      '6','7','8','9' :
        begin
          case vData.ordr_stts_dcd of
            '7','8','9' : begin bAccepted := false; stRjtCode := Format('999%s', [ vData.ordr_stts_dcd ]); end;
            else bAccepted := true;
          end;

          case aOrder.OrderType of
            otNormal: gEnv.Engine.TradeBroker.Accept( aOrder, bAccepted, stRjtCode, dtTime,iAbleQty );
            otChange,
            otCancel:
              begin
                iConfirmedQty  := iOrderQty;
                if not bAccepted then iConfirmedQty := 0;
                aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aInvest, aSymbol, iOrderNo,
                    orConfirmed, Now, 0, stRjtCode, iConfirmedQty, dPrice, dtTime);
                gEnv.Engine.TradeBroker.Confirm(aResult, Now,iAbleQty);
              end;
          end;  // case aOrder.OrderType
        end;
    end;


  except
  end;

end;

end.
