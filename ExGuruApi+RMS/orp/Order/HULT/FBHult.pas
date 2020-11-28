unit FBHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, DateUtils,

  CleSymbols, CleAccounts, ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,

  CleStorage, UPaveConfig , GleTypes , CleBHultEx, CleOrderSlots, CleStrategyStore,

  ComCtrls, StdCtrls, ExtCtrls , Grids;



type
  TFrmBHult = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    Panel2: TPanel;
    gbUseHul: TGroupBox;
    stTxt: TStatusBar;
    dtEndTime: TDateTimePicker;
    Label3: TLabel;
    cbSymbols: TComboBox;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    edtQty: TEdit;
    udQty: TUpDown;
    Label4: TLabel;
    edtGap: TEdit;
    udGap: TUpDown;
    Label9: TLabel;
    edtOrdCnt: TEdit;
    udOrdCnt: TUpDown;
    GroupBox4: TGroupBox;
    cbAutoLiquid: TCheckBox;
    edtplTick1th: TLabeledEdit;
    udplTick1th: TUpDown;
    edtLcTick1th: TLabeledEdit;
    udLcTick1th: TUpDown;
    edtplTick2th: TEdit;
    udplTick2th: TUpDown;
    edtLcTick2th: TEdit;
    udLcTick2th: TUpDown;
    cbParaLiquid: TCheckBox;
    GroupBox5: TGroupBox;
    cbPara: TCheckBox;
    cbForeign: TCheckBox;
    cbHultPos: TCheckBox;
    cbParaSymbol: TComboBox;
    edtAfVal: TLabeledEdit;
    edtForFutQty: TLabeledEdit;
    cbTarget: TComboBox;
    Label5: TLabel;
    edtTargetPos: TEdit;
    udTargetPos: TUpDown;
    dtStartTime: TDateTimePicker;
    Label6: TLabel;
    cbMarket: TComboBox;
    stHultPL: TStaticText;
    stCur: TStaticText;
    stForFutQty: TStaticText;
    Button2: TButton;
    stHultPos: TStaticText;
    cbAutoStart: TCheckBox;
    plInfo: TPanel;
    sgLog: TStringGrid;
    cbAutoStop: TCheckBox;
    edtplTick3th: TEdit;
    udplTick3th: TUpDown;
    edtLcTick3th: TEdit;
    udLcTick3th: TUpDown;
    stGap: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);

    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Button3Click(Sender: TObject);
    procedure cbMarketChange(Sender: TObject);
    procedure cbSymbolsChange(Sender: TObject);
    procedure cbAutoLiquidClick(Sender: TObject);
    procedure cbTargetChange(Sender: TObject);
    procedure cbParaSymbolChange(Sender: TObject);
    procedure edtAfValChange(Sender: TObject);
    procedure cbParaClick(Sender: TObject);
    procedure edtForFutQtyChange(Sender: TObject);
    procedure edtQtyChange(Sender: TObject);
    procedure edtplTick1thChange(Sender: TObject);
    procedure cbAutoStopClick(Sender: TObject);
    procedure cbParaLiquidClick(Sender: TObject);
    procedure cbAutoStartClick(Sender: TObject);
    procedure edtTargetPosChange(Sender: TObject);

  private
    { Private declarations }
    FAccount    : TAccount;
    FSymbol     : TSymbol;
    FParaSymbol : TSymbol;
    FTimer   : TQuoteTimer;
    FJarvisData : TJarvisData;
    FBHultAxis : TBHultEx;

    FMax, FMin : double;
    FAutoStart : boolean;

    FInitSymbol : boolean;

    procedure initControls;
    procedure GetParam;

    procedure Timer1Timer(Sender: TObject);
    function GetRect(oRect: TRect): TRect;
    procedure initSymbols;
    procedure SetControls(bEnable: boolean);
    procedure MarketChange;
    procedure DoLog( stLog : string );
  public
    { Public declarations }
    procedure Stop( bCnl : boolean = true );
    procedure Start;
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
    procedure OnDisplay(Sender: TObject; Value : boolean );
    procedure OnJarvisNotify( Sender : TObject; jetType : TjarvisEventType; stData : string );
    procedure BullMessage( var Msg : TMessage ) ;  message WM_ENDMESSAGE;
    
  end;

var
  FrmBHult: TFrmBHult;

implementation

uses
  GAppEnv, GleLib,{ CleStrategyStore,} CleVirtualHult;

{$R *.dfm}

{ TFrmBHult }

