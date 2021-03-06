unit CFundOrderBoard;

interface

uses
  Classes, StdCtrls, ExtCtrls, Grids, Controls, SysUtils, Graphics, Windows,
  Forms, Buttons, Math, ComCtrls, UAlignedEdit,  CleTrailingStops,
    // lemon: common
  GleTypes,
    // lemon: data
  CleFQN, CleSymbols, CleQuoteBroker, CleAccounts,  CleQuoteTimers,
    // lemon: trade
  ClePositions, CleOrders, COBTypes, CleStopOrders,  CleFunds, 
    // app: orderboard
  COrderTablet, CTickPainter, CHogaPainter, CleFORMOrderItems,
  DBoardParams   ,

  GR32_Image
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

  TFundOrderBoard = class(TCollectionItem)
  private
      // control: base panel
    FBoardPanel: TPanel;
    FTabletPanel: TPanel;

      // controls: Tablet
    FPaintBoxTablet: TPaintBox;
      // controls: Volumes
    FEditOrderVolume: TEdit;
    FStaticTextClearVolume: TSpeedButton;
    

    FLabelTitle: TLabel;

    FSpeedButtonPrefs: TSpeedButton;

    // 가격정렬, 시장가매도, 시장가매수  --- 상단 버튼
    PriceArrange , MarketPrcSell, MarketPrcBuy : TPanel;
    // ST취소, 일괄취소, 전부취소, 일괄취소, ST취소 -- 하단 버튼
    ShortStopCnl , ShortAllCnl, LongAllCnl, LongStopCnl : TPanel;

    FStopOrderTick: TAlignedEdit;
    FPaintBoxTicks: TPaintBox;
      // assigned data
    FSymbol: TSymbol;
    FQuote: TQuote;
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
    FPartClearQty : integer;
    FOrderType: TPositionType;

      // order delivery status
    FSentTime: Integer;
    FOrderSpeed: String;
    FDeliveryTime: String;

      // event
    FOnPosEvent: TObjectNotifyEvent;

    FTimer  : TTimer;
    FOrderItem : TOrderItem;

    FOnPanelClickEvent: TBoardPanelEvent;
    FDefAmt: Integer;
    FAmtState: TQtyState;
    FFund: TFund;
    FFundPosition: TFundPosition;
    FTmpStopList: TList;
    FPartClearVolume: TSpeedButton;
    FPartOrderQty: Integer;
    FImgStop: array [0..3] of TImage32;
    FImgLine: TImage32;
    FTrailingStop: TTrailingStop;


    function GetWidth: Integer;

      // define
    procedure SetSymbol(const Value: TSymbol);
    procedure SetQuote(const Value: TQuote);
    procedure SetPosition(const Value: TFundPosition);

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
    procedure UpdateStopOrder(aStop: TStopOrderItem);

    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
    procedure TopPanelClick(Sender: TObject);
    procedure BottomPanelClick(Sender: TObject);
    procedure SetFundPosition(const Value: TFundPosition);
    function CheckPrice(dPrc: double; iSide: integer;
      aSymbol: TSymbol): boolean;
    procedure DoAutoStop(aPos : TPosition; iQty : integer; bPrf, bLos: boolean; iPrf, iLos,
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

    // trailing stop
    procedure OnTrailingStop( bStart : boolean );
    procedure OnTrailingStopEvent(Sender: TObject; Value : boolean );
    procedure OnTTrailingStopMessage( Sender : TObject; iMax, iCalc : integer; dStopPrc : double );

    property Params: TOrderBoardParams read FParams write SetParams;
      // define
    property Symbol: TSymbol read FSymbol write SetSymbol;
    property Quote: TQuote read FQuote write SetQuote;
    property Fund    : TFund    read FFund    write FFund;
    property FundPosition: TFundPosition read FFundPosition write SetFundPosition;
    property TmpStopList : TList read FTmpStopList write FTmpStopList;

      // controls
    property PaintBoxTablet: TPaintBox read FPaintBoxTablet;
    property ImgLine: TImage32 read FImgLine;

    property EditOrderVolume: TEdit read FEditOrderVolume write FEditOrderVolume;
    property StopOrderTick  : TAlignedEdit read FStopOrderTick write FStopOrderTick;
    property StaticTextClearVolume: TSpeedButton read FStaticTextClearVolume write FStaticTextClearVolume;
    property PartClearVolume: TSpeedButton read FPartClearVolume write FPartClearVolume;

    property SpeedButtonPrefs: TSpeedButton read FSpeedButtonPrefs;
    procedure AllCancels( iSide : integer = 0 );
    procedure AllLiquids;
    procedure StopAllCancels( iSide : integer );
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
    property TrailingStop : TTrailingStop read FTrailingStop;
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
    property PartOrderQty: Integer read FPartOrderQty write FPartOrderQty;
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

  TFundOrderBoards = class(TCollection)
  private
    FOwnerForm: TForm;
    FPanel: TPanel;
    FTickPanel: TPanel;

    function GetBoard(i: Integer): TFundOrderBoard;
  public
    constructor Create(aForm: TForm; aPanel: TPanel);

    function New: TFundOrderBoard;
    function Find(aTablet: TOrderTablet): TFundOrderBoard;
    function FindPaintBox(aPaintBox: TPaintBox): TFundOrderBoard;

    property Boards[i: Integer]: TFundOrderBoard read GetBoard; default;
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

uses ClePriceItems, MMSystem, GAppEnv, GleConsts, GleLib,  CleFills,
  FFundOrderBoard,  FOrpMain,
  GR32;

{ TFundOrderBoard }


procedure TFundOrderBoard.CheckEditFocus(bLock: boolean);
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

constructor TFundOrderBoard.Create(Coll: TCollection);
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
  FTablet.SetLine(FImgStop);
  FTablet.SetLine2( FImgLine );
  FTablet.SetArea(FPaintBoxTablet);

  FTrailingStop:= TTrailingStop.Create( gEnv.Engine.TradeCore.TrdStops );

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

  FTmpStopList:= TList.Create;

end;

destructor TFundOrderBoard.Destroy;
begin

  FTmpStopList.Free;
  FHighlightTimer.Free;
  FTickPainter.Free;

  FTablet.Free;
  FBoardPanel.Free;
  FTrailingStop.Free;
  inherited;
end;


procedure TFundOrderBoard.DoAutoStop(aPos : TPosition; iQty: integer; bPrf, bLos: boolean; iPrf,
  iLos, iTick: integer; pcValue: TPriceControl);
var

    iIncQty, iGroupID, iSide  : integer;
    iPrfQty, iLosQty : integer;
    dAvgPrc, dPrfPrc, dLosPrc: double;

    bPrfcnl, bLoscnl : boolean;
    aStopOrder : TStopOrder;
    aStop : TStopOrderItem;
    stLog : string;
begin

  if aPos.AvgPrice < EPSILON then Exit;

  dAvgPrc := Round( aPos.AvgPrice / aPos.Symbol.Spec.TickSize + EPSILON) *
                  aPos.Symbol.Spec.TickSize;

  if aPos.Volume > 0 then begin
    dLosPrc := dAvgPrc  - ( aPos.Symbol.Spec.TickSize * iLos );
    dPrfPrc := dAvgPrc  + ( aPos.Symbol.Spec.TickSize * iPrf );
    iSide   := -1;
  end
  else begin
    dPrfPrc := dAvgPrc  - ( aPos.Symbol.Spec.TickSize * iPrf );
    dLosPrc := dAvgPrc  + ( aPos.Symbol.Spec.TickSize * iLos );
    iSide   := 1;
  end;

  if not CheckPrice( dLosPrc, iSide, aPos.Symbol ) then begin
    gEnv.EnvLog( WIN_FUNDORD, Format( '%s %s %s 손실 Auto Stop 가격 오류 -> avg :%s, %s, %d', [
      FFund.Name,  FFundPosition.Symbol.ShortCode,
      ifThenStr( iSide > 0 ,'매수','매도'), aPos.Symbol.PriceToStr( dAvgPrc ),
      aPos.Symbol.PriceToStr( dLosPrc ), iLos
      ])   );
    Exit;
  end;
  if not CheckPrice( dPrfPrc, iSide, aPos.Symbol ) then begin
    gEnv.EnvLog( WIN_FUNDORD, Format( '%s %s %s 이익 Auto Stop 가격 오류 -> avg :%s, %s, %d', [
      FFund.Name,  FFundPosition.Symbol.ShortCode,
      ifThenStr( iSide > 0 ,'매수','매도'), aPos.Symbol.PriceToStr( dAvgPrc ),
      aPos.Symbol.PriceToStr( dPrfPrc ), iPrf
      ])   );
    Exit;
  end;

  iIncQty := 0;
  iPrfQty := 0;
  iLosQty := 0;

  bPrfcnl := false; bLoscnl:= false;

  aStopOrder := gEnv.Engine.TradeCore.StopOrders.Find(aPos.Account, aPos.Symbol );
  if aStopORder = nil then exit;

  // 익절 수량 구하기
  if ( aStopOrder.PrfStop <> nil ) and ( aStopOrder.PrfStop.Side = iSide ) and ( aStopOrder.PrfStop.soType = soNew ) then begin
    iIncQty := aStopOrder.PrfStop.OrdQty;
    bPrfcnl := true;
  end
  else
    iIncQty := 0;

  iPrfQty := iQty + iIncQty;
  if iPrfQty > abs( aPos.Volume ) then
    iPrfQty :=  abs( aPos.Volume );

  // 손절 수량 구하기
  iIncQty := 0;
  if ( aStopOrder.LosStop <> nil ) and ( aStopOrder.LosStop.Side = iSide ) and ( aStopOrder.LosStop.soType = soNew ) then begin
    iIncQty := aStopOrder.LosStop.OrdQty;
    bLoscnl := true;
  end
  else
    iIncQty := 0;

  iLosQty := iQty + iIncQty;
  if iLosQty > abs( aPos.Volume ) then
    iLosQty :=  abs( aPos.Volume );

  stLog := Format('%s %s 수량  losQty:%d, prfQty:%d (설정Tcik %d, %d )  --> %d, %d', [
    FFund.Name, aPos.Symbol.ShortCode, iLosQty, iPrfQty, iLos, iPrf,
    iQty, aPos.Volume ]);
  gLog.Add( lkKeyOrder,'TOrderBoard','OnFill', stLog );

  /////////////////////////////////////////////////////////////////////
  // 이익 스탑 주문
  iGroupID := gEnv.GetStopGroupID;
  if bPrf then
  begin
    if bPrfcnl then begin
      aStopOrder.Cancel( aStopOrder.PrfStop );
      aStopOrder.PrfStop := nil;
    end ;

    iQty  := iPrfQty;
    aStop := aStopOrder.New( aPos.Account, aPos.Symbol, iSide, iQty, iTick, dPrfPrc );

    if aStop <> nil then
    begin
      aStop.pcValue := pcValue;
      aStop.GroupID := iGroupID;
      aStop.Index   := FTablet.GetIndex( dPrfPrc );
      aStop.MustClear := true;

      aStopOrder.BroadCast( etStop, vtAdd, aStop);

      stLog :=   Format( 'New 이익 Auto Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
      [
        aStop.Symbol.code,
        ifThenStr(  aStop.Side > 0, '매도', '매수' ),
        aStop.Symbol.PriceToStr( aStop.Price ),
        aStop.OrdQty,
        aStop.Tick,
        aStop.Index,
        aStop.Symbol.PriceToStr(aStop.TargetPrice ),
        ifThenStr( aStop.Side > 0,  IntToStr( aStopOrder.BidStopList.Count-1)
          , IntToStr( aStopOrder.AskStopList.Count-1) )
      ]);
      gLog.Add( lkKeyOrder,'TFundOrderBoard','OnFill', stLog );
    end;
    aStopOrder.PrfStop := aStop;
  end;
  /////////////////////////////////////////////////////////////////////
  // 손실 스탑 주문
  if bLos then
  begin
    if bLoscnl then begin
      aStopOrder.Cancel( aStopOrder.LosStop );
      aStopOrder.LosStop := nil;
    end;

    iQty  := iLosQty;
    aStop := aStopOrder.New( aPos.Account, aPos.Symbol, iSide, iQty, iTick, dLosPrc );

    if aStop <> nil then
    begin
      aStop.pcValue := pcValue;
      aStop.GroupID := iGroupID;
      aStop.Index   := FTablet.GetIndex( dLosPrc );
      aStop.MustClear := true;

      aStopOrder.BroadCast( etStop, vtAdd, aStop);

      stLog :=   Format( 'New 손실 Auto Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
      [
        aStop.Symbol.code,
        ifThenStr(  aStop.Side > 0, '매도', '매수' ),
        aStop.Symbol.PriceToStr( aStop.Price ),
        aStop.OrdQty,
        aStop.Tick,
        aStop.Index,
        aStop.Symbol.PriceToStr(aStop.TargetPrice ),
        ifThenStr( aStop.Side > 0,  IntToStr( aStopOrder.BidStopList.Count-1)
          , IntToStr( aStopOrder.AskStopList.Count-1) )
      ]);
      gLog.Add( lkKeyOrder,'TFundOrderBoard','OnFill', stLog );
    end;
    aStopOrder.LosStop := aStop;
  end;

end;

procedure TFundOrderBoard.CreateControls;
var
  iLeft, iTop, iLen  : integer;
  I: integer;
begin
    // base panel
  FBoardPanel := TPanel.Create((Collection as TFundOrderBoards).FPanel);
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
  FPaintBoxTicks := TPaintBox.Create( TFundOrderBoards( Collection ).TickPanel   );
  FPaintBoxTicks.Parent := TFundOrderBoards( Collection ).TickPanel;
  FPaintBoxTicks.Align := alClient;

    // control: tablet
  FPaintBoxTablet := TPaintBox.Create(FTabletPanel);
  FPaintBoxTablet.Parent := FTabletPanel;
  FPaintBoxTablet.Align := alClient;

  for I := 0 to 4 - 1 do
  begin
    FImgStop[i]  := TImage32.Create( FTabletPanel );
    FImgStop[i].Parent :=FTabletPanel;

    FImgStop[i].Bitmap := OrpMainForm.Bitmap32.Bitmap[1];   //.LoadFromFile('./img/blue2.bmp');
//    FImgStop[i].Bitmap.MasterAlpha  := 150;
    FImgStop[i].Bitmap.DrawMode := dmBlend;
    FImgStop[i].BitmapAlign  := baTile;
  end;

  FImgLine  := TImage32.Create( FTabletPanel );
  FImgLine.Left   :=  FTabletPanel.Left;
  FImgLine.Parent :=FTabletPanel;

  FImgLine.Bitmap := OrpMainForm.Bitmap32.Bitmap[0];        //.LoadFromFile('./img/navy.bmp');
  FImgLine.BitmapAlign  := baTile;
  FImgLine.BringToFront;

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

procedure TFundOrderBoard.SetPosition(const Value: TFundPosition);
begin
  if (FFundPosition <> Value) and ( Value <> nil )then
    FFundPosition := Value;
end;


procedure TFundOrderBoard.SetQuote(const Value: TQuote);
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


procedure TFundOrderBoard.SetSymbol(const Value: TSymbol);
begin
  if Value = nil then Exit;

  FSymbol := Value;
  FTablet.Symbol := Value;

end;

//-------------------------------------------------------------------< update >

procedure TFundOrderBoard.UpdatePositionInfo;
begin
  if FFundPosition = nil then
  begin
    FTablet.OpenPosition  := 0;
    FTablet.AvgPrice      := 0;
    Exit;
  end;
  FTablet.OpenPosition  := FFundPosition.Volume;
  FTablet.AvgPrice := FFundPosition.AvgPrice;
  if Assigned(OnPosEvent) then
    OnPosEvent( Self, FFundPosition );
end;


procedure TFundOrderBoard.UpdateOrderLimit;
begin
  if FFundPosition = nil then
  begin
    FClearOrderQty  := 0;
    FPartOrderQty   := 0;
    SetClearVolume( false );
    Exit;
  end;

    // set clear order volume
  FClearOrderQty :=  FFundPosition.LiquidatableQty ;
  FPartOrderQty  :=  FFundPosition.Volume;

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

  // T Stop..Check;
  if ( FFundPosition.Symbol <> nil ) and ( FFundPosition.Symbol.Quote <> nil ) then
    TrailingStop.Observer( FFundPosition.Symbol.Quote as TQuote, true );
end;

procedure TFundOrderBoard.SetPositionVolume( iDiv : integer );
begin
  if FFundPosition = nil then
    Exit;

  if FFundPosition.Volume <> 0 then
  begin
    SetClearVolume(False);
    // set order volume
    SetOrderVolume(abs(FFundPosition.Volume) div iDiv,  True);
    // selection notified

  end;
end;

//----------------------------------------------------------------< dimension >

procedure TFundOrderBoard.Resize;
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

procedure TFundOrderBoard.Resize2(iWidth: integer);
begin
  FTablet.SetArea(FPaintBoxTablet);
end;

//----------------------------------------------------------< board selection >


//-------------------------------------------------------------------< params >

procedure TFundOrderBoard.SetParams(const Value: TOrderBoardParams);
var
  i,j: Integer;
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

    if Fund = nil then break;
    for j := 0 to Fund.FundItems.Count - 1 do
    begin

      if (aOrder.State = osActive)
         and (aOrder.Account = Fund.FundAccount[j])
         and (aOrder.Symbol = Symbol) then
         begin
          Tablet.DoOrder2(aOrder);
          bSend := true;
         end;
    end;
  end;

  ShowStopOrder;

  if bSend then
    Tablet.RefreshTable;

end;

procedure TFundOrderBoard.AllCancels( iSide : integer );
var
  I: Integer;
begin

  if FFund = nil then Exit;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin

    FOrderItem := gEnv.Engine.FormManager.OrderItems.Find( FFund.FundAccount[i], FSymbol );
    if FOrderItem = nil then continue;
    gEnv.Engine.FormManager.DoCancels( FOrderItem, iSide );
  end;

end;

procedure TFundOrderBoard.AllLiquids;
var
  aTicket : TOrderTicket;
  aPos : TPosition;  aOrder  : TOrder;
  I: Integer;
begin
  if FFundPosition = nil then Exit;

  for I := 0 to FFundPosition.Positions.Count - 1 do
  begin
    aPos  := FFundPosition.Positions.Positions[i];
    if (aPos.Volume <> 0 ) then begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, aPos.Account, aPos.Symbol,
                  -aPos.Volume, pcMarket, 0.0, tmGTC, aTicket);  //
      if aOrder <> nil then
        gEnv.Engine.TradeBroker.Send(aTicket);
    end;
  end;
