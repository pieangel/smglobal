unit CleApiReceiver;

interface

uses
  Classes, SysUtils,

  CleQuoteBroker,  CleFunds,

  CleAccounts, CleOrders, CleSymbols, ClePositions,  ClePriceCrt,

  ApiPacket, ApiConsts
  ;

type
                                             {
    ESID_5611 ,  // ��ü��
    ESID_5612,	 // ���ܰ�
    ESID_5614,	 // ���º� �ֹ�ü����Ȳ
    ESID_5615 :  // ��Ź�ڻ�� ���ű�
                                             }
  TApiReceiver = class
  private
    function CheckError( stData : string ): boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ParseMarketPrice;
    procedure ParseReqHoga( winID : string );

    procedure ParsePrice( var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
    procedure ParseHoga( var s1, s2, s3,
      s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
      s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35,
      s36, s37: OleVariant);
    procedure ParseChartData( stData : string );

    procedure ParseActiveOrder;
    procedure ParsePosition;
    procedure ParseDeposit( idx : integer );
    procedure ParseAbleQty( stData : string );

    procedure ParseTickSize;

    procedure ParseOrderAck( iID : integer; stData : string );
    procedure ParseOrder( var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant );
    procedure ParseRealPos( var s1, s2, s3,
      s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
      s21, s22 : OleVariant );

    procedure ProcessAccountList;

  end;

var
  gReceiver : TApiReceiver;

implementation

uses
  GAppEnv , GleLib, GleTypes, GleConsts, CleKrxSymbols, Ticks,
  Math ,
  CleMarketSpecs
  ;

{ TApiReceiver }

function TApiReceiver.CheckError(stData: string): boolean;
var
  //vErr : PErrorData;
  stRjt: string;
begin
  Result := true;
 {
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
  end;  }
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
  //vData : POutAbleQty;
  aInvest : TInvestor;
  aAcnt   : TAccount;
  aSymbol : TSymbol;
  aPosition, aTmpPos: TPosition;
  I: Integer;

begin
{
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

  // ������� �����ǿ��� �ֹ����ɼ� ����
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
  }
  
end;

procedure TApiReceiver.ParseActiveOrder;
var

  i, iCnt : integer;
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

  aInvest : TInvestor;

  count: Integer;
  winID: OleVariant;
  flag: OleVariant;
begin
  winID := '2';
  flag := '0';

  with gEnv.Engine.Api do
  begin
    count := GetDataCount(winID);
    if (count = 0) then Exit;

    for i := 1 to count do
    begin
      aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( GetGridString(winID, flag, 'o_acno', i)));
      if (aInvest = nil) or ( aInvest.RceAccount = nil ) then Exit;
      aAccount  := aInvest.RceAccount;
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(trim(GetGridString(winID, flag, 'o_code', i)));                     //** �����ڵ�
      if aSymbol = nil then Continue;

      iOrderNo := StrToInt64Def(GetGridString(winID, flag, 'o_jmno', i),0);            //** �ֹ���ȣ
      iOriginNo := StrToInt64Def(GetGridString(winID, flag, 'o_ojno', i),0);           //** �ֹ���ȣ

      aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
      if aOrder = nil then
      begin
      //Cells[1, i] := GetGridString(winID, flag, 'o_stat', i);                     //** �ֹ�����
        iTmp := StrToInt(GetGridString(winID, flag, 'o_type', i));       //** �ֹ�����
        case iTmp of
          1 : pcValue := pcMarket;
          2 : pcValue := pcLimit;
        end;

        iTmp := StrToInt(GetGridString(winID, flag, 'o_mdms', i));       //** �Ÿű���
        case iTmp of
          1 : iSide := 1;
          2 : iSide := -1;
        end;
        iOrderQty := StrToInt(GetGridString(winID, flag, 'o_jqty', i));        //** �ֹ�����
        //dPrice    := StrToFloat(GetGridString(winID, flag, 'o_jprc', i));      //** �ֹ�����
        dPrice    := aSymbol.PriceCrt.GetDouble(GetGridString(winID, flag, 'o_jprc', i));      //** �ֹ�����
        stTime    := trim( GetGridString(winID, flag, 'o_time', i) );
        if stTime <> '' then
          dtAcptTime  := Date + EncodeTime( StrToInt( Copy( stTime, 1, 2 )),
                                          StrToInt( Copy( stTime, 3, 2 )),
                                          StrToInt( Copy( stTime, 5, 2 )), 0);
        stTmp   := GetGridString(winID, flag, '0_mtno', i);        //**�����׷�

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
        aOrder  := gEnv.Engine.TradeCore.Orders.NewRecoveryOrder( gEnv.ConConfig.UserID,
                                                                    aAccount,
                                                                    aSymbol,
                                                                    iSide,  iOrderQty,
                                                                    pcValue,
                                                                    dPrice,
                                                                    tmFAS,
                                                                    aTicket,
                                                                    iOrderNo
                                                                    );

        if aOrder <> nil then
        begin
          gEnv.Engine.TradeBroker.Accept( aOrder, true, '', dtAcptTime );
          gEnv.EnvLog( WIN_PACKET, Format('ActiveOrder(%d:%d):%s', [ iCnt,i, aOrder.Represent2  ])  );
        end;
      end;
    end;
  end;

