unit FleStopOrderList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls,

  CleAccounts, CleSymbols, CleStopOrders, CBoardDistributor   , CleDistributor,

  CleStorage , CleFunds,

  COBTypes
  ;

  {
    Account : TAccount;
    Symbol  : TSymbol;
    Side    : integer;
    OrdQty  : integer;
    soType  : TStopOrderType;
    Price   : double;
    TargetPrice : double;
    LastPrice   : double;
    Tick    : integer;
    Index   : integer;
    MustClear   : boolean;
    GroupID : integer;
  }
const
  Title_Cnt = 7;
  Title : array [0..Title_Cnt-1] of string = ( '종목','LS','가격','수량', '타켓','Tick','비고'  );
  Title2: array [0..Title_Cnt] of string = ('계좌','종목','LS','가격','수량', '타켓','Tick','비고'  );
  Stop_Col  = 0;
  Color_Col = 1;

type
  TFrmStopOrderList = class(TForm)
    Panel1: TPanel;
    sgStop: TStringGrid;
    cbAccount: TComboBox;
    cbAcntType: TComboBox;
    sgStop2: TStringGrid;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbAccountChange(Sender: TObject);
    procedure sgStopDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgStopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAcntTypeChange(Sender: TObject);

  private
    { Private declarations }
    FAccount  : TAccount;
    FFund     : TFund;
    FIsFund   : Boolean;
    FRow      : array [0..1] of integer;

    procedure initControls;
    procedure UpdateData( aAccount : TAccount ) ; overload;
    procedure UpdateData; overload;
    procedure UpdateStopData( aStop : TStopOrderItem );
    procedure UpdateStopLine(iRow: integer; aStop: TStopOrderItem);
    procedure OrderEventHandler(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);
    procedure OnAccount(aInvest: TInvestor; EventID: TDistributorID);
    function GetGrid: TStringGrid;
  public
    { Public declarations }
    procedure ClearGrid( aGrid : TStringGrid );
    procedure BoardEnvEventHander (Sender : TObject; DataObj: TObject;
      etType: TEventType; vtType : TValueType );
  end;

var
  FrmStopOrderList: TFrmStopOrderList;

implementation

uses
  GAppEnv, GleLib, GleConsts
  ;

{$R *.dfm}

procedure TFrmStopOrderList.BoardEnvEventHander(Sender, DataObj: TObject;
  etType: TEventType; vtType: TValueType);
  var
    pStop : TStopOrderItem;
begin
  pStop := DataObj as TStopOrderItem;

  if FIsFund then
  begin
    if FFund = nil then Exit;
    if FFund.FundItems.Find2( pStop.Account ) < 0 then Exit;
  end else
  begin
    if (pStop.Account <> FAccount ) then Exit;
  end;

  case vtType of
    vtAdd   ,
    vtDelete: UpdateStopData( pStop );
    else Exit;
  end;

end;

procedure TFrmStopOrderList.OrderEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
    ACCOUNT_NEW     ,
    ACCOUNT_DELETED ,
    ACCOUNT_UPDATED : OnAccount( DataObj as Tinvestor, EventID );
    else
      Exit;
  end;
end;

procedure TFrmStopOrderList.OnAccount(aInvest: TInvestor;
  EventID: TDistributorID);
begin
  cbAccount.Items.Clear;
  gEnv.Engine.TradeCore.Accounts.GetList3( cbAccount.Items );

  case integer( EventID ) of

    ACCOUNT_NEW , ACCOUNT_UPDATED  :
      begin
        if FAccount <> nil then
          SetComboIndex( cbAccount, FAccount )
        else
          if cbAccount.Items.Count > 0 then
          begin
            cbAccount.ItemIndex  := 0;
            cbAccountChange( nil );
          end;
      end;
    ACCOUNT_DELETED :
      if cbAccount.Items.Count > 0 then
      begin
        cbAccount.ItemIndex  := 0;
        cbAccountChange( nil );
      end
  end;
end;

procedure TFrmStopOrderList.cbAccountChange(Sender: TObject);
var
  aAcnt : TAccount;
  aFund : TFund;
begin

  if FIsFund then
  begin

    aFund := TFund( cbAccount.Items.Objects[ cbAccount.ItemIndex ]);
    if aFund = nil then Exit;
    if FFund <> aFund then
    begin
      ClearGrid( sgStop2 );
      FFund := aFund;
      UpdateData;
    end;

  end else
  begin

    aAcnt := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
    if aAcnt = nil then Exit;
    if FAccount <> aAcnt then
    begin
      ClearGrid( sgStop );
      FAccount := aAcnt;
      UpdateData;
    end;

  end;
end;

procedure TFrmStopOrderList.ClearGrid( aGrid : TStringGrid );
var
  I: integer;
begin
  with aGrid do
    for I := 1 to RowCount - 1 do
      Rows[i].Clear;

  aGrid.RowCount := 2;
  aGrid.FixedRows:= 1;
    
end;

procedure TFrmStopOrderList.cbAcntTypeChange(Sender: TObject);
var
  bIsFund, bChg : boolean;
begin
  //
  bIsFund := cbAcntType.ItemIndex = 1;

  if bIsFund = FIsFund then
    bChg := false
  else
    bChg := true;

  if not bChg then Exit;

  cbAccount.Items.Clear;

  if bIsFund then
    gEnv.Engine.TradeCore.Funds.GetList( cbAccount.Items)
  else
    gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );

  FIsFund := bIsFund;

  if cbAccount.Items.Count > 0 then begin
    if bIsFund then begin
      sgStop.Visible := false;
      sgStop2.Visible:= true;
      if FFund <> nil then
        SetComboIndex( cbAccount, FFund )
      else
        cbAccount.ItemIndex := 0;
      FFund := nil;
    end else
    begin
      sgStop.Visible := true;
      sgStop2.Visible:= false;
      if FAccount <> nil then
        SetComboIndex( cbAccount, FAccount )
      else
        cbAccount.ItemIndex := 0;
      FAccount := nil;
    end;
    cbAccountChange( nil );
  end;

