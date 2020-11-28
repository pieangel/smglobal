unit CleBHultEx;

interface
uses
  Classes, SysUtils, Math, DateUtils, Dialogs,
  CleAccounts, CleSymbols, ClePositions, CleOrders, CleFills, CleFORMOrderItems,
  UObjectBase, UPaveConfig, CleQuoteTimers,  CleOrderSlots,
  CleDistributor, CleQuoteBroker, CleKrxSymbols, CleInvestorData,
  GleTypes, GleConsts, CleStrategyStore ,UOscillators, UOscillatorBase ,
  CleVirtualHult
  ;

const

  Lc_ord = '0';   // 손절   // OrderTag = -300
  Para_Liq_Ord = '3';        // OrderTag = -100

  Liq_Ord  = '2';    // OrderTag = 300
  Ent_Ord = '1';     // OrderTag = 0

type

  TjarvisEventType = ( jetLog, jetStop );
  TjarvisEvent  = procedure( Sender : TObject; jetType : TjarvisEventType; stData : string ) of object;

  TBHultEx = class(TTradeBase)
  private

    FJarvisData: TJarvisData;

    FReady : boolean;
    FLossCut : boolean;
    FLcTimer : TQuoteTimer;
    FOnPositionEvent: TObjectNotifyEvent;
    FRemSide, FRemNet, FRemQty : integer;
    FRetryCnt : integer;
    FProfitCnt  : integer;
    FLossCutCnt : integer;
    FTermCnt : integer;

    FMinPL, FMaxPL : double;
    FMinTime, FMaxTime : TDateTime;

    FStartIndex : integer;

    FLost : integer;
    FWin  : integer;
    FRemainLost : integer;
    FSuccess : boolean;
    FScreenNumber : integer;

    FOrderSlots: TBHultOrderSlots;
    FOrderItem: TOrderItem;

    //FM

    FForeingerFut: TInvestorData;
    FIsFirst: boolean;
    FPara: TParabolicSignal;

    FEntryCount: integer;
    FHult: TVirtualHult;
    FParaSymbol: TSymbol;
    FOnJarvisEvent: TjarvisEvent;
    FOrders: TOrderList;

    procedure OnLcTimer( Sender : TObject );

    procedure OnQuote( aQuote : TQuote; iData : integer ); override;
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID ); override;
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  ); override;

    procedure Reset;
    procedure OrderReset;

    procedure DoInit(aQuote : TQuote);
    function IsRun : boolean;
    procedure UpdateQuote(aQuote: TQuote);

    procedure DoFill(aOrder : TOrder);

    procedure DoLog; overload;
    procedure DoLog( stLog : string ); overload;
    procedure MakeOrderSlots(bDec: boolean = false);
    function  NewOrderSlot(i: integer) : TBHultOrderSlotItem;
    procedure UpdateOrderSlots( bDec : boolean );
    function  CheckLossCut(aQuote: TQuote): boolean;
    function  CheckReverseSignal( aQuote : TQuote ) : boolean;
    procedure OnBHultOrderEvent( dPrice : double; iSide : Integer; dDiv : char );
    procedure ReInit( dBasePrice : double );
    procedure DoReboot( bCnl : boolean = true );
    procedure Save;
    function CheckEntryCondition: integer;
    function CheckLiquid(aQuote: TQuote): boolean;
    procedure CheckOrderState(aOrder: TOrder);
    function GetLiquidQty(iSide: integer): integer;

  public

    SucCnt, FailCnt : integer;
    AMWrite : boolean;

    constructor Create(aColl: TCollection ); override;
    Destructor  Destroy; override;
    procedure init( aAcnt : TAccount; aSymbol, aParaSymbol : TSymbol);
    //procedure init2( aSymbol, aParaSymbol : TSymbol);
    function  Start : boolean;
    Procedure Stop( bCnl : boolean = true );
    procedure ApplyParam;
    procedure DoLiquid;

    procedure UpdatePara( bUse : boolean;  afVal : double; aSymbol : TSymbol );
    procedure UpdateHult( bUse : boolean;  iTick , iPos : integer );
    procedure IncOrderCount( iCnt : integer );

    property JarvisData: TJarvisData read FJarvisData write FJarvisData;
    property ParaSymbol : TSymbol read FParaSymbol write FParaSymbol;


    property LossCutCnt : integer read FLossCutCnt write FLossCutCnt;
    property OnPositionEvent :  TObjectNotifyEvent read FOnPositionEvent write FOnPositionEvent;
    property Lost : integer read FLost;
    property Win : integer read FWin;
    property RemainLost : integer read FRemainLost;
    property IsFirst    : boolean read FIsFirst write FIsFirst;
    property EntryCount : integer read FEntryCount write FEntryCount;

    property OrderSlots : TBHultOrderSlots read FOrderSlots  ;
    property OrderItem : TOrderItem read FOrderItem write FOrderItem;

    property ForeignerFut : TInvestorData read FForeingerFut write FForeingerFut;
    property Para: TParabolicSignal read FPara ;

    property Hult : TVirtualHult read FHult write FHult;
    property Orders : TOrderList read FOrders write FOrders;
    //FOscills: TOscillators;
    property OnJarvisEvent : TjarvisEvent read FOnJarvisEvent write FOnJarvisEvent;

  end;

  var
    RebootType : char;
