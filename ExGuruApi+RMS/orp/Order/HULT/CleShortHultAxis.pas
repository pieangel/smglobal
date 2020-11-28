unit CleShortHultAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,
  UObjectBase, UPaveConfig, UPriceItem,  CleQuoteTimers,
  CleDistributor, CleQuoteBroker, CleKrxSymbols,
  GleTypes, GleConsts, CleStrategyStore;

type
  TShortHultPrice = class(TCollectionItem)
  public
    Price : double;
    Base : boolean;
    LossCut : boolean;
    Index : integer;
    SendOrder : boolean;
    function GetString : string;
  end;

  TShortHultPrices = class(TCollection)
  private
    FBasePrice : TShortHultPrice;
  public
    constructor Create;
    destructor Destroy; override;
    function New(dPrice : double; bBase : boolean) : TShortHultPrice;
    function Find( dPrice : double; iPer : integer ) : TShortHultPrice;
    function GetItem(iIndex : integer) : TShortHultPrice;
    function FindLastOrder( iSide : integer ) : TShortHultPrice ;
    property BasePrice : TShortHultPrice read FBasePrice write FBasePrice;
  end;

  TCnlOrder = class( TCollectionItem )
  public
    Order : TOrder;
    Price : TShortHultPrice;
  end;

  TCnlOrders  = class( TCollection )
  public
    constructor Create;
    procedure New( aOrder : TOrder; aItem : TShortHultPrice );
    function Find( aOrder : TORder; var idx : integer ) : TCnlOrder;
  end;

  TShortHultAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FData: TShortHultData;
    FReady : boolean;
    FLossCut : boolean;
    FClear : boolean;
    FLcTimer : TQuoteTimer;
    FOnPositionEvent: TObjectNotifyEvent;
    FRemSide, FRemNet, FRemQty : integer;
    FRetryCnt : integer;
    FMinPL, FMaxPL : double;
    FScreenNumber : integer;
    FRun : boolean;
    FShortHultPrices : TShortHultPrices;
    FOrders: TOrderItem;
    FMinTime, FMaxTime : TDateTime;
    FSendOrders : TList;
    FCnlOrders  : TCnlOrders;
    FFirst : boolean;

    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;
    function DoOrder( iQty, iSide, iOrderTag : integer; aItem : TShortHultPrice;
      bHit  : boolean = false) : TOrder; overload;           // OrderTag : 0 : 기분점, 1 : 쿼팅주문,  2 : 손절주문
    procedure Reset;
    procedure DoInit(aQuote : TQuote);
    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote);
    procedure DoFill(aOrder : TOrder);
    procedure PutOrder( aItem : TShortHultPrice; aOrder : TOrder );
    procedure DoLossCut(aQuote : TQuote);

    procedure DoLog;
    function BHULTLossCut( iSide: integer): integer;
    function GetNowQty: integer;
    procedure DoCancel( iSide : integer; aItem: TShortHultPrice);   overload;
    procedure DoCancel( aOrder : TOrder ) ; overload;
    procedure CheckOutOrder;

  public
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol);
    function Start : boolean;
    Procedure Stop(bAuto : boolean = true);
    property Data: TShortHultData read FData write FData;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property ShortHultPrices : TShortHultPrices read FShortHultPrices;

    property MaxPL : double read FMaxPL;
    property MinPL : double read FMinPL;
    property Run : boolean read FRun;

  end;
implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }
constructor TShortHultAxis.Create(aColl: TCollection; opType: TOrderSpecies);
begin
  inherited Create(aColl, opType, stShortHult);
  FScreenNumber := Number;
  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 5000 * 4;
  FLcTimer.OnTimer := OnLcTimer;
  FShortHultPrices := TShortHultPrices.Create;
  FSendOrders := TList.Create;
  FCnlOrders  := TCnlOrders.Create;
  FFirst := true;

  Reset;
end;

destructor TShortHultAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  FShortHultPrices.Free;
  FSendOrders.Free;
  FCnlOrders.Free;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  inherited;
end;


procedure TShortHultAxis.DoCancel( iSide : integer; aItem : TShortHultPrice );
var
  I: Integer;
  aOrder : TOrder;
  aTicket: TOrderTicket;
