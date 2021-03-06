unit FleHultHedge;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FmHultHedge, ComCtrls, StdCtrls, ExtCtrls,

  CleSymbols, CleOrders, CleAccounts, CleHultHedge,

  CleStorage
  ;

const
  MaxCount = 4;
  plHeight = 78;  // 패널 하나의 높이
  MainHeight = 150;  // 패널 하나일때 폼 높이

type

  TFmItem = class( TCollectionItem )
  public
    param : THultHedgeParam;
    Hulthedge : TfmHhedge;
    pl  : TPanel;
    //HHItem : THultHedgeItem;
    RefIdx : integer;  // index of THultHedgeItem
  end;

  TFrmHultHedge = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    stBar: TStatusBar;
    Button1: TButton;
    Button2: TButton;
    edtCount: TEdit;
    Panel2: TPanel;
    plMain1: TPanel;
    fmHhedge1: TfmHhedge;
    plMain2: TPanel;
    fmHhedge2: TfmHhedge;
    plMain3: TPanel;
    fmHhedge3: TfmHhedge;
    plMain4: TPanel;
    fmHhedge4: TfmHhedge;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbStartClick(Sender: TObject);
    procedure fmHhedge1CheckBox1Click(Sender: TObject);
    procedure fmHhedge1Button1Click(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FAutoStart : boolean;
    FHCount: integer;
    FHHs: THultHedgeItems;
    FAccount  : TAccount;
    FSymbol   : TSymbol;

    procedure SetCount(const Value: integer);
    function GetHeight : integer;
    procedure GetParam(aItem : TFmItem); overload;
    procedure GetParam; overload;
    { Private declarations }
  public
    { Public declarations }
    FmItems : TCollection;

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    property HCount : integer read FHCount write SetCount;

    property HHs : THultHedgeItems read FHHs write FHHs;
  end;

var
  FrmHultHedge: TFrmHultHedge;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

procedure TFrmHultHedge.Button1Click(Sender: TObject);
var
  iTag  : integer;
  aItem : TFmItem;
begin
  iTag := TButton( Sender ).Tag;

  if (iTag > 0) and ( FHCount < MaxCount ) then
  begin
    HCount := FHCount + iTag;
    aItem := TFmItem( FmItems.Items[ FHCount-1] );
    aItem.Hulthedge.Enabled := true;
    Constraints.MaxHeight  := GetHeight;
    Height  :=  GetHeight;

  end else
  if (iTag < 0) and ( FHCount > 1 ) then
  begin
    HCount := FHCount + iTag;
    Constraints.MaxHeight  := GetHeight;
    Height  :=  GetHeight;
    aItem := TFmItem( FmItems.Items[ FHCount ] );
    aItem.Hulthedge.Enabled := false;
  end;

end;

procedure TFrmHultHedge.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
end;

procedure TFrmHultHedge.cbStartClick(Sender: TObject);
begin
  //
  if ( FAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin
    FHHs.init( FAccount, FSymbol );
    GetParam;
    FHHs.Start;
    Button1.Enabled := false;
    Button2.Enabled := false;
    {
    TT.init( FAccount, FSymbol );
    TT.OnTrendNotify  := OnTrendNotify;
    TT.OnTrendOrderEvent  := OnTrendOrderEvent;
    TT.OnTrendResultNotify:= OnTrendResultNotify;
    GetParam(1);
    GetParam(2);
    TT.InvestCode := GetInvestCode;
    TT.Start;
    }
  end
  else begin
    FHHs.Stop;
    Button1.Enabled := true;
    Button2.Enabled := true;
  {
    TT.OnTrendNotify  := nil;
    TT.OnTrendOrderEvent  := nil;
    TT.OnTrendResultNotify:= nil;
    TT.Stop;
    }
  end;

end;

procedure TFrmHultHedge.fmHhedge1Button1Click(Sender: TObject);
var
  iTag : integer;
  aItem : TFmItem;
  aH : THultHedgeItem;
begin
  iTag  := TButton( Sender ).Tag;

  if (iTag < 0 ) or ( iTag >= FmItems.Count ) then
    Exit;

  aItem := TFmItem( FmItems.Items[iTag] );
  if aItem <> nil then
  begin
    GetParam( aItem );
    aH  := FHHs.HedgeItem[ aItem.RefIdx ];
    if aH <> nil then
      aH.Param  := aItem.param;
  end;

end;

procedure TFrmHultHedge.GetParam( aItem : TFmItem );
begin
  with aItem do
  begin
    Param.StartTime1 := Hulthedge.dtStartTime1.Time;
    Param.EndTime    := Hulthedge.dtEndTime.Time;

    Param.StartTime2:= Hulthedge.dtStartTime2.Time;
    Param.Qty := StrToIntDef( Hulthedge.edtQty.Text, 1 );

    Param.E1  := StrToFloatDef(HultHedge.edtE.Text, 0.5 );
    Param.L1  := StrToFloatDef(HultHedge.edtL1.Text, 0.7 );
    Param.L2  := StrToFloatDef(HultHedge.edtL2.Text, 1.8 );
    Param.LC  := StrToFloatDef(HultHedge.edtLC.Text, 0.8 );
    Param.ConPlus := StrToFloatDef(HultHedge.edtPlus.Text , 0.3 );
    Param.Run := HultHedge.cbStart.Checked;

    //
    Param.UseFut  := HultHedge.cbFut.Checked;
    Param.UseOpt  := HultHedge.cbOpt.Checked;
    Param.dBelow  := StrToFloatDef( HultHedge.edtBelow.Text, 1.8 );
    Param.dAbove  := StrToFloatDef( HultHedge.edtAbove.Text, 0.3 );
    Param.AscIdx  := HultHedge.cbDir.ItemIndex;
    Param.OptCnt  := StrToIntDef( HultHedge.edtOptCnt.Text, 1 );

    Param.OptQty  := StrtoIntDef( HultHedge.edtOptQty.Text, 1 );
  end;
end;

procedure TFrmHultHedge.fmHhedge1CheckBox1Click(Sender: TObject);
var
  iTag : integer;
  aItem : TFmItem;
  aH : THultHedgeItem;
begin
  iTag  := TCheckBox( Sender ).Tag;
  if (iTag < 0 ) or ( iTag >= FmItems.Count ) then
    Exit;

  aItem := TFmItem( FmItems.Items[iTag] );
  if aItem <> nil then
  begin
    aItem.param.Run := TCheckBox( Sender ).Checked;
    aH  := FHHs.HedgeItem[ aItem.RefIdx ];
    if aH <> nil then
      aH.Param  := aItem.param;
  end;
end;

procedure TFrmHultHedge.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmHultHedge.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TFrmHultHedge.FormCreate(Sender: TObject);
var
  aItem : TFmItem;
  i: Integer;
  aH : THultHedgeItem;
begin
  //
  gEnv.Engine.TradeCore.Accounts.GetList(cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange(cbAccount);
  end;

  FSymbol := gEnv.Engine.SymbolCore.Future;

  FAutoStart := false;

  FmItems := TCollection.Create( TFmItem );
  FHHs:= THultHedgeItems.Create;

  aItem := FmItems.Add as TFmItem;
  aItem.pl  := plMain1;
  aItem.Hulthedge := fmHhedge1;
  aItem.Hulthedge.lbNo.Caption  := IntToStr( FmItems.Count );
  //aItem.Hulthedge.Enabled := false;
  aH  := FHHs.New( FmItems.Count );
  aItem.RefIdx  := FmItems.Count - 1;

  aItem := FmItems.Add as TFmItem;
  aItem.pl  := plMain2;
  aItem.Hulthedge :=  fmHhedge2;
  aItem.Hulthedge.lbNo.Caption  := IntToStr( FmItems.Count );
  aItem.Hulthedge.Enabled := false;
  aH  := FHHs.New( FmItems.Count );
  aItem.RefIdx  := FmItems.Count - 1;

  aItem := FmItems.Add as TFmItem;
  aItem.pl  := plMain3;
  aItem.Hulthedge :=  fmHhedge3;
  aItem.Hulthedge.lbNo.Caption  := IntToStr( FmItems.Count );
  aItem.Hulthedge.Enabled := false;
  aH  := FHHs.New( FmItems.Count );
  aItem.RefIdx  := FmItems.Count - 1;

  aItem := FmItems.Add as TFmItem;
  aItem.pl  := plMain4;
  aItem.Hulthedge :=  fmHhedge4;
  aItem.Hulthedge.lbNo.Caption  := IntToStr( FmItems.Count );
  aItem.Hulthedge.Enabled := false;
  aH  := FHHs.New( FmItems.Count );
  aItem.RefIdx  := FmItems.Count - 1;

  HCount  := 1;
  Constraints.MaxHeight  := GetHeight;

end;

procedure TFrmHultHedge.FormDestroy(Sender: TObject);
begin
  //
  FHHs.Stop;
  FHHs.Free;
  FmItems.Free;
end;

function TFrmHultHedge.GetHeight: integer;
begin
  Result  := MainHeight + ( (FHCount - 1) * plHeight ) + 1;
end;

procedure TFrmHultHedge.GetParam;
var
  iTag : integer;
  aItem : TFmItem;
  aH : THultHedgeItem;
begin

  for iTag := 0 to FHHs.Count - 1 do
  begin
    aItem := TFmItem( FmItems.Items[iTag] );
    if aItem <> nil then
    begin
      GetParam( aItem );
      aH  := FHHs.HedgeItem[ aItem.RefIdx ];
      if aH <> nil then
        aH.Param  := aItem.param;
    end;
  end;

end;

procedure TFrmHultHedge.LoadEnv(aStorage: TStorage);
var
  I: Integer;
  aItem : TFmItem;
  aAcnt : TAccount;
begin
  if aStorage = nil then Exit;

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('AccountCode').AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    cbAccountChange(cbAccount);
  end;

  HCount  := aStorage.FieldByName('HCount').AsInteger;

  for I := 0 to HCount - 1 do
  begin
    aItem := TFmItem( FmItems.Items[i] );
    aItem.Hulthedge.dtStartTime1.Time := TDateTime( aStorage.FieldByName( Format('StartTime1_%d', [i]) ).AsFloat );
    aItem.Hulthedge.dtStartTime2.Time := TDateTime(aStorage.FieldByName( Format('StartTime2_%d', [i]) ).AsFloat );
    aItem.Hulthedge.dtEndTime.Time    := TDateTime(aStorage.FieldByName( Format('EndTime_%d', [i]) ).AsFloat );

    aItem.Hulthedge.edtQty.Text := aStorage.FieldByName( Format('Qty_%d',[ i]) ).AsString;
    aItem.Hulthedge.edtE.Text   := aStorage.FieldByName( Format('E_%d',[ i]) ).AsString ;
    aItem.Hulthedge.edtL1.Text  := aStorage.FieldByName( Format('L1_%d',[ i]) ).AsString;
    aItem.Hulthedge.edtL2.Text  := aStorage.FieldByName( Format('L2_%d',[ i]) ).AsString;
    aItem.Hulthedge.edtLC.Text  := aStorage.FieldByName( Format('LC_%d',[ i]) ).AsString;

    aItem.Hulthedge.edtPlus.Text:= aStorage.FieldByName( Format('Plus_%d',[ i]) ).AsString ;
    aItem.Hulthedge.cbStart.Checked := aStorage.FieldByName( Format('Run_%d',[ i]) ).AsBoolean ;

    aItem.Hulthedge.cbOptClick( aItem.Hulthedge.cbOpt );
    aITem.Hulthedge.cbFut.Checked   := aStorage.FieldByName( Format('UseFut_%d', [i] ) ).AsBoolean ;
    aITem.Hulthedge.cbOpt.Checked   := aStorage.FieldByName( Format('UseOpt_%d', [i] ) ).AsBoolean ;
    aItem.Hulthedge.edtBelow.Text   := aStorage.FieldByName( Format('Below_%d',[ i]) ).AsString;
    aItem.Hulthedge.edtAbove.Text   := aStorage.FieldByName( Format('Above_%d',[ i]) ).AsString;

    aITem.Hulthedge.udOptCnt.Position := aStorage.FieldByName(Format('OptCnt_%d',[ i]) ).AsInteger;
    aITem.Hulthedge.cbDir.ItemIndex   := aStorage.FieldByName(Format('Dir_%d',[ i]) ).AsInteger;
    aItem.Hulthedge.edtOptQty.Text    := aStorage.FieldByName( Format('OptQty_%d',[ i]) ).AsString ;

    aItem.Hulthedge.Enabled := true;
  end;

  Constraints.MaxHeight  := GetHeight;
  Height  := Constraints.MaxHeight;
end;

procedure TFrmHultHedge.SaveEnv(aStorage: TStorage);
var
  I: Integer;
  aItem : TFmItem;
begin
  if aStorage = nil then Exit;

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';  

  aStorage.FieldByName('HCount').AsInteger  := FHCount;

  for I := 0 to HCount - 1 do
  begin
    aItem := TFmItem( FmItems.Items[i] );
    aStorage.FieldByName( Format('StartTime1_%d', [i]) ).AsFloat := double( aItem.Hulthedge.dtStartTime1.Time );
    aStorage.FieldByName( Format('StartTime2_%d', [i]) ).AsFloat := double( aItem.Hulthedge.dtStartTime2.Time );
    aStorage.FieldByName( Format('EndTime_%d', [i]) ).AsFloat := double( aItem.Hulthedge.dtEndTime.Time );

    aStorage.FieldByName( Format('Qty_%d',[ i]) ).AsString  := aItem.Hulthedge.edtQty.Text;
    aStorage.FieldByName( Format('E_%d',[ i]) ).AsString  := aItem.Hulthedge.edtE.Text;
    aStorage.FieldByName( Format('L1_%d',[ i]) ).AsString  := aItem.Hulthedge.edtL1.Text;
    aStorage.FieldByName( Format('L2_%d',[ i]) ).AsString  := aItem.Hulthedge.edtL2.Text;
    aStorage.FieldByName( Format('LC_%d',[ i]) ).AsString  := aItem.Hulthedge.edtLC.Text;
    aStorage.FieldByName( Format('Plus_%d',[ i]) ).AsString  := aItem.Hulthedge.edtPlus.Text;

    aStorage.FieldByName( Format('Run_%d',[ i]) ).AsBoolean  := aItem.Hulthedge.cbStart.Checked;

    aStorage.FieldByName( Format('UseFut_%d', [i] ) ).AsBoolean := aITem.Hulthedge.cbFut.Checked;
    aStorage.FieldByName( Format('UseOpt_%d', [i] ) ).AsBoolean := aITem.Hulthedge.cbOpt.Checked;
    aStorage.FieldByName( Format('Below_%d',[ i]) ).AsString    := aItem.Hulthedge.edtBelow.Text ;
    aStorage.FieldByName( Format('Above_%d',[ i]) ).AsString    := aItem.Hulthedge.edtAbove.Text;

    aStorage.FieldByName( Format('OptQty_%d',[ i]) ).AsString    := aItem.Hulthedge.edtOptQty.Text;
    aStorage.FieldByName(Format('OptCnt_%d',[ i]) ).AsInteger   := aITem.Hulthedge.udOptCnt.Position ;
    aStorage.FieldByName(Format('Dir_%d',[ i]) ).AsInteger      := aITem.Hulthedge.cbDir.ItemIndex;
  end;
end;

procedure TFrmHultHedge.SetCount(const Value: integer);
begin
  FHCount := Value;
  edtCount.Text := IntToStr( FHCount );
end;

procedure TFrmHultHedge.Timer1Timer(Sender: TObject);
var
  stData, stFile : string;
  dTot, dFut, dOpt, dS : double;
  aItem : THultHedgeITem;
begin

  if FSymbol <> nil then
  begin
    aITem := FHHs.HedgeItem[0];
    if aITem <> nil then
    begin
      if FSymbol.DayOpen > FSymbol.Last then
      begin
        dS := FSymbol.Last - (FSymbol.DayOpen - aItem.Param.E1 );
        stData  := Format('▼ %.2f = C:%.2f - %.2f', [ dS, FSymbol.Last, (FSymbol.DayOpen - aItem.Param.E1 ) ]);
        stBar.Panels[0].Text := stData;

        stData := Format('%.2f', [ FSymbol.Last - FSymbol.DayLow]);
        stBar.Panels[1].Text := stData;
      end
      else begin
        dS := FSymbol.Last - (FSymbol.DayOpen + aItem.Param.E1 );
        stData  := Format('▲ %.2f = C:%.2f - %.2f', [ dS, FSymbol.Last, (FSymbol.DayOpen + aItem.Param.E1 ) ]);
        stBar.Panels[0].Text := stData;

        stData := Format('%.2f ', [ FSymbol.Last - FSymbol.DayHigh]);
        stBar.Panels[1].Text := stData;
      end;
    end;
  end;

  // 손익 적기
  if FAccount = nil then Exit;
  dFut := 0; dOpt := 0; dS := 0;  dTot := 0;
  dTot := dTot
      + gEnv.Engine.TradeCore.Positions.GetMarketPl( FAccount, dFut, dOpt, dS  );

  stData  := Format('%.0f ', [ ( dTot / 1000) - ( FAccount.GetFee / 1000 )] );
  stBar.Panels[2].Text := stData;


end;

end.
