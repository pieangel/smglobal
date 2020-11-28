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

  ORDER_BUF_SIZE = 200;

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

    function NewOrderPacket(aOrder: TOrder; var Buffer : array of char): string;
    function ModifyOrderPacket(aOrder: TOrder; var Buffer : array of char): string;

    procedure OnSub(aQuote: TQuote);
    procedure OnUnSub(aQuote: TQuote);


  public
    constructor Create;
    destructor Destroy; override;

    function Send(aTicket: TOrderTicket): Integer;
    procedure init;

    procedure RequestAccountFill( aAccount : TAccount; bPush : boolean = false ) ;
    procedure RequestAccountPos( aAccount : TAccount ; bPush : boolean = false) ; overload;
    procedure RequestAccountPos( aAccount : TAccount ; aSymbol : TSymbol; bPush : boolean = false) ; overload;
    procedure RequestAccountDeposit( aAccount : TAccount; bPush : boolean = false; idx : integer = 0 ); overload;
    procedure RequestAccountDeposit( aAccount : TInvestor); overload;
    procedure ReqAbleQty( aAccount : TAccount; aSymbol : TSymbol; cLS : char = '1' );  // default 매수 조회

    procedure ReqSub( aSymbol : TSymbol );
    procedure RequestAccountData;
    procedure RequestAccountRecoveryData;
    procedure ReqPMTickSize( stPM : string = '');

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
end;

function TKRXOrderBroker.ModifyOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  pPacket : PSendModifyOrderPacket;
  aInvest : TInvestor;
  stTmp : string;  iStart : integer;
begin
  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_SendModifyOrderPacket, ' ' );
  pPacket := PSendModifyOrderPacket( @Buffer);

  MovePacket( Format('%-20s', [aInvest.Code]), pPacket.acno );
  MovePacket( Format('%-8s',  [aInvest.PassWord]), pPacket.pswd );

  case aOrder.OrderType of
    otChange: pPacket.jcgb := '2';
    otCancel: pPacket.jcgb := '3';
  end;

  Movepacket( Format('%7d', [ aOrder.Target.OrderNo]), pPacket.ojno );
  MovePacket( Format('%-30s',  [aOrder.Symbol.Code]), pPacket.code );

  if aOrder.Side > 0 then
    pPacket.mdms := '1'
  else
    pPacket.mdms := '2';

  case aOrder.PriceControl of
    pcLimit:  pPacket.jtyp := '2';
    pcMarket: pPacket.jtyp := '1' ;
  end;

  MovePacket( Format('%8d', [ aOrder.OrderQty ] ), pPacket.jqty );

  //stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
  stTmp := aOrder.Symbol.PriceCrt.GetString( aOrder.Price);
  MovePacket( Format('%-12s', [ stTMp ]), pPacket.jprc );
  //MovePacket( Format('%12f', [ 0.0 ]), pPacket.sprc );
  //pPacket.odty := '2';

  SetString( Result, PChar(@Buffer[0]), Len_SendModifyOrderPacket );

end;

function TKRXOrderBroker.NewOrderPacket(aOrder: TOrder;
  var Buffer: array of char): string;
 var
  pPacket : PSendOrderPacket;
  aInvest : TInvestor;
  stTmp : string;  iStart : integer;
begin
  aInvest := gEnv.Engine.TradeCore.Investors.Find( aOrder.Account.InvestCode );
  if aInvest = nil then Exit;

  FillChar( Buffer,  Len_SendOrderPacket, ' ' );
  pPacket := PSendOrderPacket( @Buffer);


  MovePacket( Format('%-20s', [aInvest.Code]), pPacket.acno );
  MovePacket( Format('%-8s',  [aInvest.PassWord]), pPacket.pswd );
  MovePacket( Format('%-30s',  [aOrder.Symbol.Code]), pPacket.code );

  if aOrder.Side > 0 then
    pPacket.mdms := '1'
  else
    pPacket.mdms := '2';

  case aOrder.PriceControl of
    pcLimit:  pPacket.jtyp := '2';
    pcMarket: pPacket.jtyp := '1' ;
  end;

  pPacket.jmgb  := '0';
  MovePacket( Format('%8d', [ aOrder.OrderQty ] ), pPacket.jqty );

  //stTmp := Format('%.*f', [ aOrder.Symbol.Spec.Precision, aOrder.Price ]);
  stTmp := aOrder.Symbol.PriceCrt.GetString( aOrder.Price);
  MovePacket( Format('%-12s', [ stTMp ]), pPacket.jprc );
  //stTmp := aOrder.Symbol.PriceCrt.GetString( 0);
  //MovePacket( Format('%-12s', [ stTmp ]), pPacket.sprc );

  //MovePacket( Format('%-8s', [ formatDateTime('yyyymmdd', Date)]), pPacket.date );
  //pPacket.odty := '2';

  SetString( Result, PChar(@Buffer[0]), Len_SendOrderPacket );
end;

