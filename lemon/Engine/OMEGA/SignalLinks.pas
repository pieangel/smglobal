unit SignalLinks;

interface

uses
  Classes, SysUtils, Controls,
  //
  CleAccounts, CleSymbols, ClePositions,
  SystemIF, Signals, Dialogs, Forms;

type
  TSignalLinkItem = class;
  
  TSignalLinkEvent = procedure(aLink : TSignalLinkItem) of object;
  TSignalLinkOrderEvent = procedure(aLink : TSignalLinkItem;
     aEvent : TSignalEventItem) of object;

  TSignalLinkItem = class(TCollectionItem)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FSignal : TSignalItem;
    FMultiplier : Integer;
    FPosition : Integer;

    FOnUpdate : TSignalLinkEvent;
    FOnRemove : TSignalLinkEvent;
    FOnOrder : TSignalLinkOrderEvent;
  public
    destructor Destroy; override;

    procedure UpdatePosition;
    procedure NewOrder(aEvent : TSignalEventItem);

    property Account : TAccount read FAccount;
    property Symbol : TSymbol read FSymbol;
    property Signal : TSignalItem read FSignal;
    property Multiplier : Integer read FMultiplier;
    property Position : Integer read FPosition;

    property OnUpdate : TSignalLinkEvent read FOnUpdate write FOnUpdate;
    property OnRemove : TSignalLinkEvent read FOnRemove write FOnRemove;
    property OnOrder : TSignalLinkOrderEvent read FOnOrder write FOnOrder;
  end;

  TSignalLinks = class(TCollection)
  private
    FSignals : TSignals; // reference to signal list
    function GetLink(i:Integer) : TSignalLinkItem;
  public
    constructor Create;

    function NewLink : TSignalLinkItem;
    function EditLink(aLink : TSignalLinkItem) : Boolean;
    procedure RemoveLink(aLink : TSignalLinkItem); overload;
    procedure RemoveLink(aSignal : TSignalItem); overload;

    procedure LoadLinks;
    procedure SaveLinks;
    function GetLinkCode( stData : string) : string;

    function NewOrder(aEvent : TSignalEventItem) : Integer;
    procedure UpdatePosition(aSignal : TSignalItem);

    property Signals : TSignals read FSignals write FSignals;
    property Links[i:Integer] : TSignalLinkItem read GetLink; default;
  end;


implementation

uses
  EnvFile, {LogCentral, TradeCentral, PriceCentral,  }
  DSignalLink, GAppEnv, CleMarkets;{, AppTypes;

//===============================================================//
                     { TSignalLinks }
//===============================================================//

destructor TSignalLinkItem.Destroy;
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self);

  inherited;
end;

procedure TSignalLinkItem.UpdatePosition;
begin
  if FSignal <> nil then
    FPosition := FMultiplier * FSignal.Position;

  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
end;

procedure TSignalLinkItem.NewOrder(aEvent : TSignalEventItem);
begin
  if (aEvent = nil) or (aEvent.Signal = nil) then Exit;

  if Assigned(FOnOrder) then
    FOnOrder(Self, aEvent);
end;

//===============================================================//
                     { TSignalLinks }
//===============================================================//

constructor TSignalLinks.Create;
begin
  inherited Create(TSignalLinkItem);
end;

//------------------------< Get/Set >---------------------------//

function TSignalLinks.GetLink(i:Integer) : TSignalLinkItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSignalLinkItem
  else
    Result := nil;
end;

function TSignalLinks.GetLinkCode(stData: string): string;
var
  stResult : string;
  iPos : integer;
begin
  stResult := Copy( stData , 2 , Length(stData) -2);
  iPos := Pos(',', stResult);
  Result := Copy(stResult, 1, iPos-1);
end;

//------------------------< Manage Links >---------------------------//

// (public)
// make a new link with a dialog
//
function TSignalLinks.NewLink : TSignalLinkItem;
var
  aDlg : TSignalLinkDialog;
begin
  Result := nil;

  aDlg := TSignalLinkDialog.Create(nil);
  try
    aDlg.SignalList := FSignals;

    if aDlg.ShowModal <> mrOK then Exit;

    //-- new signal-account connection item
    Result := Add as TSignalLinkItem;

    Result.FAccount := aDlg.Account;
    Result.FSymbol := aDlg.Symbol;
    Result.FSignal := aDlg.Signal;
    Result.FMultiplier := aDlg.Multiplier;
    Result.FPosition := Result.Signal.Position * Result.Multiplier;
  finally
    aDlg.Free;
  end;
end;

// (public)
// edit a link with a dialog
//
function TSignalLinks.EditLink(aLink : TSignalLinkItem) : Boolean;
var
  aDlg : TSignalLinkDialog;
begin
  Result := False;

  if aLink = nil then Exit;

  aDlg := TSignalLinkDialog.Create(nil);
  try
    aDlg.SignalList := FSignals;

    aDlg.Account := aLink.Account;
    aDlg.Symbol := aLink.Symbol;
    aDlg.Signal := aLink.Signal;
    aDlg.Multiplier := aLink.Multiplier;

    if aDlg.ShowModal <> mrOK then Exit;

    if aLink.Symbol = nil then
      aLink.FSymbol := aDlg.Symbol;
    aLink.FMultiplier := aDlg.Multiplier;
    aLink.FPosition := aLink.Signal.Position * aLink.Multiplier;

    Result := True;
  finally
    aDlg.Free;
  end;
