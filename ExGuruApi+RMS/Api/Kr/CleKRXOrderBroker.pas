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

    function Packet(aOrder: TOrder; var Buffer : array of char): string;

    procedure OnSub(aQuote: TQuote);
    procedure OnUnSub(aQuote: TQuote);

  public
    constructor Create;
    destructor Destroy; override;

    function Send(aTicket: TOrderTicket): Integer;
    procedure init;

    procedure RequestAccountFill( aAccount : TAccount; bPush : boolean = false ) ;
    procedure RequestAccountPos( aAccount : TAccount; bPush : boolean = false) ;
    procedure RequestAccountDeposit( aAccount : TAccount; bPush : boolean = false );
    procedure RequestMarketPrice(stCode: string; iIndex : integer; bPush : boolean = false);
    procedure RequestMarketHoga(stCode: string; iIndex : integer; bPush : boolean = false);
    procedure ReqSub( aSymbol : TSymbol );
    procedure ReqChartData( aSymbol : TSymbol; dtBase : TDateTime; iDataCnt, iMin : integer ; cDiv : char);
    procedure ReqAbleQty( aAccount : TAccount; aSymbol : TSymbol; cLS : char = '1' );  // default 매수 조회

    procedure RequestAccountData;
    procedure ReqAutQuote(aSymbol : TSymbol);

    procedure SubScribe(  bOn : boolean; aAccount : TAccount );
    procedure SubScribeAccount( bOn : boolean );

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

function TKRXOrderBroker.Packet(aOrder: TOrder;  var Buffer : array of char): string;
 var
  pPacket : PSendOrderPacket;
  aInvest : TInvestor;
  stTmp : string;  iStart : integer;
begin

  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_SendOrderPacket, ' ' );
  pPacket := PSendOrderPacket( @Buffer);

  MovePacket( Format('%10.10d', [ aOrder.LocalNo ]), pPacket.Header.WindowID);
  //MovePacket( Format('%15.15d', [ aOrder.LocalNo ]), pPacket.Header.filler);

  MovePacket( Format('%11.11s', [aInvest.Code]), pPacket.Account );
  stTmp := gEnv.Engine.Api.GetEncodePassword( aInvest );
  MovePacket( Format('%-8.8s    ', [ stTmp ]), pPacket.Pass );

  case aOrder.OrderType of
    otNormal: pPacket.Order_Type := '1' ;
    otChange: pPacket.Order_Type := '2';
    otCancel: pPacket.Order_Type := '3';
  end;

  MovePacket( Format('%-32.32s', [ aOrder.Symbol.ShortCode ] ), pPacket.ShortCode );

  if aOrder.Side > 0 then
    pPacket.BuySell_Type := '1'
  else
    pPacket.BuySell_Type := '2';

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

  stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);

  MovePacket( Format('%-20.20s', [ stTMp ]), pPacket.Order_Price );
  MovePacket( Format('%.5d', [ aOrder.OrderQty ] ), pPacket.Order_Volume );

  if aOrder.Target = nil then
    stTmp := ' '
  else
    stTmp := Format('%d', [ aOrder.Target.OrderNo ] );

  MovePacket( Format('%5.5s', [ stTmp ] ), pPacket.Order_Org_No );
   {
  FillChar( pPacket.Price, sizeof( pPacket.Price ), '0');
  iStart := Round(aOrder.Price * 100);

  stTmp := Format('%.11d', [ iStart ] );
  iStart := sizeof( pPacket.Price ) - Length( stTmp );
  Move( stTmp[1], pPacket.Price[iStart], Length( stTmp ));
   }

	// 통신주문구분
	stTmp := gEnv.Engine.Api.Api.ESExpGetCommunicationType;
  pPacket.Order_Comm_Type := stTmp[1];
	pPacket.Stop_Type       := '1';
  //stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
  //MovePacket( Format('%-20.20s', [ stTmp ]), pPacket.Stop_Price );
  pPacket.Oper_Type       := pPacket.Order_Type;

  SetString( Result, PChar(@Buffer[0]), Len_SendOrderPacket );

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
      RequestAccountDeposit( aInvest, true );
      RequestAccountPos( aInvest, true );
      RequestAccountFill( aInvest, true );
    end;
  end;
end;

