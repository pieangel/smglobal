unit CleHultHedge;

interface


uses
  Classes, SysUtils, Math,

  GleTypes,

  CleSymbols, CleOrders, CleQuotebroker, CleDistributor, CleQuoteTimers,

  CleAccounts, ClePositions , CleKrxSymbols, CleInvestorData
  ;

type

  THedgeOrder = class( TCollectionItem )
  public
    Order   : TOrder;
    LiqOrder: TOrder;
    OrdDir  : integer;    // 주문 방향
    UseFut  : boolean;

    MinPrc, MaxPrc : double;
    EntryPrc : double ; // 옵션일때 사용  왜냐..선물 가격보고 청산하기땜시
    ManualQty : integer; // 수동 청산 수량..

    Constructor Create( aColl : TCollection ) ; override;
  end;

  THedgeOrders = class( TCollection )
  private
    function GetOrdered(i: Integer): THedgeOrder;
  public
    OrdCnt  : array [TPositionType] of integer;
    OptOrdCnt  : array [TPositionType] of integer;

    Constructor Create;
    Destructor  Destroy; override;

    function New( aOrder : TOrder ) : THedgeOrder;
    procedure Del( aOrder: TOrder );
    function IsOrder( iSide : integer ) : boolean;

    property Ordered[i : Integer] : THedgeOrder read GetOrdered;
  end;

  THultHedgeParam = record
    StartTime1, StartTime2, EndTime : TDateTime;
    OptQty, Qty : integer;
    E1, L1, L2, LC : double;
    ConPlus : double;    // 고/저점 대비 플러스 조건
    Run : boolean;

    UseFut, UseOpt : boolean;
    dBelow, dAbove : double;
    OptCnt : integer;
    AscIdx : integer; // 0 : 오름차순  , 1 : 내림차순
  end;

  THultHedgeItem = class( TCollectionItem )
  private
    FRun: boolean;
    FSymbol: TSymbol;
    FParam: THultHedgeParam;
    FAccount: TAccount;
    FHedgeOrders: THedgeOrders;
    FNo: integer;
    FOrdDir : integer;
    FEntryCnt: integer;
    function IsRun : boolean;
    procedure Reset ;
    procedure OnQuote(aQuote: TQuote);
    function CheckSide(aQuote: TQuote): integer;

    procedure DoLog( stLog : string );
    procedure NewOrder( iSide : integer; aQuote : TQuote );
    function DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
    procedure CheckLiquid(aQuote: TQuote; bTerm: boolean);
    function CheckLiquid2(aH: THedgeOrder; aQuote: TQuote;
      bTerm: boolean): boolean;

  public
    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;
    function Start : boolean;
    Procedure Stop;

    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Account : TAccount read FAccount;
    property Param   : THultHedgeParam read FParam write FParam;
    property No : integer read FNo write FNo;
    property EntryCnt : integer read FEntryCnt write FEntryCnt;

    property HedgeOrders : THedgeOrders read FHedgeOrders;
  end;

  THultHedgeItems = class( TCollection )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    function GetHedgeItem(i: Integer): THultHedgeItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;

    function New( iNo : integer ) : THultHedgeItem;

    property HedgeItem[i : Integer] : THultHedgeItem read GetHedgeItem;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Account : TAccount read FAccount write FAccount;
  end;

implementation

uses
  GAppEnv, GleLib,
  Ticks
  ;

{ THultHedgeItem }

constructor THultHedgeItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FHedgeOrders:= THedgeOrders.Create;
  FRun    := false;
  FSymbol := nil;
  FAccount:=nil;
  FNo := -1;
  FOrdDir := 0;
  FEntryCnt := 0;
end;

destructor THultHedgeItem.Destroy;
begin
  FHedgeOrders.Free;
  inherited;
end;


procedure THultHedgeItem.DoLog(stLog: string);
begin
  if FAccount <> nil then
    gEnv.EnvLog( WIN_ENTRY, stLog, false,
      Format('HultHedge_%s', [ Account.Code]) );
end;

function THultHedgeItem.DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
var
  aTicket : TOrderTicket;
  dPrice  : double;
  stErr   : string;
  bRes    : boolean;
