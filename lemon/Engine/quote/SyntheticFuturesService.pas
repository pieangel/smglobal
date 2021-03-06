unit SyntheticFuturesService;

interface

uses
  Windows, Graphics, Classes, Controls, SysUtils, Math, Dialogs, ExtCtrls, Menus,
  //
  CleSymbols, CleQuoteBroker, CleQuoteTimers, CleDistributor, CleKrxSymbols,


  CleFQN, CalcGreeks, CleMarkets;




type

  TUpdateEvent = procedure( aSymbol : TSymbol ) of object;

  TSyntheticFutureType = (sfDaily, sfMin );
  
  TSyntheticFuturesService = class
  private
    FReady : Boolean ;
    FChanged : Boolean ;
    FSynPrice : Double ; 
    // Object

    FOptionMarket : TOptionMarket;
    FFutureMarket : TFutureMarket;

    // 2007.01.13 Timer -> TQuoteTimer



    // 2007.01.13
    // O, H, L, C ( 선물 - 합성선물간 시고저종 데이터 )
    FSpreadOpen :  array[TSyntheticFutureType] of Double ; 
    FSpreadHigh : array[TSyntheticFutureType] of Double ;
    FSpreadLow :  array[TSyntheticFutureType] of Double ; 
    FSpreadClose : array[TSyntheticFutureType] of Double ;   
    FSpreadCnt : Integer ;  // Spread 계산된 개수 ( 평균 구하기 위해 )
    FSFCnt : Integer ;  // CalcPrice에서 합성선물 계산된 개수 ( 필터링하기 위해 )
    FSpreadSum : Double ;   // Spread 합
    FSpreadRunning : Boolean ;    // Spread 계산 중인지

    FLastCalcTime : TDateTime  ;  // Min 단위 구하기 위한 시간
    FCalcSpread : array[TSyntheticFutureType] of Boolean ;
    FUpdateEvent: TUpdateEvent; // 계산 여부 ( 실서버에서는 작동 유무 정하기 위해 )
       
    procedure SaveDailySpread ;  // 최종 Daily데이터를 파일에 저장한다.
    procedure SaveMinSpread ;    // 분 단위 데이터를 파일에 저장한다. 

    //
    procedure InitSymbols ;   // 최근월물 수신 모드로 변경
    procedure FinSymbols;
    procedure InitPrice ;     // 초기 FReady = false ( PRICE_EPSILON 보다 작을때 )
    procedure CalcPrice ;     // FReady = true 일때  ( PRICE_EPSILON 보다 클때 )

    // Method Pointer
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure ServiceTimer(Sender: TObject);    // Calc

    function DateCompare( date1, date2 : TDateTime ; interval : Integer) : Boolean  ;
    function DateMinCompare( date1, date2 : TDateTime ) : Boolean ; overload ;

    function GetCalcSpread(aType:TSyntheticFutureType) : Boolean ;
    procedure SetCalcSpread(aType:TSyntheticFutureType; aCalc : Boolean ) ;

    function SymbolDelta(aQuote: TQuote): double;  overload;


  public
    FSynFutures : TSymbol ;
    FTimer : TQuoteTimer  ;
    FutQuote  : TQuote;
    OptQuotes : array [0..1] of TList;

    constructor Create;
    destructor Destroy; override;
    procedure Init;
    procedure ReSetIndicator;
    procedure ReSet;

    function SymbolDelta(aQuote: TQuote;    dPrice: double): double; overload;
    function SymbolDelta2(aQuote: TQuote; dPrice: double): double;

    property CalcSpread[aType:TSyntheticFutureType] : Boolean
      read GetCalcSpread write SetCalcSpread ;

    property UpdateEvnet : TUpdateEvent read FUpdateEvent write FUpdateEvent;

    
  end ;

var
  gSyntheticFuturesService : TSyntheticFuturesService;
  
implementation

uses GAppEnv, GleTypes;