end;

procedure TFundOrderBoard.StopAllCancels(iSide: integer);
var
  i : integer;
  aStop : TStopOrder;
begin
  if FFund = nil then Exit;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aStop := gEnv.Engine.TradeCore.StopOrders.Find( FFund.FundAccount[i], FSymbol );
    if aStop <> nil then
      aStop.Cancel( iSide );
  end;
end;

//---------------------------------------------------------------< set volume >

procedure TFundOrderBoard.SetOrderVolume(iQty: Integer; bRefresh: Boolean);
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


procedure TFundOrderBoard.SetAccount(const Value: TAccount);
begin

end;

procedure TFundOrderBoard.SetClearVolume(bEnabled: Boolean);
begin
    //
  FClearOrder := bEnabled;
    // set clear order volume
  //FStaticTextClearVolume.Caption := IntToStr(FClearOrderQty);
  FStaticTextClearVolume.Caption := '잔고('+FormatFloat('#,##0', FClearOrderQty)+')';
  FStaticTextClearVolume.Tag     := FClearOrderQty;

  FPartClearVolume.Caption       := Format('체결된잔고(%d)', [FPartOrderQty]);
  FPartClearVolume.Tag           := FPartOrderQty;

  if ( FPartOrderQty = 0) and ( FPartClearVolume.Down ) then
    FPartClearVolume.Down := false;
      
    // color

  if (FClearOrderQty > 0)then begin
    FStaticTextClearVolume.Font.Color := clRed;

  end
  else if (FClearOrderQty < 0)  then begin
    FStaticTextClearVolume.Font.Color := clBlue;
  //  FPartClearVolume.Font.Color := clBlue;
  end
  else if FClearOrderQty = 0 then begin
    FStaticTextClearVolume.Font.Color := clBlack;
  //  FPartClearVolume.Font.Color := clBtnFace;
  end;


  if (FPartOrderQty > 0)then begin
    FPartClearVolume.Font.Color := clRed;
  end
  else if (FPartOrderQty < 0)  then begin
    FPartClearVolume.Font.Color := clBlue;
  end
  else if FPartOrderQty = 0 then begin
    FPartClearVolume.Font.Color := clBlack;
  end;

  

