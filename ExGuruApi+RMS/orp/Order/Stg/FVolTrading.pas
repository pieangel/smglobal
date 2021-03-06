unit FVolTrading;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  GleTypes,  CleAccounts, CleFunds,

  CleSymbols,  cleDistributor,  CleQuoteBroker,  CleVolTrading,

  CleStorage, StdCtrls, ComCtrls, ExtCtrls, Grids
  ;

type
  TFrmVolTrading = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    cbInvest: TComboBox;
    cbInvestType: TComboBox;
    edtSymbol: TLabeledEdit;
    stTxt: TStatusBar;
    Panel1: TPanel;
    Button2: TButton;
    edtLimitDown: TLabeledEdit;
    cbRun: TCheckBox;
    edtBaseUpPrice: TLabeledEdit;
    edtBaseDownPrice: TLabeledEdit;
    udOrdQty: TUpDown;
    edtOrdQty: TLabeledEdit;
    edtOrdGap: TLabeledEdit;
    sg: TStringGrid;
    Timer1: TTimer;
    edtLimitUp: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure cbInvestTypeChange(Sender: TObject);
    procedure cbInvestChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure edtBaseUpPriceKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FIndex    : integer;
    FAccount  : TAccount;
    FFund     : TFund;
    FSymbol : TSymbol;
    FVolTr  : TVolTrade;
    FParam  : TVolTradeParam;
    procedure Start;
    procedure Stop;
    procedure GetParam;
    procedure SetControls(bAble: boolean);
    procedure OnNotifyEvent(Sender: TObject; Value: String );
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure WMSymbolSelected(var msg: TMessage); message WM_SYMBOLSELECTED;    
  end;

var
  FrmVolTrading: TFrmVolTrading;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFrmVolTrading.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;
  gSymbol.ShowWindow( Handle );
end;

procedure TFrmVolTrading.Button2Click(Sender: TObject);
begin
  if (FVolTr <> nil) and ( cbRun.Checked ) then
  begin
    GetParam;
    FVolTr.Param := FParam;
  end;
end;

procedure TFrmVolTrading.cbInvestChange(Sender: TObject);
var
  aAcnt : TAccount;
  aFund : TFund;
begin
  //
  if FIndex = 0 then
  begin
    aAcnt := TAccount( GetComboObject( cbInvest ) );
    if aACnt <> FAccount then
    begin
      FAccount := aAcnt;
    end;

  end else
  begin
    aFund := TFund( GetComboObject( cbInvest ));
    if aFund <> FFund then
    begin
      FFund := aFund;
    end;             
  end
end;

procedure TFrmVolTrading.cbInvestTypeChange(Sender: TObject);
begin
  if FIndex = cbInvestType.ItemIndex then Exit;

  FIndex := cbInvestType.ItemIndex;

  if FIndex = 0 then begin
    cbInvest.Clear;
    gEnv.Engine.TradeCore.Accounts.GetList2( cbInvest.Items );
    if FAccount <> nil then
    begin
      SetComboIndex( cbInvest, FAccount );
      cbInvestChange( cbInvest );
    end;

  end
  else begin
    cbInvest.Clear;
    gEnv.Engine.TradeCore.Funds.GetList( cbInvest.Items);
    if FFund <> nil then
    begin
      SetComboIndex( cbInvest, FFund );
      cbInvestChange( cbInvest );
    end;
  end;

  if ( cbInvest.Items.Count > 0 ) and ( cbInvest.ItemIndex < 0) then
  begin
    cbInvest.ItemIndex  := 0;
    cbInvestChange( cbInvest );
  end;
end;

procedure TFrmVolTrading.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmVolTrading.edtBaseUpPriceKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFrmVolTrading.FormCreate(Sender: TObject);
begin
  FSymbol := nil;
  FAccount  := nil;
  FFund     := nil;
  FIndex    := -1;

  FVolTr    := TVolTrade.Create( Self );
  FVolTr.NotifyEvent  := OnNotifyEvent;

  cbInvestTypeChange( cbInvestType );
end;

procedure TFrmVolTrading.GetParam;
begin
  with FParam do
  begin
    OrdQty := StrToIntDef( edtOrdQty.Text,1 );
    OrdGap := StrToIntDef( edtOrdGap.Text,20 );
    BaseUpPrc   := StrtoFloatDef( edtBaseUpPrice.Text, 0 );
    BaseDownPrc := StrToFloatDef( edtBaseDownPrice.Text, 0 );
    LimitUp   := StrToFloatDef( edtLimitUp.Text, 0);
    LimitDown := StrToFloatDef( edtLimitDown.Text, 0);
  end;

