unit FLogInYOung;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  GleTypes, IdHTTP, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP,

  CleParsers, jpeg
  ;
type
  TFrmLoginYoung = class(TForm)
    Ftp: TIdFTP;
    Timer: TTimer;
    IdAntiFreeze1: TIdAntiFreeze;
    idh: TIdHTTP;
    Image1: TImage;
    Panel1: TPanel;
    edt0LeeID: TLabeledEdit;
    edt0LeePW: TLabeledEdit;
    Button1: TButton;
    Label1: TLabel;
    Panel2: TPanel;
    edtID: TLabeledEdit;
    edtPW: TLabeledEdit;
    edtCert: TLabeledEdit;
    btnCon: TButton;
    btnExit: TButton;
    Label2: TLabel;
    stResult: TLabel;
    cbMock: TCheckBox;
    cbSaveInput: TCheckBox;
    lbMock: TLabel;
    lbSaveInput: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure cbMockClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtIDKeyPress(Sender: TObject; var Key: Char);
    procedure btnConClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure initControls;
    procedure DoLogin;


    { Private declarations }
  public
    { Public declarations }
    AutoLogin : boolean;
    procedure DoAutoLogin;
    procedure InitLogin;
    procedure SaveLoginData;
  end;

var
  FrmLoginYoung: TFrmLoginYoung;

implementation

uses
  GAppEnv  , Math
  ;

{$R *.dfm}

procedure TFrmLoginYoung.btnConClick(Sender: TObject);

  function CheckEmpty( aEdt : TLabeledEdit ) : boolean;
  begin
    if aEdt.Text = '' then begin
      Result := false;
      aEdt.SetFocus;
    end else Result := true;
  end;
begin

  if not CheckEmpty( edtID ) then Exit;
  if not CheckEmpty( edtPW ) then Exit;

  DoLogin;
end;

procedure TFrmLoginYoung.DoAutoLogin;
var
  iMode : integer;
begin

  InitLogin;
  DoLogin;
end;

procedure TFrmLoginYoung.DoLogin;
var
  iRes, iMode : integer;
begin
  if cbMock.Checked then
    iMode := 2
  else begin
    iMode := 0;
    if edtCert.Text = '' then
    begin
      ShowMessage('�������� ��ȣ�� �Է��ϼ���');
      edtCert.SetFocus;
      Exit;
    end;
  end;
  gEnv.Engine.Api.DoLogIn( edtID.Text, edtPW.Text, edtCert.Text, iMode );
end;

procedure TFrmLoginYoung.SaveLoginData;
begin
  gEnv.ConConfig.Save0LeeID := edt0LeeID.Text;
  gEnv.ConConfig.Save0LeePW := edt0LeePW.Text;

  gEnv.ConConfig.SaveInput:= cbSaveInPut.Checked;
  gEnv.ConConfig.RealMode := not cbMock.Checked;
  if gEnv.ConConfig.RealMode then
  begin
    gEnv.ConConfig.SaveID[0]  := edtID.Text;
    gEnv.ConConfig.SavePW[0]  := edtPW.Text;
    gEnv.ConConfig.SaveCert[0]:= edtCert.Text;
  end
  else begin
    gEnv.ConConfig.SaveID[1]  := edtID.Text;
    gEnv.ConConfig.SavePW[1]  := edtPW.Text;
    gEnv.ConConfig.SaveCert[1]:= edtCert.Text;
  end;
end;

procedure TFrmLoginYoung.btnExitClick(Sender: TObject);
begin
  ModalResult := IDCANCEL;
end;

procedure TFrmLoginYoung.Button1Click(Sender: TObject);
var
  strs : TStringList;
  aParser : TParser;
  stID, s : string;
  iCnt, iCode : integer;
