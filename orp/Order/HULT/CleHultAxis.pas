unit CleHultAxis;

interface
uses
  Classes, SysUtils, Math, DateUtils, Graphics,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFrontOrder,

  UObjectBase, UPaveConfig, UPriceItem,  UFillList, CleQuoteTimers,

  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleCircularQueue, CleStrategyStore,

  GleTypes, GleConsts;
type

  THultAxis = class(TStrategyBase)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FPriceSet: TPriceSet;
    FHultData: THultData;
    FLossCut : boolean;
    FOrders: TOrderItem;
    FReady: boolean;
    FMyFills: TFillList;
    FOnPositionEvent: TObjectNotifyEvent;
    FLcTimer : TQuoteTimer;

    FAskPrice : TPriceItem2;
    FBidPrice : TPriceItem2;

    FAskStartIdx: integer;
    FBidStartIdx: integer;
    FRemSide, FRemNet, FRemQty : integer;
    FScreenNumber : integer;
    FMaxPL, FMinPL : double;
    FRun : boolean;

    FBetweenPriceSet: TPriceSet;
    FBetweenReady : boolean;
    FBetweenOrders : TList;
    FFirstPrice : double;
    FBackColor : TColor;
    procedure OnLcTimer( Sender : TObject );
    procedure TradeProc(aOrder : TOrder; aPos : TPosition; iID : integer); override;
    procedure QuoteProc(aQuote : TQuote; iDataID : integer); override;

    procedure DoOrder( aPrice : TPriceItem2; iQty : integer); overload;
    procedure DoOrder(iSide: integer; dPrice: double; iIdx : integer); overload;
    procedure DoBetweenOrder( aPrice : TPriceItem2; iSide, iQty : integer);
    function IsRun : boolean;
    procedure DoInit( aQuote : TQuote );
    procedure UpdateQuote(aQuote: TQuote);
    procedure DoFill(aOrder: TOrder;  bFull : boolean = false);
    procedure MakePriceItem;
    procedure Reset;
    procedure DoOrderPiece( aQuote : TQuote; iSide : integer );
    function IsOrder(aPrice: TPriceItem2): boolean;
    function GetOrderSpecies : TOrderSpecies;
    function HULTLossCut( iSide: integer): integer;
    procedure AddPieces(aOrder1 : TOrder);

    procedure SetEndIdx(aOrder : TOrder; bCancel : boolean);

    procedure MakeBetweenPriceItem(aOrder : TOrder);
    procedure DoBetweenAdd(aOrder : TOrder);

    procedure DoLog;
    function IsValid(aPrice, tgPrice: TPriceItem2;  aQuote : TQuote; iSide: integer): boolean;
  public
    //Constructor Create( aColl : TCollection ) ; override;
    //Destructor  Destroy; override;
    constructor Create(aColl: TCollection; opType : TOrderSpecies);
    destructor Destroy; override;

    procedure init( aAcnt : TAccount; aSymbol : TSymbol);
    function Start : boolean;
    Procedure Stop( bLossCut : boolean = true);
    procedure DoBetweenCancel;
    procedure Pause;

    function CheckHULTLossCut( iNet, iSide : integer ) : boolean ;

    property Orders   : TOrderItem read FOrders ;
    property PriceSet : TPriceSet  read FPriceSet ;
    property HultData  : THultData read FHultData write FHultData;

    property Ready    : boolean    read FReady ;  // 포석을 깔았다 / 아직 안깔았다
    property AskEndIdx : integer read FAskStartIdx;
    property BidEndIdx : integer read FBidStartIdx;

    property MyFills    : TFillList read FMyFills ;
    property ScreenNumber : integer read FScreenNumber;
    property MaxPL : double read FMaxPL;
    property MinPL : double read FMinPL;
    property Run : boolean read FRun;

    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
  end;


implementation
uses
  GAppEnv, GleLib, Dialogs, CleFQN;

{ THultAxis }

procedure THultAxis.AddPieces(aOrder1 : TOrder);
var
  iBidCnt, iAskCnt, i, iMax, iGap : integer;
  tgPrice, aPrice : TPRiceITem2;
  aOrder : TOrder;