begin
  for I := 0 to FSendOrders.Count - 1 do
  begin
    aOrder  := TOrder( FSendOrders.Items[I]);
    if ( aOrder.Side = iSide ) and ( aOrder.OrderType = otNormal ) and
       ( ComparePrice( aOrder.Symbol.Spec.Precision, aOrder.Price, aItem.Price ) = 0 ) then
    begin

      if ( aOrder.State = osActive ) and ( aOrder.ActiveQty > 0 ) then
      begin
        aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
        if gEnv.Engine.TradeCore.Orders.NewCancelOrderEx( aOrder, aOrder.ActiveQty, aTicket ) <> nil then
        begin
          gEnv.Engine.TradeBroker.Send(aTicket);
          gEnv.EnvLog(WIN_SHORTHULT, Format('DoCanel : %s, %.2f, %d, %d', [
          ifThenStr( iSide > 0 ,'매수', '매도'), aOrder.Price, aOrder.ActiveQty, aOrder.OrderNo ]) );
          aItem.SendOrder := false;
          FSendOrders.Delete(i);
          break;
        end;
      end else
      if ( aOrder.State in [ osReady, osSent, osSrvAcpt ] ) then
      begin
        gEnv.EnvLog( WIN_SHORTHULT, Format('Save Cnl Order :%s, %.2f, %d, %d', [
        ifThenStr( iSide > 0 ,'매수', '매도'), aOrder.Price, aOrder.ActiveQty, aOrder.OrderNo ]) );
        FCnlOrders.New( aOrder, aItem );
        FSendOrders.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure TShortHultAxis.DoCancel(aOrder: TOrder);
var
  I: Integer;
  pOrder : TCnlOrder;
  aTicket: TOrderTicket;
begin

  i := -1;
  pOrder  := FCnlOrders.Find( aOrder, i );

  if pOrder <> nil then
    if aOrder.ActiveQty > 0  then
    begin
      aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
      if gEnv.Engine.TradeCore.Orders.NewCancelOrderEx( aOrder, aOrder.ActiveQty, aTicket ) <> nil then
      begin
        gEnv.Engine.TradeBroker.Send(aTicket);

        pOrder.Price.SendOrder := false;
        FCnlOrders.Delete(i);

        gEnv.EnvLog(WIN_SHORTHULT, Format('DoCanel 2(%d) : %s, %.2f, %d, %d', [  FCnlOrders.Count,
            ifThenStr( aOrder.Side > 0 ,'매수', '매도'), aOrder.Price, aOrder.ActiveQty, aOrder.OrderNo ]) );
      end;
    end;   
end;

procedure TShortHultAxis.DoFill(aOrder: TOrder);
var
  aItem, tItem : TShortHultPrice;
  i, iSide, iQty, iCnt, iIndex, iSend : integer;
  stLog : string;
  //aFill : TFill;
