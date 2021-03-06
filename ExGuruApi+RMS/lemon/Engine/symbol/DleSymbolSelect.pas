unit DleSymbolSelect;

// symbol selection dialog
// (c) All rights reserved.

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CheckLst, ExtCtrls, Grids, ComCtrls, Menus, CommCtrl,
    // lemon: common
  GleLib, GleConsts,
    // lemon: data
  CleSymbolCore, CleSymbols, CleMarkets, CleFQN;

const
  Title_Cnt = 4;
  Titles  : array [0..Title_Cnt-1] of string = ('거래소','종목명','코드','월물');
  Mk_Col  = 1;
type
  TSymbolDialog = class(TForm)
    Panel3: TPanel;
    cbStay: TCheckBox;
    pcOptions: TPageControl;
    tbFutures: TTabSheet;
    SymbolTab: TTabControl;
    sgSymbol : TStringGrid;
    Label1: TLabel;
    procedure RadioButtonCallPutClick(Sender: TObject);

    procedure ComboBoxMarketsChange(Sender: TObject);
    procedure ComboBoxMonthsChange(Sender: TObject);

    procedure StringGridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure SymbolDblClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

    procedure SymbolTabChange(Sender: TObject);
    procedure sgSymbolDblClick(Sender: TObject);
    procedure sgSymbolSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgSymbolDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbStayClick(Sender: TObject);
  private
    FSymbolCore: TSymbolCore;
    FMultiSelect : boolean;
    FSelected : TSymbol;
    FMoveSelected: TSymbol;
    FDefRect  : TRect;
    FDefWidth : integer;
    FLastGap  : integer;
    FAnyHandle: HWnd;
    FSaveRow  : integer;
      // set controls
    procedure SetListViewSymbols(aListView: TListView; aMarket: TMarket);
    procedure SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);
    procedure SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
      // select symbol
    procedure SelectSymbol(aSymbol : TSymbol);
      // get set

    function GetSelCount : Integer;
    procedure ReSizeGrid;
    function GetRect: TRect;
  public
    function Open( bMulti : boolean = false ) : Boolean;
    procedure ShowWindow( aOwner : HWnd ); overload;
    procedure ShowWindow( aOwner : HWnd; iRow : integer ); overload;
    procedure Add(aSymbol : TSymbol); // add a selected symbol
    property Selected: TSymbol read FSelected;

  end;

implementation

uses
  GAppEnv, GleTypes
  ;

{$R *.DFM}

procedure TSymbolDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
  gSymbol := nil;
end;

procedure TSymbolDialog.FormCreate(Sender: TObject);
var
  I: Integer;
  aMG : TMarketGroup;

begin
  gSymbol := self;
  /// futures  Set...............

  FDefWidth := sgSymbol.ColWidths[1];
  //FLastGap := -1;
  with sgSymbol do
    for I := 0 to Title_Cnt - 1 do
      Cells[i,0]  := Titles[i];

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

  /// end futuress...............
  ///
  ///  Options  sEt


  /// end options...............
  FAnyHandle  := 0;

end;

procedure TSymbolDialog.FormDestroy(Sender: TObject);
begin
  gSymbol := nil;
end;

function TSymbolDialog.GetSelCount: Integer;
begin

end;
//---------------------------------------------------------< market selection >

// (Published)
// market selected
//
procedure TSymbolDialog.cbStayClick(Sender: TObject);
begin
  //
end;

procedure TSymbolDialog.ComboBoxMarketsChange(Sender: TObject);
var
  aObject: TObject;
begin
  if (Sender = nil) or not (Sender is TComboBox) then Exit;

  aObject := GetComboObject(Sender as TComboBox);
  if (aObject = nil) or not (aObject is TMarket) then Exit;
  {
    //
  case (Sender as TComboBox).Tag of
    100: SetListViewSymbols(ListViewFutures, aObject as TMarket);
    200: SetComboBoxMonths(ComboBoxOptionMonths, aObject as TMarket);
    300: SetListViewSymbols(ListViewSpread, aObject as TMarket);
    400: SetListViewSymbols(ListViewIndex, aObject as TMarket);
    500: SetListViewSymbols(ListViewStock, aObject as TMarket);
    600: SetStringGridELWTrees(aObject as TMarket);
  end;
  }