implementation

uses
  GAppEnv, GleLib;

{ TBHultAxis }


constructor TBHultEx.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  FLcTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FLcTimer.Enabled := false;
  FLcTimer.Interval:= 1000;
  FLcTimer.OnTimer := OnLcTimer;

  FOrderSlots := TBHultOrderSlots.Create;
  FOrders     := TOrderList.Create;

  Reset;

end;

destructor TBHultEx.Destroy;
begin
  FOrders.Free;
  FLcTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FLcTimer);
  FOrderSlots.Free;
  inherited;
end;

procedure TBHultEx.DoFill(aOrder: TOrder);
var
  stLog : string;
  aQuote : TQuote;
  aFill : TFill;
  iOrdQty : integer;
begin

    aFill := Position.LastFill;
 // if aOrder.State = osFilled then
    case aOrder.OrderTag of
      0 :
        if aOrder.OrderSpecies = opNormal then
        begin
          DoLog( Format('%s 임의 청산 -> %.2f, %d ', [  SideToStr( aFill.Volume ), aFill.Price, aFill.Volume ] ));
          if Position.Volume = 0 then
          begin
            ReInit( Symbol.Last );
            DoLog( Format('ReInit %.2f', [ Symbol.Last ] ));

            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , Format('H청산 %s %.2f %d', [ ifThenStr( aFill.Volume > 0, 'L','S'),  aFill.Price, aOrder.FilledQty ])  )
          end;
        end;

      300 :
        begin
          if Position.Volume = 0 then
          begin
            DoLog( Format('%s 이익 청산 -> %.2f, %d ', [  SideToStr( aFill.Volume ), aFill.Price, aFill.Volume ] ));
            ReInit( aOrder.Price );

            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , Format('A청산 %s %.2f %d', [ ifThenStr( aFill.Volume > 0, 'L','S'),  aFill.Price, aOrder.FilledQty ])  )
          end;
        end;
      -300 :
        begin
          if Position.Volume = 0 then
          begin
            DoLog( Format('%s 손절 -> %.2f, %d ', [  SideToStr( aFill.Volume ), aFill.Price, aFill.Volume ] ));
            ReInit( FOrderSlots.BasePrice );

            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , Format('A청산 %s %.2f %d', [ ifThenStr( aFill.Volume > 0, 'L','S'),  aFill.Price, aOrder.FilledQty ])  )
          end;
        end;
      -100 :
        begin
          if Position.Volume = 0 then
          begin
            DoLog( Format('%s Para 청산 -> %.2f, %d ', [  SideToStr( aFill.Volume ), aFill.Price, aFill.Volume ] ));
            ReInit( Symbol.Last );

            if Assigned( FOnJarvisEvent ) then
              FOnJarvisEvent( Self, jetLog , Format('P청산 %s %.2f %d', [ ifThenStr( aFill.Volume > 0, 'L','S'),  aFill.Price, aOrder.FilledQty ])  )
          end;
        end;
    end;
end;

procedure TBHultEx.ReInit( dBasePrice : double );
begin
  if FJarvisData.UseAutoStop then
  begin
    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetStop , '' );
    Exit;
  end;

  FReady := false;
  FOrderSlots.Reset;
  FOrderSlots.BasePrice := dBasePrice;
  FOrderSlots.LossPrice := dBasePrice;
end;

procedure TBHultEx.DoInit(aQuote: TQuote);
var
  iSide : integer;
