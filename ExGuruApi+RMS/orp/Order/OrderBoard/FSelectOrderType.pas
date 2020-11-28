unit FSelectOrderType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, UAlignedEdit;

type
  TFrmOrderType = class(TForm)
    GroupBox4: TGroupBox;
    rbMarket: TRadioButton;
    rbHoga: TRadioButton;
    edtLiqTick: TAlignedEdit;
    udLiqTick: TUpDown;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmOrderType: TFrmOrderType;

implementation

{$R *.dfm}

end.