begin
{
  iBidCnt := FPriceSet.BidOrdCnt;// iBidSend; // 현재 매수피스를 만들어서 보낸 카운터
  iAskCnt := FPriceSet.AskOrdCnt;// -  iAskSend; // 현재 매도피스를 만들어서 보낸 카운터
  if (FBidPrice <> nil) and (FAskPrice <> nil) then
    gEnv.EnvLog( WIN_HULT,  Format('Start AddPieces :BidOrd = %d, AskOrd = %d, Index Bid = %d(%.1f), Ask = %d(%.1f)',
                                 [iBidCnt, iAskCnt, FBidPrice.Index, FBidPrice.Price, FAskPrice.Index, FAskPrice.Price])  );

    //
  if iAskCnt < FHultData.QuotingQty then
  begin
    //매도 피스
    if FAskPrice <> nil then
    begin
      tgPrice := FPriceSet.PriceItem[FAskPrice.Index + FHultData.OrdGap];
      if tgPrice <> nil then
      begin
        aPiece := FSelPieces.New( -1, FAskPrice.Price );
        aPiece.FilledPrice  := FAskPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;
        gEnv.EnvLog( WIN_HULT,  Format('Add New Piece(%d) Price > 0 : 매도 %s  %s [%d]', [
          FSelPieces.Count,  FAskPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end else if iAskCnt > FHultData.QuotingQty then
  begin
    if FAskPrice <> nil then
    begin
      if FAskPrice.CancelOrderCheck then
      begin
        for i := 0 to FAskPrice.OrderList.Count - 1 do
        begin
          aOrder := FAskPrice.OrderList.Orders[i];
          gEnv.Engine.TradeCore.FrontOrders.DoCancel( aOrder );
          gEnv.EnvLog( WIN_HULT,  Format('Cancel : 매도 %s', [FAskPrice.GetPriceDesc])  );
        end;
      end else
      begin
        gEnv.EnvLog( WIN_HULT,  Format('Cancel : 매도 취소할 주문이 없다  %s', [FAskPrice.GetPriceDesc])  );
      end;
    end;
  end;

  if iBidCnt < FHultData.QuotingQty then
  begin
    //매수 피스
    if FBidPrice <> nil then
    begin
      tgPrice := FPriceSet.PriceItem[FBidPrice.Index - FHultData.OrdGap];
      if tgPrice <> nil then
      begin
        aPiece := FBuyPieces.New( 1, FBidPrice.Price );
        aPiece.FilledPrice  := FBidPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex  := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;
        gEnv.EnvLog( WIN_HULT,  Format('Add New Piece(%d) Price > 0 : 매수 %s, %s [%d]', [
          FBuyPieces.Count,  FBidPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end else if iBidCnt > FHultData.QuotingQty then
  begin
    if FBidPrice <> nil then
    begin
      if FBidPrice.CancelOrderCheck then
      begin
        for i := 0 to FBidPrice.OrderList.Count - 1 do
        begin
          aOrder := FBidPrice.OrderList.Orders[i];
          gEnv.Engine.TradeCore.FrontOrders.DoCancel( aOrder );
          gEnv.EnvLog( WIN_HULT,  Format('Cancel : 매수 %s', [FBidPrice.GetPriceDesc])  );
        end;
      end else
      begin
        gEnv.EnvLog( WIN_HULT,  Format('Cancel : 매수 취소할 주문이 없다  %s', [FBidPrice.GetPriceDesc])  );
      end;
    end;
  end;

//취소 확인보다 체결이 더 빠른경우
  if iAskCnt >= FHultData.QuotingQty then
  begin
    tgPrice := FPriceSet.PriceItem[aOrder1.PriceIdx + (FHultData.OrdGap * FHultData.QuotingQty)];
    if (tgPrice <> nil) and (tgPrice.OrderList.Count > 0) then
    begin
      aOrder := tgPrice.OrderList[0];
      if aOrder.OrderType = otCancel then
      begin
        aPiece := FSelPieces.New( -1, tgPrice.Price );
        aPiece.FilledPrice  := tgPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;
        gEnv.EnvLog( WIN_HULT,  Format('Add New Piece 매도  iAskCnt(%d) >= QuotingCnt(%d) : %s  ]', [ iAskCnt,
                                         HultData.QuotingQty, tgPrice.GetPriceDesc])  );
      end;
    end;
  end;

  if iBidCnt >= FHultData.QuotingQty then
  begin
    tgPrice := FPriceSet.PriceItem[aOrder1.PriceIdx - (FHultData.OrdGap * FHultData.QuotingQty)];
    if (tgPrice <> nil) and (tgPrice.OrderList.Count > 0) then
    begin
      aOrder := tgPrice.OrderList[0];
      if aOrder.OrderType = otCancel then
      begin
        aPiece := FBuyPieces.New( 1, tgPrice.Price );
        aPiece.FilledPrice  := tgPrice.Price;
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;
        gEnv.EnvLog( WIN_HULT,  Format('Add New Piece 매수  iBidCnt(%d) >= QuotingCnt(%d) : %s  ]', [ iBidCnt,
                                         HultData.QuotingQty, tgPrice.GetPriceDesc])  );

      end;
    end;
  end;
  }
end;

function THultAxis.CheckHULTLossCut(iNet, iSide: integer): boolean;
var
  stLog : string;
begin
  Result := false;
  if Position = nil then exit;
end;

constructor THultAxis.Create(aColl: TCollection; opType : TOrderSpecies);
begin
  inherited Create(aColl, opType, stBHult);

  FScreenNumber := Number;


  FPriceSet := TPriceSet.Create;

  FMyFills:= TFillList.Create;
  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 5000 * 4;
  FLcTimer.OnTimer := OnLcTimer;

  FBetweenPriceSet := TPriceSet.Create;
  FBetweenOrders := TList.Create;
  Reset;
end;

destructor THultAxis.Destroy;
begin
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  FPriceSet.Free;
  FMyFills.Free;

  FBetweenPriceSet.Free;
  FBetweenOrders.Free;
  inherited;
end;

procedure THultAxis.DoBetweenAdd(aOrder : TOrder);
var
  i, iGap, iSide, iIndex, iCnt : integer;
  aPriceItem : TPriceItem2;
  dPrice : double;
  stLog : string;
begin

  iSide := 0;
  iGap := Ceil(FHultData.OrdGap / 2);
  if (Position.Volume < 0) and (aOrder.Side < 0) then
  begin
    iSide := 1;
    dPrice := TicksFromPrice(FSymbol, aOrder.FilledPrice, -iGap);
  end else if (Position.Volume > 0) and (aOrder.Side > 0) then
  begin
    iSide := -1;
    dPrice := TicksFromPrice(FSymbol, aOrder.FilledPrice, iGap);
  end;

  if iSide = 0 then exit;

  iIndex := FBetweenPriceSet.Find2(dPrice);

  for i := iIndex downto 0 do
  begin
    aPriceItem := FBetweenPriceSet.PriceItem[i];
    if aPriceItem <> nil then
    begin
      iCnt := aPriceItem.GetOrderCnt;
      if iCnt > 0 then break;
      stLog := Format('BetweenAdd %.2f -> %s, Side = %d, Gap = %d', [aOrder.FilledPrice, aPriceItem.PriceDesc, iSide, iGap]);
      gEnv.EnvLog(WIN_HULT, stLog);
      DoBetweenOrder(aPriceItem, iSide, FHultData.OrdQty);
    end else
    begin
      stLog := Format('BetweenAdd Failed %.2f -> %.2f, Side = %d, Gap = %d', [aOrder.FilledPrice, dPrice, iSide, iGap]);
      gEnv.EnvLog(WIN_HULT, stLog);
    end;
  end;

end;

procedure THultAxis.DoBetweenCancel;
var
  i : integer;
  aOrder, aTarget : TOrder;
  aTicket : TOrderTicket;
  stLog : string;
begin
  if (FBetweenOrders = nil) or (FBetweenPriceSet = nil) then exit;
  
  for i := 0 to FBetweenOrders.Count - 1 do
  begin
    aTarget := FBetweenOrders.Items[i];
    if (aTarget.State = osActive) and (aTarget.OrderType = otNormal) then
    begin
      aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
      aOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aTarget, aTarget.ActiveQty, aTicket);
      aOrder.BetweenOrder := true;
      gEnv.Engine.TradeBroker.Send(aTicket);
    end;
  end;

  FBetweenReady := false;
  FBetweenPriceSet.ReSet;
  FBetweenOrders.Clear;
  stLog := Format('DoBetweenCancel Pos = %d, %d',[Position.Volume, FHultData.EPos]);
  gEnv.EnvLog(WIN_HULT, stLog);
end;

procedure THultAxis.DoBetweenOrder(aPrice: TPriceItem2; iSide, iQty: integer);
var
  aOrder : TOrder;
  aTicket : TOrderTicket;
begin
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, FSymbol,
    iQty * iSide, pcLimit, aPrice.Price, tmGTC, aTicket);
  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := GetOrderSpecies;
    aOrder.BetweenOrder := true;
    aPrice.AddOrder( aOrder );
    aOrder.PriceIdx := aPrice.Index;
    FBetweenOrders.Add(aOrder);
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;
  gEnv.EnvLog( WIN_HULT, Format('DoBetweenOrder 주문 : %s', [ aOrder.Represent2 ]) , false, FSymbol.Code);
end;

function THultAxis.IsValid( aPrice, tgPrice : TPriceItem2;  aQuote : TQuote;
    iSide : integer ) : boolean;
begin
  Result := false;

  if ( aPrice = nil ) or ( tgPrice = nil ) or ( aQuote = nil ) or ( iSide = 0 ) then Exit;

  if ( aPrice.Price < PRICE_EPSILON ) or
     ( tgPrice.Price < PRICE_EPSILON ) or
     ( aQuote.Asks[0].Price < PRICE_EPSILON ) or
     ( aQuote.Bids[0].Price < PRICE_EPSILON ) then
  begin
    gEnv.EnvLog( WIN_HULT, Format('IsValid  무언가가 0 보다 작다 -> %s : %.2f, %.2f, %.2f, %.2f',
    [ FSymbol.ShortCode, aPrice.Price, tgPrice.Price, aQuote.Asks[0].Price, aQuote.Bids[0].Price ] ));
    Exit;
  end;

  if iSide > 0 then
  begin
    if ( aPrice.Price < tgPrice.Price ) and
      ( tgPrice.Price > aQuote.Asks[0].Price ) then
      Result := true;
  end
  else begin
    if ( aPrice.Price > tgPrice.Price ) and
      ( tgPrice.Price < aQuote.Bids[0].Price )  then
      Result := true;
  end;
end;

procedure THultAxis.DoFill(aOrder: TOrder; bFull : boolean);
var
  iOrdQty, iIdx, iGap, iTgIdx, iSide, i : integer;
  aType : TPositionType;
  aFill : TFill;
  aFItem : TFillItem;
  stLog : string;
  dPrice : double;
  aQuote : TQuote;
  tgPrice, aPrice, addPrice, cnlPrice : TPRiceITem2;
  bRes : boolean;
  aTicket : TOrderTicket;
  aTarget, pOrder : TOrder;
begin
  if Position = nil then Exit;

  aFill := TFill( Position.Fills.Last );
  if aFill = nil then Exit;
  iOrdQty := abs(aFill.Volume);

  aQuote  := FSymbol.Quote as TQuote;

  stLog := format('New Fill : %s, %s, %s, %d (%d) %s|%s|%s ', [
    FSymbol.Code, ifThenStr( aOrder.Side > 0 ,'L','S' ),
    FSymbol.PriceToStr( aFill.Price ),
    iOrdQty, aOrder.OrderNo,
    FSymbol.PriceToStr( aQuote.Asks[0].Price ),
    FSymbol.PriceToStr( aQuote.Last ),
  FSymbol.PriceToStr( aQuote.Bids[0].Price )
     ]);
  gLog.Add(lkLossCut, 'THultAxis','DoFill', stlog);

  if aOrder.Side > 0 then
    aType := ptShort
  else
    aType := ptLong;

  if aOrder.PriceIdx < 0 then begin
    iIdx := FPriceSet.GetIndex( aOrder.Price );
    aOrder.PriceIdx := iIdx;
  end;

  aPrice := FPriceSet.PriceItem[ aOrder.PriceIdx ];
  if aPrice = nil then Exit;

  // update by 2014.12.9
  // order piece 를 사용안하고..바로 주문 낸다.
  {
   * 매수 체결
     1. 청산매도주문 깔기 - 체결수량만큼
     2. 매수주문 깔기     - 전량체결시
     3. 매도주문 취소     - 전량체결시
  }

  tgPrice := FPriceSet.PriceItem[ aPrice.Index + (FHultData.OrdGap * aOrder.Side ) ];
  if (tgPrice <> nil) and ( IsValid( aPrice, tgPrice, aQuote, aOrder.Side )) then
  begin

    tgPrice.SetSide( aOrder.Side * -1 );
    DoOrder( tgPrice, iOrdQty );

    // 전량체결 됐는지..
    if ( aOrder.State = osFilled ) and  ( aPrice.OrderList.Count = 0 ) then
      bFull := true
    else
      bFull := false;

    if bFull then
    begin
      addPrice  := FPriceSet.PriceItem[ aPrice.Index + (FHultData.OrdGap * FHultData.QuotingQty * -aOrder.Side ) ];
      cnlPrice  := FPriceSet.PriceItem[ tgPrice.Index+ (FHultData.OrdGap * FHultData.QuotingQty * aOrder.Side ) ];

      if ( addPrice <> nil ) and ( addPrice.OrderList.Count = 0 ) then
      begin
        addPrice.SetSide( aOrder.Side );
        DoOrder( addPrice, FHultData.OrdQty );
      end;

      if cnlPrice <> nil then
        for i := 0 to cnlPrice.OrderList.Count-1 do
        begin
          aTarget := cnlPrice.OrderList.Orders[i];
          if (aTarget.State = osActive) and (aTarget.OrderType = otNormal) and ( not aTarget.Modify ) then
          begin
            aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
            pOrder := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx(aTarget, aTarget.ActiveQty, aTicket);
            if pOrder <> nil then
              gEnv.Engine.TradeBroker.Send(aTicket);
          end;
        end;
      end;
  end;



  {
  if aOrder.State = osFilled then
  begin
    aPrice := FPriceSet.PriceItem[ aOrder.PriceIdx ];

    if aOrder.Side > 0 then begin
      aPiece := FSelPieces.New( aOrder.Side, aOrder.Price );
      aPiece.FilledPrice  := aPrice.Price;
      tgPrice := FPriceSet.PriceItem[ aPrice.Index + FHultData.OrdGap ];
      if tgPrice <> nil then begin
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex      := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;
        gEnv.EnvLog( WIN_HULT,  Format('New Piece(%d) : 매수 체결 %s 로 매도 주문 %s [%d]', [
          FSelPieces.Count,  aPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume  ])  );
      end;
    end
    else begin
      aPiece := FBuyPieces.New( aOrder.Side, aOrder.Price );
      aPiece.FilledPrice  := aPrice.Price;
      tgPrice := FPriceSet.PriceItem[ aPrice.Index - FHultData.OrdGap ];
      if tgPrice <> nil then begin
        aPiece.OrderPrice := tgPrice.Price;
        aPiece.OrderIndex := tgPrice.Index;
        aPiece.OrderQty := FHultData.OrdQty;

        gEnv.EnvLog( WIN_HULT,  Format('New Piece(%d) : 매도 체결 %s 로 매수 주문 %s [%d]', [
          FBuyPieces.Count,  aPrice.PriceDesc, tgPrice.PriceDesc, Position.Volume])  );
      end;
    end;
  end;
  }



  // 다른 방향의 체결이면 clear
  if aFill.Volume > 0 then
    iSide := 1
  else
    iSide := -1;

  if (aOrder.State = osFilled) and (bFull) then
  begin
    if FMyFills.Side = iSide then
    begin
      aFItem := FMyFills.New( GetQuoteTime );
      aFItem.Price  := aFill.Price;
      aFItem.Qty    := abs(aFill.Volume);
      aFItem.Side   := iSide;
      aFItem.Index  := aOrder.PriceIdx;
      aFItem.Order  := aOrder;
      if iSide = 1 then
        aFItem.PosType:= ptLong
      else  aFItem.PosType := ptShort;
    end;
  end;

  FMyFills.Side := iSide;

  bRes := CheckHULTLossCut( FMyFills.Count, FMyFills.Side  );
  if bRes then
    Stop
  else
  begin
    DoOrderPiece( aQuote, aOrder.Side );
    if (aOrder.State = osFilled) and (bFull) then
    begin
      AddPieces(aOrder);
      DoOrderPiece( aQuote,  1 );
      DoOrderPiece( aQuote, -1 );
    end;
  end;
end;

procedure THultAxis.DoInit(aQuote: TQuote);
var
  I, iAskIdx, iBidIdx: Integer;
  dLastAskPrice, dLastBidPrice : double;
  AskPrice, BidPrice : double;
  SAskPrice, SBidPrice : double;

  aItem : TPriceItem2;
  stLog : string;
  bAskLimit, bBidLimit : boolean;

  function IsLAskimited : boolean;
  begin
    if (FSymbol.LimitHigh > dLastAskPrice + EPSILON ) and (aQuote.Asks[0].Price + EPSILON < dLastAskPrice ) then
      Result := false
    else
      Result := true;
  end;

  function IsBidLimited : boolean;
  begin
    if (FSymbol.LimitLow <  dLastBidPrice + EPSILON ) and (aQuote.Bids[0].Price + EPSILON > dLastBidPrice ) then
      Result := false
    else
      Result := true;
  end;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) then
  begin
    Exit;
  end;

  if aQuote.FTicks.Count <= 0 then exit;
  if Frac(GetQuoteTime) < Frac(FHultData.StartTime) then exit;

  if FHultData.STick > 0 then
  begin
    if FFirstPrice = 0 then
    begin
      FFirstPrice := aQuote.Last;
      exit;
    end;

    SAskPrice := TicksFromPrice( aQuote.Symbol, FFirstPrice, FHultData.STick );
    SBidPrice := TicksFromPrice( aQuote.Symbol, FFirstPrice, -FHultData.STick );
    if FFirstPrice > aQuote.Last + PRICE_EPSILON then           //하락
    begin
      if aQuote.Last > SBidPrice + PRICE_EPSILON then
        exit;
    end else if FFirstPrice + PRICE_EPSILON < aQuote.Last then  //상승
    begin
      if aQuote.Last + PRICE_EPSILON < SAskPrice then
        exit;
    end else
      exit;

    stLog := Format('DoInit STick = %d, First = %.2f, L = %.2f, Ask = %.2f, Bid = %.2f, TickCount = %d',
                    [FHultData.STick, FFirstPrice, aQuote.Last, SAskPrice, SBidPrice, aQuote.FTicks.Count]);
    gEnv.EnvLog(WIN_HULT, stLog);
  end;

  AskPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, FHultData.OrdGap );
  BidPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Last, -FHultData.OrdGap );

  stLog :=  Format('Index  : %.2f, %s <- %s | %s -> %s cnt:%d, %d, TickCount = %d',
    [
      aQuote.Last,
      aQuote.Symbol.PriceToStr( AskPrice ),
      aQuote.Symbol.PriceToStr( aQuote.Asks[0].Price ),
      aQuote.Symbol.PriceToStr( aQuote.Bids[0].Price ),
      aQuote.Symbol.PriceToStr( BidPrice ),
      FPriceSet.Count-1,
      FHultData.STick,
      aQuote.FTicks.Count
    ]);
  gEnv.EnvLog(WIN_HULT, stLog);    

  for I := 0 to FHultData.QuotingQty - 1 do
  begin
    bAskLimit := false;
    bBidLimit := false;
    dLastAskPrice := IfThenFloat( i=0, AskPrice,  TicksFromPrice( aQuote.Symbol, dLastAskPrice, FHultData.OrdGap ));
    dLastBidPrice := IfThenFloat( i=0, BidPrice,  TicksFromPrice( aQuote.Symbol, dLastBidPrice, -FHultData.OrdGap ));

    bAskLimit := IsLAskimited;
    bBidLimit := IsBidLimited;

    if (bAskLimit) or (bBidLimit) then
      break;

    iAskIdx := FPriceSet.GetIndex( dLastAskPrice );
    if iAskIdx >= 0 then begin
      gEnv.EnvLog( WIN_HULT, Format('매도 : %d, %s, %d, %d', [ i, FSymbol.PriceToStr( dLastAskPrice ), iAskIdx, FHultData.OrdGap ])  );
      DoOrder( -1, dLastAskPrice, iAskIdx );
      FAskPrice := FPriceSet.PriceItem[iAskIdx];
      if FAskStartIdx < 0 then
        FAskStartIdx := iAskIdx;
    end;
    iBidIdx := FPriceSet.GetIndex( dLastBidPrice );
    if iBidIdx >= 0 then begin
      gEnv.EnvLog( WIN_HULT, Format('매수 : %d, %s, %d, %d', [ i, FSymbol.PriceToStr( dLastAskPrice ), iBidIdx, FHultData.OrdGap ])  );
      DoOrder( 1, dLastBidPrice, iBidIdx  );
      FBidPrice := FPriceSet.PriceItem[iBidIdx];
      if FBidStartIdx < 0 then
        FBidStartIdx := iBidIdx;
    end;
  end;

  if ( FAskStartIdx >= 0 ) and  ( FBidStartIdx >= 0 ) then
  begin
    {
    if gEnv.RunMode = rtSimulation then
    begin
      if (FSymbol as TFuture).DaysToExp = 1 then
        FHultData.LiquidTime := EnCodeTime(14, 45, 0 ,0)
      else
        FHultData.LiquidTime := EnCodeTime(15, 0, 0 ,0);
    end;
     }
    FReady := true;
  end else
  begin
    gEnv.EnvLog( WIN_HULT, Format('Start Index Error FAskStartIdx = %d, FBidStartIdx = %d ', [FAskStartIdx, FBidStartIdx]) );
    //stop;
    //ShowMessage( 'End Index Error ' );
  end;
end;

procedure THultAxis.DoLog;
var
  stLog, stFile : string;
begin
  //날짜, Tick수, 매도대금, 매수대금, 손실매도, 손실매수, 최대잔고
  {
  if Position <> nil then
  begin
    stLog := Format('%s, %d, %.0f, %.0f, %.0f, %.0f, %d',
                 [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FHultData.OrdGap,
                 Position.AskTradeAmount, Position.BidTradeAmount, Position.AskTradeAmountMax, Position.BidTradeAmountMax, Position.MaxPos  ])


  end else
    stLog := Format('%s, %d, %.0f, %.0f, %.0f, %.0f, %d',
                 [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FHultData.OrdGap,
                 0, 0, 0, 0, 0 ]);
                }

  if Position = nil then
    stLog := Format('%s, %s, %d, %.0f, %.0f, %.0f, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime), '' ,
                FHultData.OrdGap, 0, 0, 0, 0])
  else
    stLog := Format('%s, %s, %d, %.0f, %.0f, %.0f, %d', [FormatDateTime(' yyyy-mm-dd', GetQuoteTime), Position.Symbol.ShortCode,
                FHultData.OrdGap, (Position.LastPL - Position.GetFee)/1000, MaxPL/1000, MinPL/1000, Position.MaxPos]);

  stFile := Format('Hult_%s.csv', [FAccount.Code]);
  gEnv.EnvLog(WIN_HULT, stLog, true, stFile);
