unit CleVolTrading;

interface

uses
  Classes, Sysutils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,  CleFills,

  GleTypes
  ;

type

  TVolTradeParam = record
    OrdQty : integer;
    OrdGap : integer;
    BaseUpPrc, BaseDownPrc: double;
    LimitUp, LimitDown: double;
  end;

  TVolTrade = class
  private
    FSymbol: TSymbol;
    FQuote: TQuote;
    FParam: TVolTradeParam;
    FIsFund: boolean;
    FRun: boolean;
    FFund: TFund;
    FAccount: TAccount;
    FParent: TObject;
    FReady: boolean;
    FAskOrders: TOrderList;
    FBidOrders: TOrderList;
    FFundPosition: TFundPosition;
    FPosition: TPosition;
    FNotifyEvent: TTextNotifyEvent;
    FLossCut: boolean;
    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote);
    procedure Reset;
    procedure DoLog(stLog: string);
    function IsRun: boolean;
    procedure OnInit(aQuote: TQuote);
    procedure DoOrder(aQuote: TQuote; iSide : integer; dBasePrc: double;
        bPave : boolean = true); overload;
    procedure DoOrder(aAccount : TAccount; iSide : integer; dPrice: double;
        iQty : integer; bPave : boolean; stFName : string =''); overload;
    procedure DoCancel( aAccount: TAccount; iSide : integer );overload;
    procedure DoCancelAll;
    procedure DoCancel( aOrder : TOrder );overload;
    procedure OnFill(aOrder: TOrder; aFill: TFill);
    function CheckOrder(aOrder: TOrder): boolean;
    procedure OnPosition(aPos: TPosition);
  public
    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean; overload;
    function init( aFund : TFund; aSymbol : TSymbol ) : boolean; overload;
    procedure UpdateParam( iDiv : integer ; bVal : boolean );
    procedure DoLiquid( aQuote : TQuote );

    property Param : TVolTradeParam read FParam write FParam;
    property Run   : boolean read FRun;
    property IsFund: boolean read FIsFund;
    property Ready : boolean read FReady;
    property LossCut: boolean read FLossCut;

    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Quote   : TQuote  read FQuote;   // 시세
    property Account : TAccount read FAccount;
    property Fund : TFund read FFund;

    property BidOrders : TOrderList read FBidOrders;
    property AskOrders : TOrderList read FAskOrders;

    property Position  : TPosition read FPosition;
    property FundPosition : TFundPosition read FFundPosition;

    property NotifyEvent : TTextNotifyEvent read FNotifyEvent write FNotifyEvent;
  end;

implementation

uses
  GAppEnv, GleLib, GleConsts,CleKrxSymbols,
  FVolTrading
  ;

{ TVolTrade }

procedure TVolTrade.Reset;
begin
  FReady  := false;
  FLossCut:= false;
  BidOrders.Clear;
  AskOrders.Clear;
end;

procedure TVolTrade.DoCancel(aAccount: TAccount; iSide: integer);
var
  I: Integer;
  aOrder : TOrder;
begin

  if iSide > 0 then
  begin
    for I := 0 to FBidOrders.Count - 1 do
    begin
      aOrder  := FBidOrders.Orders[i];
      if ( aOrder.State = osActive ) and ( aOrder.Account = aAccount ) and ( not aOrder.Modify ) then
      begin
        DoCancel( aOrder );
        FBidOrders.Delete(i);
        break;
      end;
    end;

  end else
  if iSide < 0 then
  begin
    for I := 0 to FAskOrders.Count - 1 do
    begin
      aOrder  := FAskOrders.Orders[i];
      if ( aOrder.State = osActive ) and ( aOrder.Account = aAccount ) and ( not aOrder.Modify ) then
      begin
        DoCancel( aOrder );
        FAskOrders.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure TVolTrade.DoCancel(aOrder : TOrder);
var
  aTicket : TOrderTicket;
  pOrder  : TOrder;
begin
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  pOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aOrder, aOrder.ActiveQty, aTicket);
  if pOrder <> nil then
  begin
    pOrder.OrderSpecies := opHult;
    gEnv.Engine.TradeBroker.Send(aTicket);
    DoLog( Format('주문취소 : %s, %s, %s, %s, %d, %d', [ aOrder.Account.Name,
      aOrder.Symbol.ShortCode,  ifThenStr( aOrder.Side > 0 , '매수','매도'),
      aOrder.Symbol.PriceToStr( aOrder.Price ),
      aOrder.ActiveQty, aOrder.OrderNo ]));
  end;
end;

procedure TVolTrade.DoCancelAll;
var
  I: Integer;
  aOrder : TOrder;
begin

  for I := 0 to FBidOrders.Count - 1 do
  begin
    aOrder  := FBidOrders.Orders[i];
    if ( aOrder.State = osActive ) and ( aOrder.ActiveQty > 0 ) and ( not aOrder.Modify ) then
    begin
      DoCancel( aOrder );
      //FBidOrders.Delete(i);
      //break;
    end;
  end;

  for I := 0 to FAskOrders.Count - 1 do
  begin
    aOrder  := FAskOrders.Orders[i];
    if ( aOrder.State = osActive ) and ( aOrder.ActiveQty > 0 ) and ( not aOrder.Modify ) then
    begin
      DoCancel( aOrder );
      //FAskOrders.Delete(i);
      //break;
    end;
  end;

