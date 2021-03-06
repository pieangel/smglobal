unit CleReEatTrend;

interface

uses
  Classes, SysUtils, Math, DateUtils,

  UObjectBase, UPaveConfig,

  CleSymbols, CleAccounts, ClePositions, CleQuoteBroker, CleDistributor,

  CleOrders, GleTypes, GleConsts, cleQuoteTimers, CleFrontOrder
  ;

const
  Sign_Cnt = 2;
  Sign_SAR = 0;
  Sign_DMI = 1;
  Liquid_Ocr = 100;
  PL_MAX = 0;
  PL_MIN = 1;
  PL_NOW = 2;

type
  // iDiv = 0  signal ,  idiv = 1 Position
  TEatTrendEvent = procedure( Sender : TObject; iDiv, iDir : integer ) of Object;
  TEatTrendOrderEvent =  procedure( Sender : TObject;  aData : TObject; bEntry, bAdd : boolean ) of Object;

  TRecordItem = class( TCollectionItem )
  public
    Gubun : char;  //  L : 손절, W : 청산 , B : 본전, R : 파라로 떨림..
    Qty   : integer;
    Price : double;
  end;

  TOrderRecord = class( TCollectionItem )
  public
    Time  : TDateTime;
    Side  : integer;
    AvgPrice  : double;
    PL  : array [0..1] of double;
    LossCutCount  : integer;
    ProfitCount   : integer;
    Qty   : integer;
    Index : integer;
    Records : TCollection;
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
  end;

  TBanOptOrder = class( TCollectionItem )
  public
    Order   : TOrder;
    LiqOrder: TOrder;
    LiqQty  : integer;
    LiqCnt  : integer;
  end;

  TBanOptOrders = class( TCollection )
  private
    function GetOrdered(i: Integer): TBanOptOrder;
  public

    Constructor Create;
    Destructor  Destroy; override;

    function  New( aOrder : TOrder ) : TBanOptOrder;
    procedure Del( aOrder: TOrder );

    property Ordered[i : Integer] : TBanOptOrder read GetOrdered;
  end;

  TReEatTrend = class( TTradeBase )
  private
    FLossCut : boolean;
    FLossTimerCnt : integer;

    FLossCutCount: integer;

    FEatTrendEvent: TEatTrendEvent;
    FTimer : TQuoteTimer;

    FZPDTData: TZombiPDT;
    FZState: TZPDTState;

    F1thLiqOrd : boolean;

    FZRecords: TCollection;
    FLastRec: TOrderRecord;
    FLoged  : boolean;
    FTargetPos: TPosition;
    FTargetAcnt: TAccount;
    //FOrders: TOrderList;
    FOrders: TBanOptOrders;
    FEatTrendOrderEvent: TEatTrendOrderEvent;
    FOrdPosition: TPosition;
    FOrdSymbol: TSymbol;

    procedure OnQuote( aQuote : TQuote ; iData : integer); override;
    procedure OnQuote2( aQuote : TQuote ; iData : integer);
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID ); override;
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  ); override;

    function DoOrder( iSide , iQty : integer; aQuote : TQuote ) : TOrder ;

    procedure DoLiquidOrder; overload;
    procedure DoLiquidOrder(aQuote: TQuote; iQty, iSide: integer); overload;
    procedure Reset;
    Procedure OrderReset( aOrder : TOrder );
    procedure OnLcTimer( Sender : TObject );

    function IsRun: boolean;
    procedure DoLog( stLog : string );

    function IsOrder( aQuote : TQuote ) : boolean;
    procedure Save;

    procedure SetZState(const Value: TZPDTState);
    function GetOrdQty(bLs: boolean): integer;
    function CheckCondition(aQuote: TQuote): boolean;
    function CheckCondition2(aQuote: TQuote): boolean;
    function CheckCondition3(aQuote: TQuote): boolean; // 옵션 매도일때만

    function GetEntryAmt: integer;
    function GetAmtPos( dAmt : double ) : integer;
    function CheckAddOrder(aQuote: TQuote): boolean;
    procedure SetOrdSymbol;


  public


    // 주문 방향
    OrdDir   : integer;
    // 랠리 시작을 알리는..
    OrdReady : boolean;
    // 한 랠리에서 나간 주문 카운트
    OrdCnt   : integer;
    //TotPL : array [0..2] of double;
    ChangeMaxPL : boolean;

    TargetPL, PL  : array [0..2] of double;

    OwnPL   : double;
    OpenPL  : double;


    BWrite  : boolean;

    FailCount, SuscCount,
    TotFailCount, TotSucsCount : integer;
    OrderStopTime   : TDateTime;
    PrevPL  : double;

    MaxGap  : integer;
    SaveQty : integer;

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol : TSymbol; aType : integer); override;

    function Start : boolean;

    Procedure Stop;

    procedure DoLiquid( bAll : boolean = false );

    // objects
    property TargetPos  : TPosition read FTargetPos write FTargetPos;
    property TargetAcnt : TAccount  read FTargetAcnt write FTargetAcnt;
    //property Orders     : TOrderList read FOrders write FOrders;
    property Orders : TBanOptOrders read FOrders write FOrders;

    property ZRecords :  TCollection read FZRecords;
    property LastRec  : TOrderRecord read FLastRec write FLastRec;

    property ZPDTData: TZombiPDT   read FZPDTData write FZPDTData;

    // price variable

    property LossCutCount : integer read FLossCutCount;

    property EatTrendEvent :  TEatTrendEvent read FEatTrendEvent write FEatTrendEvent;
    property EatTrendOrderEvent :  TEatTrendOrderEvent read FEatTrendOrderEvent write FEatTrendOrderEvent;
    property ZState  : TZPDTState read FZState write SetZState;

    property OrdSymbol : TSymbol read FOrdSymbol;
    property OrdPosition : TPosition read FOrdPosition;
  end;