end;


procedure TApiReceiver.ParseChartData(stData: string);
  var       {
    pMain : POutChartData;
    pSub  : POutChartDataSub;  }
    aSymbol : TSymbol;
    iHour, i, iCount, iMMIndex, iNextMMIndex,iStart, iMin : integer;
    stSub, stTmp : string;
    bAddTerm  : boolean;
    aQuote : TQuote;
    dtDate, dtTime : TDateTime;
    aItem  : TSTermItem;
    wHH, wMM, wSS, wCC : word;
begin
        {
  if Length( stData ) < Len_OutChartData then Exit;
  if not CheckError( stData ) then
    Exit;

  pMain :=  POutChartData( stData );
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( string( pMain.FullCode )));
  if (aSymbol = nil )  then  Exit;
  if aSymbol.Quote = nil then Exit;
  
  iCount  := StrToIntDef( trim( string( pMain.DayCnt)), 0);

  gEnv.EnvLog( WIN_TEST, Format('%s : �������� (%.*n) -> %d ',[
    trim(string( pMain.Today)), aSymbol.Spec.Precision, StrToFloat( trim( string( pMain.PrevLast ))),
    icount]));

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
             {
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
            }      {
  end;

  if (i > 0) then
  begin
    if iMin = 60 then
      aQuote.CalceATRValue;
    if (iMin = 5) or ( iMin = 1) then
      aQuote.Terms.CalcePrevATR;
    aQuote.UpdateChart( iMin );
  end;
           }
end;

procedure TApiReceiver.ParsePosition;
var
  aInvest : TInvestor;
  aAcnt, tmpAcnt : TAccount;
  aSymbol : TSymbol;
  i, iSide, iCount, iPrevVolume, iVolume : integer;
  dOpenPL, dAvgPrice, dPrice, dTmp : double;
  stTmp, stSub : string;
  aInvestPos, aPos : TPosition;
  aFund : TFund;
  aFundPos : TFundPosition ;

  idx, iCnt: Integer;
  winID: OleVariant;
  flag: OleVariant;
