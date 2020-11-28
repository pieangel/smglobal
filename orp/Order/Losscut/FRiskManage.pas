unit FRiskManage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls,

  CleORders, CleAccounts, CleSymbols, ClePositions, CleQuoteBroker,

  {CleDistributor,} CleStorage,

  GleTypes, Buttons, Menus

{$INCLUDE define.txt}
  ;

const
  TitleCnt = 9;
  TitleCnt2 = 3;
  TitleCnt3 = 3;

  Title : array [0..TitleCnt-1] of string = ('','계좌번호','계좌명','평가예탁금',
              '로스컷 평가예탁','여유 평가예탁','실행','상태','조회수');

  Title2: array [0..TitleCnt2-1] of string = ('종목','수량','평가');
  Title3: array [0..TitleCnt3-1] of string = ('종목','수량','가격');

  ColWid:  array [0..TitleCnt-1]  of integer = (25, 90, 90, 110, 110, 100, 30, 40, 50 );
  ColWid2: array [0..TitleCnt2-1] of integer = (50, 30, 90 );
  ColWid3: array [0..TitleCnt3-1] of integer = (50, 30, 90 );

  CheckCol = 0;
  AcntCol  = 1;
  RiskCol  = 2;
  SymbolCol= 0;
  ChangeCol= 5;
  ColorCol = 1;
  EDT_COL  = 4;
  ExeCol   = 6;

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
    cbAll: TCheckBox;
    Timer1: TTimer;
    cbDepType: TComboBox;
    Button1: TButton;
    Label1: TLabel;
    sgPos: TStringGrid;
    sgUnFill: TStringGrid;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    cbMarketLiq: TCheckBox;
    cbNewOrdCnl: TCheckBox;
    cbNewPosLiq: TCheckBox;
    SpeedButtonRightPanel: TSpeedButton;
    Label4: TLabel;
    cbInterval: TComboBox;
    Panel1: TPanel;
    sgLog: TStringGrid;
    tReq: TTimer;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    SpeedButton1: TSpeedButton;
    cbPosQueryPer: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgRiskDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgRiskMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAllClick(Sender: TObject);
    procedure btnAllExeClick(Sender: TObject);
    procedure sgRiskDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbDepTypeChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure sgPosDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure SpeedButtonRightPanelClick(Sender: TObject);
    procedure cbMarketLiqClick(Sender: TObject);
    procedure edtIntervalKeyPress(Sender: TObject; var Key: Char);
    procedure cbIntervalChange(Sender: TObject);
    procedure tReqTimer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cbPosQueryPerChange(Sender: TObject);
  private
    { Private declarations }
    FUnRow  : integer;
    FUnCol  : integer;
    FType   : TDepositType;// = ( dtUSD, dtWON );
    FStorage: TStorage;
    FInvest : TInvestor;
    FFormat : string;
    procedure initControls;
    procedure DisplayAccount;
    procedure UpdateData;
    function ExeCheckLossCut(bExe: boolean; iRow: integer) : boolean;
    procedure UpdateSubData;
    procedure UpdateRow(iRow: Integer; aPos: TPosition; bAdd: boolean); overload;
    procedure UpdateRow( iRow : Integer; aOrder : TOrder ); overload;
    procedure ClearGrid;
    procedure DoLog( stLog : string );
  public
    { Public declarations }
    SaveH : integer;
    procedure SaveEnv;
    procedure LoadEnv;
    procedure OnRiskResultNotify( Sender: TObject; Value: String ) ;
  end;

var
  FrmRiskManage: TFrmRiskManage;

implementation

uses
  GleConsts, GleLib, GAppEnv ,
  CleRiskManager
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

  gEnv.Engine.RMS.OnResult := nil;
  gEnv.Engine.RMS.Clear;

  SaveEnv;
  FStorage.Free;
end;