begin
  if (aQuote.Asks[0].Price < PRICE_EPSILON) or
     (aQuote.Bids[0].Price < PRICE_EPSILON) or
     (aQuote.Last < PRICE_EPSILON) then
  begin
    Exit;
  end;

  iSide :=  CheckEntryCondition;

  if iSide <> 0 then
  begin
    MakeOrderSlots;
    FOrderSlots.Side  := iSide;
    FReady  := true;
    inc(FEntryCount);
    FOrderSlots.PL  := gEnv.Engine.TradeCore.Positions.GetPL( Account ) / 1000;
    OrderReset;

    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog , Format('기준점 %s %.2f', [ ifThenStr( iSide > 0, 'L','S'), FOrderSlots.BasePrice ])  );
  end;
end;

function TBHultEx.CheckEntryCondition : integer;
var
  i, iVolume, iSide : integer;
  bPara : boolean;
  bCheck : array [0..3] of boolean;
  stLog : string;
begin

  Result := 0;
  //if FHult.GetVolume = 0 then Exit;

  // 외국인과 헐트잔고로 기준가를 잡는다.
  if (( FJarvisData.UseHultPos ) and ( FHult = nil )) or
     (( FJarvisData.UsePara ) and ( FPara = nil )) or
     (( FJarvisData.UseForFutQty ) and ( ForeignerFut = nil )) then Exit;

  if ( not FJarvisData.UseHultPos ) and
     ( not FJarvisData.UsePara ) and
     ( not FJarvisData.UseForFutQty )  then Exit;

  if FHult.GetVolume = 0 then Exit;

  for i := 0 to High(bCheck) do  bCheck[i] := false;

  with FJarvisData do
  begin

    iSide   := ifThen( FHult.GetVolume > 0, 1, -1 );

    // iside > 0 이면 하락중
    // iside < 0 이면 상승중

    if ( iSide < 0 ) and ( ForeignerFut.SumQty > ForFutQty ) then
      bCheck[3] := true
    else if ( iSide > 0 ) and ( ForeignerFut.SumQty < -ForFutQty ) then
      bCheck[3] := true;

    stLog := '';

    //----------------------------------------------------------------------------
    
    if UseHultPos then 
    begin
      if abs(FHult.GetVolume) >= TargetPos then
      begin
        bCheck[0] := true;      
        stLog :=  Format('Hult 잔고 %d > %d ', [  abs(FHult.GetVolume), TargetPos ]) ;
      end;
    end else
    begin
      bCheck[0]  := true;
      stLog := 'Hult 잔고 미사용';
    end;                

    //----------------------------------------------------------------------------

    if UseForFutQty then
    begin  
      if bCheck[3] then
      begin               
        stLog := stLog + '   ' +  Format('외국인 선물  %d > %d ', [  ForeignerFut.SumQty , ForFutQty ]) ;
        bCheck[1] := true;
      end;
    end else
    begin
      stLog := stLog + '   외국인선물  미사용';
      bCheck[1]  := true;
    end;

    //----------------------------------------------------------------------------

    if  UsePara then
    begin
      if ( FPara.Side <> 0 ) and ((iSide + FPara.Side ) = 0) then
      begin
        stLog := stLog + '   ' + Format('파라 신호  %s ', [ SideToStr( FPara.Side )  ]) ;
        bCheck[2] := true;
      end;
    end else
    begin
      stLog := stLog + '   파라  미사용';
      bCheck[2]  := true;
    end;
    //----------------------------------------------------------------------------
  end;

  iVolume := 0;
  
  for i := 0 to High(bCheck)-1 do
    if bCheck[i] then
      inc(iVolume );

  if iVolume = 3 then
  begin
    Result  := iSide * -1;
    DoLog( Format('%d.th 번 %s 준비 -> %s ',
          [ FEntryCount + 1, ifThenStr( Result > 0 , '매수', '매도') , stLog ]));
  end;

end;

procedure TBHultEx.DoLiquid;
begin
  if not IsRun then Exit;
  RebootType := Para_Liq_Ord;
  DoReboot;
end;

procedure TBHultEx.DoLog(stLog: string);
begin
  if Account <> nil then
    gEnv.EnvLog( WIN_BHULT, stLog, false, Account.Code);
end;

procedure TBHultEx.DoLog;
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
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FJarvisData.OrdGap] );
  end else
  begin
    stLog := Format('%s, %d, %.0f, %.0f, %.0f, %d',
                    [FormatDateTime('yyyy-mm-dd', GetQuoteTime), FJarvisData.OrdGap,
                      (Position.LastPL - Position.GetFee)/1000, FMaxPL/1000, FMinPL/1000, Position.MaxPos] );
  end;
  stFile := Format('BanHultJustOnce_%s.csv', [Account.Code]);
  gEnv.EnvLog(WIN_BHULT, stLog, true, stFile);
end;


procedure TBHultEx.ApplyParam;
begin
  FReady := false;
  //MakeOrderSlots;
