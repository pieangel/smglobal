unit VolatilityKOSPIIndex;

interface

uses
  Classes, SysUtils, Math, DateUtils,

  CleQuoteBroker, CleSymbols, CleMarkets, CleDistributor , CleQuoteTimers ,

  Ticks, CleCircularQueue

  ;

Const
  FM = 0;    // first month
  SM = 1;    // next month

  MAX_CNT = 5;
  DAY_SEC = 86400;
  YEAR_DAY = 365;

  TIME_INTERVAL = 1000;

type

  TParamValue = record
    CPrice  : double;
    PPrice  : double;
    CLast   : double;
    PLast   : double;
    CP  : double ;
    CP2  : double ;
    Qk  : double;
    sigma : double;
    calIv : double;
    putIv : double;
    IsCallBig: boolean;
    calDayVol: int64;
    putDayVol: int64;
  end;

  TParamValueEx = record
    Param   : TParamValue;
    Strike  : double;
  end;

  TParamArray = array of TParamValue;
  TParamExArray = array of TParamValueEx;

  TVolEvent = procedure( vol : double; idx : double ) of object;

  TVolatilityIndex = class
  private

    FOptionMarket : TOptionMarket;
    FFutureMarket : TFutureMarket;
    FTimer  : TQuoteTimer;
    FReady  : boolean;
    FInit   : boolean;

    WorkingDaysInYear: integer;

    FRemainSec : array [0..1] of double;    // 잔존시간 초단위   / 연간
    Nt         : array [0..1] of double;    // 잔존시간 초단위
    FRemainDay : array [0..1] of integer;   // 잔존일 ( 거래일 )
    ExpireDate : array [0..1] of TDateTime;
    Holiday    : array [0..1] of integer;
    FCount     : array [0..1] of integer;   // 행사가 개수
    FExpDays   : array [0..1] of integer;   // 행사가 개수

    SIndex : array [0..1] of  integer;
    K0Index: array [0..1] of integer;
    FFValue : array [0..1] of double;        // 선도지수
    FIV    : array [0..1] of double;        // 계산변동성지수
    FSigmaSum : array [0..1] of double;        // 시그마합
    FCalIV : array [0..1] of double;
    FPutIV : array [0..1] of double;

    FCalIVPerVol : array [0..1] of double;
    FPutIVPerVol : array [0..1] of double;

    Param  : array [0..1] of TParamArray;
    ParamEx  : array [0..1] of TParamExArray;
    FPlusCnt : array [0..1] of  integer;

    FCDRate    : double;
    FTimerCount: integer;
    FQuote     : TQuote;
    FSymbol    : TSymbol;
    FFrontOpt  : TOption;
    FIndex     : TSymbol;
    FvolEvent: TVolEvent;
    FUseNextMonth : boolean;

    FSum  : double;
    FCnt  : integer;
    FVal  : double;
    FvSpread: double;
    FvMASpread: double;

    function  IsReady : boolean;
    function  MonIdx( idx : integer ) : integer;
    procedure calcRemainTime(idx : integer);
    procedure calcVolatility(idx : integer); overload;
    procedure calcVolatility; overload;
    function SupplementStrike( idx :integer ) : integer;
    function GetvSpread: double;

  public

    vKospi : double;
    f0     : double;
    Q      : TCircularQueue;

    Constructor Create;
    Destructor  Destroy; override;
    procedure OnVolCalcTimer( Sender : TObject );
    procedure initSymbols;
    procedure stop;
    procedure reset;

    property volEvent :  TVolEvent read FvolEvent write FvolEvent;
    property vSpread  : double read FvSpread write FvSpread ;
    property vMASpread  : double read FvMASpread write FvMASpread ;
  end;

implementation

uses
  CalcGreeks, GAppEnv , GleLib , GleTypes,
  CleKrxSymbols, XTerms
  ;

{ TVolatilityIndex }

constructor TVolatilityIndex.Create;
begin
  FReady := false;
  FInit  := false;

  FTimerCount := 0;
  vKospi := 0;
  f0     := 0;
  FTimer := nil;

  FUseNextMonth := false;
  Q      := TCircularQueue.Create( 3600 );
end;

destructor TVolatilityIndex.Destroy;
begin
  //FTimer.Enabled := false;
  Q.Free;
  gEnv.Engine.QuoteBroker.Cancel( Self );
  Param[FM] := nil;
  Param[SM] := nil;
  inherited;
end;