procedure TFrmRiskManage.FormCreate(Sender: TObject);
begin
  initControls;

  FStorage  := TStorage.Create;
  LoadEnv;

  gEnv.Engine.RMS.OnResult  := OnRiskResultNotify;

  DisplayAccount;

  cbIntervalChange( cbInterval );
  cbDepTypeChange( cbDepType );
  cbPosQueryPerChange( cbPosQueryPer );

  gEnv.Engine.RMS.MarketLiq := cbMarketLiq.Checked;
  gEnv.Engine.RMS.NewOrdCnl := cbNewOrdCnl.Checked;
  gEnv.Engine.RMS.NewPosLiq := cbNewPosLiq.Checked;
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

  for I := 0 to TitleCnt2 - 1 do
  begin
    sgPos.ColWidths[i]  := ColWid2[i];
    sgUnFill.ColWidths[i] := ColWid3[i];

    sgPos.Cells[i,0]  := Title2[i];
    sgUnfill.Cells[i,0] := Title3[i];
  end;

  sgLog.Cells[0,0] := '시각';
  sgLog.Cells[1,0] := '로그내용';

end;

procedure TFrmRiskManage.LoadEnv;
var
  i, iCount : integer;
  aInvest : TInvestor;
begin
  if not FStorage.Load( ComposeFilePath([gEnv.DataDir,
    Format('%s_%s_account.lsg', [gEnv.ConConfig.UserID,
          ifThenStr(gEnv.ConConfig.RealMode, 'Real','Mock') ])]))  then
    Exit;

  FStorage.First;

  cbDepType.ItemIndex := FStorage.FieldByName('DepType').AsIntegerDef( 0 );
  cbInterval.ItemIndex:= FStorage.FieldByName('Interval').AsIntegerDef(2);
  cbPosQueryPer.ItemIndex := FStorage.FieldByName('QueryPer').AsIntegerDef(2);
  iCount              := FStorage.FieldByName('Count').AsIntegerDef(0);

  if iCount <= 0 then Exit;

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count-1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    if aInvest <> nil then begin
      aInvest.LossCutAmt[ dtUSD ] := FStorage.FieldByName(aInvest.Code+'_0').AsFloat;
      aInvest.LossCutAmt[ dtWON ] := FStorage.FieldByName(aInvest.Code+'_1').AsFloat;
    end;
  end;

  cbMarketLiq.Checked := FStorage.FieldByName('MarketLiq').AsBooleanDef( true );
  cbNewOrdCnl.Checked := FStorage.FieldByName('NewOrdCnl').AsBooleanDef( true );
  cbNewPosLiq.Checked := FStorage.FieldByName('NewPosLiq').AsBooleanDef( true );
end;

procedure TFrmRiskManage.N1Click(Sender: TObject);
var
  aInvest : TInvestor;
begin
  if FUnRow < 1 then Exit;

  aInvest := TInvestor( sgRisk.Objects[ AcntCol, FUnRow]);
  if aInvest <> nil then
  begin
    aInvest.BCutOff := false;
  end;
end;

procedure TFrmRiskManage.OnRiskResultNotify(Sender: TObject; Value: String);
begin
  //
  if Sender = nil then Exit;

  DoLog(  Format('%s:%s', [ ( Sender as TRiskManageItem).Invest.Code, Value ]));
end;

procedure TFrmRiskManage.SaveEnv;
var
  I: Integer;
  aInvest : TInvestor;
begin

  FStorage.Clear;
  FStorage.New;

  FStorage.FieldByName('DepType').AsInteger := integer( FType );
  FStorage.FieldByName('Count').AsInteger   := sgRisk.RowCount-1;
  FStorage.FieldByName('Interval').AsInteger := cbInterval.ItemIndex;
  FStorage.FieldByName('QueryPer').AsInteger := cbPosQueryPer.ItemIndex;

  with sgRisk do
  for I := 1 to sgRisk.RowCount - 1 do
  begin
    aInvest := TInvestor( Objects[ ACntCol, i ]);
    if aInvest <> nil then begin
      FStorage.FieldByName(aInvest.Code+'_0').AsFloat := aInvest.LossCutAmt[ dtUSD ];
      FStorage.FieldByName(aInvest.Code+'_1').AsFloat := aInvest.LossCutAmt[ dtWON ];
    end;
  end;

  FStorage.FieldByName('MarketLiq').AsBoolean :=  cbMarketLiq.Checked;
  FStorage.FieldByName('NewOrdCnl').AsBoolean :=  cbNewOrdCnl.Checked;
  FStorage.FieldByName('NewPosLiq').AsBoolean :=  cbNewPosLiq.Checked;

  FStorage.Save( ComposeFilePath([gEnv.DataDir,
      Format('%s_%s_account.lsg', [gEnv.ConConfig.UserID,
          ifThenStr(gEnv.ConConfig.RealMode, 'Real','Mock') ])]))  ;