const
  INIT_INTERVAL = 100 ;   // 0.1 초
  CALC_INTERVAL = 1000 ;  // 1초
  MAX_PRICE_GAP = 4 ;    // 행사가와 직전값 간격
  MIN_WEIGHT_PRICE_GAP = 1 ;   // 가중치 최소 간격 
  MAX_QUOTE_SPREAD = 0.3 ;  // 0.2 -> 0.3
  MIN_QUOTE_SPREAD_CNT = 1 ;  // 2 -> 1
  PRICE_EPSILON = 1.0e-8;

  START_SF_CNT = 60 ;         // 스프레드 계산시작개수
  END_SF_TIME = '150300' ;    // 스프레드 계산종료시각

{ TSyntheticFuturesService }


// ---------- << public >> ---------- //

constructor TSyntheticFuturesService.Create;
begin 
  // 2007.01.13 timer -> QuoteTimer
  {
  FTimer := TTimer.Create(nil);
  FTimer.Interval := CALC_INTERVAL ;
  FTimer.OnTimer :=  ServiceTimer ;
  }
  OptQuotes[0] := TList.Create;
  OptQuotes[1] := TList.Create;
  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  with FTimer do
  begin
    Enabled := True;
    Interval := INIT_INTERVAL;
    OnTimer := ServiceTimer ;
  end;

  //
  FReady := false ;
  FSpreadRunning := false ; 
  // 
  FSpreadOpen[sfDaily]  := 0 ;
  FSpreadHigh[sfDaily] := 0 ;
  FSpreadLow[sfDaily]  := 0 ;
  FSpreadClose[sfDaily] := 0 ;
  //
  FSpreadOpen[sfMin]  := 0 ;
  FSpreadHigh[sfMin] := 0 ;
  FSpreadLow[sfMin]  := 0 ;
  FSpreadClose[sfMin] := 0 ;
  //
  FSpreadCnt := 0 ; 
  FSFCnt := 0 ;
  FSpreadSum := 0 ;

  // 디폴트로 (계산)저장안되게 함
  FCalcSpread[sfDaily] := false ;
  FCalcSpread[sfMin] := false ;

end;

// Date1 : To , Date2 : from , interval : 초단위
// Date1과 Date2사이가 interval 보다 같거나 크면 true, 아니면 false  
// 2시부터 3시까지 30분이 지났는지 : DateCompare( 3시, 2시, 30*60 ) 
function TSyntheticFuturesService.DateCompare(date1, date2: TDateTime;
  interval: Integer): Boolean;
var
  iHour1, iHour2 : Integer ;
  iMin1, iMin2 : Integer ;
  iSec1, iSec2 : Integer ;

  iDate1, iDate2 : Integer ; 
begin

  Result := false ;
  //
  iHour1 := StrToInt(FormatDateTime( 'hh' , date1 )) ;
  iMin1 := StrToInt(FormatDateTime( 'nn' , date1 )) ;
  iSec1 := strToInt(FormatDateTime( 'ss' , date1 )) ;
  iDate1 := iHour1 * 60*60 + iMin1 * 60 + iSec1 ;
  // 
  iHour2 := StrToInt(FormatDateTime( 'hh' , date2 )) ;
  iMin2 := StrToInt(FormatDateTime( 'nn' , date2 )) ;
  iSec2 := strToInt(FormatDateTime( 'ss' , date2 )) ;
  iDate2 := iHour2 * 60*60 + iMin2 * 60 + iSec2 ;
  
  //
  {
  gLog.Add(lkError, '합성선물', 'DateCompare'  ,
    FormatDateTime( 'hh:nn:ss' , date1 ) + '/' + IntToStr(iDate1) + ' ' + 
    FormatDateTime( 'hh:nn:ss' , date2 ) + '/' + IntTostr(iDate2) + '=' + 
    IntToStr(iDate1-iDate2) );
  }
  if (iDate1-iDate2) >= interval then
    Result := true ;
  
end;

// Date1과 Date2가 시가 다르거나, 분이 다를때 true 리턴 
function TSyntheticFuturesService.DateMinCompare(date1,
  date2: TDateTime): Boolean;
var
  iHour1, iHour2 : Integer ;
  iMin1, iMin2 : Integer ;
  iSec1, iSec2 : Integer ;
