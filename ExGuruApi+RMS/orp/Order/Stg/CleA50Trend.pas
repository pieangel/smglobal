unit CleA50Trend;

interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,

  GleTypes
  ;

type

  TA50Param = record
    OrdQty  : integer;
    TermCnt : integer;
    ATRMulti: integer;
    E_I : double;
    L_I : double;
    Period : integer;
    CalcCnt: integer;
    StartTime , Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;
    LiqStTime : TDateTime;
    MkStartTime : TDateTime;
    //
    Trl1P, Trl2P, GoalP : integer;
  end;

  TA50Trend = class
  private
    FSymbol: TSymbol;
    FParam: TA50Param;
    FIsFund: boolean;
    FRun: boolean;
    FFund: TFund;
    FAccount: TAccount;
    FQuote: TQuote;
    FOrders: TOrderList;
    FStarted: boolean;
    FStartOpen: double;
    FOrdSide: integer;
    FCalcedATR: boolean;
    FATR: double;

    FTermCnt: integer;
    FHL: double;
    FMH: double;
    FML: double;
    FHL2: double;
    FLossCut: boolean;
    FEntryPrice: double;
    FEntLow: double;
    FEntHigh: double;
    FEntTermCnt: integer;

    FParent: TObject;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote);
    procedure Reset( bTr : boolean = true );

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure DoOrder( aQuote : TQuote; iDir : integer ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty: integer; bLiq : boolean = false ); overload;

    function IsRun: boolean;
    function CheckOrder(aQuote: TQuote): integer;
    function CheckLossCut(aQuote: TQuote): boolean;
    function CheckLiquid(aQuote: TQuote): boolean;

    function GetPL: double;


  public

    OrderCnt  : array [TPositionType] of integer;

    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    procedure DoLiquid; overload;
    procedure DoOrder;  overload;
    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean; overload;
    function init( aFund : TFund; aSymbol : TSymbol ) : boolean; overload;
    procedure CalcHL;
    procedure DoLog( stLog : string );

    property Param : TA50Param read FParam write FParam;
    property Run   : boolean read FRun;
    property IsFund: boolean read FIsFund;

    property Symbol  : TSymbol read FSymbol;  // 최근월물..
    property Quote   : TQuote  read FQuote;   // 시세
    property Account : TAccount read FAccount;
    property Fund : TFund read FFund;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;
    property PL     : double read GetPL;
    // 상태 변수
    property CalcedATR : boolean read FCalcedATR; // 과거데이터를 통해 TR 계산 했는지
    property Started : boolean read FStarted;     // 시작시 종가 기억을 위해
    property OrdSide   : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;    // 손절여부..

    // Value 변수
    property ATR  : double read FATR;

    property TermCnt : integer read FTermCnt;
    property StartOpen : double read FStartOpen;  // 스타트 시각 시가..
    property EntryPrice: double read FEntryPrice; // 진입가격
    property EntHigh : double read FEntHigh;      // 진입이후 고가
    property EntLow  : double read FEntLow;       // 진입이후 저가
    property EntTermCnt : integer read FEntTermCnt; // 진입 이후 봉 개수..
    //

    property HL : double read FHL;    // 전일 고저차
    property HL2: double read FHL2;   // 전일 전전일 고저차의 차이
    property MH : double read FMH;    // max( 전고, 전전고 )
    property ML : double read FML;    // min( 전저, 전전저 );


  end;

implementation

uses
  GAppEnv, GleLib, GleConsts, CleKrxSymbols,

  Math ,

  FA50Trend

  ;

{ TA50Trend }

procedure TA50Trend.Reset( bTr : boolean );
begin
  FCalcedATR  := false;
  FStarted := false;
  //FStartOpen  := 0;
  FOrdSide    := 0;
  FTermCnt    := 0;
  FATr        := 0;
  FEntryPrice := 0;
  FLossCut    := false;
  FEntTermCnt := 0;
  FEntLow   := 0;
  FEntHigh  := 0;

  Orders.Clear;

end;



constructor TA50Trend.Create( aObj : TObject );
begin
  FSymbol:= nil;
  FRun:= false;
  FFund:= nil;
  FAccount:= nil;
  FQuote:= nil;

  FOrders := TOrderList.Create;

  FParent := aObj;
  OrderCnt[ptLong]  := 0;
  OrderCnt[ptShort] := 0;
end;

destructor TA50Trend.Destroy;
begin

  FOrders.Free;
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );  
  inherited;
end;

procedure TA50Trend.DoLiquid;
begin
  DoLossCut;
  Reset;
end;

procedure TA50Trend.DoLog(stLog: string);
begin
  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_TREND, stLog, false, FFund.Name);

  if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_TREND, stLog, false, Account.Code);