begin

  winID := '2';
  flag := '0';

  with gEnv.Engine.Api do
  begin

    iCnt := GetDataCount( winID );
    for i := 1 to iCnt do
    begin
      stTmp   := trim( GetGridString(winID, flag, 'o_acno', i) );
      aInvest := gEnv.Engine.TradeCore.Investors.Find( stTmp );
      stTmp   := trim( GetGridString(winID, flag, 'o_code', i) );
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stTmp );

      if ( aInvest = nil ) or ( aSymbol = nil ) then Continue;

      aAcnt := aInvest.RceAccount;
      stTmp   := GetGridString(winID, flag, 'o_mdms', i);
      if stTmp = '1' then
        iSide := 1
      else
        iSide := -1;

      iVolume     := StrToIntDef( GetGridString(winID, flag, 'o_pqty', i), 0);        //** �̰�������
      iPrevVolume := StrToIntDef( GetGridString(winID, flag, 'o_rqty', i), 0 );       //** ���� �̰�������
      dAvgPrice := aSymbol.PriceCrt.GetDouble( GetGridString(winID, flag, 'o_avgc', i));       //** ��հ�
      dPrice    := aSymbol.PriceCrt.GetDouble( GetGridString(winID, flag, 'o_lprc', i));        //** ���簡
      dOpenPL   := aSymbol.PriceCrt.GetDouble( GetGridString(winID, flag, 'o_pamt', i));        //** �򰡼���

      dTmp    :=  StrToFloatDef( GetGridString(winID, flag, 'o_tval', i),1);
      aSymbol.Spec.SetTickValue(dTmp);

      aPos  := gEnv.Engine.TradeCore.Positions.Find( tmpAcnt, aSymbol );
      if aPos = nil then
      begin
        aPos := gEnv.Engine.TradeCore.Positions.New(aAcnt, aSymbol);
        gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_NEW);
      end;

      aPos.SetPosition( iVolume * iSide, dAvgPrice, 0);
      aPos.EntryOTE := dOpenPL;
      gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker,
          aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler );

      aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.Find( aInvest, aSymbol);
      if aInvestPos = nil then
        aInvestPos  := gEnv.Engine.TradeCore.InvestorPositions.New( aInvest, aSymbol );

      if aInvestPos <> nil then
      begin
        aInvestPos.SetPosition(iVolume * iSide, dAvgPrice,0);
        aInvestPos.EntryOTE := dOpenPL;
      end;
      gEnv.Engine.TradeBroker.PositionEvent( aPos, POSITION_UPDATE);

      // fund poistion
      aFund := gEnv.Engine.TradeCore.Funds.Find( aAcnt );
      if aFund <> nil then
      begin
        aFundPos  := gEnv.Engine.TradeCore.FundPositions.Find( aFund, aSymbol  );
        if aFundPos = nil then
          aFundPos := gEnv.Engine.TradeCore.FundPositions.New( aFund, aSymbol);

        if not aFundPos.Positions.FindPosition( aPos ) then
          aFundPos.Positions.Add( aPos );
        aFundPos.RecoveryPos( aPos.Volume, aPos.AvgPrice);
      end ;
    end;  // for i=0


  end;

end;

procedure TApiReceiver.ParseDeposit( idx : integer );

  var
    aInvest : TInvestor;
    aAcnt : TAccount;
    aSymbol : TSymbol;
    i, iCnt : integer;
    dFee, dFixedPL : double;
    aInvestPos, aPos : TPosition;

    winID: OleVariant;
    flag: OleVariant;
    aType  : TDepositType;
    stType : string;
begin

  winID := '2';
  flag := '0';

  aInvest := gEnv.Engine.TradeCore.Investors.Investor[idx];
  if aInvest = nil then Exit;

  aAcnt := aInvest.RceAccount;

  with gEnv.Engine.Api do
  begin
    iCnt := GetDataCount( winID );
    with aInvest do
    begin

      for i := 1 to iCnt  do
      begin

        stType := GetGridString(winID, flag, 'curr', i);
        if stType = 'USD' then
          aType  := dtUSD
        else continue;

        Deposit[aType]     := StrToFloatDef( GetGridString(winID, flag, 'ytkm', i), 0);     // ���Ͽ�Ź���ܾ�
        SetFixedPL(aType, StrToFloatDef( GetGridString(winID, flag, 'cson', i), 0));     // û�����
        aAcnt.SetFixedPL(aType, FixedPL[aType]);
        RecoverFees[aType] := abs( StrToFloatDef(GetGridString(winID, flag, 'susu', i), 0));     // ������
        OpenPL[aType]      := StrToFloatDef(GetGridString(winID, flag, 'pson', i), 0);     // �򰡼���
        DepositOTE[aType]  := StrToFloatDef(GetGridString(winID, flag, 'ytpm', i), 0);     // ��Ź�ڻ��򰡾�
        UnBackAmt[aType]   := StrToFloatDef(GetGridString(winID, flag, 'misu', i), 0);     // �̼���

        OrderMargin[aType] := StrToFloatDef(GetGridString(winID, flag, 'jgkm', i), 0);    // �ֹ����ɱݾ�
        TrustMargin[aType] := StrToFloatDef(GetGridString(winID, flag, 'mrg1', i), 0);    // ��Ź���ű�
        HoldMargin[aType]  := StrToFloatDef(GetGridString(winID, flag, 'mrg2', i), 0);    // �������ű�
        AddMargin[aType]   := StrToFloatDef(GetGridString(winID, flag, 'mrg3', i), 0);    // �߰����ű��ʿ��
      end;

      flag := '1';
      aType  := dtWON;
      Deposit[aType]     := StrToFloatDef( GetGridString(winID, flag, 'ytkm_o', 0), 0);     // ���Ͽ�Ź���ܾ�
      SetFixedPL(aType, StrToFloatDef( GetGridString(winID, flag, 'cson_o', 0),0));     // û�����
      aAcnt.SetFixedPL(aType, FixedPL[aType]);
      RecoverFees[aType]  := abs( StrToFloatDef(GetGridString(winID, flag, 'susu_o', 0), 0));     // ������
      OpenPL[aType]      := StrToFloatDef(GetGridString(winID, flag, 'pson_o', 0), 0);     // �򰡼���
      DepositOTE[aType]  := StrToFloatDef(GetGridString(winID, flag, 'ytpm_o', 0), 0);     // ��Ź�ڻ��򰡾�
      UnBackAmt[aType]   := StrToFloatDef(GetGridString(winID, flag, 'misu_o', 0), 0);     // �̼���

      OrderMargin[aType] := StrToFloatDef(GetGridString(winID, flag, 'jgkm_o', 0), 0);    // �ֹ����ɱݾ�
      TrustMargin[aType] := StrToFloatDef(GetGridString(winID, flag, 'mrg1_o', 0), 0);    // ��Ź���ű�
      HoldMargin[aType]  := StrToFloatDef(GetGridString(winID, flag, 'mrg2_o', 0), 0);    // �������ű�
      AddMargin[aType]   := StrToFloatDef(GetGridString(winID, flag, 'mrg3_o', 0), 0);    // �߰����ű��ʿ��

    end;
  end;       

  aAcnt.RecoverFees[dtUSD]    := aInvest.RecoverFees[dtUSD];
  aAcnt.RecoverFees[dtWON]    := aInvest.RecoverFees[dtWON];

  gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_DEPOSIT );

