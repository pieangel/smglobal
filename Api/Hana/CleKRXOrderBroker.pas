unit CleKRXOrderBroker;

interface

uses
  Classes, SysUtils,

    // lemon: common
  GleLib,Gletypes, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleTradeCore, CleOrders,
    //
  cleAccounts,

  CleQuoteBroker,

  SynThUtil, ApiPacket ;


const

  ORDER_BUF_SIZE = 100;

type

  TReqItem = class
  public
    Invest : TInvestor;
    Symbol : TSymbol;
    TrCode : integer;
    Seq    : integer;

    constructor Create;
  end;

  TKRXOrderBroker = class
  private

    FDebug: Boolean;
    FVerbose: Boolean;

    FOnFOTrade    : TSendPacketEvent;

    procedure Packet(aOrder: TOrder;var Buffer : array of char );

    procedure OnSub(aQuote: TQuote);
    procedure OnUnSub(aQuote: TQuote);
    function GetResCode( aSymbol : TSymbol ): string;

  public
    constructor Create;
    destructor Destroy; override;

    function Send(aTicket: TOrderTicket): Integer;
    procedure init;

    procedure RequestAccountFill( aAccount : TAccount; bPush : boolean = false ) ;
    procedure RequestAccountPos( aAccount : TAccount; bPush : boolean = false) ;
    procedure RequestAccountDeposit( aAccount : TAccount; bPush : boolean = false );

    procedure RequestAccountData( aAccount: TAccount; aType : TApiEventType; bPush : boolean = false ); overload;
    procedure RequestAccountData( aType : TApiEventType ); overload;
    procedure RequestAccountData; overload;
    procedure RequestAccountData2;

    procedure RequestMarketPrice(stCode: string; iIndex : integer; bPush : boolean = false);
    procedure RequestMarketHoga(stCode: string; iIndex : integer; bPush : boolean = false);
    procedure RequestSymbolData( aSymbol : TSymbol );

    procedure ReqSub( aSymbol : TSymbol );

    procedure ReqAbleQty( aInvest : TInvestor; aSymbol : TSymbol );

    property OnFOTrade : TSendPacketEvent read FOnFOTrade write FOnFOTrade;
  end;

implementation

uses
  GAppEnv,ApiConsts
  ;


constructor TKRXOrderBroker.Create;
begin
  FDebug := False;
  FVerbose := False;
end;

destructor TKRXOrderBroker.Destroy;
begin

end;


procedure TKRXOrderBroker.init;
begin
  gEnv.Engine.QuoteBroker.OnSubscribe := OnSub;
  gEnv.Engine.QuoteBroker.OnCancel    := OnUnSub;

  gLog.Add(lkApplication,'','','구독취소 프로시저 할당');
end;

procedure TKRXOrderBroker.Packet(aOrder: TOrder; var Buffer : array of char );
 var
  pPacket : PSendOrderPacket;
  aInvest : TInvestor;
  stTmp : string;  iNo : integer;
begin

  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_SendOrderPacket, ' ' );
  pPacket := PSendOrderPacket( @Buffer);

  MovePacket( Format('%-9.9s', [aInvest.AccountNo]), pPacket.Account );
  MovePacket( Format('%-3.3s', [aInvest.BranchCode]), pPacket.AnctPrd );
  MovePacket( Format('%-32.32s', [aInvest.PassWord]), pPacket.Pass );

  case aOrder.OrderType of
    otNormal: begin stTmp := 'OTS5901U01'; pPacket.Order_kind := 'N'; end;
    otChange: begin stTmp := 'OTS5901U02'; pPacket.Order_kind := 'M'; end;
    otCancel: begin stTmp := 'OTS5901U03'; pPacket.Order_kind := 'C'; end;
  end;

  MovePacket( Format('%10d', [ aOrder.LocalNo ]), pPacket.OrderID );
  Movepacket( Format('%-12.12s', [stTmp]), pPacket.ResCode );
  MovePacket( Format('%-32.32s', [ aOrder.Symbol.ShortCode ] ), pPacket.PrdtCode );

  if aOrder.Side > 0 then
    pPacket.BuySell_Type := 'B'
  else
    pPacket.BuySell_Type := 'S';

  case aOrder.PriceControl of
    pcLimit :pPacket.Price_Type := '1';
    pcMarket:pPacket.Price_Type := '2' ;
  end;

  stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);

  MovePacket( Format('%-20.20s', [ stTMp ]), pPacket.Order_Price );
  MovePacket( Format('%.5d', [ aOrder.OrderQty ] ), pPacket.Order_Volume );

  if aOrder.Target = nil then
    stTmp := ' '
  else
    stTmp := aOrder.Target.HanaOrderNo;

  MovePacket( Format('%16.16s', [ stTmp ] ), pPacket.Order_Org_No );
        {
  case aOrder.PriceControl of
  pcLimit:
    begin
      pPacket.Price_Type := '1';
      pPacket.Trace_Type := '1';
    end;
  pcMarket:
    begin
      pPacket.Price_Type := '2' ;
      pPacket.Trace_Type := '3';
    end;
  end;
     }
  case aOrder.TimeToMarket of
    tmGTD: pPacket.Trace_Type := '6' ;
    else pPacket.Trace_Type := '1';
  end;

	// 통신주문구분
	//stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  pPacket.Order_Div     := 'O';
	pPacket.Control_Type  := 'C';