begin
  if not IsRun then Exit;
  // 0 : 기준점 체결, 1 : 쿼팅 체결,  2 : 손절
  if aOrder.OrderTag = 0 then
  begin
    //반대 방향으로 다시 주문 쿼팅,
    //FOrders의 매도매수 미체결수량 카운팅해서 부족한 만큰 기준점 근처 넘으로 채워주자

    //aFill := TFill( aOrder.Fills.Items[ aOrder.Fills.Count-1] );
    //if aFill = nil then Exit;

    iSide := aOrder.Side * -1;
    iSend := 0;
    if aOrder.Side > 0 then   //매도 쿼팅
    begin
      // 기준점 에서부터 찾는다.

      aItem := FShortHultPrices.FindLastOrder( iSide );
      if (aItem = nil) and ( abs( Position.Volume ) > 0 ) then
        // 풀로 잡힌 상황인것이다..
        tItem := FShortHultPrices.GetItem( 1 )
      else begin
        tItem := FShortHultPrices.GetItem( aItem.Index + 1 );
        DoCancel( iSide, aItem );
      end;

      if tItem <> nil then
        if ( not tItem.Base ) and ( not tItem.LossCut ) and  (not tItem.SendOrder) and
           ( tItem.Index < FShortHultPrices.BasePrice.Index ) then
        begin
          stLog := Format('Base Fill 매도 깔기 %.2f', [ tItem.Price]);
          gEnv.EnvLog(WIN_SHORTHULT, stLog);
          DoOrder(FData.OrdQty, iSide, 1, tItem);
        end else
        begin
          gEnv.EnvLog(WIN_SHORTHULT, 'Base Fill 안깔림 : ' + tItem.GetString);
        end;   
    end else                  //매수 쿼팅
    begin
      aItem := FShortHultPrices.FindLastOrder( iSide );
      if (aItem = nil) and ( abs( Position.Volume ) > 0 ) then
        // 풀로 잡힌 상황인것이다..
        tItem := FShortHultPrices.GetItem( FShortHultPrices.Count-2 )
      else begin
        tItem := FShortHultPrices.GetItem( aItem.Index - 1 );
        DoCancel( iSide, aItem );
      end;

      if tItem <> nil then
        if ( not tItem.Base ) and ( not tItem.LossCut ) and  (not tItem.SendOrder) and
           ( tItem.Index > FShortHultPrices.BasePrice.Index ) then
        begin
          stLog := Format('Base Fill 매수 깔기 %.2f', [ tItem.Price]);
          gEnv.EnvLog(WIN_SHORTHULT, stLog);
          DoOrder(FData.OrdQty, iSide, 1, tItem);
        end else
        begin
          gEnv.EnvLog(WIN_SHORTHULT, 'Base Fill 안깔림 : ' + tItem.GetString);
        end;
    end;

  end else if aOrder.OrderTag = 1 then
  begin
    //SendOrder false
    aItem := FShortHultPrices.Find(aOrder.Price, Fsymbol.Spec.Precision);
    if aItem <> nil then
    begin
      aItem.SendOrder := false;
    end else
    begin
      stLog := Format('Quoting Fill Find Failed %.2f', [aOrder.Price]);
      gEnv.EnvLog(WIN_SHORTHULT, stLog);
      exit;
    end;

    //기준점에 청산주문
    if not FLossCut then
    begin
      // 한칸 위 / 아래 주문 깔기
      PutOrder( aItem, aOrder );

      iSide := aOrder.Side * -1;
      iQty := abs(TFill( Position.Fills.Last ).Volume);
      stLog := Format('Quoting Fill %.2f, OrderQty = %d, OrderSide = %d, FillQty = %d', [aOrder.Price, aOrder.OrderQty, aOrder.Side, iQty]);
      gEnv.EnvLog(WIN_SHORTHULT, stLog);
      DoOrder(iQty, iSide, 0, FShortHultPrices.BasePrice);

    end else    // 쿼팅체결이 늦게 올경우
    begin
      iQty := abs(Position.Volume);
      if Position.Volume > 0 then
        iSide := -1
      else
        iSide := 1;

      if iQty <= 0 then
      begin
        FReady := false;
        FLossCut := false;
        stLog := Format('LossCuting  Pos = 0 Quoting Fill  %.2f, OrderQty = %d, OrderSide = %d, FillQty = %d', [aOrder.Price, aOrder.OrderQty, aOrder.Side, iQty]);
        gEnv.EnvLog(WIN_SHORTHULT, stLog);
      end else
      begin
        stLog := Format('LossCuting Quoting Fill %.2f, OrderQty = %d, OrderSide = %d, FillQty = %d', [aOrder.Price, aOrder.OrderQty, aOrder.Side, iQty]);
        gEnv.EnvLog(WIN_SHORTHULT, stLog);
        DoOrder(iQty, iSide, 2, nil, true);
      end;
    end;

  end else if aOrder.OrderTag = 2 then
  begin
    if Position.Volume = 0 then
    begin
      FReady := false;
      FLossCut := false;
    end;
  end;
end;