implementation

uses
  GAppEnv, GleLib, CleKrxSymbols
  ;

{ TEatTread }


procedure TReEatTrend.OrderReset( aOrder : TOrder );
var
  aItem : TBanOptOrder;
begin
  aItem := Orders.New( aOrder );
  OrdReady    := false;
  F1thLiqOrd  := false;
  if FTargetPos <> nil then
    PrevPL      := FTargetPos.LastPL
  else
    PrevPL      := 0;

  //OpenPL      := 0;
end;

constructor TReEatTrend.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  //FOrders:= TOrderList.Create;
  FOrders:=TBanOptOrders.Create;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  Ftimer.OnTimer := OnLcTimer;
  FTimer.Interval:= 500;

  FZRecords := TCollection.Create( TOrderRecord );
end;

destructor TReEatTrend.Destroy;
begin
  if FTimer <> nil then
  begin
    FTimer.Enabled := false;
    gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  end;

  FOrders.Free;

  FZRecords.Free;
  inherited;
end;

procedure TReEatTrend.DoLiquid( bAll : boolean  );
var
  i, iQty : integer;
  pOrder , aOrder : TOrder;
  aItem : TBanOptOrder;
  bDel : boolean;
begin
  if not IsRun then Exit;

  if (FOrdPosition = nil) or (FOrdSymbol= nil) or ( FOrdPosition.Symbol.Quote = nil ) then Exit;

  iQty := abs(FOrdPosition.Volume);

  if iQty > 0 then
  begin
    if FZPDTData.UseFut then
      pOrder  := DoOrder( -OrdDir , iQty, FOrdPosition.Symbol.Quote as TQuote )
    else begin
      if FZPDTData.UseOptSell  then
        pOrder  := DoOrder( 1 , iQty, FOrdPosition.Symbol.Quote as TQuote )
      else
        pOrder  := DoOrder( -1 , iQty, FOrdPosition.Symbol.Quote as TQuote );
    end;

    if pOrder <> nil then
    begin
      if Assigned( FEatTrendOrderEvent ) then
        FEatTrendOrderEvent( Self, pOrder, false, true );
   //   FLossCut  := true;
    end;
  end;
  {
  for I := Orders.Count-1 downto 0 do
  begin
    aItem := Orders.Ordered[i];
    bDel  := false;
    if aItem.Order.State = osFilled then
    begin

      iQty := 0;
      if (aItem.LiqCnt = 0) and bAll then      // 완전 청산
      begin
        bDel := true;
        iQty := aItem.Order.FilledQty;
      end else
      if (aItem.LiqCnt > 0 ) and bAll then     // 남아 있던 물량 청산
      begin
        bDel := true;
        iQty := aItem.Order.FilledQty - aItem.LiqQty;
      end else
      if (aItem.LiqCnt = 0) and ( not bAll ) then // 부분청산
      begin
        iQty := aItem.Order.FilledQty div 2;
        inc( aItem.LiqCnt );
        aItem.LiqQty  := iQty;
      end;

      if iQty > 0 then
      begin
        pOrder  := DoOrder( -aItem.Order.Side , iQty, aItem.Order.Symbol.Quote as TQuote );
        if pOrder <> nil then
          if Assigned( FEatTrendOrderEvent ) then
            FEatTrendOrderEvent( Self, pOrder, false, true );
        if bDel then
          Orders.Delete(i);
      end;
    end;
  end;
  }
end;

procedure TReEatTrend.DoLiquidOrder;
var
  aQuote : TQuote;
  dPrice : double;
  iQty, iNet: Integer;
begin
  if not Run then Exit;

  aQuote  := Symbol.Quote as TQuote;
  iNet    := abs( Position.Volume );


end;

procedure TReEatTrend.DoLiquidOrder( aQuote : TQuote; iQty , iSide : integer );
var
  dPrice : double;
  i, iQtySum , iTmp: integer;
  aOrder : TOrder;
  stLog   : string;
begin
  dPrice  := TicksFromPrice( Symbol, aQuote.Last, 4 * iSide );
  // 매수주문 ( 매도잔고 청산)
  iQtySum := 0;
  iTmp    := iQty;
  if iSide > 0 then
  begin

    // 나머지 수량은 직접 청산
    DoOrder( 1, iQty ,  aQuote );

  end else
  // 매도주문 ( 매수잔고 청산)
  if iSide < 0 then
  begin

    DoOrder( -1, iQty , aQuote )
  end;

end;


procedure TReEatTrend.DoLog(stLog: string);
begin
  gEnv.EnvLog( WIN_ENTRY, stLog, false, Account.Code);
