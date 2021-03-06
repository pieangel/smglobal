unit Indicator;

interface

uses
  Classes, Graphics, Forms, Windows, Math, SysUtils,
  //
  GleLib, GleTypes, CleStorage,
  Charters, Symbolers;

type
  TPlotColor = (pcAqua, pcBlack, pcBlue, pcDkGray, pcFuchsia, pcGray,
                pcGreen, pcLime, pcLtGray, pcMaroon, pcNavy, pcOlive,
                pcPurple, pcRed, pcSilver, pcTeal, pcWhite, pcYellow);
const
  PLOT_COLORS : array[TPlotColor] of TColor =
               (clAqua, clBlack, clBlue, clDkGray, clFuchsia, clGray,
                clGreen, clLime, clLtGray, clMaroon, clNavy, clOlive,
                clPurple, clRed, clSilver, clTeal, clWhite, clYellow);
  PLOT_COLOR_NAMES : array[TPlotColor] of String =
               ('Aqua', 'Black', 'Blue', 'DkGray', 'Fuchsia', 'Gray',
                'Green', 'Lime', 'LtGray', 'Maroon', 'Navy', 'Olive',
                'Purple', 'Red', 'Silver', 'Teal', 'White', 'Yellow');
  PLOT_COLOR_START = pcAqua;
  PLOT_COLOR_END = pcYellow;

type
  TIndicator = class;

  TIndicatorRefreshMode = (irmHot, irmWarm, irmCold);


  { Numeric Series }

  TNumericSeriesItem = class(TCollectionItem)
  public
    IsValid : Boolean;
    Value : Double;
  end;

  TNumericSeries = class(TCollectionItem)
  protected
    FIndicator : TIndicator;
    FKey : String;
    FData : TCollection;

    //
    procedure FillGap;
    // property methods
    function GetValid(i:Integer) : Boolean;
    function GetValue(i:Integer) : Double;
    function GetIValue(i:integer) : Double;
    procedure SetIValue(i:Integer; dValue : Double);
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    constructor CustomCreate(aColl : TCollection); // used by childern

    procedure Tick;
    function Count : Integer;
    procedure GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);

    property Key : String read FKey write FKey;
    property Indicator : TIndicator read FIndicator write FIndicator;

    property Valids[i:Integer] : Boolean read GetValid;
    property Values[i:Integer] : Double read GetValue;
    property IValues[i:Integer] : Double read GetIValue write SetIValue; default;
  end;

  TNumericSeriesStore = class(TCollection)
  public
    constructor Create;

    procedure Tick;
    function Get(aIndicator : TIndicator; stKey : String) : TNumericSeries;
  end;

  { indicator }


  TPlotStyle = (psLine, psHistogram, psDot, psBarHigh, psBarLow );

  TPlotSeriesItem = class(TNumericSeriesItem)
  public
    Color : TColor;
  end;

  TPlotSeries = class(TNumericSeries)
  protected
    function GetColor(i:Integer) : TColor;
    function GetIColor(i:Integer) : TColor;
    procedure SetIColor(i:Integer; aColor : TColor);
  public
    constructor Create(aColl : TCollection); override;

    property Colors[i:Integer] : TColor read GetColor;
    property IColors[i:Integer] : TColor read GetIColor write SetIColor;
  end;

  TPlotItem = class(TCollectionItem)
  private
    FCollection : TCollection;
    FData : TPlotSeries;
  public
    Title : String;
    Style : TPlotStyle;
    Color : TColor;
    Weight : Integer;

    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    procedure ClearData;

    procedure Assign(Source : TPersistent); override;
    property Data : TPlotSeries read FData;
  end;

  TParamType = (ptInteger, ptFloat, ptString, ptBoolean, ptColor, ptAccount, ptSymbol);

  TParamItem = class(TCollectionItem)
  private
    FParamType : TParamType;

    FInteger : Integer;
    FFloat : Double;
    FString : String;
    FBoolean : Boolean;
    FColor : TPlotColor;

    function GetInteger : Integer;
    procedure SetInteger(iValue : Integer);
    function GetFloat : Double;
    procedure SetFloat(dValue : Double);
    function GetString : String;
    procedure SetString(stValue : String);
    function GetBoolean : Boolean;
    procedure SetBoolean(bValue : Boolean);
    function GetColor : TPlotColor;
    procedure SetColor(aColor : TPlotColor);

    function GetAccount: string;
    procedure SetAccount(const Value: string);
    function GetSymbol: string;
    procedure SetSymbol(const Value: string);
  public
    Title : String;
    Precision : Integer;

    procedure Assign(Source : TPersistent); override;

    property ParamType : TParamType read FParamType;

    property AsInteger : Integer read GetInteger write SetInteger;
    property AsFloat : Double read GetFloat write SetFloat;
    property AsString : String read GetString write SetString;
    property AsBoolean : Boolean read GetBoolean write SetBoolean;
    property AsColor : TPlotColor read GetColor write SetColor;
    property AsAccount : string read GetAccount write SetAccount;
    property AsSymbol : string read GetSymbol write SetSymbol;
  end;

  TIndicatorPosition = (ipMain, ipSub);

  TIndicator = class(TSeriesCharter)
  private

    FBAccount: boolean;
    FAdded: boolean;
    function GetPlot(i:Integer) : TNumericSeries;
    function GetParam(stTitle : String) : TParamItem;
    function GetParamDesc: String;
    function GetBarLowItem : TPlotItem;


  protected
    FSymboler : TSymboler;
    FNumericSeriesStore : TNumericSeriesStore;
    FCurrentBar : Integer;

    FParams : TCollection;
    FPlots : TCollection;

    procedure DoInit; virtual;
    procedure DoPlot; virtual;
    //
    function Expression(stExpr : String) : TNumericSeries;
    function NumericSeries(stKey : String) : TNumericSeries;

    procedure AddParam(stTitle : String; iPrecision : Integer; dDef : Double); overload;
    procedure AddParam(stTitle : String; iDef : Integer); overload;
    procedure AddParam(stTitle : String; stValue : String); overload;
    procedure AddParam(stTitle : String; bValue : Boolean); overload;
    procedure AddParam(stTitle : String; aColor : TPlotColor); overload;
    procedure AddParam(stTitle : String; stValue : String; bObject : boolean); overload;

    procedure AddPlot(stTitle : String; aStyle : TPlotStyle; aColor : TColor;
        iWeight : Integer);
    //
    procedure Plot(i:Integer; dValue : Double; iDisplace : Integer = 0;
               aColor : TColor = -1); overload;
    procedure Plot(i:Integer; dValue : Double; iDisplace : Integer;
               aColor : TPlotColor); overload;
    procedure SetPlotColor(i : Integer; aColor : TPlotColor);
    //function GetPlotColor(i : Integer) : TPlotColor;
    procedure ClearPlotData;
  public
    constructor Create(aSymboler : TSymboler);virtual;
    destructor Destroy; override;

    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure GetPersistence(aBitStream : TMemoryStream);

    procedure SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    // default config
    procedure SetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);

    // config
    function Config(aForm : TForm) : Boolean; override;
    procedure CloneParams(aColl : TCollection);
    procedure ClonePlots(aColl : TCollection);
    procedure AssignParams(aColl : TCollection);
    procedure AssignPlots(aColl : TCollection);
    // draw
    procedure GetMinMax(iStart, iEnd : Integer); override;
    function GetDateTimeDesc(iBarIndex : Integer) : String; override;
    function SpotData(iBarIndex : Integer) : String; override;
    procedure HintData(iBarIndex : Integer; stHints : TStringList); override;
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean); override;
    procedure DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                        var iLeft : Integer; bSelected : Boolean); override;
    // data
    procedure Refresh(irmValue : TIndicatorRefreshMode); virtual;
    procedure Update;virtual;
    procedure Add;virtual;
    // basic functions
    function High : TNumericSeries;
    function Low : TNumericSeries;
    function Close : TNumericSeries;
    function Open : TNumericSeries;
    function Volume : TNumericSeries;
    function Side : TNumericSeries; // used only for tick (2004.2.16)
    function SideVolume : TNumericSeries;
    function SymbolDelta  :  double;

    //
    function FutVol : TNumericSeries;
    function OptVol : TNumericSeries;
    function CallVol : TNumericSeries;
    function PutVol : TNumericSeries;

    function FutVol2 : TNumericSeries;
    function OptVol2 : TNumericSeries;
    function CallVol2 : TNumericSeries;
    function PutVol2 : TNumericSeries;

    function SymbolPL : TNumericSeries;

    //
    function LongFill : TNumericSeries;
    function ShortFill : TNumericSeries;
    //
    function UVol : TNumericSeries;
    function DVol : TNumericSeries;
    function NetVol : TNumericSeries;
    function vSpread: TnumericSeries;
    function vStandLine: TnumericSeries;
    function vMASpread: TnumericSeries;

    function AskCnt: TnumericSeries;
    function BidCnt: TnumericSeries;
    function SAR : TnumericSeries;


    // common functions
    function Average(Key:String; Price:TNumericSeries; Length:Integer) : TNumericSeries;
    function AverageFC(Key:String; Price:TNumericSeries; Length:Integer) : TNumericSeries;
    function WAverage(Key:String; Price:TNumericSeries; Length:Integer) : TNumericSeries;
    function XAverage(Key:String; Price:TNumericSeries; Length:Integer) : TNumericSeries;
    function StdDev(Key:String; Price:TNumericSeries; Length:Integer) : TNumericSeries;
    function Lowest(Price : TNumericSeries; Length : Integer) : Double;
    function Highest(Price : TNumericSeries; Length : Integer) : Double;
    //

    procedure SetObject; virtual;

    procedure LoadEnv(aStorage: TStorage; idx : integer = 0);
    procedure SaveEnv(aStorage: TStorage; idx : integer = 0);
    //
    property CurrentBar : Integer read FCurrentBar;
    property Symboler : TSymboler read FSymboler;
    //
    property Plots[i:Integer] : TNumericSeries read GetPlot;
    property Params[stTitle : String] : TParamItem read GetParam;
    property ParamDesc : String read GetParamDesc;

    //
    property BAccount  : boolean read FBAccount write FBAccount;
    property Added     : boolean read FAdded write FAdded;
  end;

  TIndicatorClass = class of TIndicator;

  { Indicator List }

  TIndicatorListItem = class(TCollectionItem)
  public
    Title : String;
    ClassDesc : String;
    IndicatorClass : TIndicatorClass;
  end;