procedure TShortHultAxis.DoInit(aQuote: TQuote);
var
  i : integer;
  stTmp, stTmp1, stLog : string;
  iSide, iCnt, iIndex : integer;
  dPrice, dBasePrice : double;
  aItem, aBid, aAsk : TShortHultPrice;
  aOrder : TOrder;
  dUpStart, dDownStart : double;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;
  if aQuote.FTicks.Count <= 0  then exit;


  if FFirst then
  begin
    if FData.SPoint > 0 then
    begin
      dUpStart := aQuote.Symbol.DayOpen + FData.SPoint;
      dDownStart := aQuote.Symbol.DayOpen - FData.SPoint;

      if (aQuote.Last >= dUpStart) or (aQuote.Last <= dDownStart) then
        gEnv.EnvLog(WIN_SHORTHULT, Format('DoInit SPoint Open = %.2f, Last = %.2f, Up = %.2f, Down = %.2f',
                     [aQuote.Symbol.DayOpen, aQuote.Last, dUpstart, dDownStart]))
      else
        exit;
    end;
    FFirst := false;
  end;

  for i := 0 to FSendOrders.Count - 1 do
  begin
    aOrder := FSendOrders.Items[i];
    stLog := Format('SendOrders %s, %d, %d', [aOrder.StateDesc, aOrder.OrderNo, FSendOrders.Count]);
    gEnv.EnvLog(WIN_SHORTHULT, stLog );

    if aOrder.State in [osReady, osSent, osSrvAcpt] then
    begin
      exit;
    end;
  end;

  if (FOrders.AskOrders.Count > 0) or (FOrders.BidOrders.Count > 0) then
    gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );
  FShortHultPrices.Clear;
  FSendOrders.Clear;
  FCnlOrders.Clear;

  //매도 주문.....
  dBasePrice := aQuote.Last;
  iCnt := FData.ClearPos + 1;
  //매도
  dPrice := dBasePrice;
  for i := iCnt downto 1 do
  begin
    dPrice := TicksFromPrice( FSymbol, dBasePrice , FData.OrdGap * i );
    aItem := FShortHultPrices.New(dPrice, false);
    if i = iCnt then
      aItem.LossCut := true;
  end;
  //기준점
  FShortHultPrices.BasePrice := FShortHultPrices.New(dBasePrice, true);
  //매수
  dPrice := dBasePrice;
  for i := 1 to iCnt do
  begin
    dPrice := TicksFromPrice( FSymbol, dBasePrice , FData.OrdGap * i * -1 );
    aItem := FShortHultPrices.New(dPrice, false);
    if i = iCnt then
      aItem.LossCut := true;
  end;

  if FShortHultPrices.Count = iCnt * 2 + 1 then
  begin
    for i := 1 to FData.ClearPos do
    begin
      iIndex := FShortHultPrices.BasePrice.Index;

      aBid := FShortHultPrices.GetItem(iIndex + i);
      aAsk := FShortHultPrices.GetItem(iIndex - i);

      if (aBid <> nil) and (aAsk <> nil) then
      begin
        if i= 1 then
        begin
          DoOrder(FData.OrdQty, 1, 1, aBid);
          DoOrder(FData.OrdQty, -1, 1, aAsk);
        end;
      end;
    end;
    FReady := true;
    gEnv.EnvLog(WIN_SHORTHULT, Format('DoInit %d', [ FShortHultPrices.Count ]) ) ;
  end else
    gEnv.EnvLog(WIN_SHORTHULT, Format('DoInit Failed, %d = %d', [ iCnt *2 + 1 , FShortHultPrices.Count ]) ) ;

  for i := 0 to FShortHultPrices.Count - 1 do
  begin
    aItem := FShortHultPrices.Items[i] as TShortHultPrice;
    if aItem.Base then
      stTmp := 'Base'
    else
      stTmp := 'not Base';
    if aItem.LossCut then
      stTmp1 := 'LossCnt'
    else
      stTmp1 := 'not LossCut';
    aItem.Index := i;
    gEnv.EnvLog(WIN_SHORTHULT, Format('[%s] [%s] : %.2f, %.2f ( %d | %d )',
       [ stTmp, stTmp1, aItem.Price, aQuote.Last , aItem.Index, i ]) ) ;
  end;

end;

procedure TShortHultAxis.DoLog;
var
  stLog, stFile : string;
