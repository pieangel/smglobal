unit CleBHultAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFORMOrderItems,
  UObjectBase, UPaveConfig, UPriceItem,  CleQuoteTimers,
  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue,
  GleTypes, GleConsts, CleStrategyStore, CleVirtualHult;

type

  TBHultOrderEvent = procedure( dPrice : double; iSide : Integer; dDiv : char ) of object;

  TBHultOrderSlotItem = class( TCollectionItem )
  public
    index     : integer;
    OrderDiv  : array [TPositionType] of char ; // 1 : 일반  2 : 청산
    Price     : array [TPositionType] of double;
    PriceStr  : array [TPositionType] of string;
    IsOrder   : array [TPositionType] of boolean;

    Constructor Create( aColl : TCollection ); override;
  end;

  TBHultOrderSlots  = class( TCollection )
  private
    FBasePrice: double;
    FIsFirst: boolean;
//    FSide: integer;
    FDone: boolean;
    FBHultOrderEvent: TBHultOrderEvent;
    FLossCut: boolean;
    FMaxOrdCnt: integer;
    FOrdCount: integer;
    function GetOrderSlot(i: integer): TBHultOrderSlotItem;


  public
    Constructor Create;
    Destructor  Destroy; override;

    function New : TBHultOrderSlotItem;

    procedure Reset;
    procedure OnQuote( aQuote : TQuote );

    property HultOrderSlot[ i  :integer] : TBHultOrderSlotItem read GetOrderSlot; default;
    property BasePrice : double read FBasePrice write FBasePrice;
    property IsFirst   : boolean read FIsFirst write FIsFirst;

 //   property Side      : integer read FSide;
    property Done      : boolean read FDone;  // 모든 주문이 다 나가있는 상태;
    property LossCut   : boolean read FLossCut write FLossCut;

    property MaxOrdCnt : integer read FMaxOrdCnt write FMaxOrdCnt;// 최대 주문 수량( 건수로 체크..무한주문을 막기 위해 )
    property OrdCount  : integer read FOrdCount write FOrdCount;

    property BHultOrderEvent : TBHultOrderEvent read FBHultOrderEvent write FBHultOrderEvent;

  end;


  TBHultAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FBHultData: TBHultData;

    FReady : boolean;
    FLossCut : boolean;
    FLcTimer : TQuoteTimer;
    FOnPositionEvent: TObjectNotifyEvent;
    FRemSide, FRemNet, FRemQty : integer;
    FRetryCnt : integer;
    FLossCutCnt : integer;
    FTermCnt : integer;

    FMinPL, FMaxPL : double;
    FMinTime, FMaxTime : TDateTime;

    FStartIndex : integer;

    FLost : integer;
    FWin : integer;
    FRemainLost : integer;
    FSuccess : boolean;
    FScreenNumber : integer;
    FRun : boolean;
    FOrderSlots: TBHultOrderSlots;
    FOrderItem: TOrderItem;

    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure Reset;

    procedure DoInit(aQuote : TQuote);
    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote);

    procedure DoFill(aOrder : TOrder);

    procedure CheckActiveOrder(aOrder : TOrder; EventID: TDistributorID);
    procedure CancelLossCut(aOrder : TOrder);
    procedure ClearOrder;


    procedure DoLog; overload;
    procedure DoLog( stLog : string ); overload;
    procedure MakeOrderSlots;
    function NewOrderSlot(i: integer) : TBHultOrderSlotItem;
    procedure UpdateOrderSlots( bDec : boolean );
    function CheckLossCut(aQuote: TQuote): boolean;
    procedure OnBHultOrderEvent( dPrice : double; iSide : Integer; dDiv : char );
    procedure ReInit( dBasePrice : double );
    procedure DoReboot( bCnl : boolean = true );
    procedure Save;
  public

    SucCnt, FailCnt : integer;
    AMWrite : boolean;

    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol);
    function  Start : boolean;
    Procedure Stop( bCnl : boolean = true );
    procedure ApplyParam;
    procedure DoLiquid;

    property BHultData: TBHultData read FBHultData write FBHultData;

    property LossCutCnt : integer read FLossCutCnt write FLossCutCnt;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property Lost : integer read FLost;
    property Win : integer read FWin;
    property RemainLost : integer read FRemainLost;
    property OrderSlots : TBHultOrderSlots read FOrderSlots  ;

    property OrderItem : TOrderItem read FOrderItem write FOrderItem;
    
  end;

  var
    RebootType : char;
implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }


procedure TBHultAxis.CancelLossCut(aOrder: TOrder);
begin

end;

procedure TBHultAxis.CheckActiveOrder(aOrder: TOrder; EventID: TDistributorID);
var
  iIndex : integer;
  stLog : string;
begin
 { if (EventID = ORDER_ACCEPTED) then
  begin
    if (aOrder.OrderType = otNormal) and (aOrder.ClearOrder) and (aOrder.State = osActive) and ( aOrder.ActiveQty > 0 ) then
    begin
      if aOrder.Side > 0  then
        FBidOrders.Add(aOrder)
      else
        FAskOrders.Add(aOrder);
      stLog := Format('ActiveOrder A:%d B:%d, %d, %.1f, %d, %d', [FAskOrders.Count, FBidOrders.Count, aOrder.OrderNo, aOrder.Price, aOrder.Side, aOrder.ActiveQty]);
      gEnv.EnvLog(WIN_BHULT, stLog);
    end;
  end;
  iIndex := 0;
  while iIndex <= FBidOrders.Count -1 do
  begin
    aOrder := FBidOrders.Items[iIndex];
    if (aOrder.State <> osActive) then
      FBidOrders.Delete(iIndex)
    else
      inc(iIndex);
  end;


  iIndex := 0;
  while iIndex <= FAskOrders.Count -1 do
  begin
    aOrder := FAskOrders.Items[iIndex];
    if (aOrder.State <> osActive) then
      FAskOrders.Delete(iIndex)
    else
      inc(iIndex);
  end;  }
end;

procedure TBHultAxis.ClearOrder;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  dPrice : double;
  stLog   : string;
  iLiqQty : integer;
  iSide : integer;
begin

  if Position = nil then exit;

  {if Position.Volume = 0 then exit;

  if Position.Volume > 0 then
    iSide := -1
  else
    iSide := 1;

  if iLiqQty > 0 then
  begin

    if iSide = 1 then
      dPrice := Symbol.LimitHigh
    else
      dPrice := Symbol.LimitLow;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrder(
                  gEnv.ConConfig.UserID, Account, Symbol,
                  iLiqQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.ClearOrder := true;
      if Symbol.Spec.Exchange = SANG_EX then
        aOrder.OffsetFlag := cofCloseToday
      else
        aOrder.OffsetFlag := cofClose;
      aOrder.OrderSpecies := opBHult;



      gEnv.Engine.TradeBroker.Send(aTicket);
      stLog := Format( 'Clear Order : %s, %s, %s, %d',
        [
          Symbol.Code,
          ifThenStr( iSide > 0 , 'L', 'S'),
          Symbol.PriceToStr( dPrice ),
          iLiqQty
        ]
        );

      gEnv.EnvLog(WIN_BHULT , stLog);
    end;
  end;     }
end;

constructor TBHultAxis.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stBHult);

  FScreenNumber := Number;

  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;

  FOrderSlots := TBHultOrderSlots.Create;

  Reset;
end;

destructor TBHultAxis.Destroy;
begin

  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);

  FOrderSlots.Free;

  inherited;
end;

procedure TBHultAxis.DoFill(aOrder: TOrder);
var
  stLog : string;
  aQuote : TQuote;
  aFill : TFill;
  iOrdQty : integer;
begin

  if aOrder.State = osFilled then
    case aOrder.OrderTag of
      300 :
        begin
          inc(SucCnt);
          DoLog( Format( '%d 번째 이익 -> 간격 : %d,  잔고 : %d ', [ SucCnt,
            FBHultData.OrdGap, FBHultData.ClearPos ]));
          ReInit( aOrder.Price );
        end;
      -300 :
        begin
          inc(FailCnt);
          DoLog( Format( '%d 번째 손절 -> 간격 : %d,  잔고 : %d ', [ FailCnt,
            FBHultData.OrdGap, FBHultData.ClearPos ]));
          ReInit( FOrderSlots.BasePrice );

        end;
      -100 :
        begin
          // 임의로 청산시킨것이기 때문에 기준가를 현재가로 한다.
      //    inc(FailCnt);
          DoLog( Format( '임의청산  -> 간격 : %d,  잔고 : %d ', [
            FBHultData.OrdGap, FBHultData.ClearPos ]));
          ReInit( FSymbol.Last );

        end;
    end;
