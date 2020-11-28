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
    tbOptions: TTabSheet;
    SymbolTab: TTabControl;
    sgSymbol: TStringGrid;
    OptTab: TTabControl;
    Panel1: TPanel;
    sgOpt: TStringGrid;
    Panel2: TPanel;
    sgOptUnder: TStringGrid;
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
    procedure OptTabChange(Sender: TObject);
    procedure sgOptDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgOptUnderDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgOptUnderSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgOptUnderDblClick(Sender: TObject);
    procedure pcOptionsChange(Sender: TObject);
  private
    FSymbolCore: TSymbolCore;
    FMultiSelect : boolean;
    FSelected : TSymbol;
    FMoveSelected: TSymbol;

    FDefWidth : array [0..1] of integer;
    FLastGap  : array [0..1] of integer;
    FAnyHandle: HWnd;
    FSaveRow  : integer;

    FATMRow, FATMCol, FOptUnderRow , FOptCol, FOptRow : integer;
    FOptMarket  : TOptionMarket;
      // set controls
    procedure SetListViewSymbols(aListView: TListView; aMarket: TMarket);
    procedure SetStringGridOptions(aGrid: TStringGrid; aTree: TOptionTree);
    procedure SetComboBoxMonths(aComboBox: TComboBox; aMarket: TMarket);
      // select symbol
    procedure SelectSymbol(aSymbol : TSymbol);
      // get set

    function GetSelCount : Integer;
    procedure ReSizeGrid( sg : TStringGrid; idx : integer );
    function GetRect: TRect;
    procedure UpdateOption;
    procedure ClearOptGrid;
    procedure Reset;
  public
    function Open( bMulti : boolean = false ) : Boolean;
    procedure ShowWindow( aOwner : HWnd ); overload;
    procedure ShowWindow( aOwner : HWnd; iRow : integer ); overload;
    procedure Add(aSymbol : TSymbol); // add a selected symbol
    property Selected: TSymbol read FSelected;

  end;

implementation

uses
  GAppEnv, GleTypes,
  Math
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

  FOptMarket  := nil;

  /// futures  Set...............
  FDefWidth[0] := sgSymbol.ColWidths[1];
  FDefWidth[1] := sgOptUnder.ColWidths[0];
  //FDefWidth2:= 62;//sgSymbol.ColWidths[3];

  //FLastGap := -1;
  with sgSymbol do
    for I := 0 to Title_Cnt - 1 do
      Cells[i,0]  := Titles[i];

  for I := 0 to gEnv.Engine.SymbolCore.Sectors.Count - 1 do
  begin
    aMG := gEnv.Engine.SymbolCore.Sectors.Groups[i];
    SymbolTab.Tabs.AddObject( aMG.Title, aMG );
    OptTab.Tabs.AddObject( aMG.Title, aMG );
  end;

  if SymbolTab.Tabs.Count > 0 then
  begin
    SymbolTab.TabIndex  := 0;
    SymbolTabChange( SymbolTab );
  end;

  /// end futuress...............
  ///
  ///  Options  sEt

  if OptTab.Tabs.Count > 0 then
  begin
    OptTab.Tabs.InsertObject(0, '전체', nil );
    OptTab.TabIndex  := 0;
    OptTabChange( OptTab );
  end;

  /// end options...............
  FAnyHandle  := 0;

  pcOptionsChange(nil );

  pcOptions.Pages[1].TabVisible := false;
  

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
  a := sgSymbol.CellRect(sgSymbol.LeftCol,0);
  b := sgSymbol.CellRect(sgSymbol.LeftCol+5,0);
  Result := Rect( a.Left, a.Top, b.Right, b.Bottom );
end;

