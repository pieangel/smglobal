unit CleSymbolCore;

interface

uses
  Classes, SysUtils, Windows, EnvFile,

  CleFQN, CleMarketSpecs, CleSymbols, CleMarkets, CalcGreeks, GleTypes,

  CleKrxSymbolMySQLLoader
  ;

{$INCLUDE define.txt}

type
//  TSymbolLoadEvent = function(stDate: TDateTime): Boolean of object;

  TDuraReceiveEvent = procedure (aSymbol : TSymbol ) of object;

  TSymbolCore = class
  private
      // dates
    FMasterDate: TDateTime;

      // Specifications
    FSpecs: TMarketSpecs;

      // Symbol Information
    FSymbols: TSymbolList;
      // 
    FIndexes: TIndexes;
    FStocks: TStocks;
    FFutures: TFutures;
    FOptions: TOptions;
    FSpreads: TSpreads;
    FELWs: TELWs;
      //
    FSymbolCache: TSymbolCache;
    FOnDuraReceive : TDuraReceiveEvent;

      // Market Information ( subtype.underlying.market type.exchange.country)
    FMarkets: TMarketList;
      //
    FIndexMarkets: TIndexMarkets;   // *.index.exchange.country
    FStockMarkets: TStockMarkets;   // *.stock.exchange.country
    FFutureMarkets: TFutureMarkets; // *.future.exchange.country
    FSpreadMarkets: TSpreadMarkets; // *.spread.exchange.country
    FOptionMarkets: TOptionMarkets; // *.option.exchange.country
    FETFMarkets: TETFMarkets;       // *.etf.exchange.country
    FBondMarkets: TBondMarkets;     // *.bond.exchange.country
    FELWMarkets: TELWMarkets;       // *.elw.exchange.country
    FCurrencyMarkets: TCurrencyMarkets;     // *.currency.exchange.country
    FCommodityMarkets: TCommodityMarkets;   // *.commodity.exchange.country

      // Market Groups
    FUnderlyings: TMarketGroups;    // *.underlying.*.exchange.country
    FExchanges: TMarketGroups;

    FSynFutures: TSymbol;
    FFuture: TFuture;      // *.exchange.country

    FChartStore : TCollection;

    FCalcDr  : boolean;
    FMonthlyItem : TOptionMarket;

    FPuts: TSymbolList;
    FCalls: TSymbolList;
    FMiniFuture: TFuture;
    FDollars: TDollars;
    FDollarMarkets: TDollarMarkets;
    FBonds: TBonds;
    FSymbolLoader: TKRXSymbolMySQLLoader;
    FCommodities: TCommodities;
    FCurrencies: TCurrencies;
    FSectors: TMarketGroups;
    FFavorFutMarkets: TStringList;
    FFavorFutType: integer;


    function GetATMIndex: Integer;
    function FindNextUserBlock(aEnvFile: TEnvFile; var iP,
      iEndP: Integer): Boolean;
    function SaveFavorSymbol(aEnvFile: TEnvFile; aFutMarket: TFutureMarket; stName :string): Boolean;
    function LoadFavorSymbol(aEnvFile: TEnvFile; var iP: Integer): Boolean;
  public

    k200DR  : Double;
    AggereGateValue : Double;  // 시가총액

    constructor Create;
    destructor Destroy; override;
    procedure MarketsSort;   // 월물 sort;

    procedure Reset;