// add a indicator to the list
// you can show the result in the indicator selection dialog
procedure AddIndicator(stTitle, stClassDesc : String; aClass : TIndicatorClass);
function FindIndicator(stClassDesc : String) : TIndicatorClass;

function PlotColor(stColorName : String) : TPlotColor;

var
  gIndicatorList : TCollection;

implementation

uses DIndicatorCfg, XTerms, GAppEnv, CleFQN, CleSymbols, CleQuoteTimers, CalcGreeks;

//---------------------< Uitlity functions >-----------------------//

function PlotColor(stColorName : String) : TPlotColor;
var
  pcValue : TPlotColor;
begin
  Result := pcBlack;

  for pcValue := PLOT_COLOR_START to PLOT_COLOR_END do
    if CompareStr(PLOT_COLOR_NAMES[pcValue], stColorName) = 0 then
    begin
      Result := pcValue;
      Break;
    end;
end;

//========================================================================//
                     { TNumericSeries }
//========================================================================//

constructor TNumericSeries.Create(aColl : TCollection);
begin
  inherited Create(aColl);

  FData := TCollection.Create(TNumericSeriesItem);
end;

destructor TNumericSeries.Destroy;
begin
  FData.Free;
  //
  inherited;
end;

constructor TNumericSeries.CustomCreate(aColl : TCollection); // used by childern
begin
  inherited Create(aColl);
  // children have to create FData object
end;

// data access in normal order

function TNumericSeries.GetValid(i:Integer) : Boolean;
begin
  if (i>=0) and (i<FData.Count) then
    Result := (FData.Items[i] as TNumericSeriesItem).IsValid
  else
    Result := False;
end;

function TNumericSeries.GetValue(i:Integer) : Double;
begin
  if (i>=0) and (i<FData.Count) then
    Result := (FData.Items[i] as TNumericSeriesItem).Value
  else
    Result := 0.0;
end;

// data access in reverse order, used in indicator calculation

procedure TNumericSeries.Tick;
var
  aItem : TNumericSeriesItem;
begin
  if FData.Count > 0 then
    aItem := FData.Items[FData.Count-1] as TNumericSeriesItem
  else
    aItem := nil;
  //-- add an item and copy previous value
  with FData.Add as TNumericSeriesItem do
  if aItem <> nil then
  begin
    IsValid := aItem.IsValid;
    Value := aItem.Value;
  end else
  begin
    IsValid := False;
    Value := 0.0;
  end;
end;

function TNumericSeries.Count : Integer;
begin
  Result := FData.Count;
end;

procedure TNumericSeries.GetMinMax(iStart, iEnd : Integer; var dMin, dMax : Double);
var
  i, iCnt : Integer;
begin
  iCnt := 0;
  dMin := 0.0;
  dMax := 0.0;
  //
  for i:=iStart to iEnd do
    if (i>=0) and (i<FData.Count) and Valids[i] then
    with FData.Items[i] as TNumericSeriesItem do
    if iCnt > 0 then
    begin
      dMin := Min(dMin, Value);
      dMax := Max(dMax, Value);
    end else
    begin
      Inc(iCnt);
      dMin := Value;
      dMax := Value;
    end;
end;

procedure TNumericSeries.FillGap;
var
  i : Integer;
begin
  for i:=1 to FIndicator.CurrentBar-FData.Count do
  with FData.Add as TNumericSeriesItem do
  begin
    IsValid := False;
    Value := 0.0;
  end;
end;

function TNumericSeries.GetIValue(i:Integer) : Double;
var
  iP : Integer;
begin
  if FData.Count < FIndicator.CurrentBar then FillGap;
  //
  iP := FIndicator.CurrentBar - 1 - i;
  //
  if (iP >= 0) and (iP < FData.Count) then
    Result := (FData.Items[iP] as TNumericSeriesItem).Value
  else
    Result := 0.0;
end;

procedure TNumericSeries.SetIValue(i:Integer; dValue : Double);
var
  j, iP : Integer;
begin
  if FData.Count < FIndicator.CurrentBar then FillGap;
  //
  iP := FIndicator.CurrentBar - 1 - i;
  //
  if iP > FData.Count-1 then
    for j:=1 to iP-(FData.Count-1) do
    with FData.Add as TNumericSeriesItem do
    begin
      IsValid := False;
      Value := 0.0;
    end;
  //
  if (iP >= 0) and (iP < FData.Count) then
  with FData.Items[iP] as TNumericSeriesItem do
  begin
    IsValid := True;
    Value := dValue;
  end;
end;

//========================================================================//
                     { TNumericSeriesStore }
//========================================================================//

constructor TNumericSeriesStore.Create;
begin
  inherited Create(TNumericSeries);
end;

procedure TNumericSeriesStore.Tick;
var
  i : Integer;
begin
  for i:=0 to Count-1 do
  (Items[i] as TNumericSeries).Tick;
end;

//
// (public) find a Numeric Series having a same key
//          , or create a new NumericSeries
function TNumericSeriesStore.Get(aIndicator : TIndicator;
  stKey: String): TNumericSeries;
var
  i : Integer;
begin
  Result := nil;
  //
  for i:=0 to Count-1 do
    with Items[i] as TNumericSeries do
    if Key = stKey then
    begin
      Result := Items[i] as TNumericSeries;
      Break;
    end;
  //
  if Result = nil then
  begin
    Result := Add as TNumericSeries;
    Result.Key := stKey;
    Result.Indicator := aIndicator;
  end;
end;

//==================================================================//
                    { TParamItem }
//==================================================================//

procedure TParamItem.Assign(Source : TPersistent);
var
  aParam : TParamItem;
