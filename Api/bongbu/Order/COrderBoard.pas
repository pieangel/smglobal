unit COrderBoard;

interface

uses
  Classes, StdCtrls, ExtCtrls, Grids, Controls, SysUtils, Graphics, Windows,
  Forms, Buttons, Math,  ComCtrls,  UAlignedEdit,
    // lemon: common
  GleTypes,
    // lemon: data
  CleFQN, CleSymbols, CleQuoteBroker, CleAccounts,  CleQuoteTimers,
    // lemon: trade
  ClePositions, CleOrders, COBTypes, CleStopOrders,
    // app: orderboard
  COrderTablet, CTickPainter, CHogaPainter, CleFORMOrderItems,
  DBoardParams
  ;

const
  SHORT_ST_CANCEL = -2;
  SHORT_ORD_CANCEL = -1;
  ALL_CANCEL  = 0;
  LONG_ORD_CANCEL = 1;
  LONG_ST_CANCEL = 2;

type

  TQtyState = (qsSelected, qsLong, qsShort, qsData);

  TSetSymbolEvent = procedure( aSymbol : TSymbol ) of object;
  TStandByEvent  = procedure( Sender, aControl : TObject ) of object;

  TOrderBoard = class(TCollectionItem)
  private
      // control: base panel
    FBoardPanel: TPanel;
    FTabletPanel: TPanel;

      // controls: Tablet
    FPaintBoxTablet: TPaintBox;
    FPaintLineTablet: TPaintBox;
      // controls: Volumes
    FEditOrderVolume: TEdit;
    FStaticTextClearVolume: TSpeedButton;

    FLabelTitle: TLabel;

    FSpeedButtonPrefs: TSpeedButton;

    // 가격정렬, 시장가매도, 시장가매수  --- 상단 버튼
    PriceArrange , MarketPrcSell, MarketPrcBuy : TPanel;
    // ST취소, 일괄취소, 전부취소, 일괄취소, ST취소 -- 하단 버튼
    ShortStopCnl , ShortAllCnl, {AllCnl,} LongAllCnl, LongStopCnl : TPanel;

    FStopOrderTick: TAlignedEdit;
      // new Contronl  add 2014.09.18 stop order
      {
    FStopOrderPanel : TPanel;

    FStopOrderTickVolume : TUpDown;
    FStopOrderTickTitle : TLabel;
    FUseProfitStop : TCheckBox;
    FUseLossCutStop: TCheckBox;
    FProfitVolumes : TStringGrid;
    FLossCutVolumes: TStringGrid;
    FProfitConfig: TStaticText;
    FLossCutConfig: TStaticText;
    }

    FPaintBoxTicks: TPaintBox;
      // assigned data
    FSymbol: TSymbol;
    FQuote: TQuote;
    FPosition: TPosition;
    FAccount : TAccount;

      // created objects
    FTablet: TOrderTablet;

    FTickPainter: TTickPainter;
    FHighlightTimer: TTimer;
      // config
    FSubscribed: Boolean;
    FInfoAlign: TAlign;
    FInfoVisible: Boolean;

      // status
    FTNSCount: Integer; // time & sale count

     // control
    FParams: TOrderBoardParams;

    FDefQty: Integer; // default order volume
    FQtyState: TQtyState;

    FClearOrder: Boolean;
    FClearOrderQty: Integer;
    FOrderType: TPositionType;

      // order delivery status
    FSentTime: Integer;
    FOrderSpeed: String;
    FDeliveryTime: String;

      // event
    FOnPosEvent: TObjectNotifyEvent;

    FTimer  : TTimer;
    FOrderItem : TOrderItem;

    FStopOrder : TStopOrder;

    FOnPanelClickEvent: TBoardPanelEvent;
    FDefAmt: Integer;
    FAmtState: TQtyState;

    FTmpStopList: TList;


    function GetWidth: Integer;

      // define
    procedure SetSymbol(const Value: TSymbol);
    procedure SetQuote(const Value: TQuote);
    procedure SetPosition(const Value: TPosition);

      // init
    procedure CreateControls;
    procedure SetParams(const Value: TOrderBoardParams);

      // volume click
    procedure StringGridVolumesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);


    procedure StringGridOrderVolumeSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);


      // volume hightlight
    procedure HighlightTimerProc(Sender: TObject);
    procedure SetEditOrderVolumeColor;

      // misc
    procedure StringGridMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SetAccount(const Value: TAccount);

    procedure SetStopOrder(const Value: TStopOrder);
    procedure UpdateStopOrder(aStop: TStopOrderItem);

    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
    procedure TopPanelClick(Sender: TObject);
    procedure BottomPanelClick(Sender: TObject);
    function CheckPrice(dPrc: double; iSide: integer;
      aSymbol: TSymbol): boolean;
    procedure DoAutoStop(iQty: integer; bPrf, bLos: boolean; iPrf, iLos,
      iTick: integer; pcValue: TPriceControl);


  public

    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    procedure Resize;
    procedure Resize2( iWidth : integer );
    procedure SetOrderVolume(iQty: Integer; bRefresh: Boolean);
    procedure SetClearVolume(bEnabled: Boolean);
    procedure SetPositionVolume( iDiv : integer = 1);
    procedure SetOrderVolumeToKeyBoard(iDiv: integer = 1);
    procedure CheckEditFocus( bLock : boolean );

    procedure StaticTextClearVolumeClick(Sender: TObject);
    procedure EditOrderVolumeClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);

    procedure UpdatePositionInfo;
    procedure UpdateOrderLimit;

    procedure FocusDelete( Sender : TOrderTablet; bLock : boolean );
    // autostop...
    procedure OnFillExec( bPrf, bLos : boolean; iPrf, iLos, iTick : integer; pcValue : TPriceControl);
    procedure OnFill( aOrder : TOrder;
      bPrf, bLos : boolean; iPrf, iLos, iTick : integer; pcValue : TPriceControl);

    property Params: TOrderBoardParams read FParams write SetParams;

      // define
    property Symbol: TSymbol read FSymbol write SetSymbol;
    property Quote: TQuote read FQuote write SetQuote;
    property Position: TPosition read FPosition write SetPosition;
    property Account : TAccount read FAccount write SetAccount;
    property TmpStopList : TList read FTmpStopList write FTmpStopList;

      // controls
    property PaintBoxTablet: TPaintBox read FPaintBoxTablet;
    property PaintLineTablet: TPaintBox read FPaintLineTablet;
    property EditOrderVolume: TEdit read FEditOrderVolume write FEditOrderVolume;
    property StopOrderTick  : TAlignedEdit read FStopOrderTick write FStopOrderTick;
    property StaticTextClearVolume: TSpeedButton read FStaticTextClearVolume write FStaticTextClearVolume;
    
    property SpeedButtonPrefs: TSpeedButton read FSpeedButtonPrefs;
    procedure AllCancels( iSide : integer = 0 );
    procedure AllLiquids;
      // stop
    procedure OnNewStopOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure OnStopCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure OnStopChangeOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure OnLastStopCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
      // new order or remove stop
    procedure OnStopOrderEvent( Sender : TObject;  aStop : TObject ; vtType : TValueType );
    procedure OnAutoStopOrderEvent(  Sender : TObject; aStop : TStopOrderItem; bOrder : boolean );
    procedure OnCancelStopOrderEvent ( Sender : TObject; aStop : TStopOrderItem );

    function ShowStopOrder: integer;
      // objects
    property Tablet: TOrderTablet read FTablet;
    property TickPainter: TTickPainter read FTickPainter;
    property StopOrder  : TStopOrder  read FStopOrder write SetStopOrder;

      // status
    property Subscribed: Boolean read FSubscribed write FSubscribed;
    property TNSCount: Integer read FTNSCount write FTNSCount;
    property Width: Integer read GetWidth;

      // order control
    property DefQty: Integer read FDefQty write FDefQty;
    property QtyState: TQtyState read FQtyState write FQtyState;
    property DefAmt: Integer read FDefAmt write FDefAmt;
    property AmtState: TQtyState read FAmtState write FAmtState;
    property ClearOrder: Boolean read FClearOrder write FClearOrder;
    property ClearOrderQty: Integer read FClearOrderQty write FClearOrderQty;
    property OrderType: TPositionType read FOrderType write FOrderType;

      // order delivery status
    property SentTime: Integer read FSentTime write FSentTime;
    property OrderSpeed: String read FOrderSpeed write FOrderSpeed;
    property DeliveryTime: String read FDeliveryTime write FDeliveryTime;

      // event
      {
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property OnSetup: TNotifyEvent read FOnSetup write FOnSetup;
    property OnSymbolSelect: TNotifyEvent read FOnSymbolSelect write FOnSymbolSelect;
    property OnQtySelect: TNotifyEvent read FOnQtySelect write FOnQtySelect;
    }
    property OnPanelClickEvent : TBoardPanelEvent read FOnPanelClickEvent write FOnPanelClickEvent;
    property OnPosEvent : TObjectNotifyEvent read FOnPosEvent write FOnPosEvent;
      //

  end;

  TOrderBoards = class(TCollection)
  private
    FOwnerForm: TForm;
    FPanel: TPanel;
    FTickPanel: TPanel;

    function GetBoard(i: Integer): TOrderBoard;
  public
    constructor Create(aForm: TForm; aPanel: TPanel);

    function New: TOrderBoard;
    function Find(aTablet: TOrderTablet): TOrderBoard;
    function FindPaintBox(aPaintBox: TPaintBox): TOrderBoard;

    property Boards[i: Integer]: TOrderBoard read GetBoard; default;
    property TickPanel : TPanel read FTickPanel write FTickPanel;
  end;