begin
  Result := false ;
  //
  iHour1 := StrToInt(FormatDateTime( 'hh' , date1 )) ;
  iMin1 := StrToInt(FormatDateTime( 'nn' , date1 )) ;
  iSec1 := strToInt(FormatDateTime( 'ss' , date1 )) ; 
  // 
  iHour2 := StrToInt(FormatDateTime( 'hh' , date2 )) ;
  iMin2 := StrToInt(FormatDateTime( 'nn' , date2 )) ;
  iSec2 := strToInt(FormatDateTime( 'ss' , date2 )) ; 

  {
  gLog.Add(lkError, '합성선물', 'DateMinCompare'  ,
  IntToStr(iHour1) + ':' + IntToStr(iMin1) + ':' + IntToStr(iSec1)+  ' ' +
  IntToStr(iHour2) + ':' + IntToStr(iMin2) + ':' + IntToStr(iSec2)   );
  }
  
  if( iHour1 <> iHour2 ) or ( iMin1 <> iMin2 ) then
  begin
    // gLog.Add(lkError, '합성선물', 'DateMinCompare'  , 'true');
    Result := true ;
  end; 
end;

destructor TSyntheticFuturesService.Destroy;
begin

  // 2007.01.13
  if(FCalcSpread[sfDaily] = true ) then
    SaveDailySpread ;

  //
  if FTimer <> nil then
  begin
    FTimer.Enabled := false;
    FTimer.Free ;
  end ;
  
  //
  OptQuotes[0].Free;
  OptQuotes[1].Free;

  FinSymbols;

  inherited;
end;



procedure TSyntheticFuturesService.FinSymbols;
var
  i : integer;
  aQuote : TQuote;
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
end;

procedure TSyntheticFuturesService.Init;
begin
// 1.

  FSynFutures := gEnv.Engine.SymbolCore.Symbols.FindCode(KOSPI200_SYNTH_FUTURES_CODE);
  gEnv.Engine.SymbolCore.SynFutures := FSynFutures;

  gLog.Add(lkApplication, 'TSyntheticFuturesService', 'Init', 'Create ' + FSynFutures.Code );
  //
  InitSymbols ;

  FTimer.Enabled := true ;
end;

// ---------- << private >> ---------- //

function TSyntheticFuturesService.GetCalcSpread(
  aType: TSyntheticFutureType): Boolean;
begin
  Result := FCalcSpread[aType] ; 
end;

procedure TSyntheticFuturesService.SetCalcSpread(aType: TSyntheticFutureType;
  aCalc: Boolean);
begin
  FCalcSpread[aType] := aCalc ; 
end;


procedure TSyntheticFuturesService.InitSymbols;
var
  i : Integer ;
  FOptionMarket : TOptionMarket;
  FFutureMarket : TFutureMarket;
  aStrike : TStrike;
  //FOptionMarkets
  aSymbol : TSymbol ;
  aQuote  : TQuote;
begin

  // 최근월 선물
  FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];

  if FFutureMarket = nil then Exit;

  aSymbol := FFutureMarket.FrontMonth;
  gEnv.Engine.SymbolCore.Future := aSymbol as TFuture;
  FutQuote  := gEnv.Engine.QuoteBroker.Subscribe( self, aSymbol, QuoteProc, gEnv.DB.OneMinLog, spLowest);
  // 최근월 옵션
  FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];

  if FOptionMarket = nil  then Exit;

  for i := 0 to FOptionMarket.Trees.FrontMonth.Strikes.Count-1 do
  begin
    aStrike := FOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    aQuote  := gEnv.Engine.QuoteBroker.Subscribe( self, aStrike.Call, QuoteProc,gEnv.DB.OneMinLog, spLowest);
    OptQuotes[0].Add( aQuote );
    aQuote  := gEnv.Engine.QuoteBroker.Subscribe( self, aStrike.Put, QuoteProc, gEnv.DB.OneMinLog, spLowest);
    OptQuotes[1].Add( aQuote );
  end;

end;

procedure TSyntheticFuturesService.ServiceTimer(Sender: TObject);
var
  stTime : String ;
  i : Integer ;
begin

  stTime := FormatDateTime( 'hh:nn:ss' , gEnv.Engine.QuoteBroker.Timers.Now ) ;
  //

  if FReady = true then
    CalcPrice
  else
    InitPrice ;



  // FChanged = true일때 현재가로 Broadcast 한다. 
   
end;

procedure TSyntheticFuturesService.QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
begin

end;

procedure TSyntheticFuturesService.ReSet;
begin
  OptQuotes[0].Clear;
  OptQuotes[1].Clear;