end;


procedure TBHultEx.init(aAcnt: TAccount; aSymbol, aParaSymbol : TSymbol );
begin
  inherited init( aAcnt, aSymbol, integer(opJarvis) );

  FParaSymbol := aParaSymbol;

  FPara := gEnv.Engine.SymbolCore.ConsumerIndex.Paras.New( FParaSymbol, FJarvisData.AfValue );
  FHult := gEnv.Engine.VirtualTrade.GetHult( FJarvisData.TargetTick );

  Reset;
end;
                         

function TBHultEx.IsRun: boolean;
begin
  if ( not Run ) or ( Symbol = nil ) or ( Account = nil ) or
    ( FParaSymbol = nil ) or ( FHult = nil ) or ( ForeignerFut = nil )  then
    Result := false
  else
    Result := true;
end;

procedure TBHultEx.OnBHultOrderEvent(dPrice: double; iSide: Integer;
  dDiv: char);
  var
    aTicket : TOrderTicket;
    aOrder  : TOrder;
    iQty, iTag    : integer;
begin

  iTag  := 100;

  // 청산주문 플래그..전량 체결 판단을 위해
  case dDiv of
    Lc_ord,Para_Liq_Ord, Liq_Ord :
      begin
        if Position = nil then
        begin
          DoLog( Format(' 엇 !! 청산 주문을 낼려고 하는데 포지션이 없다  %s, %s', [
            Symbol.ShortCode, Account.Code ]));
          Exit;
        end;

        iQty  := abs(GetLiquidQty( Position.Volume * -1 ));

        case dDiv of
          Lc_ord       : iTag := -300;
          Para_Liq_Ord : iTag := -100;
          Liq_ord :   // 하나씩 손절..
            begin
              iTag := 300;
              if FJarvisData.OrdQty <= iQty then
                iQty := FJarvisData.OrdQty;
            end;
        end;
      end;
    Ent_Ord :  iQty  := FJarvisData.OrdQty;
    else Exit;
  end;

  if ( dPrice < PRICE_EPSILON ) or ( iQty <= 0 ) then
  begin
    DoLog( Format(' 엇 !! %s 주문 인자 이상  %.2f, %d(%d)', [
      ifThenStr( iSide > 0 , '매수','매도'),  dPrice, iQty, Position.Volume  ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self);
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, Symbol,
  iQty * iSide, pcLimit, dPrice,  tmGTC, aTicket);

  if aOrder <> nil then
  begin
    aOrder.OrderSpecies := opJarvis;
    aOrder.OrderTag := iTag;
    gEnv.Engine.TradeBroker.Send(aTicket);

    FOrders.Add( aOrder );

    case dDiv of
      Ent_Ord :
        begin
          if FJarvisData.OrdCnt > (FOrderSlots.OrdCount + 1) then
          begin
            MakeOrderSlots;
       //     if FOrderSlots.OrdCount = 1 then
       //       OrderReset;
          end;
        end;
     // Liq_Ord : MakeOrderSlots( true );
    end;

    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog , Format('%s 주문 %s %.2f %d', [
        ifThenStr( dDiv = Ent_Ord, '', '청산'),
        ifThenStr( iSide > 0, 'L','S'), aOrder.Price, aOrder.OrderQty ])  );

    DoLog( Format('Send Order(%s) : %s, %s, %s, %.2f, %d', [ dDiv, Account.Code, Symbol.ShortCode,
      ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty ]));
  end;


end;

procedure TBHultEx.OnLcTimer(Sender: TObject);
begin
end;

procedure TBHultEx.OnOrder(aOrder: TOrder; EventID: TDistributorID);
begin
  if not IsRun then Exit;
  // normal 은 손으로 털었을경우를 대비해서
  if not (aOrder.OrderSpecies in [ opNormal, opJarvis ]) then exit;

  if EventID in [ORDER_FILLED] then
    DoFill( aOrder );

  CheckOrderState( aOrder );
end;