begin
  if Position = nil then
    stLog := Format('%s, %d, %d, %.0f, %s, %.0f, %s, %.0f, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime),
                                                         FData.OrdGap, FData.ClearPos, 0,
                                                         FormatDateTime('hh:nn:ss', FMaxTime), 0,
                                                         FormatDateTime('hh:nn:ss', FMinTime), 0, 0])
  else
    stLog := Format('%s, %d, %d, %.0f, %s, %.0f, %s, %.0f, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime),
                FData.OrdGap, FData.ClearPos, (Position.LastPL - Position.GetFee)/1000,
                FormatDateTime('hh:nn:ss', FMaxTime), MaxPL/1000,
                FormatDateTime('hh:nn:ss', FMinTime), MinPL/1000, Position.MaxPos]);

  stFile := Format('ShortHult_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_SHORTHULT, stLog, true, stFile);
end;

procedure TShortHultAxis.DoLossCut(aQuote: TQuote);
var
  i, iQty : integer;
  aItem : TShortHultPrice;
  stLog, stTmp : string;
begin
  if Position = nil then exit;
  if FLossCut then exit;          // 손절 진행중이면 ....빠지자..

  if abs(Position.Volume) >= FData.ClearPos then
  begin
    iQty := abs(Position.Volume);
    if Position.Volume > 0 then   //매수잔고 손절 => 매도
    begin
      aItem := FShortHultPrices.GetItem(FShortHultPrices.Count-1);
      if aItem = nil then exit;
      if ComparePrice(Fsymbol.Spec.Precision, aItem.Price, aQuote.Bids[0].Price) >= 0 then
      begin
        gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );
        stLog := Format('LossCut Bid(%.2f) <= Item(%.2f), %d', [aQuote.Bids[0].Price, aItem.Price, iQty]);
        gEnv.EnvLog(WIN_SHORTHULT, stLog);
        FLossCut := true;
        DoOrder(iQty, -1, 2, nil, true);
      end;
    end else                     //매도잔고 손절 => 매수
    begin
      aItem := FShortHultPrices.GetItem(0);
      if aItem = nil then exit;
      if ComparePrice(Fsymbol.Spec.Precision, aQuote.Asks[0].Price, aItem.Price) >= 0 then
      begin
        gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );
        stLog := Format('LossCut Ask(%.2f) >= Item(%.2f), %d', [aQuote.Asks[0].Price, aItem.Price, iQty]);
        gEnv.EnvLog(WIN_SHORTHULT, stLog);
        FLossCut := true;
        DoOrder(iQty, 1, 2, nil, true);
      end;
    end;
  end;
end;

function TShortHultAxis.DoOrder(iQty, iSide, iOrderTag: integer; aItem : TShortHultPrice; bHit : boolean): TOrder;
var
  aTicket : TOrderTicket;
  aQuote : TQuote;
  idx : integer;
  iMax, i : integer;
  iCnt : integer;
  aOrder : TOrder;
  tgType : TPositionType;
  dPrice : double;
begin
  if FSymbol = nil then exit;
  if iQty <= 0 then  Exit;

  if bHit then
  begin
    aQuote  := FSymbol.Quote as TQuote;
    if iSide > 0 then
      dPrice  := TicksFromPrice( FSymbol, aQuote.Asks[0].Price, 10 )
    else
      dPrice  := TicksFromPrice( FSymbol, aQuote.Bids[0].Price, -10 );
  end else
    dPrice := aItem.Price;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  Result := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, FSymbol,
    iQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if Result <> nil then                        // OrderTag : 0 : 기준점, 1 : 쿼팅주문,  2 : 손절주문
  begin
    Result.OrderSpecies := opShortHult;
    Result.OrderTag := iOrderTag;
    if iOrderTag = 1 then
      aItem.SendOrder := true;
    gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.EnvLog(WIN_SHORTHULT, Format('주문 : %s', [ Result.Represent2 ]) ) ;
    FSendOrders.Add(Result);
  end;
end;



function TShortHultAxis.GetNowQty: integer;
begin
  Result := 0;
  if Position = nil then Exit;
  Result := abs( Position.Volume ) + FOrders.AskOrders.Count + FOrders.BidOrders.Count ;
end;

function TShortHultAxis.BHULTLossCut(iSide: integer): integer;
var
  stLog : string;
  aTicket : TOrderTicket;
  aOrder : TOrder;
  aPrice : TPriceItem2;
  dPrice : double;
  iQty, i : integer;
  aPos : TPosition;