procedure TSymbolDialog.sgSymbolDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  iL, iC, iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
  aRect : TREct;
  cBack : TColor;

  aFutMarket : TFutureMarket;
  aSymbol    : TSymbol;
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  aGrid := Sender as TStringGrid;
  aRect := Rect;
  cBack := clWhite;

  iL    := sgSymbol.LeftCol;
  iC    := iL + 5;//sgSymbol.ColCount-1;
  with aGrid.Canvas do
  begin

    Font.Name := aGrid.Font.Name;
    Font.Size := aGrid.Font.Size;
    Font.Color := clBlack;
      // colors
    if ARow = 0 then
    begin
      if ACol in [iL..iC] then
      begin
        aRect := GetRect;
        //Caption := Format('%d,%d',[ iL, iC]) + ' '+ IntToStr( aRect.Left ) + ',' + IntToStr(aRect.Right - aRect.Left );
      end;
      cBack := clMoneyGreen;
    end else
    begin
      aFutMarket := TFutureMarket( aGrid.Objects[Mk_Col, ARow]);
      if ACol in [0..2] then
        cBack := clBtnFace;

      if (aFutMarket <> nil ) and ( aGrid.Objects[ACol, ARow] <> nil ) and
        ( aFutMarket.MuchMonth = aGrid.Objects[ACol, ARow] ) and ( ACol <> Mk_Col )  then
        cBack:= clYellow;

      if (gdSelected in State ) and ( aGrid.Objects[ACol, ARow] <> nil ) and ( ACol > 2) then
        cBack := clSkyblue;
    end;

    // background
    Brush.Color := cBack;
    FillRect(aRect);
    //-- text
    if ( ARow = 0 ) and ( ACol in [iL..iC] ) then
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

    case (Sender as TStringGrid).Tag of
      2 : begin FOptCol := ACol; FOptRow := ARow;  end; 
    end;

    if not cbStay.Checked then
      Hide;
  end;

end;

procedure TSymbolDialog.sgOptDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
  aRect : TREct;
  cBack : TColor;
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  aGrid := Sender as TStringGrid;
  aRect := Rect;
  cBack := clWhite;

  with aGrid.Canvas do
  begin

    Font.Name := aGrid.Font.Name;
    Font.Size := aGrid.Font.Size;
    Font.Color := clBlack;

    if ARow < 2 then
      cBack := clBtnFace
    else begin

      if (ARow mod 2) =0 then
        cBack:= clWhite
      else
        cBack:= $F0F0F0;

      if ( ARow = FOptRow ) and ( ACol = FOptCol ) then
        cBack := clYellow;

      if ( ARow = FATMRow ) and ( ACol = FATMCol ) then
        cBack := clGray;
    end;

    // background
    Brush.Color := cBack;
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

procedure TSymbolDialog.sgOptUnderDblClick(Sender: TObject);
begin
  if FOptUnderRow > -1 then
  begin
    //
    UpdateOption;
  end;
end;

procedure TSymbolDialog.sgOptUnderDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  iL, iC, iX, iY : Integer;
  aSize : TSize;
  stText : String;
  aGrid: TStringGrid;
  aRect : TREct;
  cBack : TColor;
begin
  if (Sender = nil) or not (Sender is TStringGrid) then Exit;

  aGrid := Sender as TStringGrid;
  aRect := Rect;
  cBack := clWhite;

  iL    := sgSymbol.LeftCol;
  iC    := iL + 5;//sgSymbol.ColCount-1;
  with aGrid.Canvas do
  begin

    Font.Name := aGrid.Font.Name;
    Font.Size := aGrid.Font.Size;
    Font.Color := clBlack;

    if ACol = 0 then
      cBack := clMoneyGreen
    else begin

      if (ARow mod 2) =0 then
      begin
        //cBack:= clWhite ;
        if{ (gdSelected in State) and} (  ARow = FOptUnderRow ) then
          cBack:= clYellow
        else
          cBack:= clwhite;
      end
      else begin
        //cBack:= $F0F0F0;
        if {(gdSelected in State) and }( ARow = FOptUnderRow  ) then
          cBack:= clYellow
        else
          cBack:= $F0F0F0;
      end;
    end;

    // background
    Brush.Color := cBack;
    FillRect(aRect);

    stText := aGrid.Cells[aCol, aRow];

    if stText <> '' then
    begin
      //-- calc position
      aSize := TextExtent(stText);
      iY := aRect.Top + (aRect.Bottom - aRect.Top - aSize.cy) div 2;
      iX := aRect.Left + (aRect.Right - aRect.Left - aSize.cx) div 2;
      //-- put text

      if ACol = 0 then
        TextRect(aRect, aRect.Left+1, iY, stText)
      else
        TextRect(aRect, iX, iY, stText);
    end;
  end;

end;

procedure TSymbolDialog.sgOptUnderSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ( ARow < 0 ) or ( sgOptUnder.RowCount < ARow ) then Exit;
  FOptUnderRow  := ARow;
  sgOptUnder.Repaint;
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


procedure TSymbolDialog.OptTabChange(Sender: TObject);
var
  pMG, aMG : TMarketGroup;
  aMarket: TMarket;
  aOptMarket: TOptionMarket;   //
  aSymbol : TSymbol;
  I, j, iRow, iCol : Integer;