procedure  TBHultEx.CheckOrderState( aOrder : TOrder ) ;
begin
  if aOrder.State in  [ osSrvRjt, osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
    FOrders.Remove( aOrder );
end;


function TBHultEx.CheckReverseSignal(aQuote: TQuote): boolean;
var
  iRes : integer;
begin
  Result := false;
  // 주문 안나간 상태에서 반대신호일때..
  if (Position.Volume <> 0) or ( FOrderSlots.OrdCount > 0)  then Exit;

  if FHult.GetVolume = 0 then
  begin
    Result := true;
    Exit;
  end;

  with FJarvisData do
  begin
    if ( not UseHultPos ) and ( not UseForFutQty ) and ( UsePara ) then
    begin
      // 매수로..나가있을때
      iRes := ifThen( FOrderSlots.PosType = ptLong , 1, -1 );
      // 3 가지 경우..
      if  Symbol.ShortCode[1] = '3' then
      begin
        if FParaSymbol.ShortCode[1] = '3' then
        begin
          if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) = 0 ) then
            Result := true;
        end
        else begin
          if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) <> 0 ) then
            Result := true;
        end;
      end
      else begin
        if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) = 0 ) then
          Result := true;
      end;

      if Result then
        DoLog( Format(' Para 반대신호로 ReInit %d ->  Para 신호 :%d',
          [ iRes, FPara.Side ]));
    end;
  end;
end;

function TBHultEx.GetLiquidQty( iSide : integer ) : integer;
var
  iTmp, I, iActive: Integer;
  aOrder  : TOrder;
begin

  Result := 0;
  if iSide = 0 then Exit;  

  if iSide > 0 then
    iSide := 1
  else iSide := -1;

  iActive := 0;

  for I := 0 to FOrders.Count - 1 do
  begin
    aOrder  := FOrders.Orders[i];
    if (aORder = nil ) or ( aOrder.Side <> iSide )  then Continue;

    iTmp := 0;
    case aOrder.State of
      osActive : iTmp := aOrder.ActiveQty;
      osSent, osReady, osSrvAcpt  : iTmp := aOrder.OrderQty;
      else
        Continue;
    end;

    iActive := iActive + itmp;
  end;

  if Position.Volume > 0 then
    Result := Position.Volume - iActive
  else
    Result := Position.Volume + iActive;

end;

procedure TBHultEx.OnPosition(aPosition: TPosition; EventID: TDistributorID);
begin

end;

procedure TBHultEx.OnQuote(aQuote: TQuote; iData: integer);
begin
  if iData = 300 then
  begin
    //DoLog;
    exit;
  end;

  Save;

  if ForeignerFut = nil then
    ForeignerFut := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.Find(INVEST_FORIN, 'F');

  if not IsRun then Exit;

  if ( Symbol <> aQuote.Symbol ) then Exit;

  if frac(FJarvisData.StartTime) > frac(GetQuoteTime) then
    Exit;

  if not FReady then
    DoInit( aQuote )
  else
    UpdateQuote( aQuote );
end;

procedure TBHultEx.OrderReset;
begin
  FProfitCnt  := 0;
  FLossCutCnt := 0;
  FOrders.Clear;
end;

procedure TBHultEx.Save;
var
  dPL : double;
  dtTime : TDateTime;
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

procedure TBHultEx.Reset;
begin
  Run := false;
  FReady  := false;
  FLossCut:= false;

  FRemSide := 0;
  FRemNet := 0;
  FRemQty := 0;
  FRetryCnt := 0;

  OrderReset;

  FLost := 0;
  FWin := 0;
  FRemainLost := 0;
  FSuccess := false;
  FTermCnt := 0;

  SucCnt  := 0;
  FailCnt := 0;
  FEntryCount := 0;
  AMWrite := false;

  ForeignerFut  :=  nil;
  FOrderSlots.Reset;
  FOrderItem  := nil;
  FIsFirst    := true;

  RebootType := '0';

  FOrderSlots.BHultOrderEvent := OnBHultOrderEvent;
end;

function TBHultEx.Start: boolean;
begin
  Result := false;
  if ( Symbol = nil ) or ( Account = nil ) or ( FParaSymbol = nil ) then Exit;

  Run := true;

  DoLog( Format('BHult Start %s, %d', [Symbol.Code, FJarvisData.OrdGap]) );
end;

procedure TBHultEx.Stop( bCnl : boolean = true );
begin
  Run := false;

  DoLog( Format('BHult Stop %s, %d', [Symbol.Code, FJarvisData.OrdGap]) );
  // 손절 넣자....
  RebootType := Lc_Ord;
  DoReboot( bCnl );
end;