begin
  if Source is TParamItem then
  begin
    aParam := Source as TParamItem;

    Title := aParam.Title;
    Precision := aParam.Precision;

    FParamType := aParam.FParamType;
    FInteger := aParam.FInteger;
    FFloat := aParam.FFloat;
    FString := aParam.FString;
    FBoolean := aParam.FBoolean;
    FColor := aParam.FColor;
  end;
end;

function TParamItem.GetInteger : Integer;
begin
  case FParamType of
    ptInteger : Result := FInteger;
    ptFloat   : Result := Round(FFloat);
    ptString  : Result := StrToIntDef(FString, 0);
    ptBoolean : if FBoolean then
                  Result := 1
                else
                  Result := 0;
    ptColor   : try
                  Result := PLOT_COLORS[FColor];
                except
                  Result := 0;
                end;

  end;
end;



procedure TParamItem.SetInteger(iValue : Integer);
begin
  FParamType := ptInteger;
  //
  FInteger := iValue;
end;


function TParamItem.GetFloat : Double;
begin
  case FParamType of
    ptInteger : Result := FInteger;
    ptFloat   : Result := FFloat;
    ptString  : Result := 0.0;
    ptBoolean : Result := 0.0;
    ptColor   : Result := 0.0;
  end;
end;

procedure TParamItem.SetFloat(dValue : Double);
begin
  FParamType := ptFloat;
  //
  FFloat := dValue;
end;

function TParamItem.GetString : String;
begin
  case FParamType of
    ptInteger : Result := IntToStr(FInteger);
    ptFloat   : Result := Format('%.*f', [Precision, FFloat]);
    ptString  : Result := FString;
    ptBoolean : if FBoolean then
                  Result := 'True'
                else
                  Result := 'False';
    ptColor   : try
                  Result := PLOT_COLOR_NAMES[FColor];
                except
                  Result := '';
                end;
    ptAccount , ptSymbol : Result := FString;
  end;
end;

function TParamItem.GetSymbol: string;
begin
  Result := FString;
end;

procedure TParamItem.SetString(stValue : String);
begin
  FParamType := ptString;
  //
  FString := stValue;
end;

procedure TParamItem.SetSymbol(const Value: string);
begin
  FParamType := ptSymbol;
  //
  FString := Value;
end;

function TParamItem.GetAccount: string;
begin
  Result := FString;
end;

function TParamItem.GetBoolean : Boolean;
begin
  case FParamType of
    ptInteger : Result := (FInteger = 1);
    ptFloat   : Result := False;
    ptString  : Result := (CompareStr('True', FString) = 0);
    ptBoolean : Result := FBoolean;
    ptColor   : Result := False;
  end;
end;

procedure TParamItem.SetAccount(const Value: string);
begin
  FParamType := ptAccount;
  //
  FString := Value;
end;

procedure TParamItem.SetBoolean(bValue : Boolean);
begin
  FParamType := ptBoolean;
  //
  FBoolean := bValue;
end;

function TParamItem.GetColor : TPlotColor;
begin
  case FParamType of
    ptInteger : Result := pcBlack;
    ptFloat   : Result := pcBlack;
    ptString  : Result := pcBlack;
    ptBoolean : Result := pcBlack;
    ptColor   : Result := FColor;
  end;
end;

procedure TParamItem.SetColor(aColor : TPlotColor);
begin
  FParamType := ptColor;
  //
  FColor := aColor;
end;

//==================================================================//
                    { TPlotSeries }
//==================================================================//

constructor TPlotSeries.Create(aColl : TCollection);
begin
  inherited CustomCreate(aColl);

  FData := TCollection.Create(TPlotSeriesItem);
end;

function TPlotSeries.GetColor(i:Integer) : TColor;
begin
  if (i>=0) and (i<=FData.Count-1) then
    Result := (FData.Items[i] as TPlotSeriesItem).Color
  else
    Result := clBlack;
end;

function TPlotSeries.GetIColor(i:Integer) : TColor;
var
  iP : Integer;
begin
  if FData.Count < FIndicator.CurrentBar then FillGap;
  //
  iP := FIndicator.CurrentBar - 1 - i;
  //
  if (iP >= 0) and (iP <= FData.Count-1) then
    Result := (FData.Items[iP] as TPlotSeriesItem).Color
  else
    Result := clBlack;
end;

procedure TPlotSeries.SetIColor(i:Integer; aColor : TColor);
var
  j, iP : Integer;
begin
  if FData.Count < FIndicator.CurrentBar then FillGap;
  //
  iP := FIndicator.CurrentBar - 1 - i;
  //
  if iP > FData.Count-1 then
    for j:=1 to iP-(FData.Count-1) do
    with FData.Add as TPlotSeriesItem do
    begin
      Color := clBlack;
    end;
  //
  if (iP >= 0) and (iP < FData.Count) then
  with FData.Items[iP] as TPlotSeriesItem do
  begin
    Color := aColor;
  end;
end;

//==================================================================//
                    { TPlotItem }
//==================================================================//

constructor TPlotItem.Create(aColl : TCollection);
begin
  inherited Create(aColl);

  FCollection := TCollection.Create(TPlotSeries);
  FData := FCollection.Add as TPlotSeries;
end;

destructor TPlotItem.Destroy;
begin
  FCollection.Free;

  inherited;
end;

procedure TPlotItem.Assign(Source : TPersistent);
var
  aPlot : TPlotItem;
begin
  if Source is TPlotItem then
  begin
    aPlot := Source as TPlotItem;
    Title := aPlot.Title;
    Style := aPlot.Style;
    Color := aPlot.Color;
    Weight := aPlot.Weight;
  end;
end;

procedure TPlotItem.ClearData;
begin
  FData.FData.Clear;
end;

//==================================================================//
                    { TIndicator }
//==================================================================//

constructor TIndicator.Create(aSymboler : TSymboler);
begin
  inherited Create;

  //FIndicatorType := dtBasic;
  //FValueUnit := ptFloat;
  FBAccount  := false;

  FSymboler := aSymboler;
  //
  FParams := TCollection.Create(TParamItem);
  FPlots := TCollection.Create(TPlotItem);
  //
  FNumericSeriesStore := TNumericSeriesStore.Create;
  //
  FPosition := cpSubGraph;
  FScaleType := stScreen;
  //
  FAdded  := false;
  DoInit;
end;



destructor TIndicator.Destroy;
begin
  FNumericSeriesStore.Free;
  FPlots.Free;
  FParams.Free;

  inherited;
end;

procedure TIndicator.SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  SetPersistence(Stream);
end;

function TIndicator.ShortFill: TNumericSeries;
var
  aTerm : TXTermItem;
begin
  Result := NumericSeries('ShortFill');
  if FCurrentBar >= 1 then
  begin
    aTerm := FSymboler.XTerms.XTerms[FCurrentBar-1];
    aTerm.CalcAvgFill(1);
    Result[0] := FSymboler.XTerms[FCurrentBar-1].ShortFill;
  end;
end;


procedure TIndicator.GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  GetPersistence(Stream);
end;



procedure TIndicator.SetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  SetPersistence(Stream);
end;

procedure TIndicator.SetObject;
begin

end;

procedure TIndicator.GetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  GetPersistence(Stream);
end;


procedure TIndicator.SetPersistence(aBitStream : TMemoryStream);
var
  i : Integer;
  szBuf : array[0..101] of Char;
begin
  with aBitStream do
  begin
    Read(FPosition, SizeOf(TCharterPosition));
    Read(FScaleType, SizeOf(TScaleType));

    // parameters
    for i:=0 to FParams.Count-1 do
    with FParams.Items[i] as TParamItem do
    begin
      case FParamType of
        ptInteger : Read(FInteger, SizeOf(Integer));
        ptFloat   : Read(FFloat, SizeOf(Double));
        ptString  :
                   begin
                     Read(szBuf, 91);
                     FString := szBuf;
                     FString := Trim(FString);
                   end;
        ptBoolean : Read(FBoolean, SizeOf(Boolean));
        ptColor   : Read(FColor, SizeOf(TPlotColor));
      end;
    end;

    // plots
    for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      Read(Style, SizeOf(TPlotStyle));
      Read(Color, SizeOf(TColor));
      Read(Weight, SizeOf(Integer));
    end;
  end;