procedure TFrmBHult.BullMessage(var Msg: TMessage);
begin
  cbStart.Checked := false;
end;

procedure TFrmBHult.Button2Click(Sender: TObject);
begin

  with FJarvisData do
  begin                           
    StartTime   := dtStartTime.Time;
    EndTime     := dtEndTime.Time;
  end;

  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;

end;

procedure TFrmBHult.Button3Click(Sender: TObject);
begin
  //
  if FBHultAxis <> nil then
    FBHultAxis.DoLiquid;
end;

procedure TFrmBHult.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;

  if FAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    FAccount := aAccount;
    FBHultAxis := nil;
  end;

end;

procedure TFrmBHult.cbAutoLiquidClick(Sender: TObject);
var
  i : integer;
begin
  with FJarvisData do
  begin
    UseAutoLiquid := cbAutoLiquid.Checked;

    if UseAutoLiquid then
    begin
      PLTick[0] := StrToIntDef( edtPLTick1th.Text, 0 );
      PLTick[1] := StrToIntDef( edtPLTick2th.Text, 0 );
      PLTick[2] := StrToIntDef( edtPLTick3th.Text, 0 );

      LCTick[0] := StrToIntDef( edtLCTick1th.Text, 0 );
      LCTick[1] := StrToIntDef( edtLCTick2th.Text, 0 );
      LCTick[2] := StrToIntDef( edtLCTick3th.Text, 0 );

      PLCount := 0;
      for I := 0 to High(PLTick) do
      begin
        if PLTick[i] = 0 then
          break;
        inc( PLCount );
      end;

      LCCount := 0;
      for I := 0 to High(LCTick) do
      begin
        if LCTick[i] = 0 then
          break;
        inc(LCCount );
      end;
    end;
  end;

  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;

end;

procedure TFrmBHult.cbAutoStartClick(Sender: TObject);
begin
  FTimer.Enabled  := cbAutoStart.Checked;
end;

procedure TFrmBHult.cbAutoStopClick(Sender: TObject);
begin
  FJarvisData.UseAutoStop := cbAutoStop.Checked;
  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;
end;

procedure TFrmBHult.cbParaLiquidClick(Sender: TObject);
begin
  FJarvisData.UseParaLiquid := cbParaLiquid.Checked;
  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;
end;

procedure TFrmBHult.cbMarketChange(Sender: TObject);
begin
  //
  MarketChange;
end;

procedure TFrmBHult.cbParaClick(Sender: TObject);
begin

  if ( FBHultAxis = nil ) or ( not cbStart.Checked ) then Exit;

  with FJarvisData do
  case (Sender as TCheckBox).Tag of
    0 :
      begin
        UsePara := cbPara.Checked;
        AFValue := StrTofloatDef( edtAfVal.Text, 0.001 );
        FBHultAxis.UpdatePara( UsePara, AFValue, FParaSymbol ) ;
      end;
    1 :
      begin
        UseForFutQty  := cbForeign.Checked;
        ForFutQty := StrToIntDef( edtForFutQty.Text, 0 );
        FBHultAxis.JarvisData := FJarvisData ;
      end;
    2 :
      begin
        UseHultPos  := cbHultPos.Checked;
        TargetTick  := StrToIntDef( cbTarget.Items[ cbTarget.ItemIndex], 5 );
        TargetPos   := StrToIntDef( edtTargetPos.Text, 3 );
        FBHultAxis.UpdateHult( UseHultPos, TargetTick, TargetPos );
      end;
  end;
end;



procedure TFrmBHult.cbParaSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  aSymbol := nil;
  case cbParaSymbol.ItemIndex of
    0 : aSymbol := gEnv.Engine.SymbolCore.Futures[0];
    1 : aSymbol := FSymbol;
  end;

  if aSymbol = FParaSymbol then Exit;

  FParaSymbol := aSymbol;
end;

procedure TFrmBHult.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop( false );
end;


procedure TFrmBHult.cbSymbolsChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if cbSymbols.ItemIndex = -1 then Exit;

  aSymbol := GetComboObject( cbSymbols ) as TSymbol;
  if aSymbol = nil then Exit;
  if FSymbol = aSymbol then Exit;

  FSymbol := aSymbol;

  cbParaSymbolChange( cbParaSymbol );
end;

procedure TFrmBHult.cbTargetChange(Sender: TObject);
var
  iTmp : integer;
