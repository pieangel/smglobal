unit FRiskManage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls,

  CleAccounts, CleSymbols, ClePositions, CleQuoteBroker,

  CleDistributor, CleStorage,

  GleTypes

  ;

const
  TitleCnt = 7;
  Title : array [0..TitleCnt-1] of string = ('','계좌번호','계좌명','평가예탁금',
              '로스컷 평가예탁','여유 평가예탁','실행');

  ColWid: array [0..TitleCnt-1] of integer = (25, 90, 90, 110, 110, 110, 30 );

  CheckCol  = 0;
  AcntCol  = 1;
  SymbolCol = 2;
  ChangeCol = 3;
  ColorCol  = 3;
  EDT_COL  = 4;
  ExeCol = 6;

  CHKON = 100;
  CHKOFF = -100;
type
  TFrmRiskManage = class(TForm)
    plLeft: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    sgRisk: TStringGrid;
    btnAllExe: TButton;
    btnAllStop: TButton;
    btnConfig: TButton;
    cb1Sec: TCheckBox;
    cbRealTime: TCheckBox;
    cbAll: TCheckBox;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgRiskDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgRiskMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAllClick(Sender: TObject);
    procedure btnAllExeClick(Sender: TObject);
    procedure btnAllStopClick(Sender: TObject);
    procedure sgRiskDblClick(Sender: TObject);
  private
    { Private declarations }
    FUnRow  : integer;
    FUnCol  : integer;
    FType   : TDepositType;// = ( dtUSD, dtWON );
    procedure initControls;
    procedure DisplayAccount;
    procedure ExeCheckLossCut(bExe: boolean; iRow: integer);
  public
    { Public declarations }
    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

var
  FrmRiskManage: TFrmRiskManage;

implementation

uses
  GleConsts, GleLib, GAppEnv
  ;

{$R *.dfm}

procedure TFrmRiskManage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmRiskManage.FormDestroy(Sender: TObject);
begin
  //
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmRiskManage.FormCreate(Sender: TObject);
begin
  initControls;

  DisplayAccount;
end;

procedure TFrmRiskManage.initControls;
var
  I: Integer;
begin
  FUnRow := -1;
  FUnCol := -1;
  sgRisk.ColCount := TitleCnt;

  with sgRisk do
  for I := 0 to TitleCnt - 1 do
  begin
    ColWidths[i]  := ColWid[i];
    Cells[i,0]    := Title[i];
  end;

  FType := dtUSD ;
end;

procedure TFrmRiskManage.LoadEnv(aStorage: TStorage);
begin

end;

procedure TFrmRiskManage.SaveEnv(aStorage: TStorage);
begin

end;

procedure TFrmRiskManage.ExeCheckLossCut( bExe : boolean; iRow : integer );
var
  aInvest : TInvestor;
  stLog   : string;
begin

  aInvest := TInvestor( sgRisk.Objects[ AcntCol, iRow]);
  if ( aInvest = nil ) then Exit;

  // 실행할때만
  if bExe then
  begin
    if ( aInvest.PassWord = '' ) then Exit;
    if ( aInvest.LossCutAmt[FType] <= 0 ) then Exit;
    sgRisk.Objects[ExeCol, iRow] := Pointer(CHKON);
    gEnv.EnvLog( WIN_LOSS, Format( '%s(%s) 한도관리 실행 ( %0n, %0n)', [ aInvest.Code,
      ifThenStr( FType = dtUSD,'달러','원화'), aInvest.DepositOTE[FType], aInvest.LossCutAmt[FType] ]  ));
    //
  end else
  begin
    sgRisk.Objects[ExeCol, iRow] := Pointer(CHKOFF);
    gEnv.EnvLog( WIN_LOSS, Format( '%s(%s) 한도관리 해제 ( %0n, %0n)', [ aInvest.Code,
      ifThenStr( FType = dtUSD,'달러','원화'), aInvest.DepositOTE[FType], aInvest.LossCutAmt[FType] ]  ));
    //
  end;
end;

procedure TFrmRiskManage.btnAllExeClick(Sender: TObject);
var
  ival, I: Integer;
begin

  with sgRisk do
  begin
    for I := 1 to RowCount - 1 do
    begin
      ival  := integer( Objects[ExeCol, i]);
      if ival = CHKOFF then
        ExeCheckLossCut( true, i );
    end;
    Repaint;
  end;
end;

procedure TFrmRiskManage.btnAllStopClick(Sender: TObject);
begin
  //
end;

procedure TFrmRiskManage.cbAllClick(Sender: TObject);
var
  I: Integer;
begin

  with sgRisk do
  begin
    for I := 1 to RowCount - 1 do
    begin
      if Objects[ AcntCol, i ] <> nil then
        if ( Sender as TCheckBox).Checked then
          Objects[CheckCol, i] := Pointer(CHKON)
        else
          Objects[CheckCol, i] := Pointer(CHKOFF);
    end;
    Repaint;
  end;
end;