end;


//---------------------------------------------------------< volume selection >

//
//  order volume selected from the volume list
//
procedure TFundOrderBoard.StringGridVolumesSelectCell(Sender: TObject; ACol,
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

procedure TFundOrderBoard.TopPanelClick(Sender: TObject);
begin
  case (Sender as TPanel).Tag of
   0  : FTablet.ScrollToLastPrice;
   else begin
    if Assigned( FOnPanelClickEvent ) then
      FOnPanelClickEvent( Self, 1, (Sender as TPanel).Tag);
   end;

  end;
end;

procedure TFundOrderBoard.BottomPanelClick(Sender: TObject);
begin
  case (Sender as TPanel).Tag of
    SHORT_ST_CANCEL   : StopAllCancels( -1 );// if FStopOrder <> nil then FStopOrder.Cancel(-1) ; //= -2;
    1,0,-1  :  AllCancels( (Sender as TPanel).Tag );
    LONG_ST_CANCEL    : StopAllCancels( 1 ); // = 2;
  end;     
end;

procedure TFundOrderBoard.PanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvLowered;
end;

procedure TFundOrderBoard.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvRaised;
end;

//
// the order volume clicked
//
procedure TFundOrderBoard.StringGridOrderVolumeSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SetClearVolume(False);
end;

procedure TFundOrderBoard.EditKeyPress(Sender: TObject; var Key: Char);
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

procedure TFundOrderBoard.EditOrderVolumeClick(Sender: TObject);
begin

  SetClearVolume(False);

    // selection notified

end;

procedure TFundOrderBoard.FocusDelete(Sender: TOrderTablet; bLock: boolean);
begin
  if FTablet = Sender then
    CheckEditFocus( bLock );

end;


function TFundOrderBoard.GetWidth: Integer;
begin

  Result := FTablet.TabletWidth;//+ iTNS ;
    //
  if FSymbol = nil then
    Result := Max(BOARD_MIN, Result);
end;

//
// the clear order volume clicked
//


procedure TFundOrderBoard.StaticTextClearVolumeClick(Sender: TObject);
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



procedure TFundOrderBoard.SetOrderVolumeToKeyBoard( iDiv : integer );
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

procedure TFundOrderBoard.HighlightTimerProc(Sender: TObject);
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


procedure TFundOrderBoard.OnAutoStopOrderEvent(Sender: TObject;
  aStop: TStopOrderItem; bOrder: boolean);
begin

end;

procedure TFundOrderBoard.OnCancelStopOrderEvent(Sender: TObject;
  aStop: TStopOrderItem);
begin

end;

procedure TFundOrderBoard.OnLastStopCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  i : integer;
  aStop : TStopOrder;
begin
  if FFund = nil then Exit;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aStop := gEnv.Engine.TradeCore.StopOrders.Find( FFund.FundAccount[i], FSymbol );
    if aStop <> nil then
      aStop.LastStopCancel;
  end;
end;

function TFundOrderBoard.CheckPrice( dPrc : double; iSide : integer; aSymbol : TSymbol ) : boolean;
begin
  Result := false;

  if dPrc < EPSILON then Exit;
  if ( aSymbol.TabletHigh < dPrc ) or ( aSymbol.TabletLow > dPrc ) then Exit;

  Result := true;
end;

procedure TFundOrderBoard.OnFill(aOrder: TOrder;
    bPrf, bLos : boolean; iPrf, iLos, iTick : integer; pcValue : TPriceControl);
var
    aFill : TFill;
    aPos  : TPosition;
begin

  if ( FFund = nil ) or ( FFundPosition = nil ) then Exit;
  if ( not bPrf ) and ( not bLos ) then Exit;

  aPos  := FFundPosition.Positions.FindPosition( aOrder.Account, aOrder.Symbol );
  if aPos = nil then Exit;
  if aPos.Volume = 0 then Exit;
  if ( aPos.Side + aOrder.Side ) = 0 then Exit;

  aFill := TFill( aOrder.Fills.Last );
  DoAutoStop( aPos, abs( aPos.Volume ), bPrf, bLos, iPrf, iLos, iTick, pcValue );

end;

procedure TFundOrderBoard.OnFillExec(bPrf, bLos: boolean; iPrf, iLos,
  iTick: integer; pcValue: TPriceControl);
  var
    i : integer;
    aPos : TPosition;
begin
  if ( FFund = nil ) or ( FFundPosition = nil ) then Exit;
  if ( not bPrf ) and ( not bLos ) then Exit;

  for I := 0 to FFundPosition.Positions.Count - 1 do
  begin
    aPos  := FFundPosition.Positions.Positions[i];
    if ( aPos = nil ) or ( aPos.Volume = 0 ) then continue;
    DoAutoStop( aPos, abs( aPos.Volume ), bPrf, bLos, iPrf, iLos, iTick, pcValue );
  end;
  
end;

procedure TFundOrderBoard.OnNewStopOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
  var
    iSide, iTick, iQty : integer;
    aStop : TStopOrderItem;
    aOwner : TFundBoardForm;
    stLog  : string;
    bRes   : boolean;
    I: Integer;
    aStopOrder : TStopOrder;
begin
  if (Sender = nil) or (FTablet <> Sender ) then Exit;
  if (FFund = nil ) or ( FSymbol = nil ) then Exit;

  if ((aPoint1.Price + PRICE_EPSILON) < FTablet.LowLimit ) or
   ((aPoint1.Price - PRICE_EPSILON ) > FTablet.HighLimit ) then
  begin
    Exit;
  end;

  if FDefQty <= 0 then
    Exit;
  aOwner := (Collection as TFundOrderBoards).FOwnerForm as TFundBoardForm;

  iTick := StrToIntDef( FStopOrderTick.Text, 0 );
  {
  if FTablet.StopChange then
    iQty := FTablet.StopChangeQty
  else
  }
  iQty := FDefQty;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aStopOrder := gEnv.Engine.TradeCore.StopOrders.Find(FFund.FundAccount[i], FSymbol );
    aStop := aStopOrder.New( FFund.FundAccount[i], FSymbol, ifThen( aPoint1.PositionType = ptLong, 1, -1),
      iQty * FFund.FundItems[i].Multiple , iTick, aPoint1.Price );

    if aStop = nil then Exit;
    aStop.Index := aPoint1.Index;;

    aStopOrder.BroadCast( etStop, vtAdd, aStop);

    stLog :=   Format( 'New Stop : %s, %s, prc:%s, %d, tick:%d, idx:%d, %s, (%s)',
    [

      aStop.Symbol.code,
      ifThenStr(  aStop.Side > 0, '매도', '매수' ),
      aStop.Symbol.PriceToStr( aStop.Price ),
      aStop.OrdQty,
      aStop.Tick,
      aStop.Index,
      aStop.Symbol.PriceToStr(aStop.TargetPrice ),
      ifThenStr( aStop.Side > 0,  IntToStr( aStopOrder.BidStopList.Count-1)
        , IntToStr( aStopOrder.AskStopList.Count-1) )
    ]);
    gLog.Add( lkKeyOrder,'TFundOrderBoard','OnNewStopOrder', stLog );
  end;

end;

procedure TFundOrderBoard.OnStopCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  i : integer;
  aStop, aStop2 : TStopOrderItem;
  aStops : TStopOrder;
begin
  if FFund = nil then Exit;

  FTmpStopList.Clear;

  if Tablet.GetStopOrders( aPoint1, FTmpStopList ) = 0 then Exit;

  aStop2 := nil;
  for I := 0 to FTmpStopList.Count - 1 do
  begin

    aStop := TStopOrderItem( FTmpStopList.Items[i] );
    aStops  := gEnv.Engine.TradeCore.StopOrders.Find( aStop.Account, aStop.Symbol );
    if aStops <> nil then
    begin

      if aStop.MustClear then
        aStop2 := aStops.FindStopOrder( aStop );
      if aStop2 <> nil then
        aStops.Cancel( aStop2 );
      aStops.Cancel( aStop);
    end;
  end;

end;

procedure TFundOrderBoard.OnStopChangeOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  i : integer;
  aStop : TStopOrder;
begin
  if FFund = nil then Exit;

  for I := 0 to FFund.FundItems.Count - 1 do
  begin
    aStop := gEnv.Engine.TradeCore.StopOrders.Find( FFund.FundAccount[i], FSymbol );
    if aStop <> nil then
      aStop.Change( FSymbol, aPoint1.Price, aPoint2.Price,
              aPoint2.Index, ifThen( aPoint1.PositionType = ptLong, 1, -1 ));
  end;
end;

procedure TFundOrderBoard.OnStopOrderEvent(Sender, aStop: TObject;
  vtType: TValueType);
var
  aColl : TFundBoardForm;
  pStop : TStopOrderItem;
begin
  if FFund = nil then Exit;

  aColl := ( Collection as TFundOrderBoards).FOwnerForm as TFundBoardForm;
  if Sender <> aColl then Exit;

  pStop := aStop as TStopOrderItem;

  if (FFund.FundItems.Find( pStop.Account) = nil ) or ( pStop.Symbol <> FSymbol ) then Exit;

  case vtType of
    vtAdd   : UpdateStopOrder( pStop );
    vtDelete: UpdateStopOrder( pStop );
    else Exit;
  end;
end;

procedure TFundOrderBoard.OnTrailingStop(bStart: boolean);
var
  aColl : TFundBoardForm;

  function GetParam : TStopParam;
  begin
    aColl := ( Collection as TFundOrderBoards).FOwnerForm as TFundBoardForm;
    Result.BaseTick := StrToInt( aColl.edtBaseLCTick.Text );
    Result.PLTick   := StrToInt( aColl.edtPLTick.Text );
    Result.LCTick   := StrToInt( aColl.edtLCTick.Text );
    Result.IsMarket := aColl.rbMarket2.Checked;
    Result.OrdTick  := StrToInt( aColl.edtLiqTick2.Text );
  end;

begin

  if ( FFund = nil ) or ( FSymbol = nil ) or ( FFundPosition = nil ) then
  begin
    OnTrailingStopEvent( FTrailingStop, false );
  end else
  begin

    if bStart then
    begin

      if gEnv.Engine.TradeCore.TrdStops.FindEx( FFundPosition ) <> nil then
      begin
        ShowMessageLE(  nil , Format('%s, %s 잔고 ' + #13#10 +  '트레일링 스탑 이미 실행중',
          [ FFundPosition.Fund.Name, FFundPosition.Symbol.ShortCode])    );
        OnTrailingStopEvent( FTrailingStop, false );
        Exit;
      end;

      FTrailingStop.Param  := GetParam;
      FTrailingStop.initEx( FFundPosition );
      FTrailingStop.OnResult  := OnTrailingStopEvent;
      FTrailingStop.OnMessage := OnTTrailingStopMessage;
      FTrailingStop.Start;
    end else begin
      FTrailingStop.Stop;
      FTrailingStop.OnResult  := nil;
      FTrailingStop.OnMessage := nil;
      FTablet.StopPrice := 0;
    end;
  end;

end;

procedure TFundOrderBoard.OnTrailingStopEvent(Sender: TObject; Value: boolean);
var
  aColl : TFundBoardForm;
begin
  if Sender <> FTrailingStop then Exit;

  aColl := ( Collection as TFundOrderBoards).FOwnerForm as TFundBoardForm;
  if (aColl.cbTrailingStop.Checked) and ( not Value ) then
    aColl.cbTrailingStop.Checked := false;
end;

procedure TFundOrderBoard.OnTTrailingStopMessage(Sender: TObject; iMax, iCalc : integer;
   dStopPrc: double);
var
  aColl : TFundBoardForm;
begin
  if Sender <> FTrailingStop then Exit;

  if FSymbol <> nil then
  begin

  aColl := ( Collection as TFundOrderBoards).FOwnerForm as TFundBoardForm;
  aColl.lbMaxTick.Caption  := IntToStr( iMax );
  aColl.lbCalcTick.Caption := IntTostr( iCalc );
  FTablet.StopPrice := dStopPrc;

  end;
end;

function TFundOrderBoard.ShowStopOrder : integer;
var
  j, I: Integer;
  aStop : TStopOrderItem;
  aStopOrder : TStopOrder;
begin

  Result := 0;
  if FFund = nil then Exit;

  for j := 0 to FFund.FundItems.Count - 1 do
  begin

    aStopOrder :=gEnv.Engine.TradeCore.StopOrders.Find( FFund.FundAccount[j], FSymbol );
    if aStopOrder = nil then Continue;       

    for I := 0 to aStopOrder.AskStopList.Count - 1 do
    begin
      aStop := TStopOrderItem( aStopOrder.AskStopList.Items[i] );
      FTablet.DoStopOrderEvent( aStop );
      inc( Result );
    end;

    for I := 0 to aStopOrder.BidStopList.Count - 1 do
    begin
      aStop := TStopOrderItem( aStopOrder.BidStopList.Items[i] );
      FTablet.DoStopOrderEvent( aStop );
      inc( Result );
    end;
  end;
end;

procedure TFundOrderBoard.UpdateStopOrder( aStop : TStopOrderItem );
begin
  FTablet.DoStopOrderEvent( aStop );
end;

//---------------------------------------------------------------------< draw >

procedure TFundOrderBoard.SetEditOrderVolumeColor;
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



procedure TFundOrderBoard.SetFundPosition(const Value: TFundPosition);
begin
  FFundPosition := Value;
end;

//---------------------------------------------------------------------< misc >

procedure TFundOrderBoard.StringGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TFundOrderBoard.StringGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;


//============================================================================//
                          { TFundOrderBoards }

//---------------------------------------------------------------------< init >

constructor TFundOrderBoards.Create(aForm: TForm; aPanel: TPanel);
begin
  inherited Create(TFundOrderBoard);

  FOwnerForm := aForm;
  FPanel := aPanel;
end;

//----------------------------------------------------------------------< new >

function TFundOrderBoards.New: TFundOrderBoard;
begin
  Result := Add as TFundOrderBoard;
end;

//---------------------------------------------------------------------< find >

function TFundOrderBoards.Find(aTablet: TOrderTablet): TFundOrderBoard;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TFundOrderBoard).FTablet = aTablet then
    begin
      Result := Items[i] as TFundOrderBoard;
      Break;
    end;
end;

function TFundOrderBoards.FindPaintBox(aPaintBox: TPaintBox): TFundOrderBoard;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if (Items[i] as TFundOrderBoard).FPaintBoxTablet = aPaintBox then
    begin
      Result := Items[i] as TFundOrderBoard;
      Break;
    end;
end;

//---------------------------------------------------------------------< misc >

function TFundOrderBoards.GetBoard(i: Integer): TFundOrderBoard;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TFundOrderBoard
  else
    Result := nil;
end;

end.