//    function Load(dtMaster: TDateTime): Boolean;
    procedure RegisterSymbol(aSymbol: TSymbol);
      // date
    property MasterDate: TDateTime read FMasterDate;
      // specifications
    property Specs: TMarketSpecs read FSpecs;
      // symbols
    property Symbols: TSymbolList read FSymbols;
    property Indexes: TIndexes read FIndexes;
    property Dollars: TDollars read FDollars;
    property Bonds: TBonds read FBonds;
    property Commodities : TCommodities read FCommodities;
    property Currencies  : TCurrencies read FCurrencies;

    property Stocks: TStocks read FStocks;
    property Futures: TFutures read FFutures;
    property Options: TOptions read FOptions;
    property Spreads: TSpreads read FSpreads;
    property ELWs: TELWs read FELWs;
      //
    property Calls : TSymbolList read FCalls;
    property Puts  : TSymbolList read FPuts;

      // cache
    property SymbolCache: TSymbolCache read FSymbolCache;

      // markets
    property Markets: TMarketList read FMarkets;
    property IndexMarkets: TIndexMarkets read FIndexMarkets;
    property DollarMarkets: TDollarMarkets read FDollarMarkets;

    property StockMarkets: TStockMarkets read FStockMarkets;
    property FutureMarkets: TFutureMarkets read FFutureMarkets;
    property SpreadMarkets: TSpreadMarkets read FSpreadMarkets;
    property OptionMarkets: TOptionMarkets read FOptionMarkets;
    property ETFMarkets: TETFMarkets read FETFMarkets;
    property BondMarkets: TBondMarkets read FBondMarkets;
    property ELWMarkets: TELWMarkets read FELWMarkets;
    property CurrencyMarkets : TCurrencyMarkets read FCurrencyMarkets;
    property CommodityMarkets: TCommodityMarkets read FCommodityMarkets;
    property FavorFutMarkets : TStringList read FFavorFutMarkets;
    property FavorFutType    : integer read FFavorFutType write FFavorFutType;
      // market groups
    property Underlyings: TMarketGroups read FUnderlyings;
    property Exchanges: TMarketGroups read FExchanges;
    property Sectors  : TMarketGroups read FSectors;

    property SynFutures : TSymbol read FSynFutures write FSynFutures;
    property Future     : TFuture read FFuture  write FFuture;
    property MiniFuture : TFuture read FMiniFuture  write FMiniFuture;
    property OnDuraReceive : TDuraReceiveEvent read FOnDuraReceive write FOnDuraReceive;
    property MonthlyItem : TOptionMarket read FMonthlyItem;

    property SymbolLoader : TKRXSymbolMySQLLoader read FSymbolLoader;

    procedure PrePare;


    function GetStrikeOption(dStrikePrice: double; bCall: boolean): TOption;
    function GetCustomATMIndex( dLast : double; iMonth : integer ): Integer;
    procedure GetCurCallList(StrikeCount: Integer; var aList: TList); overload;
    procedure GetCurPutList(StrikeCount: Integer; var aList: TList); overload;

    procedure GetCurCallList(dAbove, dBelow : double; StrikeCount: Integer; var aList: TList); overload;
    procedure GetCurPutList(dAbove, dBelow  : double; StrikeCount: Integer; var aList: TList); overload;

    procedure GetPriceSymbolList(dPriceLow : double; dPriceHigh : double;  bExpect : boolean; var aCall : TList; var aPut : TList);
    procedure GetOpenPriceSymbolList(dPriceLow : double; dPriceHigh : double;  bExpect : boolean; var aCall : TList; var aPut : TList);

    // 변동성
    function GetCurCallVol(StrikeCount : Integer; aType : TRdCalcType ) : Double;overload;
    function GetCurPutVol(StrikeCount : Integer; aType : TRdCalcType ) : Double;overload;

    //Insert SMS
    function GetCurCallVol(StrikeCount : Integer; aType : TRdCalcType ;
      dFuturePrice : Double ; dMixRatio : Double) : Double ; overload;
    function GetCurPutVol(StrikeCount : Integer; aType : TRdCalcType ;
      dFuturePrice : Double ; dMixRatio : Double) : Double ; overload;

    // only dong bu..옵션 기초자산 코드를 잘못준다.. ㅜㅜ;..
    function FindFutureMarket( stUnder : string ) : TFutureMarket;
    function GetSymbolInfo : boolean;
    procedure OptionPrint;

    procedure SaveFavorSymbols;
    procedure LoadFavorSymbols;

{$IFDEF DONGBU_STOCK}
    procedure RegisterMuchSymbol( aSymbol : TSymbol );
{$ENDIF}



  end;

function SortDate(Item1, Item2: Pointer): Integer;

implementation

uses GAppEnv, GAppConsts,CleQuoteTimers, ApiPacket, ApiConsts,    Math;

{ TSymbolCore }


constructor TSymbolCore.Create;
begin
  FSynFutures := nil;
  FFuture     := nil;
    // objects: specifications
  FSpecs := TMarketSpecs.Create;

    // objects: symbols
  FSymbols := TSymbolList.Create;
  FIndexes := TIndexes.Create;
  FDollars := TDollars.Create;
  FBonds   := TBonds.Create;
  FStocks  := TStocks.Create;
  FFutures := TFutures.Create;
  FOptions := TOptions.Create;
  FSpreads := TSpreads.Create;
  FELWs := TELWs.Create;
  FCommodities:= TCommodities.Create;
  FCurrencies := TCurrencies.Create;

  FPuts := TSymbolList.Create;
  FCalls:= TSymbolList.Create;

  FSymbolCache := TSymbolCache.Create;

    // objects: markets
  FMarkets       := TMarketList.Create;
  FIndexMarkets  := TIndexMarkets.Create;
  FDollarMarkets := TDollarMarkets.Create;
  FStockMarkets  := TStockMarkets.Create;
  FFutureMarkets := TFutureMarkets.Create;
  FOptionMarkets := TOptionMarkets.Create;
  FSpreadMarkets := TSpreadMarkets.Create;
  FETFMarkets    := TETFMarkets.Create;
  FBondMarkets   := TBondMarkets.Create;
  FELWMarkets    := TELWMarkets.Create;
  FCurrencyMarkets:= TCurrencyMarkets.Create;     // *.currency.exchange.country
  FCommodityMarkets:= TCommodityMarkets.Create ;   // *.commodity.exchange.country
  FFavorFutMarkets:= TStringList.Create;
  FFavorFutType   := 1;

    // objects: market groups
  FUnderlyings := TMarketGroups.Create;
  FExchanges   := TMarketGroups.Create;
  FSectors     := TMarketGroups.Create;

  FSymbolLoader:= TKRXSymbolMySQLLoader.Create( nil );

  K200Dr := 0;
  AggereGateValue := 0;
  FCalcDr := false;
end;

destructor TSymbolCore.Destroy;
begin
    // objects: market groups
  FSymbolLoader.Free;

  FUnderlyings.Free;
  FExchanges.Free;
  FSectors.Free;
    // objects: markets
  FMarkets.Free;
  FIndexMarkets.Free;
  FDollarMarkets.Free;
  FStockMarkets.Free;
  FSpreadMarkets.Free;
  FFutureMarkets.Free;
  FOptionMarkets.Free;
  FETFMarkets.Free;
  FBondMarkets.Free;
  FELWMarkets.Free;
  FCurrencyMarkets.Free;
  FCommodityMarkets.Free;
  FFavorFutMarkets.Free;
    // objects: symbols
  FSymbolCache.Free;
  FPuts.Free;
  FCalls.Free;
  FSymbols.Free;
  FSpreads.Free;
  FStocks.Free;
  FIndexes.Free;
  FDollars.Free;
  FOptions.Free;
  FFutures.Free;
  FELWs.Free;
  FBonds.Free;
  FCommodities.Free;
  FCurrencies.Free;
    // objects: specifications
  FSpecs.Free;
  FChartStore.Free;
  inherited;
