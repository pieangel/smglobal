unit DleInterestConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, Grids, ComCtrls,

  CleSymbols, CBoardEnv, COBTypes, CleMarkets, StdCtrls, ExtCtrls;


const
  Title_Cnt = 3;
  Titles  : array [0..Title_Cnt-1] of string = ('거래소','종목명','코드');
  Mk_Col  = 1;

{$INCLUDE define.txt}

type
  TFrmInterestConfig = class(TForm)
    SymbolTab: TTabControl;
    sgSymbol: TStringGrid;
    ButtonUpper: TSpeedButton;
    ButtonLower: TSpeedButton;
    sgSymbol2: TStringGrid;
    ButtonToLeft: TSpeedButton;
    ButtonToRight: TSpeedButton;
    Label5: TLabel;
    Label6: TLabel;
    ButtonCancel: TButton;
    ButtonConfirm: TButton;
    Label1: TLabel;
    RadioGroupMonth: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    procedure sgSymbol2DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure SymbolTabChange(Sender: TObject);
    procedure sgSymbolDblClick(Sender: TObject);
    procedure sgSymbolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonToRightClick(Sender: TObject);
    procedure ButtonConfirmClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure sgSymbol2DblClick(Sender: TObject);
    procedure ButtonToLeftClick(Sender: TObject);
    procedure ButtonUpperClick(Sender: TObject);
    procedure ButtonLowerClick(Sender: TObject);
    procedure sgSymbol2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FSelectRow: array [0..1] of integer;
    FCol  : integer;
    FLastGap  : integer;
    FDefWidth,  FTabGap : integer;
    procedure ReSizeGrid;
    function  GetIndex : integer;
    procedure UpdateGridData(aGrid : TStringGrid;iRow: integer; aFutMarket: TFutureMarket; stAlias : string; bLeft : boolean = false);
  public
    { Public declarations }
    function Open : Boolean;
  end;

var
  FrmInterestConfig: TFrmInterestConfig;

implementation

uses
  GAppEnv,  GleLib , CleFQN

  ;

{$R *.dfm}

procedure TFrmInterestConfig.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmInterestConfig.ButtonConfirmClick(Sender: TObject);
var
  I: Integer;
  af,aFutmarket : TFutureMarket;
begin

  gEnv.Engine.SymbolCore.FavorFutMarkets.Clear;
  gEnv.Engine.SymbolCore.FavorFutType := RadioGroupMonth.ItemIndex;

  for I := 1 to sgSymbol2.RowCount - 1 do
  begin
    aFutMarket  := TFutureMarket( sgSymbol2.Objects[ Mk_Col, i]);
    if aFutMarket <> nil then
      gEnv.Engine.SymbolCore.FavorFutMarkets.AddObject( sgSymbol2.Cells[2, i] ,  aFutMarket );
  end;

  ModalResult := mrOk;
end;

procedure TFrmInterestConfig.ButtonUpperClick(Sender: TObject);
var
  ito : integer;
begin
  if FSelectRow[1] <= 1 then Exit;
  if sgSymbol2.Objects[ Mk_Col, FSelectRow[1]] = nil then Exit;

  ito := FSelectRow[1] - 1;

  MoveRow( sgSymbol2, FSelectRow[1], iTo );
  FSelectRow[1] := iTo;

  sgSymbol2.Repaint;

end;

procedure TFrmInterestConfig.ButtonLowerClick(Sender: TObject);
var
  ito : integer;
begin
  if FSelectRow[1] >= sgSymbol2.RowCount-1 then Exit;

  ito := FSelectRow[1] + 1;
  if ito > GetIndex then Exit;

  MoveRow( sgSymbol2, FSelectRow[1], iTo );
  FSelectRow[1] := iTo;

  sgSymbol2.Repaint;

end;

procedure TFrmInterestConfig.ButtonToLeftClick(Sender: TObject);
var
  I: Integer;
  aFutMarket: TFutureMarket;   //