end;

// ���δ� �ǽð� ������...�� �ش�.
// �ֹ��� ����ȭ�� ��� ����� �ϳ�..
// �� tick ��ġ��..���� �Ѵ�..
procedure TApiReceiver.ParseRealPos(var s1, s2, s3, s4, s5, s6, s7, s8, s9, s10,
  s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22: OleVariant);
  var
    aSymbol : TSymbol;
    aPos    : TPosition;
    dValue  : double;
  I: Integer;
begin

  try

    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( s3 ));
    if aSymbol = nil then Exit;

    if aSymbol.Spec.IsUpdate then Exit;
    dValue := StrToFloatDef( trim( s12 ), 1 );
    if dValue < EPSILON then Exit;
    aSymbol.Spec.SetTickValue( dValue );

    for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.Positions.Positions[i];
      aPos.CaclOpePL( aPos.Symbol.Last );
    end;


  except
  end;

end;

procedure TApiReceiver.ParseReqHoga(winID: string);
var

  aQuote: TQuote;
  aSymbol : TSymbol;
  stTime: string;
  col, i : integer;
  dtQuote : TDateTime;
begin

  try
    with gEnv.Engine.Api do
    begin
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( GetString( winID, 'ItemCd')) );
      if aSymbol = nil then Exit;

      if StrToInt( winID ) >= gEnv.Engine.SymbolCore.SymbolLoader.Idx then
      begin
        gEnv.EnvLog( WIN_TEST,  Format('��������  %s - %s %s %s', [ winID, aSymbol.Code, aSymbol.Name, aSymbol.Spec.FQN ])  );
        gEnv.Engine.SymbolCore.RegisterMuchSymbol(aSymbol);
      end;

      if aSymbol.Quote = nil then Exit;
      aQuote  := aSymbol.Quote as TQuote;

      aSymbol.Last  := aSymbol.PriceCrt.GetDouble( GetString( winID, 'Curr'));// GetDouble(winID, 'Curr');
      aSymbol.DayOpen := aSymbol.PriceCrt.GetDouble( GetString(winID, 'Open'));
      aSymbol.DayHigh := aSymbol.PriceCrt.GetDouble( GetString(winID, 'High'));
      aSymbol.DayLow  := aSymbol.PriceCrt.GetDouble( GetString(winID, 'Low'));
      aSymbol.PrevClose := aSymbol.PriceCrt.GetDouble( GetString(winID, 'PreviousClose'));

      {
      if aSymbol.Quote <> nil then
        (aSymbol.Quote as TQuote).UpdateCustom( now );
      }
      for i := 0 to aQuote.Asks.Size - 1 do
      begin
        col := i + 1;
        aQuote.Asks[i].Price  := aSymbol.PriceCrt.GetDouble( GetString(winID, Format('SellHoga%d', [col])));
        aQuote.Asks[i].Volume := GetInt(winID, Format('SellQty%d', [col]));
        aQuote.Asks[i].Cnt    := GetInt(winID, Format('SellCount%d', [col]));

        aQuote.Bids[i].Price  := aSymbol.PriceCrt.GetDouble( GetString(winID, Format('BuyHoga%d', [col])));
        aQuote.Bids[i].Volume := GetInt(winID, Format('BuyQty%d', [col]));
        aQuote.Bids[i].Cnt    := GetInt(winID, Format('BuyCount%d', [col]));
      end;

      stTime  :=  GetString(winID, 'HogaTime');      
      dtQuote  := Date
                 + EncodeTime(StrToIntDef(Copy(stTime,1,2),0), // hour
                              StrToIntDef(Copy(stTime,4,2),0), // min
                              StrToIntDef(Copy(stTime,7,2),0), // sec
                              0 ); ;

      aQuote.Asks.VolumeTotal := GetInt(winID, 'SellQtyTotal');
      aQuote.Asks.CntTotal    := GetInt(winID, 'SellCountTotal');

      aQuote.Bids.VolumeTotal := GetInt(winID, 'BuyQtyTotal');
      aQuote.Bids.CntTotal    := GetInt(winID, 'BuyCountTotal');
    end;
    aQuote.UpdateCustom( dtQuote );
  except
  end;
