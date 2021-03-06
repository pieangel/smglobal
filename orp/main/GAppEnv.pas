unit GAppEnv;

interface

{$INCLUDE define.txt}

uses
    // delphi libraries
  Classes, SysUtils,    Windows, Messages, Math, Forms,
    // lemon: common
  GleTypes,
  LemonEngine,
  CleSymbols, CleMySQLConnector,

  CleLog,
  FFPopupMsg, FServerMessage,

  TimeSpeeds,

{$IFDEF YOUNG_LEE}
  FLoginYoung,
{$ELSE}
  FLogin,
{$ENDIF}
  DleSymbolselect,
  CBoardEnv  ,
  EnvUtil
  ;



type
  TInputData = record
    // new add woori fut
    UID : string;
    AcntNo : string;
    AcntPw : string;
    MemNo  : string;    // 회원번호
    BraNo  : string;    // 지점번호
    SID    : string     // 서버 ID
  end;



  TConConfig = record

    UserName  : string;
    UserID    : string;
    Password  : string;
    CertPass  : string;
    SaveInput : boolean;
    // 마지막 접속..
    RealMode  : boolean;

    // 모의...
    SaveID    : array [0..1] of string;
    SavePW    : array [0..1] of string;
    SaveCert  : array [0..1] of string;
    // 영리 아뒤/ 패스
    Save0LeeID    : string;
    Save0LeePW    : string;
    Save0LeeCode  : string;
    // 임시....
    tUserID    : string;
    tPassword  : string;
    tCertPass  : string;
    t0LeeID    : string;
    t0LeePW    : string;
    tUseMock   : boolean;
    tUseSave   : boolean;

    ApType    : string;
    // ftp
    FtpIP     : string;
    FtpID     : string;
    FtpPass   : string;
    FtpRemoteD: string;
    FtpLocalD : string;
    // DB
    DbIP      : string;
    DbID      : string;
    DbPass    : string;
    DbSource  : string;
    Mdb       : string;
    UseMdb    : boolean;

    StartOrderNo : int64;
    EndOrderNo   : int64;
    LastOrderNo  : int64;

    LastDate     : TDateTime;
    IncCount     : integer;
    //
    SisAddr      : string;
    TradeAddr    : string;
    TradeAddr2   : string;
    MacAddr      : string;

    UdpDuraPort : integer;
    UdpDuraIP : string;
  end;

  TFillSound = record
    FillSnd : string;
    IsSound : boolean;
    DelayMs : double;
  end;

  TRunModeType = ( rtRealTrading, rtSimulUdp , rtSimulation );
  TUserType   =  ( utBeta, utNormal, utStaff, utAdmin  );

  // 차세대 이전, 차세대
  TPacketVersion  = ( pv0, pv1, pv2, pv3, pv4 );

  TDistributeType = record
    Used  : boolean;
    MS    : integer;
  end;


  TOrderSpeed = record
    AvgAcptTime : DWORD;
    AvgChgTime  : DWORD;
    AvgCnlTime  : DWORD;
    OrderCount  : integer;
    OrderCnlCnt : integer;
    OrderChgCnt : integer;
  end;

  TBoardCon = record
    SaveDate  : string;
    TodayNoShowDlg : boolean;
  end;

  TUdpPort  = record
    Port    : integer;
    Use     : boolean;
    UseMulti: boolean;
    MultiIP : string;
    Name    : string;
    MarketType : string;
  end;

  TCost = record
    FDues : string;
    FCost : string;
    ODues : string;
    OCost : string;
  end;

  TFees = record
    FFee  : double;
    OFee  : double;
  end;

  TAppEnv = record
    Main  : TForm;
    MainBoard : TForm;
    YoungLee : boolean;
    Beta     : boolean;
    Simul : boolean;
    Engine: TLemonEngine;
    Log   : TLogThread;

    PacketVer : TPacketVersion;
    AppPid: DWord;

    Cost    : TCost;
    Fees    : TFees;

    UserType  : TUserType;
    RunMode : TRunModeType;
    UseVFEP : boolean;
    AppDate : TDateTime;
    PrevAppDate : TDateTime;
    DBMode  : boolean;

    OrderSpeed  : TOrderSpeed;
    BoardCon : TBoardCon;

    Trade : TObject;
    Info  : TFrmServerMessage;

    LogInOut : char;

    LogDir : string;
    RootDir: String;   // application root directory
    DataDir: String;   // application data directory
    OutputDir: String; // application output directory
    QuoteDir: string;
    TemplateDir : string;
    SimulDir  : string;
    EnvDir    : string;
    ErrString : string;



    Input : TInputData;
    ConConfig : TConConfig;

    SaveID : array [0..2] of string;
    SavePW : array [0..2] of string;
    SaveCert : array [0..2] of string;

    // 0 : fut sis delay
    // 1 : call sis dealy , 2 : put sis dealy
    // 3 : 잔량스탑 , 4 : 프런트쿼팅
    FillSnd   : array [TOrderSpecies] of TFillSound;

    //MySQLConnector: TMySQLConnector;

    OnLog: TTextNotifyEvent; // event for log
    OnState : TAsNotifyEvent;

    RecoveryEnd : boolean;
    StopGroupID : integer;

    procedure SetAppStatus(const Value: TAppStatus);
    procedure SimulationReady;
    procedure DoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure EnvLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure OrderNoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
    procedure FreeLog;
    procedure ShowMsg( stType , stMsg : string; bLog : boolean = true );
    procedure AppMsg( stType , stMsg : string );

    procedure SetRunMode( iMode : integer );
    procedure SetDBMode(iMode: integer);
    procedure CreateAppLog;
    procedure CreateTimeSpeeds;
    procedure CreateSymbolSelect;
    procedure CreateLogin(aObj : TObject);
    procedure CreateBoardEnv;
    procedure SetFees;

    function  GetStopGroupID : integer;

    function LoadLoginInfo : boolean;
    procedure SaveLoginInfo;
  private

  end;