procedure TFrmRiskManage.DisplayAccount;
var
  iCol, iRow, I: Integer;
  aInvest : TInvestor;
  //aRect : TRect;
  //aEdt  : TEdit;
begin

  with sgRisk do
  begin
    RowCount  := gEnv.Engine.TradeCore.Investors.Count + 1;
    if RowCount > 1 then FixedRows := 1;
    iRow := 1;

    for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    begin
      iCol := 1;
      aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];

      Cells[ iCol, iRow+i]  := aInvest.Code;  inc( iCol );
      Cells[ iCol, iRow+i]  := aInvest.Name;  inc( iCol );

      Cells[ iCol, iRow+i]  := FormatFloat('#,##0', aInvest.DepositOTE[FType]  );
      inc( iCol );

      Cells[ iCol, iRow+i]  := FormatFloat('#,##0', aInvest.LossCutAmt[FType]  );
      inc( iCol );

      Cells[ iCol, iRow+i]  := FormatFloat('#,##0', aInvest.DepositOTE[FType] - aInvest.LossCutAmt[FType]   );
      Objects[ AcntCol, iRow+i] := aInvest;

    end;
  end;
end;

procedure TFrmRiskManage.sgRiskDblClick(Sender: TObject);
var
  stData : string;
  aInvest: TInvestor;
begin
  if ( FUnRow > 0 )  and ( FUnCol = EDT_COL ) then
  begin
    aInvest := TInvestor( sgRisk.Objects[ AcntCol, FUnRow] );
    if aInvest <> nil then begin
      stData  := Format( '%.0f', [aInvest.LossCutAmt[FType]] );
      if inPutQuery('로스컷 평가예탁금액 설정','', stData ) then
      begin
        aInvest.LossCutAmt[FType] := StrToFloatDef( stData, 0 );
        sgRisk.Cells[ EDT_COL, FUnRow]  := FormatFloat('#,##0', aInvest.LossCutAmt[FType]  );
      end;
    end;

  end;
end;

procedure TFrmRiskManage.sgRiskDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

var
  aGrid : TStringGrid;
  aBack, aFont : TColor;
  dFormat : Word;
  stTxt : string;
  aRect : TRect;
  //aPos : TPosition;

  procedure DrawCheck(DC:HDC;BBRect:TRect;bCheck:Boolean);
  begin
    if bCheck then
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK + DFCS_CHECKED)
    else
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK);
  end;

  procedure DrawButton(DC:HDC;BBRect:TRect;bDown:Boolean);
  var
    fRect : TRect;
  begin
    fRect := BBRect;
    fRect.Top := BBRect.Top + 4;
    fRect.Bottom := BBrect.Bottom - 1;
    if bDown then begin
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONPUSH + DFCS_PUSHED);
      DrawTextA( DC, '■', 2, fRect, DT_CENTER + DT_VCENTER );
    end
    else begin
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONPUSH);
      //DrawFocusRect( DC, BBRect );
      DrawTextA( DC, '▶', 2, fRect, DT_CENTER + DT_VCENTER );
    end;
  end;
begin

  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
      aBack := clBtnFace
    else begin

      case ACol of
        2 : aFont := TColor( Objects[ColorCol, ARow]);
        3 ,4, 5:
          begin
            dFormat := DT_RIGHT or DT_VCENTER;
            if ACol = EDT_COL then aBack := NODATA_COLOR;
          end;
      end;

      if ( ARow mod 2 ) = 0 then
        aBack := GRID_REVER_COLOR
      else
        aBack  := clWhite;

      if ARow = FUnRow then
        aBack := SELECTED_COLOR;

    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 4;
    aRect.Right := aRect.Right - 2;
    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;
    

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ARow = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end else
    begin
       if ACol = CheckCol then
       begin
          arect := Rect;
          arect.Top := Rect.Top + 2;
          arect.Bottom := Rect.Bottom - 2;
          DrawCheck(Canvas.Handle, arect, integer(Objects[CheckCol,ARow]) = CHKON );
       end else
       if ACol = ExeCol then
       begin
          DrawButton(Canvas.Handle, Rect, integer(Objects[ExeCol,ARow]) = CHKON );
       end;
    end;
  end;

end;

procedure TFrmRiskManage.sgRiskMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    iBack, iTmp, iTag : integer;
begin

  iBack := FUnRow;
  ( Sender as TStringGrid).MouseToCell( X, Y, FUnCol, FUnRow);

  if (FUnRow > 0) and ( FUnCol in [ CheckCol, ExeCol]) then
  begin
    if (FUnCol = CheckCol) then
      iTmp := integer(  ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow] )
    else if (FUnCol = ExeCol ) then
      iTmp := integer(  ( Sender as TStringGrid ).Objects[ ExeCol, FUnRow] ) ;

    if iTmp = CHKON then
      iTmp := CHKOFF
    else
      iTmp:= CHKON;

    ( Sender as TStringGrid ).Objects[ FUnCol, FUnRow] := Pointer(iTmp );
    //( Sender as TStringGrid ).Invalidate;
  end;

  ( Sender as TStringGrid ).Invalidate;


end;

end.

