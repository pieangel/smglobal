unit CleApiReceiver;

interface

uses
  Classes, SysUtils,

  CleQuoteBroker,  CleFunds,

  CleAccounts, CleOrders, CleSymbols, ClePositions,

  ApiPacket, ApiConsts
  ;

type
                                             {
    ESID_5611 ,  // 실체결
    ESID_5612,	 // 실잔고
    ESID_5614,	 // 계좌별 주문체결현황
    ESID_5615 :  // 예탁자산및 증거금
                                             }
  TApiReceiver = class
  private
    function CheckError( stData : string ): boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ParseMarketPrice( stData : string );
    procedure ParsePrice( stData : string );
    procedure ParseReqHoga( stData : string );
    procedure ParseHoga( stData : string );
    procedure ParseChartData( stData : string );

    procedure ParseActiveOrder( stData : string );
    procedure ParsePosition(  stData : string );
    procedure ParseDeposit(  stData : string);
    procedure ParseAbleQty( stData : string );

    procedure ParseOrderAck( iTrCode: integer; strData: string);
    procedure ParseOrder( strData: string );

  end;

var
  gReceiver : TApiReceiver;

implementation

uses
  GAppEnv , GleLib, GleTypes, GleConsts, CleKrxSymbols, Ticks,
  Math

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
end;

destructor TApiReceiver.Destroy;
begin
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

procedure TApiReceiver.ParseActiveOrder(stData : string );

var
  aMain : POutAccountFill;
  i, iStart, iCnt : integer;
  aAccount : TAccount;
  aSymbol  : TSymbol;
  stTmp, stTime, stSub  : string;
  iOrderQty, iTmp , iSide : integer;
  iOrderNo, iOriginNo : int64;
  aTicket  : TorderTicket;
  dPrice   : Double;
  aOrder   : TOrder;
  pcValue  : TPriceControl;
  tmValue  : TTimeToMarket;
  bAsk : boolean;
  dtAcptTime : TDateTime;
  aSub : POutAccountFillSub;
  aInvest : TInvestor;
begin

  if Length( stData ) < Len_OutAccountFillSub then Exit;
  if not CheckError( stData ) then
    Exit;

  aMain := POutAccountFill( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( string(aMain.Account));
  if (aInvest = nil) or ( aInvest.RceAccount = nil ) then Exit;
  aAccount  := aInvest.RceAccount;

  aInvest.ActOrdQueried := true;

  iCnt  := StrToIntDef( trim(string( aMain.Dtno )),0);
  if iCnt > 0 then
    for I := 0 to iCnt - 1 do
    begin
      iStart  := i* Len_OutAccountFillSub + (Len_OutAccountFill + 1);
      stSub := Copy( stData, iStart ,  Len_OutAccountFillSub );
      aSub  := POutAccountFillSub( stSub );

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( trim(string(aSub.ShortCode)));
      if aSymbol = nil then Continue;

      gEnv.EnvLog( WIN_PACKET, Format('ActiveOrder(%d:%d):%s', [ iCnt,i, stSub])  );

      iOrderNo  := StrToInt64( trim( string( aSub.Ord_No )));
      iOriginNo := StrToInt64( trim( string( aSub.Org_ord_No )));

      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
      if aOrder = nil then
      begin
        if ( aSub.Bysl_tp = '1' ) or ( aSub.Bysl_tp = '3' ) then
          iSide := 1
        else
          iSide := -1;

        iOrderQty := StrToInt( trim( string( aSub.Mcg_q )));

        case aSub.Prce_tp of
         '1' : pcValue := pcLimit;
         '2' : pcValue := pcMarket;
        end;

        case aSub.Trd_cond of
          '1' : tmValue := tmFAS;
          '2' : tmValue := tmFOK;
          '3' : tmValue := tmIOC;
        end;

        dPrice  := StrToFloat( trim( string( aSub.Ord_p )));
        stTime  := string( aSub.Ex_ord_tm );
        dtAcptTime  := Date + EncodeTime( StrToInt( Copy( stTime, 1, 2 )),
                                          StrToInt( Copy( stTime, 3, 2 )),
                                          StrToInt( Copy( stTime, 5, 2 )), 0);

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
        if aOrder <> nil then
          case aSub.Proc_stat of
            '0' : {aOrder.SrvAcpt;}
              gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, '');
            '1' : {aOrder.Accept( dtAcptTime ); }
              gEnv.Engine.TradeBroker.Accept( aOrder, true, '', dtAcptTime );
          end;
      end;
    end;

  if aMain.Header.NextKind <> '0' then
  begin
    
    gEnv.EnvLog( WIN_PACKET, Format('%s : Stand by Next Active Order ', [ aInvest.Code ])   );
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