procedure DoEnvLog(Sender: TObject; stLog: String);
procedure AddLog( lkValue : TLogKind;
                  stSource, stTitle, stDesc : String; iLogLevel : Integer = 0);


var
  gEnv  : TAppEnv;
  gUseB : Boolean = False;
  gLog  : TAppLog;
  gClock  : TTimeSpeed;
  gSymbol : TSymbolDialog;
  gBoardEnv : TBoardEnv;

{$IFDEF YOUNG_LEE}
  gLogin    : TFrmLoginYoung;
{$ELSE}
  gLogin    : TFrmLogin;
{$ENDIF}

const
  KRX_FQN ='krx.kr';

  // log
  {
  WIN_LOG ='./log/win';

  WIN_ORD ='./log/ord';
  WIN_TEST='./log/test';
  WIN_GI  ='./log/Gi';

  WIN_VIR ='./log/vir';
  WIN_TS  ='./log/TS';
  WIN_PACKET = './log/Packet';
  WIN_LINK  = './log/Link';

  WIN_SIS   = './log/sis';

  //
  WIN_DEBUG = './log/Debug';
  WIN_ERR   = './log/Err';
  WIN_APP   = './log/App';
  WIN_KEYORD= './log/KeyOrd';
  WIN_WARN  = './log/Warn';
  WIN_RJT   = './log/Rjt';
  WIN_LOSS  = './log/Loss';
  WIN_REC   = './log/Rec';

  //
  WIN_TRDSTOP = './log/TrdStop';
  WIN_JJUNG2 = './log/JJUNG2';
  WIN_JPOS  = './log/JPOS';
  WIN_SIMUBAO = './log/SimulBAO';
  WIN_ENTRY = './log/Entry';
  WIN_UPDOWN = './log/UpDown';
  WIN_CATCH = './log/Ctch';
  WIN_ARB = './log/Arb';
  WIN_STR = './log/Strangle';
  WIN_YH = './log/YH';
  WIN_CP = './log/Parity';
  WIN_RATIO = './log/Ratio';
  WIN_STR2 = './log/Strangle2';
  WIN_INV = './log/Investor';
  WIN_REPORT = './log/Report';
  WIN_HL = './log/HL';
  WIN_HULT = './log/HULT';
  WIN_RATIOS = './log/RatioS';
  WIN_TREND = './log/trend';
  WIN_OPTHULT = './log/HULT';
  WIN_BHULT = './log/BanHULT';
  WIN_HULFT = './log/EvolHult';
  WIN_WOOK = './log/Wook';
  WIN_SHORTHULT = './log/ShortHult';
  WIN_DEFORD = './log/Def';
  WIN_FUNDORD = './log/Fund';
  }
  WIN_LOG ='win';

  WIN_ORD ='ord';
  WIN_TEST='test';
  WIN_GI  ='Gi';

  WIN_VIR ='vir';
  WIN_TS  ='TS';
  WIN_PACKET = 'Packet';
  WIN_LINK  = 'Link';

  WIN_SIS   = 'sis';

  //
  WIN_DEBUG = 'Debug';
  WIN_ERR   = 'Err';
  WIN_APP   = 'App';
  WIN_KEYORD= 'KeyOrd';
  WIN_WARN  = 'Warn';
  WIN_RJT   = 'Rjt';
  WIN_LOSS  = 'Loss';
  WIN_REC   = 'Rec';

  //
  WIN_TRDSTOP = 'TrdStop';
  WIN_JJUNG2 = 'JJUNG2';
  WIN_JPOS  = 'JPOS';
  WIN_SIMUBAO = 'SimulBAO';
  WIN_ENTRY = 'Entry';
  WIN_RISK = 'Risk';
  WIN_CATCH = 'Ctch';
  WIN_ARB = 'Arb';
  WIN_STR = 'Strangle';
  WIN_YH = 'YH';
  WIN_CP = 'Parity';
  WIN_RATIO = 'Ratio';
  WIN_STR2 = 'Strangle2';
  WIN_INV = 'Investor';
  WIN_REPORT = 'Report';
  WIN_HL = 'HL';
  WIN_HULT = 'HULT';
  WIN_RATIOS = 'RatioS';
  WIN_TREND = 'trend';

  WIN_BHULT = 'BanHULT';
  WIN_HULFT = 'EvolHult';
  WIN_WOOK = 'Wook';
  WIN_SHORTHULT = 'ShortHult';
  WIN_DEFORD = 'OrderBoard';
  WIN_FUNDORD = 'FundOrderBoard';
 {
      lkError:      stFolder  := WIN_LOG;
    lkDebug:      stFolder  := ;
    lkKeyOrder: ;
    lkApplication: ;
    lkWarning: ;
 }