begin

  if cbStart.Checked then
  begin
    iTmp  := StrToIntDef( cbTarget.Items[ cbTarget.ItemIndex], 5 );
    if iTmp <> FJarvisData.TargetTick then
      cbHultPos.Checked := false;
  end;
end;

procedure TFrmBHult.DoLog(stLog: string);
begin
  InsertLine( sgLog, 1 );
  sgLog.Cells[0, 1] := FormatDateTime('hh:nn:ss', GetQuoteTime );
  sgLog.Cells[1, 1] := stLog;
end;

procedure TFrmBHult.edtAfValChange(Sender: TObject);
begin
  if cbStart.Checked then
    cbPara.Checked  := false;
end;

procedure TFrmBHult.edtForFutQtyChange(Sender: TObject);
begin
  if cbStart.Checked then
    cbForeign.Checked := false;
end;

procedure TFrmBHult.edtplTick1thChange(Sender: TObject);
begin
  if ( cbAutoLiquid.Checked ) and ( cbStart.Checked ) then
    cbAutoLiquid.Checked  := false;
end;

procedure TFrmBHult.edtQtyChange(Sender: TObject);
var
  iTmp : integer;
begin
  if ( FBHultAxis = nil ) or ( not cbStart.Checked ) then Exit;

  with FJarvisData do
  case (Sender as TEdit ).Tag of
    0 : OrdQty  := StrToIntDef( edtQty.Text, 1 ) ;
    1 : OrdGap  := StrToIntDef( edtGap.Text, 5 ) ;
    2 :
      begin
        iTmp    := OrdCnt;
        OrdCnt  := StrToIntDef( edtOrdCnt.Text, 1 ) ;
        if iTmp < OrdCnt then
          FBHultAxis.IncOrderCount( OrdCnt - iTmp );
      end;
  end;

  FBHultAxis.JarvisData := FJarvisData;

end;

procedure TFrmBHult.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmBHult.edtTargetPosChange(Sender: TObject);
begin

  FJarvisData.TargetPos := StrToIntDef( edtTargetPos.Text, 5 );
  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;
end;

procedure TFrmBHult.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
        cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmBHult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmBHult.FormCreate(Sender: TObject);
begin
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );
  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  FAutoStart := false;
  FInitSymbol:= false;

//  cbMarket.ItemIndex  := 0;
//  cbMarketChange(cbMarket);
end;

procedure TFrmBHult.FormDestroy(Sender: TObject);
var
  stLog : string;
begin
  FTimer.Enabled := false;
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  FBHultAxis.Free;
end;

procedure TFrmBHult.GetParam;
begin
  with FJarvisData do
  begin
    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtGap.Text, 5 );
    OrdCnt  := StrToIntDef( edtOrdCnt.Text, 1 );

    UseAutoLiquid := cbAutoLiquid.Checked;
    UseAutoStop   := cbAutoStop.Checked;
    UseParaLiquid := cbParaLiquid.Checked;

    cbAutoLiquidClick( cbAutoLiquid );

    UsePara := cbPara.Checked;
    ParaSymbol  := cbParaSymbol.ItemIndex;
    AfValue     := StrToFloatDef( edtAfVal.Text, 0.01 );

    UseForFutQty  := cbForeign.Checked;
    ForFutQty     := StrToIntDef( edtForFutQty.Text, 0 );

    UseHultPos    := cbHultPos.Checked;
    //cbTargetChange( cbTarget );
    TargetTick  := StrToIntDef( cbTarget.Items[ cbTarget.ItemIndex], 5 );
    TargetPos := StrToIntDef( edtTargetPos.Text, 4 ) ;

    StartTime   := dtStartTime.Time;
    EndTime     := dtEndTime.Time;

  end;
                            {
  if FBHultAxis <> nil then
    FBHultAxis.BHultData := FBHultData;
    }
end;

procedure TFrmBHult.initControls;
begin
  FTimer   := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval:= 300;
  FTimer.OnTimer := Timer1Timer;
end;