begin
  if FCol = 2 then Exit;  
  if FSelectRow[1] < 1 then Exit;
  sgSymbol2.Rows[ FSelectRow[1] ].Clear;

  for I := FSelectRow[1]+1 to sgSymbol2.RowCount - 1 do
    MoveRow( sgSymbol2, i, i-1 );   
end;

procedure TFrmInterestConfig.ButtonToRightClick(Sender: TObject);
var
  iRow : integer;
  aFutMarket: TFutureMarket;   //
begin
  if FSelectRow[0] < 1 then Exit;
  aFutMarket  := TFutureMarket( sgSymbol.Objects[ Mk_Col, FSelectRow[0] ] );
  if aFutMarket <> nil then
    UpdateGridData( sgSymbol2, GetIndex, aFutMarket, '' );
end;



procedure TFrmInterestConfig.FormCreate(Sender: TObject);
var
  i   : integer;
  aMG : TMarketGroup;
  aFutMarket: TFutureMarket;   //
begin

  FSelectRow[0] := -1;
  FSelectRow[1] := -1;
  FDefWidth := sgSymbol.ColWidths[1];
  FCol          := -1;

  for I := 0 to Title_Cnt - 1 do
  begin
    sgSymbol.Cells[i,0]  := Titles[i];
    sgSymbol2.Cells[i,0] := Titles[i];
  end;

  sgSymbol2.Cells[2,0] := '별칭입력';

  for I := 0 to gEnv.Engine.SymbolCore.Sectors.Count - 1 do
  begin
    aMG := gEnv.Engine.SymbolCore.Sectors.Groups[i];
    SymbolTab.Tabs.AddObject( aMG.Title, aMG );
  end;

  if SymbolTab.Tabs.Count > 0 then
  begin
    SymbolTab.TabIndex  := 0;
    SymbolTabChange( SymbolTab );
  end;

  for i := 0 to gEnv.Engine.SymbolCore.FavorFutMarkets.Count-1 do
  begin
    aFutMarket  := TFutureMarket( gEnv.Engine.SymbolCore.FavorFutMarkets.Objects[i] );
    if aFutMarket <> nil then
      UpdateGridData( sgSymbol2, i+1, aFutMarket, gEnv.Engine.SymbolCore.FavorFutMarkets.Strings[i] );
  end;

  RadioGroupMonth.ItemIndex := gEnv.Engine.SymbolCore.FavorFutType;



end;

function TFrmInterestConfig.GetIndex: integer;
var
  I: Integer;
begin

  for I := 1 to sgSymbol2.RowCount - 1 do
    if sgSymbol2.Objects[Mk_Col, i] = nil then
      break;

  if i >= sgSymbol2.RowCount then
    Result := sgSymbol2.RowCount - 1
  else
    Result := i;
end;

function TFrmInterestConfig.Open: Boolean;
begin

  if ShowModal=mrOK then
    Result := True
  else
    Result := False;
end;



procedure TFrmInterestConfig.sgSymbol2DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
  aRect : TREct;

begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  aGrid := Sender as TStringGrid;
  aRect := Rect;

  with aGrid.Canvas do
  begin

    Font.Name := aGrid.Font.Name;
    Font.Size := aGrid.Font.Size;
    Font.Color := clBlack;
      // colors
    if ARow = 0 then
    begin
      Brush.Color := clBtnFace;
    end else
    if (ARow > 0) then
    begin
      if (ARow mod 2) =0 then
      begin
        Brush.Color:= clWhite ;
      end
      else begin
        Brush.Color:= $F0F0F0;
      end;

      if ARow = FSelectRow[ aGrid.Tag]  then  Brush.Color:= clYellow;
    end;
    // background


    FillRect(aRect);
    stText := aGrid.Cells[aCol, aRow];

    if stText <> '' then
    begin
      //-- calc position
      aSize := TextExtent(stText);
      iY := aRect.Top + (aRect.Bottom - aRect.Top - aSize.cy) div 2;
      iX := aRect.Left + (aRect.Right - aRect.Left - aSize.cx) div 2;
      //-- put text
      TextRect(aRect, iX, iY, stText);
    end;

  end;

end;