end;

procedure THultAxis.DoOrder(iSide: integer; dPrice: double; iIdx: integer);
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
  stLog   : string;
  aPos : TPosition;
  aPrice : TPriceItem2;
  iMax : integer;
begin
  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);

  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, Account, FSymbol,
                FHultData.OrdQty * iSide, pcLimit, dPrice, tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := GetOrderSpecies;

    gEnv.Engine.TradeBroker.Send(aTicket);
    stLog := Format( 'Send Order : %s, %s, %s, %d, %d ',
      [
        FSymbol.Code,
        ifThenStr( iSide > 0 , 'L', 'S'),
        FSymbol.PriceToStr( dPrice ),
        FHultData.OrdQty, iIdx
      ]
      );

    gEnv.EnvLog( WIN_HULT, Format('주문 : %s', [ aOrder.Represent2 ]) , false, FSymbol.Code);
    gLog.Add(lkLossCut, 'TPriceAxis','DoOrder', stLog );

    aPrice  := FPriceSet.PriceItem[iIdx];
    if aPrice <> nil then
    begin
      aPrice.AddOrder( aOrder );
      aOrder.PriceIdx := iIdx;
    end;
  end;
end;

procedure THultAxis.DoOrder(aPrice: TPriceItem2; iQty : integer);
var
  iMax, i : integer;
  iCnt, iLiqQty, iLiqQty2, iSide : integer;
  aOrder : TOrder;
  tgType : TPositionType;
  aTicket : TOrderTicket;