procedure TFrmBHult.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;
  // Main
  cbAutoStart.Checked := aStorage.FieldByName('AutoStart').AsBoolean ;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end
  else begin
    if cbAccount.Items.Count > 0 then
    begin
      cbAccount.ItemIndex := 0;
      cbAccountChange(cbAccount);
    end;
  end;

  cbMarket.ItemIndex  := aStorage.FieldByName('MarketIndex').AsInteger;

  // 기본
  udQty.Position    := StrToIntDef(aStorage.FieldByName('OrderQty').AsString, 1 );
  udGap.Position    := StrToIntDef(aStorage.FieldByName('OrderGap').AsString, 5 );
  udOrdCnt.Position := StrToIntDef(aStorage.FieldByName('Ordercnt').AsString, 1 );

  // 자동 청산
  cbAutoLiquid.Checked  := aStorage.FieldByName('UseAutoLiquid').AsBoolean;
  cbParaLiquid.Checked  := aStorage.FieldByName('UseParaLiquid').AsBoolean;
  cbAutoStop.Checked    := aStorage.FieldByName('UseAutoStop').AsBoolean;

  udplTick1th.Position  := StrToIntDef(aStorage.FieldByName('PlTick1th').AsString, 5 );
  udplTick2th.Position  := StrToIntDef(aStorage.FieldByName('PlTick2th').AsString, 8 );
  udplTick3th.Position  := StrToIntDef(aStorage.FieldByName('PlTick3th').AsString, 10 );

  udLcTick1th.Position  := StrToIntDef(aStorage.FieldByName('LcTick1th').AsString, 5 );
  udLcTick2th.Position  := StrToIntDef(aStorage.FieldByName('LcTick2th').AsString, 8 );
  udLcTick3th.Position  := StrToIntDef(aStorage.FieldByName('LcTick3th').AsString, 10 );

  // 조건
  cbPara.Checked    :=  aStorage.FieldByName('UsePara').AsBoolean;
  cbForeign.Checked :=  aStorage.FieldByName('UseForeign').AsBoolean;
  cbHultPos.Checked :=  aStorage.FieldByName('UseHultPos').AsBoolean;

  cbParaSymbol.ItemIndex  := aStorage.FieldByName('ParaSymbolIndex').AsInteger;
  edtForFutQty.Text       := aStorage.FieldByName('ForFutQty').AsString ;
  cbTarget.ItemIndex      := aStorage.FieldByName('TargetIndex').AsInteger;

  udTargetPos.Position:= aStorage.FieldByName('TargetPos').AsInteger;
  edtAfVal.Text       := aStorage.FieldByName('AfVal').AsString ;

  // 시간
  dtStartTime.Time  := TDateTime( aStorage.FieldByName('StartTime').AsFloat	);
  dtEndTime.Time    := TDateTime( aStorage.FieldByName('EndTime').AsFloat	);

  if cbAutoStart.Checked  then
    FTimer.Enabled  := true;

end;

procedure TFrmBHult.OnDisplay(Sender: TObject; Value: boolean);
var
  i : integer;
  aItem : THultPriceItem;
begin
  if FBHultAxis = nil then exit;
end;

procedure TFrmBHult.OnJarvisNotify(Sender: TObject; jetType: TjarvisEventType;
  stData: string);
begin
  if Sender <> FBHultAxis then Exit;

  case jetType of
    jetLog : DoLog( stData ) ;
    jetStop: PostMessage( Handle, WM_ENDMESSAGE, 0, 0 );
  end;

end;

procedure TFrmBHult.SaveEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin
  if aStorage = nil then Exit;
  // Main

  aStorage.FieldByName('AutoStart').AsBoolean     := cbAutoStart.Checked;
  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString  := FAccount.Code;
  aStorage.FieldByName('MarketIndex').AsInteger := cbMarket.ItemIndex;

  // 기본
  aStorage.FieldByName('OrderQty').AsString := edtQty.Text;
  aStorage.FieldByName('OrderGap').AsString := edtGap.Text;
  aStorage.FieldByName('Ordercnt').AsString := edtOrdCnt.Text;

  // 자동 청산
  aStorage.FieldByName('UseAutoLiquid').AsBoolean := cbAutoLiquid.Checked ;
  aStorage.FieldByName('UseParaLiquid').AsBoolean := cbParaLiquid.Checked ;
  aStorage.FieldByName('UseAutoStop').AsBoolean   := cbAutoStop.Checked ;

  aStorage.FieldByName('PlTick1th').AsString  := edtplTick1th.Text;
  aStorage.FieldByName('PlTick2th').AsString  := edtplTick2th.Text;
  aStorage.FieldByName('PlTick3th').AsString  := edtplTick3th.Text;

  aStorage.FieldByName('LcTick1th').AsString  := edtLcTick1th.Text;
  aStorage.FieldByName('LcTick2th').AsString  := edtLcTick2th.Text;
  aStorage.FieldByName('LcTick3th').AsString  := edtLcTick3th.Text;

  // 조건
  aStorage.FieldByName('UsePara').AsBoolean   := cbPara.Checked  ;
  aStorage.FieldByName('UseForeign').AsBoolean:= cbForeign.Checked ;
  aStorage.FieldByName('UseHultPos').AsBoolean:= cbHultPos.Checked ;

  aStorage.FieldByName('ParaSymbolIndex').AsInteger:= cbParaSymbol.ItemIndex;
  aStorage.FieldByName('AfVal').AsString      := edtAfVal.Text    ;

  aStorage.FieldByName('ForFutQty').AsString  := edtForFutQty.Text;

  aStorage.FieldByName('TargetIndex').AsInteger:= cbTarget.ItemIndex;
  aStorage.FieldByName('TargetPos').AsInteger := udTargetPos.Position;
  // 시간
  aStorage.FieldByName('StartTime').AsFloat	:= double( dtStartTime.Time );
  aStorage.FieldByName('EndTime').AsFloat	:= double( dtEndTime.Time );