begin
  if optTab.TabIndex < 0 then Exit;

  pMG := optTab.Tabs.Objects[ optTab.TabIndex] as TMarketGroup;
  iRow := 0;

  for I := 0 to sgOptUnder.RowCount - 1 do
    sgOptUnder.Rows[i].Clear;

  try

    with sgOptUnder do
    for j := 0 to gEnv.Engine.SymbolCore.Sectors.Count - 1 do
    begin

      aMG := gEnv.Engine.SymbolCore.Sectors.Groups[j];

      if optTab.TabIndex > 0 then
        if pMG <> aMG then Continue;

      for i := 0 to aMG.Markets.Count - 1 do
      begin
        aMarket := aMG.Markets[i];

        case aMarket.Spec.Market of
          mtOption:
            begin
              aOptMarket := aMarket as TOptionMarket;

              iCol := 0;
              Cells[iCol,iRow] := UpperCase(aOptMarket.Spec.Exchange ) + ' ' + aOptMarket.Spec.Description;
              inc(iCol);
              Cells[iCol,iRow] := UpperCase(aOptMarket.Spec.RootCode );
              Objects[0,iRow]  := aOptMarket;
              inc( iRow );

            end;
        end;
      end; // for i;
    end;
  finally
    sgOptUnder.RowCount := iRow;
    ReSizeGrid( sgOptUnder, 0 );
    FOptUnderRow := 0;
    UpdateOption;
  end;
end;

procedure TSymbolDialog.pcOptionsChange(Sender: TObject);
begin
  if pcOptions.ActivePage = tbFutures then
  begin
    if Height > 329 then
      Height := 329
  end
  else if pcOptions.ActivePage = tbOptions then
  begin
    Height := 500;
  end;

end;

procedure TSymbolDialog.SymbolTabChange(Sender: TObject);
var
  aMG : TMarketGroup;
  aMarket: TMarket;
  aFutMarket: TFutureMarket;   //
  aSymbol : TSymbol;
  I, iRow, iCol, j, iMaxCol: Integer;
  stResult : string;

  procedure SetCol ;
  begin
    if iCol > sgSymbol.ColCount-1 then
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
          sgSymbol.Objects[ Mk_Col, iRow] := aFutMarket;

          iCol := 3;
          for j := 0 to aFutMarket.Symbols.Count - 1 do
          begin
            aSymbol := aFutMarket.Symbols.Symbols[j];
          //  SetCol;
            //stResult  := GetMonth(aSymbol.ShortCode);
            stResult := FormatDateTime('yyyy.mm', (asymbol as TDerivative).ExpDate);// + ','+ GetMonth(aSymbol.ShortCode);
            sgSymbol.Cells[iCol,iRow] := stResult;
            sgSymbol.Objects[iCol,iRow] := aSymbol;
            inc( iCol );
          end;

          if iCol > iMaxCol then
            iMaxCol := iCol;

          inc( iRow );

        end;
    end;
  end;

  if iMaxCol < 9 then
    iMaxCol := 9;
  sgSymbol.ColCount := iMaxCol;

  sgSymbol.RowCount := iRow;

  if sgSymbol.RowCount > 1 then
  begin
    sgSymbol.FixedRows  := 1;
    sgSymbol.FixedCols  := 3;
    //sgSymbol.FixedColor := clBtnFace;
  end;

  ReSizeGrid( sgSymbol, 1);

  except
    gEnv.EnvLog( WIN_TEST, Format( '%d,%d,%d,%d', [ SymbolTab.TabIndex, i, j, aFutMarket.Symbols.Count] ));
  end;
end;

procedure TSymbolDialog.ClearOptGrid;
var
  i : integer;
begin
  for I := 1 to sgOpt.RowCount - 1 do
    sgOpt.Rows[i].Clear;
  sgOpt.ColCount := 1;
  sgOpt.RowCount := 1;
end;

procedure TSymbolDialog.UpdateOption;
var
  aOptMarket  : TOptionMarket ;
  iATMRow, iPre, iMaxPre, iMonCnt, i, j, idx, iRow , iStkCnt : integer;
  aTree : TOptionTree;
  aStk  : TStrike;
  stTmp : string;
