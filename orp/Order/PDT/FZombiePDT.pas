unit FZombiePDT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleSymbols, CleQuoteBroker, CleDistributor,

  UPaveConfig, UOscillatorBase, UOscillators, CleReEatTrend,

  CleStorage, CleQuoteTimers, CleOrders,

  GleTypes, StdCtrls, ExtCtrls, ComCtrls, Grids, ActnMan, ActnColorMaps
  ;

const
  TitleCnt = 6;
  Order_Col = 0;
  Title : array [0..TitleCnt-1] of string = ( '시각','종목','구분',
                                              'LS','수량','평균가' );
  BHULT_ENV = 'bhult.ini';
type
  TFrmZombiePDT = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    Panel2: TPanel;
    Label2: TLabel;
    edtSymbol: TEdit;
    Button1: TButton;
    stbar: TStatusBar;
    GroupBox4: TGroupBox;
    edtAbove: TEdit;
    Label5: TLabel;
    edtBelow: TEdit;
    cbDir: TComboBox;
    Panel3: TPanel;
    sgOrd: TStringGrid;
    cbBHAcnt: TComboBox;
    edtReOrdCnt: TEdit;
    udReOrdCnt: TUpDown;
    edtLiqPer: TEdit;
    edtRiskAmt: TEdit;
    dtFstLiquidTime: TDateTimePicker;
    Button2: TButton;
    Label3: TLabel;
    Label7: TLabel;
    Label4: TLabel;
    Button4: TButton;
    Button3: TButton;
    edtEntryAmt: TEdit;
    edtInitQty: TEdit;
    edtAddQty: TEdit;
    udAddQty: TUpDown;
    edtDecAmt: TEdit;
    cbTargetQty: TCheckBox;
    cbTerm: TCheckBox;
    cbFut: TCheckBox;
    edtPLAmt: TEdit;
    cbOptSell: TCheckBox;
    cbVer2: TCheckBox;
    cbVer2R: TCheckBox;
    edtPLAbove: TEdit;
    Label6: TLabel;
    rgEntryMode: TRadioGroup;
    cbFixPL: TCheckBox;
    procedure cbAccountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

    procedure edt1thProfitTickKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtAFKeyPress(Sender: TObject; var Key: Char);
    procedure Button4Click(Sender: TObject);

    procedure stbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure cbBHAcntChange(Sender: TObject);
    procedure sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button3Click(Sender: TObject);
    procedure cbFutClick(Sender: TObject);
    procedure cbOptSellClick(Sender: TObject);
    procedure cbVer2Click(Sender: TObject);


  private
    FSymbol: TSymbol;
    FBHAccount  ,FAccount: TAccount;

    FEatTrend  : TReEatTrend;
    FZPDTData : TZombiPDT;
    
    FTimer : TQuoteTimer;

    MaxPl, MinPl : double;

    FAutoStart : boolean;
    procedure initControls;
    procedure GetParam;
    function GetRect(oRect: TRect): TRect;
    procedure LoadConfig;
    { Private declarations }
  public
    { Public declarations }
    property Account : TAccount read FAccount ;
    property Symbol  : TSymbol  read FSymbol;

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnEatTrendEvent( Sender : TObject; iDiv, iDir : integer );
    procedure OnEatTrendOrderEvent( Sender : TObject; aData : TObject; bEntry, bAdd : boolean );
    procedure OnLogTimer( Sender : TObject );

    property EatTrend  : TReEatTrend read FEatTrend write FEatTrend;
    property ZPDTData  : TZombiPDT   read FZPDTData;
  end;

var
  FrmZombiePDT: TFrmZombiePDT;

implementation

uses
  GAppEnv, GleLib , CleIni
  ;

{$R *.dfm}


procedure TFrmZombiePDT.initControls;
var
  i : Integer;
begin

  MaxPl := -1;
  MinPl := 10000000;

  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := false;
  FTimer.Interval := 200;
  FTimer.OnTimer := OnLogTimer;

  with sgOrd do
    for I := 0 to TitleCnt - 1 do
      Cells[i,0]  := Title[i];
end;

procedure TFrmZombiePDT.LoadEnv(aStorage: TStorage);
var
  stCode : string;