end;



procedure TKRXOrderBroker.RequestAccountData;
var
  I: Integer;
  aInvest : TInvestor;
begin

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if (aInvest <> nil) and ( aInvest.PassWord <> '') then
    begin
      // 비번 오류 체크를 위해 예수금만 조회
      RequestAccountData( aInvest, rtDeposit, true );
      //RequestAccountDeposit( aInvest, true );
      //RequestAccountPos( aInvest, true );
      //RequestAccountFill( aInvest, true );
    end;
  end;
end;

procedure TKRXOrderBroker.RequestAccountData2;
var
  I: Integer;
  aInvest : TInvestor;
begin

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if (aInvest <> nil) and ( aInvest.IsInit ) then
    begin
      RequestAccountData( aInvest, rtAcntPos, true );
      RequestAccountData( aInvest, rtActiveOrd, true );
    end;
  end;

end;

procedure TKRXOrderBroker.RequestAccountData(aType: TApiEventType);
  var
    stTrCode : string;
    aData : TReqAccountData;
    aInvest: TInvestor;
    i, iCnt  : integer;

begin
  case aType of
    rtAcntPos: stTrCode := 'OTS5919Q41';
    //rtDeposit: stTrCode := 'OTS5943Q01';
    rtActiveOrd: stTrCode := 'OTS5911Q41';
    else exit;
  end;

  MovePacket( stTrCode, aData.Comm.trCode );
  MovePacket( FormatDateTime('yyyymmdd', Date),  aData.Comm.date );

  iCnt  := 0 ;
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if ( aInvest <> nil ) and ( aInvest.PassWord = '' ) then Continue;

    MovePacket( aInvest.AccountNo, aData.Data[i].Account );
    MovePacket( aInvest.BranchCode, aData.Data[i].PrdtCode );
    MovePacket( aInvest.PassWord, aData.Data[i].Password );
    inc( iCnt );
  end;

  MovePacket( IntToStr( iCnt), aData.Comm.cnt );
  gEnv.Engine.Api.aRequestData( TRD, integer( aType ), iCnt, @aData );

  

end;

procedure TKRXOrderBroker.RequestAccountData(aAccount: TAccount;
  aType: TApiEventType; bPush : boolean );
  var
    stTrCode : string;
    aData : TReqAccountData;
    Buffer : array of char;
    stData : string;
begin
  case aType of
    rtAcntPos: stTrCode := 'OTS5919Q41';
    rtDeposit: stTrCode := 'OTS5943Q01';
    rtActiveOrd: stTrCode := 'OTS5911Q41';
    else exit;
  end;

  if not gEnv.Engine.Api.IsRequest( aType ) then
  begin
    gEnv.EnvLog( WIN_ERR, ApieEventName[ aType] + ' 조회 카운트 초과 ' );
    Exit;
  end;

  MovePacket( stTrCode, aData.Comm.trCode );
  MovePacket( FormatDateTime('yyyymmdd', Date),  aData.Comm.date );
  MovePacket( '001', aData.Comm.cnt );

  MovePacket( aAccount.AccountNo, aData.Data[0].Account );
  MovePacket( aAccount.BranchCode, aData.Data[0].PrdtCode );
  MovePacket( aAccount.PassWord, aData.Data[0].Password );

  if bPush then begin

    SetLength(Buffer, sizeof(TReqAccountData) );
    Move(aData, Buffer[0], sizeof(TReqAccountData));
    SetString( stData, PChar(@Buffer[0]), sizeof(TReqAccountData)  );
    gEnv.Engine.Api.PushData( TRD, aType , 1, stData );

    //gEnv.Engine.Api.PushData( TRD, aType , 1, @aData );
  end
  else
    gEnv.Engine.Api.aRequestData( TRD, integer( aType ), 1, @aData );

