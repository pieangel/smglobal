﻿unit FFundOrderBoard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Buttons, ComCtrls, ImgList,  Menus, Math, Spin,
  MMSystem, DateUtils,
    // lemon: common
  GleTypes, GleLib, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleMarkets, CleKrxSymbols, CleQuoteBroker, CleStopOrders,
    // lemon: trade
  CleAccounts, CleOrders, ClePositions, CleTradeBroker, CleFunds,
    // lemon: utils
  CleDistributor, CleStorage,
    // lemon: import
  CalcGreeks,  COBTypes,
    // app: main
  GAppEnv,
    // app: orderboard
  CFundOrderBoard, COrderTablet,
  {DBoardPrefs,} DBoardParams, DBoardOrder, UAlignedEdit;

const
  PlRow = 12;
  FeeRow = 13;
  BtnCnt = 8;

  TitleCnt = 4;
  TitleCnt2 = 6;
  TitleInfoCnt = 10;

  CheckCol  = 0;
  OrderCol  = 1;
  SymbolCol = 2;
  ChangeCol = 3;
  ColorCol  = 3;

  InFo_Last_Row = 3;
  InFo_Change_Row = 4;

  Title1 : array [0..TitleCnt-1] of string = ('','종목','구분','수량');
  Title2 : array [0..TitleCnt-1] of string = ('','종목','구분','평가손익');
  Title3 : array [0..TitleCnt2-1] of string = ('종목','구분','잔고','평균가','현재가','평가손익');
  TitleInfo : array [0..TitleInfoCnt-1] of string =
    ('시가','고가','저가','종가','전일대비','총거래량','틱가치','틱사이즈','거래소','만기월');



type

  TFundBoardForm = class(TForm)
    PanelLeft: TPanel;
    PanelMain: TPanel;
    PanelTop: TPanel;
    PopupMenuOrders: TPopupMenu;
    N6000X11: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    PopQuote: TPopupMenu;
    N8: TMenuItem;
    C1: TMenuItem;
    PanelRight: TPanel;
    N9: TMenuItem;
    FlipSide1: TMenuItem;
    FlipDirection1: TMenuItem;
    FlipSideDirection1: TMenuItem;
    SpeedButtonPrefs: TSpeedButton;
    ComboBoAccount: TComboBox;
    tmPriceSort: TTimer;
    reFresh: TTimer;
    Button1: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    cbSymbol: TComboBox;
    UpDown1: TUpDown;
    edtOrderQty: TEdit;
    PanelTicks: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label4: TLabel;
    Button3: TButton;
    sgUnFill: TStringGrid;
    Panel6: TPanel;
    Panel7: TPanel;
    Label5: TLabel;
    Button4: TButton;
    sgUnSettle: TStringGrid;
    Panel8: TPanel;
    sgAcntPL: TStringGrid;
    cbUnFillAll: TCheckBox;
    cbUnSettleAll: TCheckBox;
    Panel1: TPanel;
    Panel4: TPanel;
    PopupMenu1: TPopupMenu;
    N10: TMenuItem;
    N11: TMenuItem;
    sgQuote: TStringGrid;
    edtMin: TLabeledEdit;
    Button2: TButton;
    edtTmpQty: TEdit;
    edtPw: TEdit;
    sbtnActOrdQry: TSpeedButton;
    sbtnPosQry: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label2: TLabel;
    sgSymbolPL: TStringGrid;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    btnClearQty: TSpeedButton;
    cbAcntLisk: TCheckBox;
    edtOpenLiskAmt: TAlignedEdit;
    PanelOrderList: TPanel;
    Panel5: TPanel;
    sgInterest: TStringGrid;
    sgInfo: TStringGrid;
    stSymbolName: TStaticText;
    Panel9: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel11: TPanel;
    GroupBox1: TGroupBox;
    Label8: TLabel;
    UpDown2: TUpDown;
    edtStopTick: TAlignedEdit;
    TabSheet2: TTabSheet;
    Panel10: TPanel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    cbKeyOrder: TCheckBox;
    rbMouseSelect: TRadioGroup;
    rbLastOrdCnl: TRadioGroup;
    Label29: TLabel;
    SpeedButton6: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    edtOrdH: TAlignedEdit;
    edtOrdW: TAlignedEdit;
    cbOneClick: TCheckBox;
    cbHogaFix: TCheckBox;
    SpeedButtonLeftPanel: TSpeedButton;
    SpeedButtonRightPanel: TSpeedButton;
    Label11: TLabel;
    btnAbleNet: TSpeedButton;
    SpeedButton8: TSpeedButton;
    plAllLiq: TPanel;
    plthisLiq: TPanel;
    plAllCnl: TPanel;
    plthisCnl: TPanel;
    cbShortCutOrd: TCheckBox;
    cbConfirmOrder: TCheckBox;
    GroupBox3: TGroupBox;
    cbPrfLiquid: TCheckBox;
    cbLosLiquid: TCheckBox;
    udPrfTick: TUpDown;
    udLosTick: TUpDown;
    edtPrfTick: TAlignedEdit;
    edtLosTick: TAlignedEdit;
    GroupBox4: TGroupBox;
    rbMarket: TRadioButton;
    rbHoga: TRadioButton;
    edtLiqTick: TAlignedEdit;
    udLiqTick: TUpDown;
    Button5: TButton;
    SpeedButton15: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedMiddle: TSpeedButton;

    procedure SpeedButtonLeftPanelClick(Sender: TObject);
    procedure SpeedButtonRightPanelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure StringGridOptionsMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridOptionsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);

    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure FormResize(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure FormActivate(Sender: TObject);


    procedure listReadyDblClick(Sender: TObject);

    procedure ComboBoAccountChange(Sender: TObject);

    procedure udControlClick(Sender: TObject; Button: TUDBtnType);
    procedure ComboBoxUnderlyingsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBoxUnderlyingsKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);


    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure sgUnFillDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbUnFillAllClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure sgAcntPLDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbUnSettleAllClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure sgSymbolPLDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbSymbolChange(Sender: TObject);
    procedure reFreshTimer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInterestDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure N10Click(Sender: TObject);
    procedure sgInterestMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInterestSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure edtPrfTickKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton6Click(Sender: TObject);
    procedure sgUnFillDblClick(Sender: TObject);
    procedure sgUnFillMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbKeyOrderClick(Sender: TObject);
    procedure cbOneClickClick(Sender: TObject);
    procedure rbMouseSelectClick(Sender: TObject);
    procedure rbLastOrdCnlClick(Sender: TObject);
    procedure cbHogaFixClick(Sender: TObject);

    procedure edtOrderQtyChange(Sender: TObject);
    procedure edtLiskAmtKeyPress(Sender: TObject; var Key: Char);
    procedure sgQuoteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button2Click(Sender: TObject);

    procedure edtTmpQtyExit(Sender: TObject);
    procedure edtTmpQtyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnAbleNetClick(Sender: TObject);
    procedure sbtnActOrdQryClick(Sender: TObject);
    procedure sbtnPosQryClick(Sender: TObject);
    procedure edtOpenLiskAmtChange(Sender: TObject);
    procedure cbAcntLiskClick(Sender: TObject);
    procedure edtOpenLiskAmtKeyPress(Sender: TObject; var Key: Char);
    procedure cbPrfLiquidClick(Sender: TObject);

    procedure edtLiqTickChange(Sender: TObject);
    procedure rbMarketClick(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure plAllLiqClick(Sender: TObject);
    procedure plAllLiqMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure plAllLiqMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbConfirmOrderClick(Sender: TObject);
    procedure cbShortCutOrdClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure SpeedMiddleClick(Sender: TObject);
    procedure SpeedButton15Click(Sender: TObject);
    procedure SpeedButton17Click(Sender: TObject);
//    procedure cbConfirmNetQtyClick(Sender: TObject);

  private
      // created objects
    FBoards: TFundOrderBoards;

      // configuration
    FPrefs: TOrderBoardPrefs;
    FDefParams: TOrderBoardParams;

      // selection
    FUnderlying: TSymbol; // selected underlying symbol
    FFutures: TSymbol;    // selected futures
    FSpread: TSpread;
    FUnderlyingGroup: TMarketGroup; //
    FFutureMarket: TFutureMarket;   //
    FSpreadMarket: TSpreadMarket;   //
    FOptionMarket: TOptionMarket;   //
    FELWMarket: TELWMarket;         //

      // menu related -- used when executing orders from the popup menu
    FMenuBoard: TFundOrderBoard;
    FMenuPoint: TTabletPoint;

      // last selected -- used in symbol selection, info window, order list
    FSelectedBoard: TFundOrderBoard;
    FCancelPoint: TTabletPoint;

      // temporary order list -- used in sending change and cancel orders
    FTargetOrders: TOrderList;
    FPointOrders : TOrderList;
      // temporary Position list -- used in 청산
    FTargetPositions: TPositionList;

      // 순서 제어 변수들.
    FLoadEnd    : boolean;
    FLeftPos    : integer;
    FResize     : boolean;
    FKeyDown    : boolean;

    FFund       : TFund;
    FSymbol     : TSymbol;
      // 그리드 관련..
    FUfColWidth : integer;
    FUSColWidth : Integer;
    FSaveRow, FSymbolRow    : integer;

    FUfLastGap : integer;
    FUsLastGap : integer;
    FUnRow     : array [0..1] of integer;
      // 손절 금액
    FLiskAmt : double;
    FLiskChange : boolean;

    FAskCnt, FBidCnt : integer;
    FAskVol, FBidVol : integer;
    FMin  : integer;
    LastButton  : TSpeedButton;
    FIndex : integer;
    LogTitle : string;
    FFavorSymbols: TFavorSymbols;
    {todo:
    FKeyOrderMap : String;
    //FKeyOrderMapItem : TKeyOrderItem;

    procedure KeyOrderProc(Sender, Receiver, DataObj: TObject;
                       iBroadcastKind: Integer; btValue: TBroadcastType);
    procedure ObserverProc(Sender, Receiver : TObject; DataObj : TObject;
                        iBroadcastKind : Integer; btValue : TBroadcastType);
    }

    procedure ReloadSymbols;
    procedure BoardPosUpdate(Sender: TObject; Value: TObject);
    procedure MakeBoards; overload;
    procedure MakeBoards( iCount : integer ) ; overload;

    procedure MinPriceProc(Sender : TObject);
    procedure MaxPriceProc(Sender : TObject);

      // init
    procedure InitControls;
    procedure SetAccount;
    procedure SetSymbol(aSymbol : TSymbol);
    procedure SetInfo(aBoard: TFundOrderBoard; bQuote : boolean = false );

      // configuration
    procedure ApplyPrefs;
    procedure SetWidth;
    procedure SetDefaultPrefs;
    procedure SetDefaultParams;


       // order tablet events handler
    procedure BoardNewOrder; overload;
    procedure BoardNewOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint); overload;
    procedure BoardChangeOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardLastCancelOrder(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelectCell(Sender: TOrderTablet; aPoint1, aPoint2: TTabletPoint);
    procedure BoardSelect(Sender: TObject);
    procedure BoardAcntSelect( aBoard : TFundOrderBoard );
    procedure BoardPanelClickEvent( Sender : TObject; iDiv , iTag : integer );

      // send order
    function NewOrder(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
      iVolume: Integer; dPrice: Double): TOrder; overload;
    function NewOrder(aBoard: TFundOrderBoard; iSide ,iVolume: Integer; dPrice: Double;
      pcValue : TPriceControl = pcLimit ): TOrder; overload;
      // 펀드 손절에만 사용
    procedure LossCutOrder( aBoard: TFundOrderBoard; aQuote : TQuote );

    function ChangeOrder(aBoard: TFundOrderBoard; aPoint1, aPoint2: TTabletPoint): Integer; overload;
    function ChangeOrder(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer; dPrice: Double): Integer; overload;
    function CancelOrders(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
      iMaxQty: Integer = 0): Integer; overload;
    function CancelOrders(aTablet: TOrderTablet; aTypes: TPositionTypes ): Integer; overload;
    function CancelOrders(aBoard: TFundOrderBoard; aTypes: TPositionTypes): Integer; overload;
    function CancelOrders(aBoard: TFundOrderBoard; aPoint : TTabletPoint; aTypes: TPositionTypes): Integer; overload;

    procedure PartCancelOrder( Sender : TOrderTablet; aPoint : TTabletPoint; aTypes :  TPositionTypes );

      // board
    function NewBoard: TFundOrderBoard;

      // info pane

      // engine events
    procedure TradeBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure DoPosition(aPosition: TFundPosition; EventID: TDistributorID);
    procedure DoFund( aFund : TFund ; EventID: TDistributorID);

    procedure DoOrder(aOrder: TOrder; EventID: TDistributorID); overload;
    procedure DoOrder(aOrder: TOrder ); overload;
    procedure OnAccount( aInvest: TInvestor; EventID: TDistributorID); overload;
    procedure OnAccount( aInvest: TInvestor); overload;
    procedure QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure BoardEnvEventHander (Sender : TObject; DataObj: TObject;
      etType: TEventType; vtType : TValueType );

      // left side pane
    procedure SetPosition(aPosition: TFundPosition);

    procedure UpdateTotalPl;

    procedure OtherBoardScrollToLastPrice;

    procedure GetMarketAccount;
    function CancelLastOrder(aBoard: TFundOrderBoard): integer;


    procedure ShowPositionVolume;
    procedure BoardEventStopOrder(vtType: TValueType; DataObj: TObject);

    procedure UpdatePositionInfo( aPos : TFundPosition );
    procedure ClearGrid(aGrid : TStringGrid);
    procedure UpdatePositon;

    function GetMonth(stCode: string): string;
    procedure MatchTablePoint(aBoard: TFundOrderBoard; aPoint1,
      aPoint2: TTabletPoint);
    procedure CalcVolumeNCntRate(aQuote: TQuote);
    procedure UpdateData;
    procedure CheckLossCut( aQuote : TQuote );
    function CheckInvest: boolean;
    procedure SetFundStopOrder(aBoard: TFundOrderBoard);

    procedure ResetGrid(aGrid: TStringGrid);
    procedure AllCancels(bAuto: boolean);
    procedure AllLiquids(bAuto: boolean);

    procedure SetInterestSymbols;
    procedure SetFavorSymbols;
    procedure refreshFavorSymbols;

  public
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure StandByClick( Sender, aControl : TObject );
    procedure ReLoad;
    procedure CenterAlign;
    procedure RecvSymbol(aSymbol: TSymbol);
    procedure AddInterestSymbol(aSymbol: TSymbol; iRow: integer);
    procedure WMSymbolSelected(var msg: TMessage); message WM_SYMBOLSELECTED;

    property FavorSymbols : TFavorSymbols read FFavorSymbols;
  end;

var
  FundBoardForm: TFundBoardForm;

const
  SIDE_LEFT_PANEL_WIDTH = 154;
  SIDE_RIGHT_PANEL_WIDTH = 154;

implementation

uses CleQuoteTimers, CleFormBroker, DleInterestConfig,
  FConfirmLiqMode ,
  GAppForms
  ;

//uses ControlObserver ;

{$R *.dfm}

//---------------------------------------------------------------------< init >

procedure TFundBoardForm.FormCreate(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  FResize := false;
  LogTitle:= '';
  FFavorSymbols:= TFavorSymbols.Create;
    // create objects
  FBoards := TFundOrderBoards.Create(Self, PanelMain);
  FBoards.TickPanel := PanelTicks;

  FTargetOrders := TOrderList.Create;
  FPointOrders  := TOrderList.Create;
  FTargetPositions  := TPositionList.Create;
    // init variables
  FKeyDown        := false;
    // grid title
  InitControls;
    // get default
    // 주문창 전체 환경설정
  SetDefaultPrefs;
    // 개별 보드 환경설정
  SetDefaultParams;

  FSymbol   := nil;
  FFund     := nil;
  FIndex    := -1;
  SetAccount;
  SetFavorSymbols;
  SetInterestSymbols;

    // subscribe for trade events
  gEnv.Engine.TradeBroker.Subscribe(Self, TradeBrokerEventHandler);
  genv.Engine.TradeBroker.Subscribe(Self, FPOS_DATa, TradeBrokerEventHandler);
  gEnv.Engine.TradeBroker.Subscribe(Self, FUND_DATA, TradeBrokerEventHandler );

  gEnv.Engine.TradeCore.StopOrders.BoardItems.RegistCfg( Self, etStop, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etQty, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etSpace, BoardEnvEventHander );
  gBoardEnv.BroadCast.RegistCfg( Self, etInterest, BoardEnvEventHander );
    //
  ApplyPrefs;
    //

  FSaveRow := -1;
  FSymbolRow := -1;
  LoadEnv( nil );
  FLeftPos := Left;

  if FSymbol = nil then
  begin
    aSymbol := gEnv.Engine.SymbolCore.FutureMarkets[0].FrontMonth;

    if aSymbol <> nil then
    begin
      AddSymbolCombo( aSymbol, cbSymbol );
      cbSymbolChange( cbSymbol );
    end;
  end;


end;

procedure TFundBoardForm.FormActivate(Sender: TObject);
begin
  // KeyBoard
  {
  if FKeyOrderMapItem <> nil then
    FKeyOrderMapItem.Active;
  }


end;

procedure TFundBoardForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  aBoard : TFundOrderBoard;
begin
  gBoardEnv.BroadCast.UnRegistCfg( Self );
  // stop order 등록취소
  gEnv.Engine.TradeCore.StopOrders.BoardItems.UnRegistCfg( Self );

  for i := 0 to FBoards.Count - 1 do
    gEnv.Engine.QuoteBroker.Cancel(FBoards[i]);


  { todo:
  // KeyBoard
  FKeyOrderMapItem.Unsubscribe(Self);
  gKeyOrderAgent.Remove(FKeyOrderMapItem);

  gCObserver.Broadcaster.UnSubscribe(Self);
  }

    // new coding

  gEnv.Engine.TradeBroker.Unsubscribe(Self);
  gEnv.Engine.QuoteBroker.Cancel(Self);

  FTargetOrders.Free;
  FPointOrders.Free;
  FTargetPositions.Free;
  FBoards.Free;
  FFavorSymbols.Free;
end;

procedure TFundBoardForm.FormResize(Sender: TObject);
var
  iCnt,  i: Integer;
begin
  iCnt  := 0;
  if FBoards.Count >1 then
  begin
    for i := 0 to FBoards.Count - 1 do
    begin
        inc( iCnt );
    end;
  end;

  if iCnt = 0 then iCnt := 1;

  for i := 0 to FBoards.Count - 1 do
  begin
    if not FLoadEnd then
      FBoards[i].Resize
    else begin
      FBoards[i].Resize;
    end;
  end;
end;

procedure TFundBoardForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFundBoardForm.InitControls;
var
  I: Integer;
begin

  for I := 0 to TitleCnt - 1 do
  begin
    sgUnFill.Cells[i,0] := Title1[i];
    sgUnSettle.Cells[i,0] := Title2[i];
  end;

  sgAcntPL.Cells[0,0] := '평가손익';
  sgAcntPL.Cells[0,1] := '실현손익';
  sgAcntPL.Cells[0,2] := '총손익';

  for I := 0 to TitleCnt2 - 1 do
    sgSymbolPL.Cells[i,0] := Title3[i];

  sgInterest.Cells[0,0] := '구분';
  sgInterest.Cells[1,0] := '코드';
  sgInterest.Cells[2,0] := '월물';

  sgQuote.Cells[0,0]  := '거래량비';
  sgQuote.Cells[1,0]  := '건수비';

  FMin  := 60;

  for I := 0 to sgInfo.RowCount - 1 do
    sgInfo.Cells[0,i] := TitleInfo[i];

  sgInfo.ColWidths[0] := sgInfo.ColWidths[0]-10;
  sgInfo.ColWidths[1] := sgInfo.ColWidths[1]+10;

  FUfColWidth := sgUnFill.ColWidths[ChangeCol];
  FUSColWidth := sgUnSettle.ColWidths[ChangeCol];

  sgAcntPL.ColWidths[0] := 50;
  sgAcntPL.ColWidths[1] := sgAcntPL.ClientWidth - sgAcntPL.ColWidths[0]-2;

  FUfLastGap := -1;
  FUsLastGap := -1;

  FUnRow[0]  := -1;
  FUnRow[1]  := -1;

  FLiskChange := false;
  LastButton  := nil;

  if gEnv.UserType = utStaff then
    edtPw.Visible := false;
end;


procedure TFundBoardForm.listReadyDblClick(Sender: TObject);
begin
  // 대기 취소..
end;

procedure TFundBoardForm.ReLoad;
var
  i : integer;
  aBoard : TFundOrderBoard;
begin
  for i := 0 to FBoards.Count - 1 do
  begin
    FSelectedBoard := FBoards[i];

    if FselectedBoard.Symbol <> nil then
      SetSymbol( FselectedBoard.Symbol );
  end;

end;

procedure TFundBoardForm.ReloadSymbols;
begin

end;

//-----------------------------------------------------------------< defaults >

procedure TFundBoardForm.SetDefaultPrefs;
begin
  with FPrefs do
  begin
    OrderKey  := ktNone;
    RangeKey  := ktSpace;

    DbClickOrder := true;
    MouseSelect := true;
    LastOrdCnl  := false;
      // generice
    BoardCount := 1;

      // board
    AutoScroll := False;
    TraceMouse := True;

    UseKeyOrder := false;

    Colors[IDX_LONG,  IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_ORDER, IDX_FONT] := clBlack;
    Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT] := clBlack;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT] := clBlack;

    Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND] := $E4E2FC;
    Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND] := $F5E2DA;

    Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND] := $C4C4FF;
    Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND] := $FFC4C4;

    cbOneClick.Checked  := false;
    cbHogaFix.Checked   := false;
    cbKeyOrder.Checked  := false;
    rbMouseSelect.ItemIndex := 0;
    rbLastOrdCnl.ItemIndex  := 1;

    UsePrfLiquid   := false;
    UseLosLiquid   := false;
    PrfTick := 5;
    LosTick := 5;

    UseMarketPrc   := true;   // 자동 청산주문을 시장가로..
    LiquidTick     := 4;
    ConfirmSetNetQty  := false;
    FixedHoga   := false;
    UseShortCut := false;
    UseShortCutConfirm := true;

  end;