end;

procedure TA50Trend.DoLossCut;
var
  aOrd : TOrder;
  I: Integer;
  aQuote : TQuote;
begin

  if ( FSymbol = nil ) or ( FSymbol.Quote = nil ) then Exit;

  aQuote  := FSymbol.Quote as TQuote;

  for I := Orders.Count - 1 downto 0 do
  begin
    aOrd  := Orders.Orders[i];
    if (aOrd.Side = FOrdSide ) and ( aOrd.State = osFilled ) then
      DoOrder( aQuote , aOrd.Account, aOrd.FilledQty, true );

    Orders.Delete(i);
  end;

  FLossCut := true;
  DoLog( 'Stop 청산 완료'  );
end;

procedure TA50Trend.DoLossCut( aQuote : TQuote );
var
  aPos : TPosition;
  aOrd : TOrder;
  I: Integer;
begin

  for I := Orders.Count - 1 downto 0 do
  begin
    aOrd  := Orders.Orders[i];
    if (aOrd.Side = FOrdSide ) and ( aOrd.State = osFilled ) then
      DoOrder( aQuote , aOrd.Account, aOrd.FilledQty, true );

    Orders.Delete(i);
  end;


  FLossCut := true;
  DoLog( '청산 완료  리셋' );
  Reset( false );
end;

procedure TA50Trend.DoOrder(aQuote: TQuote; aAccount: TAccount; iQty: integer; bLiq: boolean);
var
  dPrice : double;
  stTxt  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
  iSide  : integer;