const
  BOARD_MIN = 300;//265;
  TNS_WIDTH = 100;
  ST_TNS_WIDTH = 130;
  HOGA_WIDTH = 175;
  ACNT_HEIGH  =  25;
  VOLUME_ROWCOUNT = 3;
  VOLUME_COLCOUNT = 4;


  
implementation

uses ClePriceItems, MMSystem, GAppEnv, GleConsts, GleLib, CleFills, CleKrxSymbols,
  FOrderBoard;

{ TOrderBoard }




procedure TOrderBoard.CheckEditFocus(bLock: boolean);
begin
  // bLock = true 이면 마우스가 테블렛 위에 있다는 야그..
  // 수량 에디트 박스에 포커스 있으면 없앤다..
  {
  if bLock then
  begin
    if FEditOrderVolume.Focused then
    begin
      FEditOrderVolume.Text := IntToStr( FDefQty );
      FEditOrderVolume.Font.Color := clBlack;
      SetFocus( FPanelVolumes.Handle );
    end;
  end
  else
  }

  if not FBoardPanel.Focused then
  begin
    SetFocus( FBoardPanel.Handle );
  end;

end;

constructor TOrderBoard.Create(Coll: TCollection);
begin
  inherited Create(Coll);

    // create controls
  CreateControls;
    // object: tablet
  FTablet := TOrderTablet.Create;
  FTablet.OnFocusDel        := FocusDelete;

  FTablet.OnNewStopOrder    := OnNewStopOrder;
  FTablet.OnCancelStopOrder := OnStopCancelOrder;
  FTablet.OnChangeStopOrder := OnStopChangeOrder;
  FTablet.OnCanelLastStopOrder  := OnLastStopCancelOrder;

  FTablet.SetButtons( MarketPrcSell, PriceArrange, MarketPrcBuy );
  FTablet.SetBottomButtons( ShortStopCnl , ShortAllCnl, LongAllCnl, LongStopCnl );
  FTablet.SetLine(FPaintLineTablet);
  FTablet.SetArea(FPaintBoxTablet);

    // object: tick painter
  FTickPainter := TTickPainter.Create;
  FTickPainter.PaintBox := FPaintBoxTicks;
  FTickPainter.RowCount := 20;
  // FTickPainter.FillQty := 1;  -- maybe needed a new version of TTickPainter
        // object: highlight timer
  FHighlightTimer := TTimer.Create(nil);
  FHighlightTimer.Interval := 500;
  FHighlightTimer.OnTimer := HighlightTimerProc;
  FHighlightTimer.Enabled := False;

    //
  FTNSCount := 0;
  
  FDefQty := 0;
  FDefAmt := 0;

  FSubscribed := False;
  FInfoVisible := True;
  FInfoAlign := alRight;

  FTmpStopList  := TList.Create;

