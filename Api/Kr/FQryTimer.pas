unit FQryTimer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFrmQryTimer = class(TForm)
    pBar: TProgressBar;
    Label1: TLabel;
    lbtot: TLabel;
    Timer1: TTimer;
    lbNow: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Open: Boolean;
  end;

var
  FrmQryTimer: TFrmQryTimer;

implementation

uses
  GAppEnv, math
  ;

{$R *.dfm}

procedure TFrmQryTimer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmQryTimer.FormCreate(Sender: TObject);
begin
  //
end;

procedure TFrmQryTimer.FormDestroy(Sender: TObject);
begin
  //
end;

function TFrmQryTimer.Open: Boolean;
begin
  pBar.Position := 0;
  pBar.Max      := gEnv.Engine.Api.AcntQryList.Count;
  lbTot.Caption := inttostr( pBar.Max );
  Timer1.Enabled := true;
  Result := (ShowModal = mrOK);
end;

procedure TFrmQryTimer.Timer1Timer(Sender: TObject);
begin
  //
  if pBar.Max = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrCancel   ;
  end;

  pBar.Position := Max( 0, pBar.Max - gEnv.Engine.Api.AcntQryList.Count );
  lbNow.Caption := IntToStr( pBar.Position );
  if gEnv.Engine.Api.AcntQryList.Count = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrOK   ;
  end;
end;

end.