end;



procedure TFundBoardForm.SetInfo(aBoard: TFundOrderBoard; bQuote : boolean);
var
  aSymbol : TSymbol;
  aQuote  : TQuote;
begin
  if ( aBoard = nil ) or ( aBoard.Symbol = nil ) then Exit;

  aSymbol := aBoard.Symbol;
  with sgInfo do
  begin
    if not bQuote then
    begin

      FAskCnt := 0;
      FBidCnt := 0;
      FAskVol := 0;
      FBidVol := 0;

      UpdateData;

      Edit1.Text  := aSymbol.Name;
      stSymbolName.Caption  := aSymbol.Name;

      Cells[1,6]  := Formatfloat('#,##0.#####', aSymbol.Spec.TickValue );

      Cells[1,8]  := UpperCase(aSymbol.Spec.Exchange) ;
      Cells[1,9]  := FormatDateTime('yyyy-mm',  TDerivative( aSymbol ).ExpDate );
    end;

    Cells[1,7]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.Spec.GetTickSize( aSymbol.Last ) ]);
    Cells[1,0]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.DayOpen ]);
    Cells[1,1]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.DayHigh]);
    Cells[1,2]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.DayLow ]);
    Cells[1,3]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.Last ]);

    if aSymbol.Quote <> nil then
    begin
      aQuote  := aSymbol.Quote as TQuote;
      Cells[1,Info_Change_Row]  := Format('%.*n', [ aSymbol.Spec.Precision, aQuote.Change ]);
      Objects[1,Info_Change_Row]  := Pointer( ifThenColor( aQuote.Change > 0, clRed,
                                     ifThenColor( aQuote.Change < 0, clBlue, clBlack )));
      Cells[1,5]  := Format('%.0n', [ aQuote.DailyVolume*0.1 ]);
    end;
  end;


end;

procedure TFundBoardForm.SetInterestSymbols;
var
  I: Integer;
  aFutMarket  : TFutureMarket;
  aFavor      : TFavorSymbolItem;
begin
  for I := 0 to BtnCnt-1 do
  begin
    aFavor      := TFavorSymbolItem( FavorSymbols.Items[i] );
    if  i <= gEnv.Engine.SymbolCore.FavorFutMarkets.Count -1  then
      aFutMarket  := TFutureMarket( gEnv.Engine.SymbolCore.FavorFutMarkets.Objects[i] )
    else
      aFutMarket  := nil;

    if aFutMarket <> nil then begin
      aFavor.button.Caption := gEnv.Engine.SymbolCore.FavorFutMarkets.Strings[i];

      case gEnv.Engine.SymbolCore.FavorFutType of
        0 : aFavor.Symbol := aFutMarket.FrontMonth;
        1 : aFavor.Symbol := aFutMarket.MuchMonth;
      end;

    if aFavor.button.Down and (FSymbol <> aFavor.Symbol) then
      aFavor.button.Down  := false;

    if (aFavor.Symbol <> nil ) and  (FSymbol = aFavor.Symbol) then
      aFavor.button.Down  := true;

    gEnv.EnvLog( WIN_TESt, Format('%d %s : %s, %s ',   [
      i,  ifThenStr( gEnv.Engine.SymbolCore.FavorFutType = 0, '월물', '거래량'),
        aFutMarket.FrontMonth.Code,  aFutMarket.MuchMonth.Code ]  ));

    end else
    begin
      aFavor.button.Caption := '';
      aFavor.Symbol := nil;
    end;
  end;

end;

procedure TFundBoardForm.SetDefaultParams;
begin
  with FDefParams do
  begin
    OrdHigh := 18;
    OrdWid  := 58;

    edtOrdH.Text  := '18';
    edtOrdW.Text  := '58';
  end;
end;


//----------------------------------------------------------------------< env >

procedure TFundBoardForm.LoadEnv(aStorage: TStorage);
var
  i, j, ii, k, iCol, iRow, iCount: Integer;
  aBoard: TFundOrderBoard;
  aStop : TSTopORder;
  stBoard, stTmp, stAcnt : String;
  aParams: TOrderBoardParams;

  aOrder : TOrder;
  ColorSave : boolean;
  aSymbol : TSymbol;
begin
  if aStorage = nil then begin
    FLoadEnd := true;
    //gEnv.OnLog( self, 'load end ');
    Exit;
  end;

  SpeedButtonLeftPanel.Down  := aStorage.FieldByName('ShowLeftPanel').AsBoolean;
  SpeedButtonRightPanel.Down := aStorage.FieldByName('ShowRightPanel').AsBoolean;
  SpeedMiddle.Down           := aStorage.FieldByName('ShowSymbolGrid').AsBoolean;

    // preferences
  FPrefs.BoardCount       := aStorage.FieldByName('Prefs.BoardCount').AsInteger;
  //MakeBoards;
  FPrefs.AutoScroll       := aStorage.FieldByName('Prefs.AutoScroll').AsBoolean;
  FPrefs.TraceMouse       := aStorage.FieldByName('Prefs.TraceMouse').AsBoolean;

  FPrefs.UseKeyOrder      := aStorage.FieldByName('Prefs.UseKeyOrder').AsBoolean;

  FPrefs.OrderKey         := TBoardKeyType( aStorage.FieldByName('Prefs.OrderKey').AsInteger );
  FPrefs.RangeKey         := TBoardKeyType( aStorage.FieldByName('Prefs.RangeKey').AsInteger );

  FPrefs.MouseSelect      := aStorage.FieldByName('Prefs.MouseSelect').AsBoolean;
  FPrefs.DbClickOrder     := aStorage.FieldByName('Prefs.DbClickOrder').AsBoolean;
  FPrefs.LastOrdCnl       := aStorage.FieldByName('Prefs.LastOrdCnl').AsBoolean;

  SpeedButton1.Caption    := aStorage.FieldByName('SpeedButton1').AsStringDef('1');
  SpeedButton2.Caption    := aStorage.FieldByName('SpeedButton2').AsStringDef('2');
  SpeedButton3.Caption    := aStorage.FieldByName('SpeedButton3').AsStringDef('3');
  SpeedButton4.Caption    := aStorage.FieldByName('SpeedButton4').AsStringDef('4');
  SpeedButton5.Caption    := aStorage.FieldByName('SpeedButton5').AsStringDef('5');

  FPrefs.PrfTick          := aStorage.FieldByName('PrfTick').AsIntegerDef(5);
  FPrefs.LosTick          := aStorage.FieldByName('LosTick').AsIntegerDef(5);

  FPrefs.UseMarketPrc     := aStorage.FieldByName('UseMarketPrc').AsBoolean;
  FPrefs.LiquidTick       := aStorage.FieldByName('LiquidTick').AsInteger;
  FPrefs.ConfirmSetNetQty := aStorage.FieldByName('ConfirmSetNetQty').AsBoolean;

  FPrefs.UseShortCut      := aStorage.FieldByName('UseShortCutOrd').AsBooleanDef( false ) ;
  FPrefs.UseShortCutConfirm := aStorage.FieldByName('UseShortCutOrdConfirm').AsBooleanDef( true );
  FPrefs.FixedHoga        := aStorage.FieldByName('FixedHoga').AsBooleanDef(false);
    // apply preferences
  ApplyPrefs;
    // boards
  // 관심종목....
  for I := 1 to sgInterest.RowCount - 1 do
  begin
    stTmp :=  aStorage.FieldByName('Symbol_'+IntToStr(i)).AsString ;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stTmp );
    AddInterestSymbol( aSymbol, i );
  end;

  for i := 0 to 0 do
  begin
    if i > FBoards.Count-1 then Break;

    aBoard := FBoards[i];
    stBoard := Format('Board[%d]', [i]);
      // symbol
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(
                          aStorage.FieldByName(stBoard + '.symbol').AsString);
    if aSymbol <> nil then
    begin
      AddSymbolCombo(aSymbol, cbSymbol );
      cbSymbolChange( cbSymbol );
    end;

    if (aBoard.Symbol <> nil) and ( FFund <> nil ) then
      aBoard.Fund:= FFund;

    if aBoard.Fund <> nil then
      BoardAcntSelect( aBoard );

    //  qty set
    stTmp := aStorage.FieldByName(stBoard + '.QtySetName').AsString;

    //OwnOrderTrace
    aParams.OrdHigh        := aStorage.FieldByName(stBoard + '.Params.OrdHigh').AsInteger;
    aParams.OrdWid         := aStorage.FieldByName(stBoard + '.Params.OrdWid').AsInteger;
    edtOrdH.Text  := IntToStr( aParams.OrdHigh );
    edtOrdW.Text  := IntToStr( aParams.OrdWid );

    if aParams.OrdHigh <= 0 then
      aParams.OrdHigh := 18;
    if aParams.OrdWid <= 0 then
      aParams.OrdWid := 58;

    aBoard.Params := aParams; // apply

    aBoard.FundPosition := gEnv.Engine.TradeCore.FundPositions.Find(aBoard.Fund , aBoard.Symbol);
    //aBoard.SmartClearCheck.Checked := aStorage.FieldByName(stBoard + '.SmartClear').AsBoolean;
    SetFundStopOrder(aBoard);
    aBoard.ShowStopOrder;

    aBoard.UpdatePositionInfo;
    aBoard.UpdateOrderLimit
  end;
    // apply visibilities of panels
  SpeedButtonLeftPanelClick(SpeedButtonLeftPanel);
  SpeedButtonRightPanelClick(SpeedButtonRightPanel);
  SpeedMiddleClick( SpeedMiddle );
    // apply account change

    // apply orders
  for i := 0 to FPrefs.BoardCount-1 do
  begin
    if i > FBoards.Count-1 then Break;
    aBoard := FBoards[i];

    if aBoard = nil  then  Continue;
    if aBoard.Fund = nil then Continue;

    for j := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[j];

      for k := 0 to aBoard.Fund.FundItems.Count - 1 do
      begin
        if (aOrder.State = osActive)
          and (aOrder.Account = aBoard.Fund.FundAccount[k] )  then
          begin
            DoOrder( aOrder );
            if (aOrder.Symbol = aBoard.Symbol) then
              aBoard.Tablet.DoOrder(aOrder);
          end;
      end;
    end;
  end;

  FLoadEnd := true;

end;

procedure TFundBoardForm.LossCutOrder(aBoard: TFundOrderBoard; aQuote : TQuote);
var
  iRes, I : integer;
  aTicket : TOrderTicket;
  aOrder  : Torder;
  aPos    : TPosition;
  dPrice  : double;
  pcValue : TPriceControl;
begin
  if ( aBoard = nil ) or ( aBoard.FundPosition = nil ) then Exit;

  for I := 0 to aBoard.FundPosition.Positions.Count - 1 do
  begin
    aPos := aBoard.FundPosition.Positions.Positions[i];
    if aPos = nil then Continue;
    if aPos.Volume = 0 then Continue; 

    dPrice := 0;
    pcValue:= pcMarket;

    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      // create normal order
    aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, aPos.Account, aPos.Symbol,
                  -aPos.Volume,
                  pcValue, dPrice, tmGTC, aTicket);  //
    aOrder.OwnForm  := self;

    if aOrder <> nil then
    begin
      iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
      gEnv.Engine.TradeCore.Orders.DoNotify( aOrder );
      aOrder.FundName := FFund.Name;

      gEnv.EnvLog( WIN_FUNDORD, Format('Send %s LossCut Order(%d) : %s, %s, %s, %.*n, %d ', [
        aBoard.Fund.Name,
        i, aOrder.Account.Code, aOrder.Symbol.ShortCode, ifThenStr( aOrder.Side > 0, '매수','매도'),
        aOrder.Symbol.Spec.Precision, 0.0, aOrder.OrderQty ])    );
    end;
  end;