end;

procedure TVolTrade.DoLiquid( aQuote : TQuote );
var
  iQty, iSide : integer;
  dPrice : double;
begin
  if FPosition = nil then Exit;
  if FPosition.Volume = 0 then Exit;

  if FPosition.Volume > 0 then
  begin
    iSide   := -1;
    dPrice  := TicksFromPrice( FSymbol, aQuote.Bids[0].Price, - 4 );
  end
  else begin
    iSide := 1;
    dPrice  := TicksFromPrice( FSymbol, aQuote.Asks[0].Price, 4 );
  end;

  DoOrder( FAccount, iSide, dPrice, abs(FPosition.Volume), false );
  FLossCut := true;

end;

procedure TVolTrade.DoLog(stLog: string);
begin
  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_HULFT, stLog, false, 'Vol_Trade_'+FFund.Name);

  if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_HULFT, stLog, false, 'Vol_Trade_'+Account.Name);
end;

constructor TVolTrade.Create(aObj: TObject);
begin
  FSymbol:= nil;
  FRun    := false;
  FReady  := false;
  FFund:= nil;
  FAccount:= nil;
  FQuote:= nil;

  FParent := aObj;

  FAskOrders:= TOrderList.Create;
  FBidOrders:= TOrderList.Create;
end;

destructor TVolTrade.Destroy;
begin

  FAskOrders.Free;
  FBidOrders.Free;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

function TVolTrade.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  FIsFund := false;
  FAccount:= aAcnt;
  FSymbol := aSymbol;
  FFund   := nil;
  FPosition := nil;
  FFundPosition := nil;
  Reset;
end;

function TVolTrade.init(aFund: TFund; aSymbol: TSymbol): boolean;
begin
  FIsFund := true;
  FAccount:= nil;
  FSymbol := aSymbol;
  FFund   := aFund;
  FFundPosition := nil;
  FPosition     := nil;
  Reset;
end;

function TVolTrade.IsRun : boolean;
begin
  if ( not Run)
    or (( FIsFund ) and ( Fund = nil ))
    or (( not FIsFund ) and ( Account = nil ))
    or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;




function TVolTrade.Start: boolean;
begin
  FRun := false;
  if (( FIsFund ) and ( Symbol <> nil ) and ( Fund <> nil ))
    or
    (( not FIsFund ) and ( Symbol <> nil ) and ( Account <> nil )) then
  begin
    FRun := true;
    DoLog( Format('TVolTrade Start %s ', [Symbol.Code ]) );
  end else Exit;

  Result := FRun;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc);
end;

procedure TVolTrade.Stop;
begin
  FRun := false;
  DoCancelAll;
  if Fsymbol.Quote <> nil then
    DoLiquid( FSymbol.Quote as TQuote );
  DoLog( 'TVolTrade Stop' );
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

function TVolTrade.CheckOrder( aOrder : TOrder ) : boolean;
begin
  Result := false;

  if FIsFund then
  begin
    if (aOrder.FundName = FFund.Name) and ( FFund.FundItems.Find2( aOrder.Account ) >= 0) then
      Result := true;
  end
  else begin
    if (aOrder.Account = FAccount) and ( aOrder.FundName = '' ) then Result := true;
  end;

  if not Result then
  begin

  end;
end;

procedure TVolTrade.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aOrder : TOrder;
    afill  : Tfill;
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;

  if not IsRun then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED:
      begin
        aOrder  := DataObj as TOrder;

        if integer(EventID) = ORDER_FILLED then begin

          if aOrder.OrderSpecies <> opHult then Exit;
          if not CheckOrder( aOrder ) then Exit;

          aFill   := aOrder.Fills.Fills[ aOrder.Fills.Count - 1];
          DoLog( Format('Filled : %s, %s, %s, %s, %d, %d', [ aOrder.Account.Code,
            aOrder.Symbol.ShortCode,  ifThenStr( aOrder.Side > 0 , '매수','매도'),
            aOrder.Symbol.PriceToStr( aFill.Price ), aFill.Volume, aOrder.OrderNo ]));
          OnFill( aOrder, aFill );
        end else
        begin
          if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed ] then
            if aOrder.Side > 0 then
              FBidOrders.Remove( aOrder)
            else
              FAskOrders.Remove( aOrder );
        end;
      end;

    POSITION_NEW ,
    POSITION_UPDATE:
      begin
        OnPosition( DataObj as TPosition );
      end;
  end;
end;

procedure TVolTrade.UpdateParam(iDiv: integer; bVal: boolean);
begin
  {
  case iDiv of
    1  : FParam.IsLossCut := bVal;
  end;
  }
end;

procedure TVolTrade.OnPosition( aPos : TPosition );
begin
  if not IsRun then Exit;
  if ( FAccount <> aPos.Account ) or ( FSymbol <> aPos.Symbol ) then
    Exit;
  FPosition := aPos;
end;