end;

procedure TFrmStopOrderList.UpdateData;
var
  I: Integer;
begin
  if FIsFund then
  begin
    if FFund <> nil then
      for I := 0 to FFund.FundItems.Count - 1 do
        UpdateData( FFund.FundAccount[i] );

  end else
  begin
    if FAccount <> nil then
      Updatedata( FAccount );
  end;
end;

procedure TFrmStopOrderList.UpdateData(aAccount: TAccount);
var
  I, j: Integer;
begin
  for I := 0 to gEnv.Engine.TradeCore.StopOrders.Count - 1 do
  begin
    if gEnv.Engine.TradeCore.StopOrders.StopOrder[i].Account = aAccount then
    begin
      for j := 0 to gEnv.Engine.TradeCore.StopOrders.StopOrder[i].BidStopList.Count - 1 do
        UpdateStopData( TStopOrderItem( gEnv.Engine.TradeCore.StopOrders.StopOrder[i].BidStopList.Items[j] )  );

      for j := 0 to gEnv.Engine.TradeCore.StopOrders.StopOrder[i].AskStopList.Count - 1 do
        UpdateStopData( TStopOrderItem( gEnv.Engine.TradeCore.StopOrders.StopOrder[i].AskStopList.Items[j] ) );
    end;
  end;

end;

procedure TFrmStopOrderList.UpdateStopData(aStop: TStopOrderItem);
var
  iRow : integer;
  aGrid: TStringGrid;
begin

  if FIsFund then
    aGrid := sgStop2
  else
    aGrid := sgStop;

  case aStop.soType of
    soNone: Exit;
    soNew :
      begin
        InsertLine( aGrid, 1 );
        UpdateStopLine( 1, aStop );
      end ;
    soCancel:
      begin
        iRow  := aGrid.Cols[Stop_Col].IndexOfObject( aStop );
        if iRow > 0 then
          DeleteLine( aGrid, iRow );
      end;
  end;

end;

function TFrmStopOrderList.GetGrid : TStringGrid;
begin
  if FIsFund then
    Result := sgStop2
  else
    REsult := sgStop;
end;

procedure TFrmStopOrderList.UpdateStopLine( iRow: integer; aStop: TStopOrderItem);
var
  iCol : integer;
  stTmp : string;

begin
                       //( '종목','LS','가격','수량', '타켓','Tick','비고'  );
  iCol  := 0;
  with GetGrid do
  begin
    Objects[ Stop_Col, iRow] := aStop;
    if aStop.Side > 0  then    
      Objects[ Color_Col, iRow]:= Pointer( clRed )
    else
      Objects[ Color_Col, iRow]:= Pointer( clBlue );

    if FIsFund then begin
      Cells[iCol, iRow] := aStop.Account.Code;          inc( iCol );
    end;

    Cells[iCol, iRow] := aStop.Symbol.ShortCode;          inc( iCol );
    Cells[iCol, iRow] := ifThenStr( aStop.Side > 0 ,'L', 'S' );  inc( iCol );
    Cells[iCol, iRow] := aStop.Symbol.PriceToStr( aStop.Price );             inc( iCol );
    Cells[iCol, iRow] := IntToStr( aStop.OrdQty );      inc( iCol );
    Cells[iCol, iRow] := aStop.Symbol.PriceToStr( aStop.TargetPrice );  inc( iCol );
    Cells[iCol, iRow] := IntToStr( aStop.Tick );  inc( iCol );
    Cells[icol, iRow] := ifThenStr( aStop.GroupID > 0,'Auto', '' ); inc( iCol );
  end;
end;

procedure TFrmStopOrderList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmStopOrderList.FormCreate(Sender: TObject);
begin

  FIsFund := false;
  FAccount:= nil;
  FFund   := nil;

  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items);

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  gEnv.Engine.TradeCore.StopOrders.BoardItems.RegistCfg( Self, etStop, BoardEnvEventHander );
  gEnv.Engine.TradeBroker.Subscribe( Self, OrderEventHandler );

  initControls;

  FRow[0] := -1;
  FRow[1] := -1;
end;

procedure TFrmStopOrderList.initControls;
var
  I: integer;
begin
  with sgStop do
    for I := 0 to ColCount - 1 do
      Cells[i,0]  := Title[i];

  with sgStop2 do
    for I := 0 to ColCount-1  do
      Cells[i,0]  := Title2[i];
end;



procedure TFrmStopOrderList.sgStopDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aFont , aBack : TColor;
    stTxt : string;
    dFormat : Word;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_RIGHT;

  with ( Sender as TStringGrid ) do
  begin
    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      aBack   := clBtnFace;
      dFormat := DT_VCENTER or DT_CENTER;
    end
    else begin

      if ACol = Color_Col then
        aFont := TColor( Objects[ ACol, ARow] );

    end;

    if ARow = FRow[Tag] then
    begin
      aBack := $00F2BEB9;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;
end;

procedure TFrmStopOrderList.sgStopMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    iTag, ARow, ACol : integer;
    aGrid : TStringGrid;
begin

  aGrid := TStringGrid( Sender );
  iTag  := aGrid.Tag;

  ARow := FRow[iTag];
  aGrid.MouseToCell( x, y, ACol, FRow[iTag]);

  InvalidateRow( aGrid, ARow );
  InvalidateRow( aGrid, FRow[iTag] );

end;

procedure TFrmStopOrderList.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeCore.StopOrders.BoardItems.UnRegistCfg( Self );

end;

end.