procedure TFrmInterestConfig.sgSymbol2MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aCol : integer;
begin

  sgSymbol2.MouseToCell( X, Y, aCol, FSelectRow[1]);

  with sgSymbol2 do
    if ( aCol = 2) and ( FSelectRow[1] > 0 ) then
    begin
      Options     := Options + [ goEditing ];
      EditorMode  := true;
    end else begin
      EditorMode  := false;
      Options     := Options - [ goEditing ];
    end;

end;

procedure TFrmInterestConfig.sgSymbolDblClick(Sender: TObject);
begin
  ButtonToRightClick( nil );
end;

procedure TFrmInterestConfig.sgSymbol2DblClick(Sender: TObject);
begin

  ButtonToLeftClick( nil );
end;

procedure TFrmInterestConfig.sgSymbolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aCol : integer;
begin
  with (Sender as TStringGrid) do
  begin
    MouseToCell(X,y, aCol, FSelectRow[ Tag ] );
    Repaint;

    if {( aCol = 2 ) and ( FSelectRow[1] > 0 ) and} (Tag = 1) then
    begin
      FCol  := aCol;
      EditorMode := false;
      Options    := Options - [ goEditing ];
    end;
  end;

end;

procedure TFrmInterestConfig.UpdateGridData( aGrid : TStringGrid; iRow : integer;
  aFutMarket : TFutureMarket ; stAlias : string ; bLeft : boolean);
var
  iCol : integer;
begin
  iCol := 0;
  aGrid.Cells[iCol,iRow] := UpperCase(aFutMarket.Spec.Exchange );  inc(iCol);
  aGrid.Cells[iCol,iRow] := aFutMarket.Spec.Description;           inc(iCol);
  if bLeft then
    aGrid.Cells[iCol,iRow] := UpperCase(aFutMarket.Spec.RootCode )
  else
    if stAlias = '' then    
      aGrid.Cells[iCol,iRow] := aFutMarket.Spec.Description
    else
      aGrid.Cells[iCol,iRow] := stAlias;

  aGrid.Objects[Mk_Col, iRow]  := aFutMarket;
end;

procedure TFrmInterestConfig.SymbolTabChange(Sender: TObject);
var
  aMG : TMarketGroup;
  aMarket: TMarket;
  aFutMarket: TFutureMarket;   //
  aSymbol : TSymbol;
  I, iRow, j, iMaxCol: Integer;
  stResult : string;

begin
  if SymbolTab.TabIndex < 0 then Exit;
  aMG := SymbolTab.Tabs.Objects[ SymbolTab.TabIndex] as TMarketGroup;

  iRow := 1;

  for I := 1 to sgSymbol.RowCount - 1 do
    sgSymbol.Rows[i].Clear;

  try


  iMaxCol := 0;
  for i := 0 to aMG.Markets.Count - 1 do
  begin
    aMarket := aMG.Markets[i];

    case aMarket.Spec.Market of
      mtFutures:
        begin
          aFutMarket := aMarket as TFutureMarket;
          UpdateGridData( sgSymbol, iRow, aFutMarket, '', true );
          inc( iRow );
        end;
    end;
  end;
  {
  if iMaxCol < 9 then
    iMaxCol := 9;
  sgSymbol.ColCount := iMaxCol;
  }
  sgSymbol.RowCount := iRow+1;

  ReSizeGrid;

  except
    gEnv.EnvLog( WIN_TEST, Format( '%d,%d,%d,%d', [ SymbolTab.TabIndex, i, j, aFutMarket.Symbols.Count] ));
  end;
end;

procedure TFrmInterestConfig.ReSizeGrid;
var
  aRect, bRect : TRect;
  iGap : integer;
begin

  iGap := sgSymbol.Width - sgSymbol.ClientWidth ;

  with sgSymbol do
    //if FLastGap > 0 then
      if iGap > FLastGap  then
        ColWidths[1] := FDefWidth - iGap - 20
      else if iGap < FLastGap then
        ColWidths[1] := FDefWidth - 20;

  FLastGap  := iGap;
end;

end.