end;

procedure TSyntheticFuturesService.ReSetIndicator;
begin
end;

function TSyntheticFuturesService.SymbolDelta( aQuote : TQuote ) : double;
var
  U, E, R, T, TC, W, I : Double;
  ExpireDateTime : TDateTime;
begin
  Result := 1;

  if FSynFutures = nil then
    Exit;

  if aQuote.Symbol = nil then Exit;

  if aQuote.Symbol.Spec.Market <> mtOption then
    Exit;

  U := FSynFutures.Last;
  E := (aQuote.Symbol as TOption).StrikePrice;
  R := (aQuote.Symbol as TOption).CDRate;
  ExpireDateTime := GetQuoteDate + (aQuote.Symbol as TOption).DaysToExp - 1 + EncodeTime(15,15,0,0);
  T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);
  TC := (aQuote.Symbol as TOption).DaysToExp / 365;

  if aQuote.Symbol.OptionType = otCall then
    W := 1
  else
    W := -1;

  I := IV(U, E, R, T, TC, aQuote.Symbol.Last , W);
  Result := Delta(U, E, R, I, T, TC, W);

end;

procedure TSyntheticFuturesService.CalcPrice;
var
  i, iCnt : Integer ;

  aFuture : TSymbol ;
  dStrikePrice : Double ;
  // 호가 Spread 구하는 변수
  dCallGap, dPutGap, dQuoteSpread  : Double ;
  // 합성값 구하는 변수
  dCallAvg, dPutAvg, dSynPrice, dWeight, dGap, dWeightedPrice: Double ;
  // 결과값
  dSpread, dPrice, dPriceSum, dWeightSum : Double ;
  //
  //rec : TPriceRec  ;
  aStrike : TStrike;
  stTime : String ;
  dtCalcTime : TDateTime ;
  aCall, aPut : TQuote;

begin

  iCnt := 0 ;
  dPriceSum := 0 ;
  dWeightSum := 0 ; 
  dPrice := 0 ;

  // 최근월 선물
  aFuture := FFutureMarket.FrontMonth;
  //

  for i := 0 to OptQuotes[0].Count - 1 do
  begin
    aCall  := TQuote( OptQuotes[0].Items[i]);
    aPut   := TQuote( OptQuotes[1].Items[i]);
    dStrikePrice :=  (aCall.Symbol as TOption).StrikePrice;
    dGap := abs(FSynPrice - dStrikePrice) ;
    // abs(직전값-행사가) 가 PRICE_GAP 보다 같거나 작으면
    if dGap < MAX_PRICE_GAP + PRICE_EPSILON then
    begin
      //
      if ( aCall.Asks[0].Price < PRICE_EPSILON ) or
         ( aPut.Asks[0].Price < PRICE_EPSILON ) then
         Continue;

      // 호가 Spread =
      dCallGap := abs(aCall.Asks[0].Price  - aCall.Bids[0].Price) ;
      dPutGap  :=  abs(aPut.Asks[0].Price  -  aPut.Bids[0].Price) ;
      dQuoteSpread := dCallGap + dPutGap ;

      if dQuoteSpread > MAX_QUOTE_SPREAD then
        Continue;

      dCallAvg := ( aCall.Asks[0].Price + aCall.Bids[0].Price )/2 ;
      dPutAvg := ( aPut.Asks[0].Price + aPut.Bids[0].Price )/2 ;
      dSynPrice := dCallAvg - dPutAvg + dStrikePrice ;

      // 최소 간격보다 같거나 작으면 최소 간격으로 default
      if dGap <  MIN_WEIGHT_PRICE_GAP then
        dWeight := MIN_WEIGHT_PRICE_GAP
      else
        dWeight := 1/dGap ;
      //
      dWeightedPrice := dSynPrice * dWeight ;


 {     gLog.Add(lkError, '합성선물', 'SynPrice',
      '[SP] ' + FloatToSTr(aOptionMonth.StrikePrices[i].StrikePrice)
      + '[C] ' + FloatToSTr(dCallAvg)
      + '[P] ' + FloatToSTr(dPutAvg)
      + '[S] ' + FloatToSTr(dSynPrice)
      + '[W] ' + FloatToSTr(dWeight)
      + '[R] ' + FloatToSTr(dWeightedPrice))  ;  }
      //
      dPriceSum := dPriceSum + dWeightedPrice ;
      dWeightSum := dWeightSum + dWeight ; 
      
      Inc(iCnt);

    end ;
    
  end ;
   
  if dWeightSum > 0 then dPrice := dPriceSum / dWeightSum ;