begin
  Result := 0;
  if Position = nil then exit;

  aPos := gEnv.Engine.TradeCore.Positions.Find(FAccount, FSymbol);
  if aPos <> nil then
  begin
    if aPos.Volume > 0 then
    begin
      iSide := -1;
      dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
    end else
    begin
      iSide := 1;
      dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
    end;

    iQty := abs(aPos.Volume);

    if iQty <= 0 then exit;
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
    iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := opShortHult;
      gEnv.Engine.TradeBroker.Send(aTicket);
      stLog := Format('ShortHult정리 %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_SHORTHULT, stLog);
    end;
  end;





  {

  if (FOrders.AskOrders.Count > 0) or (FOrders.BidOrders.Count > 0) then
    gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );

  for i := 0 to Positions.Count - 1 do
  begin
    aPos := Positions.Items[i] as TPosition;
    if aPos.Volume <> 0 then
    begin
      //손절.... 해주자
      if aPos.Volume > 0 then
      begin
        iSide := -1;
        dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
      end else
      begin
        iSide := 1;
        dPrice := TicksFromPrice( aPos.Symbol, aPos.Symbol.Last, 10 * iSide );
      end;

      iQty := abs(aPos.Volume);
      if iQty <= 0 then exit;
      aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
      aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
      iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

      if aOrder <> nil then
      begin
        aOrder.OrderSpecies := opShortHult;
        aOrder.OrderTag := 4;
        gEnv.Engine.TradeBroker.Send(aTicket);

        stLog := Format('ShortHult정리 %s',[aOrder.Represent2]);
        gEnv.EnvLog(WIN_SHORTHULT, stLog);
      end;
    end;
  end;   }
end;

procedure TShortHultAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  inherited;
  FOrders := gEnv.Engine.TradeCore.FrontOrders.New( aAcnt, aSymbol );
  FSymbol := aSymbol;
  FAccount := aAcnt;
  Account := aAcnt;
  Reset;
end;

function TShortHultAxis.IsRun: boolean;
begin
  if ( not FRun ) or ( FSymbol = nil ) or ( Account = nil ) then
    Result := false
  else
    Result := true;
end;


procedure TShortHultAxis.OnLcTimer(Sender: TObject);
begin
  BHULTLossCut(1);
end;

procedure TShortHultAxis.PutOrder( aItem : TShortHultPrice; aOrder : TOrder);
var
  iSide , iQty : integer;
  aFill : TFill;
  pItem : TShortHultPrice;

  function CheckPutPrice : boolean;
  var
    aQuote : TQuote;
  begin
    Result := false;

    aQuote  := aOrder.Symbol.Quote as TQuote;
    if aQuote = nil then
      Exit;

    if ((aOrder.Side > 0) and ( pItem.Price < aQuote.Bids[0].Price ))
      or
       ((aOrder.Side < 0) and ( pItem.Price > aQuote.Asks[0].Price )) then
      Result := true
    else begin
      gEnv.EnvLog( WIN_SHORTHULT, Format( 'CheckPutOrder Failed : pItem %.2f(%d)  Quote %.2f , %.2f, %.2f', [
        pItem.Price, pItem.Index, aQuote.Asks[0].Price, aQuote.Last, aQuote.Bids[0].Price ]));
    end;

  end;

begin

  if aOrder.Fills.Count <= 0 then
  begin
    gEnv.EnvLog( WIN_SHORTHULT, Format('TFill Count Error : %s, %s, %.2f, %d, %d',  [
      aOrder.Symbol.ShortCode, ifThenstr( aOrder.Side > 0,'매수','매도'),
      aOrder.Price, aOrder.OrderQty, aOrder.OrderNo
      ]));

    Exit;
  end
  else begin
    aFill := TFill( aOrder.Fills.Items[ aOrder.Fills.Count-1] );
    pItem := FShortHultPrices.GetItem( aItem.Index + aOrder.Side  );
    if pItem = nil then Exit;
    if ( pItem.SendOrder ) or ( pItem.LossCut ) then
    begin
      gEnv.EnvLog( WIN_SHORTHULT, Format('PutOrder Index Error : %s, %s, %.2f, %d, %d, (aItem : %.2f, %d, %s)',  [
      aOrder.Symbol.ShortCode, ifThenstr( aOrder.Side > 0,'매수','매도'),
      aOrder.Price, aOrder.OrderQty, aOrder.OrderNo,
      aItem.Price, aItem.Index , ifThenStr( pItem.LossCut, 'Last','--')
      ]));
      Exit;
    end;

    if CheckPutPrice then
      DoOrder(FData.OrdQty, aOrder.Side, 1, pItem);
  end;                                             

  //aItem.Index