begin

  if FOptUnderRow < 0 then
    FOptUnderRow := 0;

  aOptMarket  := TOptionMarket( sgOptUnder.Objects[ 0, FOptUnderRow ]);
  if aOptMarket = FOptMarket then Exit;


  Reset;
  // 월물 개수..
  iMonCnt := aOptMarket.Trees.Count;

  sgOpt.ColCount  := iMonCnt * 2 + 1;
  sgOpt.ColWidths[iMonCnt]  := 60;
  sgOpt.Cells[iMonCnt, 0]   := '행사가';

  iStkCnt := 0;      idx := 0;
  for I := 0 to aOptMarket.Trees.Count - 1 do
  begin
    aTree := aOptMarket.Trees.Trees[i];
    if aTree.Strikes.Count > iStkCnt then
    begin
      iStkCnt := aTree.Strikes.Count ;
      idx := i;
    end;

    sgOpt.Objects[iMonCnt-1-i, 1] := aTree;
    sgOpt.Objects[iMonCnt+1+i, 1] := aTree;

    sgOpt.Cells[iMonCnt-1-i, 1] := Format('%d월', [aTree.ExpMonth]);
    sgOpt.Cells[iMonCnt+1+i, 1] := Format('%d월', [aTree.ExpMonth]);
  end;

  sgOpt.RowCount := iStkCnt + 2;
  if sgOpt.RowCount > 2 then
    sgOpt.FixedRows := 2;

  // 행사가 max 개수 = iStkCnt
  iMaxPre := 0;
  for I := aOptMarket.Trees.Trees[idx].Strikes.Count - 1 downto 0 do
  begin
    aStk  := aOptMarket.Trees.Trees[idx].Strikes.Strikes[i];
    //Cells[iMonCnt, i+2 ] := FloatToStr( aStk.StrikePrice );
    iPre  := GetPrecision( FloatToStr( aStk.StrikePrice ));
    if iMaxPre < iPre then
      iMaxPre := iPre;
  end;

  iRow := 2;
  with sgOpt do
  for I := aOptMarket.Trees.Trees[idx].Strikes.Count - 1 downto 0 do
  begin
    aStk  := aOptMarket.Trees.Trees[idx].Strikes.Strikes[i];
    Cells[iMonCnt, iRow ] := Format('%.*f', [ iMaxPre, aStk.StrikePrice ]);
    inc(iRow);
  end;

  // /////////////

  iATMRow := -1;
  idx := 1;
  with sgOpt do
    for j := iMonCnt+1 to  sgOpt.ColCount-1 do
    begin

      iRow := 2;
      aTree  := TOptionTree( sgOpt.Objects[ j, 1] );
      if aTree <> nil then
        for I := 0 to aTree.Strikes.Count  - 1 do
        begin
          aStk  := aTree.Strikes.Strikes[i];
          stTmp := Format('%.*f', [ iMaxPre, aStk.StrikePrice ]);
          iRow := sgOpt.Cols[iMonCnt].IndexOf( stTmp );
          if iRow > 0 then
          begin
            // 풋월물
            Cells[j, iRow]  := 'O';
            Objects[j, iRow]  := aStk.Put;
            // 콜월물
            Cells[iMonCnt-idx, iRow]  := 'O';
            Objects[iMonCnt-idx, iRow]  := aStk.Call;

            if aStk.Call.IsATM then
              iATMRow := iRow;
          end;
        end;
      inc( idx );
    end;


  if iATMRow > 0 then
  begin
    iStkCnt := sgOpt.VisibleRowCount div 2;
    sgOpt.TopRow  := Max(0, iATMRow - iStkCnt);
    FATMRow := iATMRow;
  end;

  if iMonCnt > 0 then
  begin
    iStkCnt := sgOpt.VisibleColCount div 2;
    sgOpt.LeftCol := Max(0, iMonCnt - iStkCnt);
    FATMCol := iMonCnt;
  end;

  FOptMarket  := aOptMarket;

  sgOpt.Repaint;

end;

procedure TSymbolDialog.Reset;
begin
  ClearOptGrid;
  FATMRow := -1;
  FATMCol := -1;
  FOptCol := -1;
  FOptRow := -1;
end;

procedure TSymbolDialog.ReSizeGrid( sg : TStringGrid; idx : integer );
var
  iGap : integer;
begin


  iGap := sg.Width - sg.ClientWidth ;

  with sg do
    //if FLastGap > 0 then
      if iGap > FLastGap[ sg.Tag ]  then
        ColWidths[idx] := ColWidths[idx] - iGap
      else if iGap < FLastGap[ sg.Tag ] then
        ColWidths[idx] := FDefWidth[ sg.Tag ];

  FLastGap[ sg.Tag ]  := iGap;
end;


end.
