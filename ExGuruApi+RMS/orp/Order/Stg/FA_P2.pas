unit FA_P2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, StdCtrls, ExtCtrls,

  GleTypes,  CleAccounts, CleFunds,

  CleSymbols,  cleDistributor,  CleQuoteBroker, CleA_P2Trend,

  CleStorage
  ;

type
  TFrmA_P2 = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    cbInvest: TComboBox;
    cbInvestType: TComboBox;
    edtSymbol: TLabeledEdit;
    cbRun: TCheckBox;
    mkStart: TDateTimePicker;
    Label7: TLabel;
    Label2: TLabel;
    dtStart: TDateTimePicker;
    Label1: TLabel;
    dtEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    Label4: TLabel;
    dtEntStart: TDateTimePicker;
    Label3: TLabel;
    Label5: TLabel;
    dtReEntStart: TDateTimePicker;
    Label6: TLabel;
    dtReEntEnd: TDateTimePicker;
    edtATRPeriod: TLabeledEdit;
    edtATRMulti: TLabeledEdit;
    edtTermCnt: TLabeledEdit;
    edtOrdQty: TLabeledEdit;
    edtE1: TLabeledEdit;
    edtL1: TLabeledEdit;
    edtPeriod: TLabeledEdit;
    edtL2: TLabeledEdit;
    edtGoalP: TLabeledEdit;
    stTxt: TStatusBar;
    sgLog: TStringGrid;
    Timer1: TTimer;
    Button2: TButton;
    dtATRLiqStart: TDateTimePicker;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbInvestTypeChange(Sender: TObject);
    procedure cbInvestChange(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtE1KeyPress(Sender: TObject; var Key: Char);
    procedure edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FIndex    : integer;
    FAccount  : TAccount;
    FFund     : TFund;
    FSymbol : TSymbol;
    FA50P2  : TA50_P2_Trend;
    FParam  : TA50_P2Param;
    procedure Start;
    procedure Stop;
    procedure GetParam;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure WMSymbolSelected(var msg: TMessage); message WM_SYMBOLSELECTED;    
  end;

var
  FrmA_P2: TFrmA_P2;

implementation

uses
  GAppEnv , GleLib
  ;

{$R *.dfm}

procedure TFrmA_P2.Button1Click(Sender: TObject);
begin

  if gSymbol = nil then
    gEnv.CreateSymbolSelect;
  gSymbol.ShowWindow( Handle );
end;

procedure TFrmA_P2.Button2Click(Sender: TObject);
begin
  if (FA50P2 <> nil) and ( cbRun.Checked ) then
  begin
    GetParam;
    FA50P2.Param := FParam;
    FA50P2.CalcHL;
  end;
end;

procedure TFrmA_P2.cbInvestChange(Sender: TObject);
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
  end;
end;

procedure TFrmA_P2.cbInvestTypeChange(Sender: TObject);
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

procedure TFrmA_P2.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmA_P2.edtE1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFrmA_P2.edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFrmA_P2.Start;
begin
  if ( FSymbol = nil ) or (( FIndex = 0 ) and ( FAccount = nil ))  or
     ((FIndex = 1) and ( FFund = nil ))  then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbRun.Checked := false;
    Exit;
  end;

  if FA50P2 <> nil then
  begin

    Color := clAqua;
    GetParam;
    FA50P2.Param := FParam;

    if cbInvestType.ItemIndex = 0 then
      FA50P2.init( FAccount, FSymbol )
    else
      FA50P2.init( FFund, FSymbol );
    FA50P2.Start;
    Timer1.Enabled := true;
  end;
end;

procedure TFrmA_P2.Stop;
begin
  if FA50P2 <> nil then
  begin
    FA50P2.Stop;
    Color := clBtnFace;
    //FA50P2.OnJarvisEvent  := nil;
  end;
end;

procedure TFrmA_P2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmA_P2.FormCreate(Sender: TObject);
begin
  FSymbol := nil;
  FAccount  := nil;
  FFund     := nil;
  FIndex    := -1;
  FA50P2    := TA50_P2_Trend.Create( Self );

  cbInvestTypeChange( cbInvestType );
end;

procedure TFrmA_P2.FormDestroy(Sender: TObject);
begin
  if FA50P2 <> nil then
    FA50P2.Free;

end;

procedure TFrmA_P2.GetParam;
begin
  with FParam do
  begin
    OrdQty  := StrToIntDef( edtOrdQty.Text, 1 );
    TermCnt := StrToIntDef( edtTermCnt.Text, 12 );
    ATRMulti:= StrToIntDef( edtATRMulti.Text, 4 );
    E_1 := StrToFloatDef( edtE1.Text, 3.0 );
    L_1 := StrToFloatDef( edtL1.Text, 0.013 );
    L_2 := StrToFloatDef( edtL2.Text, 0.018 );
    Period := StrToIntDef( edtPeriod.Text , 5 );
    StartTime := Frac(dtStart.Time);
    Endtime := Frac(dtEnd.Time);
    EntTime := Frac(dtEntStart.Time);
    EntEndtime := Frac(dtEntEnd.Time);
    ReEntTime := Frac(dtReEntStart.Time);
    ReEntEndtime := Frac(dtReEntEnd.Time);
    ATRLiqTime  := Frac( dtATRLiqStart.Time );
    MkStartTime := Frac( mkStart.Time );

    CalcCnt     := StrToIntDef( edtATRPeriod.Text, 30 );

    GoalP := StrTointDef( edtGoalp.Text, 480); 
  end;
end;

procedure TFrmA_P2.LoadEnv(aStorage: TStorage);
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
  dtStart.Time      := TDateTime(aStorage.FieldByName('StartTime').AsTimeDef( dtStart.Time )  );
  dtEnd.Time        := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time ) );
  dtEntStart.Time   := TDateTime(aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time ));
  dtEntEnd.Time     := TDateTime(aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntend.Time ));
  dtReEntStart.Time := TDateTime(aStorage.FieldByName('ReEntStartTime').AsTimeDef( dtReEntStart.Time));
  dtReEntEnd.Time   := TDateTime(aStorage.FieldByName('ReEntEndTime').AsTimeDef( dtReEntEnd.Time ));
  dtATRLiqStart.Time   := TDateTime(aStorage.FieldByName('ATRLiqStartTime').AsTimeDef( dtATRLiqStart.Time ));

  MkStart.Time      := TDateTime(aStorage.FieldByName('MarketStartTime').AsTimeDef( mkStart.Time )  );
  //
  edtATRPeriod.Text := aStorage.FieldByName('ATRPeriod').AsStringDef('30');
  edtATRMulti.Text  := aStorage.FieldByName('ATRMulti').AsStringDef('4') ;
  edtTermCnt.Text   := aStorage.FieldByName('TermCnt').AsStringDef('36') ;
  edtOrdQty.Text    := aStorage.FieldByName('OrdQty').AsStringDef('1')  ;
  edtE1.Text        := aStorage.FieldByName('E1').AsStringDef('3.0') ;
  edtL1.Text        := aStorage.FieldByName('L1').AsStringDef('0.013') ;
  edtL2.Text        := aStorage.FieldByName('L2').AsStringDef('0.018') ;
  edtPeriod.Text    := aStorage.FieldByName('Period').AsStringDef('5') ;

  edtGoalp.Text     := aStorage.FieldByName('Goalp').AsStringDef('480')  ;