end;

procedure TBHultAxis.ReInit( dBasePrice : double );
begin
  FReady := false;
  FOrderSlots.Reset;
  FOrderSlots.BasePrice := dBasePrice;
end;

procedure TBHultAxis.DoInit(aQuote: TQuote);
var
  i, iIndex, idx: integer;

  stTime, stLog : string;
  iSide, iQty : integer;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) or
     (aQuote.Last < PRICE_EPSILON) then
  begin
    Exit;
  end;

  MakeOrderSlots;

  FReady  := true;
end;



procedure TBHultAxis.DoLiquid;
begin
  if not IsRun then Exit;
  RebootType := '3';
  DoReboot;
end;

procedure TBHultAxis.DoLog(stLog: string);
begin
  if Account <> nil then
    gEnv.EnvLog( WIN_BHULT, stLog, false, Account.Code);
end;

procedure TBHultAxis.DoLog;
var
  stLog, stFile : string;
begin
  //날짜, Gap, 순손익, 최대손익, 최대손실, 최대잔고
  {
  stLog := Format('%s, %d, %.0f, %s, %.0f, %s, %.0f, %d, %d, %d',
                  [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap,
                    Position.EntryPLSum - Position.GetFee, FormatDateTime('hh:mm:ss', FMaxTime),  FMaxPL,
                    FormatDateTime('hh:mm:ss', FMinTime), FMinPL, Position.MaxPos, FLost, FRemainLost]);
   }