end;

Function TReEatTrend.DoOrder(iSide, iQty: integer; aQuote : TQuote) : TOrder ;
var
  aTicket : TOrderTicket;
  dPrice  : double;
  stErr   : string;
  bRes    : boolean;
begin

  Result := nil;

  if (Account=nil) or (Symbol=nil) or ( aQuote = nil ) or ( iQty <= 0 ) then
  begin
//    Beep;
    Exit;
  end;

  if iSide > 0 then
    dPrice := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 5 )
  else
    dPrice := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -5 );

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*n', [aQuote.Symbol.Spec.Precision, dPrice]),
    stErr );

  if (iQty = 0 ) or ( not bRes ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f - %s',  [ Account.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice, stErr ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if Result <> nil then
  begin
    Result.OrderSpecies := opPDT;
    gEnv.Engine.TradeBroker.Send(aTicket);
    DoLog( Format(' Send Order -> %s %.2f, %d', [ Result.Symbol.ShortCode, dPrice, iQty ] ));
  end;

end;

procedure TReEatTrend.init(aAcnt: TAccount; aSymbol: TSymbol; aType: integer);
begin
  inherited;
  Reset;

end;


// 준비상태 이후 극점( extrem point rule ) 상태 파악후 주문...
function TReEatTrend.IsOrder( aQuote : TQuote ): boolean;
begin
  Result := false;
  if (OrdDir = 0 ) or (not OrdReady)  then Exit;

end;

function TReEatTrend.IsRun: boolean;
begin
  if ( not Run ) or ( Symbol = nil ) or ( Account = nil )  then
    Result := false
  else
    Result := true;
end;


procedure TReEatTrend.OnLcTimer(Sender: TObject);
begin
  inc( FLossTimerCnt );
  if Position.Volume = 0 then
  begin
    FTimer.Enabled := false;

    if (Assigned( FEatTrendEvent )) then
      FEatTrendEvent( Self, 2, 0 );
  end
  else begin

    if Position.Volume > 0 then begin
      DoLiquidOrder(Symbol.Quote as TQuote, abs(Position.Volume),-1);
      DoLog( '한도 초과  타이머 매수청산 ');
    end
    else if Position.Volume < 0 then begin
      DoLiquidOrder(Symbol.Quote as TQuote, abs(Position.Volume), 1);
      DoLog( '한도 초과 타이머 매도청산 ');
    end;
  end;

  if FLossTimerCnt >= 5 then
  begin
    FTimer.Enabled := false;
    FLossTimerCnt  := 0;
  end;

end;

procedure TReEatTrend.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  if not IsRun then Exit;

  case Integer(EventID) of
    ORDER_FILLED:
      begin
        if ( aOrder.State = osFilled ) and ( aOrder.Account = Account ) then
          if Assigned( FEatTrendOrderEvent ) then
            FEatTrendOrderEvent( Self, aOrder, false, false );
          //if Assigned( FEatTrendEvent ) then
           // FEatTrendEvent( aOrder, 1, 100 );
      end;
  end;

end;

procedure TReEatTrend.OnPosition(aPosition: TPosition; EventID: TDistributorID);
var
  dPL : double;
begin
  if not IsRun then Exit;

  if Assigned( FEatTrendEvent ) then
    FEatTrendEvent( Self, 1, aPosition.Volume );
end;


procedure TReEatTrend.Save;
var
  dPL : double;
begin
  if Account = nil then
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

  Account.PL  := dPL;
  Account.IsLog := true;
end;


procedure TReEatTrend.SetZState(const Value: TZPDTState);
var
  stLog : string;
begin
  FZState := Value;

  case Value of
    zsNone: stLog     := 'none';
    zsOrder: stLog    := 'Order';
    zsPosOK: stLog    := 'PosOK';
    zsReEntry: stLog  := 'ReEntry';
    zsReEntryReady: stLog  := 'ReEntryReady';
  end;

  DoLog( Format('ZState => %s', [stLog]));

end;

function TReEatTrend.GetAmtPos(dAmt: double): integer;
var
  I: Integer;
begin
  Result := -1;

  with FZPDTData do

  for I := 0 to High( ToVal ) do
  begin
    if (FromVal[i] <= dAmt ) and ( ToVal[i] > dAmt) then
    begin
      Result := i;
//      DoLog( Format('Get Entry Amt %d th. %.0f = %.0f <= %.0f < %.0f', [ i, EntVal[i], FromVal[i] ,TargetPL[PL_MAX], ToVal[i] ]));
      break;
    end;
  end;

end;

function TReEatTrend.GetEntryAmt : integer;
var
  I: Integer;
begin
  Result := -1;

  with FZPDTData do

  for I := 0 to High( ToVal ) do
  begin
    if (FromVal[i] <= TargetPL[PL_MAX] ) and ( ToVal[i] > TargetPL[PL_MAX]) then
    begin
      Result := i;
//      DoLog( Format('Get Entry Amt %d th. %.0f = %.0f <= %.0f < %.0f', [ i, EntVal[i], FromVal[i] ,TargetPL[PL_MAX], ToVal[i] ]));
      break;
    end;
  end;

end;

function TReEatTrend.CheckAddOrder( aQuote : TQuote ) : boolean;
var
  dPL : double;
begin
  Result := false;
  // 이전 손익보다  FZPDTData.DecAmt 줄어들면..추가 주문 나간다.
  dPL := PrevPL - FTargetPos.LastPL ;
  if dPL > (FZPDTData.DecAmt * 1000 ) then
  begin
    DoLog( Format( '반옵2 %s 추가 진입  %.0f 에서  %.0f 로 더 떨어짐  ',   [
        ifThenStr( OrdDir > 0, '콜매수','풋매수'),  PrevPL / 1000, FTargetPos.LastPL /1000
      ]));
    Result   := true;
    OrdReady := true;
  end;

end;

function TReEatTrend.CheckCondition2( aQuote : TQuote ) : boolean;
var
  iMaxPos, iNowPos, i : integer;
  dPL, dResult, dMax : double;
  bMinus : boolean;
begin
  Result := false;

  if OrdCnt >= FZPDTData.OrdReCount then Exit;

  bMinus := false;

  iNowPos := GetAmtPos( TargetPL[PL_NOW] );
  iMaxPos := GetAmtPos( TargetPL[PL_MAX] );

  dMax    := 0;
  dResult := FZPDTData.EntVal[0];
  // 타켓손익이 + 일때
  if (iNowPos >= 0 ) and ( iMaxPos >= 0) then
  begin

    //if (iMaxPos > iNowPos) then
    //begin
      for I := iMaxPos downto iNowPos do
      begin
        if FZPDTData.Ordered[i] then Continue
        else break;
      end;

      if (i < 0) or (FZPDTData.Ordered[i]) then Exit;  // 0 보다 작을수는 없지만..
      {
      if i = iNowPos then
      begin    }
        if TargetPL[PL_MAX] > FZPDTData.ToVal[i] then
          dMax  := FZPDTData.ToVal[i]
        else
          dMax  := TargetPL[PL_Max];
          {
      end else
      if i > iNowPos then
      begin
        dMax  := TargetPL[PL_Max];
      end;     }
    //end;
  end else
  if ( iNowPos < 0 ) and ( iMaxPos >= 0 ) then
  begin
    // 타켓 손익이 - 일때
    i := 0;
    if not FZPDTData.Ordered[i] then
    begin
      if TargetPL[PL_MAX] > FZPDTData.ToVal[i] then
        dMax  := FZPDTData.ToVal[i]
      else
        dMax  := TargetPL[PL_MAX];
    end else
    begin
      dMax    := PrevPL / 1000;
      dResult := FZPDTData.DecAmt ;
      bMinus  := true;
    end;

  end else
  if (iNowPos < 0 ) and ( iMaxPos < 0 )  then
  begin
    // 이럴경우는 나가자마자 마이너스 되는 경우..
    //dMax := -1;
    dMax    := PrevPL / 1000;
    dResult := FZPDTData.DecAmt ;
    bMinus  := true;
    //DoLog( Format(' 모지 !!  가자마자 마이너스 되는 경우.   %.0f, %.0f ', [ TargetPL[PL_NOW], TargetPL[PL_MAX]] ));

  end;

  //if dMax < 0 then Exit;

  dPL := dMax - TargetPL[PL_NOW];

  if dPL > dResult then
  begin
    Result := true;
    if i >= 0 then
      FZPDTData.Ordered[i]  := true;
  end;

  if Result then
  begin
    // 반옵은 콜매수를 들어갔으니..풋매수를 준비한다.
    if OrdDir = 0 then
      if FTargetPos.Symbol.ShortCode[1] = '2' then
        OrdDir := -1
      else
        OrdDir := 1;

    OrdReady  := true;
    Account.Data1 := dResult;
    Account.Data2 := TargetPL[PL_MAX];
    Account.Data3 := TargetPL[PL_NOW];

   if bMinus then
    DoLog( Format( '반옵2 %s 추가 진입  %.0f 에서  %.0f 로 더 떨어짐  ',   [
        ifThenStr( OrdDir > 0, '콜매수','풋매수'),  dMax, TargetPL[PL_NOW]
       ]));
    DoLog( Format( '반옵2 %s 진입 반옵손익 고점 %.0f  dMax : %.0f 대비 현재 %.0f , 주문나간구간 %d, 현재구간 %d, 최대구간 %d  ',   [
        ifThenStr( OrdDir > 0, '콜매수','풋매수'),  TargetPL[PL_Max], dMax, TargetPL[PL_NOW],
        i, iNowPos, iMaxPos
      ]));
  end;

end;

function TReEatTrend.CheckCondition3(aQuote: TQuote): boolean;
var
  dMax , dPL, dResult : double;
begin
  Result := false;

  if OrdDir <> 0 then
    Exit;

  if OrdCnt >= FZPDTData.OrdReCount then Exit;

  // volume 이 마이너스 일수는 없다 무조건 매수니깐
  if FTargetPos.Volume <= 0 then Exit;
  if TargetPL[PL_MAX] < FZPDTData.PLAbove then Exit;

  dResult := FZPDTData.dEntryAmt;
  OwnPL   := FZPDTData.PLAmt;

  if OrdCnt = 0 then
    dPL     := TargetPL[PL_MAX] - FTargetPos.LastPL / 1000
  else if OrdCnt > 0 then
  begin
    dResult  :=  FZPDTData.PLAmt -( OrdCnt  * FZPDTData.DecAmt ) ;
    if dResult < FZPDTData.DecAmt then
      dResult  := FZPDTData.DecAmt;

    case FZPDTData.EntryMode of
      // 전저점시에만..
      0 :  dPL     := (PrevPL - FTargetPos.LastPL) / 1000;
      // 전고점에만
      1 : begin
        if not ChangeMaxPL then Exit;
         dPL     := TargetPL[PL_MAX] - FTargetPos.LastPL / 1000;
         dResult := FZPDTData.dEntryAmt;
      end;
      // 혼합
      2 : begin
        if ChangeMaxPL then begin
          dPL     := TargetPL[PL_MAX] - FTargetPos.LastPL / 1000;
          dResult := FZPDTData.dEntryAmt;
        end
        else
          dPL     := (PrevPL - FTargetPos.LastPL) / 1000;
      end;
    end;  // case ~ of

    if FZPDTData.UseFixPL then
      OwnPL := FZPDTData.PLAmt
    else
      OwnPL := dResult;
  end;

  if dPL > dResult then
  begin
    Result := true;

    DoLog( Format( 'Mode %d -> %d 번째 반옵2 진입  반옵손익 고점 %.0f 대비 현재 %.0f  목표손익 %.0f ',   [
        FZPDTData.EntryMode, OrdCnt + 1,   TargetPL[PL_Max], FTargetPos.LastPL /1000 , OwnPL
      ]));

    if OrdCnt = 0 then
    begin
      OpenPL  := TargetPL[PL_MAX];
      ChangeMaxPL := false;
    end;

    if ( OrdCnt > 0 ) and ( ChangeMaxPL ) then
    begin
      OpenPL      := TargetPL[PL_MAX];
      ChangeMaxPL := false;
    end;
  end;

  if Result then
  begin
    if FTargetPos.Symbol.ShortCode[1] = '2' then
      // 반옵은 콜매수를 들어갔으니..풋매수를 준비한다.
      OrdDir := -1
    else
      OrdDir := 1;

    OrdReady  := true;
    Account.Data1 := dResult;
    Account.Data2 := TargetPL[PL_MAX];
    Account.Data3 := FTargetPos.LastPL / 1000 ;
    //Account.Data4 := OrdCnt + 1;

    DoLog( Format( '%d 번째 반옵2 진입 반옵손익 고점 %.0f 대비 현재 %.0f  목표손익 %.0f ',   [
        OrdCnt + 1,  TargetPL[PL_Max], FTargetPos.LastPL /1000 , OwnPL
      ]));
  end;

end;

function TReEatTrend.CheckCondition( aQuote : TQuote ) : boolean;
var
  idx, idx2 : integer;
  dMax , dPL, dResult : double;
begin
  Result := false;

  if OrdDir <> 0 then
  begin
    // 재진입 회수가 0 보다 클때는..
    if (OrdCnt > 0) and ( OrdCnt < FZPDTData.OrdReCount )  then
      Result := CheckAddOrder( aQuote );
    Exit;
  end;
  // volume 이 마이너스 일수는 없다 무조건 매수니깐
  if FTargetPos.Volume <= 0 then Exit;
  // 진입 결정
  idx := -1;

  if FZPDTData.UseTerm then
  begin
    idx := GetEntryAmt;
    if idx < 0 then Exit;
    dResult := FZPDTData.EntVal[idx];
    if dResult <= 0 then Exit;
  end
  else
    dResult := FZPDTData.dEntryAmt;

  dPL     := TargetPL[PL_MAX] -FTargetPos.LastPL / 1000;
  if dPL > dResult then
    Result := true;

  if Result then
  begin
    if FTargetPos.Symbol.ShortCode[1] = '2' then
      // 반옵은 콜매수를 들어갔으니..풋매수를 준비한다.
      OrdDir := -1
    else
      OrdDir := 1;

    OrdReady  := true;
    Account.Data1 := dResult;
    Account.Data2 := TargetPL[PL_MAX];
    Account.Data3 := FTargetPos.LastPL / 1000 ;
    //Account.Data4 := abs( FTargetPos.Volume );

    //if (FZPDTData.UseSlice) and ( FZPDTData.UseTerm ) and ( idx >= 0) then
    //  FZPDTData.Ordered[idx] := true;

    DoLog( Format( '반옵2 %s 진입 반옵손익 고점 %.0f 대비 현재 %.0f  ',   [
        ifThenStr( OrdDir > 0, '콜매수','풋매수'),  TargetPL[PL_Max], FTargetPos.LastPL /1000
      ]));
  end;
end;

procedure TReEatTrend.SetOrdSymbol;
var
  aList : TList;
  aSymbol  : TSymbol;
begin
      if not FZPDTData.UseFut then  // 옵션으로
      begin
        if FZPDTData.UseOptSell then
        begin
            FOrdSymbol := FTargetPos.Symbol;
            if FOrdSymbol <> nil then
            begin
              DoLog( Format('옵션매도 반옵2 종목 선정 -> %s %.2f ', [ FOrdSymbol.ShortCode, FOrdSymbol.Last ] ));
              FOrdPosition  := gEnv.Engine.TradeCore.Positions.FindOrNew( Account, FOrdSymbol);
            end;
        end
        else begin
          try
            aList := TList.Create;
            /////////////////////////////////////////////////////////////////////////////////////////////
            if (OrdDir > 0 )  then
            begin
              gEnv.Engine.SymbolCore.GetCurCallList( FZPDTData.Below, FZPDTData.Above, 10 , aList );
              if FZPDTData.AscIdx = 0 then // 오름차순 : 가격 높은것부터 주문
              begin
                if aList.Count > 0 then
                  aSymbol := TSymbol( aList.Items[0] )
                else
                  aSymbol := nil;
              end
              else begin
                if aList.Count > 0 then
                  aSymbol := TSymbol( aList.Items[ aList.Count -1 ] )
                else
                  aSymbol := nil;
              end;
            end
            else begin
              gEnv.Engine.SymbolCore.GetCurPutList( FZPDTData.Below, FZPDTData.Above, 10 , aList );

              if FZPDTData.AscIdx = 0 then // 오름차순 : 가격 높은것부터 주문
              begin
                if aList.Count > 0 then
                  aSymbol := TSymbol( aList.Items[0] )
                else
                  aSymbol := nil;
              end
              else begin
                if aList.Count > 0 then
                  aSymbol := TSymbol( aList.Items[ aList.Count -1 ] )
                else
                  aSymbol := nil;
              end;
            end;
            /////////////////////////////////////////////////////////////////////////////////////////////
            FOrdSymbol := aSymbol;
            if FOrdSymbol <> nil then
            begin
              DoLog( Format('옵션 반옵2 종목 선정 -> %s %.2f ', [ FOrdSymbol.ShortCode, FOrdSymbol.Last ] ));
              FOrdPosition  := gEnv.Engine.TradeCore.Positions.FindOrNew( Account, FOrdSymbol);
            end;
          finally
            aList.Free;
          end;
        end; // if FZPDTData.UseOptSell
      end    // if not FZPDTData.UseFut
      else begin
        FOrdSymbol  := Symbol;
        if FOrdSymbol <> nil then
        begin
            DoLog( Format('선물 반옵2 종목 선정 -> %s %.2f ', [ FOrdSymbol.ShortCode, FOrdSymbol.Last ] ));
            FOrdPosition  := gEnv.Engine.TradeCore.Positions.FindOrNew( Account, FOrdSymbol);
        end;
      end;
end;

procedure TReEatTrend.OnQuote(aQuote: TQuote; iData : integer);
var
  bRes : boolean;
  iLiqQty, iQty, iGap, i, iCnt, iMin : integer;
  bOrder, bLiq, bAll, bProfit, bLossCut : boolean;
  dtStart, dtReset : TDateTime;
  dPL, dGap, dOpen : double;

  aList : TList;
  aPos : TPosition;
  aSymbol : TSymbol;
  aOrder  : TOrder;
begin

  Save;

  if not IsRun then Exit;

  if FTargetPos = nil then
    FTargetPos  := gEnv.Engine.TradeCore.StrategyGate.GetStrategys.Find( stBHultOpt, FTargetAcnt );

  if FTargetPos = nil then Exit;

  dPL := gEnv.Engine.TradeCore.Positions.GetPL( Account ) / 1000;

  dtStart := frac( GetQuoteTime );

  if (dtStart > Frac(FZPDTData.FstLiquidTime)) and ( not FLossCut ) then
  begin
    FLossCut  := true;
    DoLiquid( true );
  end
  else begin
    // 금액 손절 들어간다.
    if not FLossCut then
    begin

      if dPL < -FZPDTData.RiskAmt then
      begin
        DoLog( format('금액 한도 손절 : %.1f < %.1f ', [ dPL , -FZPDTData.RiskAmt ] ));
        FLossCut  := true;
        DoLiquid( true );
        Exit;
      end;
   {
      if dPL > FZPDTData.PLAmt then
      begin
        DoLog( format('금액 이익 청산 : %.1f > %.1f ', [ dPL , FZPDTData.PLAmt  ] ));
        FLossCut  := true;
        DoLiquid( true );
        Exit;
      end;
      }
    end;
  end;

  TargetPL[PL_MAX] := Max( TargetPL[PL_MAX], FTargetPos.LastPL / 1000 );
  TargetPL[PL_MIN] := Min( TargetPL[PL_MIN], FTargetPos.LastPL / 1000 );
  TargetPL[PL_NOW] := FTargetPos.LastPL / 1000;

  if ( OrdCnt > 0 ) and ( OrdDir = 0 ) and  ( not ChangeMaxPL ) and ( OpenPL < TargetPL[PL_MAX] ) and ( OpenPL > 0 ) then
    ChangeMaxPL := true;

  ///////////////////////////////////////////////////////////////////////////////////////////
  // 매수:1,  매도:-1 상태 아니면 빠져나간다..
  if FLossCut then Exit;

  if FZPDTData.UseVer2 then
  begin
    OnQuote2( aQuote, iData );
    Exit;
  end;

  {
  // 반옵손익 구간 별로 주문  사용과 주문 분할해서 나갈때
  if ( FZPDTData.UseTerm ) and ( FZPDTData.UseSlice ) then
    bOrder := CheckCondition2( aQuote )
  else
  }
  bOrder := CheckCondition( aQuote );

  if OrdDir = 0  then Exit;
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  // 주문 준비가 된 상태이면..
  if (OrdReady) and ( bOrder ) and ( OrdCnt < FZPDTData.OrdReCount ) then
  begin
    if FOrdSymbol = nil then
      SetOrdSymbol;

    if FOrdSymbol <> nil then
    begin

      if OrdCnt = 0 then
      begin
        if FZPDTData.UseTargetQty then
          iQty  := FTargetPos.Volume
        else
          iQty  := FZPDTData.InitQty;
      end
      else
        iQty  := FZPDTData.AddQty;

      if FZPDTData.UseFut then
        iQty  := iQty div 5;
      if iQTy <= 0 then iQty := 1;


      if FZPDTData.UseFut then
        aOrder  := DoOrder( OrdDir, iQty , FOrdSymbol.Quote as TQuote )
      else begin
        if (FZPDTData.UseOptSell) then
          aOrder  := DoOrder( -1, iQty , FOrdSymbol.Quote as TQuote )
        else
          aOrder  := DoOrder( 1, iQty , FOrdSymbol.Quote as TQuote );
      end;

      if aOrder <> nil then
      begin
        Account.Data4 := Account.Data4 + iQty;
        inc( OrdCnt );
        OrderReset( aOrder );
        if Assigned( FEatTrendOrderEvent ) then
          FEatTrendOrderEvent( Self, aOrder, true, true );
        DoLog( Format('%d th. pdt %s 주문 가격: %.2f, 수량: %d  ( 반헐트손익:%.0f , %.2f ) ', [
          OrdCnt, FOrdSymbol.ShortCode, aOrder.Price, aOrder.OrderQty,  FTargetPos.LastPL/ 1000, aQuote.Last
          ]));

      end;
    end;
  end;
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  if (OrdDir <> 0) and ( not OrdReady ) then
  begin

    dOpen   := gEnv.Engine.TradeCore.Positions.GetOpenPL( Account ) / 1000 ;
    OpenPL  := Max( OpenPL, dOpen );
    bLiq    := false;
    bAll    := false;
    {
    // 손익 전고점을 돌파하면 손절...
    dGap := FTargetPos.LastPL/ 1000 - PrevPL;
    if dGap > 0  then
    begin
      bLiq := true;
      bAll := true;
      DoLog( Format('손익전고점 돌파..모두 청산 %.0f ->%.0f ( 현재손익 : %.0f , %.0f ) ', [ PrevPL , FTargetPos.LastPL/ 1000, dOpen, dPL ]));
    end;

    if ( not bLiq ) and ( FTargetPos.Volume = 0 ) then  // 반옵이 손절 당함
    begin
   //   bLiq := true;
   //   bAll := true;
   //   DoLog( Format('반옵 손절....모두 청산 %.0f ->%.0f ', [ PrevPL , FTargetPos.LastPL ]));
    end;

    if (not bLiq) and ( not F1thLiqOrd ) then
    begin
      // 최소 이익 금액을 넘긴 상태에서
      // 현재 손익이 최대 손익보다 작을때
      if ( OPenPL > FZPDTData.MinProfitAmt ) and ( dOpen < OPenPL ) then
      begin
        dGap  :=  100 - ((dOpen / OpenPL) * 100);
        if dGap >= FZPDTData.LiqPer then
        begin
          bLiq        := true;
          F1thLiqOrd  := true;
          DoLog( Format('부분청산 -> 최고손익 %.0f 에서 %.0f 로 %.0f %s 빠짐', [
            OpenPL , dOpen, dGap, '%'            ]));
        end;
      end;
    end;
    }

    if bLiq then
    begin
      DoLiquid( bAll );
      if bAll then
      begin
    //    OrdDir   := 0;
    //    OrdReady := false;
      end;
    end
  end;
end;


procedure TReEatTrend.OnQuote2(aQuote: TQuote; iData: integer);
var
  bOrder, bLiq : Boolean;
  iQty   : integer;
  aOrder : TOrder;
  dTmp, dTmp2, dOpen  : double;
  aList  : TList;
  asymbol : TSymbol;

begin

  bOrder  := CheckCondition3( aQuote );

  if OrdDir = 0 then Exit;

  if (OrdDir <> 0) and ( bOrder ) and ( OrdReady ) then
  begin
    if FOrdSymbol = nil then
      SetOrdSymbol;

    if (FOrdSymbol = nil) or ( FTargetPos = nil ) then Exit;

    if FZPDTData.UseTargetQty then
      iQty  := FTargetPos.Volume
    else
      iQty  := FZPDTData.InitQty;

    aOrder  := DoOrder( -1, iQty , FOrdSymbol.Quote as TQuote )  ;

    if aOrder <> nil then
    begin
      Account.Data4 := Account.Data4 + iQty;
      inc( OrdCnt );
      OrderReset( aOrder );
      if Assigned( FEatTrendOrderEvent ) then
        FEatTrendOrderEvent( Self, aOrder, true, true );
      DoLog( Format('%d th. pdt %s 주문 가격: %.2f, 수량: %d  ( 반헐트손익:%.0f , %.2f ) ', [
        OrdCnt, FOrdSymbol.ShortCode, aOrder.Price, aOrder.OrderQty,  FTargetPos.LastPL/ 1000, aQuote.Last
        ]));
    end    ;

  end;

  // 주문 나가 있는 상황이면..
  if (OrdDir <> 0) and ( not OrdReady ) then
  begin
    dOpen   := gEnv.Engine.TradeCore.Positions.GetOpenPL( Account ) / 1000 ;

    if dOpen > 0 then
    begin
      if dOpen > OwnPL  then
      begin
        DoLog( Format('%d 번째 반옵2 %.0f(%.0f) 이익 청산  ', [ OrdCnt, dOpen, OwnPL ]));
        bLiq    := true;
        PrevPL  := FTargetPos.LastPL;
      end;
    end
    else begin
      if dOpen < -OwnPL  then
      begin
        DoLog( Format('%d 번째 반옵2 %.0f(%.0f) 손절  ', [ OrdCnt, dOpen, OwnPL ]));
        bLiq    := true;
        PrevPL  := TargetPL[PL_MIN];
      end;
    end;

    if bLiq then
    begin
      DoLiquid;
      OrdDir   := 0;
      OrdReady := false;
    end;
  end;
end;

function TReEatTrend.GetOrdQty( bLs : boolean) : integer;
var
  iCnt, iDiv, iNet : integer;
begin
{
  Result := 0;
  iNet  := abs(Position.Volume );
  if iNet <= 0 then
    Exit
  else if iNet = 1 then begin
    Result := 1;
    Exit;
  end;

  iCnt := ifThen( bLS, FZPDtData.lcCnt, FZPDtData.plCnt );
  iDiv := iCnt - ifThen( bLS, FLossCutCount, FProfitCnt );

  with FZPDtData do
  begin
    if iCnt =  0 then
      Exit
    else if iCnt = 1 then
      Result := iNet
    else begin
      if iDiv = 0 then
        Result := iNet
      else begin
        if (iCnt mod 2) = 0 then
          Result := iNet div iDiv
        else
          Result := Round( iNet / iDiv );
      end;
    end;

    if Result <= 0 then
      Result := iNet;
  end;
  }
end;


procedure TReEatTrend.Reset;
var
  I: Integer;
begin
  Run := false;
  FLossCutCount := 0;

  LastRec := nil;

  FLoged  := false;

  FZRecords.Clear;

  FOrders.Clear;


  OrdDir        := 0;

  OrdReady:= false;

  FTargetPos := nil;
  FTargetAcnt:= nil;

  PL[0] := 0;
  PL[1] := 0;
  TargetPL[0] := 0;
  TargetPL[1] := 0;
  TargetPL[2] := 0;

  OpenPL  := 0;
  OwnPL   := 0;

  BWrite  := false;

  FLossTimerCnt := 0;
  FLossCut  := false;

  FZState  := zsNone;

  FailCount := 0;
  SuscCount := 0;
  TotFailCount := 0;
  TotSucsCount := 0;
  PrevPL    := 0;
  OrderStopTime := 0;
  SaveQty   := 0;
  MaxGap    := 0;
  OrdCnt    := 0;

  FOrdPosition  := nil;
  FOrdSymbol    := nil;

  ChangeMaxPL   := false;

end;

function TReEatTrend.Start: boolean;
begin
  Result := false;
  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  Run := true;
  gEnv.Engine.QuoteBroker.Subscribe( gEnv.Engine.QuoteBroker, Symbol,  gEnv.Engine.QuoteBroker.DummyEventHandler);


  DoLog( Format('%s TEatTrend Start', [ Symbol.Code]));
  Result := true;
end;

procedure TReEatTrend.Stop;
begin
  Run := false;

  gEnv.Engine.QuoteBroker.Cancel( gEnv.Engine.QuoteBroker, Symbol );
  DoLog( Format('%s TEatTrend Stop', [ Symbol.Code]));
end;

{ TOrderRecord }

constructor TOrderRecord.Create(aColl: TCollection);
begin
  inherited;
  Records := TCollection.Create(TRecordItem);
end;

destructor TOrderRecord.Destroy;
begin
  Records.Free;
  inherited;
end;


{ TBanOptOrders }

constructor TBanOptOrders.Create;
begin
  inherited Create( TBanOptOrder );
end;

procedure TBanOptOrders.Del(aOrder: TOrder);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetOrdered(i).Order = aOrder then
    begin
      Delete(i);
      break;
    end;
end;

destructor TBanOptOrders.Destroy;
begin

  inherited;
end;

function TBanOptOrders.GetOrdered(i: Integer): TBanOptOrder;
begin
  if ( i<0 ) or ( i>=Count) then
    Result := nil
  else
    REsult := Items[i] as TBanOptOrder;
end;

function TBanOptOrders.New(aOrder: TOrder): TBanOptOrder;
begin
  Result := Add as TBanOptOrder;
  REsult.Order    := aOrder;
  Result.LiqOrder := nil;
  Result.LiqQty   := 0;
  Result.LiqCnt   := 0;
end;

end.