begin

  if Position <> nil then
    iMax := abs(Position.Volume)
  else
    imax := 0;

  if aPrice.PositionType = ptLong then
    iSide := 1
  else
    iSide := -1;

  aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
  aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, FSymbol,
    iQty * iSide, pcLimit, aPrice.Price, tmGTC, aTicket);
  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := GetOrderSpecies;
    aPrice.AddOrder( aOrder );
    aOrder.PriceIdx := aPrice.Index;
    gEnv.Engine.TradeBroker.Send(aTicket);
    SetEndIdx(aOrder, false);
  end;
  //gEnv.EnvLog( WIN_HULT, Format('주문 : %s', [ aOrder.Represent2 ]) , false, FSymbol.Code);
end;

procedure THultAxis.DoOrderPiece(aQuote: TQuote; iSide: integer);
var
  iIndex: Integer;
  aPrice : TPriceItem2;
begin
{
  // 매수 체결이면 SelPiece 에서 주문체크.
  iIndex := 0;


  if iSide > 0 then
  begin
    while iIndex <= FSelPieces.Count - 1 do
    begin
      aPiece  := FSelPieces.OrderPiece[iIndex];
      aPrice  := FPriceSet.PriceItem[ aPiece.OrderIndex ];

      if aPrice <> nil then
         gEnv.EnvLog(WIN_HULT, Format('DoOrderPiece 매도 idx = %d, Cnt = %d',[aPiece.OrderIndex, aPrice.OrderList.Count]) );


      if ( aPrice <> nil ) and
         ( IsOrder( aPrice )) and ( aPrice.OrderList.Count = 0) then
      begin
        // 혹시나 방향이 틀릴수도 있어서
        aPrice.PositionType := ptShort;
        DoOrder( aPrice, aPiece.OrderQty );

        gEnv.EnvLog( WIN_HULT, Format( 'Ord Piece(%d) : 매도 %s -> %s ,%d : %s', [ FSelPieces.Count,
          FSymbol.PriceToStr( aPiece.FilledPrice), FSymbol.PriceToStr( aPiece.OrderPrice),
          aPiece.OrderIndex, aPrice.PriceDesc])  );

        FSelPieces.Delete(iIndex);
      end else
        inc(iIndex);
    end;
  end
  else begin
    while iIndex <= FBuyPieces.Count-1 do
    begin
      aPiece  := FBuyPieces.OrderPiece[iIndex];
      aPrice  := FPriceSet.PriceItem[ aPiece.OrderIndex ];

      if aPrice <> nil then
         gEnv.EnvLog(WIN_HULT, Format('DoOrderPiece 매도 idx = %d, Cnt = %d, Price = %.2f',[aPiece.OrderIndex, aPrice.OrderList.Count, aPrice.Price]) );

      if ( aPrice <> nil ) and
         ( IsOrder( aPrice )) and ( aPrice.OrderList.Count = 0) then
      begin
        // 혹시나 방향이 틀릴수도 있어서
        aPrice.PositionType := ptLong;
        DoOrder( aPrice, aPiece.OrderQty );

        gEnv.EnvLog( WIN_HULT, Format( 'Ord Piece(%d) : 매수 %s -> %s ,%d : %s', [ FBuyPieces.Count,
          FSymbol.PriceToStr( aPiece.FilledPrice), FSymbol.PriceToStr( aPiece.OrderPrice),
          aPiece.OrderIndex, aPrice.PriceDesc])  );

        FBuyPieces.Delete(iIndex);
      end else
        inc(iIndex);
    end;
  end;       }