begin
  try
    btnCon.Enabled  := false;
    Button1.Enabled := false;
    strs := TStringList.Create;

    stResult.Caption  := '�����Ϸ� ��� �ҿ�ɼ� �ֽ��ϴ�.';

    strs.Values['code'] := 'SOL_000100';
    strs.Values['user_id'] := edt0LeeID.Text;
    strs.Values['user_pw'] := edt0LeePW.Text;
    s := idh.Post('http://service.ylrms.com/auth', strs);

    aParser := TParser.Create([',']);
    iCnt := aparser.Parse( s );

    if iCnt <= 0 then
    begin
      stResult.Caption  := ('��ſ� ���� �߻� �ٽ� �õ����ּ���' ) ;
      Exit;
    end;
    iCode := StrToInt(trim( aParser[0] ));

    case iCode of
      0 :
        begin
          stResult.Caption  := Format('���� ���� , %s ���� ��밡��', [ aParser[1] ]) ;
          stID  := trim( aParser[2] );

          gEnv.ConConfig.Save0LeeID  := edt0LeeID.Text;
          gEnv.ConConfig.Save0LeePW  := edt0LeePW.Text;

          if cbMock.Checked then
          begin
            if stID = gEnv.ConConfig.SaveID[1] then
            begin
              edtID.Text  := gEnv.ConConfig.SaveID[1];
              edtPW.Text    := gEnv.ConConfig.SavePW[1];
              edtCert.Text  := gEnv.ConConfig.SaveCert[1];
            end
            else edtID.text  := stID;
          end
          else begin
            if stID = gEnv.ConConfig.SaveID[0] then
            begin
              edtID.Text  := gEnv.ConConfig.SaveID[0];
              edtPW.Text  := gEnv.ConConfig.SavePW[0];
              edtCert.Text  := gEnv.ConConfig.SaveCert[0];
            end else edtID.text  := stID;
          end;

          btnCon.Enabled := true;
          btnExit.Enabled:= true;

        end;

      1 : stResult.Caption  := '�ַ�� �ڵ� ����';
      2 : stResult.Caption  := '���̵� ����';
      3 : stResult.Caption  := '��й�ȣ ����';
      4 : stResult.Caption  := Format('���Ⱓ ����, % ���� ��밡��', [ aParser[1] ]) ;
      5 : stResult.Caption  := '��Ÿ ����';
    end;

  finally
    Button1.Enabled := true;
    aParser.Free;
    strs.Free;
  end;


end;

procedure TFrmLoginYoung.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmLoginYoung.cbMockClick(Sender: TObject);
begin
  if cbSaveInput.Checked then
    if cbMock.Checked then
    begin
      edtID.Text  := gEnv.ConConfig.SaveID[1];
      edtPW.Text  := gEnv.ConConfig.SavePW[1];
      edtCert.Text  := gEnv.ConConfig.SaveCert[1];
    end
    else begin
      edtID.Text  := gEnv.ConConfig.SaveID[0];
      edtPW.Text  := gEnv.ConConfig.SavePW[0];
      edtCert.Text  := gEnv.ConConfig.SaveCert[0];
    end;
end;



procedure TFrmLoginYoung.edtIDKeyPress(Sender: TObject; var Key: Char);
var
  iLen : integer;
begin
{
  iLen  := Length( (Sender as TLabeledEdit ).Text );
  if (iLen > 7 ) and ( key <> #8 )  then
    Key := #0;
    }

end;

procedure TFrmLoginYoung.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmLoginYoung.FormCreate(Sender: TObject);
begin
    initControls;
end;

procedure TFrmLoginYoung.initControls;
begin

  InitLogin;
end;

procedure TFrmLoginYoung.InitLogin;
begin

  cbSaveInput.Checked := gEnv.ConConfig.SaveInput;
  cbMock.Checked      := not gEnv.ConConfig.RealMode;

  if gEnv.YoungLee then
  begin

    if cbSaveInput.Checked then
    begin
      edt0LeeID.Text  := gEnv.ConConfig.Save0LeeID;
      edt0LeePW.Text  := gEnv.ConConfig.Save0LeePW;
    end;

  end
  else begin

    if cbSaveInput.Checked then
      if cbMock.Checked then
      begin
        edtID.Text  := gEnv.ConConfig.SaveID[1];
        edtPW.Text  := gEnv.ConConfig.SavePW[1];
        edtCert.Text  := gEnv.ConConfig.SaveCert[1];
      end
      else begin
        edtID.Text  := gEnv.ConConfig.SaveID[0];
        edtPW.Text  := gEnv.ConConfig.SavePW[0];
        edtCert.Text  := gEnv.ConConfig.SaveCert[0];
      end;
  end;

  if AutoLogin then
  begin

    // �ڵ��α����� ����...���Ͽ��� �о�� ������ �ѷ��ش�.
    cbSaveInput.Checked := gEnv.ConConfig.tUseSave;
    cbMock.Checked      := gEnv.ConConfig.tUseMock;

    edt0LeeID.Text  := gEnv.ConConfig.t0LeeID;
    edt0LeePW.Text  := gEnv.ConConfig.t0LeePW;

    edtID.Text    := gEnv.ConConfig.tUserID;
    edtPW.Text    := gEnv.ConConfig.tPassword;
    edtCert.Text  := gEnv.ConConfig.tCertPass;
  end;
end;

procedure TFrmLoginYoung.FormDestroy(Sender: TObject);
begin
  gLogIn  := nil;
end;

procedure TFrmLoginYoung.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnConClick( btnCon );

end;

end.