//날짜, Gap, 순손익, 최대손익, 최대손실, 최대잔고

  if Position = nil then
  begin
    stLog := Format('%s, %d, 0, 0, 0, 0',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap] );
  end else
  begin
    stLog := Format('%s, %d, %.0f, %.0f, %.0f, %d',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FBHultData.OrdGap,
                      (Position.LastPL - Position.GetFee)/1000, FMaxPL/1000, FMinPL/1000, Position.MaxPos] );
  end;
  stFile := Format('BanHultJustOnce_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_BHULT, stLog, true, stFile);
end;


procedure TBHultAxis.ApplyParam;
begin
  FReady := false;
  //MakeOrderSlots;
end;


procedure TBHultAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  inherited;
  FSymbol := aSymbol;
  FAccount := aAcnt;
  Account := aAcnt;

  Reset;
end;

function TBHultAxis.IsRun: boolean;
begin
  if ( not FRun ) or ( FSymbol = nil ) or ( FAccount = nil ) then
    Result := false
  else
    Result := true;
end;

procedure TBHultAxis.OnBHultOrderEvent(dPrice: double; iSide: Integer;
  dDiv: char);
  var
    aTicket : TOrderTicket;
    aOrder  : TOrder;
    iQty, iTag    : integer;
    aPos    : TPosition;
begin

  iTag  := 0;


    // 청산주문 플래그..전량 체결 판단을 위해
    case dDiv of
      '0','3' :
        begin

          aPos  := gEnv.Engine.TradeCore.Positions.Find( FAccount, FSymbol );
          if aPos = nil then
          begin
            DoLog( Format(' 엇 !! 청산 주문을 낼려고 하는데 포지션이 없다  %s, %s', [
              FSymbol.ShortCode, FAccount.Code ]));
            Exit;
          end;
          iQty  := abs( Position.Volume );
          if dDiv = '0' then
          begin
            iTag  := -300;
          end else
          if dDiv = '3' then
          begin
            iTag  := -100;
          end;
        end;
      '2' :
        begin
          iTag  := 300;
          iQty  := FBHultData.ClearPos  * FBHultData.OrdQty;
        end;
      else
        iQty  := FBHultData.OrdQty;
    end;



  if ( dPrice < PRICE_EPSILON ) or ( iQty <= 0 ) then
  begin
    DoLog( Format(' 엇 !! %s 주문 인자 이상  %.2f, %d', [
      ifThenStr( iSide > 0 , '매수','매도'),  dPrice, iQty  ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self, Number, stBHult);
  //aTicket := gEnv.Engine.TradeCore.OrderTickets.New(self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, FSymbol,
  iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opBHult;
    aOrder.OrderTag := iTag;
    gEnv.Engine.TradeBroker.Send(aTicket);
    DoLog( Format('Send Order(%s) : %s, %s, %s, %.2f, %d', [ dDiv, FAccount.Code, FSymbol.ShortCode,
      ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty ]));
  end;

end;

procedure TBHultAxis.OnLcTimer(Sender: TObject);
begin
end;

procedure TBHultAxis.Save;
var
  dPL : double;
  dtTime : TDateTime;
begin

  if FAccount = nil then
    Exit;

  dPL := gEnv.Engine.TradeCore.Positions.GetPL( Account ) / 1000;

  if Account.MaxPL < dPL then
  begin
    Account.MaxPL   := dPL;
    Account.MaxTime := GetQuoteTime;
  end;

  if Account.MinPL > dPL then
  begin
    Account.MinPL := dPL;
    Account.MinTime := GetQuoteTime;
  end;

  Account.Data1 := SucCnt;
  Account.Data2 := FailCnt;

  Account.PL  := dPL;
  Account.IsLog := true;

  dtTime  := EncodeTime(11,30, 0, 0);

  if (Frac( GetQuoteTime ) > dtTime) and ( not AMWrite ) then
  begin
    Account.PL2   := Account.PL;
    Account.Data3 := Account.MaxPL;
    Account.Data4 := Account.MinPL;
    Account.MaxTime2  := Account.MaxTime;
    Account.MinTime2  := Account.MinTime;
    Account.Data5 := Account.Data1;
    Account.Data6 := Account.Data2;
    AMWrite := true;
  end;
end;

procedure TBHultAxis.QuoteProc(aQuote: TQuote; iDataID: integer);
begin
  if iDataID = 300 then
  begin
    //DoLog;
    exit;
  end;

  Save;

  if not IsRun then Exit;

  if ( FSymbol <> aQuote.Symbol ) then Exit;

  if Assigned(OnResult) then
    OnResult(nil, false);

  if not FReady then
    DoInit( aQuote )
  else
    UpdateQuote( aQuote );

end;

procedure TBHultAxis.Reset;
begin
  FRun := false;
  FReady  := false;
  FLossCut:= false;

  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;

  FLossCutCnt := 0;
  FLost := 0;
  FWin := 0;
  FRemainLost := 0;
  FSuccess := false;
  FTermCnt := 0;

  SucCnt  := 0;
  FailCnt := 0;
  AMWrite := false;

  FOrderSlots.Reset;
  FOrderItem  := nil;

  RebootType := '0';

  FOrderSlots.BHultOrderEvent := OnBHultOrderEvent;
end;

function TBHultAxis.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;

  FRun := true;
  AddPosition(FSymbol);

  gEnv.EnvLog(WIN_BHULT, Format('BHult Start %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
end;

procedure TBHultAxis.Stop( bCnl : boolean = true );
begin
  FRun := false;
  gEnv.EnvLog(WIN_BHULT, Format('BHult Stop %s, %d', [FSymbol.Code, FBHultData.OrdGap]) );
  // 손절 넣자....
  RebootType := '0';
  DoReboot( bCnl );
end;


procedure TBHultAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin
  if not IsRun then Exit;
  if aOrder.OrderSpecies <> opBHult then exit;
  if iID in [ORDER_FILLED] then
    DoFill( aOrder );
end;


function TBHultAxis.CheckLossCut( aQuote : TQuote ) : boolean;
var
  iRes : integer;
begin
  Result := false;

  if Position.Volume = 0 then Exit;

  if ( aQuote.Bids[0].Price < PRICE_EPSILON )  or ( aQuote.Asks[0].Price < PRICE_EPSILON ) then
    Exit;
  
  // 매수로..나가있을때
  if Position.Volume > 0 then
  begin
    iRes  := ComparePrice( FSymbol.Spec.Precision, FOrderSlots.BasePrice, aQuote.Bids[0].Price );
    if iRes > 0 then
      Result := true;
  end
  // 매도로 나가 있을때..
  else if Position.Volume < 0 then
  begin
    iRes  := ComparePrice( FSymbol.Spec.Precision, aQuote.Asks[0].Price, FOrderSlots.BasePrice );
    if iRes > 0 then
      Result := true;
  end;
end;

procedure TBHultAxis.DoReboot( bCnl : boolean );
var
  iSide, iQty : integer;
  dPrice: double;
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin

  if bCnl then
  begin
    if Position.Volume > 0  then
    begin
      iSide := -1;
      dPrice  := TicksFromPrice( FSymbol, FSymbol.Last, 5 * iSide );
    end
    else begin
      iSide := 1;
      dPrice := TicksFromPrice( FSymbol, FSymbol.Last, 5 * iSide );
    end;

    OnBHultOrderEvent(dPrice, iSide, RebootType );
  end;

  if FOrderItem = nil then
    FOrderItem := gEnv.Engine.FormManager.OrderItems.Find( FAccount, FSymbol);

  if FOrderItem <> nil then
    gEnv.Engine.FormManager.DoCancels( FOrderItem, 0 );

end;


procedure TBHultAxis.UpdateQuote(aQuote: TQuote);
var
  stTime, stTime1 : string;
  stLog : string;
  dPL : double;
begin

  if Position <> nil then
  begin
    FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
    FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );
  end;

  stTime := FormatDateTime('hh:mm:ss.zzz', FBHultData.LiquidTime);
  stTime1 := FormatDateTime('hh:mm:ss.zzz', GetQuoteTime);

  if (FBHultData.UseAutoLiquid) and (Frac(FBHultData.LiquidTime) <= Frac(GetQuoteTime)) then
  begin
    Stop;
    stLog := Format('청산시간 %s <= %s', [stTime, stTime1]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;

  if (FBHultData.UseAllcnlNStop) and ((Position.LastPL - Position.GetFee) <= FBHultData.RiskAmt * -10000) then
  begin
    Stop;
    stLog := Format('일일한도 오버 %.0f', [Position.LastPL - Position.GetFee]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;

  if (FBHultData.UseAllcnlNStop) and (Position.LastPL - Position.GetFee >= FBHultData.ProfitAmt * 10000) then
  begin
    Stop;
    stLog := Format('일일이익 청산 %.0f', [Position.LastPL - Position.GetFee]);
    gEnv.EnvLog(WIN_BHULT, stLog);
    exit;
  end;

  // 손절 됨..리부트 될때까지.대기
  if FOrderSlots.LossCut then Exit;

  if CheckLossCut( aQuote ) then
  begin
    RebootType := '0';
    DoReboot;
    FOrderSlots.LossCut := true;
    Exit;
  end;

  FOrderSlots.OnQuote( aQuote );
end;


procedure TBHultAxis.MakeOrderSlots;
var
  iCnt ,i, iTmp, j: Integer;
  aSlot : TBHultOrderSlotItem;
begin
  if FSymbol = nil  then Exit;

  // 잔고 개수 + 청산주문
  iCnt  := FBHultData.ClearPos + 1;
  iTmp  := FOrderSlots.Count;
  if FOrderSlots.Count > iCnt  then
  begin
    J := 0;
    // 청산슬롯은 빼면 안되기에
    for I := FOrderSlots.Count - 2 downto iCnt -1 do
    begin
      FOrderSlots[i].Free;
      inc( J );
    end;
    // 지워진 만큼..청산 라인을 조정해준다.
    if J > 0 then
      UpdateOrderSlots( true );

  end else
  if FOrderSlots.Count < iCnt then
  begin

    if (FOrderSlots.Count = 0) and ( FOrderSlots.IsFirst ) then
    begin
      FOrderSlots.BasePrice := FSymbol.Last;
      FOrderSlots.IsFirst   := false;
    end;

    for I := FOrderSlots.Count to iCnt - 1 do
    begin
      aSlot := NewOrderSlot( i );
    end;

    UpdateOrderSlots( false );
  end;


  DoLog( Format(' Make Order Slot : %d -> %d (Pos :%d ) MaxOrdCnt : %d ',
    [ iTmp , FOrderSlots.Count, FBHultData.ClearPos, FOrderSlots.MaxOrdCnt ]));

  // debug //
  for I := 0 to FOrderSlots.Count - 1 do
  begin
    aSlot := FOrderSlots.HultOrderSlot[i];
    DoLog( Format('%d %.2f [%s | %s ] [ %s | %s ]', [ i, FOrderSlots.BasePrice,
      aSlot.PriceStr[ptLong], aSlot.PriceStr[ptShort],
      ifThenStr( aSlot.OrderDiv[ptLong]  = '1', '일반','청산'),
      ifThenStr( aSlot.OrderDiv[ptShort] = '1', '일반','청산') ]));

  end;

end;

function TBHultAxis.NewOrderSlot(i : integer)  : TBHultOrderSlotItem;
begin

  Result := FOrderSlots.Insert(i) as TBHultOrderSlotItem;
  Result.index := i;

  Result.Price[ptLong]  := TicksFromPrice( FSymbol, FOrderSlots.BasePrice, FBHultData.OrdGap * (i+1) );
  Result.Price[ptShort] := TicksFromPrice( FSymbol, FOrderSlots.BasePrice, -FBHultData.OrdGap* (i+1) );

  Result.PriceStr[ptLong] := Format( '%.*n', [ FSymbol.Spec.Precision, Result.Price[ptLong] ] );
  Result.PriceStr[ptShort] := Format( '%.*n', [ FSymbol.Spec.Precision, Result.Price[ptShort] ] );

  Result.IsOrder[ptlong]  := false;
  Result.IsOrder[ptShort]  := false;

  Result.OrderDiv[ptLong]  := '2';
  Result.OrderDiv[ptShort] := '2';

end;

procedure TBHultAxis.UpdateOrderSlots(bDec: boolean);
var
  aSlot : TBHultOrderSlotItem;
  i : integer;
begin

  if bDec then
  begin
    // 개수가 줄어들었음..청산 가격만 변경.
    aSlot := FOrderSlots.HultOrderSlot[ FOrderSlots.Count - 1 ];

    if aSlot <> nil then
    begin
      if aSlot.OrderDiv[ptLong] = '2' then
      begin
        aSlot.Price[ptLong]  := TicksFromPrice( FSymbol, FOrderSlots.BasePrice, FBHultData.OrdGap * ( FBHultData.ClearPos +1) );
        aSlot.PriceStr[ptLong] := Format( '%.*n', [ FSymbol.Spec.Precision, aSlot.Price[ptLong] ] );
      end;
      if aSlot.OrderDiv[ptShort] = '2' then
      begin
        aSlot.Price[ptShort] := TicksFromPrice( FSymbol, FOrderSlots.BasePrice, -FBHultData.OrdGap* ( FBHultData.ClearPos +1) );
        aSlot.PriceStr[ptShort] := Format( '%.*n', [ FSymbol.Spec.Precision, aSlot.Price[ptShort] ] );
      end;
    end;
  end
  else begin

    for I := 0 to FOrderSlots.Count - 1 do
    begin
      aSlot := FOrderSlots.HultOrderSlot[ i ];

      if i <> ( FOrderSlots.Count -1 ) then
      begin
        aSlot.OrderDiv[ptLong]  := '1';
        aSlot.OrderDiv[ptShort] := '1';
      end;
    end;
  end;

  FOrderSlots.MaxOrdCnt := FOrderSlots.Count;
end;



{ TBHultOrderSlotItem }

constructor TBHultOrderSlotItem.Create(aColl: TCollection);
begin
  inherited;

end;

{ TBHultOrderSlots }

constructor TBHultOrderSlots.Create;
begin
  inherited Create( TBHultOrderSlotItem );
  FIsFirst  := true;
end;

destructor TBHultOrderSlots.Destroy;
begin

  inherited;
end;


function TBHultOrderSlots.GetOrderSlot(i: integer): TBHultOrderSlotItem;
begin
  if ( i< 0 ) or ( i>=Count ) then
    Result := nil
  else
    Result := Items[i] as  TBHultOrderSlotItem;
end;


function TBHultOrderSlots.New: TBHultOrderSlotItem;
begin
  Result := Add as TBHultOrderSlotItem;
end;

procedure TBHultOrderSlots.OnQuote( aQuote: TQuote);
var
  I, iSide, iRes : Integer;
  aSlot : TBHultOrderSlotItem;
  bLiq  : boolean;
  dLast : double;
  aType : TPositionType;
  cmpPrice : double;
begin

  if FDone then Exit;

  dLast := aQuote.Symbol.Last;

  if (FBasePrice < PRICE_EPSILON) or ( dLast < PRICE_EPSILON ) then
  begin
    gEnv.EnvLog( WIN_BHULT, 'No Setting Basee price');
    Exit;
  end;

  iSide := 0;

  //if FSide = 0 then
  //begin
    iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aQuote.Bids[0].Price , FBasePrice );
    if iRes > 0 then
      iSide := 1
    else begin
      iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, FBasePrice, aQuote.Asks[0].Price );
      if iRes > 0 then
        iSide := -1;
    end;
  //end
  //else iSide := FSide;

  if iSide = 0 then Exit;

  if iSide > 0 then
    aType := ptLong
  else
    aType := ptShort;

  for I := 0 to Count - 1 do
  begin
    aSlot := GetOrderSlot( i );
    if aSlot.IsOrder[aType] then  continue;      

    // 청산 주문
    if aSlot.OrderDiv[aType] = '2' then
    begin
      // 가격, 방향, 수량은 잔고만큼
      //aSlot.Price, -1 , '2'
      FDone  := true;
      if (Assigned( FBHultOrderEvent )) and ( FOrdCount < FMaxOrdCnt )  then
      begin
        RebootType := aSlot.OrderDiv[aType];
        FBHultOrderEvent( aSlot.Price[aType], -iSide, aSlot.OrderDiv[aType] );
        inc( FOrdCount );
        gEnv.EnvLog( WIN_BHULT, Format( '%d 번째 %s 주문 대놓는다  : %.2f -> %.2f (%d | %d ) ',  [
            aSlot.index, ifThenStr( iSide > 0, '매수','매도'), FBasePrice, aSlot.Price[aType],
            FOrdCount, FMaxOrdCnt
            ])  );
      end;
    end
    // 치는 주문
    else begin

      if iSide > 0 then
        iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aQuote.Asks[0].Price, aSlot.Price[aType] )
      else
        iRes  := ComparePrice( aQuote.Symbol.Spec.Precision, aSlot.Price[aType], aQuote.Bids[0].Price );

      if iRes >= 0 then
      begin
        //aQuote.Asks[3].Price, 1, '1'
        if (Assigned( FBHultOrderEvent )) and ( FOrdCount < FMaxOrdCnt ) then
        begin
          RebootType := aSlot.OrderDiv[aType];
          if iSide > 0  then
            FBHultOrderEvent( aQuote.Asks[3].Price, iSide, aSlot.OrderDiv[aType] )
          else
            FBHultOrderEvent( aQuote.Bids[3].Price, iSide, aSlot.OrderDiv[aType] );

          //FBHultOrderEvent( aSlot.Price[aType], iSide, aSlot.OrderDiv[aType] );
          aSlot.IsOrder[aType]  := true;
          inc( FOrdCount );

          gEnv.EnvLog( WIN_BHULT, Format( '%d 번째 %s 주문 : %.2f -> %.2f,  (%d | %d )',  [
            aSlot.index, ifThenStr( iSide > 0, '매수','매도'), FBasePrice, dLast,
            FOrdCount, FMaxOrdCnt
            ])  );
          break;
        end;
        // 주문
      end
      else begin
        break;
      end;

    end;
  end;
end;

procedure TBHultOrderSlots.Reset;
begin
  Clear;
  FBasePrice  := 0;
  //FSide       := 0;
  FDone       := false;
  FLossCut    := false;
  FMaxOrdCnt  := 0;
  FOrdCount   := 0;
end;

end.