end;

procedure TApiReceiver.ParseTickSize;
var
  winID: OleVariant;
  flag: OleVariant;
  dTmp, dtmp2, dSize : string;
  i,iSize, iCnt : integer;
  code : string;
  aCrt  : TPriceCrt;
  aSpec : TMarketSpec;
  aDepth: TTSizeDepth;
begin
  //

  winID := '2';
  flag := '0';

  with gEnv.Engine.Api do
  begin
    iCnt := GetDataCount( winID );
    gEnv.EnvLog( WIN_GI, IntToStr( iCnt ) + ' ƽ������ ���� ');

    for I := 1 to iCnt  do
    begin
      code := GetGridString(winID, flag, 'o_commd_cd', i);
      aSpec := gEnv.Engine.SymbolCore.Specs.Find2( code );
      if aSpec = nil then Continue;
      if aSpec.PriceCrt = nil then Continue;
      
      dTmp :=   GetGridString(winID, flag, 'o_start_price', i);
      dTmp2 :=   GetGridString(winID, flag, 'o_end_price', i);
      dSize :=   GetGridString(winID, flag, 'o_tick_size', i);

      aDepth  := aSpec.TSizes.New;
      aDepth.StartPrc  :=  (aSpec.PriceCrt as TPriceCrt).GetDouble( dTmp );
      aDepth.EndPrc    :=  (aSpec.PriceCrt as TPriceCrt).GetDouble( dTmp2 );
      aDepth.Size      :=  (aSpec.PriceCrt as TPriceCrt).GetDouble( dSize );

      gEnv.EnvLog( WIN_GI, Format('%s, %s, %s, %s, %.6f,%.6f,%.6f', [ code, dSize,
      dTmp, dTmp2  ,  (aSpec.PriceCrt as TPriceCrt).GetDouble( dSize ),
      (aSpec.PriceCrt as TPriceCrt).GetDouble( dTmp ),(aSpec.PriceCrt as TPriceCrt).GetDouble( dTmp2 )

      ])  );
    end;
  end;
end;

procedure TApiReceiver.ProcessAccountList;
  var
  winID: OleVariant;
  flag: OleVariant;
  i, idx, iCnt : integer;
  stLog, code, name : string;
begin
  // winID, flag ���� �� 2, 0 ���� �ϴ� �𸣰ڴ�.
  // flag �� ��, ���� �ǹ��ϴ°� �����ѵ�..winID �� ����.
  winID := '2';
  flag  := '0';
  stLog := '';

  with gEnv.Engine.Api do
  begin

    iCnt := GetDataCount( winID );
    for I := 1 to iCnt  do
    begin
      code := GetGridString(winID, flag, 'o_acno', i);
      name := GetGridString(winID, flag, 'o_acnm', i);
      if ( code <> '' ) and ( name <> '' ) then begin
        gEnv.Engine.TradeCore.Investors.New( code, name);
        stLog := stLog + ' ' + code + ', ' + name + ' | ';
      end;
    end;
  end;

  gLog.Add( lkApplication, 'TApiReceiver', 'ProcessAccountList',   Format('%d ���� ���¼��� : %s  ', [ iCnt, stLog ])) ;

  gEnv.SetAppStatus( asRecoveryStart );

end;

procedure TApiReceiver.ParseHoga(var s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35,
  s36, s37: OleVariant);