function TBHultEx.CheckLiquid( aQuote : TQuote ) : boolean;
var
  iQty, iGap, iOrdCnt, iDiv, iSign, iPosVol : integer;
  I : Integer;
  dPrice : double;
  bLiq : boolean;
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin
  Result := false;

  //if GetLiquidQty( Position.Volume * -1 ) = 0  then Exit;
  //iPosVol := Position.Volume;

  iPosVol := GetLiquidQty( Position.Volume * -1 );
  if iPosVol = 0 then Exit;

  for I := 0 to High(JarvisData.PLTick) do
  begin

    if iPosVol = 0 then break;
    bLiq := false;

    if iPosVol > 0 then
    begin
      // 매수포지션일때
      iGap := Round(( aQuote.Last - Position.AvgPrice ) / Symbol.Spec.TickSize);

      if ( iGap > 0 ) and ( FProfitCnt < FJarvisData.PLCount ) and
         ( FJarvisData.PLTick[FProfitCnt] > 0) and  ( iGap > FJarvisData.PLTick[FProfitCnt])  then
      begin
        if i < FProfitCnt then Continue;
        bLiq := true;
        inc( FProfitCnt );
      end
      else if ( iGap < 0 ) and ( FLossCutCnt < FJarvisData.LCCount ) and
         ( FJarvisData.LCTick[FLossCutCnt] > 0) and  ( abs(iGap) > FJarvisData.LCTick[FLossCutCnt])  then
      begin
        if i < FLossCutCnt then Continue;
        bLiq := true;
        inc( FLossCutCnt );
      end;
    end
    else begin
      // 매도포지션일때
      iGap := Round(( Position.AvgPrice - aQuote.Last ) / Symbol.Spec.TickSize);

      if ( iGap > 0 ) and ( FProfitCnt < FJarvisData.PLCount ) and
         ( FJarvisData.PLTick[FProfitCnt] > 0) and  ( iGap > FJarvisData.PLTick[FProfitCnt])  then
      begin
        if i < FProfitCnt then Continue;
        bLiq := true;
        inc( FProfitCnt );
      end
      else  if ( iGap < 0 ) and ( FLossCutCnt < FJarvisData.LCCount ) and
         ( FJarvisData.LCTick[FLossCutCnt] > 0) and  ( abs(iGap) > FJarvisData.LCTick[FLossCutCnt])  then
      begin
        if i < FLossCutCnt then Continue;
        bLiq := true;
        inc( FLossCutCnt );
      end;
    end;

    if bLiq then
    begin

      iQty := 0;  dPrice := 0;   iOrdCnt := 0;
      iOrdCnt := FLossCutCnt + FProfitCnt;
      iSign := ifThen( iPosVol > 0 , -1, 1 );

      if iGap > 0 then
      begin

        if (FLossCutCnt + FProfitCnt) = FJarvisData.PLCount then //or ( FLossCutCnt > 0 ) then
          iQty  := abs(iPosVol)
        else begin
          // 위에서   FLossCutCnt or FProfitCnt 를 먼저 + 1 해준값을 마이너스 하기  때문에  +1 해준다.
          iDiv  := FJarvisData.PLCount - (FLossCutCnt + FProfitCnt) +1 ;
          if iDiv <= 0 then
            iQty := abs(iPosVol)
          else
            iQty  := abs(iPosVol) div iDiv;
        end;
      end
      else begin

        if (FLossCutCnt + FProfitCnt) = FJarvisData.LCCount then //or ( FProfitCnt > 0 ) then
          iQty  := abs(iPosVol)
        else begin
          iDiv  := FJarvisData.PLCount - (FLossCutCnt + FProfitCnt) +1;
          if iDiv <= 0 then
            iQty := abs(iPosVol )
          else
            iQty  := abs(iPosVol) div iDiv;
        end;
      end;

      if iQty <= 0 then
        iQty := abs(iPosVol);

      dPrice  := TicksFromPrice( Symbol, Symbol.Last, 5 * iSign );

      DoLog( Format('%d 번째 %s 으로 %s 자동청산  %d tick  (%.2f->%.2f, 잔고 :%d, 수량 : %d) '  ,
        [ ifThen(iGap > 0, FProfitCnt, FLossCutCnt ), ifThenStr( iGap > 0, '이익','손해'),
          SideToStr( Position.Volume ), iGap,  Position.AvgPrice, aQuote.Last, Position.Volume , iQty ]));

      if ( dPrice < 0.001 ) or ( iQty <= 0 ) then
      begin
        DoLog( Format('자동청산 주문인자 이상 %.2f, %d', [ dPrice, iQty ] ));
        Exit;
      end;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self);
      aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(gEnv.ConConfig.UserID, Account, Symbol,
          iQty * iSign, pcLimit, dPrice,  tmGTC, aTicket);

      if aOrder <> nil then
      begin
        aOrder.OrderSpecies := opJarvis;
        aOrder.OrderTag := ifThen( iGap > 0, 300, -300 );
        gEnv.Engine.TradeBroker.Send(aTicket);

        FOrders.Add( aOrder );

        if Assigned( FOnJarvisEvent ) then
          FOnJarvisEvent( Self, jetLog , Format('청산주문 %s %.2f %d', [ ifThenStr( aOrder.Side > 0, 'L','S'),  aOrder.Price, aOrder.OrderQty ])  );

        DoLog( Format('Send Order : %s, %s, %s, %.2f, %d', [  Account.Code, Symbol.ShortCode,
          ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty ]));

        if Position.Volume > 0 then
          dec( iPosVol, iQTy )
        else
          inc( iPosVol, iQty );
      end;
    end;
  end;