function TVolatilityIndex.GetvSpread: double;
var
  aFut : TSymbol;
  dAvg, dData, dData2, dVal : double;
begin
  aFut := gEnv.Engine.SymbolCore.Futures[0];

  dData := Round( ln( FQuote.Last ) * 100) / 1000;
  dData2:= Round( ln( aFut.Last ) * 100) / 1000;

  FSum := FSum + ( dData + dData2 );
  inc(FCnt);
  dAvg  := FSum / FCnt;

  FvSpread  := (( dData + dData2 ) - dAvg ) * 100;

  Q.PushItem( GetQuoteTime, dData + dData2);
  dAvg  := Q.SumPrice / Q.Count;

  FvMASpread:= (( dData + dData2 ) - dAvg ) * 100;

  Result := FvSpread;
end;

procedure TVolatilityIndex.initSymbols;
var
  I: Integer;
  aStrike : TStrike;
  j: Integer;
begin
  Exit;
  if (gEnv.Engine.SymbolCore.OptionMarkets.Count <= 0) or
     (gEnv.Engine.SymbolCore.FutureMarkets.Count <= 0) then
     exit;

  FOptionMarket  := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];

  if ( FOptionMarket = nil ) or ( FFutureMarket = nil ) then
    exit;

  FSum  := 0;
  FCnt  := 0;
  FVal  := 0;  // vspread value

  // 변수 초기화
  for I := 0 to 2 - 1 do
  begin
    FRemainSec[i] := 0;
    FRemainDay[i] := 0;
    FFValue[i]    := 0;
    FSigmaSum[i]  := 0;
    FCount[i]     := 0;
    FIV[i]        := 0;
    FCalIV[i]     := 0;
    FPutIV[i]     := 0;

    SIndex[i]     := -1;
    K0Index[i]    := -1;
  end;

  // 만기월까지 남은 날 체크..

  i := gEnv.Engine.Holidays.GetTrdRmDays( GetQuoteDate,
    (FOptionmarket.Trees.Trees[0].Strikes.Strikes[0].Call as TOption).ExpDate );
  if i<=4 then FUseNextMonth := true;

  for i := 0 to FOptionMarket.Trees.Count - 1 do
  begin
    FCount[i] := (FOptionMarket.Trees.Trees[MonIdx(i)] as TOptionTree).Strikes.Count;
    if i >= SM then
      break;
  end;
  // 행사가 개수만큼 배열을 만듬
  for i := 0 to high(FCount) do
    if FCount[i] > 0 then
      SetLength( Param[i], FCount[i] )
    else begin
      FCount[i] := -1;
      Param[i]  := nil;
      Exit;
    end;
  FInit := true;
  // 행사가 낮은거 ---> 높은거   
  for j := 0 to 2 - 1 do
    for I := 0 to FCount[j] - 1 do
    begin
      aStrike := FOptionmarket.Trees.Trees[MonIdx(j)].Strikes.Strikes[i];

      gEnv.Engine.QuoteBroker.Subscribe( Self, aStrike.Call,
            gEnv.Engine.QuoteBroker.DummyEventHandler, spIdle );
      gEnv.Engine.QuoteBroker.Subscribe( Self, aStrike.Put,
            gEnv.Engine.QuoteBroker.DummyEventHandler, spIdle );
    end;

  gEnv.Engine.QuoteBroker.Subscribe( self,  FFutureMarket.Futures[SM],
    gEnv.Engine.QuoteBroker.DummyEventHandler, spIdle );

  FSymbol := gEnv.Engine.SymbolCore.Indexes.Find( KOSPI200_VOL_CODE);
  if FSymbol <> nil  then
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( self, FSymbol,
      gEnv.Engine.QuoteBroker.DummyEventHandler, gEnv.DB.OneMinLog,spIdle)
  else
    FQuote  := nil;

  FIndex := gEnv.Engine.SymbolCore.Symbols.FindCode( KOSPI200_CODE );

  FFrontOpt := (FOptionmarket.Trees.Trees[0].Strikes as TStrikes).Strikes[0].Call;

  if FTimer = nil then
  begin
    FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
    FTimer.Interval := TIME_INTERVAL;
    FTimer.OnTimer  := OnVolCalcTimer;
    FTimer.Enabled  := true;
  end
  else
    FTimer.Enabled  := true;
end;


function TVolatilityIndex.IsReady: boolean;
var
  aOpt : TOption;
  iHolidays : integer;
  stTmp : string;