procedure TApiReceiver.ParsePosition( stData : string );
  var
    pMain : POutAccountPos;
    pSub  : POutAccountPosSub;
    aInvest : TInvestor;
    aAcnt, tmpAcnt : TAccount;
    aSymbol : TSymbol;
    i, iSide, iCount, iStart, iVolume : integer;
    dOpenPL, dOpenAmt, dAvgPrice, dPrice, dTmp : double;
    stTmp, stSub : string;
    aInvestPos, aPos, tmpPos : TPosition;
    j: Integer;
    tmpList : TList;
    aFund : TFund;
    aFundPos : TFundPosition ;
begin

  if Length( stData ) < Len_OutAccountPos then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  POutAccountPos( stData );
  aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( pMain.Account )));
  if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
  aAcnt := aInvest.RceAccount;
  iCount  := StrToIntDef( trim( string( pMain.Dtno )), 0);
  //if aInvest.PosQueried then Exit;
  aInvest.PosQueried := true;

  if iCount > 0 then
    for I := 0 to iCount - 1 do
    begin
      iStart  := i* Len_OutAccountPosSub + (Len_OutAccountPos + 1);
      stSub := Copy( stData, iStart ,  Len_OutAccountPosSub );
      pSub  := POutAccountPosSub( stSub );
      gEnv.EnvLog( WIN_PACKET, Format('PosSub(%d):%s',[ i, stSub]));
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( string ( pSub.FullCode )));
      if aSymbol = nil then Continue;

      if pSub.Bysl_tp = '1' then
        iSide := 1
      else
        iSide := -1;

      iVolume   := StrToInt( trim( string( pSub.Open_q )));
      dAvgPrice := StrToFloat( trim( string( pSub.Avgt_p )));
      stTmp  := Format('%.*f', [ aSymbol.Spec.Precision, dAvgPrice ]);
      dAvgPrice := StrToFloatDef( stTmp , 0 );
      dOpenPL   := StrToFloat( trim( string( pSub.Open_pl )));
      dOpenAmt  := StrToFloat( trim( string( pSub.Trd_amt )));
      dPrice    := StrToFloat( trim( string( pSub.Curr_p )));

      // 같은 포지션이 있는지 검색
      try
        aPos := nil;
        tmpList := TList.Create;
        for j := 0 to aInvest.Accounts.Count - 1 do
        begin
          tmpAcnt := aInvest.Accounts.Accounts[j];
          tmpPos  := gEnv.Engine.TradeCore.Positions.Find( tmpAcnt, aSymbol );
          if tmpPos <> nil then
            tmpList.Add( tmpPos );
        end;

        if tmpList.Count > 1 then
        begin
          for j := 0 to tmpList.Count - 1 do
          begin
            tmpPos := TPosition( tmpList.Items[j] );
            if tmpPos.Volume <> 0 then
            begin
              aPos := tmpPos;
              break;
            end;
          end;
        end;

      finally
        tmpList.Free;
      end;

      //aPos := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
      if aPos = nil then
      begin
        aPos := gEnv.Engine.TradeCore.Positions.New(aAcnt, aSymbol);
        gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_NEW);
      end;

      aPos.SetPosition( iVolume * iSide, dAvgPrice, 0);
      aPos.TradeAmt := dOpenAmt;
      aPos.CaclOpePL( dPrice);
      gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
          aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler );

      aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol);
      if aInvestPos = nil then
        aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );

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
          //FDistributor.Distribute(Self, FPOS_DATA, aFundPos, FPOSITION_NEW);
        end;

        if not aFundPos.Positions.FindPosition( aPos ) then
          aFundPos.Positions.Add( aPos );
        aFundPos.RecoveryPos( aPos.Volume, aPos.AvgPrice);
      end ;     
    end;

  if pMain.Header.NextKind <> '0' then
  begin
    //gEnv.Engine.SendBroker.RequestAccountPos( aInvest, pMain.Header.NextKind );
    gEnv.EnvLog( WIN_TEST, Format('%s : Stand by Next 잔고', [ aInvest.Code ])   );
  end;