begin
  if aStorage = nil then Exit;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;

  if gEnv.Simul then begin
    FSymbol := gEnv.Engine.SymbolCore.Future
  end
  else
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if FSymbol <> nil then
    edtSymbol.Text  := FSymbol.Code;

  stCode := aStorage.FieldByName('AccountCode').AsString;
  if stCode = '' then Exit;
  FAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FAccount <> nil then
  begin
    SetComboIndex( cbAccount, FAccount );
    cbAccountChange(cbAccount);
  end;

  stCode := aStorage.FieldByName('BHAccountCode').AsString;
  if stCode = '' then Exit;
  FBHAccount := gEnv.Engine.TradeCore.Accounts.Find( stCode );
  if FBHAccount <> nil then
  begin
    SetComboIndex( cbBHAcnt, FBHAccount );
    cbBHAcntChange(cbBHAcnt);
  end;

  edtBelow.Text   := aStorage.FieldByName('Below').AsString;
  edtAbove.Text   := aStorage.FieldByName('Above').AsString ;
  udReOrdCnt.Position := aStorage.FieldByName('ReOrdCnt').AsInteger ;
  rgEntryMode.ItemIndex := aStorage.FieldByName('EntryMode').AsInteger;

  udAddQty.Position := aStorage.FieldByName('AddQty').AsInteger;
  cbDir.ItemIndex   := aStorage.FieldByName('Dir').AsInteger ;

  edtDecAmt.Text    := aStorage.FieldByName('DecAmt').AsString ;
  edtRiskAmt.Text   := aStorage.FieldByName('RiskAmt').AsString ;
  edtEntryAmt.Text  := aStorage.FieldByName('EntryAmt').AsString;
  edtPLAmt.Text  := aStorage.FieldByName('PLAmt').AsString;
  edtInitQty.Text   := aStorage.FieldByName('InitQty').AsString;
  edtLiqPer.Text  := aStorage.FieldByName('LiqPer').AsString ;

  dtFstLiquidTime.Time  := TDateTime( aStorage.FieldByName('LiquidTime').AsFloat );

  cbTargetQty.Checked := aStorage.FieldByName('UseTargetQty').AsBoolean;
  cbTerm.Checked      := aStorage.FieldByName('UseTerm').AsBoolean;
  cbFut.Checked       := aStorage.FieldByName('UseFut').AsBoolean;
  cbOptSell.Checked   := aStorage.FieldByName('UseOptSell').AsBoolean ;
  cbVer2.Checked      := aStorage.FieldByName('UseVer2').AsBoolean ;

  cbFixPL.Checked     := aStorage.FieldByName('UseFixPL ').AsBoolean ;

end;

procedure TFrmZombiePDT.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
  begin
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code;
  end
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  if FBHAccount <> nil then
    aStorage.FieldByName('BHAccountCode').AsString := FBHAccount.Code
  else
    aStorage.FieldByName('BHAccountCode').AsString := '';


  aStorage.FieldByName('Below').AsString    := edtBelow.Text ;
  aStorage.FieldByName('Above').AsString    := edtAbove.Text;

  aStorage.FieldByName('ReOrdCnt').AsInteger  := udReOrdCnt.Position;
  aStorage.FieldByName('AddQty').AsInteger  := udAddQty.Position;
  aStorage.FieldByName('Dir').AsInteger     := cbDir.ItemIndex;

  aStorage.FieldByName('EntryMode').AsInteger  := rgEntryMode.ItemIndex;

  aStorage.FieldByName('DecAmt').AsString   := edtDecAmt.Text;
  aStorage.FieldByName('RiskAmt').AsString  := edtRiskAmt.Text;
  aStorage.FieldByName('EntryAmt').AsString := edtEntryAmt.Text;
  astorage.FieldByName('InitQty').AsString  := edtInitQty.Text;
  aStorage.FieldByName('LiqPer').AsString   := edtLiqPer.Text;
  aStorage.FieldByName('PLAmt').AsString    := edtPLAmt.Text;

  aStorage.FieldByName('LiquidTime').AsFloat:= dtFstLiquidTime.Time;

  aStorage.FieldByName('UseTargetQty').AsBoolean  := cbTargetQty.Checked ;
  aStorage.FieldByName('UseTerm').AsBoolean       := cbTerm.Checked ;
  aStorage.FieldByName('UseFut').AsBoolean        := cbFut.Checked ;
  aStorage.FieldByName('UseOptSell').AsBoolean    := cbOptSell.Checked ;
  aStorage.FieldByName('UseVer2').AsBoolean    := cbVer2.Checked ;

  aStorage.FieldByName('UseFixPL ').AsBoolean  := cbFixPL.Checked;
end;

procedure TFrmZombiePDT.sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer;
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

  with sgOrd do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      if ACol = 3 then
        if stTxt = 'L' then
          ftClr := clRed
        else
          ftClr := clBlue;

      if Objects[1,ARow] <> nil then
        bgClr := TColor( Objects[1,ARow] );

      if ACol in [4,5] then
        wFmt  := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;

end;

procedure TFrmZombiePDT.stbarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  var
    oRect : TRect;
