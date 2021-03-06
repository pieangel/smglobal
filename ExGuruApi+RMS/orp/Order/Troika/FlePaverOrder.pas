unit FlePaverOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FmPaveOrder, ComCtrls,

  CleStorage,  ClePaveOrders  , ClePaveOrderType  , GleTypes
  ;

const
  MaxCount = 4;
  plHeight = 160;  // 패널 하나의 높이  ( 프레임 높이는 -3 해주면 됨..
  MainHeight = 232;  // 패널 하나일때 폼 높이

type
  TFrmPaveOrder = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PaveOrder1: TFramePaveOrder;
    PaveOrder2: TFramePaveOrder;
    PaveOrder3: TFramePaveOrder;
    PaveOrder4: TFramePaveOrder;
    StatusBar1: TStatusBar;
    Button1: TButton;
    Button2: TButton;
    edtCount: TEdit;
    Timer1: TTimer;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    FHCount: integer;
    FPavers: TPaveOrders;
    CtrlPave  : array [0..MaxCount-1] of TFramePaveOrder;
    procedure SetCount(const Value: integer);
    function GetHeight: integer;

    procedure OnCheckRun(Sender: TObject);
    procedure OnApplyParam(Sender: TObject);

    procedure OnLongCancel(Sender: TObject);
    procedure OnShortCancel(Sender: TObject);

    procedure OnLongDeposit(Sender: TObject);
    procedure OnShortDepoist(Sender: TObject);

    procedure AddPave(aPave: TFramePaveOrder);
    procedure DeletePave(aPave: TFramePaveOrder);
    { Private declarations }
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    property HCount : integer read FHCount write SetCount;
    property Pavers : TPaveOrders read FPavers;

    procedure WMPaveOrderEnd(var msg: TMessage); message WM_ENDPAVEORDER;
  end;

var
  FrmPaveOrder: TFrmPaveOrder;

implementation

uses
  GAppEnv , GleLib 
  ;

{$R *.dfm}


procedure TFrmPaveOrder.Button1Click(Sender: TObject);
var
  iTag  : integer;
 // aItem : TFmItem;
begin
  iTag := TButton( Sender ).Tag;

  if (iTag < 0) and ( FHCount > 1 ) then
  begin
    if CtrlPave[FHCount-1].cbStart.Checked then
    begin
      ShowMessage('런 상태에서는 없앨수 없음 ');
      Exit;
    end;
  end;

  if ((iTag > 0) and ( FHCount < MaxCount )) or
     ((iTag < 0) and ( FHCount > 1 ) ) then
  begin
    HCount := FHCount + iTag;
    Constraints.MaxHeight  := GetHeight;
    Height  :=  GetHeight;
  end;
  


end;

procedure TFrmPaveOrder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmPaveOrder.FormDestroy(Sender: TObject);
begin
  FPavers.DeleteItem( Self );
end;

procedure TFrmPaveOrder.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  HCount  := 1;
  Constraints.MaxHeight  := GetHeight;

  CtrlPave[0] := PaveOrder1;
  CtrlPave[1] := PaveOrder2;
  CtrlPave[2] := PaveOrder3;
  CtrlPave[3] := PaveOrder4;

  for I := 0 to MaxCount - 1 do
  begin
    CtrlPave[i].OnStartClick := OnCheckRun;
    CtrlPave[i].OnApplyClick := OnApplyParam;
    CtrlPave[i].OnLongCnlClick  := OnLongCancel;
    CtrlPave[i].OnShortCnlClick := OnShortCancel;

    CtrlPave[i].OnLongDepositClick  := OnLongDeposit;
  //  CtrlPave[i].OnShortDepositClick := OnShortDepoist;
  end;

  FPavers := gEnv.Engine.TradeCore.PaveManasger.Pavers;
end;

procedure TFrmPaveOrder.OnApplyParam(Sender: TObject);
var
  aPave : TFramePaveOrder;
  aItem : TPaveOrderItem;
