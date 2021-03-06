unit FA50Trend;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  GleTypes,  CleAccounts, CleFunds,
  CleSymbols,  cleDistributor,  CleQuoteBroker, CleA50Trend,

  CleStorage, ComCtrls, Grids;

type
  TFrmA50Trend = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    cbInvest: TComboBox;
    cbInvestType: TComboBox;
    edtSymbol: TLabeledEdit;
    dtStart: TDateTimePicker;
    dtEnd: TDateTimePicker;
    Label1: TLabel;
    stTxt: TStatusBar;
    edtE1: TLabeledEdit;
    edtL1: TLabeledEdit;
    Label2: TLabel;
    dtEntStart: TDateTimePicker;
    Label3: TLabel;
    Label4: TLabel;
    dtEntend: TDateTimePicker;
    Label5: TLabel;
    dtLiqStart: TDateTimePicker;
    edtPeriod: TLabeledEdit;
    Timer1: TTimer;
    mkStart: TDateTimePicker;
    Label7: TLabel;
    edtATRPeriod: TLabeledEdit;
    edtATRMulti: TLabeledEdit;
    edtOrdQty: TLabeledEdit;
    edtTrl1P: TLabeledEdit;
    edtTrl2p: TLabeledEdit;
    edtGoalP: TLabeledEdit;
    Button2: TButton;
    edtTermCnt: TLabeledEdit;
    sgLog: TStringGrid;
    cbRun: TCheckBox;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure edtE1KeyPress(Sender: TObject; var Key: Char);
    procedure cbRunClick(Sender: TObject);
    procedure cbInvestTypeChange(Sender: TObject);
    procedure cbInvestChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    { Private declarations }
    FIndex    : integer;
    FAccount  : TAccount;
    FFund     : TFund;
    FSymbol : TSymbol;
    FA50Trend : TA50Trend;
    FParam    : TA50Param;
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
  FrmA50Trend: TFrmA50Trend;

implementation

uses
  GAppEnv, GleLib,
  DateUtils
  ;

{$R *.dfm}

procedure TFrmA50Trend.Button1Click(Sender: TObject);
begin

  if gSymbol = nil then
    gEnv.CreateSymbolSelect;
  gSymbol.ShowWindow( Handle );

end;

procedure TFrmA50Trend.Button2Click(Sender: TObject);
begin
  if (FA50Trend <> nil) and ( cbRun.Checked ) then
  begin
    GetParam;
    FA50Trend.Param := FParam;
    FA50Trend.CalcHL;
  end;
end;



procedure TFrmA50Trend.Button3Click(Sender: TObject);
begin
  if (FA50Trend <> nil) then
    FA50Trend.DoOrder;
end;

procedure TFrmA50Trend.Button4Click(Sender: TObject);
begin
 if (FA50Trend <> nil) then
    FA50Trend.DoLiquid;
end;

procedure TFrmA50Trend.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmA50Trend.FormCreate(Sender: TObject);
begin
  FSymbol := nil;
  FAccount  := nil;
  FFund     := nil;
  FIndex    := -1;
  FA50Trend := TA50Trend.Create( self );

  cbInvestTypeChange( cbInvestType );
end;

procedure TFrmA50Trend.FormDestroy(Sender: TObject);
begin
  if FA50Trend <> nil then
    FA50Trend.Free;
end;

procedure TFrmA50Trend.GetParam;
begin
  with FParam do
  begin
    OrdQty  := StrToIntDef( edtOrdQty.Text, 1 );
    TermCnt := StrToIntDef( edtTermCnt.Text, 12 );
    ATRMulti:= StrToIntDef( edtATRMulti.Text, 4 );
    E_I := StrToFloatDef( edtE1.Text, 3.8 );
    L_I := StrToFloatDef( edtL1.Text, 0.012 );
    Period := StrToIntDef( edtPeriod.Text , 5 );
    StartTime := Frac(dtStart.Time);
    Endtime := Frac(dtEnd.Time);
    EntTime := Frac(dtEntStart.Time);
    EntEndtime := Frac(dtEntEnd.Time);
    LiqStTime := Frac(dtLiqstart.Time);
    MkStartTime := Frac( mkStart.Time );

    CalcCnt     := StrToIntDef( edtATRPeriod.Text, 30 );

    Trl1P := StrToIntDef( edtTrl1p.Text, 300);
    Trl2P := StrToIntDef( edtTrl2p.Text, 100);
    GoalP := StrTointDef( edtGoalp.Text, 700); 
  end;
end;

procedure TFrmA50Trend.edtE1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
  
end;

procedure TFrmA50Trend.LoadEnv(aStorage: TStorage);
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
  dtLiqStart.Time   := TDateTime(aStorage.FieldByName('LiqStartTime').AsTimeDef( dtLiqStart.Time ));

  MkStart.Time      := TDateTime(aStorage.FieldByName('MarketStartTime').AsTimeDef( mkStart.Time )  );
  //
  edtATRPeriod.Text := aStorage.FieldByName('ATRPeriod').AsStringDef('30');
  edtATRMulti.Text  := aStorage.FieldByName('ATRMulti').AsStringDef('4') ;
  edtTermCnt.Text   := aStorage.FieldByName('TermCnt').AsStringDef('12') ;
  edtOrdQty.Text    := aStorage.FieldByName('OrdQty').AsStringDef('1')  ;
  edtE1.Text        := aStorage.FieldByName('E1').AsStringDef('3.8') ;
  edtL1.Text        := aStorage.FieldByName('L1').AsStringDef('0.012') ;
  edtPeriod.Text    := aStorage.FieldByName('Period').AsStringDef('5') ;
  edtTrl1p.Text     := aStorage.FieldByName('Trl1p').AsStringDef('300')  ;
  edtTrl2p.Text     := aStorage.FieldByName('Trl2p').AsStringDef('100')  ;
  edtGoalp.Text     := aStorage.FieldByName('Goalp').AsStringDef('700')  ;
