unit FTrendTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,

  CleStorage,  CleAccounts, ClePositions,  CleSymbols, CleORders,

  CleTrendTrade

  ;

const
  TitleCnt = 7;
  Title : array [0..TitleCnt-1] of string = ( '구분','조건','가격',
                                              '몇종목','건수','청산',
                                              '기타' );                 
  TitleCnt2 = 7;
  Title2 : array [0..TitleCnt2-1] of string = ( '시각','종목','구분',
                                              'LS','수량','평균가','비고' );

  Order_Col = 0;

type
  TFrmTrendTrade = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    rbF: TRadioButton;
    rbO: TRadioButton;
    stBar: TStatusBar;
    dtStartTime: TDateTimePicker;
    Panel2: TPanel;
    cbLiqSymbol: TComboBox;
    Button4: TButton;
    edtLiqQty: TEdit;
    UpDown3: TUpDown;
    Button5: TButton;
    Timer1: TTimer;
    Panel3: TPanel;
    cbTrend1: TCheckBox;
    edtQty1: TEdit;
    UpDown1: TUpDown;
    dtEndTime: TDateTimePicker;
    Button2: TButton;
    btnApply1: TButton;
    sgTrend1: TStringGrid;
    cbTrend2: TCheckBox;
    edtQty2: TEdit;
    UpDown2: TUpDown;
    cbTrend2Stop: TCheckBox;
    Button3: TButton;
    Button1: TButton;
    dtStartTime2: TDateTimePicker;
    Label1: TLabel;
    dtEndTime2: TDateTimePicker;
    cbInvest: TComboBox;
    sgTrend2: TStringGrid;
    Panel4: TPanel;
    sgOrd: TStringGrid;
    cbUseCnt: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure btnApply1Click(Sender: TObject);
    procedure rbFClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure stBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Button4Click(Sender: TObject);
    procedure cbLiqSymbolChange(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbTrend1Click(Sender: TObject);
    procedure cbTrend2Click(Sender: TObject);
    procedure cbTrend2StopClick(Sender: TObject);
    procedure sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private
    FAutoStart : boolean;
    FAccount  : TAccount;
    FSymbol   : TSymbol;
    TT        : TTrendTrade;
    FParam    : TTrendParam;
    procedure initControls;
    procedure SetDefaultParam(iDir: integer);
    procedure GetParam( iDir : integer );

    function GetInvestCode : string;
    { Private declarations }
  public
    { Public declarations }

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnTrendNotify( Sender : TObject; stData : string; iDiv : integer );
    procedure OnTrendOrderEvent( aItem : TOrderedItem; iDiv : integer );
    procedure OnTrendResultNotify(Sender: TObject; Value : boolean );
  end;

var
  FrmTrendTrade: TFrmTrendTrade;

implementation

uses
  GAppEnv, GleLib, GleTypes, GleConsts, CleQuoteTimers
  ;

{$R *.dfm}

procedure TFrmTrendTrade.btnApply1Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  GetParam( iTag );
end;

procedure TFrmTrendTrade.Button2Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  SetDefaultParam( iTag );
end;

procedure TFrmTrendTrade.Button4Click(Sender: TObject);
var
  I: Integer;
  aItem : TOrderedItem;
  stData : string;
begin

  if TT = nil then Exit;
  //if tt.Orders.Count > 0 then
  //begin
    //cbLiqSymbol.Enabled := false;
  cbLiqSymbol.Clear;
  //end;

  for I := 0 to tt.Orders.Count - 1 do
  begin
    aItem := tt.Orders.Ordered[i];
    if aItem.stType = stTrend then
      stData := '추세1 '
    else if aItem.stType = stInvestor then
      stData := '추세2 '
    else
      Continue;
    cbLiqSymbol.AddItem( stData + aItem.Symbol.ShortCode, aItem );
  end;

  if cbLiqSymbol.Items.Count > 0 then
    cbLiqSymbol.ItemIndex := 0;  

end;

procedure TFrmTrendTrade.Button5Click(Sender: TObject);
var
  iQty  : integer;
  aItem : TOrderedItem;
  bRes  : boolean;
begin

  try
    if (cbLiqSymbol.Items.Count <= 0) or ( cbLiqSymbol.ItemIndex  < 0 ) then Exit;
    aItem := TOrderedItem( cbLiqSymbol.Items.Objects[ cbLiqSymbol.ItemIndex ] );
    iQty  := StrToInt( edtLiqQty.Text );
    //aitme, iQty

    if ( aItem <> nil ) and ( iQty > 0 ) and ( iQty < 10 ) then
    begin
      bRes := TT.DoManualOrder( iQty, aItem );
      if bRes then begin
        Button4Click( nil );
      end;
    end;

  except
  end;

end;

procedure TFrmTrendTrade.SetDefaultParam( iDir : integer );
var
  i : integer;
begin
  case iDir of
    // 추세 1
    1 : if rbF.Checked then
        begin
          with sgTrend1 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '0.7';
              Cells[2,i]  := '0';
              Cells[3,i]  := '1';
              Cells[4,i]  := '2';
              Cells[5,i]  := '0.9';
              Cells[6,i]  := '';
            end;
        end
        else begin
          with sgTrend1 do
          begin
              // 매수
              Cells[1,1]  := '0.7';
              Cells[2,1]  := '0.7';
              Cells[3,1]  := '1';
              Cells[4,1]  := '2';
              Cells[5,1]  := '0.9';
              Cells[6,1]  := '3.0';

              // 매도
              Cells[1,2]  := '0.65';
              Cells[2,2]  := '1';
              Cells[3,2]  := '1';
              Cells[4,2]  := '2';
              Cells[5,2]  := '1';
              Cells[6,2]  := '';
          end;

        end;
    // 추세 2 투자자
    2 : if rbF.Checked then
        begin
          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';      // 조건
              if i=2 then
                Cells[1,i]  := '-50';      // 조건

              Cells[2,i]  := '0';       // 진입가격조건
              Cells[3,i]  := '1';       // 종목카운트
              Cells[4,i]  := '1';       // 진입카운트
              Cells[5,i]  := '0';       // 청산조건
              Cells[6,i]  := '50';       // 청산조건
            end;
        end
        else begin

          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';
              if i=2 then
                Cells[1,i]  := '-50';      // 조건
              Cells[2,i]  := '1';
              Cells[3,i]  := '1';
              Cells[4,i]  := '1';
              Cells[5,i]  := '0';
              Cells[6,i]  := '50';
            end;

        end;
  end;
end;

procedure TFrmTrendTrade.sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer;
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

procedure TFrmTrendTrade.stBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  {
  var
    oRect : TRect;

  function GetRect( oRect : TRect ) : TRect ;
  begin
    Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
  end;
  }
begin
   {
  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stBar.Canvas.Handle, PChar( stBar.Panels[0].Text ),
    Length( stBar.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
    }
end;

procedure TFrmTrendTrade.Timer1Timer(Sender: TObject);
var
  stData, stFile : string;
  dTot, dFut, dOpt, dS : double;
begin
  // 손익 적기
  if FAccount = nil then Exit;

  dFut := 0; dOpt := 0; dS := 0;  dTot := 0;

  dTot := dTot
      + gEnv.Engine.TradeCore.Positions.GetMarketPl( FAccount, dFut, dOpt, dS  );

  stData  := Format('%.0f ', [ ( dTot / 1000) - ( FAccount.GetFee / 1000 )] );

  stBar.Panels[2].Text := stData;
end;

function TFrmTrendTrade.GetInvestCode: string;
begin
  case cbInvest.ItemIndex of
    0 : Result := INVEST_FINANCE;
    2 : Result := INVEST_GONG;
    1 : REsult := INVEST_FORIN;
  end;
end;

procedure TFrmTrendTrade.GetParam( iDir : integer );
begin
  with FParam do
  begin

    StartTime := dtStartTime.Time;
    EndTime   := dtEndTime.Time;

    StartTime2:= dtStartTime2.Time;
    EndTime2  := dtEndTime2.Time;
    UseFut  := rbF.Checked;

    UseTrd1 := cbTrend1.Checked;
    UseTrd2 := cbTrend2.Checked;
    UseTrdStop  := cbTrend2Stop.Checked;

    case iDir of
      1 : begin
        OrdQty1            := StrToIntDef( edtQty1.Text, 2 );
        OrdCon1[ptLong]    := StrToFloat( sgTrend1.Cells[1,1] ) ;
        BasePrice1[ptLong] := StrToFloat( sgTrend1.Cells[2,1] ) ;
        SymbolCnt1[ptLong] := StrToInt( sgTrend1.Cells[3,1] ) ;
        OrdCnt1[ptLong] := StrToInt( sgTrend1.Cells[4,1] ) ;
        LiqCon1[ptLong] := StrToFloat( sgTrend1.Cells[5,1] )  ;
        OtrCon1[ptLong] := StrToFloatdef( sgTrend1.Cells[6,1], 3 ) ;

        OrdCon1[ptShort]    := StrToFloat( sgTrend1.Cells[1,2] ) ;
        BasePrice1[ptShort] := StrToFloat( sgTrend1.Cells[2,2] ) ;
        SymbolCnt1[ptShort] := StrToInt( sgTrend1.Cells[3,2] ) ;
        OrdCnt1[ptShort] := StrToInt( sgTrend1.Cells[4,2] ) ;
        LiqCon1[ptShort] := StrToFloat( sgTrend1.Cells[5,2] )  ;
        OtrCon1[ptShort] := StrToFloatdef( sgTrend1.Cells[6,2], 3 ) ;

        end;
      2 : begin
        OrdQty2            := StrToIntDef( edtQty2.Text, 1 );
        OrdCon2[ptLong]    := StrToFloat( sgTrend2.Cells[1,1] ) ;
        BasePrice2[ptLong] := StrToFloat( sgTrend2.Cells[2,1] ) ;
        SymbolCnt2[ptLong] := StrToInt( sgTrend2.Cells[3,1] ) ;
        OrdCnt2[ptLong] := StrToInt( sgTrend2.Cells[4,1] ) ;
        LiqCon2[ptLong] := StrToFloat( sgTrend2.Cells[5,1] )  ;
        OtrCon2[ptLong] := StrToFloatdef( sgTrend2.Cells[6,1], 50 ) ;

        OrdCon2[ptShort]    := StrToFloat( sgTrend2.Cells[1,2] ) ;
        BasePrice2[ptShort] := StrToFloat( sgTrend2.Cells[2,2] ) ;
        SymbolCnt2[ptShort] := StrToInt( sgTrend2.Cells[3,2] ) ;
        OrdCnt2[ptShort] := StrToInt( sgTrend2.Cells[4,2] ) ;
        LiqCon2[ptShort] := StrToFloat( sgTrend2.Cells[5,2] )  ;
        OtrCon2[ptShort] := StrToFloatdef( sgTrend2.Cells[6,2], 50 ) ;

        UseCnt    := cbUseCnt.Checked;
      end;
    end;
  end;

  if TT <> nil then
    TT.Param  := FParam;

end;


procedure TFrmTrendTrade.cbAccountChange(Sender: TObject);

var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;

end;

procedure TFrmTrendTrade.cbLiqSymbolChange(Sender: TObject);
var
  aItem : TOrderedItem;
begin
  if (cbLiqSymbol.Items.Count <= 0) or ( cbLiqSymbol.ItemIndex  < 0 ) then Exit;

  aItem := TOrderedItem( cbLiqSymbol.Items.Objects[ cbLiqSymbol.ItemIndex ] );
  if aItem <> nil then
    UpDown3.Position  := aItem.Order.FilledQty
end;

procedure TFrmTrendTrade.cbStartClick(Sender: TObject);
begin
  if ( FAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin
    TT.init( FAccount, FSymbol );
    TT.OnTrendNotify  := OnTrendNotify;
    TT.OnTrendOrderEvent  := OnTrendOrderEvent;
    TT.OnTrendResultNotify:= OnTrendResultNotify;
    GetParam(1);
    GetParam(2);
    TT.InvestCode := GetInvestCode;
    TT.Start;
  end
  else begin
    TT.OnTrendNotify  := nil;
    TT.OnTrendOrderEvent  := nil;
    TT.OnTrendResultNotify:= nil;
    TT.Stop;
  end;

end;

procedure TFrmTrendTrade.cbTrend1Click(Sender: TObject);
begin
  if TT = nil then Exit;

  FParam.UseTrd1  := cbTrend1.Checked;
  if TT <> nil then
    TT.Param  := FParam;
end;

procedure TFrmTrendTrade.cbTrend2Click(Sender: TObject);
begin
  if TT = nil then Exit;

  FParam.UseTrd2  := cbTrend2.Checked;

  if TT <> nil then
    TT.Param  := FParam;
end;

procedure TFrmTrendTrade.cbTrend2StopClick(Sender: TObject);
begin
  if TT = nil then Exit;

  FParam.UseTrdStop  := cbTrend2Stop.Checked;

  if TT <> nil then
    TT.Param  := FParam;
end;

procedure TFrmTrendTrade.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmTrendTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TFrmTrendTrade.FormCreate(Sender: TObject);
begin
  //
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList(cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange(cbAccount);
  end;

  FSymbol := gEnv.Engine.SymbolCore.Future;

  TT        := TTrendTrade.Create(nil);
  FAutoStart := false;
end;

procedure TFrmTrendTrade.FormDestroy(Sender: TObject);
begin
  TT.Stop;
  TT.Free;
end;

procedure TFrmTrendTrade.initControls;
var
  I: integer;
begin

  for I := 0 to TitleCnt - 1 do begin
    with sgTrend1 do Cells[i,0]  := Title[i];
    with sgTrend2 do Cells[i,0]  := Title[i];
  end;


  with sgOrd do
    for I := 0 to TitleCnt2 - 1 do
      Cells[i,0]  := Title2[i];

  sgTrend1.Cells[0,1] := '매수';
  sgTrend1.Cells[0,2] := '매도';

  sgTrend2.Cells[0,1] := '매수';
  sgTrend2.Cells[0,2] := '매도';

  SetDefaultParam(1);
  SetDefaultParam(2);

end;

procedure TFrmTrendTrade.LoadEnv(aStorage: TStorage);
var
  j, i : integer;
  aAcnt: TAccount;
begin
  if aStorage = nil then Exit;

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('AccountCode').AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    cbAccountChange(cbAccount);
  end;

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName( Format('Trend1[%d,%d]',[j,i] ) ).AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString;

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName( Format('Trend2[%d,%d]', [j,i])  ).AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString;

  cbTrend1.Checked  := aStorage.FieldByName('Trend1').AsBoolean;
  cbTrend2.Checked  := aStorage.FieldByName('Trend2').AsBoolean;

  rbF.Checked := aStorage.FieldByName('Fut').AsBoolean ;
  rbO.Checked := aStorage.FieldByName('Opt').AsBoolean ;

  cbTrend2Stop.Checked  := aStorage.FieldByName('Trend2Stop').AsBoolean ;

  UpDown1.Position := StrToIntDef( aStorage.FieldByName('Qty1').AsString, 2 );
  UpDown2.Position := StrToIntDef( aStorage.FieldByName('Qty2').AsString, 1 );

  dtStartTime.Time := TDateTime( aStorage.FieldByName('StartTime').AsFloat );
  dtEndTime.Time := TDateTime( aStorage.FieldByName('EndTime').AsFloat );

  dtStartTime2.Time := TDateTime( aStorage.FieldByName('StartTime2').AsFloat );
  dtEndTime2.Time := TDateTime( aStorage.FieldByName('EndTime2').AsFloat );

  cbInvest.ItemIndex  := aStorage.FieldByName('InvestIdx').AsInteger ;
  cbUseCnt.Checked    := aStorage.FieldByName('UseCnt').AsBoolean;
end;

procedure TFrmTrendTrade.OnTrendNotify(Sender: TObject; stData: string;
  iDiv: integer);
begin
  if Sender <> TT then Exit;
  stBar.Panels[iDiv-1].Text := stData;
end;

procedure TFrmTrendTrade.OnTrendOrderEvent(aItem: TOrderedItem; iDiv: integer);
var
  iRow : integer;
  stDiv: string;
begin
  iRow := 1;
  InsertLine( sgOrd, iRow );

  if aItem.stType = stTrend then
    stDiv := '건수'
  else
    stDiv := '투자';

  with sgOrd do
  begin
    if iDiv > 0  then
    begin
      Objects[Order_Col, iRow]  := aItem.Order;
    end
    else begin
      Objects[Order_Col, iRow]  := aItem.LiqOrder;
    end;

    if aItem.stType = stTrend then
      Objects[1, iRow]  := Pointer(clWhite)
    else
      Objects[1, iRow]  := Pointer($00EEEEEE);

    Cells[0, iRow]  := FormatDateTime('hh:nn:ss', GetQuoteTime );
    Cells[1, iRow]  := aItem.Symbol.ShortCode;
    Cells[2, iRow]  := stDiv;

    if iDiv > 0 then begin
      Cells[3, iRow] := ifThenStr( aItem.Order.Side > 0 ,'L','S' );
      Cells[4, iRow]  := IntToStr( aItem.Order.OrderQty );
    end
    else begin
      Cells[3, iRow] := ifThenStr( aItem.LiqOrder.Side > 0 ,'L','S' );
      Cells[4, iRow]  := IntToStr( aItem.LiqOrder.OrderQty );
    end;  

    Cells[5, iRow]  := Format('%.2f', [ aItem.Order.FilledPrice ] );
    Cells[6, iRow]  := ifThenStr( iDiv > 0 ,'신규','청산' );
  end;
end;

procedure TFrmTrendTrade.OnTrendResultNotify(Sender: TObject; Value: boolean);
var
  iRow : integer;
begin
//
  iRow  := sgOrd.Cols[Order_Col].IndexOfObject( Sender );

  if iRow > 0 then
  begin
    with sgOrd do
      Cells[5, iRow]  := Format('%.2f', [ ( Sender as TOrder).FilledPrice ] );
  end;
end;

procedure TFrmTrendTrade.rbFClick(Sender: TObject);
begin
  SetDefaultParam(1);
  SetDefaultParam(2);

  if TT = nil then Exit;

  FParam.UseFut  := rbF.Checked;
  if TT <> nil then
    TT.Param  := FParam;
end;

procedure TFrmTrendTrade.SaveEnv(aStorage: TStorage);
var
  j, i : integer;
begin
  if aStorage = nil then Exit;

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString  := Cells[j,i];

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString   := Cells[j,i];

  aStorage.FieldByName('Trend1').AsBoolean  := cbTrend1.Checked;
  aStorage.FieldByName('Trend2').AsBoolean  := cbTrend2.Checked;

  aStorage.FieldByName('Fut').AsBoolean  := rbF.Checked;
  aStorage.FieldByName('Opt').AsBoolean  := rbO.Checked;
  aStorage.FieldByName('Trend2Stop').AsBoolean  := cbTrend2Stop.Checked;

  aStorage.FieldByName('Qty1').AsString := edtQty1.Text;
  aStorage.FieldByName('Qty2').AsString := edtQty2.Text;

  aStorage.FieldByName('StartTime').AsFloat := double( dtStartTime.Time );
  aStorage.FieldByName('StartTime2').AsFloat := double( dtStartTime2.Time );

  aStorage.FieldByName('EndTime').AsFloat := double( dtEndTime.Time );
  aStorage.FieldByName('EndTime2').AsFloat := double( dtEndTime2.Time );

  aStorage.FieldByName('InvestIdx').AsInteger := cbInvest.ItemIndex;
  aStorage.FieldByName('UseCnt').AsBoolean    := cbUseCnt.Checked;
end;

end.