function TKRXOrderBroker.Packet(aOrder: TOrder;  var Buffer : array of char): string;
begin

  case aOrder.OrderType of
    otNormal: Result := NewOrderPacket( aOrder, Buffer );
    otChange ,
    otCancel: Result := ModifyOrderPacket( aOrder, Buffer );
  end;
end;

procedure TKRXOrderBroker.RequestAccountData;
begin

  gEnv.Engine.Api.RequestData( IntToStr(REQ_ACNT_LIST), '1', 'pibo0150', 'ph015301', '0', '', '0');
  gLog.Add(lkApplication,'','', '계좌요청 pibo0150, ph015301, 0, '', 0'
  );
end;



procedure TKRXOrderBroker.RequestAccountRecoveryData;
var
  I: Integer;
  aInvest : TInvestor;
begin
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if (aInvest <> nil) and ( aInvest.PassWord <> '') then
    begin

      RequestAccountDeposit( aInvest, true, i );
      RequestAccountPos( aInvest, true );
      RequestAccountFill( aInvest, true );
    end;
  end;
end;

// 응답으로 계좌번호를 주지않는다.
// 여러계좌 동시 조회시.. 어쩌란 말인가..

procedure TKRXOrderBroker.RequestAccountDeposit(aAccount: TAccount; bPush : boolean; idx : integer);
var
  Buffer  : array of char;
  aData   : PReqAccountDeposit;
  stData, stWin  : string;
begin
  SetLength( Buffer , Len_ReqAccountDeposit);
  FillChar( Buffer[0], Len_ReqAccountDeposit, ' ' );

  aData   := PReqAccountDeposit( Buffer );

  MovePacket( Format('%-20s', [ aAccount.Code]), aData.Account );
  MovePacket( Format('%-8s',  [ aAccount.PassWord]), aData.Pass );
  MovePacket( Format('%-8s',  [ FormatDateTime('yyyymmdd', Date)]), aData.Date );
  MovePacket( Format('%-3s',  [ 'TOT' ] ), aData.Crc_cd );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
  // 계좌별 예수금
  //stWin := Format('%d', [ REQ_ACNT_DEPOSIT + idx ]);
  stWin := Format('%d', [ idx ]);
  if bPush then
    gEnv.Engine.Api.PushRequest(stWin,'1','paho1310', 'ph131501', '39', stData, '1')
  else
    gEnv.Engine.Api.RequestData(stWin,'1','paho1310', 'ph131501', '39', stData, '1');

end;

procedure TKRXOrderBroker.RequestAccountDeposit(aAccount: TInvestor);
var
  Buffer  : array of char;
  aData   : PReqAccountDeposit;
  stData, stWin  : string;
  idx : integer;
begin
  SetLength( Buffer , Len_ReqAccountDeposit);
  FillChar( Buffer[0], Len_ReqAccountDeposit, ' ' );

  aData   := PReqAccountDeposit( Buffer );

  MovePacket( Format('%-20s', [ aAccount.Code]), aData.Account );
  MovePacket( Format('%-8s',  [ aAccount.PassWord]), aData.Pass );
  MovePacket( Format('%-8s',  [ FormatDateTime('yyyymmdd', Date)]), aData.Date );
  MovePacket( Format('%-3s',  [ 'TOT' ] ), aData.Crc_cd );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
  // 계좌별 예수금
  //stWin := Format('%d', [ REQ_ACNT_DEPOSIT + idx ]);
  stWin := Format('%d', [ aAccount.Index ]);
  gEnv.Engine.Api.RequestData(stWin,'1','paho1310', 'ph131501', '39', stData, '1');
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

  MovePacket( Format('%-20s', [ aAccount.Code]), aData.Account );
  MovePacket( Format('%-8s',  [ aAccount.PassWord]), aData.Pass );
  aData.reg_n_tp  := 'N';
  MovePacket( Format('%-30s',  ['' ]), aData.code );
  MovePacket( Format('%-20s',  ['' ]), aData.grnm );
  MovePacket( Format('%-20s',  ['' ]), aData.csno );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountDeposit );
    //** 미체결주문 조회 TR 전송
  if bPush then
    gEnv.Engine.Api.PushRequest(IntToStr(REQ_ACTIVE_ORD),'1','paho0200', 'ph020201',
                          IntToStr(Len_ReqAccountFill), stData, '1')
  else
    gEnv.Engine.Api.RequestData(IntToStr(REQ_ACTIVE_ORD),'1','paho0200', 'ph020201',
                          IntToStr(Len_ReqAccountFill), stData, '1');
end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount;
  aSymbol: TSymbol; bPush: boolean);
var
  Buffer  : array of char;
  aData   : PReqAccountPos;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountPos);
  FillChar( Buffer[0], Len_ReqAccountPos, ' ' );

  aData   := PReqAccountPos( Buffer );

  MovePacket( Format('%-20s', [ aAccount.Code]), aData.Account );
  MovePacket( Format('%-8s',  [ aAccount.PassWord]), aData.Pass );
  aData.reg_n_tp  := 'N';
  MovePacket( Format('%-30s',  [aSymbol.Code ]), aData.code );
  MovePacket( Format('%-20s',  ['' ]), aData.grnm );
  MovePacket( Format('%-20s',  ['' ]), aData.csno );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountPos );

  if bPush then
    gEnv.Engine.Api.PushRequest(IntToStr(REQ_POS_LIST),'1','paho0200', 'ph020401',
                                      IntToStr(Len_ReqAccountPos), stData, '1')
  else
    gEnv.Engine.Api.RequestData(IntToStr(REQ_POS_LIST),'1','paho0200', 'ph020401',
                                    IntToStr(Len_ReqAccountPos), stData, '1');