procedure TKRXOrderBroker.RequestAccountDeposit(aAccount: TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : PReqAccountDeposit;
  stData, stPW  : string;
  idx : integer;
begin
  SetLength( Buffer , Len_ReqAccountDeposit);
  FillChar( Buffer[0], Len_ReqAccountDeposit, ' ' );

  aData   := PReqAccountDeposit( Buffer );
  // - 를 붙여 앞으로 정렬
  idx  := gEnv.Engine.TradeCore.Investors.GetIndex( aAccount.InvestCode );
  MovePacket( Format('%10.10d', [ idx]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( 'USD', aData.Crc_cd );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
  // 계좌별 예수금
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5615, stData, Len_ReqAccountDeposit)
  else
    gEnv.Engine.Api.RequestData( ESID_5615, stData, Len_ReqAccountDeposit);



  FillChar( Buffer[0], Len_ReqAccountDeposit, ' ' );
  aData   := PReqAccountDeposit( Buffer );
  // - 를 붙여 앞으로 정렬
  idx  := gEnv.Engine.TradeCore.Investors.GetIndex( aAccount.InvestCode );
  MovePacket( Format('%10.10d', [ idx]), aData.Header.WindowID );
  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);
  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( 'KRW', aData.Crc_cd );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );

  // 계좌별 예수금
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5615, stData, Len_ReqAccountDeposit)
  else
    gEnv.Engine.Api.RequestData( ESID_5615, stData, Len_ReqAccountDeposit);  

end;

procedure TKRXOrderBroker.RequestAccountFill( aAccount : TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : PReqAccountFill;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountFill);
  FillChar( Buffer[0], Len_ReqAccountFill, ' ' );

  aData   := PReqAccountFill( Buffer );
  // - 를 붙여 앞으로 정렬

  //aData.Header.NextKind := cNext;
  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( Format('%8.8s',  [ FormatDateTime('yyyymmdd', Date) ]), aData.Base_dt );

  aData.Trd_gb  := '2';
  aData.Gubn    := '1';

  SetString( stData, PChar(@Buffer[0]),Len_ReqAccountFill );
  // 계좌별 실체결
  if bPush then  
    gEnv.Engine.Api.PushRequest( ESID_5611, stData,  Len_ReqAccountFill)
  else
    gEnv.Engine.Api.RequestData( ESID_5611, stData,  Len_ReqAccountFill);
end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount; bPush : boolean);
var
  Buffer  : array of char;
  aData   : PReqAccountPos;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountPos);
  FillChar( Buffer[0], Len_ReqAccountPos, ' ' );

  aData   := PReqAccountPos( Buffer );
  // - 를 붙여 앞으로 정렬
  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount);

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountPos );
  // 계좌별 실체결
  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5612, stData,  Len_ReqAccountPos)
  else
    gEnv.Engine.Api.RequestData( ESID_5612, stData,  Len_ReqAccountPos);

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

  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5503, stData,  Sizeof( TReqSymbolMaster ))
  else
    gEnv.Engine.Api.RequestData( ESID_5503, stData,  Sizeof( TReqSymbolMaster ));
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

  if bPush then
    gEnv.Engine.Api.PushRequest( ESID_5502, stData,  Sizeof( TReqSymbolMaster ))
  else
    gEnv.Engine.Api.RequestData( ESID_5502, stData,  Sizeof( TReqSymbolMaster ));

end;


procedure TKRXOrderBroker.SubScribeAccount( bOn : boolean );
var
  I: Integer;
begin
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    SubScribe( bOn, gEnv.Engine.TradeCore.Investors.Investor[i] );
end;

procedure TKRXOrderBroker.ReqAbleQty(aAccount: TAccount; aSymbol: TSymbol;
  cLS: char);
var
  Buffer  : array of char;
  aData   : PReqAbleQty;
  stData, stPW  : string;
  aInvest : TInvestor;
begin
  SetLength( Buffer , Len_ReqAbleQty);
  FillChar( Buffer[0], Len_ReqAbleQty, ' ' );

  aData   := PReqAbleQty( Buffer );
  // - 를 붙여 앞으로 정렬
  // 종목 Seq 를 딸려 보낸다.. ( 결과값으로 종목코드를 안주니깐...ㅡㅡ)
  MovePacket( Format('%10.10d', [ aSymbol.Seq ]), aData.Header.WindowID );

  stPW := gEnv.Engine.Api.GetEncodePassword( aAccount );

  MovePacket( Format('%-11.11s',[ aAccount.Code ]), aData.Account );
  MovePacket( Format('%-8.8s',  [ stPW ]), aData.Pass );
  MovePacket( Format('%-32.32s',  [ aSymbol.ShortCode]), aData.ShortCode );
  aData.Bysl_tp := cLS;

  SetString( stData, PChar(@Buffer[0]), Len_ReqAbleQty );
  // 계좌별 실체결
  gEnv.Engine.Api.PushRequest( ESID_5633, stData,  Len_ReqAbleQty);

end;

// 기준일자, 데이타개수, 몇분, 봉종류( 분, 일 주 ..)
procedure TKRXOrderBroker.ReqChartData(aSymbol: TSymbol; dtBase : TDateTime;
  iDataCnt, iMin: integer; cDiv : char);