begin

  if Sender = nil then Exit;
  aPave := Sender as TFramePaveOrder;

  gEnv.EnvLog( WIN_TEST, format('OnApplyParam Tag : %d, %s, count : %d',
    [  aPave.Tag, ifThenStr( aPave.cbStart.Checked, 'Start', 'Stop'), FPavers.Count ])  );

  if CtrlPave[ aPave.Tag-1] <> aPave then
  begin
    gEnv.EnvLog( WIN_TEST, format('OnApplyParam Tag : %d,  CtrlPave[%d] Tag : %d',
    [  aPave.Tag, aPave.Tag-1, CtrlPave[ aPave.Tag-1].Tag ])  );
    Exit;
  end;

  if not aPave.cbStart.Checked then Exit;

  aItem := FPavers.Find( aPave.Account, aPave.Symbol, Self, aPave.Tag );
  if aItem = nil then Exit;

  aItem.ApplyParam( aPave.edtLossVol.Text, aPave.edtLossPer.Text, Frac(aPave.dtEndTime.Time),
    aPave.edtCnlHour.Text, aPave.edtCnlTick.Text );

  gEnv.EnvLog( WIN_TEST, format('OnApplyParam Tag : %d, count : %d',
    [  aPave.Tag, FPavers.Count ])  );

end;

procedure TFrmPaveOrder.OnCheckRun(Sender: TObject);
var
  aPave : TFramePaveOrder;
begin

  if Sender = nil then Exit;
  aPave := Sender as TFramePaveOrder;

  gEnv.EnvLog( WIN_TEST, format('OnCheckRun Tag : %d, %s, count : %d',
    [  aPave.Tag, ifThenStr( aPave.cbStart.Checked, 'Start', 'Stop'), FPavers.Count ])  );

  if CtrlPave[ aPave.Tag-1] <> aPave then
  begin
    gEnv.EnvLog( WIN_TEST, format('OnCheckRun Tag Error: %d,  CtrlPave[%d] Tag : %d',
    [  aPave.Tag, aPave.Tag-1, CtrlPave[ aPave.Tag-1].Tag ])  );
    Exit;
  end;

  if aPave.cbStart.Checked then
    AddPave( aPave )
  else
    DeletePave( aPave );

  gEnv.EnvLog( WIN_TEST, format('OnCheckRun Tag : %d, count : %d',
    [  aPave.Tag, FPavers.Count ])  );
end;

procedure TFrmPaveOrder.OnLongCancel(Sender: TObject);
var
  aPave : TFramePaveOrder;
  aItem : TPaveOrderItem;
begin
  aPave := Sender as TFramePaveOrder;
  aItem := FPavers.Find( aPave.Account, aPave.Symbol, Self, aPave.Tag );
  if aItem = nil then Exit;

  aItem.LayOrder.DoCancels( 1,  StrToFloatDef( aPave.edtLCnlCon.Text, 0.5 ) );
end;

procedure TFrmPaveOrder.OnLongDeposit(Sender: TObject);
var
  aPave : TFramePaveOrder;
  aItem : TPaveOrderItem;
  dTmp, dSum, dPrice: double;
  i : integer;

  aParam : TLayOrderParam;
begin

  aPave := Sender as TFramePaveOrder;
  if aPave.Symbol = nil then Exit;

  if not aPave.cbL.Checked then Exit;

  aParam  := aPave.Param;

  dSum := 0; dTmp := 0;
  if aParam.UseL then
  begin
    dPrice  := aParam.LStartPrc;
    for I := 0 to aParam.OrdCnt - 1 do
    begin
      dTmp  := dPrice * aParam.OrdQty * aPave.Symbol.Spec.PointValue;
      dSum  := dSum + dTmp ;

      gEnv.EnvLog( WIN_TEST, Format('증거금(%d) : %.0n += %.0n (%.2f X %d)',
        [ i, dSum, dTmp, dPrice, aParam.OrdQty ] ) );
      dPrice  := dPrice - ( aPave.Symbol.Spec.TickSize * aParam.OrdGap );

      if dPrice < 0.01 then
      begin
        break;
      end;
    end;
  end;

  aPave.Display( Format('증거금 = %.0n' , [ dSum ] ), true );