end;

function TFrmRiskManage.ExeCheckLossCut( bExe : boolean; iRow : integer ) : boolean;
var
  aInvest : TInvestor;
  stLog   : string;
  aItem   : TRiskManageItem;
begin
  Result := false;

  aInvest := TInvestor( sgRisk.Objects[ AcntCol, iRow]);
  if ( aInvest = nil ) then Exit;

  aItem := TRiskManageItem( sgRisk.Objects[ RiskCol, iRow] );
  // 실행할때만
  if bExe then
  begin
    if ( aInvest.PassWord = '' ) or ( aInvest.LossCutAmt[FType] <= 0 ) then
    begin
      DoLog( Format( '%s(%s) 계좌비번 or 로스컷금액은 0 보다 커야 함 ', [ aInvest.Code,ifThenStr( FType = dtUSD,'달러','원화') ]));
      Exit;
    end;

    sgRisk.Objects[ExeCol, iRow] := Pointer(CHKON);
    DoLog( Format( '%s(%s) 한도관리 실행 ( %0n, %0n)', [ aInvest.Code,
      ifThenStr( FType = dtUSD,'달러','원화'), aInvest.DepositOTE[FType], aInvest.LossCutAmt[FType] ]  ));
    if aItem = nil then
      aItem := gEnv.Engine.RMS.New( aInvest );
    aItem.Start;
    //
  end else
  begin
    sgRisk.Objects[ExeCol, iRow] := Pointer(CHKOFF);
    DoLog( Format( '%s(%s) 한도관리 해제 ( %0n, %0n)', [ aInvest.Code,
      ifThenStr( FType = dtUSD,'달러','원화'), aInvest.DepositOTE[FType], aInvest.LossCutAmt[FType] ]  ));
    if aItem = nil then
      aItem := gEnv.Engine.RMS.New( aInvest );
    aItem.Stop;
  end;

  Result := true;
end;

// 전체 실행/ 해제
procedure TFrmRiskManage.btnAllExeClick(Sender: TObject);
var
  iTag, I: Integer;
  bExe    : boolean;
begin

  iTag := (Sender as TComponent).Tag;

  case iTag of
    0 : begin cbAll.Checked := true; bExe := true; end;
    1 : begin cbAll.Checked := false;bExe := false; end;
  end;

  with sgRisk do
    for I := 1 to sgRisk.RowCount - 1 do
      ExeCheckLossCut( bExe, i );
end;

// 선택실행
procedure TFrmRiskManage.Button1Click(Sender: TObject);
var
  ival, I: integer;
begin
  with sgRisk do
    for I := 0 to sgRisk.RowCount - 1 do
    begin
      iVal  := integer( Objects[CheckCol, i]);
      if iVal = CHKON then
        ExeCheckLossCut( true, i );
    end;
end;

procedure TFrmRiskManage.cbAllClick(Sender: TObject);
var
  I: Integer;
begin

  with sgRisk do
  begin
    for I := 1 to sgRisk.RowCount - 1 do
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

procedure TFrmRiskManage.cbDepTypeChange(Sender: TObject);
begin
  if cbDepType.ItemIndex < 0 then
     cbDepType.ItemIndex := 0;

  FType := TDepositType( cbDepType.ItemIndex );
  gEnv.Engine.RMS.DepType := FType;

  case FType of
    dtUSD: FFormat := '#,##0.###' ;
    dtWON: FFormat := '#,##0' ;
  end;

  UpdateData;
end;

procedure TFrmRiskManage.cbIntervalChange(Sender: TObject);
var
  iVal : integer;
begin
  case cbInterval.ItemIndex of
    0 : iVal := 1000;
    1 : iVal := 3000;
    2 : iVal := 5000;
    3 : iVal := 10000;
    4 : iVal := 15000;
    5 : iVal := 30000;
  end;
  tReq.Interval := iVal;
end;

procedure TFrmRiskManage.cbMarketLiqClick(Sender: TObject);
var
  bCheck : boolean;