end;

procedure TFrmBHult.SetControls( bEnable : boolean );
begin
  cbAccount.Enabled := bEnable;
  cbSymbols.Enabled := bEnable;
  cbMarket.Enabled  := bEnable;
  cbParaSymbol.Enabled  := bEnable;

  if bEnable then
    Panel1.Color  := clBtnFAce
  else begin
    Panel1.Color  := clSkyBlue;
    plInfo.Caption  := '';
  end;
end;

procedure TFrmBHult.Start;
var
  aColl : TStrategys;
begin

  if ( FSymbol = nil ) or ( FAccount = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FBHultAxis = nil then
    FBHultAxis := gEnv.Engine.TradeCore.PaveManasger.New( FAccount, FSymbol, opJarvis) as TBHultEx;

  if FBHultAxis <> nil then
  begin
    SetControls( false );
    GetParam;
    FBHultAxis.JarvisData := FJarvisData;

    FBHultAxis.init( FAccount, FSymbol, FParaSymbol );
    FBHultAxis.Start;
    FBHultAxis.OnJarvisEvent  := OnJarvisNotify;
    FTimer.Enabled := true;
    FInitSymbol    := true;
  end;
end;

procedure TFrmBHult.Stop( bCnl : boolean = true );
begin
  SetControls( true );

  if FBHultAxis <> nil then
  begin
    FBHultAxis.Stop( bCnl );
    FBHultAxis.OnJarvisEvent  := nil;
  end;
end;

procedure TFrmBHult.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
  //
  if stTxt.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stTxt.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stTxt.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect(Rect);
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

function TFrmBHult.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top+1, oRect.Right, oRect.Bottom );
end;

procedure TFrmBHult.MarketChange;
var
  aSymbol : TSymbol;
begin

  cbSymbols.Clear;
  FSymbol := nil;

  case cbMarket.ItemIndex of
    0 :
      begin
        aSymbol := gEnv.Engine.SymbolCore.Futures[0];
        AddSymbolCombo( aSymbol, cbSymbols );
      end;
    1 :
      begin
        gEnv.Engine.SymbolCore.Calls.GetList( cbSymbols.Items );
        if cbSymbols.Items.Count > 0 then
          cbSymbols.ItemIndex := 0;
      end;
    2 :
      begin
        gEnv.Engine.SymbolCore.Puts.GetList( cbSymbols.Items );
        if cbSymbols.Items.Count > 0 then
          cbSymbols.ItemIndex := 0;
      end;
  end;

  cbSymbolsChange( cbSymbols );

end;
procedure TFrmBHult.initSymbols;
var
  dtTime  : TDateTime;
begin
  // 옵션 종목 선정 때문에  스타트 시간 1분전에 한다..
  dtTime  := IncMinute(dtStartTime.Time, -1 );
  if dtTime > GetQuoteTime then Exit;

  MarketChange;

  FInitSymbol := FSymbol <> nil;

  if ( FInitSymbol ) and ( cbAutoStart.Checked )  then
    cbStart.Checked := true;
end;

procedure TFrmBHult.Timer1Timer(Sender: TObject);
var
  dBase, dCur, dNext, dLoss, dGap : double;
  iIdx, iGap  : integer;
  aSlot : TBHultOrderSlotItem;
  aType : TPositionType;
  ftColor : TColor;