//procedure LoadEnv(stFile: String);
//procedure SaveEnv(stFile: String);

implementation



{ TAppEnv }

procedure TAppEnv.AppMsg(stType, stMsg: string);
begin
  PopupMessage( stMsg );
  EnvLog( WIN_ERR, stMsg );
end;



procedure TAppEnv.CreateAppLog;
begin
  gLog  := TAppLog.Create;
end;

procedure TAppEnv.CreateBoardEnv;
begin
  gBoardEnv := TBoardEnv.Create;
  StopGroupID := 100;
end;

procedure TAppEnv.CreateLogin( aObj : TObject );
begin                     
{$IFDEF YOUNG_LEE}
  gLogIn := TFrmLoginYoung.Create(aObj as TComponent);
{$ELSE}
  gLogIn := TFrmLogin.Create(aObj as TComponent);
{$ENDIF}
end;

procedure TAppEnv.CreateSymbolSelect;
begin
  gSymbol := TSymbolDialog.Create(nil);
end;

procedure TAppEnv.CreateTimeSpeeds;
begin
  gClock  := TTimeSpeed.Create;
end;

procedure TAppEnv.DoLog(stDir, stData: String; bMaster : boolean = false; stFile : string = '');
begin

end;

procedure TAppEnv.FreeLog;
begin
  Log.Terminate;
  Log.LogQueue.Free;
end;

function TAppEnv.GetStopGroupID: integer;
begin
  StopGroupID := StopGroupID + 1;
  Result := StopGroupID;
end;

function TAppEnv.LoadLoginInfo : boolean;

var fs: TFileStream; r:TReader;
    stFileName, st0ID, st0PW, stUID, stPswd, stCert: string;
    szBuf: array[0..255] of char;
begin
  Result := false;
  stFileName := ExtractFilePath( ParamStr(0)) + 'LoginInfo.dat';

  if not FileExists( stFileName ) then
  begin
    EnvLog( WIN_ERR, 'no file : ' + stFileName );
    Exit;
  end;
  
  try
    fs := TFileStream.Create( stFileName, fmOpenRead );
    r := TReader.Create( fs, 1024 );

    r.Read( szBuf[0], 80 );
    utDecodeFlat( szBuf[0], 80 );
    st0ID   := Trim(Copy(szBuf,0, 16 ));
    st0PW   := Trim(Copy(szBuf,16, 16));
    stUID   := Trim(Copy(szBuf,32, 16));
    stPswd  := Trim(Copy(szBuf,48, 16));
    stCert  := Trim(Copy(szBuf,64, 16));

    ConConfig.t0LeeID    := st0ID;
    ConConfig.t0LeePW    := st0PW;
    ConConfig.tUserID    := stUID;
    ConConfig.tPassword  := stPswd;
    ConConfig.tCertPass  := stCert;
    ConConfig.tUseMock   := r.ReadBoolean;
    ConConfig.tUseSave   := r.ReadBoolean;

    Result := true;

  finally
    if Assigned(r) then
      r.Free;
    if Assigned(fs) then
      fs.Free;

    if FileExists( stFileName ) then
      DeleteFile( PChar(stFileName) );
         
  end;