begin
  // 거래날자로 계산한다.

  aOpt := FOptionMarket.Trees.Trees[MonIdx(FM)].Strikes.Strikes[0].Call;
  FCDRate := aOpt.CDRate;

  WorkingDaysInYear := gEnv.Engine.Holidays.GetWorkingDaysInYear( trunc( GetQuoteTime));

  FRemainDay[FM] := gEnv.Engine.Holidays.GetTrdRmDays( GetQuoteDate,  aOpt.ExpDate );
  ExpireDate[FM] := aOpt.ExpDate;
  Holiday[FM]   := gEnv.Engine.Holidays.GetHoliDays( GetQuoteDate, aOpt.ExpDate );
  FExpDays[FM]  := aOpt.DaysToExp;

  //stTmp := Format('FM : %d(%d) %s %d ', [ FRemainDay[FM], FExpDays[FM], FormatDateTime('yyyy-mm-dd', aOpt.ExpDate), Holiday[FM] ]);

  aOpt := FOptionMarket.Trees.Trees[MonIdx(SM)].Strikes.Strikes[0].Call;
  FRemainDay[SM] := gEnv.Engine.Holidays.GetTrdRmDays( GetQuoteDate,  aOpt.ExpDate );
  ExpireDate[SM] := aOpt.ExpDate;
  Holiday[SM]   := gEnv.Engine.Holidays.GetHoliDays( GetQuoteDate, aOpt.ExpDate );
  FExpDays[SM]  := aOpt.DaysToExp;

  //stTmp := stTmp + Format('  SM : %d(%d) %s %d ', [ FRemainDay[SM], FExpDays[SM], FormatDateTime('yyyy-mm-dd', aOpt.ExpDate), Holiday[SM] ]);

  //gEnv.EnvLog( WIN_TEST, stTmp  );
  result := true;
end;

function TVolatilityIndex.MonIdx(idx: integer): integer;
begin
  Result := ifThen( FUseNextMonth,  idx+1, idx );
end;

procedure TVolatilityIndex.OnVolCalcTimer(Sender: TObject);
var
  tstart, tend : TDateTime;
begin
  Exit;
  if not FInit then
  begin
    initSymbols;
    Exit;
  end;

  tstart := GetQuoteDate + EncodeTime(9,5,0,0);

  if GetQuoteTime < tstart then exit;


  if not FReady then
  begin
    inc(FTimerCount);
    if FTimerCount > MAX_CNT then
       FReady := IsReady;
  end
  else begin
    if FFrontOpt.DaysToExp = 1 then
      tend := GetQuoteDate + EncodeTime(14,50,0,0)
    else
      tend := GetQuoteDate + EncodeTime(15,0,0,0);

    if GetQuoteTime > tend then
      FTimer.Enabled := false
    else
      calcVolatility;
  end;
end;

procedure TVolatilityIndex.reset;
var
  i : integer;
begin
  FOptionMarket := nil;
  FFutureMarket := nil;

  // 변수 초기화
  for I := 0 to 2 - 1 do
  begin
    FRemainSec[i] := 0;
    FRemainDay[i] := 0;
    FFValue[i]    := 0;
    FSigmaSum[i]  := 0;
    FCount[i]     := 0;
    FIV[i]        := 0;
    FCalIV[i]     := 0;
    FPutIV[i]     := 0;

    SIndex[i]     := -1;
    K0Index[i]    := -1;
  end;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  Param[FM] := nil;
  Param[SM] := nil;

  FReady := false;
  FInit  := false;

  FTimerCount := 0;
  vKospi := 0;
  f0     := 0;
end;

procedure TVolatilityIndex.stop;
begin
  FTimer.Enabled  := false
end;

// 행사가 보충을 해야 할지..판단
function TVolatilityIndex.SupplementStrike( idx :integer ) : integer;
var
  iPlus2, iPlus : integer;
  I: Integer;
  U, V, E, C, P , W: double;
  vStrike, aStrike : TStrike;
  bPlus : boolean;
  ExpireDateTime : TDateTime;
  T, TC : double;