end;

procedure TFundBoardForm.SaveEnv(aStorage: TStorage);
var
  ii,i, j, k, iCol, iRow: Integer;
  aSymbol : TSymbol;
  aBoard: TFundOrderBoard;
  stBoard: String;
begin
  if aStorage = nil then Exit;

    // account
  if FFund <> nil then
    aStorage.FieldByName('FundName').AsString := FFund.Name; // account
    //
  aStorage.FieldByName('ShowLeftPanel').AsBoolean := SpeedButtonLeftPanel.Down;
  aStorage.FieldByName('ShowRightPanel').AsBoolean := SpeedButtonRightPanel.Down;
  aStorage.FieldByName('ShowSymbolGrid').AsBoolean := SpeedMiddle.Down;
    // preferences
  aStorage.FieldByName('Prefs.BoardCount').AsInteger := FPrefs.BoardCount;

  aStorage.FieldByName('Prefs.AutoScroll').AsBoolean := FPrefs.AutoScroll;
  aStorage.FieldByName('Prefs.TraceMouse').AsBoolean := FPrefs.TraceMouse;
  aStorage.FieldByName('Prefs.UseKeyOrder').AsBoolean := FPrefs.UseKeyOrder;

  aStorage.FieldByName('Prefs.OrderKey').AsInteger  := Integer( FPrefs.OrderKey );
  aStorage.FieldByName('Prefs.RangeKey').AsInteger  := Integer( FPrefs.RangeKey );

  aStorage.FieldByName('Prefs.MouseSelect').AsBoolean   := FPrefs.MouseSelect;
  aStorage.FieldByName('Prefs.DbClickOrder').AsBoolean  := FPrefs.DbClickOrder;
  aStorage.FieldByName('Prefs.LastOrdCnl').AsBoolean    := FPrefs.LastOrdCnl;

  aStorage.FieldByName('SpeedButton1').AsString := SpeedButton1.Caption;
  aStorage.FieldByName('SpeedButton2').AsString := SpeedButton2.Caption;
  aStorage.FieldByName('SpeedButton3').AsString := SpeedButton3.Caption;
  aStorage.FieldByName('SpeedButton4').AsString := SpeedButton4.Caption;
  aStorage.FieldByName('SpeedButton5').AsString := SpeedButton5.Caption;

  aStorage.FieldByName('PrfTick').AsInteger       := FPrefs.PrfTick ;
  aStorage.FieldByName('LosTick').AsInteger       := FPrefs.LosTick ;

  aStorage.FieldByName('UseMarketPrc').AsBoolean  := FPrefs.UseMarketPrc ;
  aStorage.FieldByName('LiquidTick').AsInteger    := FPrefs.LiquidTick ;
  aStorage.FieldByName('ConfirmSetNetQty').AsBoolean  := FPrefs.ConfirmSetNetQty ;
  aStorage.FieldByName('FixedHoga').AsBoolean         := FPrefs.FixedHoga;
  aStorage.FieldByName('UseShortCutOrd').AsBoolean  := FPrefs.UseShortCut;  ;
  aStorage.FieldByName('UseShortCutOrdConfirm').AsBoolean  := FPrefs.UseShortCutConfirm ;

  // 관심종목....
  for I := 1 to sgInterest.RowCount - 1 do
  begin
    aSymbol := TSymbol( sgInterest.Objects[0,i]);
    if aSymbol <> nil then
      aStorage.FieldByName('Symbol_'+IntToStr(i)).AsString := aSymbol.Code; ;
  end;

   // boards
  aStorage.FieldByName('boards.count').AsInteger := FBoards.Count; // number of boards
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    stBoard := Format('Board[%d]', [i]);

    if (aBoard <> nil) and (aBoard.Symbol <> nil) then
      aStorage.FieldByName(stBoard + '.symbol').AsString := aBoard.Symbol.Code
    else
      aStorage.FieldByName(stBoard + '.symbol').AsString := '';

    if (aBoard <> nil) and (aBoard.Fund <> nil) then
      aStorage.FieldByName(stBoard + '.FundName').AsString := aBoard.Fund.Name
    else
      aStorage.FieldByName(stBoard + '.FundName').AsString := '';

    aStorage.FieldByName(stBoard + '.Params.OrdHigh').AsInteger := aBoard.Params.OrdHigh;
    aStorage.FieldByName(stBoard + '.Params.OrdWid').AsInteger := aBoard.Params.OrdWid;

  end;
end;

procedure TFundBoardForm.sbtnActOrdQryClick(Sender: TObject);
begin
  //if not CheckInvest then Exit;
  //gEnv.Engine.SendBroker.RequestAccountFill( FInvest );
end;

procedure TFundBoardForm.sbtnPosQryClick(Sender: TObject);
begin
  //if not CheckInvest then Exit;
  //gEnv.Engine.SendBroker.RequestAccountPos( FInvest );
end;


procedure TFundBoardForm.MakeBoards;
var
  i: Integer;
  aBoard: TFundOrderBoard;
begin
  if FPrefs.BoardCount < FBoards.Count then
  begin
    for i := FBoards.Count-1 downto FPrefs.BoardCount do
      FBoards[i].Free;
  end else
  if FPrefs.BoardCount > FBoards.Count then
    for i := FBoards.Count to FPrefs.BoardCount - 1 do
    begin
      aBoard := NewBoard;
      aBoard.Params := FDefParams;
    end;
end;

procedure TFundBoardForm.MakeBoards(iCount: integer);
var
  i: Integer;
  aBoard: TFundOrderBoard;
  bSelectedDel : boolean;
begin
  FPrefs.BoardCount := iCount;

  if FPrefs.BoardCount < FBoards.Count then
  begin
    bSelectedDel  := false;
    for i := FBoards.Count-1 downto FPrefs.BoardCount do
    begin

      if (FSelectedBoard <> nil) and (FSelectedBoard = FBoards[i]) then
        bSelectedDel := true;
      FBoards[i].Free;
    end;

    if (bSelectedDel) and (FBoards.Count > 0) then
      BoardSelect( FBoards[0] );

  end else
  if FPrefs.BoardCount > FBoards.Count then
    for i := FBoards.Count to FPrefs.BoardCount - 1 do
    begin
      aBoard := NewBoard;
      aBoard.Params := FDefParams;
    end;

end;

//
// apply 'preferences'
//

procedure TFundBoardForm.ApplyPrefs;
var
  i: Integer;
  aBoard: TFundOrderBoard;
begin
    // reset selected reference
  if (FSelectedBoard <> nil)
     and (FSelectedBoard.Index > FPrefs.BoardCount-1) then
    FSelectedBoard := nil;

  if (FSelectedBoard <> nil)
     and (FSelectedBoard.Index > FPrefs.BoardCount-1) then
  begin
      // cancel board selection
    FPointOrders.Clear;
    FSelectedBoard := nil;
  end;
    // board count
  MakeBoards;

  cbOneClick.Checked  := not FPrefs.DbClickOrder;
  if FPrefs.MouseSelect then  
    rbMouseSelect.ItemIndex := 0
  else
    rbMouseselect.ItemIndex := 1;
  cbKeyOrder.Checked  := FPrefs.UseKeyOrder;

  if FPrefs.LastOrdCnl then
    rbLastOrdCnl.ItemIndex  := 0
  else
    rbLastOrdCnl.ItemIndex  := 1;

  cbHogaFix.Checked :=  FPrefs.AutoScroll;

  udPrfTick.Position  := FPrefs.PrfTick;
  udLosTick.Position  := FPrefs.LosTick;

  if FPrefs.UseMarketPrc then
    rbMarket.Checked  := true
  else
    rbHoga.Checked    := true;
  udLiqTick.Position  := FPrefs.LiquidTick;

  cbShortCutOrd.Checked := FPrefs.UseShortCut;
  cbConfirmOrder.Checked:= FPrefs.UseShortCutConfirm;
  cbHogaFix.Checked     := FPrefs.FixedHoga;

    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;

    aBoard.Tablet.DbClickOrder  := FPrefs.DbClickOrder;
    aBoard.Tablet.MouseSelect   := FPrefs.MouseSelect;
    aBoard.Tablet.LastOrdCnl    := FPrefs.LastOrdCnl;

    aBoard.Tablet.OrderColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_FONT];
    aBoard.Tablet.OrderColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_ORDER, IDX_BACKGROUND];
    aBoard.Tablet.OrderColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_FONT];
    aBoard.Tablet.OrderColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_ORDER, IDX_BACKGROUND];
    aBoard.Tablet.QuoteColors[ptLong, ctFont]  := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_FONT];
    aBoard.Tablet.QuoteColors[ptLong, ctBG]    := FPrefs.Colors[IDX_LONG,  IDX_QUOTE, IDX_BACKGROUND];
    aBoard.Tablet.QuoteColors[ptShort, ctFont] := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_FONT];
    aBoard.Tablet.QuoteColors[ptShort, ctBG]   := FPrefs.Colors[IDX_SHORT, IDX_QUOTE, IDX_BACKGROUND];

    aBoard.Resize;
    BoardSelect( aBoard );

  end;

    // adjust the form width
  SetWidth;
end;                 
//
// Set(Readjust) form width
//
procedure TFundBoardForm.SetWidth;
var
  i, iWidth: Integer;
begin

  FResize := false;

  iWidth := 0;

  if SpeedButtonLeftPanel.Down then
    iWidth := iWidth + SIDE_LEFT_PANEL_WIDTH;


  for i := 0 to FBoards.Count - 1 do
  begin
    iWidth := iWidth + FBoards[i].Width;
  end;

  if SpeedButtonRightPanel.Down then
    iWidth := iWidth + SIDE_RIGHT_PANEL_WIDTH;


  ClientWidth := iWidth;
  Left  := FLeftPos;

  FResize := true;


end;

procedure TFundBoardForm.sgAcntPLDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ACol = 0 then
      aBack := GRID_REVER_COLOR
    else begin
      aFont := TColor( Objects[ACol, ARow]);
      dFormat := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;
    aRect.Right := aRect.Right -2;
    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ACol = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end


end;

procedure TFundBoardForm.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ACol = 0 then
      aBack := clBtnFace
    else begin
      if ARow = Info_Last_Row then
        aFont := TColor( Objects[ACol, Info_Change_Row])
      else aFont := TColor( Objects[ACol, ARow]);
      dFormat := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;
    aRect.Right := aRect.Right -2;

    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ACol = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end

end;

procedure TFundBoardForm.sgInterestDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if (ACol = 0) or ( ARow = 0) then
      aBack := clBtnFace;

    if ( ARow > 0 ) and ( FSymbolRow = ARow ) then
      aBack := GRID_SELECT_COLOR;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;

    Canvas.Font.Name :='굴림체';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ACol = 0) or ( ARow = 0) then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;  
  end

end;

procedure TFundBoardForm.sgInterestMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    ACol, ARow : integer;
    aSymbol : TSymbol;
begin

  FSaveRow := -1;
  sgInterest.MouseToCell( X, Y, ACol, ARow );

  if Button = mbRight then
  begin
    if ( ARow > 0 ) then
    begin
      FSymbolRow  := ARow;
      FSaveRow := ARow;
      sgInterest.PopupMenu  := PopupMenu1;
    end
    else
      sgInterest.PopupMenu  := nil;
  end else
  if Button = mbLeft then
  begin
    if ( ARow > 0 ) then
    begin
    aSymbol := TSymbol( sgInterest.Objects[ 0, ARow] );
      if aSymbol <> nil then
      begin
        FSymbolRow := ARow;
        AddSymbolCombo( aSymbol, cbSymbol );
        cbSymbolChange( cbSymbol );
      end;
    end;
  end;   

  sgInterest.Repaint;
end;

procedure TFundBoardForm.sgInterestSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
  var
    aSymbol : TSymbol;
begin   {
  //
  if ( ARow > 0 ) then
  begin
    aSymbol := TSymbol( sgInterest.Objects[ ACol, ARow] );
    if aSymbol <> nil then
    begin
      AddSymbolCombo( aSymbol, cbSymbol );
      cbSymbolChange( cbSymbol );
      FSymbolRow := ARow;
    end;
    
  end;   }
end;


procedure TFundBoardForm.sgQuoteDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPosition : TFundPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  aBack   := clWhite;
  dFormat := DT_RIGHT or DT_VCENTER;
  aRect   := Rect;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
    begin
      aBack := clBtnFace;
      dFormat := DT_CENTER or DT_VCENTER;
    end
    else begin
      aFont := TColor( Objects[ACol, ARow]);
      aRect.Right := aRect.Right-2;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;

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
    end;

  end;

end;

procedure TFundBoardForm.sgSymbolPLDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPosition : TFundPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  aBack   := clWhite;
  dFormat := DT_RIGHT or DT_VCENTER;
  aRect   := Rect;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
    begin
      aBack := clBtnFace;
      dFormat := DT_CENTER or DT_VCENTER;
    end
    else begin

      if FSelectedBoard <> nil then
        aPosition := FSelectedBoard.FundPosition;

      if aPosition <> nil then
      begin

        case ACol of
          1, 2, 3: aFont := ifThenColor( aPosition.Volume > 0, clRed,
                       ifThenColor( aPosition.Volume < 0 , clBlue, clBlack ));

          5 :  aFont := ifThenColor( aPosition.EntryOTE > 0, clRed,
                        ifThenColor( aPosition.EntryOTE < 0 , clBlue, clBlack ));
        end;

        case ACol of
         0 : dFormat := DT_CENTER or DT_VCENTER;
        end;
      end;

    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 4;
    aRect.Right := aRect.Right-2;

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
    end;

  end;

end;

procedure TFundBoardForm.sgUnFillDblClick(Sender: TObject);
  var
    aSymbol : TSymbol;
    iTag : integer;
begin
  with Sender as TStringGrid do
  begin
    iTag := Tag;
    if FUnRow[iTag] > 0 then
    begin
      aSymbol := TSymbol( Objects[SymbolCol, FUnRow[iTag] ] );
      if aSymbol <> nil then
      begin
        AddSymbolCombo(aSymbol, cbSymbol );
        cbSymbolChange( cbSymbol );
      end;
    end;
  end;

end;

procedure TFundBoardForm.sgUnFillDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPos : TFundPosition;
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
        3 :
          begin
            if Tag = 1 then
            begin
              aPos  := TFundPosition( Objects[OrderCol, ARow]);
              if aPos <> nil then              
                if aPos.EntryOTE > 0 then aFont := clRed
                else if aPos.EntryOTE < 0 then aFont := clBlue;
            end
            else  aFont := TColor( Objects[ColorCol, ARow]);
            dFormat := DT_RIGHT or DT_VCENTER;
          end;
      end;

      if ( ARow mod 2 ) = 0 then
        aBack := GRID_REVER_COLOR
      else
        aBack  := clWhite;

      if gdSelected in State then
        aBack := GRID_SELECT_COLOR;
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
    end;

  end;
end;

procedure TFundBoardForm.sgUnFillMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    ACol, iTag : integer;
begin

  iTag := ( Sender as TStringGrid ).Tag;
  ( Sender as TStringGrid).MouseToCell( X, Y, ACol, FUnRow[iTAg]);
end;

procedure TFundBoardForm.ShowPositionVolume;
var
  i : integer;
  aPos : TFundPosition;
begin

  for i := 0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    aPos  := gEnv.Engine.TradeCore.FundPositions.FundPositions[i];
    SetPosition( aPos );
  end;
end;

//----------------------------------------------< TOrderTablet event handlers >

//
// TOrderTablet.OnNewOrder handler
//
procedure TFundBoardForm.BoardNewOrder(Sender: TOrderTablet;
  aPoint1, aPoint2: TTabletPoint);
var
  aBoard: TFundOrderBoard;
  iQty: Integer;
begin
    // check
  if (Sender = nil) or (Sender.Symbol = nil)
     or (aPoint1.AreaType <> taOrder) then Exit;

  if not CheckInvest then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order

  NewOrder(aBoard, aPoint1, aBoard.DefQty, aPoint1.Price);

end;


procedure TFundBoardForm.BoardPanelClickEvent(Sender: TObject; iDiv,
  iTag: integer);
