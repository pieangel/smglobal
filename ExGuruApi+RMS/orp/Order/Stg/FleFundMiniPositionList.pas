unit FleFundMiniPositionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleFunds, CleAccounts, CleSymbols, ClePositions, CleQuotebroker, CleDistributor,

  CleStorage, Menus
  ;

const
  Title_1 : array [0..3] of string = ('�򰡼���','��������','������','������');
  Title_2 : array [0..2] of string = ('�����ڵ�','�� ��','��հ�');
  Title_3 : array [0..3] of string = ('����','�ڵ�','�ܰ�','��հ�');

  Symbol_Col = 0;
  Color_Col  = 2;

type

  TFrmFundMiniPosList = class(TForm)
    p1: TPanel;
    cbAccount: TComboBox;
    sgTop: TStringGrid;
    Panel1: TPanel;
    sgBottom: TStringGrid;
    RefreshTimer: TTimer;
    Show0Net: TCheckBox;
    cbAcnt: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTopDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Show0NetClick(Sender: TObject);
    procedure ShowUnitClick(Sender: TObject);

    procedure DoPosition( aPosition : TFundPosition ; EventID: TDistributorID);
    procedure DoFund( aFund : TFund ; EventID: TDistributorID);
    procedure cbAcntClick(Sender: TObject);
  private
    { Private declarations }
    FFund : TFund;

    procedure initControls;
    procedure RefreshPosition;
    procedure RefreshBottom;
    procedure RefreshTop;

    procedure TradePrc( Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure UpdatePosition(aPosition: TPosition; bAdd: boolean);
    procedure UpdateRow(iRow: Integer; aPos: TFundPosition; bAdd : boolean);
    procedure Clear(aGrid: TStringGrid);
    procedure ChangeGrid;
    procedure RefreshBottom2;
    procedure UpdateRow2(iRow: Integer; aPos: TPosition; bAdd: boolean);

  public
    { Public declarations }

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

var
  FrmFundMiniPosList: TFrmFundMiniPosList;

implementation

uses
  GAppEnv , GleLib , GleConsts,
  Math
  ;

{$R *.dfm}

procedure TFrmFundMiniPosList.cbAccountChange(Sender: TObject);
var
  aFund : TFund;
begin

  aFund := TFund( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
  if (aFund <> nil ) and (FFund <> aFund) then
  begin
    FFund := aFund;
    Clear( sgBottom );
    RefreshPosition;
  end;

end;

procedure TFrmFundMiniPosList.cbAcntClick(Sender: TObject);
begin
  //
  ChangeGrid;
  RefreshBottom;
end;

procedure TFrmFundMiniPosList.Clear( aGrid : TStringGrid );
var
  I: Integer;
begin

  for I := 1 to aGrid.RowCount - 1 do
    aGrid.Rows[i].Clear;
  aGrid.RowCount  := 2;

end;

procedure TFrmFundMiniPosList.DoFund(aFund: TFund; EventID: TDistributorID);
var
  i : integer;
  bSelf : boolean;
  tmpFund : TFund;
begin
  case integer( EventID ) of
    FUND_NEW  : begin
        cbAccount.Items.AddObject( aFund.Name, aFund );
        if FFund = nil then
        begin
          cbAccount.ItemIndex  := 0;
          cbAccountChange( nil ) ;
        end;
       end;
    FUND_DELETED :
      begin
        i := cbAccount.Items.IndexOfObject( aFund );
        if i >= 0 then
        begin
          bSelf :=  i = cbAccount.ItemIndex;
          cbAccount.Items.Delete( i );
          if cbAccount.Items.Count > 0 then
          begin
            if bSelf then
              cbAccount.ItemIndex  := 0
            else
              SetComboIndex( cbAccount,FFund  );
            cbAccountChange( nil ) ;
          end else begin
            cbAccount.Clear;
            FFund := nil;
          end;
        end;

        if cbAccount.Items.Count <= 0 then
        begin
          FFund := nil;
          RefreshTop;
          Clear( sgBottom );
        end;
      end ;
    FUND_UPDATED ,FUND_ACNT_UPDATE:
      begin
        cbAccount.Clear;
        tmpFund := FFund;
        FFund   := nil;
        gEnv.Engine.TradeCore.Funds.GetList( cbAccount.Items);

        if tmpFund = nil then
          cbAccount.ItemIndex  := 0
        else
          SetComboIndex( cbAccount,tmpFund  );
        cbAccountChange( nil ) ;
      end    ;
  end;

end;

procedure TFrmFundMiniPosList.DoPosition(aPosition: TFundPosition;
  EventID: TDistributorID);
begin
  //
end;

procedure TFrmFundMiniPosList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmFundMiniPosList.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  //
  initControls;

  gEnv.Engine.TradeCore.Funds.GetList( cbAccount.Items );
  FFund  := nil;

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  gEnv.Engine.TradeBroker.Subscribe( Self, FUND_DATA, TradePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, FPOS_DATA, TradePrc );

end;

procedure TFrmFundMiniPosList.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmFundMiniPosList.initControls;
var
  i : integer;
begin
  with sgTop do
  begin
    for I := 0 to RowCount - 1 do
      Cells[0, i]  := Title_1[i];

    ColWidths[1]  := Width - DefaultColWidth - 3;

  end;

  with sgBottom do
  begin
    for I := 0 to ColCount - 1 do
      Cells[i,0]  := Title_2[i];

    ColWidths[0] := 67;
    ColWidths[1] := 49;
    ColWidths[2] := 80;
  end;
end;

procedure TFrmFundMiniPosList.ChangeGrid;
var
  i : integer;
begin
  Clear( sgBottom );
  if cbAcnt.Checked then
  begin
    with sgBottom do
    begin
      ColCount  := 4;

      for I := 0 to ColCount - 1 do
        Cells[i,0]  := Title_3[i];

      ColWidths[0] := 52;
      ColWidths[1] := 45;
      ColWidths[2] := 35;
      ColWidths[3] := 63;
    end;

  end else
  begin

    with sgBottom do
    begin
      ColCount  := 3;

      for I := 0 to ColCount - 1 do
        Cells[i,0]  := Title_2[i];

      ColWidths[0] := 67;
      ColWidths[1] := 49;
      ColWidths[2] := 80;
    end;
  end;
end;


procedure TFrmFundMiniPosList.LoadEnv(aStorage: TStorage);
begin
  //
  if aStorage = nil then Exit;

  Show0Net.Checked  := aStorage.FieldByName('Show0Net').AsBoolean ;

end;


procedure TFrmFundMiniPosList.RefreshTimerTimer(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmFundMiniPosList.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('Show0Net').AsBoolean  := Show0Net.Checked;

end;

procedure TFrmFundMiniPosList.sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
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

  with sgBottom do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      if ACol <> 0 then
        wFmt  := DT_RIGHT or DT_VCENTER;

      if (ACol = 1) and ( not cbAcnt.Checked ) then
        ftClr := TColor( integer( Objects[Color_Col, ARow] ))
      else if (ACol = 2) and ( cbAcnt.Checked ) then
        ftClr := TColor( integer( Objects[Color_Col, ARow] ));
           

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

procedure TFrmFundMiniPosList.sgTopDrawCell(Sender: TObject; ACol, ARow: Integer;
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

  with sgTop do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ACol = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      wFmt  := DT_RIGHT or DT_VCENTER;
      ftClr := TColor( integer( Objects[ACol, ARow] ));
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;
end;

procedure TFrmFundMiniPosList.Show0NetClick(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmFundMiniPosList.ShowUnitClick(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmFundMiniPosList.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  case DataID of
    FUND_DATA :
        case Integer(EventID) of
          FPOSITION_NEW,
          FPOSITION_UPDATE :  DoPosition(DataObj as TFundPosition, EventID);
        end;
    FPOS_DATA :
        case Integer(EventID) of
          FUND_NEW,
          FUND_DELETED,
          FUND_UPDATED,           // = 242;   // �ݵ� �̸� ����
          FUND_ACNT_UPDATE : DoFund( DataObj as TFund, EventID );        //  = 243;   // �ݵ忡 ���� ����
        end;
  end;

end;

procedure TFrmFundMiniPosList.UpdatePosition( aPosition : TPosition; bAdd : boolean );
begin

end;

procedure TFrmFundMiniPosList.RefreshPosition;
begin
  if FFund = nil then Exit;

  RefreshTop;
  RefreshBottom;
end;

procedure TFrmFundMiniPosList.RefreshTop;
var
  aInvestor : TInvestor;
  I: Integer;
  aAccount  : TAccount;
  aPos  : TPosition;
  dEntry, dPL, dFee, dTotPL : double;
  iDiv : integer;
begin

  dEntry  := 0;
  dPL  := 0;
  dFee := 0;
  dTotPL  := 0;

  iDiv := 1;//ifThen( ShowUnit.Checked, 1000, 1 );
  if FFund <> nil then
    gEnv.Engine.TradeCore.FundPositions.GetFundPL( FFund, dEntry, dPL, dFee  );

  dTotPL  := dEntry + dPL - dFee;

  with sgTop do
  begin
    Cells[1, 0] := Formatfloat('#,##0.###', dEntry / iDiv  );
    Cells[1, 1] := Formatfloat('#,##0.###', dPL  / iDiv  );
    Cells[1, 2] := Formatfloat('#,##0.###', dFee  / iDiv );
    Cells[1, 3] := Formatfloat('#,##0.###', (dTotPL - dFee) / iDiv  );

    if (dEntry / iDiv )= 0 then
      Objects[ Color_Col -1 , 0] := Pointer( clBlack )
    else if (dEntry / iDiv )> 0 then
      Objects[ Color_Col -1, 0] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 0] := Pointer( clBlue );

    if (dPL  / iDiv )= 0 then
      Objects[ Color_Col -1 , 1] := Pointer( clBlack )
    else if (dPL  / iDiv )> 0 then
      Objects[ Color_Col -1, 1] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 1] := Pointer( clBlue );

    if ((dTotPL - dFee)  / iDiv )= 0 then
      Objects[ Color_Col -1 , 3] := Pointer( clBlack )
    else if ((dTotPL - dFee)  / iDiv )> 0 then
      Objects[ Color_Col -1, 3] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 3] := Pointer( clBlue );
  end;

end;

procedure TFrmFundMiniPosList.RefreshBottom;
var
  i, iRow : integer;
  aFundPos : TFundPosition;
begin

  if FFund = nil then begin
    Clear(sgBottom);
    Exit;
  end;

  if cbAcnt.Checked then
  begin
    RefreshBottom2;
    Exit;
  end;

  for I := 0 to gEnv.Engine.TradeCore.FundPositions.Count - 1 do
  begin
    aFundPos  := gEnv.Engine.TradeCore.FundPositions.FundPositions[i];
    if aFundPos.Fund = FFund then
    begin
      iRow  := sgBottom.Cols[Symbol_Col].IndexOfObject( aFundPos.Symbol );
      if iRow < 0 then begin
        if (aFundPos.Volume = 0) and ( not Show0Net.Checked ) then
          Continue;
        iRow := 1;
        InsertLine( sgBottom, iRow );
      end else
      begin
        if (aFundPos.Volume = 0) and ( not Show0Net.Checked ) then begin
          DeleteLine( sgBottom, iRow );
          Continue;
        end;
      end;
      UpdateRow( iRow, aFundPos, true );
    end;
  end;
end;

procedure TFrmFundMiniPosList.RefreshBottom2;
var
  iRow, i, j : integer;
  aFundPos : TFundPosition;
  aPos : TPosition;
begin
  for I := 0 to gEnv.Engine.TradeCore.FundPositions.Count - 1 do
  begin
    aFundPos  := gEnv.Engine.TradeCore.FundPositions.FundPositions[i];
    if aFundPos.Fund = FFund then
    begin
      for j := 0 to aFundPos.Positions.Count - 1 do
      begin
        aPos  := aFundPos.Positions.Positions[j];
        iRow  := sgBottom.Cols[Symbol_Col].IndexOfObject( aPos );
        if iRow < 0 then begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then
            Continue;
          iRow := 1;
          InsertLine( sgBottom, iRow );
        end else
        begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then begin
            DeleteLine( sgBottom, iRow );
            Continue;
          end;
        end;
        UpdateRow2( iRow, aPos, true );
      end;
    end;
  end;
end;

procedure TFrmFundMiniPosList.UpdateRow( iRow : Integer; aPos : TFundPosition; bAdd : boolean );
var
  iVol : integer;
  dPrice : double;
begin
  with sgBottom do
  begin

    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ Symbol_Col, iRow ] := aPos.Symbol;

    Cells[0, iRow] := aPos.Symbol.ShortCode;
    Cells[1, iRow] := IntToStr( iVol );

    if iVol = 0 then
      Objects[ Color_Col, iRow] := Pointer( clBlack )
    else if aPos.Volume > 0 then
      Objects[ Color_Col, iRow] := Pointer( clRed )
    else
      Objects[ Color_Col, iRow] := Pointer( clBlue );

    Cells[2, iRow] := Format('%.*n', [ aPos.Symbol.Spec.Precision, dPrice ] );
  end;
end;

procedure TFrmFundMiniPosList.UpdateRow2( iRow : Integer; aPos : TPosition; bAdd : boolean );
var
  iVol : integer;
  dPrice : double;
begin
  with sgBottom do
  begin

    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ Symbol_Col, iRow ] := aPos;

    Cells[0, iRow] := aPos.Account.Code;
    Cells[1, iRow] := aPos.Symbol.ShortCode;
    Cells[2, iRow] := IntToStr( iVol );

    if iVol = 0 then
      Objects[ Color_Col, iRow] := Pointer( clBlack )
    else if aPos.Volume > 0 then
      Objects[ Color_Col, iRow] := Pointer( clRed )
    else
      Objects[ Color_Col, iRow] := Pointer( clBlue );

    Cells[3, iRow] := Format('%.*n', [ aPos.Symbol.Spec.Precision, dPrice ] );
  end;
end;




end.