end;

procedure TIndicator.GetPersistence(aBitStream : TMemoryStream);
var
  i : Integer;
  szBuf : array[0..101] of Char;
  stValue : String;
begin
  with aBitStream do
  begin
    Write(FPosition, SizeOf(TCharterPosition));
    Write(FScaleType, SizeOf(TScaleType));

    // parameters
    for i:=0 to FParams.Count-1 do
    with FParams.Items[i] as TParamItem do
    begin
      case FParamType of
        ptInteger : Write(FInteger, SizeOf(Integer));
        ptFloat   : Write(FFloat, SizeOf(Double));
        ptString  :
                    begin
                      stValue := Format('%-90s', [FString]);
                      StrPCopy(szBuf, stValue);
                      Write(szBuf, Length(stValue)+1);
                    end;
        ptBoolean : Write(FBoolean, SizeOf(Boolean));
        ptColor   : Write(FColor, SizeOf(TPlotColor));
      end;
    end;

    // plots
    for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      Write(Style, SizeOf(TPlotStyle));
      Write(Color, SizeOf(TColor));
      Write(Weight, SizeOf(Integer));
    end;
  end;
end;

//------------------------< >----------------------//

procedure TIndicator.DoInit;
begin
  // should be overrided by child
end;

procedure TIndicator.DoPlot;
begin
  // should be overrided by child
end;

//------------------------< AddParam overload >----------------------//

procedure TIndicator.AddParam(stTitle : String; iPrecision : Integer;
     dDef : Double);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    Precision := iPrecision;
    AsFloat := dDef;
  end;
end;

procedure TIndicator.AddParam(stTitle : String; iDef : Integer);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    AsInteger := iDef;
  end;
end;

procedure TIndicator.AddParam(stTitle : String; stValue : String);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    AsString := stValue;
  end;
end;

procedure TIndicator.AddParam(stTitle : String; bValue : Boolean);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    AsBoolean := bValue;
  end;
end;

procedure TIndicator.AddParam(stTitle : String; aColor : TPlotColor);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    AsColor := aColor;
  end;
end;

//------------------------< Add Plot >-------------------------//

procedure TIndicator.AddPlot(stTitle : String; aStyle : TPlotStyle; aColor : TColor;
    iWeight : Integer);
begin
  with FPlots.Add as TPlotItem do
  begin
    Title := stTitle;
    Style := aStyle;
    Color := aColor;
    Weight := iWeight;
    //
    Data.Indicator := Self;
  end;
end;

//----------------------< Plot >------------------------------//

function TIndicator.CallVol: TNumericSeries;
begin
  Result := NumericSeries('CallVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].CallVol;
end;

function TIndicator.CallVol2: TNumericSeries;
begin
  Result := NumericSeries('CallVol2');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].CallVol2;
end;

procedure TIndicator.ClearPlotData;
var
  i : Integer;
begin
  for i:=0 to FPlots.Count-1 do
    (FPlots.Items[i] as TPlotItem).ClearData;
end;

procedure TIndicator.Plot(i:Integer; dValue : Double; iDisplace : Integer;
  aColor : TColor);
var
  aItem : TPlotItem;
begin
  if (i >= 0) and (i < FPlots.Count) then
  begin
    aItem := FPlots.Items[i] as TPlotItem;
    aItem.Data.IValues[iDisplace] := dValue;
    if aColor >= 0 then
      aItem.Data.IColors[iDisplace] := aColor
    else
      aItem.Data.IColors[iDisplace] := aItem.Color;
  end;
end;

procedure TIndicator.Plot(i:Integer; dValue : Double; iDisplace : Integer;
               aColor : TPlotColor);
begin
  Plot(i, dValue, iDisplace, PLOT_COLORS[aColor]);
end;


function TIndicator.PutVol: TNumericSeries;
begin
  Result := NumericSeries('PutVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].PutVol;
end;

function TIndicator.PutVol2: TNumericSeries;
begin
  Result := NumericSeries('PutVol2');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].PutVol2;
end;

procedure TIndicator.SetPlotColor(i : Integer; aColor : TPlotColor);
var
  aItem : TPlotItem;
begin
  if (i >= 0) and (i <= FPlots.Count-1) then
  begin
    aItem := FPlots.Items[i] as TPlotItem;
    aItem.Color := PLOT_COLORS[aColor];
  end;
end;



function TIndicator.NumericSeries(stKey : String) : TNumericSeries;
begin
  Result := FNumericSeriesStore.Get(Self, stKey);
end;

function TIndicator.Expression(stExpr : String) : TNumericSeries;
begin
  Result := nil;
  if stExpr = '' then Exit;
  //
  Result := NumericSeries(stExpr);
end;

function TIndicator.FutVol: TNumericSeries;
begin
  Result := NumericSeries('FutVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].FutVol;

end;

function TIndicator.FutVol2: TNumericSeries;
begin
  Result := NumericSeries('FutVol2');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].FutVol2;
end;

function TIndicator.GetPlot(i:Integer) : TNumericSeries;
begin
  if (i>=0) and (i<FPlots.Count) then
    Result := (FPlots.Items[i] as TPlotItem).Data
  else
    Result := nil;
end;

function TIndicator.GetParam(stTitle : String) : TParamItem;
var
  i : Integer;
begin
  Result := nil;
  //
  for i:=0 to FParams.Count-1 do
  with FParams.Items[i] as TParamItem do
    if Title = stTitle then
    begin
      Result := FParams.Items[i] as TParamItem;
      Break;
    end;
end;

//--------------------< Public Methods >----------------------//

procedure TIndicator.CloneParams(aColl : TCollection);
begin
  if aColl <> nil then aColl.Assign(FParams);
end;

procedure TIndicator.ClonePlots(aColl : TCollection);
begin
  if aColl <> nil then aColl.Assign(FPlots);
end;


procedure TIndicator.AssignParams(aColl : TCollection);
var
  i : Integer;
begin
  if aColl.Count <> FParams.Count then Exit;
  //
  for i:=0 to FParams.Count-1 do
    FParams.Items[i].Assign(aColl.Items[i]);
end;

procedure TIndicator.AssignPlots(aColl : TCollection);
var
  i : Integer;
begin
  if aColl.Count <> FPlots.Count then Exit;
  //
  for i:=0 to FPlots.Count-1 do
    FPlots.Items[i].Assign(aColl.Items[i]);
end;

function TIndicator.Config(aForm : TForm) : Boolean;
var
  aDlg : TIndicatorConfig;
  aPosition : TCharterPosition;
begin
  aDlg := TIndicatorConfig.Create(aForm);
  try
    aPosition := Position;
    //
    Result := aDlg.Open(Self);
    {
    if Result then
      gWin.SaveClassDefault('Indicators', FTitle, GetDefault);
    }
    //
    if Result and (Position <> aPosition) and Assigned(FOnMove) then
      FOnMove(Self);
  finally
    aDlg.Free;
  end;
end;

//------------------------< Manipulate Data >---------------------------//

// (public)
// Remake data
//
procedure TIndicator.Refresh(irmValue : TIndicatorRefreshMode);
begin
  ClearPlotData;
  FNumericSeriesStore.Clear;
  FCurrentBar := 0;
  //
  while FCurrentBar < FSymboler.XTerms.Count do
  begin
    Inc(FCurrentBar);
    //
    FNumericSeriesStore.Tick;

    // copy basic values
    High; Low; Close; Open; Volume; Side;

    // do indicator specific
    DoPlot;
  end;
end;

// (public)
// Update the last data
//
procedure TIndicator.Update;
begin
  // copy basic values
  FAdded  := false;
  High; Low; Close; Open; Volume; Side;
  // do indicator specific
  LongFill;
  ShortFill;
  DoPlot;
end;