end;

function THultAxis.GetOrderSpecies: TOrderSpecies;
begin
  Result := opHULT
end;

function THultAxis.HULTLossCut(iSide: integer): integer;
var
  stLog : string;
  aTicket : TOrderTicket;
  aOrder : TOrder;
  aPrice : TPriceItem2;
  dPrice : double;
  iQty : integer;
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
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, aPos.Symbol,
    iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := GetOrderSpecies;
      gEnv.Engine.TradeBroker.Send(aTicket);
      stLog := Format('Hult정리 %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_HULT, stLog);
    end;
  end;
  {
  if Position.Volume <> 0 then
  begin
    //손절.... 해주자
    if Position.Volume > 0 then
    begin
      iSide := -1;
      dPrice := TicksFromPrice( FSymbol, FSymbol.Last, 10 * iSide );
    end else
    begin
      iSide := 1;
      dPrice := TicksFromPrice( FSymbol, FSymbol.Last, 10 * iSide );
    end;

    iQty := abs(Position.Volume);
    aTicket := gEnv.Engine.TradeCore.StrategyGate.GetTicket(self);
    aOrder := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, FAccount, FSymbol,
    iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

    if aOrder <> nil then
    begin
      aOrder.OrderSpecies := GetOrderSpecies;
      gEnv.Engine.TradeBroker.Send(aTicket);

      stLog := Format('Hult정리 %s',[aOrder.Represent2]);
      gEnv.EnvLog(WIN_HULT, stLog);
    end;
  end;
  }
end;

procedure THultAxis.init(aAcnt: TAccount; aSymbol: TSymbol);
begin
  FOrders := gEnv.Engine.TradeCore.FrontOrders.New( aAcnt, aSymbol );
  FSymbol := aSymbol;
  FAccount := aACnt;
  Account := FAccount;
  MakePriceItem;
  Reset;
end;

function THultAxis.IsOrder(aPrice: TPriceItem2): boolean;
var
  idx, iRe : Integer;
begin
  Result := false;
  if aPrice.PositionType = ptLong then
    idx := abs( FBidStartIdx - aPrice.Index )
  else
    idx := abs( FAskStartIdx - aPrice.Index );
  iRe := idx mod FHultData.OrdGap;
  if iRe = 0 then
    Result := true;
end;

function THultAxis.IsRun: boolean;
begin

  if ( not FRun ) or ( FSymbol = nil ) or ( FAccount = nil ) or ( Orders = nil ) then
    Result := false
  else
    Result := true;

end;

procedure THultAxis.MakePriceItem;
var
  dPrice : double;
  i : integer;
begin
  FPriceSet.Clear;
  FPriceSet.Symbol  := FSymbol;

  dPrice := FSymbol.LimitLow;
  i := 0;

  while True do
  begin
      // add a step
    with FPriceSet.New( i ) do
    begin
      Price := dPrice;
      PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
    end;
    dPrice := TicksFromPrice(FSymbol, dPrice, 1);
    inc(i);
    if dPrice > FSymbol.LimitHigh + PRICE_EPSILON then Break;
  end;
end;

procedure THultAxis.MakeBetweenPriceItem(aOrder : TOrder);
var
  dPrice : double;
  i, iGap, iOrderCnt, iTop : integer;
  aPriceItem: TPriceItem2;
  stLog : string;
begin
  FBetweenPriceSet.Clear;
  FBetweenPriceSet.Symbol := FSymbol;
  iGap := Ceil(FHultData.OrdGap / 2);
  iOrderCnt := FHultData.SPos - FHultData.EPos;
  iTop := FHultData.OrdGap * (iOrderCnt-1);
  if iOrderCnt <= 0 then
    exit;

  if Position.Volume > 0 then  // Between 매도 ...
  begin
    dPrice := aOrder.FilledPrice;
    dPrice := TicksFromPrice(FSymbol, dPrice, iGap + iTop);
    i := 0;
    while True do
    begin
        // add a step
      aPriceItem := FBetweenPriceSet.New( i );
      aPriceItem.Price := dPrice;
      aPriceItem.PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
      dPrice := TicksFromPrice(FSymbol, dPrice, -FHultData.OrdGap);
      inc(i);
      if dPrice < FSymbol.LimitLow + PRICE_EPSILON then Break;

      stLog := Format('Create Between 매도 %s', [aPriceItem.PriceDesc]);
      gEnv.EnvLog(WIN_HULT, stLog);

    end;

    for i := iOrderCnt - 1 downto 0 do
    begin
      aPriceItem := FBetweenPriceset.PriceItem[i];
      stLog := Format('Between 매도 %.2f -> %s, Gap = %d', [aOrder.FilledPrice, aPriceItem.PriceDesc, iGap]);
      gEnv.EnvLog(WIN_HULT, stLog);
      DoBetweenOrder(aPriceItem, -1, FHultData.OrdQty);
    end;
  end else                     // Between 매수...
  begin
    dPrice := aOrder.FilledPrice;
    dPrice := TicksFromPrice(FSymbol, dPrice, -(iGap + iTop) );
    i := 0;
    while True do
    begin
        // add a step
      aPriceItem := FBetweenPriceSet.New( i );
      aPriceItem.Price := dPrice;
      aPriceItem.PriceDesc := Format('%.*n', [FSymbol.Spec.Precision, dPrice]);
      dPrice := TicksFromPrice(FSymbol, dPrice, FHultData.OrdGap);
      inc(i);
      if dPrice > FSymbol.LimitHigh + PRICE_EPSILON then Break;
      stLog := Format('Create Between 매수 %s', [aPriceItem.PriceDesc]);
      gEnv.EnvLog(WIN_HULT, stLog);
    end;

    for i := iOrderCnt - 1 downto 0 do
    begin
      aPriceItem := FBetweenPriceset.PriceItem[i];
      stLog := Format('Between 매수 %.2f -> %s, Gap = %d', [aOrder.FilledPrice, aPriceItem.PriceDesc, iGap]);
      gEnv.EnvLog(WIN_HULT, stLog);
      DoBetweenOrder(aPriceItem, 1, FHultData.OrdQty);
    end;
  end;

  if FBetweenPriceset.Count > 0 then
    FBetweenReady := true;
end;

procedure THultAxis.OnLcTimer(Sender: TObject);
begin
  if Position = nil then exit;
  if Position.Volume = 0 then
  begin
    //FLcTimer.Enabled := false;
    //FLossCut := false;
    gLog.Add( lkLossCut, '','', Format( 'LcTimer Stop :%d, %d -> %d (%d)',
        [ FRemSide, FRemNet, FRemQty,  Position.Volume ] ) );
    Exit;
  end;

  FRemQty := FRemQty + HULTLossCut( FRemSide );
  gLog.Add( lkLossCut, '','', Format( 'LcTimer Time :%d, %d -> %d',
        [ FRemSide, FRemNet, FRemQty ] ) );
end;

procedure THultAxis.Pause;
begin
  if FHultData.UsePause then
  begin
    DoBetweenCancel;
    gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );
    gEnv.EnvLog(WIN_HULT, 'Pause DoBetweenCancel, DoCancels');
  end else
  begin
    if (FOrders.AskOrders.Count = 0) or (FOrders.BidOrders.Count = 0) then
    begin
      gEnv.EnvLog(WIN_HULT, 'Pause ReSet');
      Reset;
    end;
  end;