end;


function TBHultEx.CheckLossCut( aQuote : TQuote ) : boolean;
var
  iRes : integer;
  //iPos : integer;
begin
  Result := false;

  if ( Position.Volume = 0 ) or ( FPara = nil ) or ( FParaSymbol = nil ) then Exit;

  if ( aQuote.Bids[0].Price < PRICE_EPSILON )  or ( aQuote.Asks[0].Price < PRICE_EPSILON ) then
    Exit;

  // 매수로..나가있을때
  iRes := ifThen( Position.Volume > 0 , 1, -1 );

  // 3 가지 경우..
  if  Position.Symbol.ShortCode[1] = '3' then
  begin
    if FParaSymbol.ShortCode[1] = '3' then
    begin
      if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) = 0 ) then
        Result := true;
    end
    else begin
      if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) <> 0 ) then
        Result := true;
    end;
  end
  else begin
    if ( FPara.Side <> 0 ) and (( FPara.Side + iRes ) = 0 ) then
      Result := true;
  end;

  if Result then
    DoLog( Format(' Para 반대신호로 청산 -> 잔고: %d,  Para 신호 :%d',
      [ Position.Volume, FPara.Side ]));

end;

procedure TBHultEx.DoReboot( bCnl : boolean );
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
      dPrice  := TicksFromPrice( Symbol, Symbol.Last, 5 * iSide );
    end
    else begin
      iSide := 1;
      dPrice := TicksFromPrice( Symbol, Symbol.Last, 5 * iSide );
    end;

    OnBHultOrderEvent(dPrice, iSide, RebootType );
  end;
            {
  if FOrderItem = nil then
    FOrderItem := gEnv.Engine.FormManager.OrderItems.Find( FAccount, FSymbol);

  if FOrderItem <> nil then
    gEnv.Engine.FormManager.DoCancels( FOrderItem, 0 );
    }
end;




procedure TBHultEx.UpdateQuote(aQuote: TQuote);
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

  if (FJarvisData.UseAutoLiquid) and (Frac(FJarvisData.EndTime) <= Frac(GetQuoteTime)) then
  begin
    Stop;
    stLog := Format('청산시간 %s <= %s', [stTime, stTime1]);
    DoLog( stLog);
    exit;
  end;
  // 손절 됨..리부트 될때까지.대기
  if FOrderSlots.LossCut then Exit;

  if CheckReverseSignal( aQuote ) then
  begin

    ReInit( Symbol.Last );
    DoLog( Format('ReInit %.2f', [ aQuote.Last ] ));

    if Assigned( FOnJarvisEvent ) then
      FOnJarvisEvent( Self, jetLog ,  Format('반대신호로 재시작  %.2f ', [ aQuote.Last ])  );
    Exit;

  end;

  // 파라 반대신호로 청산..
  if ( FJarvisData.UseParaLiquid ) and CheckLossCut(aQuote ) then
  begin
    RebootType := Para_Liq_Ord;
    DoReboot;
    FOrderSlots.LossCut := true;
    Exit;
  end;

  // 자동청산
  if ( FJarvisData.UseAutoLiquid ) and CheckLiquid( aQuote ) then
  begin
    Exit;
  end;

  FOrderSlots.OnQuote( aQuote );
end;

/////////

procedure TBHultEx.IncOrderCount(iCnt: integer);
//var
//  I: Integer;
begin
  //
  {
  if ( FOrderSlots.Count = 0 ) or ( FOrderSlots.LastSlot = nil ) then Exit;

  if FOrderSlots.LastSlot.Price[ptLong]  then
  

  for I := 0 to iCnt - 1 do
  begin

  end;
  }
end;

procedure TBHultEx.MakeOrderSlots(bDec: boolean);
var
  iCnt ,i, iTmp, j: Integer;
  aSlot : TBHultOrderSlotItem;