{  gLog.Add(lkError, '합성선물', 'Sum',
        FloatToSTr(dPriceSum) +  ' : ' + FloatToSTr(dWeightSum) );

  gLog.Add(lkError, '합성선물', 'Price',
        FloatToSTr(dPrice) +  ' : ' + FloatToSTr(iCnt) );   }


  if( dPrice > PRICE_EPSILON ) and
    ( iCnt >= MIN_QUOTE_SPREAD_CNT ) then
  begin
    
    Inc(FSFCnt);   // 합성선물 계산 회수 

    stTime := FormatDateTime( 'hhnnss' , gEnv.Engine.QuoteBroker.Timers.Now ) ;

    {
    gLog.Add(lkError, '합성선물', '[Time] ' + stTime ,
        '[Cnt] ' + IntToStr(FSFCnt)
        + ' [P1] ' + stTime
        + ' [P2] ' + END_SF_TIME
        + ' [R] ' + IntToStr(compareStr(stTime, END_SF_TIME))
    );
    }

    // -- 합성선물 Spread 시작 ( 저장 옵션이 둘 중 하나가 true 일때 )
    if ( FSFCnt >= START_SF_CNT ) and ( compareStr(stTime, END_SF_TIME) < 0 )  then
    begin
      
      FSpreadRunning := true ;
      Inc(FSpreadCnt) ;  // Spread 계산 회수

      // Spread = 선물 - 합성선물
      dSpread := aFuture.Last - dPrice ;
      FSpreadSum := FSpreadSum + dSpread ;      // Spread 전체합

      // -- Daily 계산 로직 ( 활성화 여부에 상관없이 )

      // 종가를  계산된 값으로 셋팅
      FSpreadClose[sfDaily] := dSpread ;

      // 첫번째 값이면 FSpreadOpen와 FSpreadLow를 dSpread로 업데이트
      if FSpreadCnt = 1 then
      begin
        FSpreadOpen[sfDaily] := dSpread ;
        FSpreadLow[sfDaily] := dSpread ;
        FSpreadHigh[sfDaily] := dSpread ;
      end ;

      // 기존 FSpreadHigh가 dSpread 보다 작으면 FSpreadHigh를 dSpread로 업데이트
      if ( FSpreadHigh[sfDaily] < dSpread - PRICE_EPSILON) then
        FSpreadHigh[sfDaily] := dSpread ;

      // 기존 FSpreadLow가 dSpread보다 크면 FSpreadLow를 dSpread로 업데이트
      if (FSpreadLow[sfDaily] > dSpread + PRICE_EPSILON) then
        FSpreadLow[sfDaily] := dSpread ;


      // -- Min 계산 로직 ( 활성화 되어 있을 경우만 ) 
      if(FCalcSpread[sfMin] = true )then
      begin

        dtCalcTime := gEnv.Engine.QuoteBroker.Timers.Now ;
        
        // 첫번째 값이면 FSpreadOpen와 FSpreadLow를 dSpread로 업데이트
        if FSpreadCnt = 1 then
        begin
          // 최초 시간 ( Min Data 구하기 위해서 )
          FLastCalcTime := dtCalcTime ;
        end ;

        // 2007.01.23 bug ==> if 밑으로 내림 
        // 종가를  계산된 값으로 셋팅
        // FSpreadClose[sfMin] := dSpread ;

        // 1분 지났을 경우 로직 ( dtCalcTime와 FLastCalcTime 를 가지고 시간 계산 )
        if  DateMinCompare(dtCalcTime, FLastCalcTime )  then
        begin
          // -- 파일 저장
          SaveMinSpread ;

          // -- 데이터 리셋
          FLastCalcTime := dtCalcTime ;
          FSpreadOpen[sfMin] := dSpread ;
          FSpreadLow[sfMin] := dSpread ;
          FSpreadHigh[sfMin] := dSpread ;
        end ;

        // 2007.01.23 bug
        // if DateMinCompare 위에 코딩했던것을 밑으로 이동
        // 종가를  계산된 값으로 셋팅
        FSpreadClose[sfMin] := dSpread ;
        
        // 기존 FSpreadHigh가 dSpread 보다 작으면 FSpreadHigh를 dSpread로 업데이트
        if ( FSpreadHigh[sfMin] < dSpread - PRICE_EPSILON) then
          FSpreadHigh[sfMin] := dSpread ;

        // 기존 FSpreadLow가 dSpread보다 크면 FSpreadLow를 dSpread로 업데이트
        if (FSpreadLow[sfMin] > dSpread + PRICE_EPSILON) then
          FSpreadLow[sfMin] := dSpread ;
      end;

      // Raw Data 배포시 로그 주석처리할것  !!
      {
      stTime := FormatDateTime( 'hh:nn:ss' , GetQuoteTime ) ;
      gLog.Add(lkError, '합성선물', '[Time] ' + stTime ,
        '[SF] ' + Format('%.2f', [dPrice] )
        + ' [F] ' + Format('%.2f', [aFuture.C] )
        + ' [SP] ' + Format('%.2f', [dSpread] )
        + ' [O] ' + Format('%.2f', [FSpreadOpen[sfDaily]] )
        + ' [H] ' + Format('%.2f', [FSpreadHigh[sfDaily]] )
        + ' [L] ' + Format('%.2f', [FSpreadLow[sfDaily]] )
        + ' [C] ' + Format('%.2f', [FSpreadClose[sfDaily]] )
      );
      }
          
    end
    else
    begin
      FSpreadRunning := false ;
    end;

    // -- 합성선물 Spread 끝
    if Assigned( FUpdateEvent ) and
      (FSynPrice <> dPrice) then
      FUpdateEvent( FSynFutures );

    // 합성선물 Update
    FSynPrice := dPrice ;
    //rec.Close := dPrice ;
    FSynFutures.Last  := dPrice;
  end;