begin
  //
  bCheck := ( Sender as TCheckBox ).Checked;
  case ( Sender as TCheckBox ).Tag of
    0 : gEnv.Engine.RMS.MarketLiq := bCheck ;
    1 : gEnv.Engine.RMS.NewOrdCnl := bCheck ;
    2 : gEnv.Engine.RMS.NewPosLiq := bCheck ;
  end;

end;

procedure TFrmRiskManage.cbPosQueryPerChange(Sender: TObject);
var
  iVal : integer;
begin
  case cbPosQueryPer.ItemIndex of
    0 : iVal := 50;
    1 : iVal := 60;
    2 : iVal := 70;
    3 : iVal := 80;
    4 : iVal := 90;
    else Exit;
  end;
  gEnv.Engine.RMS.PosQueryPer := iVal;
end;

procedure TFrmRiskManage.DisplayAccount;
var
  iCol, iRow, I: Integer;
  aInvest : TInvestor;
  aItem   : TRiskManageItem;
begin

  sgRisk.RowCount  := gEnv.Engine.TradeCore.Investors.Count + 1;

  with sgRisk do
  begin
    if (sgRisk.RowCount > 1) and ( FixedRows <= 0 ) then FixedRows := 1;
    iRow := 1;

    for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    begin
      iCol := 1;
      aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
      if aInvest <> nil then
      begin
        if (i = 0) then begin FInvest := aInvest; FUnRow := iRow+i; end;

        Cells[ iCol, iRow+i]  := aInvest.Code;  inc( iCol );
        Cells[ iCol, iRow+i]  := aInvest.Name;  inc( iCol );

        Cells[ iCol, iRow+i]  := FormatFloat( FFormat, aInvest.DepositOTE[FType]  );
        inc( iCol );

        Cells[ iCol, iRow+i]  := FormatFloat( FFormat, aInvest.LossCutAmt[FType]  );
        inc( iCol );

        Cells[ iCol, iRow+i]  := FormatFloat( FFormat, aInvest.DepositOTE[FType] - aInvest.LossCutAmt[FType]   );
        Objects[ AcntCol, iRow+i] := aInvest;
        aItem := gEnv.Engine.RMS.New( aInvest );
        OBjects[RiskCol, iRow+i]  := aItem;

      end;
    end;
  end;
end;     

procedure TFrmRiskManage.DoLog(stLog: string);
begin
  insertLine( sgLog, 1 );
  sgLog.Cells[0,1] := FormatDateTime( 'hh:nn:ss.zzz', Time );
  sgLog.Cells[1,1] := stLog;

  gEnv.EnvLog( WIN_RISK, stLog );
end;

procedure TFrmRiskManage.edtIntervalKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
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
        sgRisk.Cells[ EDT_COL, FUnRow]  := FormatFloat(FFormat, aInvest.LossCutAmt[FType]  );
        UpdateData;
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
        //2 : aFont := TColor( Objects[ColorCol, ARow]);
        3 ,4, 5, TitleCnt-1:
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

      if ACol = ExeCol then
        aBack  := clBtnFace;

      if ACol = EDT_COL then
        aBack := SHORT_COLOR;

      if ACol = TitleCnt-2 then
        if stTxt <> '' then begin
          aBack := clBlue;
          aFont := clWhite;
        end
        else begin
          aFont := clBlack;
          if ( ARow mod 2 ) = 0 then
            aBack := GRID_REVER_COLOR
          else
            aBack  := clWhite;
        end;
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
    aInvest : TInvestor;
begin

  iBack := FUnRow;
  ( Sender as TStringGrid).MouseToCell( X, Y, FUnCol, FUnRow);

  if (FUnRow > 0) and ( FUnCol in [ CheckCol, ExeCol]) then
  begin
    if (FUnCol = CheckCol) then begin
      if integer(  ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow] ) = CHKON then
        iTmp := ChKOFF
      else
        iTmp := CHKON;
    end
    else if (FUnCol = ExeCol ) then begin
      if integer(  ( Sender as TStringGrid ).Objects[ ExeCol, FUnRow] ) = CHKON then begin
        if ExeCheckLossCut( false, FUnRow ) then
          iTmp := CHKOFF
        else
          iTmp := CHKON;
      end
      else begin
        if ExeCheckLossCut( true, FUnRow ) then
          iTmp := CHKON
        else
          iTmp := CHKOFF;
      end;
    end;
    ( Sender as TStringGrid ).Objects[ FUnCol, FUnRow] := Pointer(iTmp );
  end;

  ( Sender as TStringGrid ).Invalidate;

  if ( FUnRow > 0 )  then
    if sgRisk.Objects[ AcntCol, FUnRow] <> nil then begin
      aInvest := TInvestor( sgRisk.Objects[ AcntCol, FUnRow ]);
      if aInvest <> FInvest then
        ClearGrid;
      FInvest := aInvest;
      UpdateSubData;
    end;