begin
  Result := nil;

  if aQuote = nil then Exit;  

  if iSide > 0 then
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
  else
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );

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
    Result.OrderSpecies := opTrend2;
    //if Result.Symbol.ShortCode[1] = '1' then
    //  DoLog( Format('주문 만든 시간 %s ', [ FormatDateTime( 'hh:nn:ss.zzz', Result.SentTime ) ]));
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;

end;

function THultHedgeItem.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  Result := false;
  if (aAcnt = nil) or ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FAccount  := aAcnt;

  Result := true;
  Reset;
end;

function THultHedgeItem.IsRun: boolean;
begin
  if ( not FRun) or  (FAccount = nil) or ( FSymbol = nil ) or ( not FParam.Run ) then
    Result := false
  else
    Result := true;
end;

procedure THultHedgeItem.NewOrder(iSide: integer; aQuote: TQuote);
var
  aOrder : TOrder;
  aItem : THedgeOrder;
  aList : TList;
  I, iCnt: Integer;
  aSymbol : TSymbol;
  bOrdered: boolean;
begin

  bOrdered  := false;

  if FParam.UseFut then
  begin
    aOrder  := DoOrder( FParam.Qty, iSide, aQuote );
    if aOrder <> nil then
    begin
      aItem := FHedgeOrders.New( aOrder );
      aItem.OrdDir  := iSide;
      aItem.MinPrc  := aQuote.Last;
      aItem.MaxPrc  := aQuote.Last;

      bOrdered  := true;

      DoLog( Format('%d(%d) th 추세 %s %s 주문 가격: %.2f, 수량: %d  ( 시가:%.2f > 현재가:%.2f ) ', [
        //FHedgeOrders.Count,
        FEntryCnt, FNo, aQuote.Symbol.ShortCode,
        ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
        FSymbol.DayOpen, aQuote.Last
        ]));
    end;
  end;

  if FParam.UseOpt then
  begin

    {
      행사가 내림차순으로 정렬되어 있음.. 높은거부터 낼려면
      풋은 루프초기값을  Count-1 , 콜은 0 부터..하면됨
    }

    try
      aList := TList.Create;
      if iSide > 0 then
      begin
        gEnv.Engine.SymbolCore.GetCurCallList( FParam.dBelow, FParam.dAbove, 10 , aList );

        if FParam.AscIdx = 0 then // 오름차순 : 가격 높은것부터 주문
        begin
          iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := 0 to iCnt - 1 do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;
              //
              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th 추세 %s %s 주문 가격: %.2f, 수량: %d  ( 시가:%.2f > 현재가:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;

        end
        else begin
          iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          for I := aList.Count-1 downto iCnt do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th 추세 %s %s 주문 가격: %.2f, 수량: %d  ( 시가:%.2f > 현재가:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;
        end;
      end
      else begin
        gEnv.Engine.SymbolCore.GetCurPutList( FParam.dBelow, FParam.dAbove, 10 , aList );

        if FParam.AscIdx = 0 then // 오름차순 : 가격 높은것부터 주문
        begin
          //iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := 0 to iCnt-1 do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th 추세 %s %s 주문 가격: %.2f, 수량: %d  ( 시가:%.2f > 현재가:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;
        end
        else begin
          iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          //iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := aList.Count-1 downto iCnt  do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;              

              bOrdered  := true;

              DoLog( Format('%d(%d) th 추세 %s %s 주문 가격: %.2f, 수량: %d  ( 시가:%.2f > 현재가:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;

        end;
      end;

    finally
      aList.Free;
    end;
  end;

  if bOrdered then
  begin
    FOrdDir := iSide;
    if iSide > 0 then
      FHedgeOrders.OrdCnt[ptLong] := FHedgeOrders.OrdCnt[ptLong] + 1
    else
      FHedgeOrders.OrdCnt[ptShort] := FHedgeOrders.OrdCnt[ptShort] + 1;
  end;
end;

function THultHedgeItem.CheckSide( aQuote : TQuote ) : integer;
var
  dRes : double;
begin
  Result := 0;
  dRes   := aQuote.Last - FSymbol.DayOpen;
  if abs( dRes ) > FParam.E1 then
    if dRes > 0 then
      Result := 1
    else
      Result := -1;
end;

procedure THultHedgeItem.OnQuote(aQuote: TQuote);
var
  iSide : integer;
  aOrder : TOrder;
  aItem : THedgeOrder;
begin
  if not IsRun then Exit;

  if Frac( FParam.StartTime1 ) > Frac( GetQuoteTime ) then Exit;

  try
    if FOrdDir = 0 then
    begin
      iSide := CheckSide( aQuote );
      if iSide <> 0 then
      begin

        if FEntryCnt = 0 then
        begin
          NewOrder( iSide, aQuote );
          inc(FEntryCnt );
        end
        else begin
          // 2번째 진입은 첫번째와 다른 방향 StartTime2 보다 클때..
          if ( FEntryCnt = 1) then
            if Frac( FParam.StartTime2 ) < Frac( GetQuoteTime ) then
            begin
              if ( iSide > 0 ) and ( FHedgeOrders.OrdCnt[ptLong] = 0 ) then
              // Entry
                NewOrder( iSide, aQuote )
              else if ( iSide < 0 ) and  ( FHedgeOrders.OrdCnt[ptShort] = 0 ) then
                NewOrder( iSide, aQuote );
            end;
        end;

        {
        if FHedgeOrders.Count = 0 then
        begin
          // Entry
          NewOrder( iSide, aQuote );
        end
        else begin
          // 2번째 진입은 첫번째와 다른 방향 StartTime2 보다 클때..
          if ( FHedgeOrders.Count = 1) then
            if Frac( FParam.StartTime2 ) < Frac( GetQuoteTime ) then
            begin
              if ( iSide > 0 ) and ( FHedgeOrders.OrdCnt[ptLong] = 0 ) then
              // Entry
                NewOrder( iSide, aQuote )
              else if ( iSide < 0 ) and  ( FHedgeOrders.OrdCnt[ptShort] = 0 ) then
                NewOrder( iSide, aQuote );
            end;
        end;
        }
      end;
    end
    else begin
      // 청산....
      CheckLiquid( aQuote, aQuote.AddTerm );
    end;

  except
  end;
end;

procedure THultHedgeItem.CheckLiquid( aQuote : TQuote; bTerm : boolean );
var
  iCnt, I: Integer;
  aH : THedgeOrder;
begin
  //
  for I := 0 to FHedgeOrders.Count - 1 do
  begin
    aH  := FHedgeOrders.Ordered[i];
    if aH.LiqOrder <> nil then Continue;

    if aH.Order.State = osFilled then
      CheckLiquid2( aH, aQuote, bTerm );
  end;

  // 옵션이 추가됐기 때문에..청산됐음을 알리는 조건 추가.
  iCnt := 0;
  for i := 0 to FhedgeOrders.Count - 1 do
  begin
    aH  := FHedgeOrders.Ordered[i];
    if aH.LiqOrder <> nil then
      inc( iCnt );
  end;

  if (EntryCnt > 0 ) and ( FHedgeOrders.Count > 0 ) and ( FHedgeOrders.Count = iCnt ) then
  begin
    FOrdDir := 0;
    DoLog( Format('모두 청산됨 -> %d, %d, %d', [ EntryCnt, FHedgeOrders.Count , iCnt ]));
  end;

end;

  // 청산 조건
  // 이익 청산
  // 1. 고저 대비 L1 이상 차이날때
  // 2. 1.8 P  이익을 청산
  // 3. 3시에 청산
  // 손절
  // 1. 1분종가가..시가보다 높거나 낮으면 청산
  // 2. 진입 가격과 비교해. 0.8 차이날때
function THultHedgeItem.CheckLiquid2( aH : THedgeOrder; aQuote : TQuote; bTerm : boolean ) : boolean;
var
  dGap, dGap2 : double;
  aTerm :TSTermItem;
  aOrder: TOrder;
begin
  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true
  else begin

    Result := false;

    aH.MinPrc := Min( aH.MinPrc, aQuote.Last );
    aH.MaxPrc := Max( aH.MaxPrc, aQuote.Last );

    dGap := 0;
    // 매수일때 ----------------------------------------------------------------
    if aH.OrdDir > 0 then
    begin
      // 이익
      if FSymbol.DayOpen < aQuote.Last then
      begin
        dGap  := aH.MaxPrc - aQuote.Last;
        // 1번 조건
        if dGap > FParam.L1 then begin
          // 고점대비 FParam.L1 내려왔다
          // 고점은 최소 FParam.ConPlus 만큼 올라가야 한다.
          if ( FSymbol.DayOpen + FParam.ConPlus + FParam.E1 ) <= aH.MaxPrc  then
          begin
            Result := true;
            DoLog( Format('매수 이익 청산 ->  고점 %.2f 대비 현재가 %.2f  %.2f(%.2f) 포인트 하락',  [
              aH.MaxPrc, aQuote.Last, dGap, FParam.L1    ]));
          end;
        end;
        // 2번 조건
        if (not Result)  then
        begin
          //dGap  := aQuote.Last - ( FSymbol.DayOpen + FParam.E1 );
          if aH.UseFut then          
            dGap  := aQuote.Last - aH.Order.FilledPrice
          else
            dGap  := aQuote.Last - aH.EntryPrc;    // 옵션일때..

          if dGap > FParam.L2 then begin
            Result := true;

            if aH.UseFut then            
              DoLog( Format('매수 이익 청산 ->  진입가 %.2f 에서 시작 현재가 %.2f  %.2f(%.2f) 포인트 상승',  [
                aH.Order.FilledPrice, aQuote.Last, dGap, FParam.L2    ]))
            else
              DoLog( Format('매수 이익 청산 ->  진입가 %.2f 에서 시작 현재가 %.2f  %.2f(%.2f) 포인트 상승',  [
                aH.EntryPrc, aQuote.Last, dGap, FParam.L2    ]))
          end;
        end;
      end
      else begin
      // 손해
        if bTerm then
        begin
          aTerm := aQuote.Terms.XTerms[ aQuote.Terms.Count -2 ];
          if aTerm <> nil then
            if aTerm.C < FSymbol.DayOpen then
            begin
              Result := True;
              DoLog( Format('매수 손절 -> 시가 %.2f 에서 현재 1분 종가 %.2f( c: %.2f)  ', [
                FSymbol.DayOpen, aTerm.C, aQuote.Last ]));
            end;
        end;

        if not Result then
        begin
          dGap  := (FSymbol.DayOpen + FParam.E1 ) - aQuote.Last;
          if dGap > FParam.LC then
          begin
            Result := true;
            DoLog( Format('매수 손절 -> 진입 %.2f 에서 현재가 %.2f , %.2f(%.2f) 포인트  하학 ', [
                FSymbol.DayOpen + FParam.E1,aQuote.Last, dGap, FParam.LC ]));
          end;
        end;
      end;
    end
    else begin
    // 매도일때 ----------------------------------------------------------------
      // 이익
      if FSymbol.DayOpen > aQuote.Last then
      begin
        dGap  := aQuote.Last - aH.MinPrc;
        // 1번 조건
        if dGap > FParam.L1 then begin
          // 저점 대비 FParam.L1 올라왔다
          if ( FSymbol.DayOpen - FParam.ConPlus - FParam.E1 ) >= aH.MinPrc then
          begin
            Result := true;
            DoLog( Format('매도 이익 청산 ->  저점 %.2f 대비 현재가 %.2f  %.2f(%.2f) 포인트 상승',  [
              aH.MinPrc, aQuote.Last, dGap, FParam.L1    ]));
          end;
        end;
        // 2번 조건
        if (not Result)  then
        begin
          //dGap  := (FSymbol.DayOpen - FParam.E1) -aQuote.Last;
          if aH.UseFut then          
            dGap  := aH.Order.FilledPrice -aQuote.Last
          else
            dGap  := aH.EntryPrc - aQuote.Last;

          if dGap > FParam.L2 then begin
            Result := true;
            if aH.UseFut then            
              DoLog( Format('매도 이익 청산 ->  진입가 %.2f 에서 시작 현재가 %.2f  %.2f(%.2f) 포인트 하락',  [
                aH.Order.FilledPrice, aQuote.Last, dGap, FParam.L2    ]))
            else
              DoLog( Format('매도 이익 청산 ->  진입가 %.2f 에서 시작 현재가 %.2f  %.2f(%.2f) 포인트 하락',  [
                aH.EntryPrc, aQuote.Last, dGap, FParam.L2    ]))

          end;
        end;
      end
      else begin
      // 손해
        if bTerm then
        begin
          aTerm := aQuote.Terms.XTerms[ aQuote.Terms.Count -2 ];
          if aTerm <> nil then
            if aTerm.C > FSymbol.DayOpen then
            begin
              Result := True;
              DoLog( Format('매도 손절 -> 시가 %.2f 에서 현재 1분 종가 %.2f( c: %.2f)  ', [
                FSymbol.DayOpen, aTerm.C, aQuote.Last ]));
            end;
        end;

        if not Result then
        begin
          dGap  := aQuote.Last - (FSymbol.DayOpen - FParam.E1 );
          if dGap > FParam.LC then
          begin
            Result := true;
            DoLog( Format('도수 손절 -> 진입 %.2f 에서 현재가 %.2f , %.2f(%.2f) 포인트  상승 ', [
                FSymbol.DayOpen - FParam.E1,aQuote.Last, dGap, FParam.LC ]))
          end;
        end;
      end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aH.Order.FilledQty, -aH.Order.Side, aH.Order.Symbol.Quote as TQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s %s 청산 가격: %.2f, 수량: %d ', [  aOrder.Symbol.ShortCode,
        ifThenStr( aOrder.Side > 0, '매수','매도'), aOrder.Price, aOrder.OrderQty  ]));
      aH.OrdDir := 0;
      aH.LiqOrder := aOrder;
    end;
  end;
end;

procedure THultHedgeItem.Reset;
begin
  FOrdDir := 0;
  FHedgeOrders.Clear;
end;

function THultHedgeItem.Start: boolean;
begin
  Result := IsRun;

  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  FRun  := true;

  DoLog( format('%d Hult Hedge start ', [ FNo ]) );

end;

procedure THultHedgeItem.Stop;
begin
  FRun  := false;

  DoLog( format('%d Hult Hedge Stop ', [ FNo ]) );
end;

{ THedgeOrder }

constructor THedgeOrder.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Order   := nil;
  LiqOrder:= nil;
  OrdDir  := 0;
  ManualQty := 0;
  EntryPrc  := 0;
  UseFut    := true;
end;

{ THedgeOrders }

constructor THedgeOrders.Create;
begin
  inherited Create(  THedgeOrder );

  OrdCnt[ptLong]  := 0;
  OrdCnt[ptShort] := 0;

  OptOrdCnt[ptLong]  := 0;
  OptOrdCnt[ptShort] := 0;

end;

procedure THedgeOrders.Del(aOrder: TOrder);
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

destructor THedgeOrders.Destroy;
begin

  inherited;
end;

function THedgeOrders.GetOrdered(i: Integer): THedgeOrder;
begin
  if (i<0) or ( i>= Count) then
    Result := nil
  else
    Result := Items[i] as THedgeOrder;
end;

function THedgeOrders.IsOrder(iSide: integer): boolean;
begin
  if Count = 0 then
    Result := true
  else begin

  end;
end;

function THedgeOrders.New(aOrder: TOrder): THedgeOrder;
begin
  Result := Add as THedgeOrder;
  Result.Order  := aOrder;
  //Result.Symbol := aOrder.Symbol;
end;

{ THultHedgeItems }

constructor THultHedgeItems.Create;
begin
  inherited Create( THultHedgeItem );
  FSymbol := nil;
  FAccount:= nil;
end;

destructor THultHedgeItems.Destroy;
begin

  inherited;
end;

function THultHedgeItems.GetHedgeItem(i: Integer): THultHedgeItem;
begin
  if (i<0) or ( i>=Count )  then
    Result := nil
  else
    Result := Items[i] as THultHedgeItem;
end;

function THultHedgeItems.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
var
  i : integer;
begin
  for I := 0 to Count - 1 do
    GetHedgeItem(i).init( aAcnt, aSymbol );

  FSymbol := aSymbol;
  FAccount:= aAcnt;
end;

function THultHedgeItems.New(iNo: integer): THultHedgeItem;
begin
  Result := Add as THultHedgeItem;
  Result.No := Count;
end;

procedure THultHedgeItems.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  I: Integer;
begin
  if (Receiver <> Self ) or ( DataObj = nil ) then Exit;
  
  for I := 0 to Count - 1 do
    GetHedgeItem(i).OnQuote( DataObj as TQuote);
end;

function THultHedgeItems.Start: boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Result := GetHedgeItem(i).Start;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );
end;

procedure THultHedgeItems.Stop;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    GetHedgeItem(i).Stop;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure THultHedgeItems.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;

end.
