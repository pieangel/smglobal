unit DSignalLink;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,
  // App
  {
  AppTypes, AppUtils,
  AccountStore, SymbolStore,
  }
  GleLib,
  CleAccounts, CleSymbols,
  CleFQN,
  SystemIF

  ;

type
  TSignalLinkDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    ComboAccount: TComboBox;
    ButtonOK: TButton;
    Button2: TButton;
    ButtonSymbol: TSpeedButton;
    Bevel1: TBevel;
    ComboSymbol: TComboBox;
    Label3: TLabel;
    ComboSignal: TComboBox;
    Label4: TLabel;
    EditMultiplier: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FSignal : TSignalItem;
    FMultiplier: Integer;
    
    procedure SetSymbol(const Value: TSymbol);
    procedure SetAccount(const Value: TAccount);
    procedure SetMultiplier(const Value: Integer);
    procedure SetSignal(const Value: TSignalItem);
    procedure SetSignalList(const Value: TList);
  public
    property Account : TAccount read FAccount write SetAccount;
    property Symbol : TSymbol read FSymbol write SetSymbol;
    property Signal : TSignalItem read FSignal write SetSignal;
    property Multiplier : Integer read FMultiplier write SetMultiplier;
    property SignalList : TList write SetSignalList;
  end;

var
  SignalLinkDialog: TSignalLinkDialog;

function SelectSymbol(aForm : TForm; aTypes : TMarketTypes;
  bOrder : Boolean; aUnderly : TSymbol = nil) : TSymbol;
implementation

{$R *.DFM}

uses
  GAppEnv, DleSymbolSelect;
{
  TradeCentral, PriceCentral,
  DSymbol;
 }
//----------------------< Init / Final >-------------------------//

procedure TSignalLinkDialog.FormCreate(Sender: TObject);
begin
  FSymbol := nil;
  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );
  gEnv.Engine.SymbolCore.SymbolCache.GetList( ComboSymbol.Items );
end;


//----------------------< Button Actions >-----------------------//

procedure TSignalLinkDialog.ButtonOKClick(Sender: TObject);
begin
  if ComboAccount.ItemIndex = -1 then
  begin
    ShowMessage('계좌를 선택하십시오');
    ComboAccount.SetFocus;
  end else
  if ComboSymbol.ItemIndex = -1 then
  begin
    ShowMessage('종목을 선택하십시오');
    ComboSymbol.SetFocus;
  end else
  if ComboSignal.ItemIndex = -1 then
  begin
    ShowMessage('신호을 선택하십시오');
    ComboSignal.SetFocus;
  end else
  if EditMultiplier.Text = '' then
  begin
    ShowMessage('승수를 입력하십시오');
    EditMultiplier.SetFocus;
  end else
  begin
    FAccount := ComboAccount.Items.Objects[ComboAccount.ItemIndex] as TAccount;
    FSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;
    FSignal := ComboSignal.Items.Objects[ComboSignal.ItemIndex] as TSignalItem;
    FMultiplier := StrToIntDef(EditMultiplier.Text, 0);

    ModalResult := mrOK;
  end;
end;

//-------------------------< Symbol Selection >----------------------------//

procedure TSignalLinkDialog.ButtonSymbolClick(Sender: TObject);
var
  aSymbol : TSymbol;
begin

  aSymbol := SelectSymbol(Self, [mtFutures, mtOption, mtSpread], True);
  //
  if aSymbol = nil then Exit;
  //
  gEnv.Engine.SymbolCore.SymbolCache.AddSymbol( aSymbol );
  //
  AddSymbolCombo(aSymbol, ComboSymbol);
end;

procedure TSignalLinkDialog.ComboSymbolChange(Sender: TObject);
begin
  FSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;

  if FSymbol <> nil then
    AddSymbolCombo(FSymbol, ComboSymbol);
end;

//----------------------< Get/Set >-------------------------//

procedure TSignalLinkDialog.SetSymbol(const Value: TSymbol);
begin
  FSymbol := Value;

  if FSymbol <> nil then
  begin
    AddSymbolCombo(FSymbol, ComboSymbol);
    ComboSymbol.Enabled := False;
    ButtonSymbol.Enabled := False;
  end;
end;


procedure TSignalLinkDialog.SetAccount(const Value: TAccount);
begin
  FAccount := Value;

  if Value <> nil then
  begin
    SetComboIndex( ComboAccount, Value );
    ComboAccount.Enabled := False;
  end;
end;

procedure TSignalLinkDialog.SetSignal(const Value: TSignalItem);
begin
  FSignal := Value;

  if Value <> nil then
  begin
    SetComboIndex( ComboSignal, Value );
    ComboSignal.Enabled := False;
  end;
end;

procedure TSignalLinkDialog.SetMultiplier(const Value: Integer);
begin
  FMultiplier := Value;
  EditMultiplier.Text := IntToStr(Value);
end;

procedure TSignalLinkDialog.SetSignalList(const Value: TList);
var
  i : Integer;
  aSignal : TSignalItem;
begin
  if Value = nil then Exit;
  
  for i:=0 to Value.Count-1 do
  begin
    aSignal := TSignalItem(Value.Items[i]);
    ComboSignal.Items.AddObject(aSignal.Title, aSignal);
  end;
end;


function SelectSymbol(aForm : TForm; aTypes : TMarketTypes;
  bOrder : Boolean; aUnderly : TSymbol = nil) : TSymbol;
var
  aDlg : TSymbolDialog;
begin
  Result := nil;
  //
  aDlg := TSymbolDialog.Create(aForm);
  try
    aDlg.SymbolCore := gEnv.Engine.SymbolCore;
    if aDlg.Open then begin
      Result := aDlg.Selected;
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aDlg.Selected);
    end;
  finally
    aDlg.Free;
  end;



end;

end.