end;

procedure TFrmA50Trend.SaveEnv(aStorage: TStorage);
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
  aStorage.FieldByName('LiqStartTime').AsFloat    := double( dtLiqStart.Time );
  //
  aStorage.FieldByName('MarketStartTime').AsFloat    := double( MkStart.Time );
  //
  aStorage.FieldByName('ATRPeriod').AsString    := edtATRPeriod.Text;
  aStorage.FieldByName('ATRMulti').AsString     := edtATRMulti.Text;
  aStorage.FieldByName('TermCnt').AsString    := edtTermCnt.Text;
  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('E1').AsString := edtE1.Text;
  aStorage.FieldByName('L1').AsString := edtL1.Text;
  aStorage.FieldByName('Period').AsString := edtPeriod.Text;
  aStorage.FieldByName('Trl1p').AsString  := edtTrl1p.Text;
  aStorage.FieldByName('Trl2p').AsString  := edtTrl2p.Text;
  aStorage.FieldByName('Goalp').AsString  := edtGoalp.Text;

end;

procedure TFrmA50Trend.WMSymbolSelected(var msg: TMessage);
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

procedure TFrmA50Trend.cbInvestChange(Sender: TObject);
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

procedure TFrmA50Trend.cbInvestTypeChange(Sender: TObject);
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

procedure TFrmA50Trend.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmA50Trend.Start;
begin
  if ( FSymbol = nil ) or (( FIndex = 0 ) and ( FAccount = nil ))  or
     ((FIndex = 1) and ( FFund = nil ))  then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbRun.Checked := false;
    Exit;
  end;

  if FA50Trend <> nil then
  begin

    Color := clSkyblue;
    GetParam;
    FA50Trend.Param := FParam;

    if cbInvestType.ItemIndex = 0 then
      FA50Trend.init( FAccount, FSymbol )
    else
      FA50Trend.init( FFund, FSymbol );
    FA50Trend.Start;
    //FBHultAxis.OnJarvisEvent  := OnJarvisNotify;
    Timer1.Enabled := true;

  end;
end;

procedure TFrmA50Trend.Stop;
begin
  if FA50Trend <> nil then
  begin
    FA50Trend.Stop;
    Color := clBtnFace;
    //FA50Trend.OnJarvisEvent  := nil;
  end;
end;

procedure TFrmA50Trend.Timer1Timer(Sender: TObject);
begin
  if FA50Trend <> nil then
  with sgLog do
  begin
    Cells[0,0]  :=  Format('%.2f', [ FA50Trend.ATR]);
    Cells[1,0]  :=  Format('%.2f', [ FA50Trend.StartOpen]);
    Cells[2,0]  :=  Format('%.2f', [ FA50Trend.HL2]);
    //Cells[3,0]  :=  Format('%.2f', [ FA50Trend.HL]);

    Cells[0,1]  :=  Format('%.2f', [ FA50Trend.EntryPrice]);
    Cells[1,1]  :=  Format('%.2f', [ FA50Trend.EntHigh]);
    Cells[2,1]  :=  Format('%.2f', [ FA50Trend.EntLow]);
    Cells[3,1]  :=  Format('%d', [ FA50Trend.EntTermCnt]);

    if FSymbol <> nil then
    begin
      Cells[3,0]  :=  Format('%.2f', [ FSymbol.Last]);
      Cells[0,2]  :=  Format('%.2f', [ FSymbol.PrevH[1] ]);
      Cells[1,2]  :=  Format('%.2f', [ FSymbol.PrevL[1]]);
      Cells[2,2]  :=  Format('%.2f', [ FSymbol.PrevH[0]]);
      Cells[3,2]  :=  Format('%.2f', [ FSymbol.PrevL[0]]);
    end;

    stTxt.Panels[0].Text  := Format('%.2f',[ FA50Trend.PL ]);

  end;
{

 property TermCnt : integer read FTermCnt;
    property StartOpen : double read FStartOpen;  // 스타트 시각 시가..
    property EntryPrice: double read FEntryPrice; // 진입가격
    property EntHigh : double read FEntHigh;      // 진입이후 고가
    property EntLow  : double read FEntLow;       // 진입이후 저가
    property EntTermCnt : integer read FEntTermCnt; // 진입 이후 봉
  if FA50Trend <> nil then
  begin
    stTxt.Panels[1].Text  := Format('ATR:%.2f,' +
                                    'HL:%.2f,' +
                                    'HL2:%.2f',
                                    [ FA50Trend.ATR, FA50Trend.HL, FA50Trend.HL2 ]);
  end;
  }
end;

end.
