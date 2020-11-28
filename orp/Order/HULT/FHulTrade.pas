unit FHulTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Math,

  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker,

  CleStorage, UPaveConfig , CleHultAxis, GleTypes, Grids


  ;

type
  TFrmHulTrade = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label2: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    gbUseHul: TGroupBox;
    cbAllcnlNStop: TCheckBox;
    gbRiquid: TGroupBox;
    DateTimePicker: TDateTimePicker;
    cbAutoLiquid: TCheckBox;
    stTxt: TStatusBar;
    Label6: TLabel;
    edtRiskAmt: TEdit;
    UpDown5: TUpDown;
    sgAmt: TStringGrid;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    edtQty: TEdit;
    UpDown1: TUpDown;
    Label4: TLabel;
    edtGap: TEdit;
    UpDown2: TUpDown;
    Label5: TLabel;
    edtQuoting: TEdit;
    udQuoting: TUpDown;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    edtSPos: TEdit;
    udSPos: TUpDown;
    Label8: TLabel;
    edtEPos: TEdit;
    udEPos: TUpDown;
    cbUseBetween: TCheckBox;
    Label9: TLabel;
    edtSTick: TEdit;
    udSTick: TUpDown;
    btnApply: TButton;
    btnColor: TButton;
    ColorDialog: TColorDialog;
    cbPause: TCheckBox;
    DateTimePicker1: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure edtGapKeyPress(Sender: TObject; var Key: Char);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure cbPauseClick(Sender: TObject);
  private
    { Private declarations }
    FAccount : TAccount;
    FSymbol  : TSymbol;
    FTimer   : TQuoteTimer;
    FHultData : THultData;
    FHultAxis : THultAxis;
    FMax, FMin : double;
    FPosition : TPosition;
    FEndTime : TDateTime;
    FAutoStart  : boolean;
    FStartColor : TColor;

    procedure initControls;
    procedure GetParam;
    procedure Timer1Timer(Sender: TObject);
  public
    { Public declarations }
    procedure Stop;
    procedure Start;

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmHulTrade: TFrmHulTrade;

implementation

uses
  GAppEnv , GleLib, CleStrategyStore
  ;

{$R *.dfm}

procedure TFrmHulTrade.btnApplyClick(Sender: TObject);
begin
  GetParam;
  if FHultAxis <> nil then
    FHultAxis.HultData := FHultData;
end;

procedure TFrmHulTrade.btnColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    FStartColor := ColorDialog.Color;
  end;
end;

procedure TFrmHulTrade.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.Code;
          FHultAxis := nil;

        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmHulTrade.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    FAccount := aAccount;
    FHultAxis := nil;
  end;
end;

procedure TFrmHulTrade.cbAutoLiquidClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TCheckBox ).Tag;

  if iTag = 0 then
    FHultData.UseAutoLiquid := cbAutoLiquid.Checked
  else if iTag = 1 then
    FHultData.UseAllcnlNStop  := cbAllcnlNStop.Checked
  else if iTag = 2 then
  begin
    FHultData.UseBetween := cbUseBetween.Checked;

    if FHultData.UseBetween then
      GroupBox2.Enabled := false
    else
    begin
      GroupBox2.Enabled := true;
      if FHultAxis <> nil then
        FHultAxis.DoBetweenCancel;
    end;
  end;

  if FHultAxis <> nil then
    FHultAxis.HultData := FHultData;
end;

procedure TFrmHulTrade.cbPauseClick(Sender: TObject);
begin
  FHultData.UsePause := cbPause.Checked;
  if FHultAxis <> nil then
  begin
   FHultAxis.HultData := FHultData;
   FHultAxis.Pause;
  end;
end;

procedure TFrmHulTrade.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop;
end;

procedure TFrmHulTrade.edtGapKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmHulTrade.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmHulTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmHulTrade.FormCreate(Sender: TObject);
begin
  initControls;
  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;
  FPosition   := nil;
  FAutoStart  := false;
end;

procedure TFrmHulTrade.FormDestroy(Sender: TObject);
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  if FHultAxis <> nil then
    FHultAxis.Free;
end;

procedure TFrmHulTrade.GetParam;
begin
  with FHultData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 1 );
    UseAllcnlNStop  := cbAllcnlNStop.Checked;
    LiquidTime  :=  DateTimePicker.Time;
    UseAutoLiquid := cbAutoLiquid.Checked;
    QuotingQty := StrTointDef( edtQuoting.Text, 5 );
    RiskAmt := UpDown5.Position;
    UseBetween := cbUseBetween.Checked;
    SPos := udSPos.Position;
    EPos := udEPos.Position;
    STick := udSTick.Position;
    StartTime := DateTimePicker1.Time;
  end;

  if FHultAxis <> nil then
    FHultAxis.HultData := FHultData;
end;