begin
  if (Sender <> nil) and ( Sender <> FSelectedBoard) then Exit;

  if ( iDiv = 1 ) then
    gEnv.EnvLog( WIN_FUNDORD,
      Format('%s 시장가 %s %d Click', [  LogTitle, ifThenStr( iTag > 0, '매수','매도'),
        FSelectedBoard.DefQty  ])   );

  case iDiv of
    1 :
      case iTag of
        1 : // 시장가 매수    ;
            NewOrder( FSelectedBoard, 1, FSelectedBoard.DefQty, 0 , pcMarket );
        -1: // 시장가 매도   ;
            NewOrder( FSelectedBoard, -1, FSelectedBoard.DefQty, 0 , pcMarket );
      end;

  end;
end;

procedure TFundBoardForm.BoardPosUpdate(Sender, Value: TObject);
begin
//  if FSelectedBoard <> Sender then Exit;
  UpdatePositionInfo( Value as TFundPosition);
end;

//
// TOrderTablet.OnChangeOrder handler
//
procedure TFundBoardForm.BoardChangeOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TFundOrderBoard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order
  ChangeOrder(aBoard, aPoint1, aPoint2)
  {
    DoEnvLog(Self, '[OrderBoard] change order(s) sent by <Mouse Move> as '
         + Format('(%s: %.2f->%.2f)', [POSITIONTYPE_DESCS[aPoint1.PositionType],
                                       aPoint1.Price, aPoint2.Price]));
                                       }
end;

procedure TFundBoardForm.BoardEnvEventHander(Sender: TObject;
  DataObj: TObject; etType: TEventType; vtType: TValueType);
begin

  if DataObj = nil then Exit;
  case etType of
    etSpace :  OtherBoardScrollToLastPrice;
    etStop  :
      begin
        BoardEventStopOrder( vtType, DataObj );
      end;
    etInterest  : SetInterestSymbols;
  end;

end;

procedure TFundBoardForm.BoardEventStopOrder( vtType : TValueType; DataObj : TObject );
var
  I: Integer;
begin
  for I := 0 to FBoards.Count - 1 do
    FBoards[i].OnStopOrderEvent( Self, DataObj, vtType);
end;

procedure TFundBoardForm.BoardLastCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TFundOrderBoard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;
    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  CancelLastOrder( aBoard );
end;

procedure TFundBoardForm.BoardNewOrder;
begin
  if FSelectedBoard = nil then Exit;

  FSelectedBoard.Tablet.NewOrder;
end;


procedure TFundBoardForm.OnAccount(aInvest: TInvestor; EventID: TDistributorID);
begin

end;

procedure TFundBoardForm.OnAccount(aInvest: TInvestor);
begin

end;

procedure TFundBoardForm.OtherBoardScrollToLastPrice;
var
  i : integer;
begin
  for i := 0 to FBoards.Count - 1 do
    FBoards[i].Tablet.ScrollToLastPrice;
end;

//
// TOrderTablet.OnCancelOrder handler
//
procedure TFundBoardForm.BoardAcntSelect(aBoard : TFundOrderBoard);
var
  i, k: Integer;
  aAccount : TAccount;
  aOrder   : TOrder;
  bSend    : boolean;
begin

  aBoard.Tablet.RefreshDraw;
  // fund 가 nil 이면..tablet 을 깨끗이 지워주고..
  //if aBoard.Fund = nil then Exit;

  bSend := false;
  if aBoard.Fund <> nil then  
    for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
    begin
      aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

      for k := 0 to aBoard.Fund.FundItems.Count - 1 do
      begin

        if (aOrder.State = osActive)
           and (aOrder.Account = aBoard.Fund.FundAccount[k]) then
           begin
             // 계좌만 같은건 미체결 그리드로 보낸다.
             DoOrder( aOrder );
             // tablet 에는   종목까지 같은거
             if (aOrder.Symbol = aBoard.Symbol) then
             begin
               aBoard.Tablet.DoOrder2(aOrder);
               bSend := true;
             end;
           end;
      end;
    end;

  if bSend then
    aBoard.Tablet.RefreshTable;

  aBoard.UpdatePositionInfo;
  aBoard.UpdateOrderLimit;

end;

procedure TFundBoardForm.BoardCancelOrder(Sender: TOrderTablet; aPoint1,
  aPoint2: TTabletPoint);
var
  aBoard: TFundOrderBoard;
begin
  if (Sender = nil) or (Sender.Symbol = nil) then Exit;

    // identify board where the tablet is
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

    // send order
  CancelOrders(aBoard, aPoint1)
  //    DoEnvLog(Self, '[OrderBoard] change order(s) sent by <Mouse Move>');
end;



procedure TFundBoardForm.BoardSelectCell(Sender: TOrderTablet;
  aPoint1, aPoint2: TTabletPoint);
var
  i: Integer;
  aItem: TListItem;
  aOrder: TOrder;
  iSum: Integer;
  stPosition: String;
  aBoard: TFundOrderBoard;
begin

  if Sender = nil then Exit;

    // get board
  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  if FSelectedBoard = nil then
    BoardSelect(aBoard);

  if aBoard <> FSelectedBoard then Exit;

    // set order list
  if (aPoint1.AreaType = taInfo) and ( aPoint1.RowType = trInfo ) and
     (aPoint1.ColType = tcQuote ) then
  begin
    FSelectedBoard.SetPositionVolume;
  end;

  if aPoint1.AreaType <> taOrder then Exit;
  try
    FPointOrders.Clear;
      // save the point
    FCancelPoint := aPoint1;

      // get order list
    Sender.GetOrders(aPoint1, FPointOrders);
      // sort order list
    FPointOrders.SortByAcptTime;
  finally
  end;

end;

procedure TFundBoardForm.btnAbleNetClick(Sender: TObject);
var
  aDlg  : TFrmLiqMode;
begin
  if btnAbleNet.Down  then
  begin
    if btnAbleNet.Tag = 0 then
    begin
      btnAbleNet.Down := false;
      Exit;
    end;
    // confirm
    if FFund <> nil then
      if not gEnv.BoardCon.TodayNoShowDlg then
        try
          aDlg  :=  TFrmLiqMode.Create( Self );
          if not aDlg.Open( FFund.Name, btnAbleNet.Tag) then
          begin
            btnAbleNet.Down := false;
            Exit;
          end;
          gEnv.BoardCon.TodayNoShowDlg := aDlg.cbConfirm.Checked;
        finally
          aDlg.Free;
        end;
  end;

end;

//--------------------------------------------------------------< send orders >

//
// send a new order
// here, iVolume is signed integer
//

function TFundBoardForm.NewOrder(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
  iVolume: Integer; dPrice: Double ): TOrder;
var
  aTicket: TOrderTicket;
  iRes  : integer;
  I, iMulti: Integer;
  aPos : TPosition;
begin
  Result := nil;

  if not CheckInvest then Exit;
    // check
  if (aBoard.Fund = nil) or (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
      or (iVolume = 0) then
  begin
    Beep;
    Exit;
  end;

    //
  Application.ProcessMessages;

    // check if 'clearorder' flag set
  if aBoard.ClearOrder and (aBoard.OrderType = aPoint.PositionType) then
  begin
    Beep;
    Exit;
  end;

    // short order volume
  if aPoint.PositionType = ptShort then
    iVolume := -iVolume;


  if btnAbleNet.Down then
  begin
    if aBoard.FundPosition = nil then Exit;
    if aBoard.FundPosition.Volume = 0 then
    begin
      ShowMessage('해당펀드의 잔고가 없습니다. 부분체결잔고 버튼 클릭을 해제하세요');
      Exit;
    end;

    for I := 0 to aBoard.FundPosition.Positions.Count - 1 do
    begin
      aPos := aBoard.FundPosition.Positions.Positions[i];
      if aPos = nil then continue;
      if aPos.Volume = 0 then continue;

      //iMulti  := aBoard.Fund.FundItems.FindMultiple( aPos.Account );
      iVolume := abs( aPos.volume );
      if aPoint.PositionType = ptShort then
        iVolume := -iVolume;

      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                    gEnv.ConConfig.UserID, aPos.Account , aBoard.Tablet.Symbol,
                    iVolume,
                    pcLimit, dPrice, tmGTC, aTicket);  //
      Result.OwnForm  := self;

      if Result <> nil then
      begin
        iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
        gEnv.Engine.TradeCore.Orders.DoNotify( Result );
        Result.FundName := FFund.Name;

        gEnv.EnvLog( WIN_FUNDORD, Format('Send %s 부분체결 청산 Order(%d) : %s, %s, %s, %.*n, %d', [
          aBoard.Fund.Name,
          i, Result.Account.Code, Result.Symbol.ShortCode, ifThenStr( Result.Side > 0, '매수','매도'),
          Result.Symbol.Spec.Precision, dPrice, Result.OrderQty ])    );
      end;
    end;

  end
  else begin
      // issue an order ticket
    for I := 0 to aBoard.Fund.FundItems.Count - 1 do
    begin
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        // create normal order
      Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                    gEnv.ConConfig.UserID, aBoard.Fund.FundAccount[i] , aBoard.Tablet.Symbol,
                    iVolume * aBoard.Fund.FundItems[i].Multiple,
                    pcLimit, dPrice, tmGTC, aTicket);  //
      Result.OwnForm  := self;

      if Result <> nil then
      begin
        iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
        gEnv.Engine.TradeCore.Orders.DoNotify( Result );
        Result.FundName := FFund.Name;

        gEnv.EnvLog( WIN_FUNDORD, Format('Send %s New Order(%d) : %s, %s, %s, %.*n, %d X %d', [
          aBoard.Fund.Name,
          i, Result.Account.Code, Result.Symbol.ShortCode, ifThenStr( Result.Side > 0, '매수','매도'),
          Result.Symbol.Spec.Precision, dPrice, iVolume,aBoard.Fund.FundItems[i].Multiple])    );
      end;
    end;
  end;

    //
  if iRes > 0 then
  begin
    aBoard.SentTime := timeGetTime;
  end;
end;

function TFundBoardForm.NewOrder(aBoard: TFundOrderBoard; iSide, iVolume: Integer;
  dPrice: Double; pcValue: TPriceControl): TOrder;
var
  aTicket: TOrderTicket;
  i, iRes  : integer;
begin
  Result := nil;

  if not CheckInvest then Exit;

    // check
  if (aBoard.Fund = nil) or (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
      or (iVolume = 0) then
  begin
    Beep;
    Exit;
  end;
    //
  Application.ProcessMessages;
    // short order volume
  if iSide < 0 then
    iVolume := -iVolume;

    // send the order
  iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
  gEnv.Engine.TradeCore.Orders.DoNotify( Result );

  for I := 0 to aBoard.Fund.FundItems.Count - 1 do
  begin
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      // create normal order
    Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                  gEnv.ConConfig.UserID, aBoard.Fund.FundAccount[i] , aBoard.Tablet.Symbol,
                  iVolume * aBoard.Fund.FundItems[i].Multiple,
                  pcValue, dPrice, tmGTC, aTicket);  //
    Result.OwnForm  := self;

    iRes :=  gEnv.Engine.TradeBroker.Send(aTicket);
    gEnv.Engine.TradeCore.Orders.DoNotify( Result );
    if Result <> nil then Result.FundName := FFund.Name;
    gEnv.EnvLog( WIN_FUNDORD, Format('Send %s New Order(%d) : %s, %s, %s, %.*n, %d X %d', [
      aBoard.Fund.Name,
      i, Result.Account.Code, Result.Symbol.ShortCode, ifThenStr( Result.Side > 0, '매수','매도'),
      Result.Symbol.Spec.Precision, dPrice, iVolume,aBoard.Fund.FundItems[i].Multiple])    );
  end;

    //
  if iRes > 0 then
  begin
    aBoard.SentTime := timeGetTime;
  end;

end;

//
// send change orders
//
function TFundBoardForm.ChangeOrder(aBoard: TFundOrderBoard;
  aPoint1, aPoint2: TTabletPoint): Integer;
var
  i, iOrderQty: Integer;
  pOrder, aOrder: TOrder;
  aTicket: TOrderTicket;
  iMaxQty, iQty: Integer ;
begin
  Result := 0;

    // check
  if  (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Fund = nil then Exit;
  
 {
    // confirm
  if FPrefs.ConfirmOrder then
    if  MessageDlg(
           Format('%s 주문 (%.2f -> %.2f)을 정정하시겠습니까?',
             [POSITIONTYPE_DESCS[aPoint1.PositionType],
              aPoint1.Price, aPoint2.Price]),
                    mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
   }
    // clear order list
  FTargetOrders.Clear;

    // get target orders to change
  if aBoard.Tablet.GetOrders(aPoint1, FTargetOrders) = 0 then Exit;

    // send changed orders for selected orders
  if (aBoard.Tablet.Symbol = FCancelPoint.Tablet.Symbol)
     and (aPoint1.Tablet = FCancelPoint.Tablet)
     and (aPoint1.Index = FCancelPoint.Index)
     and (aPoint1.PositionType = FCancelPoint.PositionType) then
  begin

    for i := 0 to FPointOrders.Count-1 do
    begin
        aOrder := FPointOrders[i];
          // check
        if (aOrder = nil) or (aOrder.OrderType <> otNormal)
           or (aOrder.ActiveQty = 0) then Continue;

        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
          // generate order
        pOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                          aOrder, aOrder.ActiveQty, pcLimit, aPoint2.Price,
                          tmGTC, aTicket);
        if pOrder <> nil then
        begin
          pOrder.OwnForm  := self;
          gEnv.Engine.TradeBroker.Send(aTicket);
        end;
    end;
  end else
    // -- 선택셀이 아닐 경우는 전체 정정
  begin
    for i := 0 to FTargetOrders.Count-1 do
    begin
      aOrder := FTargetOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        pOrder  := gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                        aOrder, aOrder.ActiveQty, pcLimit, aPoint2.Price,
                        tmGTC, aTicket);
        if pOrder <> nil then
        begin
          pOrder.OwnForm  := self;
          gEnv.Engine.TradeBroker.Send(aTicket);
        end;
      end;
    end;
  end;

    // send the order
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;

//
// send change orders, called from the popup menu
//
function TFundBoardForm.ChangeOrder(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
  iMaxQty: Integer; dPrice: Double): Integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;
    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil)
     or (iMaxQty <= 0) then Exit;

  if aBoard.Fund = nil then Exit;
    // init
  iQty := 0;

    // clear order list
  FTargetOrders.Clear;

    // get order list
  if aBoard.Tablet.GetOrders(aPoint, FTargetOrders) = 0 then Exit;

    // generage orders
  for i := 0 to FTargetOrders.Count-1 do
  begin
    aOrder := FTargetOrders[i];

      // recheck
    if (aOrder.OrderType <> otNormal) or (aOrder.State <> osActive)
       or (aOrder.ActiveQty <= 0) then Continue;

      // get change volume
    iOrderQty := Min(iMaxQty - iQty, aOrder.ActiveQty);
    if iOrderQty <= 0 then Break;

    // get a order ticket
    aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      // generate order
    gEnv.Engine.TradeCore.Orders.NewChangeOrder(
                      aOrder, iOrderQty, pcLimit, dPrice,
                      tmGTC, aTicket);
    gEnv.Engine.TradeBroker.Send(aTicket);                      

      //
    iQty := iQty + iOrderQty;
  end;

    // send orders
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;


procedure TFundBoardForm.CheckLossCut(aQuote: TQuote);
var
  stLog : string;
begin
  if not cbAcntLisk.Checked then Exit;
  if FSelectedBoard = nil then Exit;

  if FSelectedBoard.FundPosition <> nil then
  begin
    if (-FLiskAmt > FSelectedBoard.FundPosition.EntryOTE) and ( FLiskChange ) then
    begin
      // 손절 주문....
      FLiskChange := false;
      LossCutOrder( FSelectedBoard, aQuote );
      cbAcntLisk.Checked  := false;

      stLog := Format('%s, %s 손절 -->>  설정(%s)  손익 ( %s)', [
        FSelectedBoard.Fund.Name,
        FSelectedBoard.FundPosition.Symbol.ShortCode,
        Formatfloat('#,##0.###', FLiskAmt ),
        Formatfloat('#,##0.###', FSelectedBoard.FundPosition.EntryOTE ) ]);
      gLog.Add( lkLossCut, 'TFundBoardForm','CheckLossCut', stLog );
    end;
  end;
end;

//
// send cancel order, called from TOrderTablet event handler
//

function TFundBoardForm.CancelLastOrder( aBoard : TFundOrderBoard ) : integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder, pOrder: TOrder;
  aList : TList;
  j: Integer;
