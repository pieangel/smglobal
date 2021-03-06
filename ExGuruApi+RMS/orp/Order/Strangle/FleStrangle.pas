unit FleStrangle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
  CleStrangle, CleAccounts, GleLib, CleQuoteBroker, CleSymbols, CleQuoteTimers,
  ComCtrls, CleStrategyStore, CleStorage;

const
  FutTitle : array[0..3] of string =
                            ('Code', '현재가', '매도건수', '매수건수');
  OptTitle : array[0..3] of string =
                            ('Code', '현재가', '포지션', '평가손익');
  StatusTitle : array[0..5] of string =
                            ('시가', '09:15', '10:00', '11:00', '12:00', '13:00');
type
  TFrmStrangle = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    btnSymbol: TButton;
    sgStatus: TStringGrid;
    sgFut: TStringGrid;
    sgOpt: TStringGrid;
    Timer1: TTimer;
    edtQty: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtStatus: TEdit;
    edtUpBid1: TEdit;
    edtUpBid2: TEdit;
    edtUpBid3: TEdit;
    edtUpAsk1: TEdit;
    edtUpAsk2: TEdit;
    edtUpAsk3: TEdit;
    edtDownBid1: TEdit;
    edtDownAsk1: TEdit;
    edtDownBid2: TEdit;
    edtDownAsk2: TEdit;
    edtDownBid3: TEdit;
    edtDownAsk3: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cbLow: TCheckBox;
    StatusBar1: TStatusBar;
    edtLow: TEdit;
    Label9: TLabel;
    edtHigh: TEdit;
    Label10: TLabel;
    btnClear: TButton;
    cbUseHedge: TCheckBox;
    Label12: TLabel;
    edtLoss: TEdit;
    Button1: TButton;
    Label11: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgFutDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cbStartClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FTrade : TStrangleTrade;
    FAccount : TAccount;
    procedure InitGrid;
    procedure ClearGrid;
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure OnDisplay(Sender: TObject; Value : boolean );
  end;

var
  FrmStrangle: TFrmStrangle;

implementation

uses
  GAppEnv, GleConsts, GleTypes;
{$R *.dfm}

procedure TFrmStrangle.btnClearClick(Sender: TObject);
begin
  FTrade.ClearOrder;
end;

procedure TFrmStrangle.btnSymbolClick(Sender: TObject);
begin
  FTrade.SetSymbol;
end;

procedure TFrmStrangle.Button1Click(Sender: TObject);
var
  dAmt   : double;
begin
  dAmt  := StrToFloatDef( edtLoss.Text, 0 );
  if dAmt <= 0 then
  begin
    ShowMessage('한도 금액 0 이상이여야함 ');
    Exit;
  end;

  FTrade.SetStopLossAmt( dAmt * 1000 );
end;

procedure TFrmStrangle.cbStartClick(Sender: TObject);
var
  aParam : TStrangleParams;
begin
  // 스타트 스탑 주문수량 Enable

  aParam.Start := cbStart.Checked;
  aParam.OrderQty := StrToIntDef(edtQty.Text, 1);

  aParam.UpBid[0] := StrToFloatDef(edtUpBid1.Text, 0.7);
  aParam.UpBid[1] := StrToFloatDef(edtUpBid2.Text, 0.65);
  aParam.UpBid[2] := StrToFloatDef(edtUpBid3.Text, 0.6);

  aParam.UpAsk[0] := StrToFloatDef(edtUpAsk1.Text, 0.9);
  aParam.UpAsk[1] := StrToFloatDef(edtUpAsk2.Text, 1);
  aParam.UpAsk[2] := StrToFloatDef(edtUpAsk3.Text, 1.1);

  aParam.DownBid[0] := StrToFloatDef(edtDownBid1.Text, 0.7);
  aParam.DownBid[1] := StrToFloatDef(edtDownBid2.Text, 0.65);
  aParam.DownBid[2] := StrToFloatDef(edtDownBid3.Text, 0.6);

  aParam.DownAsk[0] := StrToFloatDef(edtDownAsk1.Text, 0.9);
  aParam.DownAsk[1] := StrToFloatDef(edtDownAsk2.Text, 1);
  aParam.DownAsk[2] := StrToFloatDef(edtDownAsk3.Text, 1.1);
  aParam.LowOrder := cbLow.Checked;

  aParam.LowPrice := StrToFloatDef(edtLow.Text , 0.5);
  aParam.HighPrice := StrToFloatDef(edtHigh.Text , 2.0);
  aParam.UseHedge := cbUseHedge.Checked;
  aParam.LossAmt  := StrToFloatDef( edtLoss.Text, 200 ) * 1000;
  FTrade.SetAccount(FAccount);
  FTrade.StartStop(aParam);

  Button1.Enabled := aParam.Start;
end;

procedure TFrmStrangle.ClearGrid;
var
  i, j : integer;
begin
  for i := 1 to sgOpt.RowCount - 1 do
  begin
    for j := 0 to sgOpt.ColCount - 1 do
      sgOpt.Cells[j,i] := '';
  end;
end;