end;

procedure TSyntheticFuturesService.InitPrice;
var
  i, iCnt : Integer ;
  //aOptionMonth : TOptionMonthlyItem;
  aFuture : TSymbol;
  aCall, aPut : TQuote;
  dCallGap, dPutGap, dQuoteSpread  : Double ;
  dCallAvg, dPutAvg, dSynPrice : Double ;
  dSpread, dPrice, dSum : Double ;
  //rec : TPriceRec  ;
begin

  iCnt := 0 ;
  dSum := 0 ;
  dPrice := 0 ;
  

  // 2007.01.13 
  // 최근월 선물
  FFutureMarket  := gEnv.Engine.SymbolCore.FutureMarkets.FutureMarkets[0];
  aFuture := FFutureMarket.FrontMonth;

  // 최근월 옵션

  for i := 0 to OptQuotes[0].Count-1 do
  begin
    aCall := TQuote( OptQuotes[0].Items[i] );
    aPut  := TQuote( OptQuotes[1].Items[i] );

    if ( aCall.Asks[0].Price < PRICE_EPSILON ) or
       (  aPut.Asks[0].Price < PRICE_EPSILON ) then
       Continue;

    dCallGap := abs(aCall.Asks[0].Price - aCall.Bids[0].Price) ;
    dPutGap  :=  abs(aPut.Asks[0].Price - aPut.Bids[0].Price) ;
    dQuoteSpread := dCallGap + dPutGap ;

    // 호가 Spread가 MAX_QUOTE_SPREAD 작으면
    if dQuoteSpread < MAX_QUOTE_SPREAD then
    begin
      // -- 합성값 계산 ( Call - Put + StrikePrice ) 
      dCallAvg := ( aCall.Asks[0].Price+ aCall.Bids[0].Price )/2 ;
      dPutAvg := ( aPut.Asks[0].Price + aPut.Bids[0].Price )/2 ;
      dSynPrice := dCallAvg - dPutAvg + (aCall.Symbol as TOption).StrikePrice;

      {
      gLog.Add(lkError, '합성선물', 'InitPrice',
      '[SP] ' + FloatToSTr(aOptionMonth.StrikePrices[i].StrikePrice)
      + '[C] ' + FloatToSTr(dCallAvg)
      + '[P] ' + FloatToSTr(dPutAvg)
      + '[Result] ' + FloatToSTr(dSynPrice) )  ;
      }
      
      //
      dSum := dSum + dSynPrice ;
      // -- 개수 증가
      Inc(iCnt);
    end ;

  end ;

  if iCnt > 0 then dPrice := dSum / iCnt ;
  //

  {
  gLog.Add(lkError, '합성선물', 'InitPrice',
        FloatToSTr(dPrice) +  ' : ' + IntToStr(iCnt) );
  }
  
  //
  if( dPrice > PRICE_EPSILON ) and
    ( iCnt >= MIN_QUOTE_SPREAD_CNT ) then
  begin        {
    gLog.Add(lkError, '합성선물', 'InitPrice',
      FormatDateTime('hh:nn:ss:zzz' , gEnv.Engine.QuoteBroker.Timers.Now ) +
      'Ready! [SF] ' + Format('%.2f', [dPrice])
      + ' [F] ' + Format('%.2f', [aFuture.C])   );

    {  // 최초 CalcPrice 로 설정하는 것이 아니라, 조건에 따른 설정으로 
    // Spread = 선물 - 합성선물
    dSpread := aFuture.C - dPrice ;

    FSpreadOpen :=  dSpread ;
    FSpreadHigh :=  dSpread ;
    FSpreadLow :=  dSpread ;
    FSpreadClose :=  dSpread ;
    }
    
    // 
    FSynPrice := dPrice ;
       
    // 2007.02.24 Broadcast 
    //rec.Close := dPrice ;
    FSynFutures.Last:= dPrice;

    FTimer.Interval := CALC_INTERVAL ;
    FReady := true ;
  end ;

end;

// 2007.01.13 
// 최종 데이터를 파일에 저장한다.
procedure TSyntheticFuturesService.SaveDailySpread;
var
  TF : TextFile ;
  stFile : String ;
  stHeader, stData : String ;
  dSpreadAvg : double ;
begin
          {
  // 저장일, 데이터날짜, Spread O, H, L, C
  try

    // 2007.01.14 Temp
    stFile := gLogDir + '합성선물.csv' ;  

    // stFile :=  'E:\GssData\합성선물.csv'  ;
    
    // File Open 
    AssignFile(TF, stFile  ); 
    if  not FileExists(stFile)  then
      begin
        Rewrite(TF) ;
        // 헤더
        stHeader := 'SaveDate,Date,sum,cnt,avg,O,H,L,C' ;
        Writeln(TF, stHeader);
      end  
    else
      Append(TF);
      
    // File Write

    // Spread 평균값 
    if( FSFCnt <> 0 )then dSpreadAvg := FSpreadSum/FSFCnt ;
    
    // 2007.01.14 Temp
    stData :=
          FormatDateTime('yyyy-mm-dd hh:nn:ss' , now  ) 
          + ',' + FormatDateTime('yyyy-mm-dd hh:nn:ss' , gEnv.Engine.QuoteBroker.Timers.Now )
          + ',' + Format('%.2f', [FSpreadSum])
          + ',' + IntToStr(FSFCnt) 
          + ',' + Format('%.2f', [dSpreadAvg])
          + ',' + Format('%.2f', [FSpreadOpen[sfDaily]])
          + ',' + Format('%.2f', [FSpreadHigh[sfDaily]])
          + ',' + Format('%.2f', [FSpreadLow[sfDaily]])
          + ',' + Format('%.2f', [FSpreadClose[sfDaily]]);

    // -- 데이터 저장
    Writeln(TF, stData);

    // File Close 
    CloseFile(TF);
    
  finally
    gLog.Add(lkError, '합성선물', 'DailySpread', stData );
  end;
         }
end;

procedure TSyntheticFuturesService.SaveMinSpread;
var
  TF : TextFile ;
  stFile : String ;
  stHeader, stData : String ;
begin
{
    // 저장일, 데이터날짜, Spread O, H, L, C
  try

    // 2007.01.14 Temp
    stFile := gLogDir + '합성선물_분_' +  FormatDateTime('yyyymmdd' , gEnv.Engine.QuoteBroker.Timers.Now  )  + '.csv' ;

    // File Open
    AssignFile(TF, stFile  ); 
    if  not FileExists(stFile)  then
      begin
        Rewrite(TF) ;
        // 헤더
        stHeader := 'SaveDate,Date,O,H,L,C' ;
        Writeln(TF, stHeader);
      end
    else
      Append(TF);
      

    // 
    stData :=
          FormatDateTime('yyyy-mm-dd hh:nn:ss' , now  ) 
          + ',' + FormatDateTime('yyyy-mm-dd hh:nn:ss' , gEnv.Engine.QuoteBroker.Timers.Now )
          + ',' + Format('%.2f', [FSpreadOpen[sfMin]])
          + ',' + Format('%.2f', [FSpreadHigh[sfMin]])
          + ',' + Format('%.2f', [FSpreadLow[sfMin]])
          + ',' + Format('%.2f', [FSpreadClose[sfMin]]);
 
    // -- 데이터 저장
    Writeln(TF, stData);

    // File Close 
    CloseFile(TF);
    
  finally
    // gLog.Add(lkError, '합성선물', 'MinSpread', stData );
  end;
     }
end;

function TSyntheticFuturesService.SymbolDelta(aQuote: TQuote;
  dPrice: double): double;
var
  U, E, R, T, TC, W, I : Double;
  ExpireDateTime : TDateTime;
  stTxt : string;
begin
  Result := 1;

  if (FSynFutures = nil) or (aQuote = nil ) then
    Exit;

  if aQuote.Symbol = nil then Exit;

  if aQuote.Symbol.Spec.Market <> mtOption then
    Exit;

  U := FSynFutures.Last;
  E := (aQuote.Symbol as TOption).StrikePrice;
  R := (aQuote.Symbol as TOption).CDRate;
  ExpireDateTime := GetQuoteDate + (aQuote.Symbol as TOption).DaysToExp - 1 + EncodeTime(15,0,0,0);
  T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);//rcTrdDate);
  TC := (aQuote.Symbol as TOption).DaysToExp / 365;


  if aQuote.Symbol.OptionType = otCall then
    W := 1
  else
    W := -1;

  I := IV(U, E, R, T, TC, dPrice , W);
  Result := Delta(U, E, R, I, T, TC, W);

  (aQuote.Symbol as TOption).ThPrice  :=  OptionThPrice(U, E, R, I, T, TC, W );
  (aQuote.Symbol as TOption).Delta := Delta(U, E, R, I, T, TC, W ) ;
  (aQuote.Symbol as TOption).Gamma := Gamma(U, E, R, I, T, TC )  ;
  (aQuote.Symbol as TOption).Vega  := Vega (U, E, R, I, T, TC, W );
  (aQuote.Symbol as TOption).Theta := Theta(U, E, R, I, T, TC,
                    gEnv.Engine.Holidays.WorkingDaysInYear, W ) ;

  (aQuote.Symbol as TOption).IV    := I;
  result := i;