end;

procedure THultAxis.QuoteProc(aQuote: TQuote; iDataID : integer);
begin
  if iDataID = 300 then
  begin
    DoLog;
    exit;
  end;

  if not IsRun then Exit;
  if ( FSymbol <> aQuote.Symbol ) then Exit;

  UpdateQuote( aQuote );
  if not FReady then
    DoInit( aQuote ) ;
end;

procedure THultAxis.Reset;
begin
  //FRun := false;
  FReady  := false;
  FLossCut:= false;
  FAskStartIdx  := -1;
  FBidStartIdx  := -1;
  FMyFills.Clear;
  
  FPriceSet.ReSet;

  FBetweenReady := false;
  FBetweenPriceSet.ReSet;
  FBetweenOrders.Clear;
  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FBetweenReady := false;
  FFirstPrice := 0;
end;

procedure THultAxis.SetEndIdx(aOrder: TOrder; bCancel: boolean);
var
  i, iIndex : integer;
  aPrice : TPriceItem2;
  aOrder1 : TOrder;
  stData : string;
begin
  if bCancel then
  begin
    stData := '취소';
    if aOrder.Side > 0 then
    begin
      iIndex := aOrder.PriceIdx;
      if FBidPrice.Index <> aOrder.PriceIdx then
      begin
        gEnv.EnvLog(WIN_HULT, Format('SetEndIdx 매수 Price = %d(%.1f), Order = %d(%.1f)', [FBidPrice.Index, FBidPrice.Price, aOrder.PriceIdx, aOrder.Price] ));
        exit;
      end;

      while true do
      begin
        aPrice := FPriceSet.PriceItem[iIndex];
        if aPrice = nil then break;
        if aPrice.OrderList.Count > 0 then
        begin
          aOrder1 := aPrice.OrderList[0];
          if aOrder1.Side = aOrder.Side then
          begin
            FBidPrice := aPrice;
            break;
          end else
          begin
            //FBidPrice := FPriceSet.PriceItem[aOrder1.PriceIdx - FHultData.OrdGap];
            break;
          end;
        end;
        iIndex := iIndex + FHultData.OrdGap;
      end;
    end else
    begin
      iIndex := aOrder.PriceIdx;

      if FAskPrice.Index < aOrder.PriceIdx then
      begin
        gEnv.EnvLog(WIN_HULT, Format('매도 Price = %d(%.1f), Order = %d(%.1f)', [FAskPrice.Index, FAskPrice.Price, aOrder.PriceIdx, aOrder.Price] ));
        exit;
      end;

      while true do
      begin
        aPrice := FPriceSet.PriceItem[iIndex];
        if aPrice = nil then break;
        if aPrice.OrderList.Count > 0 then
        begin
          aOrder1 := aPrice.OrderList[0];
          if aOrder1.Side = aOrder.Side then
          begin
            FAskPrice := aPrice;
            break;
          end else
          begin           //취소주문 확인이 오기전에 앞에 주문이 체결되어 깔린주문이 아무것도 없는경우
            //FAskPrice := FPriceSet.PriceItem[aOrder1.PriceIdx + FHultData.OrdGap];
            break;
          end;
        end;
        iIndex := iIndex - FHultData.OrdGap;
      end;
    end;
  end else
  begin
    stData := '신규';
    if aOrder.Side > 0 then
    begin
      if FBidPrice.Index > aOrder.PriceIdx then
        FBidPrice := FPriceSet.PriceItem[aOrder.PriceIdx];
    end else
    begin
      if FAskPrice.Index < aOrder.PriceIdx then
        FAskPrice := FPriceSet.PriceItem[aOrder.PriceIdx];
    end;
  end;

  {
  if (FBidPrice <> nil) and (FAskPrice <> nil) then
    gEnv.EnvLog( WIN_HULT,  Format('SetEndIdx :BidOrd = %d, AskOrd = %d, Index Bid = %d(%.1f), Ask = %d(%.1f), %s',
                                 [FPriceSEt.BidOrdCnt, FPriceSet.AskOrdCnt, FBidPrice.Index, FBidPrice.Price, FAskPrice.Index, FAskPrice.Price, stData])  );
                                 }