begin
  Result := 0;

  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Fund = nil then Exit;
  {
    // confirm
  if FPrefs.ConfirmOrder then
    if MessageDlg('주문을 취소하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
   }
    // init
  iQty := 0;
  aOrder := nil;

  try

    aList := TList.Create;

    for j := 0 to aBoard.Fund.FundItems.Count - 1 do
      for i := gEnv.Engine.TradeCore.Orders.ActiveOrders.Count-1 downto 0 do
      begin
        aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders.Orders[i];
        if aOrder = nil then Continue;
        if ( aOrder.Symbol = aBoard.Tablet.Symbol) and
           ( aOrder.Account = aBoard.Fund.FundAccount[j] ) and
           ( aOrder.State = osActive ) then
        begin
          if (aOrder = nil) or (aOrder.OrderType <> otNormal) or (aOrder.ActiveQty = 0) then
            Continue
          else begin
            aList.Add( aOrder);
            break;
          end;
        end;
      end;

    for I := 0 to aList.Count - 1 do
    begin
      aOrder  := TOrder( aList.Items[i] );
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      pOrder  := gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
      if pOrder <> nil then
      begin
        Result := gEnv.Engine.TradeBroker.Send(aTicket);
        gEnv.EnvLog( WIN_FUNDORD , Format('Last %s Ord Cnl(%d) -> %s, %s, %s, %d',[
          aBoard.Fund.Name, i, aOrder.Account.Code, aOrder.Symbol.ShortCode,
          ifThenStr( aOrder.Side > 0, '매수','매도'),aOrder.ActiveQty
          ])  );
      end;
    end;

  finally
    aList.Free;
  end;


end;

function TFundBoardForm.CancelOrders(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
  iMaxQty: Integer): Integer;
var
  i, iQty, iOrderQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
  aDummy: TTabletPoint ;
begin
  Result := 0;

    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Fund = nil then Exit;
        // init
  iQty := 0;

    // clear order list
  FTargetOrders.Clear;

    // get order list
  if aBoard.Tablet.GetOrders(aPoint, FTargetOrders) = 0 then Exit;
                                                   
    // get a order ticket

  if FCancelPoint.Tablet = nil then
    BoardSelectCell( aBoard.Tablet,  aPoint, aDummy );
    //FCancelPoint  := aPoint;
    // if canceling for the selected cell, send cancel orders for
    // only selected orders
  if (aBoard.Tablet.Symbol = FCancelPoint.Tablet.Symbol)
     and (aPoint.Tablet = FCancelPoint.Tablet)
     and (aPoint.Index = FCancelPoint.Index)
     and (aPoint.PositionType = FCancelPoint.PositionType) then
  begin

    for i := 0 to FPointOrders.Count-1 do
    begin
        aOrder := FPointOrders[i];

        if (aOrder = nil) or (aOrder.OrderType <> otNormal)
           or (aOrder.ActiveQty = 0) then Continue;

          // generate order
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
        Result := gEnv.Engine.TradeBroker.Send(aTicket);

    end;
  end else
    // cancel all if it not a selected cell
  begin
    for i := 0 to FTargetOrders.Count-1 do
    begin
      aOrder := FTargetOrders[i];

      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then
      begin
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
        Result := gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;
  end;
    // send the order
end;

//
// send cancel orders, called from the Popup menu
//
function TFundBoardForm.CancelOrders(aBoard: TFundOrderBoard;
  aTypes: TPositionTypes): Integer;
var
  i, iQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;
        // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Fund = nil then Exit;

    // init
  iQty := 0;

    // clear list
  FTargetOrders.Clear;

    // get orders from the tablet
  if aBoard.Tablet.GetOrders(aTypes, FTargetOrders) = 0 then Exit;

    // generate orders
  for i := 0 to FTargetOrders.Count - 1 do
  begin
    aOrder := FTargetOrders[i];

    if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then begin
        // get a ticket
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
      gEnv.Engine.TradeBroker.Send(aTicket);
    end;
  end;

    // send
  //Result := gEnv.Engine.TradeBroker.Send(aTicket);
end;

function TFundBoardForm.CancelOrders(aTablet: TOrderTablet;
  aTypes: TPositionTypes): Integer;
  var
    aBoard : TFundOrderBoard;
begin

  result := -1;
  aBoard := FBoards.Find(aTablet);
  if aBoard = nil then Exit;

  CancelOrders( aBoard, aTypes );

  result := 1;
end;

procedure TFundBoardForm.CenterAlign;
var
  i : integer;
begin
  for i := 0 to FBoards.Count - 1 do
    FBoards[i].Tablet.ScrollToLastPrice;
end;

//------------------------------------------------------------< trade events >

procedure TFundBoardForm.TradeBrokerEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  iID: Integer;
begin
  if DataObj = nil then Exit;
  
  if (Receiver = Self) then
    case DataID  of
      TRD_DATA :
          case Integer(EventID) of
            // order events
            ORDER_NEW,
            ORDER_ACCEPTED,
            ORDER_REJECTED,
            ORDER_CHANGED,
            ORDER_CONFIRMED,
            ORDER_CONFIRMFAILED,
            ORDER_CANCELED,
            ORDER_FILLED: DoOrder(DataObj as TOrder, EventID);
         end;
      FPOS_DATA :
        case Integer(EventID) of
          FPOSITION_NEW,
          FPOSITION_UPDATE :  DoPosition(DataObj as TFundPosition, EventID);
        end;
      FUND_DATA :
        case Integer(EventID) of
          FUND_NEW,
          FUND_DELETED,
          FUND_UPDATED,           // = 242;   // 펀드 이름 변경
          FUND_ACNT_UPDATE : DoFund( DataObj as TFund, EventID );        //  = 243;   // 펀드에 계좌 변경
        end;
    end;

end;



procedure TFundBoardForm.udControlClick(Sender: TObject; Button: TUDBtnType);
var
  i,iCount : Integer;
  aBoard : TFundOrderBoard;
begin
  FLeftPos  := Left;
  iCount := FBoards.Count;

  case Button of
    btNext: inc( iCount );
    btPrev:
      begin
        if FBoards.Count = 1 then
          Exit;
        dec( iCount );
      end;
  end;

  MakeBoards( iCount );

    // apply common parameters
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    aBoard.Tablet.AutoScroll := FPrefs.AutoScroll;
    aBoard.Tablet.TraceMouse := FPrefs.TraceMouse;
  end;

  SetWidth;

end;



procedure TFundBoardForm.DoOrder(aOrder: TOrder);
var
  aType : TOrderListType;
  iRow, iGap  : integer;
  aCk : TCheckBox;

  procedure UpdateOrder( iRow : integer );
  begin
    with sgUnFill do
    begin
      Cells[1,iRow]  := aOrder.Symbol.ShortCode;
      Cells[2,iRow]  := ifThenStr( aOrder.Side > 0, 'L', 'S' );
      Cells[3,iRow]  := IntToStr( aOrder.ActiveQty );
      Objects[OrderCol, iRow] := aOrder;
      Objects[SymbolCol,iRow] := aOrder.Symbol;
      Objects[ColorCol, iRow] := Pointer(ifThenColor( aOrder.Side > 0, clRed, clBlue ));
    end;

  end;

  procedure AddOrder( aOrder : TOrder );
  var
    I: Integer;
    aCK : TCheckBox;
  begin
    if iRow < 0 then
    begin
      iRow := 1;
      InsertLine( sgUnFill, iRow );

      aCK := TCheckBox.Create( Self );
      aCK.Left  := cbUnFillAll.Left;
      aCK.Height:= cbUnFillAll.Height;
      aCk.Width := cbUnFillAll.Width;
      aCK.Top   := cbUnFillAll.Top + sgUnFill.RowHeights[0];
      aCK.Parent:= cbUnFillAll.Parent;
      sgUnFill.Objects[CheckCol, iRow]  := aCK;

      for I := iRow+1 to sgUnFill.RowCount - 1 do
      begin
        aCK := TCheckBox( sgUnFill.Objects[CheckCol, i]);
        if aCk <> nil then
          aCK.Top := cbUnFillAll.Top + (sgUnFill.RowHeights[0] * i) + i;
      end;
    end;

    UpdateOrder( iRow );
  end;

  procedure DeleteOrder( aOrde : TOrder );
  var
    i : integer;
    aCK : TCheckBox;
  begin
    if iRow < 0 then
      Exit
    else begin
      aCK := TCheckBox( sgUnFill.Objects[CheckCol, iRow]);
      if aCK <> nil then 
        aCK.Free;
      DeleteLine( sgUnFill, iRow );

      for I := 1 to sgUnFill.RowCount - 1 do
      begin
        aCK := TCheckBox( sgUnFill.Objects[CheckCol, i]);
        if aCk <> nil then
          aCK.Top := cbUnFillAll.Top + (sgUnFill.RowHeights[0] * i) + i;
      end;
    end;
  end;

begin
  if aOrder = nil then Exit;

  iRow := sgUnFill.Cols[OrderCol].IndexOfObject( aOrder );

  if (aOrder.State = osActive) then
    aType := olAdd
  else
    aType := olDelete;

  case aType of
    olAdd: AddOrder( aOrder );
    olDelete: DeleteOrder( aOrder );
  end;

  with sgUnFill do
  begin
    iGap := Width - ClientWidth ;

    if FUfLastGap > 0 then
      if (iGap > FUfLastGap) and ( FUfColWidth = ColWidths[ChangeCol] )  then
        ColWidths[ChangeCol] := ColWidths[ChangeCol] - iGap + 1
      else  if iGap < FUfLastGap then
        ColWidths[ChangeCol] := FUfColWidth;

    if (RowCount > 3) and ( FixedRows > 0 ) then
      FixedRows := 1;
  end;

  FUfLastGap := iGap;

end;

procedure TFundBoardForm.DoOrder(aOrder: TOrder; EventID: TDistributorID);
var
  i: Integer;
  aBoard: TFundOrderBoard;
  aDummy: TTabletPoint;
  stSpeed: String;
  iSpeed: Integer;

  OrderSpeed : Integer;
  bLeft, bRight : Boolean ;


  bPrf, bLos: boolean;
  iPrf, iLos, iTick: integer;
  pcValue : TPriceControl;
begin

  if (aOrder = nil) or (aOrder.PriceControl in [pcMarket, pcBestLimit]) then Exit;

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];
    if aBoard.Fund = nil then Continue;

    if aBoard.Fund.FundItems.Find( aOrder.Account ) = nil then Continue;
    DoOrder( aOrder );
    
    if aBoard.Symbol <> aOrder.Symbol then Continue;

      // apply to the tablet
    aBoard.Tablet.DoOrder(aOrder);

      // order speed
    if (EventID in [ORDER_NEW, ORDER_CHANGED, ORDER_ACCEPTED])
      and (aOrder.OrderType = otNormal)
      and (aOrder.State = osActive) then
    begin
      stSpeed := aBoard.OrderSpeed;

      iSpeed := timeGetTime - aBoard.SentTime;

      if iSpeed < 2000 then
        stSpeed := Format('%d', [iSpeed])
      else
        stSpeed := aBoard.OrderSpeed;
        //
      aBoard.OrderSpeed := stSpeed;
        //

    end;

    if (EventID in [ORDER_FILLED]) and ( aOrder.OwnForm = Self ) then
    begin

      bPrf  := cbPrfLiquid.Checked;
      bLos  := cbLosLiquid.Checked;

      if ( not bPrf ) and ( not bLos ) then Exit;

      iPrf  := StrToIntDef( edtPrfTick.Text, 5 );
      iLos  := StrToIntDef( edtLosTick.Text, 5 );
      iTick := StrToIntDef( edtLiqTick.Text, 0 );

      if rbMarket.Checked then
        pcValue := pcMarket
      else
        pcValue := pcLimit;

      aBoard.OnFill( aOrder,
        bPrf, bLos, iPrf, iLos, iTick, pcValue
       );
    end;

      // update order limit
    aBoard.UpdateOrderLimit;
  end;

  if aBoard.Tablet = FCancelPoint.Tablet then
  begin
    MatchTablePoint( aBoard, FCancelPoint, aDummy);

  end;
end;


procedure TFundBoardForm.MatchTablePoint( aBoard : TFundOrderBoard;
  aPoint1, aPoint2: TTabletPoint);
var
  i: Integer;
  aItem: TListItem;
  aOrder: TOrder;
  iSum: Integer;
  stPosition: String;
  aTablet : TOrderTablet;
  theOrders: TOrderList;

  stTmp : string;
  is1, is2, is3, is4 : int64;

begin

  aTablet := aBoard.Tablet;
    // set order list
  if (aPoint1.AreaType = taInfo) and ( aPoint1.RowType = trInfo ) and
     (aPoint1.ColType = tcQuote ) then
  begin
    aBoard.SetPositionVolume;
  end;

  if aPoint1.AreaType <> taOrder then Exit;

  theOrders := nil;

  try
    theOrders := TOrderList.Create;

      // save the point
    FCancelPoint := aPoint1;

      // get order list
    aTablet.GetOrders(aPoint1, theOrders);

      // sort order list
    theOrders.SortByAcptTime;

      // populate list view on the right side pane
    iSum := 0;
    FPointOrders.Clear;

    for i := 0 to theOrders.Count-1 do
    begin
      aOrder := theOrders[i];
      FPointOrders.Add( aOrder );
    end;
      // todo: reset click?
    for i := 0 to FBoards.Count - 1 do
      if FBoards[i].Tablet <> aTablet then
        FBoards[i].Tablet.ResetClick;
  finally
    theOrders.Free;
  end;

end;

procedure TFundBoardForm.DoFund(aFund: TFund; EventID: TDistributorID);
var
  i : integer;
  bSelf : boolean;
  tmpFund : TFund;
begin
  case integer( EventID ) of
    FUND_NEW  : begin
        ComboBoAccount.Items.AddObject( aFund.Name, aFund );
        if FFund = nil then
        begin
          ComboBoAccount.ItemIndex  := 0;
          ComboBoAccountChange( nil ) ;
        end;
       end;
    FUND_DELETED :
      begin
        i := ComboBoAccount.Items.IndexOfObject( aFund );
        if i >= 0 then
        begin
          bSelf :=  i = ComboBoAccount.ItemIndex;
          ComboBoAccount.Items.Delete( i );
          if ComboBoAccount.Items.Count > 0 then
          begin
            if bSelf then
              ComboBoAccount.ItemIndex  := 0
            else
              SetComboIndex( ComboBoAccount,FFund  );
            ComboBoAccountChange( nil ) ;
          end else begin
            ComboBoAccount.Clear;
            FFund := nil;
            for I := 0 to FBoards.Count - 1 do
              FBoards[i].Fund := nil;
          end;
        end;

        if ComboBoAccount.Items.Count <= 0 then
        begin
          FFund := nil;
          GetMarketAccount;
        end;
      end ;
    FUND_UPDATED ,FUND_ACNT_UPDATE:
      begin
        ComboBoAccount.Clear;
        // 편드의 계좌 추가및 삭체가 될수 있으므로..다시 편드 셋팅.
        tmpFund := FFund;
        FFund   := nil;
        gEnv.Engine.TradeCore.Funds.GetList( ComboBoAccount.Items);
        if tmpFund = nil then
          ComboBoAccount.ItemIndex  := 0
        else
          SetComboIndex( ComboBoAccount,tmpFund  );
        ComboBoAccountChange( nil ) ;
      end    ;
  end;
end;

procedure TFundBoardForm.DoPosition(aPosition: TFundPosition; EventID: TDistributorID);
var
  aBoard: TFundOrderBoard;
  i: Integer;
begin

  if (FFund = nil) or (aPosition.Fund <> FFund) then Exit;

  SetPosition(aPosition);
    // update position info for the board
  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if (aBoard.Symbol = aPosition.Symbol) and (aBoard.Fund = aPosition.Fund )  then
    begin
      aBoard.FundPosition := aPosition;
      aBoard.UpdatePositionInfo;
      aBoard.UpdateOrderLimit;
      //break;
    end;
  end;

  UpdateTotalPl;
end;


procedure TFundBoardForm.edtLiqTickChange(Sender: TObject);
begin
  case (Sender as TEdit).Tag of
    0 : FPrefs.PrfTick := StrToIntDef( edtPrfTick.Text, 5 );
    1 : FPrefs.LosTick := StrToIntDef( edtLosTick.Text, 5 );
    2 : FPrefs.LiquidTick := StrToIntDef( edtLiqTick.Text, 0 );
    3 : FPrefs.StopTick   := StrToIntDef( edtStopTick.Text, 0 );
  end;
end;

procedure TFundBoardForm.edtLiskAmtKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFundBoardForm.edtOpenLiskAmtChange(Sender: TObject);
begin
  if FLiskChange then
   cbAcntLisk.Checked := false;
end;

procedure TFundBoardForm.edtOpenLiskAmtKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFundBoardForm.edtOrderQtyChange(Sender: TObject);
var
  iQTy : integer;
begin
  iQty  := StrToIntDef( edtOrderQty.Text, 0  );
  if iQty > 0 then
    FSelectedBoard.SetOrderVolume( iQty, true);
end;

procedure TFundBoardForm.edtPrfTickKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFundBoardForm.edtTmpQtyExit(Sender: TObject);
begin
  if LastButton <> nil then
  begin
    LastButton.Caption  := edtTmpQty.Text;
  end;
  edtTmpQty.Hide;
  Lastbutton := nil;