function TIndicator.UVol: TNumericSeries;
begin
  Result := NumericSeries('UVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].UVol;
end;

function TIndicator.DVol: TNumericSeries;
begin
  Result := NumericSeries('DVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].DVol * -1;
end;

function TIndicator.NetVol: TNumericSeries;
begin
  Result := NumericSeries('NetVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].UVol - (FSymboler.XTerms[FCurrentBar-1].DVol );
end;

// (public)
// Add a data item
//
procedure TIndicator.Add;
begin
  Inc(FCurrentBar);
  FAdded  := true;
  //
  FNumericSeriesStore.Tick;
  // copy basic values
  High; Low; Close; Open; Volume; Side;
  // do indicator specific
  LongFill;
  ShortFill;
  DoPlot;
end;

//----------------------< Draw >-------------------------------//

function TIndicator.GetDateTimeDesc(iBarIndex : Integer) : String;
begin
  if FSymboler <> nil then
    Result := FSymboler.XTerms.DateTimeDesc(iBarIndex)
  else
    Result := '';
end;

procedure TIndicator.GetMinMax(iStart, iEnd : Integer);
var
  i : Integer;
  dMinTot, dMaxTot, dMin, dMax, dMargin : Double;
  bHistogram : Boolean;
begin
  bHistogram := False;
  //-- get min/max
  if FScaleType = stSymbol then
  begin
    FMin := FSymboler.MinValue;
    FMax := FSymboler.MaxValue;
  end else
  begin
    dMinTot := 0.0;
    dMaxTot := 0.0;
    // get min max
    for i:=0 to FPlots.Count-1 do
      with FPlots.Items[i] as TPlotItem do
      if i > 0 then
      begin
        if FScaleType = stScreen then
          Data.GetMinMax(iStart, iEnd, dMin, dMax)
        else
          Data.GetMinMax(0, Data.Count-1, dMin, dMax);
        //
        if Style = psHistogram then bHistogram := True;
        //
        dMinTot := Min(dMinTot, dMin);
        dMaxTot := Max(dMaxTot, dMax);
      end else
      begin
        if FScaleType = stScreen then
          Data.GetMinMax(iStart, iEnd, dMinTot, dMaxTot)
        else
          Data.GetMinMax(0, Data.Count-1, dMinTot, dMaxTot);
        //
        if Style = psHistogram then bHistogram := True;
      end;

    //-- apply margin

    if IsZero(dMaxTot - dMinTot) then
    begin
      if IsZero(dMaxTot) then
        dMargin := 0.01
      else
        dMargin := dMaxTot * 0.05;
    end else
      dMargin := (dMaxTot - dMinTot) * 0.05;

    dMaxTot := dMaxTot + dMargin;
    dMinTot := dMinTot - dMargin;

    //-- save
    FMin := dMinTot;
    FMax := dMaxTot;
  end;
end;


function TIndicator.GetBarLowItem : TPlotItem;
var
  i : Integer;
begin
  Result := nil;
  
  for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
      if Style = psBarLow then
      begin
        Result := FPlots.Items[i] as TPlotItem;
        Break;
      end;
end;

procedure TIndicator.Draw(const aCanvas : TCanvas; const aRect : TRect;
               const iStart, iEnd, iBarWidth : Integer; const bSelected : Boolean);
const
  SEL_WIDTH = 3;
  WING_WIDTHS : array[1..14] of Integer = (1,1,1,2,3,4,4,5,5,6,6,8,8,10);
var
  dRY : Double;
  dTmp : double;
  iCnt, iStep : Integer;
  i, j, iX, ixx, iY, iY2, iY0, iCenter : Integer;
  aBrushColor, aFontColor, aPenColor : TColor;
  aPenMode : TPenMode;
  aItem , aLowItem : TPlotItem;
  aData : TPlotSeries;
  iWingWidth : Integer;
begin
  if FMax = FMin then Exit;
  //-- Ratio
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  iStep := 50 div iBarWidth;
  //--
  aBrushColor := aCanvas.Brush.Color;
  aFontColor := aCanvas.Font.Color;
  aPenColor := aCanvas.Pen.Color;

  //-- bar
  for j:=0 to FPlots.Count-1 do
  begin
    aItem :=  FPlots.Items[j] as TPlotItem;
    with aItem do
    case Style of
      psLine :
        begin
          iCnt := 0;
          //
          for i:=iStart to Data.Count-1 do
          begin

            if Data.Valids[i] then
            begin
              aCanvas.Pen.Color := Data.Colors[i];
              aCanvas.Pen.Width := Weight;

              iX := (i-iStart)*iBarWidth + aRect.Left+1;
              if iX + iBarWidth > aRect.Right-1 then Break;

              dTmp := Data.Values[i];
              iY := aRect.Bottom - Round((dTmp - FMin)*dRY);
              if iCnt > 0 then
                aCanvas.LineTo(iX, iY)
              else
                aCanvas.MoveTo(iX, iY);
              //
              Inc(iCnt);
              //
              if bSelected then
              begin
                if iCnt mod iStep = 0 then
                begin
                  aPenMode := aCanvas.Pen.Mode;
                  aCanvas.Brush.Color := clWhite;
                  aCanvas.Pen.Mode := pmXOR;
                  aCanvas.Pen.Color := clWhite;
                  aCanvas.Rectangle(
                      Rect(iX-SEL_WIDTH, iY-SEL_WIDTH, iX+SEL_WIDTH, iY+SEL_WIDTH));
                  aCanvas.Pen.Mode := aPenMode;
                end;
              end;
            end;
          end;// for data
        end;
      psDot :
        begin
          iCnt := 0;
          //
          for i:=iStart to Data.Count-1 do
          if Data.Valids[i] then
          begin
            aCanvas.Pen.Color := Data.Colors[i];

            iX := (i-iStart)*iBarWidth + aRect.Left+1;
            if iX + iBarWidth > aRect.Right-1 then Break;

            dTmp  := Data.Values[i];
            iY := aRect.Bottom - Round((dTmp - FMin)*dRY);

            aCanvas.Pixels[iX,iY] := Data.Colors[i];
            // added on 2002.12.30
            aCanvas.Pixels[iX+1,iY] := Data.Colors[i];
            aCanvas.Pixels[iX,iY+1] := Data.Colors[i];
            aCanvas.Pixels[iX+1,iY+1] := Data.Colors[i];
            //
            if bSelected then
            begin
              Inc(iCnt);
              if iCnt mod iStep = 0 then
              begin
                aPenMode := aCanvas.Pen.Mode;
                aCanvas.Brush.Color := clWhite;
                aCanvas.Pen.Mode := pmXOR;
                aCanvas.Pen.Color := clWhite;
                aCanvas.Rectangle(
                    Rect(iX-SEL_WIDTH, iY-SEL_WIDTH, iX+SEL_WIDTH, iY+SEL_WIDTH));
                aCanvas.Pen.Mode := aPenMode;
              end;
            end;
          end;
        end;
      psHistogram :
        begin
          // Ref line
          iY0 := aRect.Bottom - Round(-FMin*dRY);
          if iY0 < aRect.Top then
            iY0 := aRect.Top
          else if iY0 > aRect.Bottom then
            iY0 := aRect.Bottom;
          //
          iCnt := 0;



          // data
          for i:=iStart to Data.Count-1 do
          if Data.Valids[i] then
          begin

            {
            if aItem.Title = 'NetVol' then
              ixx := Weight + 1
            else
              ixx := 0;

            if aItem.Title = 'NetVol' then
            begin
              if Data.Values[i] > 0 then
                aCanvas.Pen.Color := clRed
              else
                aCanvas.Pen.Color := clBlue;
            end
            else     }
            aCanvas.Pen.Color := Data.Colors[i];
            if aITem.Title = 'NetVol' then
              if Data.Values[i] > 0 then
                aCanvas.Pen.Color := clRed
              else
                aCanvas.Pen.Color := Data.Colors[i];
            aCanvas.Pen.Width := Weight;

            iX := (i-iStart)*iBarWidth + aRect.Left+1;
            if iX + iBarWidth > aRect.Right-1 then Break;

            iY := aRect.Bottom - Round((Data.Values[i] - FMin)*dRY);

            //
            if Weight <= 0 then
            begin
              aCanvas.Brush.Color := Data.Colors[i];

              if (iBarWidth >=1) and (iBarWidth <= 14) then
                iWingWidth := WING_WIDTHS[iBarWidth]
              else
                iWingWidth := Round(iBarWidth * 0.67);

              if iY > iY0 then
              begin
                aCanvas.FillRect(Rect(iX,iY,iX+iWingWidth,iY0-1));
              end else
              begin
                aCanvas.FillRect(Rect(iX,iY0,iX+iWingWidth,iY));
              end;
            end else
            begin
              if iY > iY0 then
              begin
                aCanvas.MoveTo(iX, iY);
                aCanvas.LineTo(iX, iY0-1);
              end else
              begin
                aCanvas.MoveTo(iX, iY0);
                aCanvas.LineTo(iX, iY);
              end;
            end;
            //
            if bSelected then
            begin
              Inc(iCnt);
              if iCnt mod iStep = 0 then
              begin
                aPenMode := aCanvas.Pen.Mode;
                aCanvas.Brush.Color := clWhite;
                aCanvas.Pen.Mode := pmXOR;
                aCanvas.Pen.Color := clWhite;
                aCanvas.Rectangle(
                    Rect(iX-SEL_WIDTH, iY-SEL_WIDTH, iX+SEL_WIDTH, iY+SEL_WIDTH));
                aCanvas.Pen.Mode := aPenMode;
              end;
            end;
          end;
        end;
      psBarHigh :
        begin
          //-- Get count/index of Bar High/Low style
          aLowItem := GetBarLowItem;;
          //--
          if aLowItem <> nil then
          begin
            //
            iCnt := 0;
            // data
            // for i:=iStart to iEnd do
            for i:=iStart to Data.Count-1 do
            if Data.Valids[i] and aLowItem.Data.Valids[i] then
            begin
              if Data.Values[i] >= aLowItem.Data.Values[i] then
              begin
                aCanvas.Pen.Color := Data.Colors[i];
                aCanvas.Pen.Width := Weight;
              end else
              begin
                aCanvas.Pen.Color := aLowItem.Data.Colors[i];
                aCanvas.Pen.Width := aLowItem.Weight;
              end;

              iX := (i-iStart)*iBarWidth + aRect.Left+1;
              if iX + iBarWidth > aRect.Right-1 then Break;

              iY := aRect.Bottom - Round((Data.Values[i] - FMin)*dRY);
              iY2 := aRect.Bottom - Round((aLowItem.Data.Values[i] - FMin)*dRY);
              //
              if iY2 > iY then
              begin
                aCanvas.MoveTo(iX, iY-1);
                aCanvas.LineTo(iX, iY2);
              end else
              begin
                aCanvas.MoveTo(iX, iY2-1);
                aCanvas.LineTo(iX, iY);
              end;
              //
              if bSelected then
              begin
                Inc(iCnt);
                if iCnt mod iStep = 0 then
                begin
                  aPenMode := aCanvas.Pen.Mode;
                  aCanvas.Brush.Color := clWhite;
                  aCanvas.Pen.Mode := pmXOR;
                  aCanvas.Pen.Color := clWhite;
                  aCanvas.Rectangle(
                      Rect(iX-SEL_WIDTH, ((iY+iY2) div 2) - SEL_WIDTH,
                           iX+SEL_WIDTH, ((iY+iY2) div 2) + SEL_WIDTH));
                  aCanvas.Pen.Mode := aPenMode;
                end;
              end; // if bSelected
            end; // if Data.Valids
          end; // if aLowItem <>
        end;
    end;
  end;
  //--
  aCanvas.Brush.Color := aBrushColor;
  aCanvas.Font.Color := aFontColor;
  aCanvas.Pen.Color := aPenColor;
end;

function TIndicator.SpotData(iBarIndex : Integer) : String;
var
  i : Integer;
  aPlot : TPlotItem;
begin
  Result := '';
  if (iBarIndex >=0) and (iBarIndex < FSymboler.XTerms.Count) then
    for i:=0 to FPlots.Count-1 do
    begin
      aPlot := FPlots.Items[i] as TPlotItem;
      if aPlot.Data.Valids[iBarIndex] then
        Result := Result + ' ' +
                  Format('%s:%.2f',[aPlot.Title, aPlot.Data.Values[iBarIndex]]);

    end;
end;

procedure TIndicator.HintData(iBarIndex : Integer; stHints : TStringList);
var
  i : Integer;
  aPlot : TPlotItem;
begin
  if (stHints <> nil) and
     (iBarIndex >=0) and (iBarIndex < FSymboler.XTerms.Count) then
    for i:=0 to FPlots.Count-1 do
    begin
      aPlot := FPlots.Items[i] as TPlotItem;
      if aPlot.Data.Valids[iBarIndex] then
        stHints.Add(Format('%s=%.2f',[aPlot.Title, aPlot.Data.Values[iBarIndex]]));
    end;
end;

function TIndicator.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
  const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 2;
var
  dRY : Double;
  i, j, iX, iY, iX2, iY1, iY2, iY0, iCenter : Integer;
  dY1 : Double;
  aLowItem : TPlotItem;
begin
  Result := False;
  // out data range
  if (iBarIndex < 0) or (iBarIndex >= FSymboler.XTerms.Count) then Exit;

  if FMax = FMin then Exit;
  //-- Ratio
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  //-- bar
  for j:=0 to FPlots.Count-1 do
  with FPlots.Items[j] as TPlotItem do
  case Style of
    psLine :
      begin
        if iBarIndex >= Data.Count then Continue;
        //
        if Data.Valids[iBarIndex] then
        begin
          iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
          iY := aRect.Bottom - Round((Data.Values[iBarIndex] - FMin)*dRY);
          if iBarIndex < Data.Count-1 then
          begin
            iX2 := (iBarIndex + 1 - iStartIndex) * iBarWidth + aRect.Left + 1;
            iY2 := aRect.Bottom - Round((Data.Values[iBarIndex+1] - FMin)*dRY);
          end else
          begin
            iX2 := iX;
            iY2 := iY;
          end;
          //
          if (iHitX >= iX) and (iHitX <= iX2) then
          begin
            if iX <> iX2 then
              dY1 := iY + (iHitX-iX)*(iY2-iY)/(iX2-iX)
            else
              dY1 := iY;
            //
            if (iHitY <= dY1 + HIT_RANGE) and (iHitY >= dY1 - HIT_RANGE) then
              Result := True;
          end;
        end;
      end;
    psDot :
      begin
        if iBarIndex >= Data.Count then Exit;
        //
        if Data.Valids[iBarIndex] then
        begin
          iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
          iY := aRect.Bottom - Round((Data.Values[iBarIndex] - FMin)*dRY);
          //
          if (iHitX >= iX-HIT_RANGE) and (iHitX <= iX+HIT_RANGE) and
             (iHitY >= iY-HIT_RANGE) and (iHitY <= iY+HIT_RANGE) then
            Result := True;
        end;
      end;
    psHistogram :
      begin
        if iBarIndex >= Data.Count then Exit;
        //
        if Data.Valids[iBarIndex] then
        begin
          // Ref line
          iY0 := aRect.Bottom - Round((0 - FMin)*dRY);
          // Data
          iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
          iY := aRect.Bottom - Round((Data.Values[iBarIndex] - FMin)*dRY);
          //
          if (iHitX >= iX-HIT_RANGE) and (iHitX <= iX+HIT_RANGE) then
            if ((iY0 >= iY) and (iHitY >= iY) and (iHitY <= iY0)) or
               ((iY0 < iY) and (iHitY >= iY0) and (iHitY <= iY)) then
              Result := True;
        end;
      end;
    psBarHigh :
      begin
        if iBarIndex >= Data.Count then Exit;
        //
        aLowItem := GetBarLowItem;
        //
        if (aLowItem <> nil) and
           (Data.Valids[iBarIndex]) and
           (aLowItem.Data.Valids[iBarIndex]) then
        begin
          iY0 := aRect.Bottom - Round((Data.Values[iBarIndex] - FMin)*dRY);
          iY := aRect.Bottom - Round((aLowItem.Data.Values[iBarIndex] - FMin)*dRY);
          //
          if (iHitX >= iX-HIT_RANGE) and (iHitX <= iX+HIT_RANGE) then
            if ((iY0 >= iY) and (iHitY >= iY) and (iHitY <= iY0)) or
               ((iY0 < iY) and (iHitY >= iY0) and (iHitY <= iY)) then
              Result := True;
        end;
      end;
  end;
end;

procedure TIndicator.DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                    var iLeft : Integer; bSelected : Boolean);
var
  i : Integer;
  stText : String;
  aSize : TSize;
  aFontColor : TColor;
  aFontStyle : TFontStyles;
  aPlot : TPlotItem;
begin
  //-- backup GDI environment
  aFontColor := aCanvas.Font.Color;
  aFontStyle := aCanvas.Font.Style;
  //
  //--1.  title + parameters

  if FPlots.Count > 0 then
    aCanvas.Font.Color := (FPlots.Items[0] as TPlotItem).Color;
  if bSelected then
    aCanvas.Font.Style := aCanvas.Font.Style + [fsBold];

  stText := GetTitle;
  //

  if FParams.Count > 0 then
  begin
    stText := stText + '(';
    for i:=0 to FParams.Count-1 do
    begin
      if i > 0 then stText := stText + ',';
      stText := stText + (FParams.Items[i] as TParamItem).AsString;
    end;
    stText := stText + ')';
  end;

  aSize := aCanvas.TextExtent(stText);
  aCanvas.TextOut(iLeft+5, aRect.Top - aSize.cy, stText);
  //
  iLeft := iLeft + 5 + aSize.cx;
  //
  //--2. values
  for i:=0 to FPlots.Count-1 do
  begin
    aPlot := FPlots.Items[i] as TPlotItem;
    aCanvas.Font.Color := aPlot.Color;

    if aPlot.Title = 'NetVol' then
      if aPlot.Data[0] > 0 then
        aCanvas.Font.Color := clRed
      else
        aCanvas.Font.Color := clBlue;

    stText := Format('%.*f', [FPrecision, aPlot.Data[0]]);
    aSize := aCanvas.TextExtent(stText);
    aCanvas.TextOut(iLeft+5, aRect.Top - aSize.cy, stText);
    iLeft := iLeft + 5 + aSize.cx;
  end;

  //-- restore GDI environment
  aCanvas.Font.Color := aFontColor;
  aCanvas.Font.Style := aFontStyle;
end;



//---------------< Indicator Functions : Basic >------------------//

function TIndicator.High : TNumericSeries;
begin
  Result := NumericSeries('High');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].H;
end;

function TIndicator.SAR: TnumericSeries;
begin
  Result := NumericSeries('SAR');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].SAR;
