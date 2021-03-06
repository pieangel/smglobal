unit FHnVHultManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, ExtCtrls,

  CleAccounts, ClePositions, CleSymbols, CleQuoteBroker , CleHnVHultManager,

  CleStorage
  ;

const
  Item_Col = 0;
  TitleCnt = 9;
  Title : array [0..TitleCnt-1] of string = (
    '이름','계좌','종목','상태','잔고','손익','최대','최소','대상' );

type
  TFrmHnVHultManager = class(TForm)
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    sgData: TStringGrid;
    sgLog: TStringGrid;
    Timer1: TTimer;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
  private
    procedure initControls;
    procedure UpdateData;
    { Private declarations }
  public
    { Public declarations }
    procedure AddLog( stLog : string );
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmHnVHultManager: TFrmHnVHultManager;

implementation

uses
  GAppEnv , GleLib,
  CleQuoteTimers
  ;

{$R *.dfm}

procedure TFrmHnVHultManager.AddLog(stLog: string);
begin
  InsertLine( sgLog, 1 );
  sgLog.Cells[0,1]  := FormatDateTime('hh:nn:ss.zzz', GetQuoteTime );
  sgLog.Cells[1,1]  := stLog;
end;

procedure TFrmHnVHultManager.CheckBox1Click(Sender: TObject);
begin
  gEnv.Engine.TradeCore.HnVHults.HControl := CheckBox1.Checked;
end;

procedure TFrmHnVHultManager.CheckBox2Click(Sender: TObject);
begin
  gEnv.Engine.TradeCore.HnVHults.HultLc := CheckBox2.Checked;
end;

procedure TFrmHnVHultManager.CheckBox3Click(Sender: TObject);
begin
  gEnv.Engine.TradeCore.HnVHults.TotPLLC := CheckBox3.Checked;
end;

procedure TFrmHnVHultManager.CheckBox4Click(Sender: TObject);
begin
  gEnv.Engine.TradeCore.HnVHults.SameHnVHultLc := CheckBox4.Checked;
end;

procedure TFrmHnVHultManager.CheckBox5Click(Sender: TObject);
begin
//
  gEnv.Engine.TradeCore.HnVHults.VHHalfLc := CheckBox5.Checked;
end;

procedure TFrmHnVHultManager.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TFrmHnVHultManager.FormCreate(Sender: TObject);
begin
  gEnv.HnVH := self;
  initControls;
end;

procedure TFrmHnVHultManager.FormDestroy(Sender: TObject);
begin
  gEnv.HnVH := nil;
end;

procedure TFrmHnVHultManager.initControls;
var
  I: Integer;
begin

  sgData.ColCount := TitleCnt;
  for I := 0 to sgData.ColCount - 1 do
    sgData.Cells[i,0] := Title[i];

  sgLog.Cells[0,0]  := '시각';
  sgLog.Cells[1,0]  := '내용';
end;

procedure TFrmHnVHultManager.LoadEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  CheckBox1.Checked := aStorage.FieldByName('UseHultControl').AsBoolean ;
  CheckBox2.Checked := aStorage.FieldByName('UseHultLossCut').AsBoolean ;
  CheckBox3.Checked := aStorage.FieldByName('UseTotPLLiq').AsBoolean;
  CheckBox4.Checked := aStorage.FieldByName('UseSameTimeHnVHultLossCut').AsBoolean;
  CheckBox5.Checked := aStorage.FieldByName('UseVHHalfLossCut').AsBoolean;

  gEnv.Engine.TradeCore.HnVHults.HControl := CheckBox1.Checked;
  gEnv.Engine.TradeCore.HnVHults.HultLc := CheckBox2.Checked;
  gEnv.Engine.TradeCore.HnVHults.TotPLLC := CheckBox3.Checked;
  gEnv.Engine.TradeCore.HnVHults.SameHnVHultLc := CheckBox4.Checked;
  gEnv.Engine.TradeCore.HnVHults.VHHalfLc := CheckBox5.Checked;

end;

procedure TFrmHnVHultManager.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('UseHultControl').AsBoolean := CheckBox1.Checked;
  aStorage.FieldByName('UseHultLossCut').AsBoolean := CheckBox2.Checked;
  aStorage.FieldByName('UseTotPLLiq').AsBoolean := CheckBox3.Checked;
  aStorage.FieldByName('UseSameTimeHnVHultLossCut').AsBoolean := CheckBox4.Checked;
  aStorage.FieldByName('UseVHHalfLossCut').AsBoolean  := CheckBox5.Checked;

end;

procedure TFrmHnVHultManager.Timer1Timer(Sender: TObject);
begin
  UpdateData;
end;

procedure TFrmHnVHultManager.UpdateData;
var
  aItem, tItem : THnVHultItem;
  I,j, iCol, iRow: Integer;
begin

  for I := 1 to sgData.RowCount - 1 do
    sgData.Rows[i].Clear;

  iRow := 1;
  with sgData do
  for I := 0 to gEnv.Engine.TradeCore.HnVHults.Count - 1 do
    for j := 0 to gEnv.Engine.TradeCore.HnVHults.HnVHults[i].HnVHults.Count - 1 do
    begin
      iCol := 0;
      aItem := gEnv.Engine.TradeCore.HnVHults.HnVHults[i].HnVHults.HnVHult[j];
      Cells[iCol,iRow]  := IntToStr( i + 1 ) + ' ' +aItem.GetStg ;   inc(iCol);
      Cells[iCol,iRow]  := aItem.Account.Name;       inc(iCol);
      Cells[iCol,iRow]  := aItem.Symbol.Code; inc(iCol);

      Cells[iCol,iRow]  := aItem.GetHnVH;  inc(iCol);
      Cells[iCol,iRow]  := IntToStr( aItem.Position.Volume );  inc(iCol);
      Cells[iCol,iRow]  := Format('%.0f', [ aItem.Position.LastPL / 1000.0 ] ); inc(iCol);

      Cells[iCol,iRow]  := Format('%.0f', [ aItem.MaxPL / 1000.0 ] );  inc(iCol);
      Cells[iCol,iRow]  := Format('%.0f', [ aItem.MinPL / 1000.0 ] ); inc(iCol);

      tItem := aItem.Target;//  gEnv.Engine.TradeCore.HnVHults.HnVHults[i].HnVHults.HnVHult[ aItem.TargetIdx  ];
      if tItem <> nil then
        Cells[iCol,iRow]  := tItem.Account.Name
      else
        Cells[iCol,iRow]  := '';
      inc(iCol);
      inc(iRow);
    end;
end;

end.