end;


procedure TFundBoardForm.edtTmpQtyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

//-------------------------------------------------------------< quote evnets >



procedure TFundBoardForm.QuoteBrokerEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  i: Integer;
  aBoard: TFundOrderBoard;
  stTime: String;
  aQuote: TQuote;
begin
  if DataObj = nil then Exit;

  aQuote := DataObj as TQuote;

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard.Quote <> aQuote then Continue;

    //aBoard.CheckJackPotOrder( aQuote );

    case aQuote.LastEvent of
      qtTimeNSale:
        begin
            // if it's the first feed, initialize tablet
          if not aBoard.Tablet.Ready then
            aBoard.Tablet.Ready := True;

          aBoard.TNSCount := aBoard.TNSCount + 1;

         if FPrefs.FixedHoga then
          begin
            aBoard.Tablet.UpdatePrice( false );
            aBoard.Tablet.ScrollToLastPrice;
          end else
          begin
            aBoard.Tablet.UpdatePrice;
          end;

          aBoard.TickPainter.Update;

          if aBoard.FundPosition <> nil then begin
            //aBoard.Position.DoQuote( aBoard.Quote );
            //aBoard.UpdateEvalPL;
            aBoard.UpdatePositionInfo;
            //UpdateTotalPl;
          end;

         if aBoard.TNSCount <= 1 then
            aBoard.Tablet.ScrollToLastPrice;

            // display info
          if (aBoard = FSelectedBoard) and ( SpeedButtonRightPanel.Down )then
          begin
            SetInfo( aBoard, true );
          end;

          CheckLossCut( aQuote );
          CalcVolumeNCntRate( aQuote );

        end;
      qtMarketDepth:
        begin
          aBoard.Tablet.UpdateQuote;
          aBoard.TickPainter.Update2;
        end;
      qtCustom:
        begin
          aBoard.Tablet.Symbol  := aQuote.Symbol;
          aBoard.Tablet.Quote   := aQuote;
          aBoard.Tablet.Ready   := True;
          //end;                  
          aBoard.Tablet.UpdateQuote;
          aBoard.Tablet.UpdatePrice(not FPrefs.FixedHoga);
          aBoard.Tablet.ScrollToLastPrice;

          BoardAcntSelect( aBoard );
            // display info
          if (aBoard = FSelectedBoard) and ( SpeedButtonRightPanel.Down )then
          begin
            SetInfo( aBoard, true );
          end;
        end;
    end;

  end;
end;

procedure TFundBoardForm.UpdateData;
var
  d1, d2, dVal : double;
  
begin
  with sgQuote do
  begin
    dVal := 0;

    if ( FAskCnt = 0 ) or ( FBidCnt = 0 ) then
      dVal := 0
    else begin
      d1  := FAskCnt / FBidCnt;
      d2  := FBidCnt / FAskCnt;
      dVal:= min( d1, d2 );
    end;
    Cells[1,1]  :=  Formatfloat('##0.##',  dVal  );
    Objects[1,1] := Pointer(ifThenColor( FAskCnt > FBidCnt, clBlue,
                            ifThenColor( FAskCnt < FBidCnt,  clRed, clBlack) ));

    dVal := 0;

    if ( FAskVol = 0 ) or ( FBidVol = 0 ) then
      dVal := 0
    else begin
      d1  := FAskVol / FBidVol;
      d2  := FBidVol / FAskVol;
      dVal:= min( d1, d2 );
    end;
    Cells[0,1]  := Formatfloat('##0.##',  dVal  );
    Objects[0,1] := Pointer(ifThenColor( FAskVol > FBidVol, clBlue,
                            ifThenColor( FAskVol < FBidVol, clRed, clBlack ) ));
  end;
end;

procedure TFundBoardForm.CalcVolumeNCntRate( aQuote : TQuote );
var
  aSale : TTimeNSale;
  dtNow : TDateTime;
  I, iRes: Integer;
begin

  if aQuote.Sales = nil then Exit;

  dtNow := Frac(now);

  FAskCnt := 0;
  FBidCnt := 0;
  FAskVol := 0;
  FBidVol := 0;

  for I := 0 to aQuote.Sales.Count - 1 do
  begin
    aSale := aQuote.Sales.Sales[i];
    iRes  := SecondsBetween( dtNow, Frac(aSale.Time) );

    if iRes > FMin then
      break;

    if aSale.Side > 0 then
    begin
      inc( FBidVol,  aSale.Volume );
      inc( FBidCnt );
    end
    else if aSale.Side < 0 then
    begin
      inc( FAskVol,  aSale.Volume );
      inc( FAskCnt );
    end;
  end;

  UpdateData;

end;

procedure TFundBoardForm.rbLastOrdCnlClick(Sender: TObject);
begin
  if FSelectedBoard <> nil then
    FSelectedBoard.Tablet.LastOrdCnl := rbLastOrdCnl.ItemIndex = 0;
  FPrefs.LastOrdCnl := rbLastOrdCnl.ItemIndex = 0;
end;

procedure TFundBoardForm.rbMarketClick(Sender: TObject);
begin
  FPrefs.UseMarketPrc := rbMarket.Checked;

  gEnv.EnvLog( WIN_FUNDORD, Format('%s %s 선택(%s)', [ LogTitle,
      ifThenStr( rbMarket.Checked,'시장가','상대호가'), edtLiqTick.Text  ]));
end;

procedure TFundBoardForm.rbMouseSelectClick(Sender: TObject);
begin
  if FSelectedBoard <> nil then
    FSelectedBoard.Tablet.MouseSelect := rbMouseSelect.ItemIndex = 0;
  FPrefs.MouseSelect  := rbMouseSelect.ItemIndex = 0;

  gEnv.EnvLog( WIN_FUNDORD, Format('%s %s', [ LogTitle,
    ifThenStr( rbMouseSelect.ItemIndex = 0,'마우스선택','마우스위치')  ])  );
end;

procedure TFundBoardForm.refreshFavorSymbols;
var
  I: Integer;
  aFutMarket  : TFutureMarket;
  aFavor      : TFavorSymbolItem;
begin
  if FSymbol = nil then Exit;

  for I := 0 to BtnCnt-1 do
  begin
    aFavor      := TFavorSymbolItem( FavorSymbols.Items[i] );
    if aFavor.button.Down and (FSymbol <> aFavor.Symbol) then
      aFavor.button.Down  := false;

    if (aFavor.Symbol <> nil ) and  (FSymbol = aFavor.Symbol) then
      aFavor.button.Down  := true;
  end;
end;

procedure TFundBoardForm.reFreshTimer(Sender: TObject);
begin
  UpdateTotalPL;
  UpdatePositon;
end;

//--------------------------------------------------------------< ZAPR events >

procedure TFundBoardForm.MinPriceProc(Sender: TObject);
var
  bLeft, bRight : Boolean ;
begin
{todo:
  // 2007.06.19
  exit ;


  bLeft := false ;
  bRight := false ;
  if  FZaprServices[stLeft].Symbol = FSymbols[stLeft] then bLeft := true ;
  if  FZaprServices[stRight].Symbol = FSymbols[stRight] then bRight := true ;
  //
  if bLeft = true then
  begin
    if (not FPrefs.VisibleZapr) or (not FZaprServices[stLeft].Ready) then
    begin
      FOrderTablets[stLeft].MinPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stLeft].MinPrice := FZaprServices[stLeft].MinPrice;
    end;
  end ;
  //
  if bRight = true then
  begin
    if (not FPrefs.VisibleZapr) or (not FZaprServices[stRight].Ready) then
    begin
      FOrderTablets[stRight].MinPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stRight].MinPrice := FZaprServices[stRight].MinPrice;
    end;
  end ;
}
end;



procedure TFundBoardForm.MaxPriceProc(Sender: TObject);
var
  bLeft, bRight : Boolean ;
begin
{todo:
  // 2007.06.19
  exit ;

  bLeft := false ;
  bRight := false ;
  if  FZaprServices[stLeft].Symbol = FSymbols[stLeft] then bLeft := true ;
  if  FZaprServices[stRight].Symbol = FSymbols[stRight] then bRight := true ;
  //
    if bLeft = true then
  begin
    if (not FPrefs.VisibleZapr) or (not FZaprServices[stLeft].Ready) then
    begin
      FOrderTablets[stLeft].MaxPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stLeft].MaxPrice := FZaprServices[stLeft].MaxPrice;
    end;
  end ;
  //
  if bRight = true then
  begin
    if (not FPrefs.VisibleZapr) or (not FZaprServices[stRight].Ready) then
    begin
      FOrderTablets[stRight].MaxPrice := -1 ;    // reset min
    end else
    begin
      FOrderTablets[stRight].MaxPrice := FZaprServices[stRight].MaxPrice;
    end;
  end ;
}  
end;

//----------------------------------------------------------< observer events >
  {todo:

procedure TOrderBoardForm.ObserverProc(Sender, Receiver, DataObj: TObject;
  iBroadcastKind: Integer; btValue: TBroadcastType);
//var
//  aItem : TObserverItem;
begin
  if (Receiver <> Self) or (DataObj = nil) then
  begin
    gLog.Add(lkError, '더블주문창', '옵저버 컨트롤', 'Data Integrity Failure');
    Exit;
  end;

  // 더블 주문과 관련 있는 정보
  if (iBroadcastKind = CFID_DOORDER) or
     (iBroadcastKind = CFID_EFORDER) then
  begin
    aItem := DataObj as TObserverItem;

    case aItem.ActionID of
      ACID_CENTER :
        begin
          FOrderTablets[stLeft].MoveToPrice;
          FOrderTablets[stRight].MoveToPrice;
        end;
    end;

  end;
end;
  }

//-------------------------------------------------------------< set position >

//
// set an individual position
//
procedure TFundBoardForm.SetPosition(aPosition: TFundPosition);
var
  iGap,iRow : integer;
  aType : TOrderListType;

  procedure UpdatePosition( iRow : integer );
  begin
    with sgUnSettle do
    begin
      Cells[1,iRow]  := aPosition.Symbol.ShortCode;
      Cells[2,iRow]  := ifThenStr( aPosition.Volume > 0, 'L', 'S' );
      Cells[3,iRow]  := Formatfloat('#,##0.###', aPosition.EntryOTE);
      Objects[OrderCol, iRow] := aPosition;
      Objects[SymbolCol,iRow] := aPosition.Symbol;
      Objects[ColorCol, iRow] := Pointer(ifThenColor( aPosition.Volume > 0, clRed, clBlue ));
    end;

  end;

  procedure AddPosition( aPosition : TFundPosition );
  var
    I: Integer;
    aCK : TCheckBox;
  begin
    if iRow < 0 then
    begin
      iRow := 1;
      InsertLine( sgUnSettle, iRow );
      aCK := TCheckBox.Create( Self );
      aCK.Left  := cbUnSettleAll.Left;
      aCK.Height:= cbUnSettleAll.Height;
      aCk.Width := cbUnSettleAll.Width;
      aCK.Top   := cbUnSettleAll.Top + sgUnSettle.RowHeights[0];
      aCK.Parent:= cbUnSettleAll.Parent;
      sgUnSettle.Objects[CheckCol, iRow]  := aCK;

      for I := iRow+1 to sgUnSettle.RowCount - 1 do
      begin
        aCK := TCheckBox( sgUnSettle.Objects[CheckCol, i]);
        if aCk <> nil then
          aCK.Top := cbUnSettleAll.Top + (sgUnSettle.RowHeights[0] * i) + i;
      end;
    end;

    UpdatePosition( iRow );
  end;

  procedure DeletePosition( aPosition : TFundPosition );
  var
    i : integer;
    aCK : TCheckBox;
  begin
    if iRow < 0 then
      Exit
    else begin
      aCK := TCheckBox( sgUnSettle.Objects[CheckCol, iRow]);
      if aCK <> nil then
        aCK.Free;
      DeleteLine( sgUnSettle, iRow );

      for I := 1 to sgUnSettle.RowCount - 1 do
      begin
        aCK := TCheckBox( sgUnSettle.Objects[CheckCol, i]);
        if aCk <> nil then
          aCK.Top := cbUnSettleAll.Top + (sgUnSettle.RowHeights[0] * i) + i;
      end;
    end;
  end;


begin
  if aPosition = nil then Exit;

  iRow := sgUnSettle.Cols[OrderCol].IndexOfObject( aPosition );

  if (aPosition.Volume <> 0) then
    aType := olAdd
  else
    aType := olDelete;

  case aType of
    olAdd: AddPosition( aPosition );
    olDelete: DeletePosition( aPosition );
  end;  

  with sgUnSettle do
  begin
    iGap := Width - ClientWidth ;

    if FUfLastGap > 0 then
      if (iGap > FUfLastGap) and (FUfColWidth =  ColWidths[ChangeCol])  then
        ColWidths[ChangeCol] := ColWidths[ChangeCol] - iGap + 1
      else  if iGap < FUfLastGap then
        ColWidths[ChangeCol] := FUfColWidth;

    if (RowCount > 3) and ( FixedRows > 0 ) then
      FixedRows := 1;
  end;

  FUfLastGap := iGap;
end;

procedure TFundBoardForm.ResetGrid( aGrid : TStringGrid );
var
  I: Integer;
begin
  for I := 1 to aGrid.ColCount - 1 do
    aGrid.Cols[i].Clear;
end;


procedure TFundBoardForm.UpdateTotalPl;
var
  i , j : integer;
  aAccount : TAccount ;
  dOpen, dFixed, dFee : double;
begin

  if FFund = nil then
  begin
    ResetGrid( sgAcntPL );
    Exit;
  end;

  gEnv.Engine.TradeCore.FundPositions.GetFundPL( FFund, dOpen, dFixed, dFee  );

  with sgAcntPL do
  begin
    Cells[ 1, 0] := Formatfloat('#,##0.###', dOpen );
    Cells[ 1, 1] := Formatfloat('#,##0.###', dFixed );
    //Cells[ 1, 2] := Formatfloat('#,##0.###', FAccount.GetFee );
    //Cells[ 1, 2] := Formatfloat('#,##0.###', dOpen + dFixed -FAccount.GetFee );
    Cells[ 1, 2] := Formatfloat('#,##0.###', dOpen + dFixed );

    Objects[1,0] := Pointer( ifThenColor( dOpen > 0, clRed,
                             ifThenColor( dOpen < 0, clBlue, clBlack )));
    Objects[1,1] := Pointer( ifThenColor( dFixed > 0, clRed,
                             ifThenColor( dFixed < 0, clBlue, clBlack )));
    //Objects[1,2] := Pointer( clBlue );
    //Objects[1,3] := Pointer( ifThenColor( (dOpen + dFixed - FAccount.GetFee )> 0, clRed,
    //                         ifThenColor((dOpen + dFixed - FAccount.GetFee )< 0, clBlue, clBlack )));
    Objects[1,2] := Pointer( ifThenColor( (dOpen + dFixed )> 0, clRed,
                             ifThenColor((dOpen + dFixed )< 0, clBlue, clBlack )));
  end;
end;

procedure TFundBoardForm.WMSymbolSelected(var msg: TMessage);
var
  aSymbol : TSymbol;
begin

  aSymbol := TSymbol( Pointer( msg.LParam ));

  if aSymbol <> nil then

  case msg.WParam of
    0 : RecvSymbol( aSymbol ) ;
    else
      AddInterestSymbol( aSymbol, msg.WParam );
  end;
end;

procedure TFundBoardForm.UpdatePositon;
var
  I: integer;
  aPosition : TFundPosition;
begin
  with sgUnSettle do
    for I := 1 to RowCount - 1 do
    begin
      aPosition  := TFundPosition( Objects[OrderCol, i]);
      if aPosition <> nil then
        Cells[3,i]  := Formatfloat('#,##0.###', aPosition.EntryOTE);
    end;
end;


procedure TFundBoardForm.UpdatePositionInfo( aPos : TFundPosition );
begin
  if aPos = nil then  Exit;

  with sgSymbolPL do
  begin
    Cells[ 0, 1] := aPos.Symbol.ShortCode;
    Cells[ 1, 1] := ifThenStr( aPos.Volume > 0,'매수',
                    ifThenStr( aPos.Volume < 0,'매도', '' ));
    Cells[ 2, 1] := IntToStr( aPos.Volume );
    Cells[ 3, 1] := Format('%.*n',[ aPos.Symbol.Spec.Precision,  aPos.AvgPrice] );
    Cells[ 4, 1] := Format('%.*n',[ aPos.Symbol.Spec.Precision, aPos.Symbol.Last] );
    Cells[ 5, 1] := Formatfloat('#,##0.###',  aPos.EntryOTE );
  end;

end;


//-------------------------------------------------------------------< tablet >