end;

procedure TSymbolDialog.RadioButtonCallPutClick(Sender: TObject);
begin
  //ComboBoxMarketsChange(ComboBoxELWMarkets);
end;

// (private)
// set listview for symbols
//
procedure TSymbolDialog.SetListViewSymbols(aListView: TListView; aMarket: TMarket);
var
  i : Integer;
  aItem : TListItem;
  aSymbol: TSymbol;
begin
  if (aListView = nil) or (aMarket = nil) then Exit;

    // clear existing symbol list
  aListView.Items.Clear;
  
    // populate listview
  for i := 0 to aMarket.Symbols.Count - 1 do
  begin
    aItem := aListView.Items.Add;
    aSymbol := aMarket.Symbols[i];

    aItem.Caption := aSymbol.ShortCode;
    aItem.SubItems.Add(aSymbol.Name);
    aItem.Data := aSymbol;
  end;
end;

// (private)
procedure TSymbolDialog.SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
begin
  if (aComboBox = nil) or (aMarket = nil)
     or not (aMarket is TOptionMarket) then Exit;

    // populate
  aComboBox.Items.Clear;
  (aMarket as TOptionMarket).Trees.GetList(aComboBox.Items);

    // select the first month
  SetComboIndex(aComboBox, 0);

    // set option grid
  ComboBoxMonthsChange(aComboBox);
end;

// (private)
procedure TSymbolDialog.ComboBoxMonthsChange(Sender: TObject);
var
  aObject: TObject;
  aGrid: TStringGrid;
begin
  if (Sender = nil) or not (Sender is TComboBox) then Exit;

    // get selected object
  aObject := GetComboObject(Sender as TComboBox);
  if (aObject = nil) or not (aObject is TOptionTree) then Exit;
  {
    // select string grid
  case (Sender as TComboBox).Tag of
    700: aGrid := StringGridOptions;
    800: aGrid := StringGridELWs;
    else
      Exit;
  end;
  }
    //
  SetStringGridOptions(aGrid, aObject as TOptionTree);
end;

// (private)
procedure TSymbolDialog.SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);
var
  ivar, i: Integer;
  aStrike: TStrike;
begin
  if (aGrid = nil) or (aTree = nil) then Exit;

  aGrid.RowCount := aTree.Strikes.Count;

  ivar  := FSymbolCore.GetCustomATMIndex( GetATM(FSymbolcore.Future.Last  ), 0 );

  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];

    if i= ivar then
      aGrid.Objects[1,i]  := Pointer(integer( clYellow ));

      // strike price
    aGrid.Cells[1, i] := Format('%.2f', [aStrike.StrikePrice]);
      // call
    if aStrike.Call <> nil then begin
      aGrid.Objects[0,i] := aStrike.Call;
      aGrid.Cells[0,i]   := Format('%.2f', [ aStrike.Call.Last ] );
    end
    else
      aGrid.Objects[0,i] := nil;
      // put
    if aStrike.Put <> nil then begin
      aGrid.Objects[2,i] := aStrike.Put;
      aGrid.Cells[2, i]  := format('%.2f', [ aStrike.Put.Last ]);
    end
    else
      aGrid.Objects[2,i] := nil
  end;

    // todo: checking ATM routnine
end;



function TSymbolDialog.GetRect : TRect;
var
  a, b : TRect;
begin
  a := sgSymbol.CellRect(3,0);
  b := sgSymbol.CellRect(sgSymbol.ColCount-1,0);
  Result := Rect( a.Left, a.Top, b.Right, b.Bottom );
end;