end;

// (public)
// remove a link
//
procedure TSignalLinks.RemoveLink(aLink : TSignalLinkItem);
begin
  if aLink = nil then Exit;

  aLink.Free;
end;

// (public)
// remove a link with the matched signal
//
procedure TSignalLinks.RemoveLink(aSignal : TSignalItem);
var
  i : Integer;
begin
  if aSignal = nil then Exit;

  for i:=Count-1 downto 0 do
    if Links[i].Signal = aSignal then
      Links[i].Free;
end;

//---------------------< Manage Position Quantity >----------------------//

procedure TSignalLinks.UpdatePosition(aSignal : TSignalItem);
var
  i : Integer;
begin
  if aSignal = nil then Exit;

  for i:=0 to Count-1 do
    if Links[i].Signal = aSignal then
      Links[i].UpdatePosition;
end;

//--------------------------< Manage order >--------------------------//

function TSignalLinks.NewOrder(aEvent : TSignalEventItem) : Integer;
var
  i, iMatchedCount : Integer;
begin
  if (aEvent = nil) or (aEvent.Signal = nil) then Exit;

  iMatchedCount := 0;

  for i:=0 to Count-1 do
  begin
    if Links[i].Signal = aEvent.Signal then
    begin
      Links[i].NewOrder(aEvent);
        //
      Inc(iMatchedCount);
    end;
  end;

  Result := iMatchedCount;
end;


//-------------------------< Load Save >--------------------------------//

const
  Link_FILE = 'signallink.gsu';

// (public)
// Load signal inks
//
procedure TSignalLinks.LoadLinks;
const
  FIELD_COUNT = 4;
var
  i : Integer;
  aEnvFile : TEnvFile;
  aItem : TSignalLinkItem;
  iLinkCount : Integer;
  aAccount : TAccount;
  aSymbol : TSymbol;
  aSignal : TSignalItem;
  FFutureMarket : TFutureMarket;

  stSymbol : String;
  stLog, stLinkCode : string;
begin
  aEnvFile := TEnvFile.Create;
  try
    if not aEnvFile.Exists(Link_FILE) then Exit;

    aEnvFile.LoadLines(Link_FILE);
    if aEnvFile.Lines.Count mod FIELD_COUNT <> 0 then
    begin
      stLog := Format('%s %s', ['SignalData', '연결표 복구','시스템 신호 연결표가 잘못되었습니다.']);
      gEnv.DoLog( WIN_TS, stLog);
      Exit;
    end;
    iLinkCount := aEnvFile.Lines.Count div FIELD_COUNT;

    for i:=0 to iLinkCount-1 do
    begin
      aAccount := gEnv.Engine.TradeCore.Accounts.Find(aEnvFile.Lines[i*FIELD_COUNT]);

      stSymbol := aEnvFile.Lines[i*FIELD_COUNT + 1];
      aSymbol :=  gEnv.Engine.SymbolCore.Symbols.FindCode(stSymbol);


      aSignal :=
         FSignals.Find(aEnvFile.Lines[i*FIELD_COUNT + 2]);

      if aSymbol = nil then
      begin
        stLinkCode := GetLinkCode( aSignal.Description );

        stLinkCode := UpperCase(stLinkCode);
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindLinkCode(stLinkCode);
      end;

      if aSymbol = nil then
      begin
        gEnv.DoLog(WIN_TS, '종목 찾지 못함 TSignalLinks');
        ShowMessage('종목 찾지 못함 TSignalLinks 연락주세요..!!');
        Application.Terminate;
      end;

      if (aAccount <> nil) and (aSignal <> nil) then
      begin
        aItem := Add as TSignalLinkItem;
        aItem.FAccount := aAccount;
        aItem.FSymbol := aSymbol;
        aItem.FSignal := aSignal;
        aItem.FMultiplier := StrToIntDef(aEnvFile.Lines[i*FIELD_COUNT+3],0);
        aItem.FPosition := aSignal.Position * aItem.Multiplier; // = 0
      end;
    end;
  finally
    aEnvFile.Free;
  end;
end;

// (public)
// Save signal inks
//
procedure TSignalLinks.SaveLinks;
var
  i : Integer;
  aEnvFile : TEnvFile;
begin
  aEnvFile := TEnvFile.Create;
  try
    aEnvFile.Lines.Clear;
    for i:=0 to Count-1 do
    begin
      aEnvFile.Lines.Add(Links[i].Account.Code);
      if Links[i].Symbol <> nil then
        aEnvFile.Lines.Add(Links[i].Symbol.Code)
      else
        aEnvFile.Lines.Add('');
      aEnvFile.Lines.Add(Links[i].Signal.Title);
      aEnvFile.Lines.Add(IntToStr(Links[i].Multiplier));
    end;
    aEnvFile.SaveLines(Link_FILE);
  finally
    aEnvFile.Free;
  end;
end;

end.