end;

function TSyntheticFuturesService.SymbolDelta2(aQuote: TQuote;
  dPrice: double): double;
var
  U, E, R, T, TC, W, I : Double;
  ExpireDateTime : TDateTime;
  stTxt : string;
begin
  Result := 1;

  if (FSynFutures = nil) or (aQuote = nil ) then
    Exit;

  if aQuote.Symbol = nil then Exit;

  if aQuote.Symbol.Spec.Market <> mtOption then
    Exit;

  U := FSynFutures.Last;
  E := (aQuote.Symbol as TOption).StrikePrice;
  R := (aQuote.Symbol as TOption).CDRate;
  ExpireDateTime := GetQuoteDate + (aQuote.Symbol as TOption).DaysToExp - 1 + EncodeTime(15,0,0,0);
  T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);//rcTrdDate);
  TC := (aQuote.Symbol as TOption).DaysToExp / 365;


  if aQuote.Symbol.OptionType = otCall then
    W := 1
  else
    W := -1;

  I := IV(U, E, R, T, TC, dPrice , W);
  Result := Delta(U, E, R, I, T, TC, W);

  (aQuote.Symbol as TOption).Delta := Delta(U, E, R, I, T, TC, W ) ;
  (aQuote.Symbol as TOption).Vega  := Vega (U, E, R, I, T, TC, W );
  (aQuote.Symbol as TOption).IV    := I;

end;


end.