var
  aQuote: TQuote;
  stTime: string;  
  dtQuote : TDateTime;
  aCrt  : TPriceCrt;
begin

  try
    aQuote  := gEnv.Engine.QuoteBroker.Find( s1 );
    if aQuote = nil then Exit;

    aCrt  := aQuote.Symbol.PriceCrt;
    
    stTime := s3;
    dtQuote  := Date
               + EncodeTime(StrToIntDef(Copy(stTime,1,2),0), // hour
                            StrToIntDef(Copy(stTime,4,2),0), // min
                            StrToIntDef(Copy(stTime,7,2),0), // sec
                            0 ); // msec};

    aQuote.Asks[0].price := aCrt.GetDouble(s4);
    aQuote.Asks[0].Volume := StrToIntDef(s5,0);
    aQuote.Asks[0].Cnt := StrToIntDef(s6,0);
    aQuote.Asks[1].price := aCrt.GetDouble(s7);
    aQuote.Asks[1].Volume := StrToIntDef(s8,0);
    aQuote.Asks[1].Cnt := StrToIntDef(s9,0);
    aQuote.Asks[2].price := aCrt.GetDouble(s10);
    aQuote.Asks[2].Volume := StrToIntDef(s11,0);
    aQuote.Asks[2].Cnt := StrToIntDef(s12,0);
    aQuote.Asks[3].price := aCrt.GetDouble(s13);
    aQuote.Asks[3].Volume := StrToIntDef(s14,0);
    aQuote.Asks[3].Cnt := StrToIntDef(s15,0);
    aQuote.Asks[4].price := aCrt.GetDouble(s16);
    aQuote.Asks[4].Volume := StrToIntDef(s17,0);
    aQuote.Asks[4].Cnt := StrToIntDef(s18,0);

    aQuote.Bids[0].price := aCrt.GetDouble(s19);
    aQuote.Bids[0].Volume := StrToIntDef(s20,0);
    aQuote.Bids[0].Cnt := StrToIntDef(s21,0);
    aQuote.Bids[1].price := aCrt.GetDouble(s22);
    aQuote.Bids[1].Volume := StrToIntDef(s23,0);
    aQuote.Bids[1].Cnt := StrToIntDef(s24,0);
    aQuote.Bids[2].price := aCrt.GetDouble(s25);
    aQuote.Bids[2].Volume := StrToIntDef(s26,0);
    aQuote.Bids[2].Cnt := StrToIntDef(s27,0);
    aQuote.Bids[3].price := aCrt.GetDouble(s28);
    aQuote.Bids[3].Volume := StrToIntDef(s29,0);
    aQuote.Bids[3].Cnt := StrToIntDef(s30,0);
    aQuote.Bids[4].price := aCrt.GetDouble(s31);
    aQuote.Bids[4].Volume := StrToIntDef(s32,0);
    aQuote.Bids[4].Cnt := StrToIntDef(s33,0);

    aQuote.Asks.VolumeTotal := StrToIntDef(s34,0);
    aQuote.Bids.VolumeTotal := StrToIntDef(s35,0);
    aQuote.Asks.CntTotal := StrToIntDef(s36,0);
    aQuote.Bids.CntTotal := StrToIntDef(s37,0);

    aQuote.Update(dtQuote);


    
  except
    //if s1 = 'CLM16' then
  gEnv.EnvLog( WIN_TEST,
  Format('Hoga:%s,%s, %s,' +
         '%s,%s, %s, %s, %s, %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,' +
         '%s,%s, %s, %s, %s, %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,' +
         '%s, %s',[
  s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35,
  s36, s37         ]));
  end;

end;

procedure TApiReceiver.ParseMarketPrice;
var
  //vData : POutSymbolMarkePrice;
  aSymbol : TSymbol;
  aQuote  : TQuote;
begin
{
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

  //  gEnv.Engine.SendBroker.ReqSub( aSymbol );

    if aSymbol.Quote <> nil then
      (aSymbol.Quote as TQuote).UpdateCustom( now );

  except
  end;
   }
end;