end;

function THultAxis.Start: boolean;
begin
  Result := false;
  if ( FSymbol = nil ) or ( FAccount = nil ) then Exit;
  FRun := true;

  AddPosition(FSymbol);

  if Assigned(OnResult) then
    OnResult(self, FRun);

  {gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, FSymbol,
    gEnv.Engine.QuoteBroker.DummyEventHandler);}

  gLog.Add( lkLossCut, 'THulAxis','Start', FSymbol.Code );
end;

procedure THultAxis.Stop(bLossCut : boolean);
var
  iQty, iMaxQty, iTotQty : integer;
begin
  FRun := false;

  if Assigned(OnResult) then
    OnResult(self, FRun);

  if FSymbol <> nil then
  begin
    gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, FSymbol );
    gLog.Add( lkLossCut, 'THulAxis','Stop', FSymbol.Code );
  end;
  gEnv.Engine.TradeCore.FrontOrders.DoCancels( FOrders, 0, true );

  if bLossCut then
    HULTLossCut(1);

  if FLossCut then
    if Position.Volume <> 0  then
    begin
      //gLog.Add( lkLossCut, '','', Format( 'LcTimer 시작 :%d, %d -> %d',
        //[ FRemSide, FRemNet, FRemQty ] ) );
      //FLcTimer.Enabled := true;
    end;