procedure TFrmHulTrade.initControls;
begin
  FStartColor := clBtnFace;
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TFrmHulTrade.SaveEnv(aStorage: TStorage);
var
  stLog, stFile : string;
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked;
  aStorage.FieldByName('UseAllcnlNStop').AsBoolean := cbAllcnlNStop.Checked;
  aStorage.FieldByName('RiskAmt').AsInteger := UpDown5.Position;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('QuotingQty').AsString := edtQuoting.Text;
  aStorage.FieldByName('dtClear').AsString := FormatDateTime('hhnnss', DateTimePicker.Time);
  aStorage.FieldByName('dtStart').AsString := FormatDateTime('hhnnss', DateTimePicker1.Time);

  aStorage.FieldByName('UseBetween').AsBoolean := cbUseBetween.Checked;
  aStorage.FieldByName('SPos').AsInteger := udSPos.Position;
  aStorage.FieldByName('EPos').AsInteger := udEPos.Position;
  aStorage.FieldByName('STick').AsInteger := udSTick.Position;

  aStorage.FieldByName('OrdQty').AsString := edtQty.Text;
  aStorage.FieldByName('Color').AsInteger := integer(FStartColor);


  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

end;

procedure TFrmHulTrade.LoadEnv(aStorage: TStorage);
var
  stCode,stTime : string;
begin
  if aStorage = nil then Exit;

  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;

  //edtGap.Text
  UpDown2.Position := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 3 );
  Updown1.Position := StrToIntDef( aStorage.FieldByName('OrdQty').AsString , 1 );
  udQuoting.Position := StrToIntDef(aStorage.FieldByName('QuotingQty').AsString, 5 );

  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;
  cbAllcnlNStop.Checked := aStorage.FieldByName('UseAllcnlNStop').AsBoolean;
  UpDown5.Position := StrToIntDef(aStorage.FieldByName('RiskAmt').AsString, 1000 );

  cbUseBetween.Checked := aStorage.FieldByName('UseBetween').AsBoolean;
  udSPos.Position := StrToIntDef(aStorage.FieldByName('SPos').AsString, 6 );
  udEPos.Position := StrToIntDef(aStorage.FieldByName('EPos').AsString, 0 );
  udSTick.Position := StrToIntDef(aStorage.FieldByName('STick').AsString, 0 );
  FStartColor := TColor(aStorage.FieldByName('Color').AsInteger);
  if Integer(FStartColor) = 0 then
    FStartColor := clBtnFace;

  stTime := aStorage.FieldByName('dtClear').AsString;
  if stTime <>'' then
  begin
    DateTimePicker.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;
  stTime := aStorage.FieldByName('dtStart').AsString;
  if stTime <>'' then
  begin
    DateTimePicker1.Time := EncodeTime(StrToInt(Copy(stTime,1,2)),
                                    StrToInt(Copy(stTime,3,2)),
                                    StrToInt(Copy(stTime, 5,2)),
                                    0);
  end;
  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  if gEnv.RunMode = rtSimulation then
    FSymbol := gEnv.Engine.SymbolCore.Futures[0]
  else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if FSymbol <> nil then
   edtSymbol.Text  := FSymbol.Code;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end;
end;

procedure TFrmHulTrade.OnDisplay(Sender: TObject; Value: boolean);
begin
  if Value then
    Panel1.Color := FStartColor
  else
    Panel1.Color := clbtnFace;
end;

procedure TFrmHulTrade.Start;
var
  aColl : TStrategys;
begin
  if ( FSymbol = nil ) or ( FAccount = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FHultAxis = nil then
  begin
    aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
    FHultAxis := THultAxis.Create(aColl, opHult);
    FHultAxis.OnResult := OnDisplay;
  end;

  if FHultAxis <> nil then
  begin
    cbAccount.Enabled := false;
    button1.Enabled   := false;
    GroupBox1.Enabled := false;
    FHultAxis.init( FAccount, FSymbol );
    GetParam;
    FHultAxis.HultData := FHultData;
    FHultAxis.Start;
    FTimer.Enabled := true;
  end;
end;

procedure TFrmHulTrade.Stop;
begin
  cbAccount.Enabled := true;
  button1.Enabled   := true;
  GroupBox1.Enabled := true;
  if FHultAxis <> nil then
  begin
    //FTimer.Enabled := false;
    FHultAxis.Stop(false);
    FHultAxis.OnResult := nil;
    FHultAxis.Free;
    FHultAxis := nil;
    //FHultAxis.OnPositionEvent := nil;
  end;
end;

procedure TFrmHulTrade.Timer1Timer(Sender: TObject);
var
  stLog : string;
begin
  if FHultAxis = nil then exit;

  if FHultAxis.Position <> nil then
  begin
    stTxt.Panels[0].Text := Format('%d, %d', [ FHultAxis.Position.Volume, FHultAxis.Position.MaxPos ]);

    FMin := Min( FMin, (FHultAxis.Position.LastPL - FHultAxis.Position.GetFee) );
    FMax := Max( FMax, (FHultAxis.Position.LastPL - FHultAxis.Position.GetFee) );

    stTxt.Panels[1].Text := Format('%.0f, %.0f, %.0f', [
          (FHultAxis.Position.LastPL - FHultAxis.Position.GetFee)/1000 , FMax/1000, FMin/1000 ]);

    sgAmt.Cells[0,0] := Format('%.0f',[FHultAxis.Position.BidTradeAmount]);
    sgAmt.Cells[1,0] := Format('%.0f',[FHultAxis.Position.BidTradeAmountMax]);
    sgAmt.Cells[0,1] := Format('%.0f',[FHultAxis.Position.AskTradeAmount]);
    sgAmt.Cells[1,1] := Format('%.0f',[FHultAxis.Position.AskTradeAmountMax]);
  end;

  if FHultAxis.Run then
    Panel1.Color := FStartColor;
end;

end.