end;


function TSymbolCore.FindFutureMarket(stUnder: string): TFutureMarket;
var
  stPM  : string;
  //aFMkt : TFutureMarket;
begin
  stPM := Copy( stUnder, 1, Length( stUnder ) - 3 );
  Result:= FutureMarkets.FindPumMok( stPM );
  //stDate  := Copy( stUnder, Length( stUnder ) - 2, 3 );
end;

procedure TSymbolCore.Reset;
begin
    // objects: symbols
  gEnv.Engine.QuoteBroker.Cancel( self );

  FCalls.Clear;
  FPuts.Clear;

  FSymbols.Clear;
  FSpreads.Clear;
  FStocks.Clear;
  FIndexes.Clear;
  FOptions.Clear;
  FFutures.Clear;
  FDollars.Clear;
  FBonds.Clear;
    // objects: markets
  FMarkets.Clear;
  FIndexMarkets.Clear;
  FStockMarkets.Clear;
  FFutureMarkets.Clear;
  FOptionMarkets.Clear;
  FETFMarkets.Clear;
  FBondMarkets.Clear;
  FDollarMarkets.Clear;
  FELWMarkets.Clear;
    // objects: market groups
  FUnderlyings.Clear;
  FExchanges.Clear;
end;



procedure TSymbolCore.RegisterSymbol(aSymbol: TSymbol);
var
  aMarket: TMarket;
begin
  if aSymbol = nil then Exit;

    // add to symbol list
  if FSymbols.IndexOfObject(aSymbol) < 0 then
    FSymbols.AddObject(aSymbol.Code, aSymbol);

    // add to a market
  if aSymbol.Spec <> nil then
  begin

    aMarket := FMarkets.FindMarket(aSymbol.Spec.FQN);

    if aMarket = nil then
    begin
      case aSymbol.Spec.Market of
        mtIndex:   aMarket := FIndexMarkets.New(aSymbol.Spec.FQN);
        mtStock:   aMarket := FStockMarkets.New(aSymbol.Spec.FQN);
        mtBond:    aMarket := FBondMarkets.New(aSymbol.Spec.FQN);
        mtETF:     aMarket := FETFMarkets.New(aSymbol.Spec.FQN);
        mtFutures: aMarket := FFutureMarkets.New(aSymbol.Spec.FQN);
        mtOption:  aMarket := FOptionMarkets.New(aSymbol.Spec.FQN);
        mtSpread:  aMarket := FSpreadMarkets.New(aSymbol.Spec.FQN);
        mtDollar:  aMarket := FDollarMarkets.New(aSymbol.Spec.FQN);
        mtCurrency:  aMarket := FCurrencyMarkets.New(aSymbol.Spec.FQN);
        mtCommodity:  aMarket := FCommodityMarkets.New(aSymbol.Spec.FQN);
        else
          Exit;
      end;
        //
      aMarket.Spec := aSymbol.Spec;
      FMarkets.AddMarket(aMarket);
        // underlying
      if aMarket.Spec.Market in [mtFutures, mtOption, mtSpread, mtELW] then
      begin
        if (aSymbol as TDerivative).Underlying <> nil then
          FUnderlyings.AddMarket(aMarket,
                                 aSymbol.Spec.SubMarket
                                 + aSymbol.Spec.Underlying
                                 + '.' + aSymbol.Spec.Exchange
                                 + '.' + aSymbol.Spec.Country,
                                 (aSymbol as TDerivative).Underlying.Name,
                                 (aSymbol as TDerivative).Underlying);
      end;

      FExchanges.AddMarket(aMarket,
                           aSymbol.Spec.Exchange + '.' + aSymbol.Spec.Country,
                           aSymbol.Spec.Exchange);
      FSectors.AddMarket( aMarket, aSymbol.Spec.Sector + '.' ,
                          aSymbol.Spec.Sector );

    end;
      //
    aMarket.AddSymbol(aSymbol);
  end;
end;

function TSymbolCore.GetATMIndex : Integer;
var
  i, iATM : Integer;
  MaxDiff : Double;
  dLast : double;
begin

  FMonthlyItem := OptionMarkets.OptionMarkets[0];

  if (FMonthlyItem = nil) or (FMonthlyItem.Trees.FrontMonth.Strikes.Count = 0 ) then
  begin
    Result := -1;
    Exit;
  end;

  if dLast <= 0 then
    dLast := gEnv.Engine.SymbolCore.Futures[0].Last;

  //if dLast < 0.001 then
  //  dLast :=

  iATM := -1;
  MaxDiff := 100000000.0;          // big number
  for i:=0 to FMonthlyItem.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    if Abs(FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i].StrikePrice - dLast) < MaxDiff
    then
    begin
      MaxDiff := Abs(FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i].StrikePrice - dLast);
      iATM := i;
    end
    else
      Break;
  end;
  Result := iATM;

end;