begin

  if not FInitSymbol then
    initSymbols;

  if (FSymbol = nil ) then exit;

  if FBHultAxis <> nil then
  begin

    if (FBHultAxis.Para <> nil ) and ( FParaSymbol <> nil ) then
    begin
      dGap  :=  FBHultAxis.Para.SAR - FParaSymbol.Last;
      stCur.Caption := Format('%.3f', [ abs(dGap) ] );
      if FBHultAxis.Para.Side = 0 then
        stCur.font.Color := clBtnFace
      else if FBHultAxis.Para.Side > 0  then
        stCur.font.Color := clRed
      else if FBHultAxis.Para.Side < 0 then
        stCur.font.Color := clBlue;
    end;

    if FBHultAxis.Hult <> nil then
    begin
      stHultPos.Caption := IntToStr( FBHultAxis.Hult.GetVolume );
      stHultPL.Caption  := Format('%.0f', [ FBHultAxis.Hult.GetPL / 1000 ]);

      if FBHultAxis.Hult.GetVolume  < 0 then
        stHultPos.Font.Color := clBlue
      else if FBHultAxis.Hult.GetVolume > 0 then
        stHultPos.Font.Color  := clRed
      else
        stHultPos.Font.Color  := clblack;

      if FBHultAxis.Hult.GetPL  < 0 then
        stHultPL.Font.Color := clBlue
      else if FBHultAxis.Hult.GetPL > 0 then
        stHultPL.Font.Color  := clRed
      else
        stHultPL.Font.Color  := clblack;
    end;

    if FBHultAxis.ForeignerFut <> nil then
    begin
      stForFutQty.Caption := IntToSTr( FBHultAxis.ForeignerFut.SumQty );
      if FBHultAxis.ForeignerFut.SumQty  < 0 then
        stForFutQty.Font.Color := clBlue
      else if FBHultAxis.ForeignerFut.SumQty > 0 then
        stForFutQty.Font.Color  := clRed
      else
        stForFutQty.Font.Color  := clblack;
    end;

    if FBHultAxis.OrderSlots <> nil then
    begin

      dBase := FBHultAxis.OrderSlots.BasePrice;
      aSlot := FBHultAxis.OrderSlots.LastSlot;

      if aSlot <> nil then
      begin

        if FBHultAxis.OrderSlots.OrdCount > 0 then
        begin
          if FBHultAxis.Position.Volume > 0 then
            aType := ptLong
          else aType := ptShort ;

          dNext := aSlot.Price[ aType ];
          plInfo.Caption  := Format('%s - B:%.2f, C:%.2f, %.2f  ', [
            ifThenStr( FBHultAxis.OrderSlots.PosType = ptLong , 'L','S'),
            dBase, FSymbol.Last, dNext ] )  ;
        end
        else begin
          plInfo.Caption  := Format('%s - B:%.2f, C:%.2f, (%.2f | %.2f)  ',
           [ ifThenStr( FBHultAxis.OrderSlots.PosType = ptLong , 'L','S'),
            dBase, FSymbol.Last, aSlot.Price[ptShort], aSlot.Price[ptLong]      ] )
        end;
      end;

    end;

    if FBHultAxis.Position <> nil then
    begin

      stTxt.Panels[0].Text  := IntToStr( abs(FBHultAxis.Position.Volume ));
      stTxt.Tag := FBHultAxis.Position.Volume;

      FMin := Min( FMin, (FBHultAxis.Position.LastPL - FBHultAxis.Position.GetFee) );
      FMax := Max( FMax, (FBHultAxis.Position.LastPL - FBHultAxis.Position.GetFee) );

      stTxt.Panels[1].Text := Format('%d,%d',[ FBHultAxis.SucCnt, FBHultAxis.FailCnt ] );
      stTxt.Panels[2].Text := Format('%.0f, %.0f, %.0f', [
            (FBHultAxis.Position.LastPL - FBHultAxis.Position.GetFee)/1000 , FMax/1000, FMin/1000]);

      iGap := 0;
      if FBHultAxis.Position.Volume > 0 then
        iGap := Round(( FSymbol.Last - FBHultAxis.Position.AvgPrice ) / FSymbol.Spec.TickSize)
      else if FBHultAxis.Position.Volume < 0 then
        iGap := Round(( FBHultAxis.Position.AvgPrice - FSymbol.Last ) / FSymbol.Spec.TickSize);

      if iGap = 0 then
        stGap.Font.Color  := clBlack
      else if iGap > 0 then
        stGap.Font.Color  := clRed
      else stGap.Font.Color := clBlue;

      stGap.Caption := IntToStr( iGap );
           
    end;
  end;

end;

end.