end;

procedure TIndicator.SaveEnv(aStorage: TStorage; idx : integer);
var
  i : integer;
  stPre, stValue : string;
begin

  stPre := IntToStr( idx );

  aStorage.FieldByName(stPre+'IndiPosition').AsInteger := Integer( FPosition );
  aStorage.FieldByName(stPre+'IndiScaletype').AsInteger := Integer( FScaleType );
  aStorage.FieldByName(stPre+'ParamCount').AsInteger := FParams.Count;

  for i:=0 to FParams.Count-1 do
    with FParams.Items[i] as TParamItem do
    begin
      case FParamType of
        ptInteger : aStorage.FieldByName(stPre+'ptInteger'+IntToStr(i)).AsInteger := FInteger;
        ptFloat   : aStorage.FieldByName(stPre+'ptFloat'+IntToStr(i)).AsFloat := FFloat;
        ptString  :
                    begin
                      stValue := Format('%-90s', [FString]);
                      aStorage.FieldByName(stPre+'ptString'+IntToStr(i)).AsString := stValue;
                    end;
        ptBoolean : aStorage.FieldByName(stPre+'ptBoolean'+IntToStr(i)).AsBoolean := FBoolean;
        ptColor   : aStorage.FieldByName(stPre+'ptColor'+IntToStr(i)).AsInteger := Integer( FColor );
        ptAccount :
          begin
            stValue := Format('%-90s', [FString]);
            aStorage.FieldByName(stPre+'ptAccount'+IntToStr(i)).AsString := stValue;
          end;
        ptSymbol  : aStorage.FieldByName(stPre+'ptSymbol'+IntTostr(i)).AsString := FString;
      end;
    end;

  aStorage.FieldByName(stPre+'PlotsCount').AsInteger := FPlots.Count;
  for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      aStorage.FieldByName(stPre+'PlotStyle'+IntToStr(i)).AsInteger := Integer( Style );
      aStorage.FieldByName(stPre+'PlotColor'+IntToStr(i)).AsInteger := Integer( Color );
      aStorage.FieldByName(stPre+'PlotWeight'+IntToStr(i)).AsInteger := Weight;
    end;


