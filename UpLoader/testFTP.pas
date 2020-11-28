unit testFTP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  Unit2, StdCtrls
  ;

type
  TForm1 = class(TForm)
    edtIp: TEdit;
    edtUser: TEdit;
    edtPass: TEdit;
    edtLocalDir: TEdit;
    Button1: TButton;
    Button2: TButton;
    edtRemoteDir: TEdit;
    m: TMemo;
    edtDir: TEdit;
    dlgOpen: TOpenDialog;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ftp : TFTPConnector;
    procedure DoLog(Sender: TObject; Value: String);
    function LoadConfig : boolean;
  end;

var
  Form1: TForm1;

implementation

uses
  CleIni
  ;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin

  if edtDir.Text = '' then
  begin
    ShowMessage('HanaGuruApi 접속 아이디를 입력하세요');
    edtDir.SetFocus;
    Exit;
  end;

  ftp.ServerIP  := edtIp.Text;
  ftp.UserName  := edtUser.Text;
  ftp.Password  := edtPass.Text;
  //
  ftp.LocalPath := edtLocalDir.Text ;
  ftp.RemotePath  := edtRemoteDir.Text;

  Button2.Enabled := true;

  //ftp.ListLocalFiles;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  I: Integer;
begin
  //Button1Click( nil );

  ftp.Files.Clear;

  if dlgOpen.Execute( Handle ) then
    for I := 0 to dlgOpen.Files.Count - 1 do
    begin
      ftp.Files.AddLocalFile( dlgOpen.Files[i], ExtractFileName( dlgOpen.Files[i] ) );
      m.Lines.Add( dlgOpen.Files[i]);
    end;

  if ftp.Files.Count > 0 then
    if ftp.Upload( edtDir.Text ) < 0 then
      m.Lines.Add( ftp.LastErrorMsg )
    else
      m.Lines.Add( '업로드 성공' )
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ftp := TFTPConnector.Create;
  ftp.OnLog := DoLog;

  Button1Click( nil );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ftp.Free;
end;

function TForm1.LoadConfig: boolean;
var
  ini : TInitFile;
begin
  Result := false;

  try
    ini := nil;
    ini := TInitFile.Create('Env.ini');

    if ini = nil then
      Exit; 

    edtIP.Text     := ini.GetString('FTP','IP');

    edtUser.Text   := '';
    edtPass.Text   := '';


  finally
    ini.Free
  end;
  Result := true;
end;


procedure TForm1.DoLog(Sender: TObject; Value: String);
begin
  m.Lines.Add( value);
end;

end.