end;

procedure TShortHultAxis.QuoteProc(aQuote: TQuote; iDataID: integer);
begin
  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;

  if not IsRun then Exit;
  if ( FSymbol <> aQuote.Symbol ) then Exit;

  if not FReady then
    DoInit( aQuote )
  else
    UpdateQuote( aQuote );


end;

procedure TShortHultAxis.Reset;
begin
  FRun := false;
  FReady  := false;
  FLossCut:= false;
  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;
  FMinTime := 0;
  FMaxTime := 0;

end;

function TShortHultAxis.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;
  AddPosition(FSymbol);
  FRun := true;

  if Assigned(OnResult) then
    OnResult(self, FRun);

  gEnv.EnvLog(WIN_SHORTHULT, Format('ShortHult Start %s, %d', [FSymbol.Code, FData.OrdGap]) );
end;

procedure TShortHultAxis.Stop(bAuto : boolean);
begin
  FRun := false;

  if Assigned(OnResult) then
    OnResult(self, FRun);

  gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );
  gEnv.EnvLog(WIN_SHORTHULT, Format('ShortHult Stop %s, %d', [FSymbol.Code, FData.OrdGap]) );
  // 손절 넣자....

  if bAuto then
  begin
    //FLcTimer.Enabled := true;
    BHULTLossCut(1);
  end;
end;

procedure TShortHultAxis.CheckOutOrder;
var
  I: Integer;
  aOrder : TOrder;
  aTicket: TOrderTicket;
begin
  for I := FSendOrders.Count - 1 downto 0 do
  begin
    aOrder  := TOrder( FSendOrders.Items[i] );
    if ( aOrder.OrderType = otNormal ) and ( aOrder.State = osActive ) and
      ( aOrder.ActiveQty > 0 ) then
    begin
      aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
      if gEnv.Engine.TradeCore.Orders.NewCancelOrderEx( aOrder, aOrder.ActiveQty, aTicket ) <> nil then
      begin
        gEnv.Engine.TradeBroker.Send(aTicket);
        FSendOrders.Delete(i);
      end;
    end;
  end;
end;


procedure TShortHultAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
begin

  if aOrder.OrderSpecies <> opShortHult then exit;

  if not IsRun then
  begin
    CheckOutOrder;
    Exit;
  end;

  if iID = ORDER_FILLED then
    DoFill(aOrder);

  if aOrder.State in [osSrvRjt, osRejected, osFilled, osCanceled,
                 osConfirmed, osFailed] then
    FSendOrders.Remove(aOrder);

  if aOrder.State = osActive then
    DoCancel( aOrder );

end;

procedure TShortHultAxis.UpdateQuote(aQuote: TQuote);
var
  stTime, stTime1 : string;
  stLog : string;
  dOTE : array[0..1] of double;
  dPL : double;