end;

procedure TFrmA_P2.SaveEnv(aStorage: TStorage);
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

  aStorage.FieldByName('StartTime').AsFloat       := double( dtStart.Time );
  aStorage.FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
  aStorage.FieldByName('EntStartTime').AsFloat    := double( dtEntStart.Time );
  aStorage.FieldByName('EntEndTime').AsFloat      := double( dtEntEnd.Time );
  aStorage.FieldByName('ReEntStartTime').AsFloat  := double( dtReEntStart.Time );
  aStorage.FieldByName('ReEntEndTime').AsFloat    := double( dtReEntEnd.Time );
  aStorage.FieldByName('ATRLiqStartTime').AsFloat := double( dtATRLiqStart.Time );
  //
  aStorage.FieldByName('MarketStartTime').AsFloat    := double( MkStart.Time );
  //
  aStorage.FieldByName('ATRPeriod').AsString    := edtATRPeriod.Text;
  aStorage.FieldByName('ATRMulti').AsString     := edtATRMulti.Text;
  aStorage.FieldByName('TermCnt').AsString    := edtTermCnt.Text;
  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('E1').AsString := edtE1.Text;
  aStorage.FieldByName('L1').AsString := edtL1.Text;
  aStorage.FieldByName('L2').AsString := edtL2.Text;
  aStorage.FieldByName('Period').AsString := edtPeriod.Text;
  aStorage.FieldByName('Goalp').AsString  := edtGoalp.Text;
end;

procedure TFrmA_P2.Timer1Timer(Sender: TObject);
begin
  if FA50P2 <> nil then
  with sgLog do
  begin
    Cells[0,0]  :=  Format('%.2f', [ FA50P2.ATR]);
    Cells[1,0]  :=  Format('%.2f', [ FA50P2.StartOpen]);
    if FA50P2.Symbol<> nil then    
      Cells[2,0]  :=  Format('%.2f', [ FA50P2.Symbol.DawnOpen]);
    Cells[3,0]  :=  Format('%.2f', [ FA50P2.HL]);
    //Cells[3,0]  :=  Format('%.2f', [ FA50P2.HL2]);

    Cells[0,1]  :=  Format('%.2f', [ FA50P2.EntryPrice]);
    Cells[1,1]  :=  Format('%.2f', [ FA50P2.EntHigh]);
    Cells[2,1]  :=  Format('%.2f', [ FA50P2.EntLow]);
    Cells[3,1]  :=  Format('%d', [ FA50P2.EntTermCnt]);

    if FSymbol <> nil then
    begin
      //Cells[3,0]  :=  Format('%.2f', [ FSymbol.Last]);
      Cells[0,2]  :=  Format('%.2f', [ FSymbol.PrevH[1] ]);
      Cells[1,2]  :=  Format('%.2f', [ FSymbol.PrevL[1]]);
      Cells[2,2]  :=  Format('%.2f', [ FSymbol.PrevH[0]]);
      Cells[3,2]  :=  Format('%.2f', [ FSymbol.PrevL[0]]);
    end;

    stTxt.Panels[0].Text  := Format('%.2f',[ FA50P2.PL ]);
  end;
end;

procedure TFrmA_P2.WMSymbolSelected(var msg: TMessage);
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