function TFundBoardForm.GetMonth( stCode : string ) : string;
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
procedure TFundBoardForm.N10Click(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  case ( Sender as TMenuItem ).Tag of
    1 :
      begin
        if gSymbol = nil then
          gEnv.CreateSymbolSelect;

        if FSaveRow > 0 then
          gSymbol.ShowWindow( Handle , FSaveRow );

      end;
    -1:
      begin
         with sgInterest do
         begin
           aSymbol := TSymbol( Objects[ 0, FSaveRow]);
           if aSymbol <> nil then
             Rows[FSaveRow].Clear;
         end;
      end ;
  end;
end;

procedure TFundBoardForm.AddInterestSymbol( aSymbol : TSymbol; iRow : integer );
begin
  if aSymbol <> nil then
    with sgInterest do
    begin
    Objects[ 0, iRow] := aSymbol;
                  Cells[0, iRow]    := aSymbol.Spec.Sector;
                  Cells[1, iRow]    := aSymbol.ShortCode;
                  Cells[2, iRow]    := FormatDateTime('yy.mm', (asymbol as TDerivative).ExpDate);// + ','+ GetMonth(aSymbol.ShortCode);
    end;
end;

function TFundBoardForm.NewBoard: TFundOrderBoard;
begin
  Result := FBoards.New;

  if Result <> nil then
  begin
    Result.OnPosEvent := BoardPosUpdate;
    Result.OnPanelClickEvent  :=  BoardPanelClickEvent;
    // control 등록
    Result.EditOrderVolume  := edtOrderQty;
    edtOrderQTy.OnKeyPress  := Result.EditKeyPress;
    edtOrderQty.OnClick     := Result.EditOrderVolumeClick;

    Result.StaticTextClearVolume  := btnClearQty;
    btnClearQty.OnClick := Result.StaticTextClearVolumeClick;
    Result.StopOrderTick    := edtStopTick;
    Result.PartClearVolume  := btnAbleNet;

    //Result.onc
      // popup menu for order tablet
    Result.Tablet.PopOrders := PopupMenuOrders;
      // assign event handlers
    Result.Tablet.OnNewOrder := BoardNewOrder;
    Result.Tablet.OnChangeOrder := BoardChangeOrder;
    Result.Tablet.OnCancelOrder := BoardCancelOrder;
    Result.Tablet.OnLastCancelOrder := BoardLastCancelOrder;
    Result.Tablet.OnSelectCell := BoardSelectCell;

    Result.Tablet.OnCancelOrders  := CancelOrders;

    Result.Tablet.TabletColor := $00EFD2B4;

    { todo:
    Result.ZaprService.OnMinPriceChanged := MinPriceProc;
    Result.ZaprService.OnMaxPriceChanged := MaxPriceProc;
    }
    Result.Tablet.ColWidths[tcOrder]  := Result.Tablet.ORDER_WIDTH;
    Result.Tablet.ColWidths[tcQuote]  := QTY_WIDTH;
    Result.Tablet.ColWidths[tcPrice]  := PRICE_WIDTH;
    Result.Tablet.ColWidths[tcCount ] := CNT_WIDTH;
    Result.Tablet.ColWidths[tcGutter] := GUT_WIDTH;
    Result.Tablet.ColWidths[tcStop]   := STOP_WIDTH;

    Result.Tablet.AutoScroll := FPrefs.AutoScroll;

    Result.SetOrderVolume(StrToIntDef(SpeedButton1.Caption, 0), True);
      // set dimension
    Result.Resize;
  end;
end;



procedure TFundBoardForm.BoardSelect(Sender: TObject);
var
  i: Integer;
  aBoard: TFundOrderBoard;
begin
  if Sender = nil then Exit;

  if FSelectedBoard = Sender then Exit;

  for i := 0 to FBoards.Count - 1 do
  begin
    aBoard := FBoards[i];

    if aBoard = Sender then
    begin
      FSelectedBoard := aBoard;
      FSelectedBoard.Tablet.Selected  := true;
    end else
    begin

      aBoard.Tablet.Selected  := false;
    end;
  end;

  SetInfo( FSelectedBoard );

end;

//------------------------------------------------------------------< select >

procedure TFundBoardForm.SetAccount;
begin
  gEnv.Engine.TradeCore.Funds.GetList( ComboBoAccount.Items);
  if ComboBoAccount.Items.Count > 0 then
  begin
    ComboBoAccount.ItemIndex  := 0;
    ComboBoAccountChange( nil ) ;
    ComboBox_AutoWidth( ComboBoAccount );
  end;
end;

procedure TFundBoardForm.SetSymbol(aSymbol: TSymbol);
var
  iRow, iCol, i: Integer;
  aOrder: TOrder;
  bSend , CanSelected : Boolean;
  aGrid : TStringGrid ;
  stLeftDesc, stRightDesc : String ;
  aAcnt   : TAccount;
  aTmp : TSymbol;
  aStop : TStopOrder;
  k: Integer;
begin

  FLeftPos := Left;
  if (aSymbol = nil) or (FBoards.Count = 0) then Exit;

  if FSelectedBoard = nil then
    BoardSelect(FBoards[0]);

    // check still
  if FSelectedBoard = nil then Exit;
    // unsubscribe
  if FSelectedBoard.Symbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel(FSelectedBoard, FSelectedBoard.Symbol);
    //
  FSelectedBoard.Tablet.Ready := False;
  FSelectedBoard.DeliveryTime := '';

    // 계좌 처리 먼저 한다...
  FSelectedBoard.Fund  := FFund;
    // set symbol and subscribe
  aTmp := FSelectedBoard.Symbol;
  FSelectedBoard.Symbol := aSymbol;
  FSelectedBoard.Quote := gEnv.Engine.QuoteBroker.Subscribe(FSelectedBoard, aSymbol,
                            QuoteBrokerEventHandler);

  SetInfo( FSelectedBoard );

  if (aTmp <> aSymbol) then
    SetWidth;

  if FSelectedBoard.Fund = nil then Exit;
    // assign position
  sgSymbolPL.Rows[1].Clear;
  FSelectedBoard.FundPosition := gEnv.Engine.TradeCore.FundPositions.Find(FSelectedBoard.Fund, aSymbol);
  if FSelectedBoard.FundPosition = nil then
    FSelectedBoard.FundPosition := gEnv.Engine.TradeCore.FundPositions.New(FSelectedBoard.Fund, aSymbol);
    // apply orders

  bSEnd := false;

  for i := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder := gEnv.Engine.TradeCore.Orders.ActiveOrders[i];

    for k := 0 to FSelectedBoard.Fund.FundItems.Count - 1 do
    begin
      if (aOrder.State = osActive)
         and (aOrder.Account = FSelectedBoard.Fund.FundAccount[k] ) then
         begin
           DoOrder( aOrder );
           if (aOrder.Symbol = FSelectedBoard.Symbol) then
           begin
             FSelectedBoard.Tablet.DoOrder2(aOrder);
             bSend := true;
           end;
         end;
    end;
  end;

  if bSend then
    FSelectedBoard.Tablet.RefreshTable;

    // update order limite
  FSelectedBoard.UpdatePositionInfo;
  FSelectedBoard.UpdateOrderLimit;

    // fill count
  FSelectedBoard.TNSCount := 0;
      //
  FSelectedBoard.Resize;

    // if quote has been subscribed somewhere else
  if (FSelectedBoard.Quote <> nil) then
  begin
    FSelectedBoard.Quote.LastEvent  := qtCustom;
    QuoteBrokerEventHandler(FSelectedBoard.Quote, Self, 0, FSelectedBoard.Quote, 0);
  end;

  SetFundStopOrder( FSelectedBoard );
  FSelectedBoard.ShowStopOrder;

  cbAcntLisk.Checked  := false;
  //CheckOrientation( FSelectedBoard );
end;


//-----------------------------------------------------------< select account >

//
// select account
//
procedure TFundBoardForm.ComboBoAccountChange(Sender: TObject);
var
  aFund    : TFund;
begin
  aFund  := GetComboObject( ComboBoAccount ) as TFund;
  if aFund = nil then Exit;

  if FFund <> aFund then
  begin
    FFund := aFund;
    GetMarketAccount;

    if FSymbol <> nil then
      LogTitle  := Format('%s %s', [ FFund.Name, FSymbol.ShortCode ])
    else
      LogTitle  := Format('%s %s', [ FFund.Name, '' ]);
  end;
end;

procedure TFundBoardForm.ClearGrid( aGrid : TStringGrid );
var
  I: Integer;
  aCK : TCheckBox;
begin
  for I := 1 to aGrid.RowCount - 1 do
  begin
    aCK := TCheckBox( aGrid.Objects[CheckCol, i]);
    if aCK <> nil then
      aCK.Free;
    aGrid.Rows[i].Clear;
  end;

  case aGrid.Tag of
    0 : aGrid.ColWidths[ChangeCol]  := FUfColWidth;
    1 : aGrid.ColWidths[ChangeCol]  := FUSColWidth;
  end;

  aGrid.RowCount := 1;
end;

procedure TFundBoardForm.SetFavorSymbols;
begin
  FavorSymbols.New(SpeedButton17);
  FavorSymbols.New(SpeedButton16);
  FavorSymbols.New(SpeedButton9);
  FavorSymbols.New(SpeedButton10);
  FavorSymbols.New(SpeedButton11);
  FavorSymbols.New(SpeedButton12);
  FavorSymbols.New(SpeedButton13);
  FavorSymbols.New(SpeedButton14);
end;

procedure TFundBoardForm.SetFundStopOrder( aBoard : TFundOrderBoard );
var
  aStop : TStopOrder;
  j: Integer;
begin
  if aBoard.Fund = nil then Exit;
  
  for j := 0 to aBoard.Fund.FundItems.Count - 1 do
  begin
    aStop := gEnv.Engine.TradeCore.StopOrders.Find( aBoard.Fund.FundAccount[j], aBoard.Symbol);
    if aStop = nil then
    begin
      aStop := gEnv.Engine.TradeCore.StopOrders.New( aBoard.Fund.FundAccount[j], aBoard.Symbol );
      aStop.Invest  := gEnv.Engine.TradeCore.Investors.Find( aBoard.Fund.FundAccount[j].InvestCode );
    end;
  end;
end;

procedure TFundBoardForm.GetMarketAccount;
var
  i : integer;
  aPos  : TFundPosition;
begin

  ClearGrid( sgUnFill );
  ClearGrid( sgUnSettle );
  sgSymbolPL.Rows[1].Clear;

  for i := 0 to FBoards.Count - 1 do
  begin
    if FBoards[i].Symbol <> nil then
    begin
      FBoards[i].Fund  := FFund;
      FBoards[i].FundPosition :=
        gEnv.Engine.TradeCore.FundPositions.Find( FFund, FBoards[i].Symbol );
      BoardAcntSelect( FBoards[i] );
      SetFundStopOrder( FBoards[i] );
      FBoards[i].ShowStopOrder;
    end;
  end;

  for I := 0 to gEnv.Engine.TradeCore.FundPositions.Count-1 do
  begin
    aPos := gEnv.Engine.TradeCore.FundPositions.FundPositions[i];
    if aPos.Fund = FFund then
      SetPosition( aPos );
  end;
  UpdateTotalPl;
end;

//--------------------------------------------------------< populates symbols >

//
// select underlying
//
procedure TFundBoardForm.ComboBoxUnderlyingsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  Exit;
end;

procedure TFundBoardForm.ComboBoxUnderlyingsKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TFundBoardForm.StringGridOptionsMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;

procedure TFundBoardForm.StringGridOptionsMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:= True;
end;


//---------------------------------------------------------< symbol selection >

//
// select a futures
//
procedure TFundBoardForm.StandByClick(Sender, aControl : TObject);
var
  aBoard : TFundOrderBoard;
  iLS : integer;
begin
  aBoard  := Sender as TFundOrderBoard;
  if aBoard = nil then Exit;

  iLS :=  TSpeedButton( aControl ).GroupIndex;

end;

procedure TFundBoardForm.SpeedButton15Click(Sender: TObject);
var
  aDlg  : TFrmInterestConfig;
begin
  //
  try
    aDlg  := TFrmInterestConfig.Create( Self );

    aDlg.Left := GetMousePoint.X+10;
    aDlg.Top  := GetMousePoint.Y;

    if aDlg.Open then
    begin
      gEnv.Engine.SymbolCore.SaveFavorSymbols;
      gBoardEnv.BroadCast.BroadCast( Self, self , etInterest, vtUpdate);
    end;
  finally
    aDlg.Free;
  end;
end;

procedure TFundBoardForm.SpeedButton17Click(Sender: TObject);
var
  aFavor  : TFavorSymbolItem;
begin
  try
    aFavor  := TFavorSymbolItem( FavorSymbols.Items[ (Sender as TSpeedButton).Tag ] );
    if (aFavor <> nil) and ( aFavor.Symbol <> nil ) then
    begin
      RecvSymbol( aFavor.Symbol );
      aFavor.button.Down := true;
    end;
  except
  end;
end;

procedure TFundBoardForm.SpeedButton1Click(Sender: TObject);
var
  iQTy : integer;
begin
  if edtTmpQty.Visible then
    edtTmpQty.Hide;
  edtorderQty.Text  :=  (Sender as TSpeedButton).Caption;
end;

procedure TFundBoardForm.SpeedButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    if edtTmpQty.Visible then
      edtTmpQty.Hide;
    with Sender as TSpeedButton do
    begin
      edtTmpQty.Left := Left + 1;
      edtTmpQty.Top  := Top  + 1;
      edtTmpQty.Width:= Width - 2;
      edtTmpQty.Height:= Height -2;
      edtTmpQty.Text  := Caption;
      edtTmpQty.Show;
      LastButton  := Sender as TSpeedButton;
      edtTmpQty.SetFocus;
      edtTmpQty.SelectAll;
    end;
  end;

end;

procedure TFundBoardForm.SpeedButton6Click(Sender: TObject);
begin
  //
  FLeftPos  := Self.Left;
  
  with FPrefs do
  begin
    if FSelectedBoard <> nil then
    begin
      FDefParams.OrdHigh  := StrToIntDef( edtOrdH.Text, 18 );
      FDefParams.OrdWid   := StrToIntDef( edtOrdW.Text, 58 );
      if (FDefParams.OrdHigh <> FSelectedBoard.Params.OrdHigh ) or
         (FDefParams.OrdWid  <> FSelectedBoard.Params.OrdWid  ) then
        FSelectedBoard.Params := FDefParams;
    end;
  end;

  SetWidth;
end;

procedure TFundBoardForm.SpeedButton8Click(Sender: TObject);
begin
  gEnv.Engine.FormBroker.Open(ID_MULTI_ACNT, 0);
end;

procedure TFundBoardForm.SpeedButtonLeftPanelClick(Sender: TObject);
begin

    // control size
  if SpeedButtonLeftPanel.Down then begin
    PanelLeft.Width := SIDE_LEFT_PANEL_WIDTH ;
    if FLoadEnd then
      FLeftPos  := Left - SIDE_LEFT_PANEL_WIDTH
    else
      FLeftPos  := Left;
  end
  else begin
    PanelLeft.Width := 0;
    if FLoadEnd then
      FLeftPos  := Left + SIDE_LEFT_PANEL_WIDTH
    else
      FLeftPos  := Left;
  end;


    // set form width
  SetWidth;
end;

procedure TFundBoardForm.SpeedButtonRightPanelClick(Sender: TObject);
begin
    // control size
  FLeftPos  := Left;
  if SpeedButtonRightPanel.Down then
    PanelRight.Width := SIDE_RIGHT_PANEL_WIDTH
  else
    PanelRight.Width := 0;

    // set form width
  SetWidth;
end;

procedure TFundBoardForm.SpeedMiddleClick(Sender: TObject);
begin
  if SpeedMiddle.Down then
    PanelTop.Height := 140
  else
    PanelTop.Height := 115;
    // set form width
  FormResize( nil );

end;

//-----------------------------------------------------------------------<?


procedure TFundBoardForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
  stTmp : string;
begin
    // scroll
  if Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT  ] then
  begin
    case Key of
      VK_UP:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,1);
      VK_DOWN:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,-1);
      VK_PRIOR:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollPage(1);
      VK_NEXT:
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollPage(-1);

    end;    //

    Key := 0;
  end else
    // escape key

  if (BoardKey[FPrefs.RangeKey] <> 0) and (Key = BoardKey[FPrefs.RangeKey]) then
  begin
    gBoardEnv.BroadCast.BroadCast( Self, Self, etSpace, vtUpdate);
    //OtherBoardScrollToLastPrice;
  end;

  if FPrefs.UseKeyOrder then
  begin
    if FSelectedBoard = nil then Exit;

    if not FKeyDown then
    begin
      FKeyDown  := true;

      if Key = BoardKey[FPrefs.OrderKey]  then
      begin
        //if not FKeyDown then
        BoardNewOrder;
      end;
    end;
  end;

  if cbShortCutOrd.Checked then
    case Key of
      VK_F5, VK_F6,VK_F7, VK_F8 :
        begin
          case Key of
            VK_F5 : plAllLiqClick( plAllLiq );
            VK_F8 : plAllLiqClick( plthisLiq );

            VK_F6 : plAllLiqClick( plAllCnl );
            VK_F7 : plAllLiqClick( plThisCnl );
          end;
          gEnv.EnvLog( WIN_FUNDORD,   Format('%s 단축키 사용 %d', [ LogTitle, Key ]));
        end;
    end;

  key := 0;