begin
  if ( aAccount = nil ) then Exit;

  if bLiq then
  begin
    // 청산시
    iSide := -FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 );
  end else
  begin
    // 신규
    iSide :=  FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );
  end;

  if ( dPrice < EPSILON ) or ( iQty < 0 ) then
  begin
    DoLog( Format(' 주문 인자 이상 : %s, %s, %d, %.2f ',  [ aAccount.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    Orders.Add( aOrder );
    if FIsFund  then aOrder.FundName := FFund.Name;
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, '청산', '신규' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '매수','매도'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;
end;

function TA50Trend.GetPL: double;
var
  I: Integer;
  aPos : TPosition;
  aItem: TFundItem;
begin
  Result := 0;
  if FIsFund then
  begin
    if FFund = nil then Exit;

    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aITem := FFund.FundItems.FundItem[i];
      aPos  := gEnv.Engine.TradeCore.Positions.Find( aItem.Account, FSymbol );
      if aPos <> nil then
        Result:= Result + aPos.LastPL;
    end;
  end else
  begin
    if FAccount = nil then Exit;

    aPos := gEnv.Engine.TradeCore.Positions.Find( FAccount, FSymbol );
    if aPos <> nil then
      Result := aPos.LastPL;
  end;
end;

procedure TA50Trend.DoOrder(aQuote : TQuote; iDir: integer);
var
  iQty, I: Integer;
  aAccount : TAccount;
  aItem : TFundItem;
begin
  FOrdSide := iDir;
  iQty     := FParam.OrdQty;
  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aItem := FFund.FundItems.FundItem[i];
      DoOrder( aQuote, aItem.Account, iQty * aItem.Multiple );
    end;
  end else
  begin
    DoOrder( aQuote, FAccount, iQty );
  end;

  if FOrdSide > 0 then
    inc( Ordercnt[ptLong] )
  else
    inc( OrderCnt[ptShort] );
end;

procedure TA50Trend.DoOrder;
begin
  DoOrder( FSymbol.Quote as TQuote, 1 );
  FStarted  := true;
  FStartOpen:= FSymbol.Last;
  FEntryPrice := FSymbol.Last;
end;

function TA50Trend.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  FIsFund := false;
  FAccount:= aAcnt;
  FSymbol := aSymbol;
  FFund   := nil;

  //FStarted := false;
  FStartOpen  := 0;
  Reset;
end;

function TA50Trend.init(aFund: TFund; aSymbol: TSymbol): boolean;
begin
  FIsFund := true;
  FAccount:= nil;
  FSymbol := aSymbol;
  FFund   := aFund;

  //FStarted := false;
  FStartOpen  := 0;

  Reset;
end;

function TA50Trend.IsRun : boolean;
begin
  if ( not Run)
    or (( FIsFund ) and ( Fund = nil ))
    or (( not FIsFund ) and ( Account = nil ))
    or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

function TA50Trend.Start: boolean;
var
  iAdd : integer;
begin
  FRun := false;
  if (( FIsFund ) and ( Symbol <> nil ) and ( Fund <> nil ))
    or
    (( not FIsFund ) and ( Symbol <> nil ) and ( Account <> nil )) then
  begin
    FRun := true;
    DoLog( Format('A50Trend Start %s ', [Symbol.Code ]) );
  end else Exit;

  Result := FRun;

  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, CHART_DATA, QuotePrc );
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc);

  // api 차트 데이타 요청 

  if FQuote <> nil then
  begin
    if  not FQuote.MakeTerm  then
    begin
      if not FQuote.CalcedPrevHL then
      begin
        if  Frac(now) <  Frac( FParam.MkStartTime) then
          iAdd := 0
        else
          iAdd  := HoursBetween( Frac(now) ,  Frac(FParam.MkStartTime) ) +1;
        // 차트 데이타 요청을 해서..전일 종가들을 구한다.
          gEnv.Engine.SendBroker.ReqChartData( FSymbol, Date, 36+iAdd, 60,'5' );
        //
      end else CalcHL;
    end else CalcHL;
  end;
end;

procedure TA50Trend.Stop;
begin
  FRun := false;
  DoLossCut;
  DoLog( 'A50Trend Stop' );
end;

procedure TA50Trend.CalcHL;
begin

  if FSymbol <> nil then
  begin
  FMH  := Max( FSymbol.PrevH[0], FSymbol.PrevH[1] );
  FML  := Min( FSymbol.PrevL[0], FSymbol.PrevL[1] );
  FHL  := FSymbol.PrevH[0] - FSymbol.PrevL[0] ;
  FHL2 := ( MH - ML ) / FParam.E_I;
  end;
end;



procedure TA50Trend.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin

  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;

  aQuote  := DataObj as TQuote;

  if DataID = CHART_DATA then
  begin
    case integer(EventID) of
      //
      CHART_60 :
        begin
         gEnv.Engine.SendBroker.ReqChartData( FSymbol, Date, 50, FParam.Period ,'5' );
         DoLog(' 60분 데이타 수신 --> 5분데이타 요청 ');
        end;
      CHART_5 , CHART_1: begin
        // 과거 차트데이타 수신후..실시간 텀데이터 만들기 ON
        DoLog(' 5분 데이타 수신 --> 실시간 텀데이터 만들기 On ');
        CalcHL;
        aQuote.MakeTerm := true;
        aQuote.Terms.Period := FParam.Period;
        if aQuote.Terms.LastTerm <> nil then
          FATR := aQuote.Terms.LastTerm.ATR;
      end;
    end;
    Exit;
  end;

  OnQuote( aQuote );

end;

function TA50Trend.CheckOrder( aQuote : TQuote ) : integer;
begin
  Result := 0;

  if aQuote.Terms.PrevTerm = nil then Exit;  

  if (aQuote.Terms.PrevTerm.C > ( FStartOpen + HL2 )) and ( OrderCnt[ptLong] = 0)  then
  begin
    Result := 1;
    DoLog( Format('매수 진입(%d) : %s -->  %s   > ( %s + %s )', [ OrderCnt[ptLong],
      aQuote.PrcToStr( aQuote.Last ), aQuote.PrcToStr( aQuote.Terms.PrevTerm.C ),
      aQuote.PrcToStr( FStartOpen ), aQuote.PrcToStr( HL2 ) ]));
  end
  else if  (aQuote.Terms.PrevTerm.C < ( FStartOpen - HL2 )) and ( OrderCnt[ptShort] = 0) then
  begin
    Result := -1    ;
    DoLog( Format('매도 진입(%d) : %s -->  %s < ( %s - %s )', [ OrderCnt[ptShort],
      aQuote.PrcToStr( aQuote.Last ), aQuote.PrcToStr( aQuote.Terms.PrevTerm.C ),
      aQuote.PrcToStr( FStartOpen ), aQuote.PrcToStr( HL2 ) ]));
  end;

  if Result <> 0 then
  begin
    FEntryPrice := aQuote.Last;
    FEntLow   := FEntryPrice;
    FEntHigh  := FEntryPrice;
  end;

end;

function TA50Trend.CheckLiquid(aQuote: TQuote): boolean;
var
  dVal : double;
  stLog: string;
  iPre : integer;
begin
  Result := false;

  if FOrdSide = 0 then Exit;

  dVal := FATR * FParam.ATRMulti  ;
  iPre := aQuote.Symbol.Spec.Precision;
  if FOrdSide > 0 then
  begin

    if aQuote.Last < (FEntHigh -  dVal) then
    begin
      Result := true;
      stLog  := Format('매수 청산 %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
          iPre, FEntHigh, iPre, dVal ]);
    end;
  end else
  begin
    if aQuote.Last > (FEntLow + dVal) then
    begin
      Result := true;
      stLog  := Format('매도 청산 %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
          iPre, FEntLow, iPre, dVal ]);
    end;
  end;

  if Result then  
    DoLog( stLog );
