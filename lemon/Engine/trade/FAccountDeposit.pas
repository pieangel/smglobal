unit FAccountDeposit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GleTypes,

  CleAccounts, ClePositions, CleDistributor, Grids, StdCtrls, ExtCtrls
  ;

type
  TFrmAccountDeposit = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    sgPL: TStringGrid;
    Panel3: TPanel;
    sgMargin: TStringGrid;
    cbDepositType: TComboBox;
    procedure sgPLDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbDepositTypeChange(Sender: TObject);
  private
    { Private declarations }
    FH, FTop, FLeft : integer;
    FInvest : TInvestor;
    FDType  : TDepositType;
    procedure UpdateData;
    procedure OrderEventHandler(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);
    procedure InPutData(sgGrid: TStringGrid; dVal : double;ACol, ARow: integer;
               bBlack : boolean = false);
  public
    { Public declarations }
  end;

var
  FrmAccountDeposit: TFrmAccountDeposit;

implementation

uses
  GAppEnv, GleLib , GleConsts, GAppForms
  ;

{$R *.dfm}

procedure TFrmAccountDeposit.Button1Click(Sender: TObject);
begin
  if Panel3.Visible then
  begin
    //FTop:= Top;
    //FLeft:= Left;
    Height := Height - Panel3.Height;
    Panel3.Visible :=  false;
    button1.Caption := '+증거금';
  end
  else begin
    Height := FH;
    //Top := FTop;
    //Left:= FLeft;
    Panel3.Visible :=  true;
    button1.Caption := '-증거금';
  end;
end;

procedure TFrmAccountDeposit.Button2Click(Sender: TObject);
var
  stLog : string;
begin
  if FInvest <> nil then
    if FInvest.PassWord = '' then
    begin
      stLog  := '계좌 비밀번호 미 입력';
      stLog  := stLog + #13+#10+#13+#10;
      stLog  := stLog + '비밀번호 입력화면으로 이동하시겠습니까?';
      if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      begin
        gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0);
        Exit;
      end else
        Exit
    end else
      gEnv.Engine.SendBroker.RequestAccountDeposit( FInvest );
end;

procedure TFrmAccountDeposit.cbAccountChange(Sender: TObject);
var
  aInvest : TInvestor;
begin

  aInvest := TInvestor( cbAccount.Items.Objects[ cbAccount.ItemIndex]);
  if FInvest <> aInvest then
  begin
    FInvest := aInvest;
    UpdateData;
  end;

end;

procedure TFrmAccountDeposit.cbDepositTypeChange(Sender: TObject);
var
  dtValue : TDepositType;
begin
  case cbDepositType.ItemIndex of
    0 : dtValue := dtUSD;
    1 : dtValue := dtWON;
  end;

  if dtValue <> FDType then
  begin
    FDType  := dtValue;
    UpdateData;
  end;
end;

procedure TFrmAccountDeposit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmAccountDeposit.FormCreate(Sender: TObject);
begin

  with sgPL do
  begin
    Cells[0,0]  := '예탁자산평가';
    Cells[0,1]  := '평가손익';
    Cells[0,2]  := '실현손익';
    Cells[2,0]  := '원화대용금액';
    Cells[2,1]  := '수수료';
    Cells[2,2]  := '순손익';

    ColWidths[0]  := ColWidths[0] + 10;
    ColWidths[1]  := ColWidths[1] - 10;
    ColWidths[2]  := ColWidths[0];
    ColWidths[3]  := ColWidths[1];
  end;

  with sgMargin do
  begin
    Cells[0,0]  := '위탁증거금';
    Cells[0,1]  := '유지증거금';

    Cells[2,0]  := '주문증거금';
    Cells[2,1]  := '추가증거금';

    ColWidths[0]  := ColWidths[0] + 10;
    ColWidths[1]  := ColWidths[1] - 10;
    ColWidths[2]  := ColWidths[0];
    ColWidths[3]  := ColWidths[1];
  end;

  gEnv.Engine.TradeCore.Investors.GetList2( cbAccount.Items );

  FDType  := dtUSD;
  cbDepositTypeChange( nil );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( nil );
    ComboBox_AutoWidth( cbAccount );
  end;

  gEnv.Engine.TradeBroker.Subscribe( Self, OrderEventHandler );

  FH  := Height;
  FTop:= Top;
  FLeft:= Left;
  
  Height := Height - Panel3.Height;
end;

procedure TFrmAccountDeposit.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmAccountDeposit.OrderEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  var
    aInvest : TInvestor;
begin
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  case Integer(EventID) of
    ACCOUNT_DEPOSIT :
      begin
        aInvest := DataObj as Tinvestor;
        if aInvest = FInvest then UpdateData;        
      end
    else
      Exit;
  end;
end;

procedure TFrmAccountDeposit.InPutData( sgGrid : TStringGrid; dVal : double;
  ACol, ARow : integer; bBlack : boolean );
begin
  with sgGrid do
  begin
    Cells[ ACol, ARow ] := FormatFloat('#,##0.###', dVal );
    if not bBlack then
      Objects[ACol,ARow ] := Pointer( ifThenColor( dVal > 0 , clRed,
                                    ifThenColor( dVal < 0,  clBlue, clBlack )));
  end;
end;

procedure TFrmAccountDeposit.UpdateData;
begin

  if FInvest = nil then Exit;

  InPutData( sgPL, FInvest.DepositOTE[FDType], 1, 0, true );
  InPutData( sgPL, FInvest.OpenPL[FDType] , 1, 1 );
  InPutData( sgPL, FInvest.LiquidPL[FDType] , 1, 2 );

  InPutData( sgPL, FInvest.WonDaeAmt[FDType] , 3, 0 , true);
  InPutData( sgPL, FInvest.RecoverFees[FDType], 3, 1, true );
  InPutData( sgPL, FInvest.OpenPL[FDType] + FInvest.LiquidPL[FDType] - abs(FInvest.RecoverFees[FDType]) , 3, 2 );

  InPutData( sgMargin, FInvest.TrustMargin[FDType], 1, 0, true );
  InPutData( sgMargin, FInvest.HoldMargin[FDType] , 1, 1, true );

  InPutData( sgMargin, FInvest.OrderMargin[FDType] , 3, 0, true );
  InPutData( sgMargin, FInvest.AddMargin[FDType], 3, 1, true );

end;

procedure TFrmAccountDeposit.sgPLDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPos : TPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    case ACol of
      0, 2 :
        begin
          aBack := clBtnFace
        end
      else begin
        if Objects[ACol, ARow] <> nil then
          aFont :=  TColor( Objects[ACol, ARow]);
        dFormat := DT_RIGHT or DT_VCENTER;
        aRect.Right := aRect.Right -2;
      end;
    end;


    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ACol = 0) or ( ACol = 2) then begin
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

end.