begin
  Result := 0;

  iPlus := max( 6 - SIndex[idx], 0 );
  iPlus2:= max( 6 - (FCount[idx] - SIndex[idx]), 0) ;

  FPlusCnt[idx] := 0;


  if iPlus > 0 then
  begin
    ParamEx[idx] := nil;
    SetLength( ParamEx[idx], iPlus );
    bPlus := false;
    Result := -1;
  end;

  if iPlus2 > 0  then
  begin
    ParamEx[idx] := nil;
    SetLength( ParamEx[idx], iPlus2 );
    iPlus := iPlus2;
    bPlus  := true;
    Result := 1;
  end;

  if iPlus > 0 then
  begin

    FPlusCnt[idx] := iPlus;

    if bPlus then
      aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[
      FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Count-1]
    else
      aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[0];
    vStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[ K0Index[idx] ];
    V := gEnv.Engine.SyncFuture.SymbolDelta(
        vStrike.Call.Quote as TQuote, Param[idx][K0Index[idx]].CPrice      );

    ExpireDateTime := GetQuoteDate + vStrike.Call.DaysToExp - 1 + EncodeTime(15,0,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);
    TC :=vStrike.Call.DaysToExp / 365;

    gEnv.EnvLog( WIN_TEST,  format('aStrike(%d) : %.2f, %.2f, %.2f',
        [ idx, aStrike.StrikePrice, aStrike.Call.Last, aStrike.Put.Last ] )    );

    for I := 1 to iPlus do
    begin
      W := 1;
      if bPlus then
      begin
        E := aStrike.StrikePrice + ( 2.5 * i );
      end
      else
        E := aStrike.StrikePrice - ( 2.5 * i );

      U := gEnv.Engine.SyncFuture.FSynFutures.Last;
      C := OptionThPrice( U, E, FCDRate, V, T , TC, 1 );
      P := Param[idx][K0Index[idx]].PPrice + ( C - Param[idx][K0Index[idx]].CPrice ) +
          ( E - vStrike.StrikePrice )* exp( -FCDRate * TC );

      ParamEx[idx][i-1].Strike  := E;
      ParamEx[idx][i-1].Param.CPrice  := C;
      ParamEx[idx][i-1].Param.PPrice  := P;
      ParamEx[idx][i-1].Param.CP := abs( C-P );
      ParamEx[idx][i-1].Param.IsCallBig := C >= P;

      gEnv.EnvLog( WIN_TEST,  format('add strike(%d) : %.2f, %.2f, %.2f',
        [ idx, E, C, P ] )    );
    end;
  end;
end;

procedure TVolatilityIndex.calcRemainTime(idx: integer);
var
  ExpireDateTime: TDateTime;
begin
  // 오늘은 산출 시점부터  .. 만기일은 15시까지 초단위로 구한다.
  // 산출시점부터 15 시까지의 시간

  ExpireDateTime := ExpireDate[idx] + EncodeTime(15,0,0,0);
  Nt[idx] := SecondsBetween( GetQuoteTime, ExpireDateTime )-(Holiday[idx] * DAY_SEC);
  FRemainSec[idx] := Nt[idx] / ( WorkingDaysInYear * (DAY_SEC ) );              // 만기까지 남은 초를 연단위로..

  //gEnv.EnvLog( WIN_TEST,
  //format('calcRemainTime(%d) = nt:%.0f, rem:%.6f, holi ', [idx, Nt[idx], FRemainSec[idx], Holiday[idx]] ));

end;

procedure TVolatilityIndex.calcVolatility;
var
  V, vv : double;
  iDay : integer;
  aTick : TTickITem;
begin

  //if gEnv.RunMode = rtSimulation then