end;

procedure TApiReceiver.ParseDeposit( stData : string );

  var
    pMain : ROutAccountDeposit;
    aInvest : TInvestor;
    aAcnt : TAccount;
    aSymbol : TSymbol;
    i : integer;
    dFee, dFixedPL : double;
    aInvestPos, aPos : TPosition;
begin

  if Length( stData ) < Len_OutAccountDeposit then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  ROutAccountDeposit( stData  );

  i := StrToIntDef( trim( string( pMain.Header.WindowID )), -1);
  if i < 0 then Exit;
  aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
  if (aInvest = nil ) or ( aInvest.RceAccount = nil ) then  Exit;
  aAcnt := aInvest.RceAccount;

  dFixedPL := StrToFloat( trim( string( pMain.Fut_rsrb_pl )));
  dFee     := StrToFloat( trim( string( pMain.Fut_trad_fee )));

  aInvest.RecoverFees[dtUSD]  := dFee;
  aInvest.SetFixedPL( dtUSD, dFixedPL );

  aAcnt.RecoverFees[dtUSD]    := dFee;
  aAcnt.SetFixedPL( dtUSD ,dFixedPl );

  ///////////////////////////////////////
  aInvest.Deposit[dtUSD]   := StrToFloatDef( trim( string( pMain.Entr_ch )), 0);
  aInvest.WonDaeAmt[dtUSD] := StrToFloatDef( trim( string( pMain.tdy_repl_amt )), 0);
  aInvest.OpenPL[dtUSD]    := StrToFloatDef( trim( string( pMain.Pure_ote_amt )), 0);
  aInvest.UnBackAmt[dtUSD] := StrToFloatDef( trim( string( pMain.Dfr_amt )), 0);
  aInvest.DepositOTE[dtUSD]  := StrToFloatDef( trim( string( pMain.Te_amt )), 0);

  aInvest.TrustMargin[dtUSD] := StrToFloatDef( trim( string( pMain.Trst_mgn )), 0);
  aInvest.HoldMargin[dtUSD]  := StrToFloatDef( trim( string( pMain.Mnt_mgn )), 0);

  aInvest.OrderMargin[dtUSD] := StrToFloatDef( trim( string( pMain.Ord_mgn )), 0);
  aInvest.AddMargin[dtUSD]   := StrToFloatDef( trim( string( pMain.Add_mgn )), 0);

  aInvest.OrderAbleAmt[dtUSD] := StrToFloatDef( trim( string( pMain.Ord_psbl_amt )), 0);

  gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );


end;