end;

destructor TOrderBoard.Destroy;
begin
  FTmpStopList.Free;

  FHighlightTimer.Free;
  FTickPainter.Free;

  FTablet.Free;

  FBoardPanel.Free;
  inherited;
end;


procedure TOrderBoard.CreateControls;
var
  iLeft, iTop, iLen  : integer;
  I: integer;
begin
    // base panel
  FBoardPanel := TPanel.Create((Collection as TOrderBoards).FPanel);
  with FBoardPanel do
  begin
    Parent := FBoardPanel.Owner as TPanel;
    Align := alLeft;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;

      // tablet panel
  FTabletPanel := TPanel.Create(FBoardPanel);
  with FTabletPanel do
  begin
    Parent := FBoardPanel;
    Align := alClient;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;

    // tick on Info panel
  FPaintBoxTicks := TPaintBox.Create( TOrderBoards( Collection ).TickPanel   );
  FPaintBoxTicks.Parent := TOrderBoards( Collection ).TickPanel;
  FPaintBoxTicks.Align := alClient;

    // control: tablet
  FPaintBoxTablet := TPaintBox.Create(FTabletPanel);
  FPaintBoxTablet.Parent := FTabletPanel;
  FPaintBoxTablet.Align := alClient;

  FPaintLineTablet  := TPaintbox.Create( FTabletPanel);
  FPaintLineTablet.Left   := FTabletPanel.Left;
  FPaintLineTablet.Parent := FTabletPanel;
  FPaintLineTablet.BringToFront;

   //
  PriceArrange := TPanel.Create(FTabletPanel);
  MarketPrcSell:= TPanel.Create(FTabletPanel);
  MarketPrcBuy := TPanel.Create(FTabletPanel);

  with PriceArrange do
  begin
    Parent := FTabletPanel;
    Tag    := 0;
    Caption:= '정 렬';
    Color  := clBtnFace ;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := TopPanelClick;
  end;

  with MarketPrcSell do
  begin
    Parent := FTabletPanel;
    Tag    := -1;
    Caption:= '시장가매도';
    Color  := LONG_BG_COLOR ;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := TopPanelClick;

    ParentBackground := false;
    ParentColor := false;
  end;

  with MarketPrcBuy do
  begin
    Parent := FTabletPanel;
    Tag    := 1;
    Caption:= '시장가매수';
    Color  := SHORT_BG_COLOR;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := TopPanelClick;

    ParentBackground := false;
    ParentColor := false;
  end;


  ShortStopCnl  := TPanel.Create(FTabletPanel);
  ShortAllCnl   := TPanel.Create(FTabletPanel);
  //AllCnl        := TPanel.Create(FTabletPanel);
  LongAllCnl    := TPanel.Create(FTabletPanel);
  LongStopCnl   := TPanel.Create(FTabletPanel);

  with ShortStopCnl do
  begin
    Parent := FTabletPanel;
    Tag    := SHORT_ST_CANCEL;
    Caption:= 'ST취소';
    Color  := LONG_BG_COLOR ;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := BottomPanelClick;
    ParentBackground := false;
    ParentColor := false;
  end;

  with ShortAllCnl do
  begin
    Parent := FTabletPanel;
    Tag    := SHORT_ORD_CANCEL;
    Caption:= '일괄취소';
    Color  := LONG_BG_COLOR ;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := BottomPanelClick;
    ParentBackground := false;
    ParentColor := false;
  end;
           {
  with AllCnl do
  begin
    Parent := FTabletPanel;
    Tag    := ALL_CANCEL;
    Caption:= '전체취소';
    Color  := SHORT_BG_COLOR;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := BottomPanelClick;
    ParentBackground := false;
    ParentColor := false;
  end;
          }
  with LongAllCnl do
  begin
    Parent := FTabletPanel;
    Tag    := LONG_ORD_CANCEL;
    Caption:= '일괄취소';
    Color  := SHORT_BG_COLOR ;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := BottomPanelClick;
    ParentBackground := false;
    ParentColor := false;
  end;

  with LongStopCnl do
  begin
    Parent := FTabletPanel;
    Tag    := LONG_ST_CANCEL;
    Caption:= 'ST취소';
    Color  := SHORT_BG_COLOR;
    OnMouseDown  := PanelMouseDown;
    OnMouseUp    := PanelMouseUp;
    OnClick      := BottomPanelClick;
    ParentBackground := false;
    ParentColor := false;    
  end;
end;

//-------------------------------------------------------------------< define >