end;

procedure TKRXOrderBroker.RequestAccountDeposit(aAccount: TAccount; bPush : boolean );
var
  aData : TReqAccountData;
begin
  FillChar( aData, sizeof( TReqAccountData), ' ' );

  MovePacket( 'OTS5943Q01', aData.Comm.trCode );
  MovePacket( FormatDateTime('yyyymmdd', Date),  aData.Comm.date );
  // 예수금은 하나씩 한다...
  MovePacket( '001', aData.Comm.cnt );
  MovePacket( aAccount.AccountNo, aData.Data[0].Account );
  MovePacket( aAccount.BranchCode, aData.Data[0].PrdtCode );
  MovePacket( aAccount.PassWord, aData.Data[0].Password );

  gEnv.Engine.Api.aRequestData( TRD, integer( rtDeposit ), 1, @aData );

end;

procedure TKRXOrderBroker.RequestAccountFill( aAccount : TAccount; bPush : boolean );
var
  aData   : TReqAccountData;
begin
  FillChar( aData, sizeof( TReqAccountData), ' ' );

  MovePacket( 'OTS5911Q41', aData.Comm.trCode );
  MovePacket( FormatDateTime('yyyymmdd', Date),  aData.Comm.date );
  // 예수금은 하나씩 한다...
  MovePacket( '001', aData.Comm.cnt );
  MovePacket( aAccount.AccountNo, aData.Data[0].Account );
  MovePacket( aAccount.BranchCode, aData.Data[0].PrdtCode );
  MovePacket( aAccount.PassWord, aData.Data[0].Password );

  gEnv.Engine.Api.aRequestData( TRD, integer( rtActiveOrd ), 1, @aData );

end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount; bPush : boolean);
var
  aData   : TReqAccountData;
begin
  FillChar( aData, sizeof( TReqAccountData), ' ' );

  MovePacket( 'OTS5919Q41', aData.Comm.trCode );
  MovePacket( FormatDateTime('yyyymmdd', Date),  aData.Comm.date );
  // 예수금은 하나씩 한다...
  MovePacket( '001', aData.Comm.cnt );
  MovePacket( aAccount.AccountNo, aData.Data[0].Account );
  MovePacket( aAccount.BranchCode, aData.Data[0].PrdtCode );
  MovePacket( aAccount.PassWord, aData.Data[0].Password );

  gEnv.Engine.Api.aRequestData( TRD, integer( rtActiveOrd ), 1, @aData );

end;

procedure TKRXOrderBroker.RequestMarketHoga(stCode: string; iIndex: integer;
  bPush: boolean);
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;
  stData  : string;

begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-32.32s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ iIndex ]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );


end;

procedure TKRXOrderBroker.RequestMarketPrice(stCode: string; iIndex : integer; bPush : boolean);
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;
  stData  : string;

begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-32.32s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ iIndex ]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );

end;


procedure TKRXOrderBroker.RequestSymbolData(aSymbol: TSymbol);
var
  //Buffer  : ;//array of char;
  aData   : TReqSymbolData;
  stData  : string;

begin
  //SetLength( Buffer , Sizeof( TReqSymbolData ));
  FillChar( aData, Sizeof( TReqSymbolData), ' ' );

  //aData := PReqSymbolData( Buffer );

  case aSymbol.Spec.Market of
    mtStock: aData.MarketCode[0] := 'J';
    mtElw  : aData.MarketCode[0] := 'W';
    mtFutures:
      if aSymbol.Spec.Country = 'kr' then
        aData.MarketCode[0] := 'F'
      else
        move( 'FF', aData.MarketCode, sizeof( aData.MarketCode ));
    mtOption: aData.MarketCode[0] := 'O';
  end;

  MovePacket('1000', aData.GID);
  Movepacket(aSymbol.Code, aData.Code );

  gEnv.Engine.Api.aRequestData( FID, integer( rtSymbolInfo ), 0, @aData );