end;

procedure TKRXOrderBroker.RequestAccountPos(aAccount: TAccount; bPush : boolean );
var
  Buffer  : array of char;
  aData   : PReqAccountPos;
  stData, stPW  : string;

begin
  SetLength( Buffer , Len_ReqAccountPos);
  FillChar( Buffer[0], Len_ReqAccountPos, ' ' );

  aData   := PReqAccountPos( Buffer );

  MovePacket( Format('%-20s', [ aAccount.Code]), aData.Account );
  MovePacket( Format('%-8s',  [ aAccount.PassWord]), aData.Pass );
  aData.reg_n_tp  := 'N';
  MovePacket( Format('%-30s',  ['' ]), aData.code );
  MovePacket( Format('%-20s',  ['' ]), aData.grnm );
  MovePacket( Format('%-20s',  ['' ]), aData.csno );

  SetString( stData, PChar(@Buffer[0]), Len_ReqAccountPos );

  if bPush then
    gEnv.Engine.Api.PushRequest(IntToStr(REQ_POS_LIST),'1','paho0200', 'ph020401',
                                      IntToStr(Len_ReqAccountPos), stData, '1')
  else
    gEnv.Engine.Api.RequestData(IntToStr(REQ_POS_LIST),'1','paho0200', 'ph020401',
                                    IntToStr(Len_ReqAccountPos), stData, '1');
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
begin

end;

procedure TKRXOrderBroker.ReqPMTickSize( stPM : string );
begin
  // 공백일시 전체 조회
  gEnv.Engine.Api.RequestData( IntToStr(REQ_TICK_SIZE) ,'1',
     'paho8000', 'ph800801', '5',  format('%5s', [ stPM]), '0');
end;

procedure TKRXOrderBroker.ReqSub(aSymbol: TSymbol);
begin
  OnSub( aSymbol.Quote as TQuote );
end;

procedure TKRXOrderBroker.SubScribe( bOn : boolean; aAccount : TAccount );
{
var
  Buffer  : array of char;
  aData   : PSendAutoKey;
  stData, stPW  : string;   }
begin
{
  if aAccount = nil then Exit;

  SetLength( Buffer , Len_SendAutoKey);
  FillChar( Buffer[0], Len_SendAutoKey, ' ' );

  aData   := PSendAutoKey( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-10.10d', [ 12 ]),  aData.header.WindowID );
  MovePacket( Format('%-32.32s',[ aAccount.Code ]), aData.AutoKey );
  SetString( stData, PChar(@Buffer[0]), Len_SendAutoKey );
  // 계좌별 실체결
  //gEnv.Engine.Api.ReqRealTimeOrder( bOn, stData );
  }
end;

procedure TKRXOrderBroker.OnSub(aQuote: TQuote);
var
  bNew    : boolean;
begin
  if aQuote = nil then Exit;

  bNew := false;

  if not aQuote.Symbol.DoSubscribe then
  begin
    gEnv.Engine.Api.RequestData( IntToStr(aQuote.Symbol.Seq),'0',
      'pibo7000', 'pibo7012', '16',   aQuote.Symbol.Code, '0');
    aQUote.Symbol.DoSubscribe := true;
    bNew := true;
  end;

  if bNew then
    gEnv.Engine.QuoteBroker.Subscribe(  gEnv.Engine.QuoteBroker,
      aQuote.Symbol, gEnv.Engine.QuoteBroker.DummyEventHandler );

end;

procedure TKRXOrderBroker.OnUnSub(aQuote: TQuote);
begin

  if aQuote = nil then Exit;
  aQuote.Symbol.DoSubscribe := false;

  gEnv.Engine.Api.UnRegistData( aQuote.Symbol.Seq );

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
  iSize, i, iCount : Integer;

  aOrder: TOrder;
  stTr,stPacket: String;
  Buffer : array [0..ORDER_BUF_SIZE-1] of char;

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
            otNormal: begin stTr := 'pibo5001';  iSize := Len_SendOrderPacket; end;
            otChange,
            otCancel: begin stTr := 'pibo5002';  iSize := Len_SendModifyOrderPacket; end;
          end;

          gEnv.Engine.Api.RequestData( IntToStr(aOrder.LocalNo), '2', 'pibo5000', sTtr,
             IntToStr(iSize),stPacket, '2');
          gEnv.EnvLog( WIN_TEST, format('Packet(%d/%d)-%d:%s',
            [i, gEnv.Engine.TradeCore.Orders.NewOrders.Count,aOrder.LocalNo,stPacket]) );

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