var
  Buffer  : array of char;
  aData   : PReqChartData;
  stData  : string;
begin

  SetLength( Buffer , Len_ReqChartData);
  FillChar( Buffer[0], Len_ReqChartData, ' ' );

  aData := PReqChartData( Buffer );

  aData.JongUp  := '5';     // 고정
  aData.DataGb  := cDiv;    // 분봉으로 하겠지...'5'
  aData.DiviGb  := '0';     // 고정'

  MovePacket( Format('%-32.32s',[ aSymbol.Code ]), aData.FullCode );
  MovePacket( Format('%4.4d',   [ aSymbol.Seq ]), aData.Index );
  MovePacket( Format('%8.8s',   [ FormatDateTime('yyymmdd', dtBase)]), aData.InxDay );
  MovePacket( Format('%4.4d',   [ iDataCnt ]), aData.DayCnt );
  MovePacket( Format('%3.3d',   [ iMin ]), aData.Summary );       ///* tick, 분에서 모으는 단위										*/

  aData.Linked  := 'Y';         // 연결선물
  aData.JunBonGb  := '1';       // 전산장

  SetString( stData, PChar(@Buffer[0]), Len_ReqChartData );

  gEnv.Engine.Api.RequestData( ESID_5522, stData,  Len_ReqChartData);

end;

procedure TKRXOrderBroker.ReqAutQuote(aSymbol: TSymbol);
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
begin

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-32.32s',[ aSymbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.PushRequest( AUTO_0933, stData, 0);
  //gEnv.Engine.Api. ReqRealTimeQuote( True, stData );
end;



procedure TKRXOrderBroker.ReqSub(aSymbol: TSymbol);
begin
  OnSub( aSymbol.Quote as TQuote );
end;

procedure TKRXOrderBroker.SubScribe( bOn : boolean; aAccount : TAccount );
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData, stPW  : string;
begin
  if aAccount = nil then Exit;

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-10.10d', [ 12 ]),  aData.header.WindowID );
  MovePacket( Format('%-32.32s',[ aAccount.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );
  // 계좌별 실체결
  gEnv.Engine.Api.ReqRealTimeOrder( bOn, stData );
end;

procedure TKRXOrderBroker.OnSub(aQuote: TQuote);
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
  bNew    : boolean;
begin
  if aQuote = nil then Exit;

  bNew := false;
  if not aQuote.Symbol.DoSubscribe then
  begin
    RequestMarketPrice( aQuote.Symbol.Code, aQuote.Symbol.Seq );
    RequestMarketHoga( aQuote.Symbol.Code, aQuote.Symbol.Seq );
    aQUote.Symbol.DoSubscribe := true;
    bNew := true;
  end;

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-32.32s',[ aQuote.Symbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.ReqRealTimeQuote( True, stData );

  if bNew then
    gEnv.Engine.QuoteBroker.Subscribe(  gEnv.Engine.QuoteBroker,
      aQuote.Symbol, gEnv.Engine.QuoteBroker.DummyEventHandler );  

end;

procedure TKRXOrderBroker.OnUnSub(aQuote: TQuote);
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData  : string;
begin
  if aQuote = nil then Exit;

  aQuote.Symbol.DoSubscribe := false;
  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-32.32s',[ aQuote.Symbol.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );

  gEnv.Engine.Api.ReqRealTimeQuote( false, stData );

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
  iTrCode , i, iCount : Integer;
  aOrder: TOrder;
  stPacket: String;
  Buffer : array [0..Len_SendOrderPacket-1] of char;

begin

  iCount := 0;

  for i := 0 to gEnv.Engine.TradeCore.Orders.NewOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.NewOrders[i];
    if (aOrder <> nil) and (aOrder.State = osReady)
       and ((aTicket = nil) or (aOrder.Ticket = aTicket)) then
    begin

      stPacket := Packet(aOrder, Buffer);

      if stPacket <> '' then
        try
          aOrder.Sent;

          case aOrder.OrderType of
            otNormal: iTrCode := ESID_5601 ;
            otChange: iTrCode := ESID_5602;
            otCancel: iTrCode := ESID_5603;
          end;

          gEnv.Engine.Api.PushRequest( iTrCode, stPacket, Len_SendOrderPacket);
          gEnv.EnvLog( WIN_PACKET, format('Packet(%d/%d):%s',
            [i, gEnv.Engine.TradeCore.Orders.NewOrders.Count,stPacket]) );

          Inc(iCount);
        except
          gEnv.EnvLog( WIN_PACKET, format('%s, %d',[ stPacket, aOrder.LocalNo]) );
        end;

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