end;

procedure TFrmRiskManage.SpeedButton1Click(Sender: TObject);
begin
  if SpeedButton1.Down then begin
    //Panel1.Visible := true;
    Panel1.Height := SaveH;
    Height := Height + Panel1.Height -1;
  end
  else begin
    Height:= Height - Panel1.Height;
    SaveH := Panel1.Height;
    Panel1.Height := 1;
    //Panel1.Visible := false;
  end;
end;

procedure TFrmRiskManage.SpeedButtonRightPanelClick(Sender: TObject);
begin
  if SpeedButtonRightPanel.Down then begin
    Panel4.Visible := true;
    Height := Height + Panel4.Height;
  end
  else begin
    Height:= Height - Panel4.Height;
    Panel4.Visible := false;
  end;
end;

procedure TFrmRiskManage.Timer1Timer(Sender: TObject);
begin
  UpdateData;
  UpdateSubData;
end;

procedure TFrmRiskManage.tReqTimer(Sender: TObject);
begin
  gEnv.Engine.RMS.OnTimer( Sender );
end;

procedure TFrmRiskManage.UpdateData;
var
  iCol, iGap, iRow, I: Integer;
  aInvest : TInvestor;
  dVal  : double;
  aItem : TRiskManageItem;
begin

  iRow := 1;

  with sgRisk do
  begin
    for I := 1 to sgRisk.RowCount - 1 do
    begin
      iCol := 3;
      aInvest := TInvestor( Objects[ AcntCol, iRow] );
      aItem   := TRiskManageItem( Objects[ RiskCol, iRow]);
      dVal    := aItem.DepositeOTE;

      Cells[ iCol, iRow]  := FormatFloat(FFormat, dVal  );
      inc( iCol );
      Cells[ iCol, iRow]  := FormatFloat(FFormat, aInvest.LossCutAmt[FType]  );
      inc( iCol );
      Cells[ iCol, iRow]  := FormatFloat(FFormat, dVal - aInvest.LossCutAmt[FType]   );
      inc( iCol );
      inc( iCol);
      Cells[ iCol, iRow]  := ifThenStr( aInvest.BCutOff , '한도','');
      inc( iCol );
      Cells[ iCol, iRow]:= Format('%d',
            [ aItem.QueryCnt[0] +  aItem.QueryCnt[1] + aItem.QueryCnt[2] ] );

      inc( iRow );
    end;
  end;

  iGap := sgRisk.Height div sgRisk.DefaultRowHeight;

  if iGap < sgRisk.RowCount then
    sgRisk.ColWidths[ChangeCol] := ColWid[ChangeCol] - 19
  else
    sgRisk.ColWidths[ChangeCol] := ColWid[ChangeCol];
end;

procedure TFrmRiskManage.ClearGrid;
var
  I: Integer;
begin
  for I := 1 to sgPos.RowCount - 1 do
    sgPos.Rows[i].Clear;
  sgPos.RowCount := 2;

  for I := 1 to sgUnfill.RowCount - 1 do
    sgUnFill.Rows[i].Clear;
  sgUnFill.RowCount := 2;
end;

procedure TFrmRiskManage.UpdateSubData;
var
  iRow, i, iGap : integer;
  aPos : TPosition;
  aOrder: TOrder;