procedure TApiReceiver.ParseReqHoga(stData: string);
var
  vData : POutSymbolHoga;
  aQuote: TQuote;
  aSymbol : TSymbol;

  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin
  if Length( stData ) < SizeOf( TOutSymbolHoga) then Exit;

  vData := POutSymbolHoga( stData );

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.FullCode )));
  if aSymbol = nil then Exit;
  {
  if aSymbol.Quote = nil then
  begin
    aQuote  :=  gEnv.Engine.QuoteBroker.Subscribe_kr(  gEnv.Engine.QuoteBroker,
      aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler );
  end;    }

  if aSymbol.Quote = nil then Exit;

  aQuote  := aSymbol.Quote as TQuote;
  stTime  := string( vData.Time );
  try

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloatDef( trim(string( vData.Arr[i].SellPrice )),0 );
      aQuote.Asks[i].Volume := StrToIntDef( trim(string( vData.Arr[i].SellQty )),0 );
      aQuote.Asks[i].Cnt    := StrToIntDef( trim(string( vData.Arr[i].SellNo )),0 );

      aQuote.Bids[i].Price  := StrToFloatDef( trim(string( vData.Arr[i].BuyPrice )),0);
      aQuote.Bids[i].Volume := StrToIntDef( trim(string( vData.Arr[i].BuyQty )),0);
      aQuote.Bids[i].Cnt    := StrToIntDef( trim(string( vData.Arr[i].BuyNo )),0);

    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.TotSellQty )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.TotBuyQty )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.TotSellNo )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.TotBuyNo )));
    dtQuote  := Date
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,4,2)), // min
                            StrToInt(Copy(stTime,7,2)), // sec
                            0 ); // msec};

   aQuote.Update(dtQuote);
  except
  end;

end;

procedure TApiReceiver.ParseHoga(stData: string);
var
  vData : PAutoSymbolHoga;
  aQuote: TQuote;
  stTime: string;
  i : integer;
  dtQuote : TDateTime;
begin
  if Length( stData ) < Len_AutoSymbolHoga then Exit;

  vData := PAutoSymbolHoga( stData );

  aQuote  := gEnv.Engine.QuoteBroker.Find( string(vData.FullCode) );
  if aQuote = nil then Exit;

    if aQuote.Symbol.ShortCode = 'ZWK6' then
      gEnv.OnLog( Self, 'aa');

  stTime  := string( vData.Time );

  try

   for i := 0 to aQuote.Asks.Size - 1 do
    begin
      aQuote.Asks[i].Price  := StrToFloat( trim(string( vData.Arr[i].SellPrice )));
      aQuote.Asks[i].Volume := StrToInt( trim(string( vData.Arr[i].SellQty )));
      aQuote.Asks[i].Cnt    := StrToInt( trim(string( vData.Arr[i].SellNo )));

      aQuote.Bids[i].Price  := StrToFloat( trim(string( vData.Arr[i].BuyPrice )));
      aQuote.Bids[i].Volume := StrToInt( trim(string( vData.Arr[i].BuyQty )));
      aQuote.Bids[i].Cnt    := StrToInt( trim(string( vData.Arr[i].BuyNo )));

    end;

    aQuote.Asks.VolumeTotal := StrToInt( trim(string( vData.TotSellQty )));
    aQuote.Bids.VolumeTotal := StrToInt( trim(string( vData.TotBuyQty )));

    aQuote.Asks.CntTotal := StrToInt( trim(string( vData.TotSellNo )) );
    aQuote.Bids.CntTotal := StrToInt( trim(string( vData.TotBuyNo )));
    dtQuote  := Date
               + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                            StrToInt(Copy(stTime,4,2)), // min
                            StrToInt(Copy(stTime,7,2)), // sec
                            0 ); // msec};

    aQuote.Update(dtQuote);
  except
  end;
end;

procedure TApiReceiver.ParseMarketPrice(stData: string);
var
  vData : POutSymbolMarkePrice;
  aSymbol : TSymbol;
  aQuote  : TQuote;
begin
  if Length( stData ) < Sizeof(TOutSymbolMarkePrice)  then Exit;

  try
    vData := POutSymbolMarkePrice( stData );
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string( vData.FullCode )));

    if aSymbol = nil then Exit;

 // if aSymbol.ShortCode = 'NGH6' then
  //  gEnv.OnLog( self, 'ngh6');

    aSymbol.Last  := StrToFloat( trim( string( vData.ClosePrice )));
    aSymbol.DayOpen := StrToFloat( trim( string( vData.OpenPrice )));
    aSymbol.DayHigh := StrToFloat( trim( string( vData.HighPrice )));
    aSymbol.DayLow  := StrToFloat( trim( string( vData.LowPrice )));
    aSymbol.PrevClose := StrToFloat( trim( string( vData.ClosePrice_1 )));

  //  gEnv.Engine.SendBroker.ReqSub( aSymbol );

    if aSymbol.Quote <> nil then
      (aSymbol.Quote as TQuote).UpdateCustom( now );

  except
  end;