end;

procedure TFundBoardForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FKeyDown := false;
end;

procedure TFundBoardForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
        if FSelectedBoard <> nil then
          FSelectedBoard.Tablet.ScrollLine(1,-1);
end;

procedure TFundBoardForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
       if FSelectedBoard <> nil then
         FSelectedBoard.Tablet.ScrollLine(1,1);
end;


//---------------------------------------------------------------< popup menu >

//
procedure TFundBoardForm.PartCancelOrder(Sender: TOrderTablet;
  aPoint: TTabletPoint; aTypes: TPositionTypes);
  var
    aBoard : TFundOrderBoard;
begin

  aBoard := FBoards.Find(Sender);
  if aBoard = nil then Exit;

  CancelOrders( aBoard, aPoint, aTypes );
end;


procedure TFundBoardForm.plAllLiqClick(Sender: TObject);
var
  i : integer;
  stMsg : string;
begin

  if cbConfirmOrder.Checked then
  begin
    if FFund = nil then Exit;
    if FSymbol  = nil then Exit;

    case (Sender as TPanel).Tag of
      5 : stMsg := Format('%s 펀드의 전종목 청산',[ FFund.Name]) ;
      8 : stMsg := Format('%s 펀드의 %s 청산',[ FFund.Name, FSymbol.Name]) ;

      6 : stMsg := Format('%s 펀드의 전종목 취소',[ FFund.Name]) ;
      7 : stMsg := Format('%s 펀드의 %s 취소',[ FFund.Name, FSymbol.Name]) ;
    end;

    if  MessageDlg(stMsg + '을(를) 하시겠습니까?',
      mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;
  end;

  case (Sender as TPanel).Tag of
       // 전종목 청산
    5 : AllLiquids( true );
       // 현종목 청산
    8 : if FSelectedBoard <> nil then
          FSelectedBoard.AllLiquids;

    6 : AllCancels( true );
    7 : // 현종목 취소
        if FSelectedBoard <> nil then
          FSelectedBoard.AllCancels;
        // 전종목 취소
  end;

  if FFund = nil then Exit;
  if FSymbol  = nil then Exit;
  case (Sender as TPanel).Tag of
    5 : stMsg := Format('%s 펀드의 전종목 청산',[ FFund.Name]) ;
    8 : stMsg := Format('%s 펀드의 %s 청산',[ FFund.Name, FSymbol.Name]) ;

    6 : stMsg := Format('%s 펀드의 전종목 취소',[ FFund.Name]) ;
    7 : stMsg := Format('%s 펀드의 %s 취소',[ FFund.Name, FSymbol.Name]) ;
  end;

  gEnv.EnvLog( WIN_FUNDORD,   Format('plAllLiqClick %s ', [ stMsg ]));  

end;

procedure TFundBoardForm.plAllLiqMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvLowered;
end;

procedure TFundBoardForm.plAllLiqMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter :=  bvRaised;
end;

//
// send cancel order by button click
//

procedure TFundBoardForm.Button1Click(Sender: TObject);
var
  a : TPoint;
begin

  a := GetMousePoint;

  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    //gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  gSymbol.ShowWindow( Handle);

  gSymbol.Left := a.X+10;
  gSymbol.Top  := a.Y;

end;

procedure TFundBoardForm.RecvSymbol( aSymbol : TSymbol );
begin
  if aSymbol <> nil then
  begin
    AddSymbolCombo(aSymbol, cbSymbol );
        // apply
    cbSymbolChange( cbSymbol );
  end;
end;


procedure TFundBoardForm.Button2Click(Sender: TObject);
begin
  FMin  := StrToIntDef( edtMin.Text, 1 ) * 60;
  if ( FSymbol <> nil ) and ( FSymbol.Quote <> nil ) then  
    CalcVolumeNCntRate( FSymbol.Quote as TQuote );
end;

function TFundBoardForm.CancelOrders(aBoard: TFundOrderBoard; aPoint: TTabletPoint;
  aTypes: TPositionTypes): Integer;
var
  i, iQty: Integer;
  aTicket: TOrderTicket;
  aOrder: TOrder;
begin
  Result := 0;
    // check
  if (aBoard = nil) or (aBoard.Tablet.Symbol = nil) then Exit;

  if aBoard.Fund = nil then Exit;

    // init
  iQty := 0;

    // clear list
  FTargetOrders.Clear;

    // get orders from the tablet
  if aBoard.Tablet.GetOrders(aPoint, aTypes, FTargetOrders) = 0 then Exit;

    // generate orders
  for i := 0 to FTargetOrders.Count - 1 do
  begin
    aOrder := FTargetOrders[i];

    if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then begin
        // get a ticket
      aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
      gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
      gEnv.Engine.TradeBroker.Send(aTicket);
    end;
  end;                          
end;

procedure TFundBoardForm.cbAcntLiskClick(Sender: TObject);
var
  dLiskAmt : double;
  dOpen, dFixed, dFee : double;
  stLog : string;
begin

  if ( FSelectedBoard = nil ) or ( FSelectedBoard.FundPosition = nil ) then Exit;
  if cbAcntLisk.Checked then
  begin
    //  input check....
    dLiskAmt  := 0;
    if edtOpenLiskAmt.Text = '' then
    begin
      cbAcntLisk.Checked := false;
      Exit;
    end else
      dLiskAmt  := StrToFloatDef( edtOpenLiskAmt.Text, 0 );

    // 한도 금액 체크
    if dLiskAmt <= 0 then
    begin
      cbAcntLisk.Checked := false;
      Exit;
    end;

    dOpen := FSelectedBoard.FundPosition.EntryOTE;

    if -dLiskAmt > dOpen then
    begin
      ShowMessage( Format('평가손익 %s 보다 작은값으로는 설정 불가',
        [Formatfloat('#,##0.###', dOpen )]));
      cbAcntLisk.Checked := false;
      Exit;
    end;

    // 한도 금액 체크
    FLiskAmt  := dLiskAmt;

    edtOpenLiskAmt.Text := FormatFloat('#,##0.###', FLiskAmt);
    edtOpenLiskAmt.Font.Color := clWhite;
    edtOpenLiskAmt.Color := clBlue;

    FLiskChange := true;

    gLog.Add( lkLossCut, 'TFundBoardForm','',
      Format('%s, %s 한도 설정 ---> %s ( 현재손익 : %s )',  [ FSelectedBoard.Fund.Name,
        FSelectedBoard.FundPosition.Symbol.ShortCode,
        FormatFloat('#,##0.###', FLiskAmt), FormatFloat('#,##0.###', dOpen)])       );

  end else
  begin
    FLiskChange := false;
    if FLiskAmt = 0 then Exit;

    edtOpenLiskAmt.Text := FloatToStr( FLiskAmt );
    edtOpenLiskAmt.Font.Color := clBlack;
    edtOpenLiskAmt.Color := clWhite;

    gLog.Add( lkLossCut, 'TFundBoardForm','',
      Format('%s, %s 한도 설정 해제 ---> %s ',  [ FSelectedBoard.Fund.Name,
        FSelectedBoard.FundPosition.Symbol.ShortCode,
        FormatFloat('#,##0.###', FLiskAmt)])
       );
  end;

end;

procedure TFundBoardForm.cbConfirmOrderClick(Sender: TObject);
begin
  FPrefs.UseShortCutConfirm  := cbConfirmOrder.Checked;

  gEnv.EnvLog( WIN_FUNDORD, Format('%s %s %s', [ LogTitle,
      cbConfirmOrder.Caption, ifThenStr( FPrefs.UseShortCutConfirm ,'On','Off')  ])  );
end;

procedure TFundBoardForm.cbHogaFixClick(Sender: TObject);
begin
  FPrefs.FixedHoga := cbHogafix.Checked;
  if FSelectedBoard <> nil then
    FSelectedBoard.Tablet.FixedHoga  := FPrefs.FixedHoga;
end;


procedure TFundBoardForm.cbKeyOrderClick(Sender: TObject);
begin
  if cbKeyOrder.Checked then
  begin
    rbMouseSelect.Enabled := true;
    Label3.Caption  := '정렬 : Alt Key';
  end
  else begin
    rbMouseSelect.Enabled := false;
    Label3.Caption  := '정렬 : Space bar';
  end;

  with FPrefs do
  begin
    UseKeyOrder := cbKeyOrder.Checked;
    if UseKeyOrder then
    begin
      OrderKey := ktSpace;
      RangeKey := ktAlt;
    end
    else begin
      OrderKey := ktNone;
      RangeKey := ktSpace;
    end;
  end;
end;

procedure TFundBoardForm.cbOneClickClick(Sender: TObject);
begin
  if FSelectedBoard <> nil then
    FSElectedBoard.Tablet.DbClickOrder  := not cbOneClick.Checked;
  FPrefs.DbClickOrder := not cbOneClick.Checked;

  gEnv.EnvLog( WIN_FUNDORD, Format('%s %s %s', [ LogTitle,
      cbOneClick.Caption,    ifThenStr( cbOneClick.Checked ,'On','Off')  ])  );
end;

procedure TFundBoardForm.cbPrfLiquidClick(Sender: TObject);
begin
  FPrefs.UsePrfLiquid := cbPrfLiquid.Checked;
  FPrefs.UseLosLiquid := cbLosLiquid.Checked;

  gEnv.EnvLog( WIN_FUNDORD,
    Format('%s 이익/손실설정 이익 %s %s , 손실 %s %s', [
      LogTitle,
      ifthenStr( cbPrfLiquid.Checked, 'On','Off' ),  edtPrfTick.Text,
      ifthenStr( cbLosLiquid.Checked, 'On','Off' ),  edtLosTick.Text
      ]));
end;

procedure TFundBoardForm.cbShortCutOrdClick(Sender: TObject);
begin
  FPrefs.UseShortCut  := cbShortCutOrd.Checked;

  gEnv.EnvLog( WIN_FUNDORD, Format('%s %s %s', [ LogTitle,
    cbShortCutOrd.Caption,
      ifThenStr( FPrefs.UseShortCut ,'On','Off')  ])  );
end;

procedure TFundBoardForm.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  i : integer;
begin
  //
  aSymbol  := GetComboObject( cbSymbol ) as TSymbol;
  if aSymbol = nil then Exit;

  if FSymbol <> aSymbol then
  begin
    FSymbol := aSymbol;
    SetSymboL( FSymbol );

    refreshFavorSymbols;

    if FFund <> nil then
      LogTitle  := Format('%s %s', [ FFund.Name, FSymbol.ShortCode ])
    else
      LogTitle  := Format('%s %s', [ '', FSymbol.ShortCode ]);
    // 주문가능수..요청..
  end;
end;

procedure TFundBoardForm.cbUnFillAllClick(Sender: TObject);
var
  I: Integer;
  aCK : TCheckBox;
begin
  for I := 1 to sgUnFill.RowCount - 1 do
  begin
    aCK := TCheckBox( sgUnFill.Objects[ CheckCol, i ]);
    if aCK <> nil then
      aCK.Checked := cbUnFillAll.Checked;
  end;

end;

procedure TFundBoardForm.cbUnSettleAllClick(Sender: TObject);
var
  I: Integer;
  aCK : TCheckBox;
begin
  for I := 1 to sgUnSettle.RowCount - 1 do
  begin
    aCK := TCheckBox( sgUnSettle.Objects[ CheckCol, i ]);
    if aCK <> nil then
      aCK.Checked := cbUnSettleAll.Checked;
  end;

end;

  // 일괄 취소
procedure TFundBoardForm.AllCancels( bAuto : boolean );
var
  I: Integer;
  aCK : TCheckBox;
  aTicket : TOrderTicket;
  aOrder: TOrder;
begin

  if not CheckInvest then Exit;

  try
    FTargetOrders.Clear;

    for I := 1 to sgUnFill.RowCount - 1 do
    begin
      aCK := TCheckBox( sgUnFill.Objects[ CheckCol, i ]);
      if ((aCK <> nil) and ( aCK.Checked )) or ( bAuto ) then
      begin
        aCK.Checked := false;
        aOrder  := TORder( sgUnFill.Objects[ OrderCol, i] );
        if aOrder <> nil then
          FTargetOrders.Add( aOrder);
      end;
    end;

      // generate orders
    for i := 0 to FTargetOrders.Count - 1 do
    begin
      aOrder := FTargetOrders[i];
      if (aOrder.OrderType = otNormal) and (aOrder.State = osActive) then begin
          // get a ticket
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
        gEnv.Engine.TradeCore.Orders.NewCancelOrder(aOrder, aOrder.ActiveQty, aTicket);
        gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;

  finally
  end;
end;

procedure TFundBoardForm.Button3Click(Sender: TObject);
begin
  gEnv.EnvLog( WIN_FUNDORD,  Format('%s 일괄취소 버튼 클릭', [ LogTitle ])      );
  AllCancels( false );
end;

  // 일괄 청산

procedure TFundBoardForm.AllLiquids( bAuto : boolean );
var
  I, j: Integer;
  aCK : TCheckBox;
  aTicket : TOrderTicket;
  aFundPos: TFundPosition;
  aPos : TPosition;
  aOrder   : TOrder;
begin

  if not CheckInvest then Exit;

  try
    FTargetPositions.Clear;

    for I := 1 to sgUnSettle.RowCount - 1 do
    begin
      aCK := TCheckBox( sgUnSettle.Objects[ CheckCol, i ]);
      if ((aCK <> nil) and ( aCK.Checked )) or ( bAuto ) then
      begin
        aCK.Checked := false;
        aFundPos  := TFundPosition( sgUnSettle.Objects[ OrderCol, i] );
        if aFundPos <> nil then
          for j := 0 to aFundPos.Positions.Count - 1 do
            FTargetPositions.Add( aFundPos.Positions.Positions[j] );
      end;
    end;

      // generate orders
    for i := 0 to FTargetPositions.Count - 1 do
    begin
      aPos := FTargetPositions[i];
      if (aPos.Volume <> 0 ) then begin
        // issue an order ticket
        aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

        // create normal order
        aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
                    gEnv.ConConfig.UserID, aPos.Account, aPos.Symbol,
                    //iVolume, pcLimit, dPrice, tmFOK, aTicket) ;
                    -aPos.Volume, pcMarket, 0, tmGTC, aTicket);  //
        aOrder.OwnForm  := self;

        // send the order
        if aOrder <> nil then aOrder.FundName := FFund.Name;

        gEnv.Engine.TradeBroker.Send(aTicket);
      end;
    end;


  finally
  end;
end;

procedure TFundBoardForm.Button4Click(Sender: TObject);
begin
  gEnv.EnvLog( WIN_FUNDORD,  Format('%s 일괄청산 버튼 클릭', [ LogTitle ])   );
  AllLiquids( false );
end;


procedure TFundBoardForm.Button5Click(Sender: TObject);
var
  bPrf, bLos: boolean;
  iPrf, iLos, iTick: integer;
  pcValue : TPriceControl;
begin

  gEnv.EnvLog( WIN_FUNDORD, Format('%s 이익/손실 적용 버튼 클릭 - 이익 %s %s , 손실 %s %s', [ LogTitle,

      ifthenStr( cbPrfLiquid.Checked, 'On','Off' ),  edtPrfTick.Text,
      ifthenStr( cbLosLiquid.Checked, 'On','Off' ),  edtLosTick.Text
   ]) );

  if FSelectedBoard = nil then Exit;
  if FSelectedBoard.FundPosition = nil then Exit;

  bPrf  := cbPrfLiquid.Checked;
  bLos  := cbLosLiquid.Checked;

  if ( not bPrf ) and ( not bLos ) then Exit;
  if FSelectedBoard = nil then Exit;

  iPrf  := StrToIntDef( edtPrfTick.Text, 5 );
  iLos  := StrToIntDef( edtLosTick.Text, 5 );
  iTick := StrToIntDef( edtLiqTick.Text, 0 );

  if rbMarket.Checked then
    pcValue := pcMarket
  else
    pcValue := pcLimit;

  FSelectedBoard.OnFillExec( bPrf, bLos, iPrf, iLos, iTick, pcValue );

end;

function TFundBoardForm.CheckInvest : boolean;
begin
  Result := true;
end;



end.