begin
  //
  if FInvest = nil then Exit;

  for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
  begin
    aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];

    if aPos.Account.InvestCode = FInvest.Code then
    begin
      iRow  := sgPos.Cols[SymbolCol].IndexOfObject( aPos );
      if iRow < 0 then begin
        if (aPos.Volume = 0)  then
          Continue;
        iRow := 1;//InsertRow( aPos.Symbol );
        InsertLine( sgPos, iRow );
      end else
      begin
        if (aPos.Volume = 0) then begin
          DeleteLine( sgPos, iRow );
          Continue;
        end;
      end;
      UpdateRow( iRow, aPos, true );
    end;
  end;

  iGap := sgPos.Height div sgPos.DefaultRowHeight;

  if iGap < sgPos.RowCount then
    sgPos.ColWidths[2] := ColWid[2] - 19
  else
    sgPos.ColWidths[2] := ColWid[2];

  // active 아닌것들은 지우고..
  for I := sgUnfill.RowCount - 1 downto 1 do
  begin
    aOrder  := TOrder( sgUnFill.Objects[ SymbolCol, i ]);
    if aOrder <> nil then
      if ( aOrder.Account.InvestCode <> FInvest.Code ) or ( aOrder.State <> osActive ) then
        DeleteLine( sgUnfill, i );
  end;

  for I := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder  := gEnv.Engine.TradeCore.Orders.ActiveOrders.Orders[i];

    if ( aOrder <> nil ) and ( aOrder.Account.InvestCode = FInvest.Code ) then
    begin
      iRow := sgUnFill.Cols[SymbolCol].IndexOfObject( aOrder);
      if iRow < 0 then begin
        iRow := 1;
        InsertLine( sgUnfill, iRow );
      end;
      UpdateRow( iRow, aOrder );
    end;
  end;

  iGap := sgUnFill.Height div sgUnFill.DefaultRowHeight;

  if iGap < sgUnFill.RowCount then
    sgUnFill.ColWidths[2] := ColWid[2] - 19
  else
    sgUnFill.ColWidths[2] := ColWid[2];
end;

procedure TFrmRiskManage.UpdateRow( iRow : Integer; aPos : TPosition; bAdd : boolean );
var
  iVol : integer;
  dPrice : double;
begin
  with sgPos do
  begin
    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ SymbolCol, iRow ] := aPos;

    Cells[0, iRow] := aPos.Symbol.ShortCode;
    Cells[1, iRow] := IntToStr( iVol );

    if iVol = 0 then
      Objects[ ColorCol, iRow] := Pointer( clBlack )
    else if aPos.Volume > 0 then
      Objects[ ColorCol, iRow] := Pointer( clRed )
    else
      Objects[ ColorCol, iRow] := Pointer( clBlue );

    Cells[2, iRow] := Formatfloat(FFormat, aPos.EntryOTE);
  end;
end;
procedure TFrmRiskManage.UpdateRow( iRow : Integer; aOrder : TOrder );
var
  iVol : integer;
  dPrice : double;
begin
  with sgUnFill do
  begin

    Objects[ SymbolCol, iRow ] := aOrder;

    Cells[0, iRow] := aOrder.Symbol.ShortCode;
    Cells[1, iRow] := IntToStr( aOrder.ActiveQty );

    if aOrder.Side = 0 then
      Objects[ ColorCol, iRow] := Pointer( clBlack )
    else if aOrder.Side > 0 then
      Objects[ ColorCol, iRow] := Pointer( clRed )
    else
      Objects[ ColorCol, iRow] := Pointer( clBlue );

    Cells[2, iRow] := aOrder.Symbol.PriceToStr( aOrder.Price );
  end;
end;

procedure TFrmRiskManage.sgPosDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with ( Sender as TStringGrid ) do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      if ACol <> 0 then
        wFmt  := DT_RIGHT or DT_VCENTER;

      if ACol = ColorCol then
        ftClr := TColor( integer( Objects[ColorCol, ARow] ));

      if (( Sender as TStringGrid ).Tag = 0 ) and ( Objects[SymbolCol, ARow] <> nil ) and ( ACol = 2)  then
        with TPosition( Objects[SymbolCol, ARow] ) do
        begin
          if EntryOTE > 0 then ftClr := clRed
          else if EntryOTE < 0 then ftClr := clBlue;
        end;

      if ( ARow mod 2 ) = 0 then
        bgClr := $00EEEEEE;

      if ARow = RowCount-1 then
        bgClr := clWhite;
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;

end;

end.