procedure TOrderBoard.SetPosition(const Value: TPosition);
begin
  if (FPosition <> Value) and ( Value <> nil )then

    FPosition := Value;
    // 주문가능수 요청..
    if FPosition <> nil then
      gEnv.Engine.TradeCore.InvestorPositions.ReqAbleQty( FPosition );

end;


procedure TOrderBoard.SetQuote(const Value: TQuote);
var
  aTmp : TQuote;
begin
  if Value = nil then Exit;

  aTmp := FQuote;

  FQuote := Value;
  FTablet.Quote := Value;
  FTickPainter.Quote := Value;

  if (aTmp <> Value) then
    FBoardPanel.Width := GetWidth;
end;

procedure TOrderBoard.SetStopOrder(const Value: TStopOrder);
begin

  if FStopOrder <> nil then
  begin
    FStopOrder.OnStopOrderEvent := nil;
  end;

  FStopOrder := Value;

end;

procedure TOrderBoard.SetSymbol(const Value: TSymbol);
begin
  if Value = nil then Exit;

  FSymbol := Value;
  FTablet.Symbol := Value;

end;

//-------------------------------------------------------------------< update >

procedure TOrderBoard.UpdatePositionInfo;
begin
  if FPosition = nil then
    Exit;
  FTablet.OpenPosition  := FPosition.Volume;
  FTablet.AvgPrice := FPosition.AvgPrice;
  if Assigned(OnPosEvent) then
    OnPosEvent( Self, FPosition );
end;


procedure TOrderBoard.UpdateOrderLimit;
begin
  if FPosition = nil then
  begin
    FClearOrderQty  := 0;
    SetClearVolume( false );
    Exit;
  end;

    // set clear order volume
  FClearOrderQty := FPosition.LiquidatableQty;

    // set order type
  if FClearOrderQty > 0 then
    FOrderType := ptShort
  else
    FOrderType := ptLong;

    // set control
  if FClearOrder then
  begin
    if FClearOrderQty = 0 then
    begin
      SetClearVolume(False);
      SetOrderVolume(0, False);
    end else
    begin
      SetClearVolume(True);
      SetOrderVolume(FClearOrderQty, False);
    end;
  end else
    SetClearVolume(False);
end;

procedure TOrderBoard.SetPositionVolume( iDiv : integer );
begin
  if FPosition = nil then
    Exit;

  if FPosition.Volume <> 0 then
  begin
    SetClearVolume(False);
    // set order volume
    SetOrderVolume(abs(FPosition.Volume) div iDiv,  True);
    // selection notified

  end;
end;

//----------------------------------------------------------------< dimension >

procedure TOrderBoard.Resize;
var
  iWidth : integer;
  //stTmp  : string;
begin
  iWidth := FTabletPanel.Width - FTablet.TabletWidth;
  {
  stTmp := Format( 'FTabletPanel.Width : %d   FTablet.TabletWidth : %d',
    [FTabletPanel.Width , FTablet.TabletWidth
    ]);
  gEnv.OnLog( self, stTmp );
  }
  FTablet.SetArea(FPaintBoxTablet);
end;

procedure TOrderBoard.Resize2(iWidth: integer);
begin
  FTablet.SetArea(FPaintBoxTablet);
end;

//----------------------------------------------------------< board selection >


//-------------------------------------------------------------------< params >

procedure TOrderBoard.SetParams(const Value: TOrderBoardParams);
var
  i: Integer;
  aList : TList;
  iQtyCount : Integer;
  iWidth, iLWidth, iRWidth : Integer ;
  aSideType : TSideType ;
  aPositionType : TPositionType ;
  bChangeOwnerOrderTrace, bChangeShowOrderData, bChangeForceDist : boolean;
  aOrder : TOrder;
  bSend : boolean;
begin

  FParams := Value;

  with FParams do
  begin
    FTablet.ORDER_WIDTH := OrdWid;
    FTablet.DEFAULT_HEIGHT := OrdHigh;  

    FTablet.ColWidths[ tcOrder ] := OrdWid;
  end;
    // set columns
  FTablet.MakeColumns(True);
  FTablet.MakeTable;

    //-- 현재가/호가 index -> No draw
  FTablet.UpdatePrice(False);
  FTablet.UpdateQuote(False);

  FTablet.ScrollToLastPrice;
  FTablet.SetArea(FPaintBoxTablet);
    // set width
  FBoardPanel.Width := GetWidth;

  bSend := false;
  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    if (aOrder.State = osActive)
       and (aOrder.Account = Account)
       and (aOrder.Symbol = Symbol) then
       begin
        Tablet.DoOrder2(aOrder);
        bSend := true;
       end;
  end;

  ShowStopOrder;

  if bSend then
    Tablet.RefreshTable;

end;

procedure TOrderBoard.AllLiquids;
var
  aTicket : TOrderTicket;
  aOrder  : TOrder;
begin
  if FPosition = nil then Exit;

  if (FPosition.Volume <> 0 ) then begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                gEnv.ConConfig.UserID, FPosition.Account, FPosition.Symbol,
                -FPosition.Volume, pcMarket, 0.0, tmGTC, aTicket);  //
    if aOrder <> nil then    
      gEnv.Engine.TradeBroker.Send(aTicket);
  end;
end;

procedure TOrderBoard.AllCancels( iSide : integer );
var
  bOK : boolean;
begin

  FOrderItem := gEnv.Engine.FormManager.OrderItems.Find( FAccount, FSymbol );
  if FOrderItem = nil then
    Exit;

  bOK := gEnv.Engine.FormManager.DoCancels( FOrderItem, iSide );

end;


//---------------------------------------------------------------< set volume >