//    Exit;

  calcVolatility(FM);
  calcVolatility(SM);
  //
  if ( FIV[FM] < 0.0011 ) or ( FIV[SM] < 0.0011 ) then
    Exit;


  if FExpDays[FM] >= 30 then begin
    V  := sqrt(FIV[FM]);
  end
  else begin
    iDay := FRemainDay[SM]-FRemainDay[FM];
    vv :=
    (
      FRemainSec[FM]*FIV[FM]*
        (
          ( Nt[SM] - (iDay*DAY_SEC) )  / (Nt[SM] - Nt[FM])
        )
        +
      FRemainSec[SM]*FIV[SM]*
        (
          ( (iDay*DAY_SEC) - Nt[FM]) / ( Nt[SM] - Nt[FM] )
        )
    )
    *(( WorkingDaysInYear  * DAY_SEC) / ( iDay* DAY_SEC) );

    V := sqrt(vv);
  end;

  vv := sqrt( FIV[FM]);

  // vKospi 에는 30일간의 미래 변동성을
  // Quote 에는 당월의 변동성을..
  vKospi := V*100;

  if Assigned( FVolEvent) then
    FVolEvent(  V*100 ,vv*100);

  if FQuote = nil then
    FQuote := gEnv.Engine.QuoteBroker.Find( KOSPI200_VOL_CODE );

  //FSyncQuote.up

  if FQuote <> nil then
  begin
    FQuote.LastEvent := qtTimeNSale;
    aTick := TTickITem( FQuote.FTicks.Add);
    aTick.T := GetQuoteTime;
    aTick.C := vv*100;
    aTick.FillVol := 0;
    aTick.AccVol  := 0;
    aTick.Side    := 1;
    FQuote.LastQuoteTime  := GetQuoteTime;
    FQuote.LastEventTime  := GetQuoteTime;

    FQuote.Change := aTick.C - FQuote.Last;
    FQuote.Last := aTick.C;
    if FQuote.High < aTick.C then
      Fquote.High := aTick.C;
    if FQuote.Low > aTick.C then
      FQuote.Low := aTick.C;

    if FQuote.FTicks.Count = 1 then
    begin
      FQuote.Open := aTick.C;
      FQuote.High := aTick.C;
      FQuote.Low  := aTick.C;
    end;

    FQuote.Symbol.Last := aTick.C;

    if FQuote.MakeTerm then FQuote.Terms.NewTick(aTick);

    GetvSpread;

    FQuote.Distributor.Distribute(FQuote, 0, FQuote, 0);
  end;
  {
  gEnv.EnvLog( WIN_SIS,
    Format('%.2f, %.2f, %.2f', [V*100,  sqrt(FIV[FM]) * 100,
      gEnv.Engine.SyncFuture.FSynFutures.Last
       ] )
  );
   }

end;


procedure TVolatilityIndex.calcVolatility(idx: integer);
var
  I, cn, pn : Integer;
  aStrike, vStrike : TStrike;
  aCal, aPut : TSymbol;
  dQkSum,dSigmaSum, dTmp, dv, k, dCalSigmaSum, dPutSigmaSum,
  dTmp2, dTmp3, dv2,dv3, dCalSigmaSum2, dPutSigmaSum2 : double;
  stTime : string;
  aQuote : TQuote;
  cv, pv : int64;