end;


procedure TFrmPaveOrder.OnShortCancel(Sender: TObject);
var
  aPave : TFramePaveOrder;
  aItem : TPaveOrderItem;
begin
  aPave := Sender as TFramePaveOrder;
  aItem := FPavers.Find( aPave.Account, aPave.Symbol, Self, aPave.Tag );
  if aItem = nil then Exit;

  aItem.LayOrder.DoCancels( -1,  StrToFloatDef( aPave.edtSCnlCon.Text, 0.5 ) );

end;

procedure TFrmPaveOrder.OnShortDepoist(Sender: TObject);
begin

end;

procedure TFrmPaveOrder.AddPave( aPave : TFramePaveOrder );
var
  bNew : boolean;
  aItem : TPaveOrderItem;
  aParam: TLayOrderParam;
begin

  aItem := FPavers.New( aPave.Account, aPave.Symbol, Self, aPave.Tag, bNew );

  if bNew then
  begin
    aItem.init( aPave.Account, aPave.Symbol, aPave.Param );
    aItem.Start;
  end else
  begin
    // 이미 등록되어 있음..
    aPave.cbStart.Checked := false;
  end;
end;

procedure TFrmPaveOrder.DeletePave( aPave : TFramePaveOrder );
var
  aItem : TPaveOrderItem;
begin

  aItem := FPavers.Find( aPave.Account, aPave.Symbol, Self, aPave.Tag );
  if aItem <> nil then
  begin
    aItem.Stop;
    FPavers.DeleteItem( aItem );
  end;
end;

function TFrmPaveOrder.GetHeight: integer;
begin
  Result  := MainHeight + ( (FHCount - 1) * plHeight ) + 1;
end;

procedure TFrmPaveOrder.LoadEnv(aStorage: TStorage);
var
  I: Integer;
begin
  if aStorage = nil then Exit;

  for I := 0 to MaxCount - 1 do
    CtrlPave[i].LoadEnv( aStorage, i );

  FHCount  := aStorage.FieldByName('HCount').AsInteger;
  edtCount.Text := IntToStr( FHCount);
  Constraints.MaxHeight  := GetHeight;
  Height  := Constraints.MaxHeight;
end;

procedure TFrmPaveOrder.SaveEnv(aStorage: TStorage);
var
  I: Integer;
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('HCount').AsInteger  := FHCount;

  for I := 0 to MaxCount - 1 do
    CtrlPave[i].SaveEnv( aStorage, i);
end;

procedure TFrmPaveOrder.SetCount(const Value: integer);
begin
  FHCount := Value;
  edtCount.Text := IntToStr( FHCount );
end;

procedure TFrmPaveOrder.Timer1Timer(Sender: TObject);
var
  aItem : TPaveOrderItem;
  i : integer;
begin

  for I := 0 to MaxCount - 1 do
    if CtrlPave[i].cbStart.Checked then
    begin
      aItem := FPavers.Find( CtrlPave[i].Account, CtrlPave[i].Symbol, Self, CtrlPave[i].Tag );
      if aItem <> nil then
      begin
        CtrlPave[i].Display( aItem.LayOrder.LogData );
        aItem.OnTime( Self );
      end;
    end;

end;

procedure TFrmPaveOrder.WMPaveOrderEnd(var msg: TMessage);
var
  iTag : integer;
begin
  iTag  := msg.WParam - 1;

  if (iTag >= 0)  and ( MaxCount > iTag) then
    CtrlPave[iTag].cbStart.Checked := false;
end;

end.