procedure TOrderBoard.SetOrderVolume(iQty: Integer; bRefresh: Boolean);
var
  iOrderQty: Integer;
begin
  iOrderQty := StrToIntDef(FEditOrderVolume.Text, 0);

  if bRefresh or (iOrderQty <> iQty) then
  begin
      // highlited state
    FQtyState := qsSelected;

      // default order volume
    FDefQty := Abs(iQty);

      // set the volume to the edit box
    //FEditOrderVolume.Text := IntToStr(FDefQty);
    FEditOrderVolume.Text := FormatFloat('#,##0', FDefQty);
    SetEditOrderVolumeColor;

      // start the highlight timer
    if FHighlightTimer.Enabled then
      FHighlightTimer.Enabled := False;

    FHighlightTimer.Enabled := True;
  end;
end;


procedure TOrderBoard.SetAccount(const Value: TAccount);
begin
  FAccount := Value;
  FTablet.Account := FAccount;
end;


procedure TOrderBoard.SetClearVolume(bEnabled: Boolean);
begin
    //
  FClearOrder := bEnabled;
    // set clear order volume
  //FStaticTextClearVolume.Caption := IntToStr(FClearOrderQty);
  FStaticTextClearVolume.Caption := '잔고('+FormatFloat('#,##0', FClearOrderQty)+')';
  FStaticTextClearVolume.Tag     := FClearOrderQty;
    // color

  if (FClearOrderQty > 0)then begin
    FStaticTextClearVolume.Font.Color := clRed;
    //FStaticTextClearVolume.Color := clRed;
  end
  else if (FClearOrderQty < 0)  then begin
    FStaticTextClearVolume.Font.Color := clBlue;
    //FStaticTextClearVolume.Color := clBlue;
  end
  else if FClearOrderQty = 0 then begin
    FStaticTextClearVolume.Font.Color := clBlack;
    //FStaticTextClearVolume.Color := clBtnFace;
  end;
end;

//---------------------------------------------------------< volume selection >

//
//  order volume selected from the volume list
//
procedure TOrderBoard.StringGridVolumesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  iNum : Integer;
  aGrid : TStringGrid;
begin
  aGrid := TStringGrid( Sender );
    // reset clear order flat
  SetClearVolume(False);

    // set order volume
  SetOrderVolume(StrToIntDef(aGrid.Cells[aCol, aRow], 0),  True);

    // selection notified

end;

procedure TOrderBoard.TopPanelClick(Sender: TObject);
begin
  case (Sender as TPanel).Tag of
   0  : FTablet.ScrollToLastPrice;
   else begin
    if Assigned( FOnPanelClickEvent ) then
      FOnPanelClickEvent( Self, 1, (Sender as TPanel).Tag);
   end;

  end;
end;

procedure TOrderBoard.BottomPanelClick(Sender: TObject);
begin
  case (Sender as TPanel).Tag of
    SHORT_ST_CANCEL   : if FStopOrder <> nil then FStopOrder.Cancel(-1) ; //= -2;
    1,0,-1  :  AllCancels( (Sender as TPanel).Tag );
    LONG_ST_CANCEL    : if FStopOrder <> nil then FStopOrder.Cancel(1); // = 2;
  end;     
end;

procedure TOrderBoard.PanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvLowered;
end;

procedure TOrderBoard.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvRaised;
end;

//
// the order volume clicked
//
procedure TOrderBoard.StringGridOrderVolumeSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SetClearVolume(False);
end;

procedure TOrderBoard.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
  else begin
    {
    if (Sender as TEdit ).Tag = 0 then
    begin
      SetClearVolume(False);
      SetOrderVolume(StrToIntDef(FEditOrderVolume.Text , 0),  True);
    end;
    }
  end;

end;

procedure TOrderBoard.EditOrderVolumeClick(Sender: TObject);
begin

  SetClearVolume(False);

    // selection notified

end;

procedure TOrderBoard.FocusDelete(Sender: TOrderTablet; bLock: boolean);
begin
  if FTablet = Sender then
    CheckEditFocus( bLock );

end;


function TOrderBoard.GetWidth: Integer;
begin

  Result := FTablet.TabletWidth;//+ iTNS ;
    //
  if FSymbol = nil then
    Result := Max(BOARD_MIN, Result);
end;

//
// the clear order volume clicked
//


procedure TOrderBoard.StaticTextClearVolumeClick(Sender: TObject);
begin
  if FStaticTextClearVolume.Tag = 0 then Exit;

    //
  //FStaticTextClearVolume.SetFocus;
  if FClearOrder then
    SetClearVolume(not FClearOrder);

    // set order volume as clear order volume
  SetOrderVolume(FClearOrderQty, True);

    // selection notified

end;

procedure TOrderBoard.SetOrderVolumeToKeyBoard( iDiv : integer );
begin
  //if FStaticTextClearVolume.Caption = '0' then Exit;
  if FStaticTextClearVolume.Tag = 0 then Exit;

    //
  //FStaticTextClearVolume.SetFocus;
  if FClearOrder then
    SetClearVolume(not FClearOrder);

    // set order volume as clear order volume
  SetOrderVolume(FClearOrderQty div iDiv, True);

    // selection notified

end;


//---------------------------------------------------------< volume list setup>

//
// configure order volume list
//



//--------------------------------------------------------< volume hightlight >

procedure TOrderBoard.HighlightTimerProc(Sender: TObject);
begin
    // set state
  if FClearOrder then
    begin
      if FOrderType = ptLong then
        FQtyState := qsLong   // clear order - long
      else
        FQtyState := qsShort  // clear order - short
    end
  else
    FQtyState  := qsData;      // normal

    // set color accordingly
  SetEditOrderVolumeColor;

    // stop timer
  FHighlightTimer.Enabled := False;