begin

  dTmp := 1000;

  calcRemainTime(idx);

  // 올림차순으로 되어 있음..
  for I := 0 to FCount[idx] - 1 do
  begin
    aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[i];

    aQuote  := aStrike.Call.Quote as TQuote;
    Param[idx][i].calDayVol  := aQuote.DailyVolume;

    Param[idx][i].CPrice := aStrike.Call.Last;
    if aStrike.Call.Last < 0.001 then
    begin
      gEnv.EnvLog( WIN_TEST,
        format('현재가 없음 : %s  %f ', [ aStrike.Call.ShortCode, aStrike.Call.Last])        );
      //if( aQuote.Bids[0].Price < 0.001 ) or (  aQuote.Asks[0].Price < 0.001) then
        Param[idx][i].CPrice := aStrike.Call.Base;
      //else
      //  Param[idx][i].CPrice := (aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;


    end;

    Param[idx][i].PPrice := aStrike.Put.Last;
    if aStrike.Put.Last < 0.001 then
    begin
      gEnv.EnvLog( WIN_TEST,
        format('현재가 없음 : %s  %f ', [ aStrike.Put.ShortCode, aStrike.Put.Last])        );
      //if( aQuote.Bids[0].Price < 0.001 ) or (  aQuote.Asks[0].Price < 0.001) then
        Param[idx][i].PPrice := aStrike.Put.Base;
      //else
      //  Param[idx][i].PPrice := (aQuote.Bids[0].Price + aQuote.Asks[0].Price ) / 2;

    end;

    Param[idx][i].CP :=  abs(  Param[idx][i].CPrice - Param[idx][i].PPrice );
    Param[idx][i].IsCallBig := Param[idx][i].CPrice >= Param[idx][i].PPrice;

    if dTmp > Param[idx][i].CP then
    begin
      dTmp    := Param[idx][i].CP;
      vStrike := aStrike;
      SIndex[idx] := i;
    end;
  end;


  k :=  vStrike.StrikePrice;

  FFValue[idx]  := (Param[idx][SIndex[idx]].CPrice - Param[idx][SIndex[idx]].PPrice)
              * exp(FCDRate  * FRemainSec[idx] ) + k;
  f0 := FFValue[0];

  // C > P 인 경우는 FValue 보다 낮은 행사가(K)를 선택
  // C < P 인 경우는 FValue 보다 큰 행사가(K)를 선택
  if Param[idx][SIndex[idx]].CP <= 0.0001 then
  begin
    K0Index[idx] := gEnv.Engine.SymbolCore.GetCustomATMIndex( FFvalue[idx], MonIdx(idx) );
  end
  else
    if Param[idx][SIndex[idx]].IsCallBig then begin
      for I := FCount[idx] - 1 downto 0 do
      begin
        aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[i];
        if (FFValue[idx] - 0.001) > aStrike.StrikePrice then
          break;
      end;
      K0Index[idx] := i;
    end
    else begin
      for I := 0 to FCount[idx] - 1 do
      begin
        aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[i];
        if FFValue[idx] < (aStrike.StrikePrice - 0.001) then
          break;
      end;
      K0Index[idx] := i;
    end;

  i := SupplementStrike( idx );

  if i <> 0 then
    for I := 0 to FPlusCnt[idx] - 1 do
    begin
      if K0Index[idx] > ParamEx[idx][i].Strike then
        ParamEx[idx][i].Param.Qk := ParamEx[idx][i].Param.PPrice
      else
        ParamEx[idx][i].Param.Qk := ParamEx[idx][i].Param.CPrice;

      ParamEx[idx][i].Param.sigma := 2.5 * ParamEx[idx][i].Param.Qk / Power( ParamEx[idx][i].Strike, 2 );
      dSigmaSum := dSigmaSum + ParamEx[idx][i].Param.sigma
    end;


  if SIndex[idx] >= 0 then
  begin

    dSigmaSum :=0;
    dCalSigmaSum :=0;
    dPutSigmaSum :=0;
    dCalSigmaSum2 :=0;
    dPutSigmaSum2 :=0;
    cn :=0;
    pn :=0;
    cv :=0;
    pv :=0;

    for I := 0 to FCount[idx] - 1 do
    begin


      aStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[i];
      if K0Index[idx] > I then
        Param[idx][i].Qk := Param[idx][i].PPrice
      else if K0Index[idx] = i then
      begin
        Param[idx][i].Qk := (Param[idx][i].CPrice + Param[idx][i].PPrice) / 2 ;

      end
      else
        Param[idx][i].Qk := Param[idx][i].CPrice;

      Param[idx][i].sigma  := 2.5 * Param[idx][i].Qk / Power( aStrike.StrikePrice, 2 );
      //Param[idx][i].sigma  := 2.5 / Power( aStrike.StrikePrice, 2 )* Exp( FCDRate * FRemainSec[idx] ) *Param[idx][i].Qk  ;

      dSigmaSum := dSigmaSum + param[idx][i].sigma;

        {
      gEnv.EnvLog( WIN_TEST,
        Format( '%.2f, %.2f, %.2f, %.2f, %.2f,%.6f',// %.4f',//, %.6f',// %.6f, %.6f',
          [
          aStrike.StrikePrice,
          Param[idx][i].CPrice,
          Param[idx][i].PPrice,
          Param[idx][i].CP, Param[idx][i].Qk,
          Param[idx][i].sigma
          //Param[idx][i].calIv,
          //Param[idx][i].putIv
          ///Param[idx][i].calsigma, Param[idx][i].sigma//, Param[i].putsigma
          ])
        );
          }
    end;  // for I


    FSigmaSum[idx]  := dSigmasum;
    vStrike := FOptionmarket.Trees.Trees[MonIdx(idx)].Strikes.Strikes[K0Index[idx]];

    FIV[idx] := (2 * Exp( FCDRate * FRemainSec[idx] ) * dSigmaSum) / FRemainSec[idx] -
        ( Power((( FFValue[idx] / vStrike.StrikePrice)-1 ),2)) / FRemainSec[idx];

    // test
    {
    stTime := Format('V:%2.2f C-P:%2.2f, K:%3.2f, F:%3.2f, K0:%3.2f, sigma:%.6f, %2d, %3d, %.5f' ,
    [

    sqrt(FIV[idx]) * 100,
    Param[idx][SIndex[idx]].CP2,
    k,
    FFValue[idx],
    vStrike.StrikePrice    ,
    FSigmaSum[idx],
    FCount[idx],
    FRemainDay[idx],
    FRemainSec[idx]
    ]);

    if idx = FM then
    begin
      stTime := 'First - ' + stTime;
    end
    else
      stTime := 'Second- ' + stTime;

    gEnv.EnvLog( WIN_TEST, stTime );
    }
  end;

end;

end.