procedure TSymbolCore.GetCurCallList(StrikeCount: Integer;
  var aList : TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;
  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := Min(iATM+StrikeCount-1, FMonthlyItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    aList.Add( call);
  end;

end;


procedure TSymbolCore.GetCurPutList(StrikeCount: Integer;
  var aList : TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;

  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := Max(0, iATM-StrikeCount+1);


  for i:=iATM downto iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
    aList.Add( put);

end;

function TSymbolCore.GetCurCallVol(StrikeCount: Integer;
  aType: TRdCalcType): Double;
var
  i, iATM, iEnd, iCount : Integer;
  dIVSum : Double;
  CurCallVol : Double;

  OptPrice : Double;            // 옵션가격
  U : Double;                   // 기초자산가격
  E : Double;                    // 행사가
  R : Double;                   // CD Rate
  T : Double;                   // 잔존일수
  TC : Double;                  // 달력일기준 잔존일수
  W : Double;                   // Call=1, Put=-1
  ExpireDateTime : TDateTime;
begin
  //-- ATM strike price
  iATM := GetATMIndex;
  if iATM < 0 then
  begin
    Result := 0;
    Exit;
  end;

  // Call 현재대표내재변동성
  dIVSum := 0.0;
  iCount := 0;

  iEnd := Min(iATM+StrikeCount-1, FMonthlyItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    U := gEnv.Engine.SymbolCore.Future.Last;
    //U := gEnv.Engine.SyncFuture.FSynFutures.Last;
    E := StrikePrice;
    R := Call.CDRate;
    ExpireDateTime := GetQuoteDate + Call.DaysToExp - 1 + EncodeTime(15,15,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, aType);
    TC := Call.DaysToExp/365;
    OptPrice := Call.Last;
    W := 1;

    dIVSum := dIVSum + IV(U, E, R, T, TC, OptPrice, W);
    Inc(iCount);
  end;

  CurCallVol := dIVSum / iCount;
  //
  Result := CurCallVol;

end;


function TSymbolCore.GetCurPutVol(StrikeCount: Integer;
  aType: TRdCalcType): Double;
var
  i, iATM, iEnd, iCount : Integer;
  dIVSum, dTmp : Double;
  CurPutVol : Double;

  OptPrice : Double;            // 옵션가격
  U : Double;                   // 기초자산가격
  E : Double;                    // 행사가
  R : Double;                   // CD Rate
  T : Double;                   // 잔존일수
  TC : Double;                  // 달력일기준 잔존일수
  W : Double;                   // Call=1, Put=-1
  ExpireDateTime : TDateTime;
begin
  //-- ATM strike price
  iATM := GetATMIndex;
  if iATM < 0 then
  begin
    Result := 0;
    Exit;
  end;

  // Put 현재대표내재변동성
  dIVSum := 0.0;
  iCount := 0;
  iEnd := Max(0, iATM-StrikeCount+1);

  dTmp := 0;

  for i:=iATM downto iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin

    U := gEnv.Engine.SymbolCore.Future.Last;
    //U := gEnv.Engine.SyncFuture.FSynFutures.Last;
    E := StrikePrice;
    R := Put.CDRate;
    ExpireDateTime := GetQuoteDate + Put.DaysToExp - 1 + EncodeTime(15,15,0,0);
    T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, aType);
    TC := Put.DaysToExp/365;
    OptPrice := Put.Last;
    W := -1;

    dTmp := IV(U, E, R, T, TC, OptPrice, W);
    dIVSum := dIVSum + dTmp;
    Inc(iCount);

    gEnv.EnvLog( WIN_TEST,
      Format('%.2f, %.2f, %.4f', [ StrikePrice, OptPrice, dTmp ])
    );
  end;

  CurPutVol := dIVSum / iCount;

  gEnv.EnvLog( WIN_TEST,
      Format('put iv : %.4f', [ CurPutVol ])
    );
  //
  Result := CurPutVol;

end;

procedure TSymbolCore.GetCurCallList(dAbove, dBelow : double; StrikeCount: Integer;
  var aList: TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;
  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := FMonthlyItem.Trees.FrontMonth.Strikes.Count-1;

  // Min(iATM+StrikeCount-1, FMonthlyItem.Trees.FrontMonth.Strikes.Count-1);

  for i:=iATM to iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin

    if StrikeCount <= aList.Count then
      break;

    if (call.Last <= dAbove) and ( call.Last >= dBelow) then
      aList.Add( call);
  end;

end;

function TSymbolCore.GetCurCallVol(StrikeCount: Integer; aType: TRdCalcType;
  dFuturePrice, dMixRatio: Double): Double;
begin

end;


procedure TSymbolCore.GetCurPutList(dAbove, dBelow : double; StrikeCount: Integer;
  var aList: TList);
  var
    i, iATM, iEnd, iCount : Integer;
begin
  aList.Clear;

  iATM := GetATMIndex;
  if iATM < 0 then
    Exit;

  iCount := 0;
  iEnd := 0;//Max(0, iATM-StrikeCount+1);


  for i:=iATM downto iEnd do
  with FMonthlyItem.Trees.FrontMonth.Strikes.Strikes[i] do
  begin
    if aList.Count >= StrikeCount then
      break;  
    if ( put.Last <= dAbove ) and ( put.Last >= dBelow ) then
      aList.Add( put);
  end;
end;

function TSymbolCore.GetCurPutVol(StrikeCount: Integer; aType: TRdCalcType;
  dFuturePrice, dMixRatio: Double): Double;
begin

end;


function TSymbolCore.GetCustomATMIndex(dLast: double; iMonth : integer): Integer;
var
  i, iATM : Integer;
  MaxDiff : Double;
  aMonthlyItem : TOptionMarket;
begin
  aMonthlyItem := OptionMarkets.OptionMarkets[0];

  if (aMonthlyItem = nil) or ((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count= 0 ) then
  begin
    Result := -1;
    Exit;
  end;

  iATM := -1;
  MaxDiff := 100000000.0;          // big number
  for i:=(aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Count - 1 downto 0 do
  begin
    if Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast) < MaxDiff
    then
    begin
      MaxDiff := Abs((aMonthlyItem.Trees.Trees[iMonth] as TOptionTree).Strikes.Strikes[i].StrikePrice - dLast);
      iATM := i;
    end;
    //else
    //  Break;
  end;
  Result := iATM;
end;


procedure TSymbolCore.GetOpenPriceSymbolList(dPriceLow, dPriceHigh: double;
  bExpect: boolean; var aCall, aPut: TList);
var
  i : integer;
  aOptionMarket : TOptionMarket;
  aStrike : TStrike;
  aSymbol : TSymbol;
  dPrice : double;
  stLog : string;
begin
  aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
  begin
    aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    aSymbol := aStrike.Call as TSymbol;
    dPrice := aSymbol.DayOpen;

    if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
      aCall.Add(aSymbol);

    stLog := Format('Open %s, %.2f', [aSymbol.ShortCode, dPrice]);


    aSymbol := aStrike.Put as TSymbol;
    dPrice := aSymbol.DayOpen;

    stLog := Format('%s, %s, %.2f', [stLog, aSymbol.ShortCode, dPrice]);
    //gEnv.EnvLog(WIN_RATIOS, stLog);
    if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
      aPut.Add(aSymbol);
  end;
end;

procedure TSymbolCore.GetPriceSymbolList(dPriceLow: double; dPriceHigh : double; bExpect : boolean;
  var aCall, aPut: TList);
var
  i : integer;
  aOptionMarket : TOptionMarket;
  aStrike : TStrike;
  aSymbol : TSymbol;
  dPrice : double;
  stLog : string;
begin
  if bExpect then
  begin
    aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
    for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
    begin
      aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
      aSymbol := aStrike.Call as TSymbol;
      dPrice := aSymbol.ExpectPrice;
      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aCall.Add(aSymbol);

      aSymbol := aStrike.Put as TSymbol;
      dPrice := aSymbol.ExpectPrice;
      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aPut.Add(aSymbol);
    end;
  end else
  begin
    aOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
    for i := 0 to aOptionMarket.Trees.FrontMonth.Strikes.Count - 1 do
    begin
      aStrike := aOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
      aSymbol := aStrike.Call as TSymbol;
      dPrice := aSymbol.Last;

      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aCall.Add(aSymbol);

      stLog := Format('Open %s, %.2f', [aSymbol.ShortCode, dPrice]);

      aSymbol := aStrike.Put as TSymbol;
      dPrice := aSymbol.Last;


      if (dPrice >= dPriceLow) and (dPrice <= dPriceHigh) then
        aPut.Add(aSymbol);
      stLog := Format('%s, %s, %.2f', [stLog, aSymbol.ShortCode, dPrice]);
      //gEnv.EnvLog(WIN_RATIOS, stLog);
    end;
  end;
end;

function TSymbolCore.GetStrikeOption(dStrikePrice: double;
  bCall: boolean): TOption;
  var
    i : integer;
    aStrike : TStrike;
    stSrc, stDsc : string;
    FOptionMarket : TOptionMarket;
begin
  Result := nil;
  FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  if FOptionMarket = nil then Exit;  

  stSrc := Format('%.2f', [ dStrikePrice ] );

  for i := 0 to FOptionMarket.Trees.FrontMonth.Strikes.Count-1 do
  begin
    aStrike := FOptionMarket.Trees.FrontMonth.Strikes.Strikes[i];
    stDsc := Format('%.2f', [ aStrike.StrikePrice ] );

    if CompareStr( stDsc, stSrc ) = 0 then
    begin
      if bCall then
        Result := aStrike.Put
      else
        Result := aStrike.Call;

      break;
    end;
  end;
end;
function TSymbolCore.GetSymbolInfo: boolean;
var
  I: Integer;
  aSymbol : TSymbol;
  stUnder, stData : string;
begin
 {
  Result := false;

  for I := 0 to FSymbols.Count - 1 do
  begin
    aSymbol := FSymbols.Symbols[i];
    if (aSymbol is TIndex) or
      (aSymbol is TBond ) or
      (aSymbol is TDollar) then Continue;

    case aSymbol.UnderlyingType of
      utKospi200: stUnder := K2I;
      utMiniKospi200: stUnder := MKI;
      utDollar: stUnder := USD;
      utBond3: stUnder := BM3;
      utBond10: stUnder := BM5;
      else continue;
    end;
    // 3, 12, 4
    stData := Format('%3.3s%12.12s%-4.4d', [ stUnder, aSymbol.Code, aSymbol.Seq ]);

   // if not gEnv.Engine.Api.RequestSymbolInfo( REQ_SYMBOL_INF, i, stData ) then
   //   gEnv.EnvLog( WIN_TEST, '실패 종목정보 : '+ IntToStr(i) +','+stData );
    if not gEnv.Engine.Api.RequestSymbolInfo( REQ_SYMBOL_LIMIT, i, stData ) then
      gEnv.EnvLog( WIN_TEST, '실패 상하한가정보 : '+ IntToStr(i) +','+stData );

    if (i mod 20 ) = 0 then sleep(1);
  end;

  Result := true;
  }
end;




function SortDate(Item1, Item2: Pointer): Integer;
var
  iDate1 , iDate2 : integer;
begin
  iDate1 := Floor( TFuture( Item1).ExpDate );
  iDate2 := Floor( TFuture( Item2).ExpDate );

  if iDate1 < iDate2 then
    Result := 1
  else if iDate1 > iDate2 then
    Result := -1
  else
    Result := 0;
end;

procedure TSymbolCore.MarketsSort;
var
  k, i, j: Integer;
  aFut,bFut, tFut : TFuture;
  stLog : string;
  aMG : TMarketGroup;
  aMarket : TMarket;
  aFutMarket : TFutureMarket;
begin

  for k := 0 to FFutureMarkets.Count - 1 do
  begin
 {$ifdef DEBUG}
      stLog := '';
      for i := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
      begin
        aFut := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
        stLog := stLog + Format(' %s ', [ FormatDateTime('yyyy.mm', aFut.ExpDate)]);
      end;
    //  gEnv.EnvLog( WIN_GI, Format('%s before : %s', [ FFutureMarkets.FutureMarkets[k].FQN, stLog])  );
  {$ENDIF}

      for i := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
        for j := i+1 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
        begin
          aFut := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
          bFut := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[j] as TFuture;

          if  Floor( aFut.ExpDate ) > Floor( bFut.ExpDate ) then
          begin
            tFut := aFut;
            FFutureMarkets.FutureMarkets[k].Symbols.Objects[i]  := bFut;
            FFutureMarkets.FutureMarkets[k].Symbols.Objects[j]  := tFut;
          end;
        end;

 {$ifdef DEBUG}
       stLog := '';
      for i := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
      begin
        aFut := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
        stLog := stLog + Format(' %s ', [ FormatDateTime('yyyy.mm', aFut.ExpDate)]);
      end;
    //  gEnv.EnvLog( WIN_GI, Format('%s after : %s', [ FFutureMarkets.FutureMarkets[k].FQN, stLog])  );
 {$ENDIF}

  end;
 {

  for I := 0 to FSectors.Count - 1 do
  begin
    aMG := FSectors.Groups[i];
    for k := 0 to aMG.Markets.Count - 1 do
    begin
      aMarket := aMG.Markets[k];

      case aMarket.Spec.Market of
        mtFutures:
          begin
            aFutMarket := aMarket as TFutureMarket;

            stLog := '';
            for j := 0 to aFutMarket.Symbols.Count - 1 do
            begin
              aFut := aFutMarket.Symbols.Symbols[j] as TFuture;
              stLog := stLog + Format(' %s ', [ FormatDateTime('yyyy.mm', aFut.ExpDate)]);
            end;

         //   gEnv.EnvLog( WIN_GI, Format('%s %s : %s', [  aFutMarket.Spec.Description,
         //     aFutMarket.Spec.FQN, stLog])  );
          end;
      end;
    end;

  end;
}
  for k := 0 to FFutureMarkets.Count - 1 do
  begin
 {$ifdef DEBUG}
      stLog := '';
      for i := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
      begin
        aFut := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
        stLog := stLog + Format(' %s ', [ FormatDateTime('yyyy.mm', aFut.ExpDate)]);
      end;
      //gEnv.EnvLog( WIN_GI, Format('%s debug : %s', [ FFutureMarkets.FutureMarkets[k].FQN, stLog])  );
  {$ENDIF}
  end;

  // 정렬후  월물 셋팅..

{$IFDEF KR_FUT}
  for k := 0 to FFutureMarkets.Count - 1 do
  begin
    aFut := FFutureMarkets.FutureMarkets[k].Symbols.Objects[0] as TFuture;
    if aFut <> nil then
      FFutureMarkets.FutureMarkets[k].FrontMonth := aFut;


    for I := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
    begin
      aFut  := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
      if aFut = nil then Continue;
      if FFutureMarkets.FutureMarkets[k].MuchMonth = nil then
        FFutureMarkets.FutureMarkets[k].MuchMonth := aFut
      else begin
        if FFutureMarkets.FutureMarkets[k].MuchMonth.PrevVolume < aFut.PrevVolume then
          FFutureMarkets.FutureMarkets[k].MuchMonth := aFut;
      end;
    end;
  end;
{$ENDIF}

{$IFDEF HANA_STOCK}
  for k := 0 to FFutureMarkets.Count - 1 do
  begin
    aFut := FFutureMarkets.FutureMarkets[k].Symbols.Objects[0] as TFuture;
    if aFut <> nil then
      FFutureMarkets.FutureMarkets[k].FrontMonth := aFut;


    for I := 0 to FFutureMarkets.FutureMarkets[k].Symbols.Count - 1 do
    begin
      aFut  := FFutureMarkets.FutureMarkets[k].Symbols.Symbols[i] as TFuture;
      if aFut = nil then Continue;
      if aFut.IsTopStep then begin
        FFutureMarkets.FutureMarkets[k].MuchMonth := aFut;
        break;
      end;
    end;
  end;
{$ENDIF}

end;

procedure TSymbolCore.OptionPrint;
var

  aTree: TOptionTree;
  j,i: Integer;
  aStrike: TStrike;
  stData : string;
  aFutMarket : TFutureMarket;
  aGroup : TMarketGroup;
  aSymbol : TSymbol;
  aMarket : TMarket;
begin

  exit;

  for I := 0 to Underlyings.Count - 1 do
  begin
    aGroup := Underlyings.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Under %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to Exchanges.Count - 1 do
  begin
    aGroup := Exchanges.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Exchanges %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );

  for I := 0 to Sectors.Count - 1 do
  begin
    aGroup := Sectors.Groups[i];
    for j := 0 to aGroup.Markets.Count - 1 do
    begin
      aMarket := aGroup.Markets.Markets[j];
      stData  := Format('Sectors %d(%d), %s, %s, %s ', [
        i,j, aMarket.FQN, aMarket.Spec.FQN, aGroup.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;

  gEnv.EnvLog( WIN_TEST, ''  );


  for I := 0 to FutureMarkets.Count - 1 do
  begin
    aFutMarket := FutureMarkets.FutureMarkets[i];
    for j := 0 to aFutMarket.Symbols.Count - 1 do
    begin
      aSymbol := aFutMarket.Symbols.Symbols[j];
      stData  := Format('%d(%d), %s, %s, (%s) ', [
        i,j, aSymbol.ShortCode, aSymbol.Name, aSymbol.Spec.FQN
        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;



  {
  gEnv.EnvLog( WIN_TEST, FormatDateTime('yyyy-mm-dd', GetQuoteTime )
    , true, '반옵2 손익.csv');

  gEnv.EnvLog( WIN_TEST, FormatDateTime('yyyy-mm-dd', GetQuoteTime )
    , true, '옵션일별 시세표.csv');
  }
  {
  for j := 0 to OptionMarkets.Count - 1 do
  begin

    aTree := OptionMarkets.OptionMarkets[j].Trees.FrontMonth;
    for i := 0 to aTree.Strikes.Count - 1 do
    begin
      aStrike := aTree.Strikes[i];
      stData  := Format('%d(%d) %.2f, %.2f, %.2f, %.2f,' +
                        '%.2f,' +
                        '%.2f, %.2f, %.2f, %.2f, %s',
                        [ j,i,
                          aStrike.Call.PrevOpen,
                          aStrike.Call.PrevHigh,
                          aStrike.Call.PrevLow,
                          astrike.Call.Last,
                          astrike.StrikePrice ,
                          aStrike.Put.PrevOpen,
                          aStrike.Put.PrevHigh,
                          aStrike.Put.PrevLow,
                          astrike.Put.Last,
                          aStrike.Call.Spec.FQN
                        ]);
      gEnv.EnvLog( WIN_TEST, stData);
    end;
  end;
  }
end;

procedure TSymbolCore.PrePare;
begin
  // 최근월물들을 셋
  FMonthlyItem := OptionMarkets.OptionMarkets[0];
  Future       := FutureMarkets.FutureMarkets[0].Futures[0];
end;

const
  BEGIN_OF_USER = 'begin_of_user';
  END_OF_USER = 'end_of_user';

function TSymbolCore.FindNextUserBlock(aEnvFile: TEnvFile; var iP, iEndP: Integer) : Boolean;
var
  i : Integer;
  bStart, bEnd : Boolean;
begin
  i := iP;
  bStart := False;
  bEnd := False;
  Result := False;

  while i <= aEnvFile.Lines.Count-1 do
  begin
    if CompareStr(aEnvFile.Lines[i], BEGIN_OF_USER) = 0 then
    begin
      iP := i;
      bStart := True;
    end else
    if CompareStr(aEnvFile.Lines[i], END_OF_USER) = 0 then
    begin
      iEndP := i;
      bEnd := True;
    end;

    Inc(i);

    if bStart and bEnd and (iEndP > iP) then
      Break;
  end;

  Result := (bStart and bEnd and (iEndP > iP));
end;

procedure TSymbolCore.SaveFavorSymbols;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt, iUserSaveCount : Integer;
  iLong : Integer;
  iVersion : Word;
  stUserID : String;
  aEnvOld, aEnvNew : TEnvFile;
  aFutMarket : TFutureMarket;
begin
  try
    aEnvOld := TEnvFile.Create;
    aEnvNew := TEnvFile.Create;

    if aEnvOld.Exists(FILE_FAVOR_SYMBOL) then
      aEnvOld.LoadLines(FILE_FAVOR_SYMBOL);

    iP := 0;

    if aEnvOld.Lines.Count = 0 then
    begin
      iVersion := 0;
      iUserCnt := 0;
    end else
    begin
      iLong := StrToInt(aEnvOld.Lines[iP]); Inc(iP);
      iVersion := HiWord(iLong);
      iUserCnt := LoWord(iLong);
    end;

      // copy the old information except the one under the current ID
    iUserSaveCount := 0;

    if (iVersion = GURU_VERSION) and (iUserCnt > 0) then
    begin
      for i:=0 to iUserCnt-1 do
      begin
          // find user block
        if not FindNextUserBlock(aEnvOld, iP, iEndP) then Break;

          // get ID for the user block
        stUserID := 'GURU';//aEnvOld.Lines[iP+1];

          // save if the ID is not the current HTS ID
        if CompareStr(stUserID, 'GURU') <> 0 then
        begin
            // copy a USER block
          while iP <= iEndP do
          begin
            aEnvNew.Lines.Add(aEnvOld.Lines[iP]);
            Inc(iP);
          end;

            // increase user count
          Inc(iUserSaveCount);
        end;
          // next
        iP := iEndP + 1;
      end;
    end;

      // save groups under the current HTS ID
    aEnvNew.Lines.Add(BEGIN_OF_USER);
    aEnvNew.Lines.Add('GURU');
    aEnvNew.Lines.Add(IntToStr(FFavorFutMarkets.Count));
    for i:=0 to FFavorFutMarkets.Count-1 do
    begin
      aFutMarket  := TFutureMarket( FFavorFutMarkets.Objects[i] );
      SaveFavorSymbol(aEnvNew, aFutMarket, FFavorFutMarkets.Strings[i]  );
    end;
    aEnvNew.Lines.Add(IntToStr(FFavorFutType));
    aEnvNew.Lines.Add(END_OF_USER);

    Inc(iUserSaveCount);

      // insert version & count
    iLong := MakeLong(iUserSaveCount, GURU_VERSION);
    aEnvNew.Lines.Insert(0, IntToStr(iLong));

      // save to file
    aEnvNew.SaveLines(FILE_FAVOR_SYMBOL);

  finally
    aEnvOld.Free;
    aEnvNew.Free;
  end;

end;

function TSymbolCore.SaveFavorSymbol(aEnvFile: TEnvFile; aFutMarket: TFutureMarket; stName :string): Boolean;
var
  i : Integer;
begin
  Result := False;

  if (aEnvFile = nil) or (aFutMarket = nil) then Exit;

  aEnvFile.Lines.Add(aFutMarket.FQN );
  aEnvFile.Lines.Add(stName); // 펀드그룹에 등록된 계좌수

  gEnv.EnvLog( WIN_TEST, Format('save : %s, %s', [aFutMarket.FQN, stName ] ) );
  Result := True;

end;

procedure TSymbolCore.LoadFavorSymbols;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt : Integer;
  iLong : Integer;
  iVersion : Word;
  stUserID : String;
  aEnvFile : TEnvFile;
begin
  aEnvFile := TEnvFile.Create;
  try
    if (not aEnvFile.Exists(FILE_FAVOR_SYMBOL)) or
       (not aEnvFile.LoadLines(FILE_FAVOR_SYMBOL)) or
       (aEnvFile.Lines.Count = 0)
    then
      Exit;

    iP := 0;
      // version + count
    iLong := StrToInt(aEnvFile.Lines[iP]); Inc(iP);
      // get version
    iVersion := HiWord(iLong);

      // load by version
    if iVersion = 0 then
    begin // conversion from the old version
      iGroupCnt := LoWord(iLong);

      for i:=0 to iGroupCnt - 1 do
        if not LoadFavorSymbol(aEnvFile, iP) then
          Break;

        // make sure version change
      SaveFavorSymbols;
    end else
      // new version
    if iVersion = GURU_VERSION then
    begin
      iUserCnt := LoWord(iLong);    // User ID Number

      for i:=0 to iUserCnt-1 do
      begin
        if not FindNextUserBlock(aEnvFile, iP, iEndP) then Break;

        Inc(iP);
        stUserID := 'GURU';//aEnvFile.Lines[iP];
        Inc(iP);

          // 저장된 ID가 현재 로그인한 ID 와 같을 경우
        if CompareStr(stUserID, 'GURU' ) = 0 then
        begin
          FFavorFutMarkets.Clear;
          iGroupCnt := StrToInt(aEnvFile.Lines[iP]); Inc(iP);

          for j:=0 to iGroupCnt - 1 do
            if not LoadFavorSymbol(aEnvFile, iP) then
              Break;
          FFavorFutType := StrToInt(aEnvFile.Lines[iP]); Inc(iP);
          Break;
        end;         

        iP := iEndP + 1;
      end;  //... for i
    end;  //... if iVersion = 0 then
  finally
    aEnvFile.Free;
  end;

end;


function TSymbolCore.LoadFavorSymbol(aEnvFile: TEnvFile; var iP: Integer): Boolean;
var
  i, iAccCnt: Integer;
  iMultiple : integer;
  stFQN : String;
  aFutMarket : TFutureMarket;
  stName  : string;
begin
  Result := False;

  try


    stFQN      := aEnvFile.Lines[iP];
    aFutMarket := TFutureMarket( FFutureMarkets.Find( stFQN )) ;
    Inc(iP);
    stName     := aEnvFile.Lines[iP];
    Inc(iP);
    //gEnv.EnvLog( WIN_TEST, Format('load %d : %s, %s', [iP, stFQN, stName ] ) );
    if aFutMarket <> nil then
      FFavorFutMarkets.AddObject( stName, aFutMarket);
    Result := True;
  except
    gLog.Add(lkDebug, 'FavorSymbol Storage', 'Load FavorSymbol', 'FavorSymbol loading failure');
  end;

end;



{$IFDEF DONGBU_STOCK}
procedure TSymbolCore.RegisterMuchSymbol( aSymbol : TSymbol );
var
  aFutMarket : TFutureMarket;
begin

  aFutMarket := TFutureMarket(FFutureMarkets.Find( aSymbol.Spec.FQN ));
  if aFutMarket <> nil then
  begin
    aFutMarket.MuchMonth  := TFuture( aSymbol );
    //FSymbolLoader.DeleteArrivedMonthSymbol( aSymbol);
  end;

end;
{$ENDIF}


end.