end;


procedure TOrderBoard.OnAutoStopOrderEvent(Sender: TObject;
  aStop: TStopOrderItem; bOrder: boolean);
begin

end;

procedure TOrderBoard.OnCancelStopOrderEvent(Sender: TObject;
  aStop: TStopOrderItem);
begin

end;



procedure TOrderBoard.OnLastStopCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
begin
  FStopOrder.LastStopCancel;
end;

function TOrderBoard.CheckPrice( dPrc : double; iSide : integer; aSymbol : TSymbol ) : boolean;
begin
  Result := false;

  if dPrc < EPSILON then Exit;
  if ( aSymbol.TabletHigh < dPrc ) or ( aSymbol.TabletLow > dPrc ) then Exit;

  Result := true;
end;


procedure TOrderBoard.DoAutoStop( iQty: integer;
  bPrf, bLos : boolean; iPrf, iLos, iTick : integer; pcValue : TPriceControl );
  var

    iGroupID, iIncQty , iPrfQty, iLosQty : integer;
    dAvgPrc, dPrfPrc, dLosPrc: double;
    iSide, idx     : integer;
    bPrfcnl, bLoscnl : boolean;
    aStop : TStopOrderItem;
    stLog : string;

begin
  // 가격 구하기
  dAvgPrc := FTablet.GetTickValue( FPosition.Symbol.Spec.Market, FPosition.AvgPrice );

  if FPosition.Volume > 0 then begin
    dLosPrc := TicksFromPrice(FPosition.Symbol, dAvgPrc, -iLos); // dAvgPrc  - ( FPosition.Symbol.Spec.TickSize * iLos );
    dPrfPrc := TicksFromPrice(FPosition.Symbol, dAvgPrc, iPrf); //dAvgPrc  + ( FPosition.Symbol.Spec.TickSize * iPrf );
    iSide   := -1;
  end
  else if FPosition.Volume < 0 then begin
    dPrfPrc := TicksFromPrice(FPosition.Symbol, dAvgPrc, -iPrf); //dAvgPrc  - ( FPosition.Symbol.Spec.TickSize * iPrf );
    dLosPrc := TicksFromPrice(FPosition.Symbol, dAvgPrc, iLos); // dAvgPrc  + ( FPosition.Symbol.Spec.TickSize * iLos );
    iSide   := 1;
  end else Exit;

  if not CheckPrice( dLosPrc, iSide, FPosition.Symbol ) then begin
    gEnv.EnvLog( WIN_DEFORD, Format( '%s %s %s 손실 Auto Stop 가격 오류 -> avg :%s, %s, %d', [
      FPosition.Account.Code, FPosition.Symbol.ShortCode,
      ifThenStr( iSide > 0 ,'매수','매도'), FPosition.Symbol.PriceToStr( dAvgPrc ),
      FPosition.Symbol.PriceToStr( dLosPrc ), iLos
      ])   );
    Exit;
  end;
  if not CheckPrice( dPrfPrc, iSide, FPosition.Symbol ) then begin
    gEnv.EnvLog( WIN_DEFORD, Format( '%s %s %s 이익 Auto Stop 가격 오류 -> avg :%s, %s, %d', [
      FPosition.Account.Code, FPosition.Symbol.ShortCode,
      ifThenStr( iSide > 0 ,'매수','매도'), FPosition.Symbol.PriceToStr( dAvgPrc ),
      FPosition.Symbol.PriceToStr( dPrfPrc ), iPrf
      ])   );
    Exit;
  end;

  ///////////////////////////////////////////////////
  ///
  ///  수량구하기
  iIncQty := 0;
  iPrfQty := 0;
  iLosQty := 0;

  bPrfcnl := false; bLoscnl:= false;

  // 익절 수량 구하기
  if ( FStopOrder.PrfStop <> nil ) and ( FStopOrder.PrfStop.Side = iSide ) and ( FStopOrder.PrfStop.soType = soNew ) then begin
    iIncQty := FStopOrder.PrfStop.OrdQty;
    bPrfcnl := true;
  end
  else
    iIncQty := 0;

  iPrfQty := iQty + iIncQty;
  if iPrfQty > abs( FPosition.Volume ) then
    iPrfQty :=  abs( FPosition.Volume );

  // 손절 수량 구하기

  iIncQty := 0;
  if ( FStopOrder.LosStop <> nil ) and ( FStopOrder.LosStop.Side = iSide ) and ( FStopOrder.LosStop.soType = soNew ) then begin
    iIncQty := FStopOrder.LosStop.OrdQty;
    bLoscnl := true;
  end
  else
    iIncQty := 0;

  iLosQty := iQty + iIncQty;
  if iLosQty > abs( FPosition.Volume ) then
    iLosQty :=  abs( FPosition.Volume );

  //iQty  := Max( iLosQty, iPrfQty );

  stLog := Format('%s %s 수량  losQty:%d, prfQty:%d (설정Tcik %d, %d )  --> %d, %d', [
    FPosition.Account.Name, FPosition.Symbol.ShortCode, iLosQty, iPrfQty, iLos, iPrf,
    iQty, FPosition.Volume ]);
  gLog.Add( lkKeyOrder,'TOrderBoard','OnFill', stLog );
  ///////////////////////////////////////////////////////////////

  iGroupID := gEnv.GetStopGroupID;

  // 이익 스탑 주문
  if bPrf then
  begin
    if bPrfcnl  then
    begin
      FStopOrder.Cancel( FStopOrder.PrfStop );
      FStopOrder.PrfStop := nil;
    end;

    iQty  := iPrfQty;
    aStop := FStopOrder.New( FAccount, FSymbol, iSide, iQty, iTick, dPrfPrc );

    if aStop <> nil then
    begin
      aStop.pcValue := pcValue;
      aStop.GroupID := iGroupID;
      aStop.Index   := FTablet.GetIndex( dPrfPrc );
      aStop.MustClear := true;

      FStopOrder.BroadCast( etStop, vtAdd, aStop);

      stLog :=   Format( 'New 이익 Auto Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
      [
        aStop.Symbol.code,
        ifThenStr(  aStop.Side > 0, '매도', '매수' ),
        aStop.Symbol.PriceToStr( aStop.Price ),
        aStop.OrdQty,
        aStop.Tick,
        aStop.Index,
        aStop.Symbol.PriceToStr(aStop.TargetPrice ),
        ifThenStr( aStop.Side > 0,  IntToStr( StopOrder.BidStopList.Count-1)
          , IntToStr( StopOrder.AskStopList.Count-1) )
      ]);
      gLog.Add( lkKeyOrder,'TOrderBoard','OnFill', stLog );
    end;
    FStopOrder.PrfStop := aStop;
  end;
  /////////////////////////////////////////////////////////////////////
  // 손실 스탑 주문
  if bLos then
  begin

    if bLoscnl then
    begin
      FStopOrder.Cancel( FStopOrder.LosStop );
      FStopOrder.LosStop := nil;
    end;
    iQty  := iLosQty;
    aStop := FStopOrder.New( FAccount, FSymbol, iSide, iQty, iTick, dLosPrc );

    if aStop <> nil then
    begin
      aStop.pcValue := pcValue;
      aStop.GroupID := iGroupID;
      aStop.Index   := FTablet.GetIndex( dLosPrc );
      aStop.MustClear := true;

      FStopOrder.BroadCast( etStop, vtAdd, aStop);

      stLog :=   Format( 'New 손실 Auto Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
      [
        aStop.Symbol.code,
        ifThenStr(  aStop.Side > 0, '매도', '매수' ),
        aStop.Symbol.PriceToStr( aStop.Price ),
        aStop.OrdQty,
        aStop.Tick,
        aStop.Index,
        aStop.Symbol.PriceToStr(aStop.TargetPrice ),
        ifThenStr( aStop.Side > 0,  IntToStr( StopOrder.BidStopList.Count-1)
          , IntToStr( StopOrder.AskStopList.Count-1) )
      ]);
      gLog.Add( lkKeyOrder,'TOrderBoard','OnFill', stLog );
    end;
    FStopOrder.LosStop := aStop;
  end;