begin
  if Symbol = nil  then Exit;

  if bDec  then
    iCnt  := FOrderSlots.Count -1
  else
    iCnt  := FOrderSlots.Count + 1;
  iTmp  := FOrderSlots.Count;

  if (FOrderSlots.Count > iCnt) and ( iCnt >=0 ) then
  begin
    J := 0;

    // 청산슬롯은 빼면 안되기에
    for I := FOrderSlots.Count - 1 downto iCnt  do
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
    if (FOrderSlots.Count = 0) then
    begin
      FOrderSlots.BasePrice := Symbol.Last;
      FOrderSlots.LossPrice := FOrderSlots.BasePrice;
      FOrderSlots.IsFirst   := false;
    end;

    for I := FOrderSlots.Count to iCnt - 1 do
    begin
      aSlot := NewOrderSlot( i );
    end;

    UpdateOrderSlots( bDec );
  end;

  DoLog( Format(' Make Order Slot : %d -> %d ) MaxOrdCnt : %d ',
    [ iTmp , FOrderSlots.Count,  FOrderSlots.MaxOrdCnt ]));

  // debug //
  for I := 0 to FOrderSlots.Count - 1 do
  begin
    aSlot := FOrderSlots.HultOrderSlot[i];
    DoLog( Format('%d %.2f(%.2f) [%s | %s ] [ %s | %s ]', [ i, FOrderSlots.BasePrice,
      FOrderSlots.LossPrice,
      aSlot.PriceStr[ptLong], aSlot.PriceStr[ptShort],
      ifThenStr( aSlot.OrderDiv[ptLong]  = Ent_Ord, '일반','청산'),
      ifThenStr( aSlot.OrderDiv[ptShort] = Ent_Ord, '일반','청산') ]));

  end;
end;

function TBHultEx.NewOrderSlot(i : integer)  : TBHultOrderSlotItem;
begin

  Result := FOrderSlots.Insert(i) as TBHultOrderSlotItem;
  Result.index := i;

  if i = 0  then
  begin
    Result.Price[ptLong]  := TicksFromPrice( Symbol, FOrderSlots.BasePrice, FJarvisData.OrdGap  );
    Result.Price[ptShort] := TicksFromPrice( Symbol, FOrderSlots.BasePrice, -FJarvisData.OrdGap );
  end
  else begin
    Result.Price[ptLong]  := TicksFromPrice( Symbol, FORderSlots.LastSlot.Price[ptLong] , FJarvisData.OrdGap  );
    Result.Price[ptShort] := TicksFromPrice( Symbol, FORderSlots.LastSlot.Price[ptShort], -FJarvisData.OrdGap );
  end;

  Result.PriceStr[ptLong] := Format( '%.*n', [ Symbol.Spec.Precision, Result.Price[ptLong] ] );
  Result.PriceStr[ptShort] := Format( '%.*n', [Symbol.Spec.Precision, Result.Price[ptShort] ] );

  Result.IsOrder[ptlong]  := false;
  Result.IsOrder[ptShort]  := false;

  Result.OrderDiv[ptLong]  := Ent_Ord;
  Result.OrderDiv[ptShort] := Ent_Ord;

  FORderSlots.LastSlot  := Result;

end;



procedure TBHultEx.UpdateOrderSlots(bDec: boolean);
var
  aSlot : TBHultOrderSlotItem;
  i : integer;
  dTmp : double;
begin

  if bDec then
  begin

    aSlot := FOrderSlots.HultOrderSlot[ FOrderSlots.Count - 1 ];
    if aSlot <> nil then
    begin
      aSlot.IsOrder[ptLong] := false;
      aSlot.IsOrder[ptShort] := false;
    end;

  end  ;

  FOrderSlots.MaxOrdCnt := FOrderSlots.Count;
end;

procedure TBHultEx.UpdatePara( bUse : boolean;  afVal : double; aSymbol : TSymbol );
begin

  FPara := gEnv.Engine.SymbolCore.ConsumerIndex.Paras.New( aSymbol, FJarvisData.AfValue );
  FParaSymbol := aSymbol;

  with FJarvisData do
  begin
    UsePara := bUse;
    if bUse then
      AfValue := afVal;
  end;

end;

//        FBHultAxis.UpdateHult( UseHultPos, TargetTick, TargetPos );
procedure TBHultEx.UpdateHult( bUse : boolean;  iTick , iPos : integer );
begin
  with FJarvisData do
  begin
    UseHultPos  := bUse;
    TargetPos := iPos;
    TargetTick:= iTick;

    if bUse then
      FHult := gEnv.Engine.VirtualTrade.GetHult( iTick  );
  end;
end;

end.
