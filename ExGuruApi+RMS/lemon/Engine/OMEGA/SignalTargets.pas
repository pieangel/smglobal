unit SignalTargets;

interface

uses
  Classes, SysUtils, Controls, Dialogs,  ExtCtrls ,
  //

  GleTypes,CleDistributor,{ AppUtils, EtcTypes, Broadcaster, Globals,
  TradeCentral,} CleOrders, CleQuoteBroker, GleConsts,
  CleAccounts, CleSymbols, ClePositions, CleTradeBroker,
  SystemIF, Signals, SignalLinks,
  DSignalConfig, CleQuoteTimers,
  SignalData;

type
  // storage for chasing an order issued by a signal event
  TChasingState = (csNone, csWaitingAccept, csWaitingFill, csPartFill,
                   csRejected, csManual, csCancel, csFullFill);
const
  ChasingStateDescs : array[TChasingState] of String =
                  ('', '접수대기', '체결대기', '부분체결',
                  '주문거부', '수동정정', '취소', '전량체결');
  PRICE_EPSILON = 0.001;
  EPSILON = 1.0e-8;
type
  TSignalTargetItem = class;

  TChasingItem = class(TCollectionItem)
  private
    FOwner : TSignalTargetItem;

    FActor : TSignalItem;
    FIssuedTime : TDateTime;
    FAccount : TAccount;
    FSymbol : TSymbol;
    FQty : Integer;
    FRemark : String;

    FState : TChasingState;

    //FReq : TOrderReqItem;
    FOrder : TOrder;
    FFillPrice : Double;

    FRetryCount : Integer;
    FCounter : Integer;

    FOnTimeOut : TNotifyEvent;
    FQuoteTimer: TQuoteTimer;

    procedure BeaterProc(Sender : TObject);
    function GetStateDesc : String;
    function GetDescription : String;
  public
    destructor Destroy; override;

    procedure SetCounter(iCount : Integer);
    procedure ResetCounter;

    property Owner : TSignalTargetItem read FOwner;
    property Actor : TSignalItem read FActor;
    property IssuedTime : TDateTime read FIssuedTime;
    property Account : TAccount read FAccount;
    property Symbol : TSymbol read FSymbol;
    property Qty : Integer read FQty;
    property State : TChasingState read FState;
    property Remark : String read FRemark;
    property StateDesc : String read GetStateDesc;
    property RetryCount : Integer read FRetryCount;
    property FillPrice : Double read FFillPrice;
    property Order : TOrder read FOrder write FOrder;

    property Description : String read GetDescription;

    property OnTimeOut : TNotifyEvent read FOnTimeOut write FOnTimeOut;
  end;

  TSignalTargets = class;


  TSignalTargetItem = class(TCollectionItem)
  private
    FParent : TSignalTargets;
    FChasingItems : TList;

    // SignalTarget 기본 : 계좌별, 종목별
    FAccount : TAccount;
    FSymbol : TSymbol;
    FPosition : TPosition;

    // 관련 수량
    FTargetQty : Integer;           // 목표 수량
    //FPositionQty : Integer;         // 포지션 수량
    //FOrderQty : array[TPositionType] of Integer ;       // 현재 주문 수량 ( 체결 되지 않음)
    //FOrderNewReqQty : array[TPositiontype] of Integer;  // 신규 주문 요청 수량
    //FCancelReqQty : array[TPositionType] of Integer ;   // 취소 요청 수량
    //FChangeReq : array[TPositionType] of boolean ;      // 정정 요청 여부

    //
    FOrderHandler : TTradeBroker;
    FLinks : TList{TSignalLinkItem};
    //FOrders : TList{TOrderItem};

    FOnLog : TTextNotifyEvent;
    FOnUpdate : TNotifyEvent;
    FOnChasingUpdate : TNotifyEvent;
    FOnAutoTargetState : TNotifyEvent;

    //procedure CalcStatus;
    function GetPrice(iPriceIndex : TPriceIndexRange; aPositionType : TPositionType): double;
    //function FindChasingItem(aReq : TOrderReqItem) : TChasingItem; overload;
    function FindChasingItem(aOrder : TOrder) : TChasingItem; overload;
    function FindChasingItem(iOrderNo : Integer) : TChasingItem; overload;
    //
    procedure PutOrder(aSignal : TSignalItem; iQty : Integer; dPrice : double = 0 );

    // set
    procedure SetSymbol(aSymbol : TSymbol);

    // Subscribe
    procedure ChasingTimeoutProc(Sender : TObject);
    procedure OrderReqProc(Sender : TObject);

    procedure PositionProc(aPosition : TPosition );

    procedure OrderProc(Sender, Receiver: TObject;
              DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(Sender, Receiver: TObject;
              DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    // misc
    procedure DoLog(stLog : String);
    //function GetOrderQty(ptValue: TPositionType): Integer;
    //function GetCancelQty(ptValue: TPositionType): Integer;
    //function GetNewQty(ptValue: TPositionType): Integer;
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;
    //
    procedure AddLink(aLink : TSignalLinkItem);
    procedure UpdateLink(aLink : TSignalLinkItem);
    procedure RemoveLink(aLink : TSignalLinkItem);
    procedure NewOrder(aLink : TSignalLinkItem; aEvent : TSignalEventItem);
    //                                         
    procedure TargetPosition;
    procedure CalcTarget;
    //
    procedure SetAuto(bEnabled : Boolean);
    procedure ClearPosition;
    procedure CancelAllOrders;
    procedure CancelOrder(aChasing : TChasingItem);
    //
    property Account : TAccount read FAccount;
    property Symbol : TSymbol read FSymbol write SetSymbol;
    property Position : TPosition read FPosition write FPosition;

    property TargetQty : Integer read FTargetQty;
    //property PositionQty : Integer read FPositionQty;
    //property OrderQty[ptValue : TPositionType] : Integer read GetOrderQty ;
    //property CancelQty[ptValue : TPositionType] : Integer read GetCancelQty ;
    //property NewQty[ptValue : TPositionType] : Integer read GetNewQty ;

    property Links : TList read FLinks;

    property OnLog : TTextNotifyEvent read FOnLog write FOnLog;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnChasingUpdate : TNotifyEvent read FOnChasingUpdate write FOnChasingUpdate;

    //  FTargets.OnChasingUpdate := ChasingUpdate;
    //  aLink.OnUpdate := UpdateLink;
    //  aLink.OnRemove := RemoveLink;
    //  aLink.OnOrder := NewOrder;
  end;

  TSignalTargets = class(TCollection)
  private
    FChasingItems : TCollection{TChasingItem};
    //
    FClear : Boolean ;
    //
    FOnLog : TTextNotifyEvent;
    FOnUpdate : TNotifyEvent;
    FOnChasingUpdate : TNotifyEvent;
    FOnAutoTargetState : TNotifyEvent;
    //
    FChasingConfig : TChasingConfig;
    //
    function GetTarget(i:Integer) : TSignalTargetItem;
    procedure SetAutoChasing(Value : Boolean);

    function GetChasingItem(i:Integer) : TChasingItem;
    function GetChasingItemCount : Integer;
    //
    procedure LoadConfig;
    procedure SaveConfig;
  public
    constructor Create;
    destructor Destroy ; override;
    //
    procedure TargetPositions;
    procedure ConfigChasing;
    procedure ClearAllPositions;
    procedure CancelAllOrders;
    //
    function Find(aLink : TSignalLinkItem) : TSignalTargetItem;
    function AddLink(aLink : TSignalLinkItem) : TSignalTargetItem;
    //
    property AutoChasing : Boolean read FChasingConfig.Auto write SetAutoChasing;
    property Targets[i:Integer] : TSignalTargetItem read GetTarget; default;

    property Orders[i:Integer] : TChasingItem read GetChasingItem;
    property OrderCount : Integer read GetChasingItemCount;
    property ChasingConfig : TChasingConfig read FChasingConfig;
    //
    property OnLog : TTextNotifyEvent read FOnLog write FOnLog;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnChasingUpdate : TNotifyEvent read FOnChasingUpdate write FOnChasingUpdate;
    property OnAutoTargetState : TNotifyEvent read FOnAutoTargetState write FOnAutoTargetState ;

  end;

procedure SaveToFile(stFile, stData : String);

implementation

uses
  EnvFile{, PriceCentral,
  LogCentral}, GAppEnv;

const
  REJECT_MAX_COUNT = 10 ;

procedure SaveToFile(stFile, stData : String);
var
  F : TextFile;
begin
  AssignFile(F, stFile);
  try
    //
    if not FileExists(stFile) then
      Rewrite(F)
    else
      Append(F);
    //
    Writeln(F, stData);
    CloseFile(F);
  except
    CloseFile(F);
  end;
end;

//===============================================================//
                     { TChasingItem }
//===============================================================//

destructor TChasingItem.Destroy;
begin
  if FQuoteTimer <> nil then
    FQuoteTimer.Enabled := false;
  inherited;
end;

procedure TChasingItem.BeaterProc(Sender : TObject);
var
  stTmp : string;
begin
  if FCounter < 0 then exit;
  if FQuoteTimer = nil then exit;

  if (FCounter = 0) or
     not (FState in [csPartFill, csWaitingFill]) then
       FQuoteTimer.Enabled := false;

  Dec(FCounter);
  if FCounter = 0 then
  begin
    Inc(FRetryCount);
    if Assigned(FOnTimeOut) then
       FOnTimeOut(Self);
  end;

end;

procedure TChasingItem.SetCounter(iCount : Integer);
var
  stTmp : string;
begin
  if FCounter > 0 then Exit;
  FCounter := iCount;
  FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FQuoteTimer.Interval := 1000;
  FQuoteTimer.OnTimer := BeaterProc;
  FQuoteTimer.Enabled := True;
end;

function TChasingItem.GetStateDesc : String;
begin
  if FState in [csPartFill, csWaitingFill] then
    Result := ChasingStateDescs[FState] + '(' + IntToStr(FRetryCount) + ')'
  else
    Result := ChasingStateDescs[FState];
end;

procedure TChasingItem.ResetCounter;
begin
 if FQuoteTimer <> nil then
   FQuoteTimer.Enabled := false;
 FCounter := 0;
end;

function TChasingItem.GetDescription : String;
begin
    // actor
  if FActor = nil then
    Result := '사용자'
  else
    Result := FActor.Title+'/' + FActor.Description;

    // 계좌 & 종목
  if FAccount <> nil then
    Result := Result + '/' + FAccount.Code;
  if FSymbol <> nil then
    Result := Result + '/' + FSymbol.Code;

    // 수량 & 상태 & 재시도 회수
  Result := Result + '/Q:' + IntToStr(FQty)
                   + '/S:' + ChasingStateDescs[FState]
                   + '/R:' + IntToStr(FRetryCount);
end;

//===============================================================//
                     { TSignalTargetItem }
//===============================================================//

// (public)
// constructor
//
constructor TSignalTargetItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FChasingItems := TList.Create;

  FOrderHandler := gEnv.Engine.TradeBroker;
  //??
  //FOrderHandler.OnChanged := OrderReqProc;
  //FOrderHandler.OnOrderChange

  FLinks := TList.Create;
  //FOrders := TList.Create;
end;


destructor TSignalTargetItem.Destroy;
begin
  gEnv.Engine.TradeBroker.Unsubscribe( self );


  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( self );

  //FOrderHandler.Free;
  //FOrders.Free;
  FLinks.Free;

  FChasingItems.Free;

  inherited;
end;

//-----------------------------< Definining >----------------------------//

// (private : property method)
// set a symbol
//
procedure TSignalTargetItem.SetSymbol(aSymbol : TSymbol);
var
  i : Integer;
  aOrder : TOrder;
begin
  if (FAccount = nil) or (aSymbol = nil) then Exit;

  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( self, FSymbol );
  gEnv.Engine.QuoteBroker.Subscribe( self, aSymbol, QuoteProc);

  FSymbol := aSymbol;

  gEnv.Engine.TradeBroker.Subscribe( self, OrderProc );
  // get position object
  FPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, FSymbol );
end;

//-----------------------< Public : Managing Links >-----------------------//

procedure TSignalTargetItem.AddLink(aLink : TSignalLinkItem);
begin
  if aLink = nil then Exit;
  if FLinks.IndexOf(aLink) >= 0 then Exit; // already added

  aLink.Signal.Refer;
  aLink.OnUpdate := UpdateLink;
  aLink.OnRemove := RemoveLink;
  aLink.OnOrder := NewOrder;

  FLinks.Add(aLink);
  //
  CalcTarget;
end;

procedure TSignalTargetItem.UpdateLink(aLink : TSignalLinkItem);
begin
  if aLink = nil then Exit;

  CalcTarget;
end;

procedure TSignalTargetItem.RemoveLink(aLink : TSignalLinkItem);
begin
  if aLink = nil then Exit;
  if FLinks.IndexOf(aLink) < 0 then Exit; // not added

  aLink.Signal.Derefer;
  FLinks.Remove(aLink);
  //
  if FLinks.Count > 0 then
  begin
    CalcTarget;
  end else
    Free;
end;

//----------------------< Setting Auto Enabled >--------------------//

procedure TSignalTargetItem.SetAuto(bEnabled : Boolean);
var
  i : Integer;
  aChasing : TChasingItem;
begin
  for i:=0 to FChasingItems.Count-1 do
  begin
    aChasing := TChasingItem(FChasingItems.Items[i]);

    if bEnabled then
    begin
      if (aChasing.State in [csWaitingFill, csPartFill]) and
         (aChasing.RetryCount < FParent.ChasingConfig.MaxRetryCount) then
        aChasing.SetCounter(FParent.ChasingConfig.TimeOut);
    end else
    begin
      aChasing.ResetCounter;
    end;
  end;
end;

//--------------------< Order Triggers for canceling orders >---------------//

// (public)
// Cancel all pending orders for this target item
//
procedure TSignalTargetItem.CancelAllOrders;
var
  i : Integer;
  aChasing : TChasingItem;
  aTicket : TOrderTicket;
begin
  aChasing := nil;

  for i:=0 to FChasingItems.Count-1 do
  begin
    aChasing := TChasingItem(FChasingItems.Items[i]);

    if (aChasing.Order <> nil) and
       (aChasing.Order.State = osActive ) then
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      gEnv.Engine.TradeCore.Orders.NewCancelOrder( aChasing.Order,
           aChasing.Order.ActiveQty, aTicket )  ;
      gEnv.Engine.TradeBroker.Send(aTicket);

      aChasing.FRemark := '사용자 취소';

    end;
  end;

  if (aChasing <> nil) and Assigned(FOnChasingUpdate) then
  try
    FOnChasingUpdate(aChasing); // just a meaningless representative
  except
  end;
end;

// (public)
// Cancel an order
procedure TSignalTargetItem.CancelOrder(aChasing : TChasingItem);
var
  aTicket : TOrderTicket;
begin
  if aChasing = nil then Exit;

  if (aChasing.Order <> nil) and
     (aChasing.Order.State = osActive) then
  begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    gEnv.Engine.TradeCore.Orders.NewCancelOrder(aChasing.Order, aChasing.Order.ActiveQty, aTicket);
    gEnv.Engine.TradeBroker.Send(aTicket);
    //aChasing.FReq := FOrderHandler.Put(aChasing.Order, aChasing.Order.UnfillQty);
    aChasing.FRemark := '사용자 취소';

    //if FOrderhandler.WaitCount > 0 then
    //  FOrderHandler.Send;
  end;

  if Assigned(FOnChasingUpdate) then
  try
    FOnChasingUpdate(aChasing);
  except
  end;
end;

//----------------------< Order Triggers for making position >---------------//

// (Public)
// Synchronize positions between signal source and the form
//
procedure TSignalTargetItem.TargetPosition;
var
  iDiff, iEpQty : Integer;
begin
  // CalcStatus;

  //-- get current position quantity
  if FPosition = nil then
    iEpQty := 0
  else
    iEpQty := FPosition.Volume + FPosition.ActiveBuyOrderVolume - FPosition.ActiveSellOrderVolume;
  {
    iEpQty := FPosition.CurQty + FPosition.NewOrderQtys[ptLong] -
                                 FPosition.NewOrderQtys[ptShort];
  }

  //-- get diff
  iDiff := FTargetQty - iEpQty;

  //-- put order
  PutOrder(nil, iDiff);
end;

// (private)
// Handles order event from signal source
//
procedure TSignalTargetItem.NewOrder(aLink : TSignalLinkItem; aEvent : TSignalEventItem);
begin
  if (aLink = nil) or (aEvent = nil) or (aEvent.Signal = nil) then Exit;

  PutOrder(aEvent.Signal, aEvent.Qty * aLink.Multiplier);
end;

// (private)
// -- used by TargetPositions()
// calculate the sum of signal positions
//
procedure TSignalTargetItem.CalcTarget;
var
  i, iSum : Integer;
  aLink : TSignalLinkItem;
begin
  iSum := 0;
  for i:=0 to FLinks.Count-1 do
  begin
    aLink := TSignalLinkItem(FLinks.Items[i]);
    iSum := iSum + aLink.Position;
  end;

  FTargetQty := iSum;
end;

// (private) -- defunct
// -- used by TargetPositions()
// calculate the current status of the position
//
{
procedure TSignalTargetItem.CalcStatus;
var
  i : Integer;
begin
  // position qty, order qty
  if FPosition = nil then
    begin
      FPositionQty := 0;
      FOrderQty[ptLong] := 0 ;
      FOrderQty[ptShort] := 0;
    end
  else
    begin
      FPositionQty := FPosition.CurQty;
      FOrderQty[ptLong] := FPosition.OrderQtys[ptLong];
      FOrderQty[ptShort] := FPosition.OrderQtys[ptShort];
      // 평균단가
      //if gUseB then
      //  FAvgPrice := FPosition.AvgPriceB
      //else
      //  FAvgPrice := FPosition.AvgPrice ;
      //
    end;

  // OrderReq qty 구하기

  // 초기화
  FOrderNewReqQty[ptLong] := 0;
  FOrderNewReqQty[ptShort] := 0;
  FCancelReqQty[ptLong] := 0;
  FCancelReqQty[ptShort] := 0;
  FChangeReq[ ptLong] := false ;
  FChangeReq[ ptShort] := false ;

  // 구하기
  if FOrderHandler.WaitCount > 0 then
    for i:=0 to FOrderHandler.Count-1 do
      if ( FOrderHandler.Reqs[i].IsDoing )  then
        begin
          // 정정주문 요청여부
          if  ( FOrderHandler.Reqs[i].OrderType = otChange ) then
            FChangeReq[ FOrderHandler.Reqs[i].PositionType ] := true ;

          // 신규주문 요청수량
          if  ( FOrderHandler.Reqs[i].OrderType = otNew ) then
            begin
              Inc( FOrderNewReqQty[FOrderHandler.Reqs[i].PositionType] ,
                    FOrderHandler.Reqs[i].Qty ) ;
            end;

          // 취소주문 요청수량
          if  ( FOrderHandler.Reqs[i].OrderType = otCancel ) then
            begin
              Inc( FCancelReqQty[FOrderHandler.Reqs[i].PositionType] ,
                    FOrderHandler.Reqs[i].Qty );
            end;
          //
        end;  // for end
end;
}

//-----------------------< Private : Handling Order >------------------------//

// (public)
// Clear position when the time pass a designated time
//
procedure TSignalTargetItem.ClearPosition;
var
  i : Integer;
  aOrder : TOrder;
  ptValue : TPositionType;
  aChasing : TChasingItem;
  aTicket : TOrderTicket;
begin
  // all orders in control should be canceled before clear the position
  // but, if that is the same direction? 
  for i:=0 to FChasingItems.Count-1 do
  begin
    aChasing := TChasingItem(FChasingItems.Items[i]);
    if (aChasing.Order <> nil) and
       (aChasing.Order.State = osActive ) then  begin// [osKseAcpt, osPartFill]) then
      //FOrderhandler.Put(aChasing.Order, aChasing.Order.UnfillQty);
      gEnv.Engine.TradeCore.Orders.NewCancelOrder( aChasing.Order,
           aChasing.Order.ActiveQty, aTicket )  ;
      gEnv.Engine.TradeBroker.Send(aTicket);

    end;
  end;

  //if FOrderHandler.WaitCount > 0 then
  //  FOrderHandler.Send;

  //--2. Clear the position
  if (FPosition <> nil) and (FPosition.Volume <> 0) then
    PutOrder(nil, -FPosition.Volume);
end;

// (private)
// -- used by TargetPositions() and NewOrder()
// fires an order
//
procedure TSignalTargetItem.PutOrder(aSignal : TSignalItem; iQty : Integer; dPrice : double);
var
  aItem : TChasingItem;
  ptValue : TPositionType;
  pcValue: TPriceControl;
  tmValue: TTimeToMarket;
  aTicket: TOrderTicket;
  aOrder, aTmpOrder  : TOrder;
  iClearQty, iRemainQty,iSentQty, iRet : integer;
  stLog, stTmp : string;
begin
  if (FAccount = nil) or (FSymbol = nil) or
     (iQty = 0) or (dPrice < 0) then Exit;

  iSentQty := 0;
  iRemainQty := 0;
  iClearQty := 0;

  iSentQty := iQty;
  //--1. add a chasing item
  aItem := FParent.FChasingItems.Insert(0) as TChasingItem;
    // set owner
  aItem.FOwner := Self;
    // set basic info
  aItem.FActor := aSignal;
  aItem.FIssuedTime := Now;
  aItem.FAccount := FAccount;
  aItem.FSymbol := FSymbol;
  aItem.FQty := iQty;
    // set init state
  aItem.FState := csNone;
  aItem.FRetryCount := 0;
  aItem.FCounter := 0;
  aItem.FRemark := '';

  aItem.FOrder := nil;
  //aItem.FReq := nil;
  // set event
  aItem.FOnTimeOut := ChasingTimeOutProc;
    // add to local list
  FChasingItems.Add(aItem);

  //-- 2. send an order
  if iQty > 0 then
    ptValue := ptLong
  else
    ptValue := ptShort;

  tmValue := tmFAS;
  //??
  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  if dPrice = 0  then
  begin
    // at market price
    if FParent.ChasingConfig.PriceNew = AT_MARKET_INDEX then //시장가 주문
      gEnv.OnLog(Self, '시장가 주문 금지')
    else
    begin
      dPrice := GetPrice(FParent.ChasingConfig.PriceNew, ptValue);
      aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrder( gEnv.ConConfig.UserID, aItem.Account, FSymbol,
         iQty, pcLimit, dPrice, tmValue, aTicket );
    end;
  end else
  begin            //dPrice > 0 정정 신규 주문 일때
    aOrder:= gEnv.Engine.TradeCore.Orders.NewNormalOrder( gEnv.ConConfig.UserID, aItem.Account, FSymbol,
         iQty, pcLimit, dPrice, tmValue, aTicket );
  end;

  if aOrder <> nil then
  begin
    aItem.FState := csWaitingAccept;
    aItem.Order := aOrder;
    gEnv.Engine.TradeBroker.Send( aTicket );
    stTmp := '신규주문';
    stLog := Format('주문 Send , Code = %s, Price = %f, Qty = %d, %s', [aOrder.Symbol.Code , aOrder.Price, aOrder.OrderQty, stTmp]);
    gEnv.DoLog(WIN_TS, stLog);
    //--3. notify update
    if Assigned(FOnChasingUpdate) then
      FOnChasingUpdate(aItem);
  end
  else
  begin
    stLog := Format('신규주문 생성 못함 Code = %s, Price = %f, Qty = %d', [FSymbol.Code, dPrice, iQty]);
    gEnv.DoLog(WIN_TS, stLog);
  end;
end;

//----------------------------< Processing Events >--------------------//

// (private)
// handling the time out event of chasing items(Time to change)
//
procedure TSignalTargetItem.ChasingTimeOutProc(Sender : TObject);
var
  aChasing : TChasingItem;
  iPriceIndex, iQty : Integer;
  dPrice : Double;
  aOrder  : TOrder;
  aTicket : TOrderTicket;
  aPosition : TPosition;
begin
  //??
  //-- basic filter
  if Sender = nil then Exit;
    // if not automatic following of an order
  if not FParent.ChasingConfig.Auto then Exit;

  //-- get object
  aChasing := Sender as TChasingItem;

  //-- filter II
  if (not (aChasing.State in [csPartFill, csWaitingFill])) or
     (aChasing.RetryCount > FParent.ChasingConfig.MaxRetryCount) then Exit;

  //-- get price index
  if aChasing.RetryCount = FParent.ChasingConfig.MaxRetryCount then
    iPriceIndex := FParent.ChasingConfig.PriceLast
  else
    iPriceIndex := FParent.ChasingConfig.PriceChange;

  //-- make order request
     // order at market

  if iPriceIndex = AT_MARKET_INDEX then    //시장가 주문은 안됨.......  khw
  begin
    gEnv.OnLog(Self, '시장가 주문 금지')
  end else
    // order at limit
  begin
    dPrice := GetPrice(iPriceIndex, aChasing.FOrder.PositionType);
    if Abs(dPrice - aChasing.FOrder.Price) > PRICE_EPSILON then
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      //취소주문 발주
      iQty := aChasing.Order.ActiveQty;
      aChasing.FOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrder(aChasing.Order, iQty , aTicket);
      aChasing.FRemark := IntToStr(aChasing.RetryCount) + '정정 취소';
      aChasing.FQuoteTimer.Enabled := false;

      if FOrderHandler.Send( aTicket ) > 0 then
      begin
        //신규 주문 발주
        if aChasing.FOrder.Side = 1 then
          PutOrder(nil, iQty, dPrice)
        else
          PutOrder(nil, -iQty, dPrice);
      end;
    end else
    begin
      aTicket := nil;
      aChasing.FRemark :=
                    IntToStr(aChasing.RetryCount) + '차 정정안함(동일 가격)';
        //.. logging
        DoLog('자동주문 >> ' + aChasing.FRemark + ' : ' + aChasing.Description);
        //.. logging
      if aChasing.RetryCount < FParent.ChasingConfig.MaxRetryCount then
      begin
        if FParent.ChasingConfig.Auto then
        begin
          if aChasing.FQuoteTimer = nil then         //khw
            aChasing.SetCounter(FParent.ChasingConfig.TimeOut)
          else
            aChasing.FCounter := FParent.ChasingConfig.TimeOut;
            aChasing.FQuoteTimer.Enabled := true;
        end;
      end;
    end;
  end;
end;

procedure TSignalTargetItem.OrderReqProc(Sender : TObject);
var
  aChasing : TChasingItem;
  aOrder  : TOrder;
begin
  if Sender = nil then Exit;

  aOrder := Sender as TOrder;
  aChasing := FindChasingItem(aOrder);

  if aChasing = nil then Exit;

  if (aChasing.State = csWaitingAccept) and
     (aOrder.State in [osSrvRjt, osRejected, osFailed]) then
  begin
    case aOrder.OrderType of
      otNormal :
          begin
            aChasing.FState := csRejected;
            aChasing.FRemark := aOrder.Reason;
               //.. logging
              gEnv.DoLog(WIN_TS, '신규주문 실패 : ' + aChasing.FRemark + ' : ' + aChasing.Description);
              //.. logging
         end;
      otChange :
          begin
            //aChasing.Order := nil;
            aChasing.FRemark := IntToStr(aChasing.RetryCount) + '차 정정 실패';
               //.. logging
              gEnv.DoLog(WIN_TS, aChasing.FRemark + ' : ' + aChasing.Description);
              //.. logging
          end;
    end;

    if Assigned(FOnChasingUpdate) then
      FOnChasingUpdate(aChasing);
  end;
end;

procedure TSignalTargetItem.OrderProc(Sender, Receiver: TObject;
              DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aOrder : TOrder;
  aChasing : TChasingItem;
  aPosition : TPosition;
begin
  if DataObj = nil then Exit;

  aChasing := nil;
  if DataObj is TOrder then
    aOrder := DataObj as TOrder
  else if DataObj is TPosition then
    aPosition := DataObj as TPosition
  else
    exit;

  // filter
  if aOrder <> nil then
    if (aOrder.Account <> FAccount) or (aOrder.Symbol <> FSymbol) then Exit;

  case Integer( EventID ) of
    POSITION_NEW,
    POSITION_UPDATE :
      begin
        PositionProc( aPosition );
      end ;
    ORDER_FILLED :
        begin
          aChasing := FindChasingItem(aOrder);
          if aOrder.State = osFilled then
          begin
            if (aChasing <> nil) and
               (aChasing.State <> csFullFill) then
            begin
              aChasing.FState := csFullFill;
              aChasing.FFillPrice := aOrder.FilledPrice;
                             //.. logging
                            gEnv.DoLog(WIN_TS, '주문추적 >> 전량체결' + ' : ' + aChasing.Description);
                            //.. logging
            end;
          end
          else begin
            if (aChasing <> nil) and
               (aChasing.State <> csPartFill) then
            begin
              aChasing.FState := csPartFill;
              aChasing.FFillPrice := aOrder.FilledPrice;
                             //.. logging
                            gEnv.DoLog(WIN_TS,'주문추적 >> 부분체결' + ' : ' + aChasing.Description);
                            //.. logging
            end;
          end;            //
        end;
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED :
      begin
        case aOrder.State of
          osActive :
              case aOrder.OrderType of
                otNormal :
                   begin
                       // new order
                     if aOrder.Target = nil then         //??
                       aChasing := FindChasingItem(aOrder.OrderNo)
                     else // change -> new order
                       aChasing := FindChasingItem(aOrder.Target);

                     if (aChasing <> nil) then
                     begin
                       if (aChasing.State in [csWaitingAccept, csWaitingFill, csPartFill]) then
                       begin
                         //aChasing.FReq := nil;
                         aChasing.FOrder := aOrder;
                         aChasing.FState := csWaitingFill;
                         if aChasing.RetryCount < FParent.ChasingConfig.MaxRetryCount then
                           if FParent.ChasingConfig.Auto then
                           begin
                            aChasing.SetCounter(FParent.ChasingConfig.TimeOut);
                           end;
                                 //.. logging
                                gEnv.DoLog(WIN_TS,'주문추적 >> 증전 접수' + ' : ' + aChasing.Description);
                                //.. logging
                       end else
                       begin
                         aChasing.FOrder := aOrder;
                       end;
                     end;
                   end;
                otChange :
                   begin
                     aChasing := FindChasingItem(aOrder.OrderNo);
                     if aChasing = nil then
                     begin
                       aChasing := FindChasingItem(aOrder.Target);
                       if aChasing <> nil then
                       begin
                         aChasing.FState := csManual;
                         aChasing.FRemark := '사용자 개입';
                                 //.. logging
                                gEnv.DoLog(WIN_TS,'주문추적 >> 사용자 정정' + ' : ' + aChasing.Description);
                                //.. logging
                       end;
                     end;
                   end;
                otCancel :
                   begin
                     aChasing := FindChasingItem(aOrder.OrderNo);
                     if aChasing = nil then
                       aChasing := FindChasingItem(aOrder.Target);

                     if aChasing <> nil then
                     begin
                       aChasing.FState := csCancel;
                       aChasing.FRemark := '사용자 취소';
                                 //.. logging
                                gEnv.DoLog(WIN_TS,'주문추적 >> 사용자 취소' + ' : ' + aChasing.Description);
                                //.. logging
                     end;
                   end;
              end;

          osCanceled :
            begin
              aChasing := FindChasingItem(aOrder);
                if (aChasing <> nil) then
                begin
                  aChasing.FState := csCancel;
                  aChasing.FRemark := '취소';
                                 //.. logging
                                gEnv.DoLog(WIN_TS,'주문추적 >> 취소' + ' : ' + aChasing.Description);
                                //.. logging
                end;
            end;
          osSrvRjt, osRejected, osFailed :
              begin
                aChasing := FindChasingItem(aOrder);
                if (aChasing <> nil) and
                   (aChasing.State in [csWaitingAccept, csWaitingFill, csPartFill]) then
                begin
                  aChasing.FState := csRejected;
                  aChasing.FRemark := '거래소 거부';
                                 //.. logging
                                gEnv.DoLog(WIN_TS,'주문추적 >> 거래소 거부' + ' : ' + aChasing.Description);
                                //.. logging
                end;
              end;
        end;
      end;
  end;

  if Assigned(FOnChasingUpdate) and (aChasing <> nil) then
  try
    FOnChasingUpdate(aChasing);
  except
  end;

  if Assigned(FOnUpdate) then
  try
    FOnUpdate(Self);
  except
    //
  end;
end;

// (private)
// <-- called from TPositionStore if aPosition is created or its quantity updated
// 1. Set position reference if it is nil
// 2. notify the position update
//
procedure TSignalTargetItem.PositionProc(aPosition : TPosition);
begin

  if aPosition = nil then Exit;

  if (aPosition.Account <> FAccount) or (aPosition.Symbol <> FSymbol) then Exit;

  //if FPosition = nil then
  FPosition := aPosition;

   //CalcStatus; -- considering to delete

  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
end;



// (private)
// <-- called from TSymbolItem
// Fire an OnUpdate event
//
procedure TSignalTargetItem.QuoteProc(Sender, Receiver: TObject;
              DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin
  if Assigned(FOnUpdate) then
  try
    FOnUpdate(Self);
  except
    //
  end;
end;


//--------------------------< Misc >-------------------------------------//

// (private)
// Handles event of log from other log sources
//
procedure TSignalTargetItem.DoLog(stLog : String);
begin
  if Assigned(FOnLog) then
    FOnLog(self, stLog);
end;


{
function TSignalTargetItem.GetOrderQty(ptValue: TPositionType): Integer;
begin
  Result := FOrderQty[ptValue] ;
end;


function TSignalTargetItem.GetCancelQty(ptValue: TPositionType): Integer;
begin
  Result := FCancelReqQty[ptValue] ;
end;


function TSignalTargetItem.GetNewQty(ptValue: TPositionType): Integer;
begin
  Result := FOrderNewReqQty[ptValue] ;
end;
}

function TSignalTargetItem.GetPrice(iPriceIndex : TPriceIndexRange; aPositionType : TPositionType): double;
var
  qtValue : TMarketDepths;
  aQuote : TQuote;
  dPrice : Double;
begin
  Result := 0.0;

  if FSymbol = nil then Exit;

  aQuote  := gEnv.Engine.QuoteBroker.Find( FSymbol.Code );
  if aQuote = nil then
    Exit;

  if FSymbol.Last = 0 then exit;
  
  case iPriceIndex of
    0 : Result := FSymbol.Last;                                     //현재가
    1..5 :                                                          //호가1~5
      begin
        if aPositionType = ptLong then
          dPrice := FSymbol.Last + (FSymbol.Spec.TickSize *iPriceIndex)
        else
          dPrice := FSymbol.Last - (FSymbol.Spec.TickSize*iPriceIndex);
        Result := dPrice;
      end;
    -1 :                                                             //반대호가1
      begin
        if aPositionType = ptLong then
          dPrice := FSymbol.Last - FSymbol.Spec.TickSize * 5
        else
          dPrice := FSymbol.Last + FSymbol.Spec.TickSize * 5;
        Result := dPrice;
      end;
  end;
end;

{
//??
function TSignalTargetItem.FindChasingItem(aReq : TOrderReqItem) : TChasingItem;
var
  i : Integer;
begin
  Result := nil;

  if aReq = nil then Exit;

  for i:=0 to FChasingItems.Count-1 do
    if TChasingItem(FChasingItems.Items[i]).FReq = aReq then
    begin
      Result := TChasingItem(FChasingItems.Items[i]);
      Break;
    end;
end;

}
function TSignalTargetItem.FindChasingItem(aOrder : TOrder) : TChasingItem;
var
  i : Integer;
begin
  Result := nil;

  if aOrder = nil then Exit;

  for i:=0 to FChasingItems.Count-1 do
    if TChasingItem(FChasingItems.Items[i]).FOrder = aOrder then
    begin
      Result := TChasingItem(FChasingItems.Items[i]);
      Break;
    end;
end;

function TSignalTargetItem.FindChasingItem(iOrderNo : Integer) : TChasingItem;
var
  i : Integer;
begin
  Result := nil;

  for i:=0 to FChasingItems.Count-1 do
    if (TChasingItem(FChasingItems.Items[i]).Order <> nil) and
       (TChasingItem(FChasingItems.Items[i]).Order.OrderNo = iOrderNo) then
    begin
      Result := TChasingItem(FChasingItems.Items[i]);
      Break;
    end;
end;

//===============================================================//
                     { TSignalTargets }
//===============================================================//


constructor TSignalTargets.Create;
begin
  inherited Create(TSignalTargetItem);

  FChasingItems := TCollection.Create(TChasingItem);
  
  FClear := false;
   
  with FChasingConfig do
  begin
    Auto := True;

    TimeOut := 5 ;
    MaxRetryCount := 2;

    PriceNew := 1;
    PriceChange := 2;
    PriceLast := 3;

    ForcedClear := False;
    CloseHour := 15;
    CloseMin := 10;

    NotifyPosition := False;
    NotifySignal := True;
    UseSound := False;
    SoundFile := '체결1.wav';
  end;

  LoadConfig;
  
end;

destructor TSignalTargets.Destroy;
begin
  SaveConfig;
  
  FChasingItems.Free;
  //
  inherited;
end;

//-----------------------------< Link related >------------------------//

// (public)
// find a target item related with a specific link
//
function TSignalTargets.Find(aLink : TSignalLinkItem) : TSignalTargetItem;
var
  i : Integer;
  aTarget : TSignalTargetItem;
begin
  Result := nil;

  for i:=0 to Count-1 do
  begin
    aTarget := Items[i] as TSignalTargetItem;
    if (aTarget.Account = aLink.Account) and
       (aTarget.Symbol = aLink.Symbol) then
    begin
      Result := aTarget;
      Break;
    end;
  end;
end;

// (public)
// add a link to a target item
//
function TSignalTargets.AddLink(aLink : TSignalLinkItem) : TSignalTargetItem;
var
  aTarget : TSignalTargetItem;
begin
  if (aLink = nil) or (aLink.Account = nil) or
     (aLink.Symbol = nil) or (aLink.Signal = nil) then Exit;

  aTarget := Find(aLink);

  if aTarget = nil then
  begin
    aTarget := Add as TSignalTargetItem;

    aTarget.FParent := Self;

    aTarget.OnLog := FOnLog;
    aTarget.OnUpdate := FOnUpdate;
    aTarget.OnChasingUpdate := FOnChasingUpdate;

    aTarget.FAccount := aLink.Account;
    aTarget.Symbol := aLink.Symbol;
  end;

  // apply Link
  aTarget.AddLink(aLink);
  //
end;

//----------------------< Order-Triggering routines >-------------------//

// (public)
// Synchronize position quantity with signal sum
//
procedure TSignalTargets.TargetPositions;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
    Targets[i].TargetPosition;
end;

// (public)
// Clear all position quantities
//
procedure TSignalTargets.ClearAllPositions;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
    Targets[i].ClearPosition;
end;

// (public)
// Cancel all pending orders in control
//
procedure TSignalTargets.CancelAllOrders;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
    Targets[i].CancelAllOrders;
end;

//---------------------< Config >-------------------//

// (public) -- property
// Set auto chasing
//
procedure TSignalTargets.SetAutoChasing(Value : Boolean);
var
  i : Integer;
begin
  if Value = FChasingConfig.Auto then Exit;

  FChasingConfig.Auto := Value;

  for i:=0 to Count-1 do
    Targets[i].SetAuto(Value);
end;

// (public)
// Set chasing config with a dialog
//
procedure TSignalTargets.ConfigChasing;
var
  aDlg : TSignalConfigDialog;
  i : Integer;
begin
  aDlg := TSignalConfigDialog.Create(nil);
  if aDlg = nil then
  begin
    ShowMessage('설정창을 열지 못했습니다.');
    Exit;
  end else
  try
    aDlg.Config := FChasingConfig;

    if aDlg.ShowModal = mrOK then
    begin
      FChasingConfig := aDlg.Config;
    end;
  finally
    aDlg.Free;
  end;
end;

// constants for loading & saiving of chasing config
const
  CHASING_CONFIG = 'chacfg.gsu';
  FILENAME_LEN = 255;
  CONFIG_VERSION = 1;


// (private)
// Load chasing config from a file
//
procedure TSignalTargets.LoadConfig;
var
  aEnvFile : TEnvFile;
  szBuf : array[0..FILENAME_LEN] of Char;
  iVersion : Integer;
begin
  aEnvFile := TEnvFile.Create;
  if aEnvFile.LoadStream(CHASING_CONFIG) then
  with FChasingConfig do
  try
    aEnvFile.Stream.Read(iVersion, SizeOf(Integer));

    aEnvFile.Stream.Read(PriceNew,    SizeOf(TPriceIndexRange));
    aEnvFile.Stream.Read(PriceChange, SizeOf(TPriceIndexRange));
    aEnvFile.Stream.Read(PriceLast,   SizeOf(TPriceIndexRange));

    aEnvFile.Stream.Read(TimeOut,       SizeOf(Integer));
    aEnvFile.Stream.Read(MaxRetryCount, SizeOf(Integer));

    aEnvFile.Stream.Read(ForcedClear,    SizeOf(Boolean));
    aEnvFile.Stream.Read(CloseHour,     SizeOf(Integer));
    aEnvFile.Stream.Read(CloseMin,      SizeOf(Integer));

    aEnvFile.Stream.Read(NotifyPosition, SizeOf(Boolean));
    aEnvFile.Stream.Read(NotifySignal,   SizeOf(Boolean));
    aEnvFile.Stream.Read(UseSound,       SizeOf(Boolean));

    if aEnvFile.Stream.Position + FILENAME_LEN <= aEnvFile.Stream.Size then
    begin
      aEnvFile.Stream.Read(szBuf, FILENAME_LEN);
      SoundFile := szBuf;
    end else
      SoundFile := '체결1.wav';

    aEnvFile.Stream.Read(Auto,       SizeOf(Boolean));

  finally
    aEnvFile.Free;
  end;
end;

// (private)
// Save chasing config to a file
//
procedure TSignalTargets.SaveConfig;
var
  aEnvFile : TEnvFile;
  szBuf : array[0..FILENAME_LEN] of Char;
  iVersion : Integer;
begin
  aEnvFile := TEnvFile.Create;
  with FChasingConfig do
  try
    iVersion := CONFIG_VERSION;
    aEnvFile.Stream.Write(iVersion, SizeOf(Integer));
    
    aEnvFile.Stream.Write(PriceNew,    SizeOf(TPriceIndexRange));
    aEnvFile.Stream.Write(PriceChange, SizeOf(TPriceIndexRange));
    aEnvFile.Stream.Write(PriceLast,   SizeOf(TPriceIndexRange));

    aEnvFile.Stream.Write(TimeOut,       SizeOf(Integer));
    aEnvFile.Stream.Write(MaxRetryCount, SizeOf(Integer));

    aEnvFile.Stream.Write(ForcedClear,    SizeOf(Boolean));
    aEnvFile.Stream.Write(CloseHour,     SizeOf(Integer));
    aEnvFile.Stream.Write(CloseMin,      SizeOf(Integer));

    aEnvFile.Stream.Write(NotifyPosition, SizeOf(Boolean));
    aEnvFile.Stream.Write(NotifySignal,   SizeOf(Boolean));
    aEnvFile.Stream.Write(UseSound,       SizeOf(Boolean));
    StrPCopy(szBuf, SoundFile);
    aEnvFile.Stream.Write(szBuf, FILENAME_LEN);
    
    aEnvFile.Stream.Write(Auto,       SizeOf(Boolean));

    aEnvFile.SaveStream(CHASING_CONFIG);
  finally
    aEnvFile.Free;
  end;
end;

//-----------------------< get/set >----------------------------//

function TSignalTargets.GetTarget(i:Integer) : TSignalTargetItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSignalTargetItem
  else
    Result := nil;
end;

function TSignalTargets.GetChasingItem(i:Integer) : TChasingItem;
begin
  if (i>=0) and (i<=FChasingItems.Count-1) then
    Result := FChasingItems.Items[i] as TChasingItem
  else
    Result := nil;
end;

function TSignalTargets.GetChasingItemCount : Integer;
begin
  Result := FChasingItems.Count;
end;

end.