end;

procedure TKRXOrderBroker.ReqAbleQty(aInvest: TInvestor; aSymbol: TSymbol);
begin

end;

procedure TKRXOrderBroker.ReqSub(aSymbol: TSymbol);
begin
  OnSub( aSymbol.Quote as TQuote );
end;


function TKRXOrderBroker.GetResCode( aSymbol : TSymbol ): string;
begin
  case aSymbol.Spec.Market of
    mtStock: Result  := 'S0';
    mtFutures:
      if aSymbol.Spec.Country = 'kr' then
        Result := 'F0'
      else
        Result := 'V1';
    mtOption: Result := 'O0';
  end;
end;

procedure TKRXOrderBroker.OnSub(aQuote: TQuote);
var
  bNew    : boolean;
  stTmp   : string;
  aData   : TRegisterData;
begin
  if aQuote = nil then Exit;

  bNew := false;
  if not aQuote.Symbol.DoSubscribe then
  begin
    //gEnv.EnvLog( WIN_TEST, format('요청 %s', [ aQuote.Symbol.Code])  );
    RequestSymbolData( aQuote.Symbol );
    aQUote.Symbol.DoSubscribe := true;
    bNew := true;
  end;

  stTmp := GetResCode( aQuote.Symbol );
  FillChar( aData, Sizeof( TRegisterData), ' ' );
  MovePacket( stTmp,  aData.resName );
  MovePacket( aQuote.Symbol.Code, aData.regCode );

  gEnv.Engine.Api.aRegisterReal( 1, @aData );


   {
  if bNew then
    gEnv.Engine.QuoteBroker.Subscribe(  gEnv.Engine.QuoteBroker,
      aQuote.Symbol, gEnv.Engine.QuoteBroker.DummyEventHandler );  
     }
end;

procedure TKRXOrderBroker.OnUnSub(aQuote: TQuote);
var
  aData   : TRegisterData;
  stTmp  : string;
begin
  if aQuote = nil then Exit;

  aQuote.Symbol.DoSubscribe := false;
  stTmp := GetResCode( aQuote.Symbol );
  FillChar( aData, Sizeof( TRegisterData), ' ' );
  MovePacket( stTmp,  aData.resName );
  MovePacket( aQuote.Symbol.Code, aData.regCode );
  gEnv.Engine.Api.aRegisterReal( 0, @aData );

  //gEnv.EnvLog( WIN_TEST, format('구독 취소 %s', [ aQuote.Symbol.Code])  );

end;

//
// (SEND ORDERS)
// 1. copy maximum 20 new orders to tmp list
// 2. make packets and send using API
// 3. change the order status of the sent orders
//
const
  MAX_PACKETS = 20;
  PACKET_SIZE = 176;

function TKRXOrderBroker.Send(aTicket: TOrderTicket): Integer;
var
  iTrCode , i, iRes, iCount : Integer;
  aOrder: TOrder;
  Buffer : array [0..Len_SendOrderPacket-1] of char;
begin

  iCount := 0;

  for i := 0 to gEnv.Engine.TradeCore.Orders.NewOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.NewOrders[i];
    if (aOrder <> nil) and (aOrder.State = osReady)
       and ((aTicket = nil) or (aOrder.Ticket = aTicket)) then
    begin

      Packet(aOrder, Buffer);
      gEnv.Engine.Api.aRequestOrder( integer( rtOrder), 1, @Buffer );
      gEnv.EnvLog( WIN_ORD, 'Send : ' + aOrder.Represent2);
      Inc(iCount);
      if iCount >= MAX_PACKETS then Break;

    end;
  end;
    //
  if iCount = 0 then
    exit;
  result := iCount;

end;    


{ TReqItem }

constructor TReqItem.Create;
begin
  Invest := nil;
  Symbol := nil;
  TrCode := 0;
  Seq    := -1;
end;

end.