end;

procedure THultAxis.TradeProc(aOrder: TOrder; aPos: TPosition; iID: integer);
var
  aPrice : TPriceItem2;
  idx : integer;
  I, iQty: Integer;
  bFind, bFull, bCancel : boolean;
  stLog : string;
begin
  if not IsRun then Exit;

  if not aOrder.BetweenOrder then
  begin
    if aOrder.PriceIdx >= 0 then
    begin
      aPrice  := FPriceSet.PriceItem[aOrder.PriceIdx];
    end else
    begin
      idx := FPriceSet.Find( aOrder.Price);
      if idx >= 0 then
      begin
        aOrder.PriceIdx  := idx;
        aPrice  := FPriceSet.PriceItem[aOrder.PriceIdx];
      end;

      aOrder.OrderSpecies := GetOrderSpecies;
      if aPrice <> nil then
        aPrice.AddOrder( aOrder );
    end;

    iQty := 0;
    if (iID = ORDER_FILLED) and (Position <> nil) then
      iQty := TFill( Position.Fills.Last ).Volume;

    bFull := false;
    if aPrice <> nil then
      bFull := aPrice.OnOrder( aOrder, iQty );

    bCancel := false;
    if (iID = ORDER_CANCELED) then
      bCancel := true;

    SetEndIdx(aOrder, bCancel);

  end;

  if iID = ORDER_FILLED then begin
    gEnv.EnvLog( WIN_HULT, Format('체결 : %s ', [ aOrder.Represent2 ]));
    if not aOrder.BetweenOrder then
    begin
      DoFill( aOrder, bFull );

      if FHultData.UseBetween then
      begin
        if (not FBetweenReady) and (abs(Position.Volume) >= (FHultData.SPos * FHultData.OrdQty) ) then   // BetweenOrder 깔기....
          MakeBetweenPriceItem(aOrder);

        if (FBetweenReady) and (abs(Position.Volume) > (FHultData.EPos * FHultdata.OrdQty) ) then       // BetweenOrder 추가 깔기.....
          DoBetweenAdd(aOrder);
      end;
    end;

    if FHultData.UseBetween then
    begin
      if (abs(Position.Volume) <= ( FHultData.EPos * FHultData.OrdQty) ) and (FBetweenReady) then         // 보유잔고 체크 해서 깔린주문 취소......
        DoBetweenCancel;
    end;

  end
  else if iID = ORDER_ACCEPTED then
    gEnv.EnvLog( WIN_HULT, Format('접수 : %s ',[aOrder.Represent2 ]));
end;

procedure THultAxis.UpdateQuote(aQuote: TQuote);
var
  stTime, stTime1 : string;
  dPL : double;
begin

  if Position <> nil then
  begin
    FMinPL := Min( FMinPL, (Position.LastPL - Position.GetFee) );
    FMaxPL := Max( FMaxPL, (Position.LastPL - Position.GetFee) );
  end;

  stTime := FormatDateTime('hh:mm:ss.zzz', FHultData.LiquidTime);
  stTime1 := FormatDateTime('hh:mm:ss.zzz', GetQuoteTime);
  if (FHultData.UseAutoLiquid) and (Frac(FHultData.LiquidTime) <= Frac(GetQuoteTime)) then
  begin
    if Position <> nil then
    begin
      if Position.Volume > 0 then
      begin
        FRemNet := Position.Volume;
        FRemSide := 1;
      end else
      begin
        FRemNet := abs(Position.Volume);
        FRemSide := -1;
      end;
    end;
    FLossCut := true;
    Stop;
    exit;
  end;

  if Position <> nil then
  begin
    dPL := (Position.LastPL - Position.GetFee)/10000;
    if (FHultData.UseAllCnlNStop) and (dPL <= FHultData.RiskAmt * -1 ) and (not FHultData.UsePause) then
    begin
      if Position.Volume > 0 then
      begin
        FRemNet := Position.Volume;
        FRemSide := 1;
      end else
      begin if Position.Volume < 0 then
        FRemNet := abs(Position.Volume);
        FRemSide := -1;
      end;
      FLossCut := true;
      Stop;
      exit;
    end;
  end;

  DoOrderPiece( aQuote, 1 );
  DoOrderPiece( aQuote, -1 );
end;

end.