end;


procedure TIndicator.LoadEnv(aStorage: TStorage; idx : integer);
var
  i : integer;
  stPre, stValue : string;
begin
  stPre := IntToStr( idx );

  FPosition := TCharterPosition( aStorage.FieldByName(stPre+'IndiPosition').AsInteger );
  FScaleType  := TScaleType( aStorage.FieldByName(stPre+'IndiScaletype').AsInteger );
  aStorage.FieldByName(stPre+'ParamCount').AsInteger := FParams.Count;

  for i:=0 to FParams.Count-1 do
    with FParams.Items[i] as TParamItem do
    begin
      case FParamType of
        ptInteger : FInteger := aStorage.FieldByName(stPre+'ptInteger'+IntToStr(i)).AsInteger;
        ptFloat   : FFloat := aStorage.FieldByName(stPre+'ptFloat'+IntToStr(i)).AsFloat;
        ptString  : FString := Trim(aStorage.FieldByName(stPre+'ptString'+IntToStr(i)).AsString);
        ptBoolean : FBoolean := aStorage.FieldByName(stPre+'ptBoolean'+IntToStr(i)).AsBoolean;
        ptColor   : FColor := TPlotColor( aStorage.FieldByName(stPre+'ptColor'+IntToStr(i)).AsInteger );
        ptAccount :
          begin
            FString := aStorage.FieldByName(stPre+'ptAccount'+IntToStr(i)).AsString;
            if FString <> '' then
              FBAccount := true;
            if FBAccount then
              SetObject;
          end;             
        ptSymbol :
          begin
            FString := aStorage.FieldByName(stPre+'ptSymbol'+IntToStr(i)).AsString;
            if FString <> '' then
              FBAccount := true;
            if FBAccount then
              SetObject;
          end;
      end;
    end;

  for i:=0 to FPlots.Count-1 do
    with FPlots.Items[i] as TPlotItem do
    begin
      Style := TPlotStyle( aStorage.FieldByName(stPre+'PlotStyle'+IntToStr(i)).AsInteger );
      Color := TColor( aStorage.FieldByName(stPre+'PlotColor'+IntToStr(i)).AsInteger );
      Weight  := aStorage.FieldByName(stPre+'PlotWeight'+IntToStr(i)).AsInteger;
    end;

end;


function TIndicator.LongFill: TNumericSeries;
var
  aTerm : TXTermItem;
begin
  Result := NumericSeries('LongFill');
  if FCurrentBar >= 1 then
  begin
    aTerm := FSymboler.XTerms.XTerms[FCurrentBar-1];
    aTerm.CalcAvgFill(1);
    Result[0] := FSymboler.XTerms[FCurrentBar-1].LongFill;
  end;
end;

function TIndicator.Low : TNumericSeries;
begin
  Result := NumericSeries('Low');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].L;
end;

function TIndicator.Close : TNumericSeries;
begin
  Result := NumericSeries('Close');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].C;
end;

function TIndicator.Open : TNumericSeries;
begin
  Result := NumericSeries('Open');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].O;
end;

function TIndicator.OptVol: TNumericSeries;
begin
  Result := NumericSeries('OptVol');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].OptVol;
end;

function TIndicator.OptVol2: TNumericSeries;
begin
  Result := NumericSeries('OptVol2');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].OptVol2;
end;

function TIndicator.Volume : TNumericSeries;
begin
  Result := NumericSeries('Volume');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].FillVol;
end;

function TIndicator.vSpread: TnumericSeries;
begin

  Result := NumericSeries('vSpread');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].vSpread;
end;