procedure TApiReceiver.ParsePrice(  var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
var
  aQuote: TQuote;
  aSale: TTimeNSale;
  dtQuote : TDAteTime;
  stTime  : string;
  askPrice : double;
  aCrt  : TPriceCrt;
begin

  try
    aQuote  := gEnv.Engine.QuoteBroker.Find( s1 );
    if aQuote = nil then Exit;

    aCrt  := aQuote.Symbol.PriceCrt;

    stTime  := s14;
    dtQuote  := Date
                 + EncodeTime(StrToIntDef(Copy(stTime,1,2),0), // hour
                              StrToIntDef(Copy(stTime,3,2),0), // min
                              StrToIntDef(Copy(stTime,5,2),0), // sec
                              0 ); // msec};    

    aSale := aQuote.Sales.New;
    aSale.LocalTime := now;
    aSale.Price := aCrt.GetDouble(s4);

    if  s8 = '1' then
      aSale.Side := 1
    else if s8 = '2' then
      aSale.Side := -1
    else
      aSAle.Side := 0;

    aSale.Volume := StrToIntDef(s9,0);
    aSale.DayVolume := StrToIntDef(s10,0);
    aSale.Time  := dtQuote;

    aQuote.Open := aCrt.GetDouble(s11);
    aQuote.High := aCrt.GetDouble(s12);
    aQuote.Low  := aCrt.GetDouble(s13);
    aQuote.Last := aSale.Price;
    //aQuote.Change := StrToFloat(s6);
    aQuote.DailyVolume  := aSale.DayVolume;

    aQuote.Update(dtQuote );

  except
    //if s1 = 'CLM16' then
       
    gEnv.EnvLog( WIN_GI,
    format('price: %s, %s, %s, ' +
           '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, ' +
           '%s, %s, %s',[
            s1, s2, s3, s4,
            s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
            s20, s21, s22      ])
            );
  end;

end;




procedure TApiReceiver.ParseOrderAck( iID : integer; stData : string );
  var
    aOrder : TOrder;
    iOrderNo : integer;
    stRjt : string;
    sIsError, sMessage, stjm  : string;
    bFailed: boolean;

    winID: OleVariant;
    flag: OleVariant;
begin

  sIsError := Trim(Copy(stData, 1, 1));
  bFailed := (sIsError <> '1');// or (pstr = '���� �Ǿ����ϴ�.');

  aOrder := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder2( iID );

  if aOrder = nil then begin
    gEnv.EnvLog( WIN_ORD, Format('Not Found LocalNo order : %s, %s', [
         stRjt, stData  ]) );
    Exit;
  end;

  try
    if bFailed then
    begin
      sMessage := Trim(Copy(stData, 2, Length(stData) - 1));
      gLog.Add( lkError,'', '', sMessage) ;
      gEnv.Engine.TradeBroker.SrvReject( aOrder, '9999', sMessage );
    end else
    begin
      winID := '2';
      flag  := '1';
      stRjt := '';
      stjm  := gEnv.Engine.Api.GetGridString(winID, flag, 'Jmno', 0);
      iOrderNo  := StrToInt( trim( stjm ));
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjt );
    end;

  except
  end;

end;

