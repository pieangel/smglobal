unit FmHultHedge;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TfmHhedge = class(TFrame)
    cbStart: TCheckBox;
    edtQty: TEdit;
    edtE: TLabeledEdit;
    dtStartTime2: TDateTimePicker;
    edtL1: TLabeledEdit;
    edtL2: TLabeledEdit;
    edtLC: TLabeledEdit;
    dtEndTime: TDateTimePicker;
    Button1: TButton;
    Label1: TLabel;
    dtStartTime1: TDateTimePicker;
    lbNo: TLabel;
    edtPlus: TLabeledEdit;
    cbOpt: TCheckBox;
    Panel1: TPanel;
    edtAbove: TEdit;
    Label2: TLabel;
    edtBelow: TEdit;
    edtOptCnt: TEdit;
    udOptCnt: TUpDown;
    cbDir: TComboBox;
    cbFut: TCheckBox;
    edtOptQty: TEdit;
    procedure cbOptClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfmHhedge.cbOptClick(Sender: TObject);
begin
  panel1.Enabled  := cbOpt.Checked;
end;

end.