procedure TSymbolDialog.sgSymbolDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
  aRect : TREct;
  aFutMarket : TFutureMarket;
  aSymbol    : TSymbol;
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
      if ACol in [3..aGrid.ColCount-1] then
        aRect := GetRect;

    end else
    if (ARow > 0) then
    begin
      aFutMarket := TFutureMarket( aGrid.Objects[Mk_Col, ARow]);
      if (ARow mod 2) =0 then
        Brush.Color:= clWhite
      else
        Brush.Color:= $F0F0F0;
      if (aFutMarket <> nil ) and ( aGrid.Objects[ACol, ARow] <> nil ) and
        ( aFutMarket.MuchMonth = aGrid.Objects[ACol, ARow] ) and ( ACol <> Mk_Col )  then
        Brush.Color:= clYellow;

      if (gdSelected in State ) and ( aGrid.Objects[ACol, ARow] <> nil ) and ( ACol > 2) then
        Brush.Color := clSkyblue;
    end;
    // background
    FillRect(aRect);
    //-- text
    if ( ARow = 0 ) and ( ACol in [3..8] ) then
      stText := aGrid.Cells[3,ARow]
    else
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

procedure TSymbolDialog.sgSymbolSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  if (aCol > 2) and
     ((Sender as TStringGrid).Objects[aCol, aRow] <> nil) then
    CanSelect := True
  else
    CanSelect := False;

    //
  if CanSelect then
    SelectSymbol(TSymbol((Sender as TStringGrid).Objects[aCol,aRow]))
  else
    SelectSymbol(nil);

  if FSelected <> nil then
  begin

    try
      if FAnyHandle > 0 then
        if FSaveRow > 0 then
          SendMessage( FAnyHandle, WM_SYMBOLSELECTED, FSaveRow, integer(Pointer( FSelected )))
        else
          SendMessage( FAnyHandle, WM_SYMBOLSELECTED, 0, integer(Pointer( FSelected )));
    except
    end;

    if not cbStay.Checked then
      Hide;
  end;

end;

procedure TSymbolDialog.sgSymbolDblClick(Sender: TObject);
begin

end;

// select symbol
procedure TSymbolDialog.SelectSymbol(aSymbol : TSymbol);
begin
    FSelected := aSymbol;
end;


//--------------------------------------------------------------------< open >

// (public)
//

function TSymbolDialog.Open( bMulti : boolean ): Boolean;
begin
  Result := (ShowModal = mrOK);
end;

// add to the selected symbol list
//
procedure TSymbolDialog.Add(aSymbol : TSymbol);
begin

end;

//--------------------------------------------------------------------< draw >


// 옵션종목
procedure TSymbolDialog.ShowWindow(aOwner: HWnd);
begin
  Show;
  FAnyHandle  := aOwner;
  FSaveRow:= -1;
end;

procedure TSymbolDialog.ShowWindow(aOwner: HWnd; iRow: integer);
begin
  Show;
  FAnyHandle  := aOwner;
  FSaveRow:= iRow;
end;

procedure TSymbolDialog.StringGridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin

end;

//--------------< UI Events : Buttons >----------------//

procedure TSymbolDialog.ButtonOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TSymbolDialog.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TSymbolDialog.ButtonHelpClick(Sender: TObject);
begin
//  gHelp.Show(ID_SYMBOL);
end;

//--------------< UI Events : Move >-----------------------//

procedure TSymbolDialog.SymbolDblClick(Sender: TObject);
begin
  if not FMultiSelect then
    ModalResult := mrOK
  else
    Add(FSelected);
end;