end;

procedure TFrmVolTrading.LoadEnv(aStorage: TStorage);
var
  aSymbol : TSymbol;
  aAcnt : TAccount;
  aFund : TFund;
begin
  if aStorage = nil then Exit;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2( aStorage.FieldByName('Symbolcode').AsString  );
  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  cbInvestType.ItemIndex  := aStorage.FieldByName('InvestType').AsInteger;
  cbInvestTypeChange( cbInvestType );

  if cbInvestType.ItemIndex = 0 then  // 계좌
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('AcntCode').AsString );
    if aAcnt <> nil then
    begin
      SetComboIndex( cbInvest, aAcnt );
      cbInvestChange(cbInvest);
    end;

  end else
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Find( aStorage.FieldByName('FundName').AsString );
    if aFund <> nil then
    begin
      SetComboIndex( cbInvest, aFund );
      cbInvestChange(cbInvest);
    end;
  end;

  udOrdQty.Position := StrToIntDef( aStorage.FieldByName('OrdQty').AsString ,1 );
  edtBaseUpPrice.Text := aStorage.FieldByName('BaseUpPrc').AsString;
  edtBaseDownPrice.Text := aStorage.FieldByName('BaseDownPrc').AsString;
  edtOrdGap.Text    := aStorage.FieldByName('OrdGap').AsStringDef('') ;
  edtLimitUp.Text   := aStorage.FieldByName('LimitUp').AsStringDef('');
  edtLimitDown.Text   := aStorage.FieldByName('LimitDown').AsStringDef('');
end;

procedure TFrmVolTrading.OnNotifyEvent(Sender: TObject; Value: String);
begin
  if Sender <> FVolTr then Exit;

  InsertLine( sg, 1 );

  sg.Cells[0,1] := FormatDateTime('hh:nn:ss', now);
  sg.Cells[1,1] := Value;
end;

procedure TFrmVolTrading.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('InvestType').AsInteger    := cbInvestType.ItemIndex;
  if FAccount <> nil then
    aStorage.FieldByName('AcntCode').AsString    := FAccount.Code
  else
    aStorage.FieldByName('AcntCode').AsString    := '';

  if FFund <> nil then
    aStorage.FieldByName('FundName').AsString    := FFund.Name
  else
    aStorage.FieldByName('FundName').AsString    := '';

  aStorage.FieldByName('Symbolcode').AsString     := edtSymbol.Text;

  aStorage.FieldByName('OrdQty').AsString     := edtOrdQty.Text;
  aStorage.FieldByName('BaseUpPrc').AsString    := edtBaseUpPrice.Text;
  aStorage.FieldByName('BaseDownPrc').AsString    := edtBaseDownPrice.Text;
  aStorage.FieldByName('OrdGap').AsString     := edtOrdGap.Text;

  aStorage.FieldByName('LimitUp').AsString  := edtLimitUp.Text ;
  aStorage.FieldByName('LimitDown').AsString:= edtLimitDown.Text;
end;

procedure TFrmVolTrading.Start;
begin
  if ( FSymbol = nil ) or (( FIndex = 0 ) and ( FAccount = nil ))  or
     ((FIndex = 1) and ( FFund = nil ))  then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbRun.Checked := false;
    Exit;
  end;

  if FVolTr <> nil then
  begin

    GetParam;
    FVolTr.Param := FParam;

    if cbInvestType.ItemIndex = 0 then
      FVolTr.init( FAccount, FSymbol )
    else
      FVolTr.init( FFund, FSymbol );
    FVolTr.Start;
    SetControls( false );

  end;
end;

procedure TFrmVolTrading.Stop;
begin
  if FVolTr <> nil then
  begin
    SetControls( true );
    FVolTr.Stop;
  end;
end;

procedure TFrmVolTrading.SetControls( bAble : boolean );
begin
  cbInvestType.Enabled := bAble;
  cbInvest.Enabled     := bAble;
  Button1.Enabled      := bAble;
  Timer1.Enabled       := bAble;
  if not bAble then
    plRun.Color := clAqua
  else
    plRun.Color := clBtnFace;
end;

procedure TFrmVolTrading.Timer1Timer(Sender: TObject);
begin
  //
end;

procedure TFrmVolTrading.WMSymbolSelected(var msg: TMessage);
var
  aSymbol : TSymbol;
begin

  aSymbol := TSymbol( Pointer( msg.LParam ));

  if aSymbol <> nil then
    if aSymbol <> FSymbol then
    begin
      FSymbol := aSymbol;
      edtSymbol.Text  := FSymbol.ShortCode;
    end;  
end;

end.