end;

procedure TApiReceiver.ParsePrice(stData: string);
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

    aQuote  := gEnv.Engine.QuoteBroker.Find( string(vData.FullCode) );
    if aQuote = nil then Exit;

    if aQuote.Symbol.ShortCode = 'ZWK6' then
      gEnv.OnLog( Self, 'aa');

    stTime  := string( vData.Time );
    dtQuote  := Date
                 + EncodeTime(StrToInt(Copy(stTime,1,2)), // hour
                              StrToInt(Copy(stTime,4,2)), // min
                              StrToInt(Copy(stTime,7,2)), // sec
                              0 ); // msec};

    aQuote.DailyVolume  := StrToInt64( trim(string(vData.TotQty )));

    aSale := aQuote.Sales.New;
    aSale.LocalTime := now;
    aSale.Volume  := StrToInt64( trim(string( vData.ContQty )));
    aSale.Price   := StrToFloat( trim(string( vData.ClosePrice )));
    aSale.DayVolume := aQuote.DailyVolume;
    //aSale.DayAmount := aQuote.DailyAmount;
    aSale.Time  := dtQuote;

    if  vData.MatchKind = '+' then
      aSale.Side := 1
    else
      aSale.Side := -1;

    aQuote.Open := StrToFloat( trim(string( vData.OpenPrice )));
    aQuote.High := StrToFloat( trim(string( vData.HighPrice ))) ;
    aQuote.Low  := StrToFloat( trim(string( vData.LowPrice )));
    aQuote.Last := aSale.Price;
    aQuote.Change := StrToFloat( trim(string( vData.CmpPrice )));

    case vData.CmpSign of
      '2','4','6','8' : aQuote.Change := aQuote.Change * -1;
    end;

    aQuote.Update(dtQuote);

  except
  end;

end;




procedure TApiReceiver.ParseOrderAck(iTrCode: integer; strData: string);
  var
    aOrder : TOrder;
    iLocalNo : integer;
    iOrderNo : integer;
    aData : POutOrderPacket;
    aErr  : PErrorData;
    stRjt : string;
    aInvestor : TInvestor;
    aSymbol   : TSymbol;
begin

  try
    gEnv.EnvLog( WIN_PACKET, Format('Order_%d:%s', [  iTrCode, strData  ]) );

    aErr  :=  PErrorData( strData );
    CheckError( strData );

    stRjt :=  trim(string( aErr.Header.ErrorCode ));

    iLocalNo  := StrToInt(trim( string( aErr.Header.WindowID )));
    aOrder := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder2( iLocalNo );

    if aOrder = nil then begin
      gEnv.EnvLog( WIN_ORD, Format('Not Found LocalNo(%d) order : %s, %s', [
           iLocalNo, stRjt, strData  ]) );
      Exit;
    end;

    if( stRjt = '' ) or ( stRjt = '0000') then
    begin
      aData     := POutOrderPacket( strData );
      iOrderNo  := StrToInt( trim( string( aData.Order_No )));
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjt );
    end
    else begin
      gEnv.Engine.TradeBroker.SrvReject( aOrder, stRjt, trim(string(aErr.ErrorMsg)) );
    end;

  except
  end;

end;