end;

procedure TAppEnv.SaveLoginInfo;
var stFileName : string; fs: TFileStream; w: TWriter;
     stTmp: string; szBuf:array[0..255] of char;
begin
  stFileName := 'LoginInfo.dat';      // 저장될 파일명

  stTmp := Format( '%-16s%-16s%-16s%-16s%-16s',  [
    ConConfig.Save0LeeID,
    ConConfig.Save0LeePW,
    ConConfig.UserID,
    ConConfig.Password,
    ConConfig.CertPass  ]);
  try
    if FileExists( stFileName ) then
      DeleteFile( PChar(stFileName) );

    fs := TFileStream.Create( stFileName, fmCreate );
    w := TWriter.Create( fs, 1024 );

  // 사용자아이디 패스워드를 암호화하고 파일에 저장한다
    move( stTmp[1], szBuf[0], 80 );
    utEncodeFlat( szBuf[0], 80 );
    w.Write( szBuf[0], 80 );
    w.WriteBoolean( not ConConfig.RealMode );
    w.WriteBoolean( ConConfig.SaveInput );

  finally
    if Assigned(w) then
      w.Free;
    if Assigned(fs) then
      fs.Free;
  end;

end;


procedure TAppEnv.OrderNoLog(stDir, stData: String; bMaster: boolean;
  stFile: string);
begin
  Log.LogPushQueue2(stDir, stData, bMaster, stFile);
end;

procedure TAppEnv.EnvLog(stDir, stData: String; bMaster: boolean;
  stFile: string);
begin
  Log.LogPushQueue(stDir, stData, bMaster, stFile);
end;

procedure TAppEnv.SetAppStatus(const Value: TAppStatus);
begin
  if Assigned( OnState ) then
    if Engine.AppStatus <> Value then
    begin
      if Engine.AppStatus = asLoad then
        Exit;

      Engine.AppStatus :=  Value;
{$IFDEF HANA_STOCK}
      if ( Main <> nil )  then
        PostMessage( Main.Handle, WM_MAIN_MESSAGE, integer( Value ), 0 );
{$ELSE}
      OnState( Value );
{$ENDIF}

    end;
end;


procedure TAppEnv.SetRunMode(iMode: integer);
begin
  case iMode of
    0 : RunMode := rtRealTrading;
    1 : RunMode := rtSimulUdp;
    2 : RunMode := rtSimulation;
  end;

  if iMode in [1..2] then
    Simul := true
  else
    Simul := false;

end;

procedure TAppEnv.SetDBMode(iMode: integer);
begin
  case iMode of
    0 : DBMode  := true;
    1 : DBMode  := false;
  end;
end;

procedure TAppEnv.SetFees;
begin
  // env 파일에는 퍼센트값 읽어옴.. 뒤에 천을 곱하는 이유는..거래대금을 /1000 으로 계산하기 때문에
  Fees.FFee :=  (StrToFloatDef( Cost.FDues,0.0 ) + StrToFloatDef( Cost.FCost,0.0 ))
        / 100.0 * 1000.0;
  Fees.OFee :=  (StrToFloatDef( Cost.ODues,0.0 ) + StrToFloatDef( Cost.OCost,0.0 ))
        / 100.0 * 1000.0;

  try
//    gEnv.EnvLog( WIN_APP, Format('수수료 -->  Fut : %.4f , Opt : %.4f', [ Fees.FFee, Fees.OFee ] ));
  except
  end;
end;

procedure TAppEnv.ShowMsg(stType, stMsg: string; bLog : boolean);
begin
  PopupMessage( stMsg );
  if bLog then
    DoLog( stType, stMsg );
end;

procedure TAppEnv.SimulationReady;
begin
  OnState( asSimul );
end;


procedure DoEnvLog(Sender: TObject; stLog: String);
begin
  if Assigned(gEnv.OnLog) then
    gEnv.OnLog(Sender, stLog);
end;


procedure AddLog( lkValue : TLogKind;
                  stSource, stTitle, stDesc : String; iLogLevel : Integer = 0);
begin

end;


end.