procedure TVolTrade.OnFill( aOrder: TOrder; aFill : TFill );
var
  bFull : boolean;
  iSide, iQty  : integer;
  dPrice : double;
  stName : string;
  aItem : TFundItem;
begin

  // 체결 수량만큼 청산 주문을 대 놓는다.

  iQty  := abs( aFill.Volume );
  if iQty <= 0 then Exit;
  iSide := aOrder.Side * -1;
  dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, FParam.OrdGap * aOrder.Side );

  if FIsFund then
    stName := FFund.Name
  else stName := '';

  DoOrder(  aOrder.Account, iSide, dPrice, iQty, true, stName );

  // 깔아논 주문 전량 체결 되면..
  // 반대편 깔아논 주문 취소 한다.  ( 증거금 부족할수도 있으므로 )
  // 같은방향에 다음 단계 주문을 대 놓는다.

  if aOrder.State = osFilled then
  begin
    DoLog( Format('전량체결 : %s, %s, %s, %s, (%d,%d,%d), %d', [ aOrder.Account.Code,
            aOrder.Symbol.ShortCode,  ifThenStr( aOrder.Side > 0 , '매수','매도'),
            aOrder.Symbol.PriceToStr( aFill.Price ), aOrder.OrderQty, aOrder.FilledQty, aFill.Volume, aOrder.OrderNo ]));

    DoCancel( aOrder.Account, iSide );
    dPrice  := TicksFromPrice( aOrder.Symbol, aFill.Price, FParam.OrdGap * iSide );

    if FIsFund then
    begin
      aItem := FFund.FundItems.Find( aOrder.Account);
      if aItem <> nil then
        DoOrder( aOrder.Account, aOrder.Side, dPrice, aItem.Multiple * FParam.OrdQty , true , stName);
    end else
    begin
      DoOrder( aOrder.Account, aOrder.Side, dPrice, FParam.OrdQty , true , stName);
    end;
  end;
end;

procedure TVolTrade.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;
  aQuote  := DataObj as TQuote;

  if not IsRun then Exit;

  if not FReady then
    OnInit( aQuote )
  else
    OnQuote( aQuote );
end;

procedure TVolTrade.OnInit(aQuote: TQuote);
begin
  if ( FParam.BaseUpPrc < 0.00001 ) or ( FParam.BaseDownPrc < 0.00001 ) or
     ( aQuote.Last < 0.00001 ) then
    Exit;

  if ( aQuote.Last <= FParam.BaseDownPrc ) or ( aQuote.Last >= FParam.BaseUpPrc ) then
  begin
    DoOrder( aQuote, 1 , aQuote.Last);
    DoOrder( aQuote, -1, aQuote.Last);
    DoLog( Format('Init Vol Trade --> Cur Price %s', [ aQuote.PrcToStr( aQuote.Last  ) ]));
    FReady := true;
  end;
end;

procedure TVolTrade.OnQuote(aQuote: TQuote);
begin
  if not IsRun then Exit;

  if ( aQuote.Last > FParam.LimitUp ) or ( aQuote.Last < FParam.LimitDown )  then
  begin

    if FLossCut then Exit;
    
    DoLog( Format('Limit Over  L - %s, Param - %s, %s', [ aQuote.PrcToStr( aQuote.Last),
      aQuote.PrcToStr( FParam.LimitUp ), aQuote.PrcToStr( FParam.LimitDown)]));

    DoCancelAll;
    DoLiquid( aQuote );
  end;
end;

procedure TVolTrade.DoOrder(aQuote: TQuote; iSide : integer; dBasePrc: double; bPave : boolean);
var
  iQty, I: Integer;
  aAccount : TAccount;
  aItem : TFundItem;
  dPrice: double;
begin

  dPrice  := TicksFromPrice( aQuote.Symbol, dBasePrc, FParam.OrdGap * iSide * -1 );

  iQty     := FParam.OrdQty;
  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aItem := FFund.FundItems.FundItem[i];
      DoOrder( aItem.Account, iSide, dPrice, iQty * aItem.Multiple, bPave, FFund.Name );
    end;
  end else
  begin
    DoOrder( FAccount, iSide, dPrice, iQty, bPave );
  end;

end;

procedure TVolTrade.DoOrder(aAccount : TAccount; iSide : integer; dPrice: double;
  iQty : integer; bPave : boolean; stFName : string);
var
  stTxt  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
begin

  if ( aAccount = nil ) then Exit;

  if ( dPrice < 0.00001 ) or ( iQty < 0 ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f ',  [ aAccount.Code,
      FSymbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, FSymbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket );
    if bPave then    
      if aOrder.Side > 0 then
        FBidOrders.Add( aOrder )
      else
        FAskOrders.Add( aOrder );

    aOrder.OrderSpecies := opHult;
    aOrder.FundName := stFName;

    DoLog( Format('%s Send Order : %s, %s, %s, %s, %d', [
        ifThenStr( bPave, '신규', '청산' ),
        aAccount.Code, FSymbol.ShortCode, ifThenStr( iSide > 0, '매수','매도'),
        FSymbol.PriceToStr( dPrice ), iQty
      ]));

  end;
end;

end.