end;

function TA50Trend.CheckLossCut( aQuote : TQuote ) : boolean;
var
  dVal, dVal2 : double;
  stLog: string;
  iPre : integer;
begin
  Result := false;
  if FOrdSide = 0 then Exit;

  try
    ////................
    ///  손절조건 1
    dVal :=  FEntryPrice * FParam.L_I;
    iPre := aQuote.Symbol.Spec.Precision;
    if FOrdSide > 0 then
    begin
      if aQuote.Last < (FEntryPrice - dVal) then
      begin
        Result := true;
        stLog  := Format('매수 손절 %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
            iPre, FEntryPrice, iPre, dVal ]);
      end;
    end else
    begin
      if aQuote.Last > (FEntryPrice + dVal) then
      begin
        Result := true;
        stLog  := Format('매도 손절 %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
            iPre, FEntryPrice, iPre, dVal ]);
      end;
    end;

    ////............
    ///  Traiing stop
    if Result then Exit;

    if FOrdSide > 0 then
    begin
      dVal  := FEntHigh - FEntryPrice;
      dVal2 := FEntHigh - aQuote.Last;
    end
    else begin
      dVal  := FEntryPrice - FEntLow;
      dVal2 := aQuote.Last - FEntLow;
    end;

    if (dVal > FParam.Trl1P) and ( dVal2 > FParam.Trl2P ) then
    begin
      Result := true;
      stLog  := Format('%s 스탑 %.*n --> %.*n --> *.*n', [
        ifThenStr( FOrdSide > 0,'매수','매도'),
        iPre, FEntryPrice,iPre, ifthen( FOrdSide > 0 ,FEntHigh, FEntLow)
        ,iPre, aQuote.Last]);
    end;

    if Result then Exit;

    if FOrdSide > 0 then
      dVal  := aQuote.Last - FEntryPrice
    else
      dVal  := FEntryPrice - aQuote.Last;

    if (dVal > FParam.GoalP) then
    begin
      Result := true;
      stLog  := Format('%s 익절 스탑 %.*n --> %.*n --> *.*n', [
        ifThenStr( FOrdSide > 0,'매수','매도'),
        iPre, FEntryPrice,iPre, aQuote.Last]);
    end;


  finally
    if Result then DoLog( stLog );
  end;

end;

procedure TA50Trend.OnQuote( aQuote : TQuote );
var
  dtNow : TDateTime;
  bTerm , bRes: boolean;
  iDir  : integer;
begin
  dtNow := Frac( now );
  bTerm := false;

  if aQuote.AddTerm then
  begin     
    bTerm := true;
    FATR := aQuote.Terms.LastTerm.ATR;
    if FOrdSide <> 0 then
      inc(FEntTermCnt);
  end;


  if not IsRun then Exit;

  // 시작
  if dtNow < FParam.StartTime then Exit;
  
   // Stop
  if dtNow >= FParam.Endtime then
  begin
    // 청산

    TFrmA50Trend( FParent).cbRun.Checked := false;
    //FRun := false;
    Exit;
  end;

  if FLossCut then Exit;  

  if FOrdSide <> 0 then
  begin
    FEntHigh := Max( FEntHigh, aQuote.Last );
    FEntLow  := Min( FEntLow,  aQuote.Last );
  end;

  if ( not FStarted ) and ( bTerm ) then
  begin
    if aQuote.Last < DOUBLE_EPSILON then Exit;
    if aQuote.Terms.PrevTerm <> nil then
    begin
      FStarted    := true;
      FStartOpen  := aQuote.Terms.PrevTerm.C;
      DoLog( Format('시가 셋팅 %.*n', [ FSymbol.Spec.Precision, FStartOpen]));
    end;
  end;

  // 시가가 DOUBLE_EPSILON 보다 작을순 없지
  if ( not FStarted ) or ( FStartOpen < DOUBLE_EPSILON ) then
  begin
    FStarted  := false;
    Exit;
  end;

  // 진입
  if ( dtNow >= FParam.EntTime ) and ( dtNow < FParam.EntEndtime ) then

    if (bTerm) and ( FOrdSide = 0) then
    begin
      iDir := CheckOrder( aQuote );
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;

    end;

  FLossCut := CheckLossCut( aQuote );

  if FLossCut then
  begin
    DoLossCut( aQuote );
    Exit;
  end;
    // 청산시작
  if ( dtNow >= FParam.LiqStTime ) and ( FEntTermCnt > FParam.TermCnt ) then
  begin
    FLossCut := CheckLiquid( aQuote );
    if FLossCut then
    begin
      DoLossCut( aQuote );
      Exit;
    end;
  end;

end;

procedure TA50Trend.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;



end.