procedure TApiReceiver.ParseOrder( strData: string);
  var
    bOutOrd : boolean;
    vData : PAutoOrderPacket;
    stRjtCode, stTmp, stSub : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    i, iSide, iStart, iOrderQty, iCount, iConfirmedQty , iAbleQty: integer;
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

    //gEnv.EnvLog( WIN_PACKET, Format('%s:%s', [ vData.ReplyType, strData])  );

    aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( string( vData.Account )) );
    if aInvest = nil then Exit;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim(string(vData.FullCode)));
    if aSymbol = nil then Exit;

    iOrderNo  := StrToInt64Def( trim(string(vData.Ord_no )),0);

    iOrderQty     := StrToIntDef( trim(string( vData.Qty )), 0);
    // '2' 일때는 체결수량  '3,4,5,6' 일때는..확인수량..
    iConfirmedQty := StrToIntDef( trim(string( vData.ExecQty )), 0);
    dPrice   := StrToFloatDef( trim(string( vData.Price )), 0);

    stRjtCode := trim( string( vData.Header.ErrorCode ));
    bAccepted := (iOrderNo > 0) and ( (stRjtCode = '0000') or (stRjtcode = ''))  ;

    stTmp  := trim( string( vData.TradeTime ));
    dtTime := Date +
                    EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                               StrToIntDef(Copy(stTmp,4,2),0),
                               StrToIntDef(Copy(stTmp,7,2),0), 0);

    iAbleQty  :=  StrToInTDef(trim(string( vData.Ordp_q )),0);

    aAccount  := aInvest.RceAccount;
    aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);

    // 주문로그
    gEnv.EnvLog( WIN_ORD,
      Format('%s : %s, 번호(%d) 주문(%s) 실행(%s) 남은(%s) 청산가(%s) 잔고(%s) 주문가(%s)', [ vData.ReplyType,
        stRjtCode, iOrderNo,
        trim(string( vData.Qty) ),trim(string( vData.ExecQty )),
        trim(string( vData.RemainQty )), trim(string( vData.Rsrb_q)),
        trim(string( vData.Open_q )),  trim(string( vData.Ordp_q )) ])
      );
    bOutOrd := false;
    // 외부 주문이란 애기
    if (aOrder = nil) then
    begin
      bOutOrd := true;

      //gEnv.EnvLog( WIN_ORD,      Format('외부 주문 !!'        );
      // 파싱...............
      iOriginNo := StrToInt64Def( string(vData.Orig_ord_no ),0);
      if vData.Side = '1' then
        iSide := 1
      else
        iSide := -1;

      iOrderQty := StrToInt( trim( string( vDAta.RemainQty )));
      dPrice  := StrToFloat( trim(string( vData.Price )));

      case vDAta.Modality of
        '1' : pcValue := pcLimit;
        '2' : pcValue := pcMarket;
      end;

      case vData.Validity of
        '1' : tmValue  := tmFAS;
        '2' : tmValue  := tmFOK;
        '3' : tmValue  := tmIOC;
        '4' : tmValue  := tmGTC;
      end;

      if vData.ReplyType = '0' then      
        case vData.ORD_TP of
          '1' : otValue := otNormal;
          '2' : otValue := otChange;
          '3' : otValue := otCancel;
        end
      else begin
        case vData.ReplyType of
          '1','2','5' : otValue := otNormal;
          '3','6' : otValue := otChange;
          '4','7' : otValue := otCancel;
        end;
      end;

      aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
        dPrice, iSide, iOrderQty );

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
    end;
    //.......
    case vData.ReplyType of
      '0'     : if aOrder <> nil then gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      '1','5' :
        begin
          //gEnv.Engine.TradeCore.Orders.Find()
          gEnv.Engine.TradeBroker.Accept( aOrder, bAccepted, stRjtCode, dtTime,iAbleQty );
        end;
      '2'     :
        begin

          dFilledPrice  := StrToFloat( trim( string( vData.ExecPrice )));
          aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aInvest, aSymbol, iOrderNo, orFilled, now,
                    StrToInt( trim(string( vData.Trd_no ))) , '',iConfirmedQty,
                    dFilledPrice, dtTime);
          gEnv.Engine.TradeBroker.Fill( aResult, dtTime,iAbleQty);
        end;
      '3','4','6','7' :
        begin
          aResult := gEnv.Engine.TradeCore.OrderResults.New(
                          aInvest, aSymbol, iOrderNo,
                          orConfirmed, Now, 0, stRjtCode, iConfirmedQty, dPrice, dtTime);
          gEnv.Engine.TradeBroker.Confirm(aResult, Now,iAbleQty);
        end;
    end;


  except
  end;

end;

end.