begin
  //
  if stBar.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stBar.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stBar.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stBar.Canvas.Handle, PChar( stBar.Panels[0].Text ),
    Length( stBar.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;

end;

function TFrmZombiePDT.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmZombiePDT.OnEatTrendEvent(Sender: TObject; iDiv, iDir: integer);
begin
  if EatTrend <> nil then
  begin
    stBar.Panels[0].Text  := IntToStr( abs(EatTrend.Position.Volume ));
    stBar.Tag := EatTrend.Position.Volume;
  end;
end;

procedure TFrmZombiePDT.OnEatTrendOrderEvent(Sender: TObject; aData : TObject;
  bEntry,  bAdd: boolean);
var
  iRow : integer;
  stDiv: string;
  aOrder: TOrder;
begin
  iRow := 1;
  if bAdd then
    InsertLine( sgOrd, iRow )
  else
    iRow  := sgOrd.Cols[ Order_Col ].IndexOfObject( aData );

  if (iRow <= 0) or ( aData = nil ) then
    Exit;

  if bEntry then
    stDiv := '진입'
  else
    stDiv := '청산';

  aOrder  := aData as TOrder;

  with sgOrd do
  begin
    if bADd  then
      Objects[Order_Col, iRow]  := aOrder;

    Cells[0, iRow]  := FormatDateTime('hh:nn:ss', GetQuoteTime );
    Cells[1, iRow]  := aOrder.Symbol.ShortCode;
    Cells[2, iRow]  := stDiv;

    Cells[3, iRow] := ifThenStr( aOrder.Side > 0 ,'L','S' );

    if bAdd then
      Cells[4, iRow]  := IntToStr( aOrder.OrderQty )
    else
      Cells[4, iRow]  := IntToStr( aOrder.FilledQty );

    Cells[5, iRow]  := Format('%.2f', [ aOrder.FilledPrice ] );
  end;  
end;

procedure TFrmZombiePDT.OnLogTimer(Sender: TObject);
begin
  if (EatTrend <> nil) and ( FAccount <> nil ) then
  begin
    stbar.Panels[2].Text  := Format('%.0f, %.0f, %.0f ', [
      Account.PL, Account.MaxPL, Account.MinPL]);

    stbar.Panels[1].Text  := Format('%.0f, %.0f, %.0f ', [
      EatTrend.TargetPL[2],  EatTrend.TargetPL[0], EatTrend.TargetPL[1] ]);
  end
end;

procedure TFrmZombiePDT.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
        begin
          ShowMessage('실행중에는 종목을 바꿀수 없음');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.Code;
          EatTrend := nil;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmZombiePDT.LoadConfig;
var
  ini : TInitFile;
  iCount, iPos, i : integer;
  stTmp : string;
begin
  ini := nil;
  try
    ini := TInitFile.Create( BHULT_ENV );
    iCount:= ini.GetInteger('CONFIG', 'COUNT');

    if iCount <=  0 then Exit;

    with FZPDTData do
    begin
      ToVal   := nil;
      FromVal := nil;
      EntVal  := nil;

      TermCnt := iCount;

      SetLength( ToVal, iCount );
      SetLength( FromVal, iCount );
      SetLength( EntVal, iCount );
      SetLength( Ordered, iCount );

      for I := 0 to iCount - 1 do
      begin
        stTmp := 'CON_'+FZPDTData.EntryAmt+'_'+IntToStr(i);
        FromVal[i]  := ini.GetFloat(stTmp, 'From' );
        ToVal[i]    := ini.GetFloat(stTmp, 'To' );
     //   if UseSlice then
     //     EntVal[i]   := StrToFloatDef( FzPDTData.EntryAmt, 200 ) * 10
     //   else
          ini.GetFloat(stTmp, 'Ent' );;
        Ordered[i]  := false;
      end;
    end;

  finally
    ini.Free;
  end;
end;

procedure TFrmZombiePDT.Button2Click(Sender: TObject);
begin

  if FAccount = nil then
  begin
    ShowMessage('계좌를 먼저 선택하세요');
    Exit;
  end;

  GetParam;
  if EatTrend <> nil then
    EatTrend.ZPDTData  := FZPDTData;
end;

procedure TFrmZombiePDT.Button3Click(Sender: TObject);
var
  stName : string;
begin
  if FAccount = nil then
  begin
    ShowMessage('계좌를 먼저 선택하세요');
    Exit;
  end;

  stName := ExtractFilePath( paramstr(0) )+ 'env\'+BHULT_ENV;
  ShowNotePad( Handle, stName );
end;

procedure TFrmZombiePDT.Button4Click(Sender: TObject);
begin
  if EatTrend <> nil then
    EatTrend.DoLiquid;

end;

procedure TFrmZombiePDT.cbAccountChange(Sender: TObject);
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
    EatTrend := nil;
  end;
end;


procedure TFrmZombiePDT.cbBHAcntChange(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbBHAcnt ) as TAccount;
  if aAccount = nil then Exit;

  if FBHAccount <> aAccount then
  begin
    if cbStart.Checked then
    begin
      ShowMessage('실행중에는 계좌를 바꿀수 없음');
      Exit;
    end;
    FBHAccount := aAccount;   
  end;
end;


procedure TFrmZombiePDT.cbFutClick(Sender: TObject);
begin
  if cbOptSell.Checked then
  begin
    ShowMessage('반옵 매도와 동시 선택이 안됨 ');
    cbFut.Checked := false;
    Exit;
  end;

end;

procedure TFrmZombiePDT.cbOptSellClick(Sender: TObject);
begin
  if cbFut.Checked then
  begin
    ShowMessage('fut 과 동시 선택이 안됨 ');
    cbOptSell.Checked := false;
    Exit;
  end;
end;

procedure TFrmZombiePDT.cbVer2Click(Sender: TObject);
begin
{
  if not cbTerm.Checked then
  begin
    ShowMessage('구간 과 같이 선택해야 됨 ');
    cbSlice.Checked := false;
    Exit;
  end;
  }
end;

procedure TFrmZombiePDT.cbStartClick(Sender: TObject);
begin
  if ( FSymbol = nil ) or ( FAccount = nil ) or ( FBHAccount = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin
    EatTrend  := gEnv.Engine.TradeCore.PaveManasger.New( FAccount, FSymbol, opPDT) as TReEatTrend;

    if EatTrend <> nil then
    begin
      EatTrend.init( FAccount, FSymbol, integer( opPDT ) );
      Button2Click( nil );
      EatTrend.EatTrendEvent      := OnEatTrendEvent;
      EatTrend.EatTrendOrderEvent := OnEatTrendOrderEvent;
      EatTrend.TargetAcnt   := FBHAccount;
      EatTrend.Start;

      FTimer.Enabled := true;
    end;
  end
  else
    if EatTrend <> nil then
    begin
      EatTrend.EatTrendEvent := nil;
      EatTrend.Stop;

    end;
end;



procedure TFrmZombiePDT.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmZombiePDT.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmZombiePDT.FormCreate(Sender: TObject);
begin
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  gEnv.Engine.TradeCore.Accounts.GetList( cbBHAcnt.Items );

  if cbBHAcnt.Items.Count > 0 then
  begin
    cbBHAcnt.ItemIndex := 0;
    cbBHAcntChange( cbAccount );
  end;

  FAutoStart := false;
end;

procedure TFrmZombiePDT.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  gEnv.Engine.TradeCore.PaveManasger.RemvoePave( EatTrend );
end;

procedure TFrmZombiePDT.edt1thProfitTickKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmZombiePDT.edtAFKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0;
end;

procedure TFrmZombiePDT.GetParam;
var
  i : integer;
begin

  with FZPDTData do
  begin

    Below  := StrToFloatDef( edtBelow.Text, 1.5 );
    Above  := StrToFloatDef( edtAbove.Text, 0.3 );
    AscIdx := cbDir.ItemIndex;
    OrdReCount := StrToIntDef( edtReOrdCnt.Text, 1 );

    EntryAmt  := edtEntryAmt.Text;
    dEntryAmt := StrToFloatDef(EntryAmt, 200 ) * 10;
    InitQty   := StrToIntDef( edtInitQty.Text  , 40 );
    AddQty    := StrToIntDef( edtAddQty.Text, 5 );
    RiskAmt   := StrToFloatDef( edtRiskAmt.Text , 10000) ;
    DecAmt    := StrToFloatDef( edtDecAmt.Text, 100 );
    PLAmt     := StrToFloatDef( edtPLAmt.Text, 700 );
    PLAbove   := StrToFloatDef( edtPLAbove.Text, 5000 );
    LiqPer    := StrToIntDef( edtLiqPer.Text, 30 );

    FstLiquidTime := dtFstLiquidTime.Time;

    UseTargetQty := cbTargetQty.Checked;
    UseTerm      := cbTerm.Checked;
    UseFut       := cbFut.Checked;
    UseOptSell   := cbOptSell.Checked;
    UseVer2     := cbVer2.Checked;    
    //
    UseVer2R    := cbVer2R.Checked;

    EntryMode := rgEntryMode.ItemIndex;
    UseFixPL  := cbFixPL.Checked;
  end;

  LoadConfig;
end;

end.