end;

procedure TOrderBoard.OnFill(aOrder: TOrder;
   bPrf, bLos : boolean; iPrf, iLos, iTick : integer; pcValue : TPriceControl);
  var
    aFill : TFill;
begin

  if ( FPosition = nil ) or ( FPosition.Volume = 0 ) then Exit;
    // 반대 포지션 체결은 패스...
  if ( FPosition.Side + aOrder.Side ) = 0 then Exit;
  if ( not bPrf ) and ( not bLos ) then Exit;

  aFill := TFill( aOrder.Fills.Last );
  DoAutoStop( abs( aFill.Volume ), bPrf, bLos, iPrf, iLos, iTick, pcValue );

end;

procedure TOrderBoard.OnFillExec(bPrf, bLos: boolean; iPrf, iLos,
  iTick: integer; pcValue: TPriceControl);
begin
  if ( FPosition = nil ) or ( FPosition.Volume = 0 ) then Exit;
  if ( not bPrf ) and ( not bLos ) then Exit;
  DoAutoStop( abs( FPosition.Volume ), bPrf, bLos, iPrf, iLos, iTick, pcValue );
end;

procedure TOrderBoard.OnNewStopOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
  var
    iSide, iTick, iQty : integer;
    aStop : TStopOrderItem;
    aOwner : TOrderBoardForm;
    stLog  : string;
    bRes   : boolean;
begin
  if (Sender = nil) or (FTablet <> Sender ) then Exit;
  if ( FAccount = nil ) or ( FSymbol = nil ) then Exit;

  if ((aPoint1.Price + PRICE_EPSILON) < FTablet.LowLimit ) or
   ((aPoint1.Price - PRICE_EPSILON ) > FTablet.HighLimit ) then
  begin
    Exit;
  end;

  if FDefQty <= 0 then
    Exit;
  aOwner := (Collection as TOrderBoards).FOwnerForm as TOrderBoardForm;

  iTick := StrToIntDef( FStopOrderTick.Text, 0 );
  {
  if FTablet.StopChange then
    iQty := FTablet.StopChangeQty
  else
  }
  iQty := FDefQty;

  aStop := FStopOrder.New( FAccount, FSymbol, ifThen( aPoint1.PositionType = ptLong, 1, -1),
    iQty, iTick, aPoint1.Price );

  if aStop = nil then Exit;
  aStop.Index := aPoint1.Index;;

  FStopOrder.BroadCast( etStop, vtAdd, aStop);

  stLog :=   Format( 'New Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
  [

    aStop.Symbol.code,
    ifThenStr(  aStop.Side < 0, '매도', '매수' ),
    aStop.Symbol.PriceToStr( aStop.Price ),
    aStop.OrdQty,
    aStop.Tick,
    aStop.Index,
    aStop.Symbol.PriceToStr(aStop.TargetPrice ),
    ifThenStr( aStop.Side > 0,  IntToStr( StopOrder.BidStopList.Count-1)
      , IntToStr( StopOrder.AskStopList.Count-1) )
  ]);
  gLog.Add( lkKeyOrder,'TOrderBoard','OnNewStopOrder', stLog );

end;