procedure TApiReceiver.ParseOrder( var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
  var

    stDiv , stRjtCode, stTmp, stSub : string;
    aInvest : TInvestor;
    aAccount: TAccount;
    aSymbol : TSymbol;
    iOrderNo, iOriginNo : int64;
    i, iSide, iStart, iRemQty, iOrderQty, iCount, iConfirmedQty , iFillQty: integer;
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
  // 10, 20, 30 ---> ���� ����....
  // ���� ����  0   ü�����  0 �̸�..���ֹ� ��� ( ���� or ��� �϶� );;
  try

    aInvest := gEnv.Engine.TradeCore.Investors.Find( trim( s1) );
    if aInvest = nil then Exit;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( trim( s3 ));
    if aSymbol = nil then Exit;

    iOrderNo  := StrToInt64Def( trim(s4),0);
    iOrderQty     := StrToIntDef( trim(s8), 0);

    iFillQty := StrToIntDef( trim(s12), 0);
    iRemQty  := StrToIntDef( trim(s9), 0 );
    dPrice   := aSymbol.PriceCrt.GetDouble( trim(s7));

    stDiv   := trim(s18);

    stRjtCode := '';
    bAccepted := true;
    if stDiv = '90' then
    begin
      stRjtCode := '9999';
      bAccepted := false;
    end;

    if iFillQty > 0 then
      stDiv := '80';

    stTmp  := trim( s17 );
    dtTime :=  Date +
                    EncodeTime(StrToIntDef(Copy(stTmp,1,2),0),
                               StrToIntDef(Copy(stTmp,3,2),0),
                               StrToIntDef(Copy(stTmp,5,2),0),
                               0);

    aAccount  := aInvest.RceAccount;
    aOrder  := gEnv.Engine.TradeCore.Orders.FindINvestorOrder( aInvest, aSymbol, iOrderNo);
    // �ֹ� ����
    // 10, 11........20,21........30,31.........90 : �ź�
    gEnv.EnvLog( WIN_ORD,
      Format('%s : ��ȣ(%s) %s, %s, ����(%s) ����(%s) ����(%s) (%s)', [
        s14,  s4, s5, s7,  s8, s12, s9 , s21      ])      );

    //if ( iRemQty = 0 ) and ( iFillQty = 0 ) then
    //if aOrder.State in [ osRejected, osFilled, osCanceled,
    //             osConfirmed, osFailed ] then Exit;
    

    // �ܺ� �ֹ��̶� �ֱ�
    if (aOrder = nil) then
    begin

      // �Ľ�...............
      iOriginNo := StrToInt64Def( trim(s15) ,0);
      stTmp     := trim( s5 );
      if stTmp = '1' then
        iSide := 1
      else
        iSide := -1;

      stTmp  := trim( s13 );
      if stTmp = '1' then
        pcValue := pcMarket
      else if stTmp = '2' then
        pcValue := pcLimit
        ;
        {
      else if stTmp = '3' then
      else if stTmp = '4' then
         }
      stTmp  := trim( s11 );
      if stTmp = '1' then
        tmValue := tmGTC
      else if stTmp = '0' then
        tmValue := tmGFD
      else if stTmp = '6' then
        tmValue := tmGTD
      else tmValue := tmGTC;

      if (stDiv = '10') or ( stDiv = '11') then
        otValue := otNormal
      else if (stDiv = '20') or ( stDiv = '21') then
        otValue := otChange
      else if (stDiv = '30') or ( stDiv = '31') then
        otValue := otCancel;

      aOrder  := gEnv.Engine.TradeCore.Orders.NewOrders.FindOrder( aInvest.Code, aSymbol,
        dPrice, iSide, iOrderQty );

      if aOrder = nil then
      begin
        gEnv.EnvLog( WIN_ORD, '�ܺ��ֹ�..!!!');
        // �ֹ� ����...............
        if otValue in [otChange, otCancel] then
        begin
          aTarget := gEnv.Engine.TradeCore.Orders.Find(aAccount, aSymbol, iOriginNo);
          if aTarget = nil then
          begin
            gEnv.Engine.TradeBroker.ForwardAccepts.New(aAccount, aSymbol, iOriginNo, iOrderNo, iOrderQty,
                                                    dPrice, otValue, pcValue, bAccepted,
                                                    stRjtCode, dtTime);

            gEnv.EnvLog( WIN_ORD, format('���ֹ� ��ã�� : ��ȣ%d(%d),%d', [ iOrderNo, iOriginNo, iOrderQty])  );
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
        genv.EnvLog( WIN_ORD, Format('�ֹ����� - (%d)%s ',[ iOrderNo, aOrder.Represent2 ])         );
      if aOrder = nil then Exit;
      // �������� ó��.....................
      gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
    end;
    //.......
    case StrToInt( stDiv ) of
      // ���� ����...
      10, 20, 30 : if ( aOrder <> nil) and (aOrder.State in [ osSent, osReady] ) then gEnv.Engine.TradeBroker.SrvAccept( aOrder, iOrderNo, stRjtCode);
      11, 90 : gEnv.Engine.TradeBroker.Accept( aOrder, bAccepted, stRjtCode, dtTime );
      80    :
        begin

          dFilledPrice  := aSymbol.PriceCrt.GetDouble( trim( s19));
          aResult := gEnv.Engine.TradeCore.OrderResults.New(
                    aInvest, aSymbol, iOrderNo, orFilled, now,
                    // ü���ȣ�� ��ü..�� ���ִ°�
                    gEnv.Engine.TradeCore.OrderResults.Count , '',iFillQty,
                    dFilledPrice, dtTime);
          gEnv.Engine.TradeBroker.Fill( aResult, dtTime );
        end;
      21,31 :
        begin
          aResult := gEnv.Engine.TradeCore.OrderResults.New(
                          aInvest, aSymbol, iOrderNo,
                          orConfirmed, Now, 0, stRjtCode, iOrderQty, dPrice, dtTime);
          gEnv.Engine.TradeBroker.Confirm(aResult, Now );
        end;
    end;


  except
  end;

end;

end.
