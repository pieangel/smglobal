unit FFundDetailConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,

  CleAccounts, CleFunds, StdCtrls, ExtCtrls, AppEvnts,

  CleDistributor
  ;

const
  title : array [0..3] of string = ('주문','승수','계좌','계좌명' );
  CheckCol = 0;
  FontCol  = 2;
  CHKON = 100;
  CHKOFF = -100;

type
  TFrmFund = class(TForm)
    sgFund: TStringGrid;
    plFund: TPanel;
    ComboBoAccount: TComboBox;
    ApplicationEvents1: TApplicationEvents;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgFundDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgFundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure ComboBoAccountChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FFund: TFund;
    FUnRow : integer;
    procedure initControls;
    procedure SetFund(const Value: TFund);
    procedure ClearGrid;
    procedure UpdateFund;
    procedure UpdateData(aItem: TFundItem; iRow :Integer);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    { Private declarations }
  public
    { Public declarations }
    procedure TradeProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure WMNCLButtonDown( var Message : TMessage) ; message WM_NCLBUTTONDOWN;
    property Fund  : TFund read FFund write SetFund;
  end;

var
  FrmFund: TFrmFund;

implementation

uses
  GleConsts, GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFrmFund.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmFund.FormCreate(Sender: TObject);
begin
  //
  initControls;

  FFund := nil;
  FUnRow:= -1;

  gEnv.Engine.TradeCore.Funds.GetList( ComboBoAccount.Items);

  if ComboBoAccount.Items.Count > 0 then
  begin
    ComboBoAccount.ItemIndex  := 0;
    ComboBoAccountChange( nil )
  end;

  ApplicationEvents1.OnIdle :=  ApplicationEvents1Idle;

  gEnv.Engine.TradeBroker.Subscribe( Self, FUND_DATA, TradeProc );
end;

procedure TFrmFund.FormDestroy(Sender: TObject);
begin
  //
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmFund.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  // 도킹일때는 버튼 보이게 아니면 안보이게..
  plFund.Visible  := Floating;
end;

procedure TFrmFund.FormResize(Sender: TObject);
var
  iGap, iWid : integer;
begin
  iWid := sgFund.Width;

  with sgFund do
  begin
    ColWidths[0]  := Round(iWid * 0.15);
    ColWidths[1]  := Round(iWid * 0.2);
    ColWidths[2]  := iWid - ColWidths[0] - ColWidths[1] - 4;
    ColWidths[3]  := ColWidths[2];
  end;

  {
  iGap := sgFund.Height div sgFund.DefaultRowHeight;
  if iGap < sgFund.RowCount then
    sgFund.ColWidths[3] := sgFund.ColWidths[3] - 19
  else
    sgFund.ColWidths[3] := sgFund.ColWidths[3];
  }
  if (sgFund.RowCount >= 2) and ( sgFund.FixedRows < 1 ) then begin
    sgFund.FixedRows := 1;
    sgFund.FixedCols := 2;
  end;
end;

procedure TFrmFund.initControls;
var
  I: Integer;
begin
  for I := 0 to 4 - 1 do
    sgFund.Cells[i,0] := Title[i];
end;

procedure TFrmFund.SetFund(const Value: TFund);
begin
  SetComboIndex( ComboBoAccount, Value ) ;
  ComboBoAccountChange( nil );
  FormResize( nil );
end;

procedure TFrmFund.sgFundDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aItem : TFundItem;


  procedure DrawCheck(DC:HDC;BBRect:TRect;bCheck:Boolean);
  begin
    if bCheck then
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK + DFCS_CHECKED)
    else
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK);
  end;

begin

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;

  with sgFund do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
      aBack := clBtnFace
    else begin

      case ACol of
        1 : dFormat := DT_RIGHT or DT_VCENTER;
      end;

      if ( ARow mod 2 ) = 0 then
        aBack := GRID_REVER_COLOR
      else
        aBack  := clWhite;

      if gdSelected in State then
        aBack := GRID_SELECT_COLOR;

      aItem := TFundItem( Objects[1, ARow] );
      if (aItem <> nil) and ( not aItem.Enable) then
      begin
        aFont := clsilver;
        Canvas.Font.Style := Canvas.Font.Style + [ fsStrikeOut ] ;
        //fsUnderline, fsStrikeOut)
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
    {
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
                       }
    end
    else if (ARow > 0) and ( ACol = CheckCol ) then
    begin
      arect := Rect;
      arect.Top := Rect.Top + 2;
      arect.Bottom := Rect.Bottom - 2;
      DrawCheck(Canvas.Handle, arect, integer(Objects[CheckCol,ARow]) = CHKON );
    end;    

    Canvas.Font.Style := Canvas.Font.Style - [ fsStrikeOut ] ;
  end;
