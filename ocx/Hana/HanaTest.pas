unit HanaTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  CleParsers, UTypes, Uconsts

  ;

type


  TForm1 = class(TForm)
    m: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Timer1: TTimer;
    cbStockGame: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    FStep : integer;
    procedure ReceiveReqData(wData: WPARAM; lData: LPARAM);
    procedure parseMaster(iCnt: integer; stData: string);
  public
    { Public declarations }
    HanaDll : THandle;
    aLogin    : pLogin;
    aLogOut   : pLogOut;

    aCallBack : pRegisterCallBack;
    aInitXLap : pInitXLap;
    aHCommand : pHCommand;
    aConnect  : pConnect;
    aEncript  : pEncript;

    aRequestAccount : pRequestAccount;
    aRequestSymbolMaster  : pRequestSymbolMaster;
    procedure DoLogin;
  end;

  procedure OnCallBackHanaEvent( iType, iTag, iSize : integer; pData : PChar); cdecl;
  procedure OnCallBackHanaLog( iType : integer; pData:  PChar); cdecl;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  iRes : integer;
begin
  //
  aCallBack( OnCallBackHanaEvent,  OnCallBackHanaLog );
  iRes := aInitXLap;
  m.Lines.Add( 'init result is ' + InttoStr( iRes ) );
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  iLen, iRes : integer;

  pData : TSignM;
  pUser : TData;
  stTmp : string;
  cType : char;
begin

  iLen  :=  sizeof( TSignM);
  FillChar( pData, iLen , ' ');

  move( 'eungjun1', pData.user, sizeof( pData.user ));
  move( '11111', pData.pass, sizeof( pData.pass ));
  move( 'ylrms5759', pData.cpas, sizeof( pData.cpas));

  iRes := aLogin( @pData,  0 );
  if iRes < 0 then
    m.Lines.Add( '로긴 실패');

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  iRes : integer;
begin
  iRes := aLogOut;
  if iRes >= 0 then
    m.Lines.Add('정상적 로그아웃')
  else
    m.Lines.Add('Error  로그아웃');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  aRequestAccount;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  aRequestSymbolMaster;
end;

procedure TForm1.DoLogin;
var
  iLen, iRes : integer;

  pData : TSignM;
  pUser : TData;
  stTmp : string;
  cType : char;
begin

  FillChar( pData, sizeof( TSignM) , ' ');

  stTmp := 'eungjun1';
  move( stTmp[1], pData.user, sizeof( pData.user ));

  FillChar( pUser, 40, #0);
  move( stTmp[1], pUser.key, 20 );

  stTmp := 'june76';
  move( stTmp[1], pUser.pass, 20 );

  stTmp := aEncript( @pUser, 1 );
  m.Lines.Add( '암호화 : ' + stTmp);
  move( stTmp[1], pData.pass, sizeof( pData.pass ));

  stTmp := 'ylrms5759';
  move( stTmp[1], pData.cpas, sizeof( pData.cpas));

  if cbStockGame.Checked then
    cType := 'X'
  else
    cType := '2';

  iRes := aHCommand( 103, @pData,  Ord(cType) );
  if iRes <> 0 then
    m.Lines.Add( '로긴 실패');

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if HanaDll > 0 then
    FreeLibrary( HanaDll );
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  HanaDll := LoadLibrary('HanaXLap.dll');

  if HanaDll <= 0 then
  begin
    m.Lines.Add('dll load 실패');
    exit;
  end;

  @aLogin :=  GetProcAddress(HanaDll, PChar(DLL_LOGIN));
  if @aLogin = nil then Exit;

  @aLogOut  :=GetProcAddress(HanaDll, PChar(DLL_LOGOUT));
  if @aLogOut = nil then Exit;

  @aCallBack := GetProcAddress(HanaDll, PChar(DLL_REGI_CALLBACK));
  if @aCallBack = nil then Exit;

  @aInitXLap := GetProcAddress(HanaDll, PChar(DLL_INIT));
  if @aInitXLap = nil then Exit;

  @aRequestAccount := GetProcAddress(HanaDll, PChar(DLL_REQUEST_ACCOUNT));
  if @aRequestAccount = nil then Exit;

  @aRequestSymbolMaster := GetProcAddress(HanaDll, PChar(DLL_REQUEST_SYMBOLMASTER));
  if @aRequestSymbolMaster = nil then Exit;
            {
  @aConnect := GetProcAddress(HanaDll, PChar(DLL_Connect));
  if @aInitXLap = nil then Exit;

  @aHCommand := GetProcAddress(HanaDll, PChar(DLL_HCommnad));
  if @aHCommand = nil then Exit;

  @aEncript := GetProcAddress(HanaDll, PChar(DLL_Encript));
  if @aEncript = nil then Exit;
        }
  m.Lines.Add('성공');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  case FStep of
    0 :
      begin
        DoLogIn;
        Timer1.Enabled := false;
      end;
  end;
end;

procedure TForm1.ReceiveReqData( wData:  WPARAM;  lData : LPARAM );
begin

end;

procedure TForm1.parseMaster( iCnt : integer; stData : string );
var
  aParse : TParser;
  iSize  : integer;
  stTmp  : string;
  I: Integer;
begin

  try
    aParse  := TParser.Create( [Chr(9)] );
    iSize   := aParse.Parse( stData );

    stTmp := '';
    for I := 0 to iSize - 1 do
    begin
      stTmp := stTmp+','+aParse[i];
    end;

    //m.Lines.Add( Format('%d:%s',[ iCnt, stTmp])  );


  finally
    aParse.Free;
  end;

end;

procedure OnCallBackHanaEvent( iType, iTag, iSize : integer; pData : PChar);
begin

  with  Form1 do
  case  TApiEventType( iType )  of
		AcntList : m.Lines.Add( Format('%d, %s', [ iSize, pData]))  ;
		DemoAcntList : ;
		AcntPos :;
		ActiveOrd :;
		Deposit : ;
		SymbolMaster :
      begin
        m.Lines.Add( Format('%d:%d, %s', [ iTag, iSize, pData]))  ;
        parseMaster( iTag,  pData);

      end;
  end;
end;


procedure OnCallBackHanaLog( iType : integer; pData:  PChar);
begin
  Form1.m.Lines.Add( Format('log(%d), %s ', [ iType, pData ]));
end;

end.