procedure TFrmStrangle.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  startTIme : TDateTime;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;

  FTrade.SetAccount(FAccount);

  cbStart.Checked := false;
  cbStartClick(cbStart);



  startTime := EncodeTime(9,0,0,0);
  if Frac(GetQuoteTime) > startTime then
  begin
    // 초기화......
    ClearGrid;
    FTrade.ReSet;

    FTrade.SetSymbol;
  end;
end;

procedure TFrmStrangle.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmStrangle.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  InitGrid;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;

  FTrade := TStrangleTrade.Create(aColl, opStrangle);
  FTrade.OnResult := OnDisplay;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;
end;

procedure TFrmStrangle.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StrategyGate.Del(FTrade);
  FTrade := nil;
end;

procedure TFrmStrangle.InitGrid;
var
  i : integer;
begin
  for i := 0 to 3 do
  begin
    sgFut.Cells[i,0] := FutTitle[i];
    sgOpt.Cells[i,0] := OptTitle[i];
  end;

  for i := 0 to 5 do
    sgStatus.Cells[i,0] := StatusTitle[i];
end;

procedure TFrmStrangle.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aAccount : TAccount;
begin

  if aStorage.FieldByName('edtQty').AsString = '' then
    edtQty.Text := '1'
  else
    edtQty.Text := aStorage.FieldByName('edtQty').AsString;
  cbLow.Checked := aStorage.FieldByName('cbLow').AsBoolean;
  cbUseHedge.Checked := aStorage.FieldByName('cbUseHedge').AsBoolean;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  aAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( ComboAccount, aAccount );
    ComboAccountChange(ComboAccount);
  end;

  edtLoss.Text := aStorage.FieldByName('LossAmt').AsStringDef( '200');
end;

procedure TFrmStrangle.OnDisplay(Sender: TObject; Value: boolean);
var
  i, iCol, iRow : integer;
  aQuote : TQuote;
  aItem : TStrangle;
begin
  if Sender = nil then exit;

  aQuote := Sender as TQuote;

  sgFut.Cells[0,1] := aQuote.Symbol.ShortCode;
  sgFut.Cells[1,1] := Format('%.2f', [aQuote.Last]);
  sgFut.Cells[2,1] := Format('%d', [aQuote.Asks.CntTotal]);
  sgFut.Cells[3,1] := Format('%d', [aQuote.Bids.CntTotal]);

  edtStatus.Text := FTrade.Strangles.GetStatusDesc;
  StatusBar1.Panels[0].Text  := Format('%.0n', [FTrade.TotPL ]);

  iRow := 1;
  for i := 0 to FTrade.Strangles.Count - 1 do
  begin
    aItem := FTrade.Strangles.Items[i] as TStrangle;
    iCol := 0;
    sgOpt.Cells[iCol, iRow] := aItem.Symbol.ShortCode; inc(iCol);
    sgOpt.Cells[iCol, iRow] := Format('%.2f', [aItem.Symbol.Last]); inc(iCol);
    if aItem.Position <> nil then
    begin
      sgOpt.Cells[iCol, iRow] := Format('%d', [aItem.Position.Volume]); inc(iCol);
      sgOpt.Cells[iCol, iRow] := Format('%.0n', [aItem.Position.EntryOTE]); inc(iCol);
    end;
    inc(iRow);
  end;

  for i := 0 to 5 do
    sgStatus.Cells[i,1] := ' ';

  if sgStatus.Objects[0, 1] = nil then
  begin
    for i := 0 to 5 do
      sgStatus.Objects[i, 1]:= FTrade.Strangles.GetTimeOrder(i) as TObject;
  end;
end;

procedure TFrmStrangle.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('edtQty').AsString := edtQty.Text;
  aStorage.FieldByName('cbLow').AsBoolean := cbLow.Checked;
  aStorage.FieldByName('cbUseHedge').AsBoolean := cbUseHedge.Checked;

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  aStorage.FieldByName('LossAmt').AsString := edtLoss.Text;

end;

procedure TFrmStrangle.sgFutDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat : Word;
  sgGrid : TStringGrid;
  dData : double;
  aItem : TTimeOrder;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_CENTER;

  sgGrid := Sender as TStringGrid;
  with sgGrid do
  begin
    stTxt := Cells[ ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace
    else
    begin
      if Tag = 1 then
      begin
        aItem := Objects[ACol, 1] as TTimeOrder;
        if aItem <> nil then
        begin
          if aItem.Send then aBack := SELECTED_COLOR2;
        end;
      end;
    end;
    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmStrangle.Timer1Timer(Sender: TObject);
var
  startTime : TDateTime;
begin
  startTime := EncodeTime(8,59,58,0);
  if Frac(GetQuoteTime) > startTime then
  begin
    ClearGrid;
    FTrade.ReSet;
    FTrade.SetSymbol;

    if FTrade.Strangles.Count > 0 then
    begin
      Timer1.Enabled  := false;
      StatusBar1.Panels[1].Text := Format('청산시간 : %s', [FormatDateTime('hh:nn:ss', FTrade.EndTime)]);
    end;
    //btnSymbol.Enabled := false;
    //ComboAccount.Enabled := false;
  end;

end;

end.