end;

procedure TFrmFund.sgFundMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    iTmp, ACol, iTag : integer;
    aItem : TFundItem;
begin

  iTag := ( Sender as TStringGrid ).Tag;
  ( Sender as TStringGrid).MouseToCell( X, Y, ACol, FUnRow);

  if (FUnRow > 0) and (ACol = CheckCol) then   //0번째 열
  begin

    iTmp := integer(  ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow] ) ;
    aItem := TFundItem(( Sender as TStringGrid ).Objects[1, FUnRow]);

    if aItem = nil then Exit;

    if iTmp = CHKON then
      iTmp := CHKOFF
    else
      iTmp:= CHKON;

    aITem.Enable  := not aItem.Enable;

    ( Sender as TStringGrid ).Objects[ CheckCol, FUnRow] := Pointer(iTmp );
    ( Sender as TStringGrid ).Invalidate;

    gEnv.EnvLog( WIN_TEST, Format('%s Fund %s 설정변경 -> %s', [FFund.Name, aItem.Account.Code,
      ifThenStr( aITem.Enable, '주문 On', '주문 off')] )  );    
  end;

end;

procedure TFrmFund.Timer1Timer(Sender: TObject);
begin
  UpdateFund;
end;

procedure TFrmFund.TradeProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  idx, iID: Integer;
begin
  if DataObj = nil then Exit;

  if (Receiver = Self) then
    case DataID  of
      FUND_DATA :
        case Integer(EventID) of
          FUND_NEW :
              ComboBoAccount.Items.AddObject( ( DataObj as TFund).Name, DataObj );
          FUND_DELETED :
            begin
              idx := ComboBoAccount.Items.IndexOfObject( DataObj );
              if idx >= 0 then
                ComboBoAccount.Items.Delete( idx);

              if FFund = DataObj then begin
                FFund := nil;
                UpdateFund;
              end;

            end;
          FUND_UPDATED,
          FUND_ACNT_UPDATE :
              if DataObj = FFund then
                UpdateFund;
        end;
    end;
end;

procedure TFrmFund.UpdateFund;
var
  I: Integer;
begin
  ClearGrid;

  if FFund = nil then Exit;

  Caption := FFund.Name;

  sgFund.RowCount := FFund.FundItems.Count + 1;

  for I := 0 to FFund.FundItems.Count - 1 do
    UpdateData( FFund.FundItems.FundItem[i], i+1 );

end;

procedure TFrmFund.WMNCLButtonDown(var Message: TMessage);
begin
  inherited;
end;

procedure TFrmFund.UpdateData( aItem : TFundItem; iRow :Integer );
begin
  with sgFund do
  begin
    //InsertLine( sgFund, 1 );
    Objects[1, iRow]  := aItem;
    if aItem.Enable then
      Objects[CheckCol, iRow]  := Pointer( CHKON )
    else
      Objects[CheckCol, iRow]  := Pointer( CHKOFF );

    Cells[1, iRow] := IntToStr( aITem.Multiple );
    Cells[2, iRow] := aItem.Account.Code;
    Cells[3, iRow] := aItem.Account.Name;
  end;
end;


procedure TFrmFund.ClearGrid;
var
  I: Integer;
begin
  Caption := ' ';
  for I := 1 to sgFund.RowCount - 1 do
    sgFund.Rows[i].Clear;
  sgFund.RowCount := 1;
end;

procedure TFrmFund.ComboBoAccountChange(Sender: TObject);
var
  aFund    : TFund;
begin
  aFund  := GetComboObject( ComboBoAccount ) as TFund;
  if aFund = nil then Exit;

  if FFund <> aFund then
  begin
    FFund := aFund;
    UpdateFund;
  end;

end;

end.