begin

  if Position <> nil then
  begin
    if FMinPL > Position.LastPL - Position.GetFee then
    begin
      FMinPL := Position.LastPL - Position.GetFee;
      FMinTime := GetQuoteTime;
    end;

    if FMaxPL < Position.LastPL - Position.GetFee then
    begin
      FMaxPL := Position.LastPL - Position.GetFee;
      FMaxTime := GetQuoteTime;
    end;
    //FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
    //FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );
  end;

  stTime := FormatDateTime('hh:mm:ss.zzz', FData.LiquidTime);
  stTime1 := FormatDateTime('hh:mm:ss.zzz', GetQuoteTime);
  if (FData.UseAutoLiquid) and (Frac(FData.LiquidTime) <= Frac(GetQuoteTime)) then
  begin
    Stop;
    stLog := Format('청산시간 %s <= %s', [stTime, stTime1]);
    gEnv.EnvLog(WIN_SHORTHULT, stLog);
    exit;
  end;

  if Position <> nil then
  begin
    if (FData.UseAllcnlNStop) and (TotPL <= FData.RiskAmt * -10000) then
    begin
      Stop;
      stLog := Format('일일한도 오버 %.0f', [TotPL]);
      gEnv.EnvLog(WIN_SHORTHULT, stLog);
      exit;
    end;

    if (FData.UseAllcnlNStop) and (TotPL >= FData.ProfitAmt * 10000) then
    begin
      Stop;
      stLog := Format('이익청산 %.0f', [TotPL]);
      gEnv.EnvLog(WIN_SHORTHULT, stLog);
      exit;
    end;
  end;

  if aQUote.LastEvent = qtTimeNSale then
  begin
    //손절... 체크
    DoLossCut(aQuote);
  //  if FData.UseBaseLast then
  //    DoBaseClear(aQuote);
  end;

end;

{ TAddEntrys }

constructor TShortHultPrices.Create;
begin
  inherited Create(TShortHultPrice);
end;

destructor TShortHultPrices.Destroy;
begin

  inherited;
end;

function TShortHultPrices.Find(dPrice: double; iPer : integer): TShortHultPrice;
var
  i : integer;
  aItem : TShortHultPrice;

begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    aItem := Items[i] as TShortHultPrice;
    if ComparePrice( iPer, dPrice, aItem.Price) = 0 then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

function TShortHultPrices.FindLastOrder(iSide: integer): TShortHultPrice;
var
  index, i : integer;
  aItem : TShortHultPrice;
begin
  index := BasePrice.Index;

  Result := nil;

  if iSide > 0 then
  begin
    for I := index + 1 to Count - 2 do
    begin
      aItem := GetItem(i);
      if aItem = nil then Continue;
      if aItem.SendOrder then
      begin
        Result := aItem;
        break;
      end;
    end;
  end else
  begin
    for I := index-1 downto  1 do
    begin
      aItem := GetItem(i);
      if aItem = nil then Continue;
      if aItem.SendOrder then
      begin
        Result := aItem;
        break;
      end;
    end;
  end;

  // Result 가 nill 이면
  // 깔려있는 주문이 없다는 뜻..
end;

function TShortHultPrices.GetItem(iIndex: integer): TShortHultPrice;
begin
  Result := nil;
  if (iIndex < 0) or (Count <= iIndex) then exit;

  Result := Items[iIndex] as TShortHultPrice;
end;

function TShortHultPrices.New(dPrice : double; bBase : boolean): TShortHultPrice;
begin
  //Result := Find(dPrice);
  //if Result = nil then
  //begin
  Result := Add as TShortHultPrice;
  Result.Price := dPrice;
  Result.Base := bBase;
  Result.LossCut := false;
  Result.SendOrder := false;
  if Result.Base then
    Result.Index := Count - 1;
  //end;
end;

{ TShortHultPrice }

function TShortHultPrice.GetString: string;
begin
{
    Price : double;
    Base : boolean;
    LossCut : boolean;
    Index : integer;
    SendOrder : boolean;
    }
  Result  := format('%d, %.2f, %s, %s, %s', [ Index, Price,
    ifThenStr( Base, 'Base', 'not Base'),
    ifThenStr( LossCut, 'End', 'not End'),
    ifThenStr( SendOrder, 'Have Order', 'not Order ')
    ]);
end;

{ TCnlOrders }

constructor TCnlOrders.Create;
begin
  inherited Create( TCnlOrder );
end;

function TCnlOrders.Find(aOrder: TORder; var idx : integer): TCnlOrder;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if ( Items[i] as TCnlOrder).Order = aOrder then
    begin
      Result := Items[i] as TCnlOrder;
      idx    := i;
      break;
    end;
end;

procedure TCnlOrders.New(aOrder: TOrder; aItem: TShortHultPrice);
begin
  with ( Add as TCnlOrder ) do
  begin
    Order := aOrder;
    Price := aItem;
  end;

end;

end.
