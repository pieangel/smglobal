unit FmLiqSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UAlignedEdit, ComCtrls,

  GleTypes;

type
  TFrmLiqSet = class(TFrame)
    GroupBox3: TGroupBox;
    Label1: TLabel;
    cbPrfLiquid: TCheckBox;
    cbLosLiquid: TCheckBox;
    udPrfTick: TUpDown;
    udLosTick: TUpDown;
    edtPrfTick: TAlignedEdit;
    edtLosTick: TAlignedEdit;
    Button5: TButton;
    cbLiqType: TComboBox;
    edtLiqTick: TAlignedEdit;
    udLiqTick: TUpDown;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    cbTrailingStop: TCheckBox;
    edtBaseLCTick: TAlignedEdit;
    edtPLTick: TAlignedEdit;
    edtLCTick: TAlignedEdit;
    udLCTick: TUpDown;
    udPLTick: TUpDown;
    udBaseLCTick: TUpDown;
    cbLiqType2: TComboBox;
    edtLiqTick2: TAlignedEdit;
    udLiqTick2: TUpDown;
    lbCalcTick: TLabel;
    lbMaxTick: TLabel;
    btnApply: TButton;
    procedure cbLiqTypeChange(Sender: TObject);
    procedure edtBaseLCTickKeyPress(Sender: TObject; var Key: Char);
    procedure edtBaseLCTickChange(Sender: TObject);
  private
    { Private declarations }
    FIsFund : boolean;
    FOnEditChange: TNotifyEvent;
    FOnConfChange: TNotifyEvent;
    procedure SetControls;
  public
    { Public declarations }
    procedure init( bFund : boolean = false );
    procedure WMLiqSetMessage( var msg : TMessage) ; message  WM_LIQSET_MESSAGE;

    property OnEditChange : TNotifyEvent read  FOnEditChange write FOnEditChange;
    property OnConfChange : TNotifyEvent read  FOnConfChange write FOnConfChange;

  end;

implementation

uses
  GleConsts
  ;

{$R *.dfm}

{ TFrmLiqSet }

procedure TFrmLiqSet.cbLiqTypeChange(Sender: TObject);
var
  iTag  : integer;
  bVisible : boolean;
begin
  iTag := ( Sender as TComponent ).Tag;
  bVisible := true;
  if ( Sender as TComboBox).ItemIndex = 0 then
    bVisible := false;

  case iTag of
    0 : begin edtLiqTick.Visible  := bVisible;  udLiqTick.Visible := bVisible;  end;
    1 : begin edtLiqTick2.Visible := bVisible; udLiqTick2.Visible := bVisible;  end;
  end;

  if Assigned( FOnConfChange ) then
    FOnConfChange( Self );

end;



procedure TFrmLiqSet.edtBaseLCTickChange(Sender: TObject);
begin
  if Assigned( FOnEditChange ) then
    FOnEditChange( Sender );
end;

procedure TFrmLiqSet.edtBaseLCTickKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFrmLiqSet.init(bFund: boolean);
begin
  FIsFund := bFund;
  SetControls;
end;

procedure TFrmLiqSet.SetControls;
begin
  if FIsFund then
    Color  := FUND_FORM_COLOR
  else
    Color  := clBtnFace;
end;

procedure TFrmLiqSet.WMLiqSetMessage(var msg: TMessage);
begin
  //  w : tag
  //  L : val
  if Assigned( FOnEditChange ) then
    case msg.WParam of
      4 : FOnConfChange( edtBaseLCTick );
      5 : FOnConfChange( edtPLTick );
      6 : FOnConfChange( edtLCTick );
    end;

end;

end.