procedure TOrderBoard.OnStopCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  I: Integer;
  aStop, aStop2 : TStopOrderItem;
begin
  //
  FTmpStopList.Clear;

  if Tablet.GetStopOrders( aPoint1, FTmpStopList ) = 0 then Exit;

  aStop2 := nil;
  for I := 0 to FTmpStopList.Count - 1 do
  begin
    aStop := TStopOrderItem( FTmpStopList.Items[i] );
    if aStop.MustClear then
      aStop2 := FStopOrder.FindStopOrder( aStop );

    if aStop2 <> nil then
      FStopOrder.Cancel( aStop2 );

    FStopORder.Cancel( aStop);
  end;
                              {
  FStopOrder.Cancel( FSymbol, aPoint1.Price,
    ifThen( aPoint1.PositionType = ptLong, 1, -1 ));
                              }
end;

procedure TOrderBoard.OnStopChangeOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
begin
           {
  if ((aPoint2.Price + PRICE_EPSILON) < FSymbol.RealLowerLimit ) or
   ((aPoint2.Price - PRICE_EPSILON ) > FSymbol.RealUpperLimit ) then
  begin
    gLog.Add( lkKeyOrder,'TOrderBoard','OnNewStopOrder',
      Format('가격이상 으로 스탑주문 정정 불가 -> %.2f, 상 : %.2f, 하 : %.2f',
        [ aPoint2.Price,   FSymbol.RealLowerLimit , FSymbol.RealUpperLimit ])
       );
    Exit;
  end;
           }
  FStopOrder.Change( FSymbol, aPoint1.Price, aPoint2.Price,
    aPoint2.Index, ifThen( aPoint1.PositionType = ptLong, 1, -1 ));
end;

procedure TOrderBoard.OnStopOrderEvent(Sender, aStop: TObject;
  vtType: TValueType);
var
  aColl : TOrderBoardForm;
  pStop : TStopOrderItem;
begin
  aColl := ( Collection as TOrderBoards).FOwnerForm as TOrderBoardForm;
  if Sender <> aColl then Exit;

  pStop := aStop as TStopOrderItem;

  if (pStop.Account <> FAccount ) or ( pStop.Symbol <> FSymbol ) then Exit;

  case vtType of
    vtAdd   : UpdateStopOrder( pStop );
    vtDelete: UpdateStopOrder( pStop );
    else Exit;
  end;
end;

function TOrderBoard.ShowStopOrder : integer;
var
  I: Integer;
  aStop : TStopOrderItem;
begin

  Result := 0;
  if FStopOrder = nil then Exit;

  for I := 0 to FStopOrder.AskStopList.Count - 1 do
  begin
    aStop := TStopOrderItem( FStopORder.AskStopList.Items[i] );
    FTablet.DoStopOrderEvent( aStop );
    inc( Result );
  end;

  for I := 0 to FStopOrder.BidStopList.Count - 1 do
  begin
    aStop := TStopOrderItem( FStopORder.BidStopList.Items[i] );
    FTablet.DoStopOrderEvent( aStop );
    inc( Result );
  end;
end;

procedure TOrderBoard.UpdateStopOrder( aStop : TStopOrderItem );
begin
  FTablet.DoStopOrderEvent( aStop );
end;

//---------------------------------------------------------------------< draw >

procedure TOrderBoard.SetEditOrderVolumeColor;
var
  stValue: String;
begin
  stValue := FEditOrderVolume.Text;

  case FQtyState of
    qsSelected :
      begin
        FEditOrderVolume.Font.Color := clWhite;
        FEditOrderVolume.Color := clBlue ;
      end;
    qsLong :
      begin
        if CompareStr(Trim(stValue), '0') = 0  then
        begin
          FEditOrderVolume.Font.Color := clBlack;
          FEditOrderVolume.Color := clYellow;
        end else
        begin
          FEditOrderVolume.Font.Color := clBlack;
          FEditOrderVolume.Color := $FF9090 ;
        end;
      end;
    qsShort :
      begin
        if CompareStr(Trim(stValue), '0') = 0 then
        begin
          FEditOrderVolume.Font.Color := clBlack;
          FEditOrderVolume.Color := clYellow;
        end else
        begin
          FEditOrderVolume.Font.Color := clBlack;
          FEditOrderVolume.Color := $9090FF;
        end;
      end;
    qsData :
      begin
        FEditOrderVolume.Font.Color := clBlack;
        FEditOrderVolume.Color := clWhite;
      end;
  end;
end;



//---------------------------------------------------------------------< misc >

procedure TOrderBoard.StringGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TOrderBoard.StringGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;


//============================================================================//
                          { TOrderBoards }

//---------------------------------------------------------------------< init >

constructor TOrderBoards.Create(aForm: TForm; aPanel: TPanel);
begin
  inherited Create(TOrderBoard);

  FOwnerForm := aForm;
  FPanel := aPanel;
end;

//----------------------------------------------------------------------< new >

function TOrderBoards.New: TOrderBoard;
begin
  Result := Add as TOrderBoard;
end;

//---------------------------------------------------------------------< find >

function TOrderBoards.Find(aTablet: TOrderTablet): TOrderBoard;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TOrderBoard).FTablet = aTablet then
    begin
      Result := Items[i] as TOrderBoard;
      Break;
    end;
end;

function TOrderBoards.FindPaintBox(aPaintBox: TPaintBox): TOrderBoard;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TOrderBoard).FPaintBoxTablet = aPaintBox then
    begin
      Result := Items[i] as TOrderBoard;
      Break;
    end;
end;

//---------------------------------------------------------------------< misc >

function TOrderBoards.GetBoard(i: Integer): TOrderBoard;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TOrderBoard
  else
    Result := nil;
end;

end.