procedure TSymbolDialog.SymbolTabChange(Sender: TObject);
var
  aMG : TMarketGroup;
  aMarket: TMarket;
  aFutMarket: TFutureMarket;   //
  aSymbol : TSymbol;
  I, iRow, iCol, j, iMaxCol: Integer;
  stLog, stResult, stTmp : string;

  procedure SetCol ;
  begin
    if iCol = sgSymbol.ColCount-1 then
    begin
      iCol := 3;
      inc( iRow );
    end
    else
      inc( iCol );
  end;

  function GetMonth( stCode : string ) : string;
  var
    iM,iLen : integer;
    stM : string;
  begin
    iLen := Length( stCode );
    iM := iLen -1;

    case stCode[iM] of
      'F' : Result := '01';
      'G' : Result := '02';
      'H' : Result := '03';
      'J' : Result := '04';
      'K' : Result := '05';
      'M' : Result := '06';
      'N' : Result := '07';
      'Q' : Result := '08';
      'U' : Result := '09';
      'Y' : Result := '10';
      'X' : Result := '11';
      'Z' : Result := '12';
    end;
  end;


begin
  if SymbolTab.TabIndex < 0 then Exit;
  aMG := SymbolTab.Tabs.Objects[ SymbolTab.TabIndex] as TMarketGroup;

  iRow := 1;

  for I := 1 to sgSymbol.RowCount - 1 do
    sgSymbol.Rows[i].Clear;

  try

  gEnv.EnvLog( WIN_TEST, aMG.FQN );

  iMaxCol := 0;
  for i := 0 to aMG.Markets.Count - 1 do
  begin
    aMarket := aMG.Markets[i];

    case aMarket.Spec.Market of
      mtFutures:
        begin
          aFutMarket := aMarket as TFutureMarket;

          iCol := 0;
          sgSymbol.Cells[iCol,iRow] := UpperCase(aFutMarket.Spec.Exchange );  inc(iCol);
          sgSymbol.Cells[iCol,iRow] := aFutMarket.Spec.Description;           inc(iCol);
          sgSymbol.Cells[iCol,iRow] := UpperCase(aFutMarket.Spec.RootCode );

          //gEnv.EnvLog( WIN_TEST, Format('[%d, %d ,%s(%s) ]', [ iCol, iRow, aFutMarket.Spec.Description, aFutMarket.FQN ] ));
          sgSymbol.Objects[ Mk_Col, iRow] := aFutMarket;

          stLog := '';
          for j := 0 to aFutMarket.Symbols.Count - 1 do
          begin
            aSymbol := aFutMarket.Symbols.Symbols[j];
            SetCol;
            //stResult  := GetMonth(aSymbol.ShortCode);
            //stResult := FormatDateTime('yyyy', (asymbol as TFuture).ExpDate) + ','+ GetMonth(aSymbol.ShortCode);
            stTmp    := FormatDateTime('yyyy', (asymbol as TFuture).ExpDate);
            stResult := Format('%s%s.%s', [ Copy( stTmp, 1, 3), aSymbol.ShortCode[Length( aSymbol.ShortCode )],
                        GetMonth(aSymbol.ShortCode) ]);
            //stResult := FormatDateTime('yyyy', (asymbol as TFuture).ExpDate) + ','+ GetMonth(aSymbol.ShortCode);
            sgSymbol.Cells[iCol,iRow] := stResult;
            sgSymbol.Objects[iCol,iRow] := aSymbol;

            //stLog := stLog + Format('[%d, %d ,%s ]', [ iCol, iRow, stResult ] );
          end;

          //gEnv.EnvLog( WIN_TEST, stLog );

            {
          if iCol > iMaxCol then
            iMaxCol := iCol;
            }

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

procedure TSymbolDialog.ReSizeGrid;
var
  aRect, bRect : TRect;
  iGap : integer;
begin
  aRect  := sgSymbol.CellRect(3,0);
  bRect  := sgSymbol.CellRect(8,0);

  FDefRect := Rect( aRect.Left, aRect.Top, bRect.Right, bRect.Bottom );

  iGap := sgSymbol.Width - sgSymbol.ClientWidth ;

  with sgSymbol do
    //if FLastGap > 0 then
      if iGap > FLastGap  then
        ColWidths[1] := ColWidths[1] - iGap
      else if iGap < FLastGap then
        ColWidths[1] := FDefWidth;

  FLastGap  := iGap;
end;


end.