function TIndicator.vStandLine: TnumericSeries;
begin

  Result := NumericSeries('vStandLine');
  if FCurrentBar >= 1 then
    Result[0] := 0;
end;

function TIndicator.vMASpread: TnumericSeries;
begin
  Result := NumericSeries('vMASpread');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].vMASpread;
end;

function TIndicator.AskCnt: TnumericSeries;
begin
  Result := NumericSeries('AskCnt');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].AskCnt;
end;

function TIndicator.BidCnt: TnumericSeries;
begin
  Result := NumericSeries('BidCnt');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].BidCnt;
end;


function TIndicator.Side : TNumericSeries;
begin
  Result := NumericSeries('Side');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].Side;
end;

function TIndicator.SideVolume: TNumericSeries;
begin

  Result := NumericSeries('SideVolume');
  if FCurrentBar >= 1 then
    Result[0] := FSymboler.XTerms[FCurrentBar-1].SideVol * SymbolDelta;
end;
function TIndicator.SymbolDelta: double;
var
  U, E, R, T, TC, W, I : Double;
  ExpireDateTime : TDateTime;
begin
  Result := 1;

  if gEnv.Engine.SyncFuture.FSynFutures = nil then
    Exit;

  if FSymboler.XTerms.Symbol = nil then Exit;

  if FSymboler.XTerms.Symbol.Spec.Market <> mtOption then
    Exit;

  U := gENv.Engine.SyncFuture.FSynFutures.Last;
  E := (FSymboler.XTerms.Symbol as TOption).StrikePrice;
  R := (FSymboler.XTerms.Symbol as TOption).CDRate;
  ExpireDateTime := GetQuoteDate + (FSymboler.XTerms.Symbol as TOption).DaysToExp - 1 + EncodeTime(15,15,0,0);
  T := gEnv.Engine.Holidays.CalcDaysToExp(GetQuoteTime, ExpireDateTime, rcTrdTime);
  TC := (FSymboler.XTerms.Symbol as TOption).DaysToExp / 365;

  if FSymboler.XTerms.Symbol.OptionType = otCall then
    W := 1
  else
    W := -1;

  I := IV(U, E, R, T, TC, FSymboler.XTerms.Symbol.Last , W);
  Result := Delta(U, E, R, I, T, TC, W);

end;

function TIndicator.SymbolPL: TNumericSeries;
begin

end;

//-----------< Indicator Functions : Generic >----------------------//

function TIndicator.Lowest(Price : TNumericSeries; Length : Integer) : Double;
var
  Counter : Integer;
begin
  Result := 0.0;
  //
  for Counter :=0 to Length - 1 do
    if Counter > 0 then
      Result := Min(Result, Price[Counter])
    else
      Result := Price[0];
end;

function TIndicator.Highest(Price : TNumericSeries; Length : Integer) : Double;
var
  Counter : Integer;
begin
  Result := 0.0;
  //
  for Counter :=0 to Length - 1 do
    if Counter > 0 then
      Result := Max(Result, Price[Counter])
    else
      Result := Price[0];
end;

function TIndicator.Average(Key : String; Price : TNumericSeries;
     Length : Integer) : TNumericSeries;
var
  Sum : Double;
  Counter : Integer;
begin
  Average := NumericSeries(Key+'Average');
  //
  Sum := 0.0;
  for Counter := 0 to Length - 1 do
    Sum := Sum + Price[Counter];

  if Length > 0 then
    Average[0] := Sum / Length
  else
    Average[0] := 0;
end;

function TIndicator.AverageFC(Key : String; Price : TNumericSeries;
  Length : Integer) : TNumericSeries;
var
  Sum : TNumericSeries;
  Counter : Integer;
begin
  AverageFC := NumericSeries(Key + 'AverageFC');
  Sum := NumericSeries(Key + 'AverageFCSum');
  //
  if CurrentBar = 1 then
  begin
    Sum[0] := 0.0;
    for Counter := 0 to Length - 1 do
      Sum[0] := Sum[0] + Price[Counter];
  end else
    Sum[0] := Sum[1] + Price[0] - Price[Length];

  if CurrentBar >= Length then
    AverageFC[0] := Sum[0] / Length
  else
  if Length > 0 then
    AverageFC[0] := Sum[0] / CurrentBar
  else
    AverageFC[0] := 0.0;
end;



function TIndicator.StdDev(Key : String; Price : TNumericSeries;
  Length : Integer) : TNumericSeries;
var
  Avg, SumSqr : Double;
  Counter : Integer;
begin
  StdDev := NumericSeries(Key + 'StdDev');
  //
  if Length > 0 then
  begin
    Avg := AverageFC(Key + 'StdDev', Price, Length)[0];
    SumSqr := 0.0;
    for Counter := 0 to Length-1 do
      SumSqr := SumSqr + (Price[Counter]-Avg)*(Price[Counter]-Avg);
    StdDev[0] := Sqrt(SumSqr / Length);
  end else
    StdDev[0] := 0;
end;

function TIndicator.WAverage(Key : String; Price : TNumericSeries; Length : Integer) :
  TNumericSeries;
var
  Sum : Double;
  Counter, CSum : Integer;
begin
  WAverage := NumericSeries(Key + 'WAverage');

  Sum := 0;
  CSum := 0;

  for Counter := 0 to Length - 1 do
  begin
    Sum := Sum + Price[Counter] * (Length-Counter);
    CSum := CSum + Length - Counter;
  end;

  if CSum > 0 then
    WAverage[0] := Sum / CSum
  else
    WAverage[0] := 0;
end;

function TIndicator.XAverage(Key : String; Price : TNumericSeries; Length : Integer) :
  TNumericSeries;
var
  Factor : Double;
begin
  XAverage := NumericSeries(Key + 'XAverage');
  //
  if Length + 1 <> 0 then
  begin
    Factor := 2 / (Length + 1);
    //
    if CurrentBar <= 1 then
      XAverage[0] := Price[0]
    else
      XAverage[0] := Factor * Price[0] + (1-Factor) * Result[1];
  end;
end;

//=================================================================//

procedure AddIndicator(stTitle, stClassDesc : String; aClass : TIndicatorClass);
begin
  with gIndicatorList.Add as TIndicatorListItem do
  begin
    Title := stTitle;
    ClassDesc := stClassDesc;
    IndicatorClass := aClass;
  end;
end;

function FindIndicator(stClassDesc : String) : TIndicatorClass;
var
  i : Integer;
begin
  Result := nil;
  
  for i:=0 to gIndicatorList.Count-1 do
  with gIndicatorList.Items[i] as TIndicatorListItem do
    if CompareStr(ClassDesc, stClassDesc) = 0 then
    begin
      Result := IndicatorClass;
      Break;
    end;
end;


function TIndicator.GetParamDesc: String;
var
  i : Integer;
  stTmp : string;
begin
  Result := '';
{
    for i := 0 to FParams.Count - 1 do
      if i <> FParams.Count - 1 then
        Result := Result + (FParams.Items[i] as TParamItem).AsString + ', '
      else
        Result := Result + (FParams.Items[i] as TParamItem).AsString;
}
    for i := 0 to FParams.Count-1 do
    begin
        if i > 0 then
          Result := Result + ', ';

        stTmp := (FParams.Items[i] as TParamItem).AsString;
        case (FParams.Items[i] as TParamItem).ParamType of
          ptAccount :
            if stTmp <> '' then
              stTmp := Copy( stTmp, Length( stTmp ) - 3, 4);
          ptSymbol :
            if stTmp <> '' then
              stTmp := Copy( stTmp, 4, Length( stTmp )- 4 );
        end;
        Result := Result + stTmp;
    end;


end;

{
procedure TIndicator.DoEtc;
begin
  //
end;
}
procedure TIndicator.AddParam(stTitle, stValue: String; bObject: boolean);
begin
  with FParams.Add as TParamItem do
  begin
    Title := stTitle;
    if stValue = '1' then
      AsSymbol  := ''
    else
      AsAccount := stValue;
  end;
end;

initialization
  gIndicatorList := TCollection.Create(TIndicatorListItem);

finalization
  gIndicatorList.Free;

end.
