unit FOrpMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, Menus, Math, Shellapi, DateUtils,

    // lemon: common
  GleTypes, GleLib, LemonEngine,
    // lemon: symbol
  DleSymbolSelect, CleQuoteTimers,
    // lemon: trade
  FleOrderList2,
    // lemon: util
  CleStorage,
    // lemon: KRX
  CleFTPConnector,   CleApiReceiver, CleAccountLoader,
  CleKrxSymbols,
    // app
  GAppEnv, GAppConsts, GAppForms, StreamIO, DataMenu,
    // app: forms
  ActiveX,
  ExtCtrls, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, IdBaseComponent, IdAntiFreezeBase,
  IdAntiFreeze, OleCtrls, AlphaCommProj_TLB, IdHTTP, GR32_Image
  ;

{$INCLUDE define.txt}

const
  RegRootKey = HKEY_LOCAL_MACHINE;
  RegOpenKeyIni = '\SOFTWARE\DONGBU\GURU\';



type
  TOrpMainForm = class(TForm)
    StatusBar: TStatusBar;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N26: TMenuItem;
    Exit2: TMenuItem;
    Timer1: TTimer;
    plInfo: TPanel;
    pb: TPaintBox;
    Bitmap32: TBitmap32List;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Show1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);
  private
    FEngine: TLemonEngine;
    FQuoteTimer: TQuoteTimer;
    FAcntLoader: TAccountLoader;
    FCertSucces: boolean;

    procedure QuoteTimerProc(Sender: TObject);
    procedure QuoteTime(Sender: TObject; Value: TDateTime);

    procedure OrderReset( Sender : TObject; bBack : boolean; Value : Integer );
    //procedure QuoteDateChanged(Sender: TObject; Value: TDateTime);

    procedure DoLog(Sender: TObject; stLog: String);
    procedure DoTimeLog(Sender: TObject; stLog: String);
    procedure AppException(Sender: TObject; E: Exception);
    //*^^*
    procedure OnAppState( asType : TAppStatus );
    function LoadConfig : boolean;

    procedure LoadRegedit;
    procedure SaveRegedit;

    procedure SaveProfitNLoss;
    procedure BackUpWindows;

    function CheckRemainActiveOrder: boolean;
    procedure LogInEnd;


    { Private declarations }
  public
    { Public declarations }
    m_stIni : string;
    ExpertCtrl : TAlphaCommX;

    function FindGiComponet( stName : string ) : boolean;
      // 모드별 분기
    procedure BranchMode;
    procedure StepInitSymbolLoad;
    procedure SetpRecoveryEnd;
    procedure initQ;
    procedure StepSimulation;
    procedure FillAccountPass;
    procedure OnWindowMenuClick(Sender: TObject);

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);

    property AcntLoader: TAccountLoader read FAcntLoader;
    // only young_lee
    property CertSucces: boolean read FCertSucces;

  end;

var
  OrpMainForm: TOrpMainForm;

implementation

uses CalcGreeks, CleIni, CleLog,  Registry, CleFQN,CleFormBroker, CleParsers,
  GleConsts, CleExcelLog, CleOrders,
  TLHelp32,  FAppInfo,  
  DBoardEnv,  FAccountPassWord, FServerMessage    ;

{$R *.dfm}

//-----------------------------------------------------------------< init >

procedure TOrpMainForm.FillAccountPass;
var
  aForm : TFrmAccountPassWord;
begin

  if gEnv.UserType = utStaff then
  begin
    FEngine.SendBroker.RequestAccountData;
    Exit;
  end else
  if gEnv.UserType = utNormal then
  begin
    aForm := TFrmAccountPassWord.Create( Self );
    try
      if aForm.Open then
      begin
        FEngine.SendBroker.RequestAccountRecoveryData;
      end else gEnv.SetAppStatus( asRecoveryEnd );
    finally
      aForm.Free;
    end;
  end; 
end;

function TOrpMainForm.FindGiComponet(stName: string): boolean;
var
  peList : TProcessEntry32;
  hL : THandle;
begin
  Result := False;
  peList.dwSize := SizeOf(TProcessEntry32);
  hL            := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(hL, peList) then begin
    repeat
      if CompareText(peList.szExeFile, stName) = 0 then begin
        Result := True;
        break;
      end;
    until not Process32Next(hL, peList);
  end;

  CloseHandle(hL);
end;

function TOrpMainForm.CheckRemainActiveOrder : boolean;
var
  i, iVol, iCnt : integer;
  aOrder : TOrder;
  stLog : string;
  bExist: boolean;
begin
  Result := true;
  iCnt := gEnv.Engine.TradeCore.Orders.ActiveOrders.Count;

  if iCnt > 0 then
    stLog := Format('미체결 주문 : %d 개 존재 ', [ iCnt ]);

  iVol := 0;
  stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
  bExist := false;
  for i:=0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    //iVol := iVol +  gEnv.Engine.TradeCore.Positions.Positions[i].Volume;
    if gEnv.Engine.TradeCore.Positions.Positions[i].Volume <> 0 then
    begin
      stLog := stLog + Format('%s : %s 잔고 %d 존재', [ gEnv.Engine.TradeCore.Positions.Positions[i].Symbol.ShortCode,
        ifThenStr( gEnv.Engine.TradeCore.Positions.Positions[i].Volume > 0, '매수', '매도'),
        abs(gEnv.Engine.TradeCore.Positions.Positions[i].Volume)
        ]);
      stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
      bExist := true;
    end;
  end;

  if (iCnt > 0) or ( bExist ) then
  begin
    stLog  := stLog + '종료하시겠습니까?';
    if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      Result := true
    else
      Result := false;
  end;

end;

procedure TOrpMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
  bClose : boolean;
begin

  bClose := CheckRemainActiveOrder;
  if not bClose then
  begin
    Action := caNone;
    Exit;
  end;
    // save the working environment
  CoUnInitialize;

  if gEnv.RecoveryEnd then
  begin
    gEnv.Engine.FormBroker.Save(ComposeFilePath([gEnv.DataDir, FILE_ENV]));
    gEnv.Engine.TradeCore.SaveFunds;
  end;

  //FEngine.SendBroker.SubScribeAccount( false );
  //FEngine.Api.Fin;
    // before free main form
    // free all work forms (required)
  for i := ComponentCount-1 downto 0 do
    if Components[i] is TForm then
      Components[i].Free;

  //Module.Free;
  SaveRegedit;

  FAcntLoader.Free;
  gSymbol.Free;
  gBoardEnv.Free;
    //
  FQuoteTimer.Free;
    //

  FEngine.Free;

  gLog.Free;
  gClock.Free;


  Action  := caFree;

end;

procedure TOrpMainForm.FormDestroy(Sender: TObject);
begin
  //

end;

procedure TOrpMainForm.FormCreate(Sender: TObject);
var
  bValue : boolean;
  i, iParam  : integer;
  stParam : string;
  bResult : boolean;

  stLog, stMsg : string;

begin

  Application.OnException := AppException;

  Left := 0;
  Top := 0;

  gEnv.CreateAppLog;
  gEnv.Log       := TLogThread.Create;

  if not LoadConfig then
  begin
    ShowMessage('관리자에게 문의하세요 비정상 종료합니다.');
    close;
  end;

  LoadRegedit;
  // 레지스트리 읽기
  LoadRegedit;
  // 런처에서 넘어온 로그인 정보 읽기
  gEnv.LoadLoginInfo;

  gEnv.YoungLee := false;
{$IFDEF YOUNG_LEE}
  gEnv.YoungLee := true;
{$ENDIF}
{$IFDEF MY_GURU}
  gEnv.YoungLee := false;
  {$IFDEF Beta}
    gEnv.Beta := true;
  {$ENDIF}
{$ENDIF}

  if ( gEnv.Beta ) and ( ParamCount <= 0 ) then
  begin
    ShowMessage('Guru 인증 먼저 하세요 ' );
    WinExec( 'grLauncher.exe', SW_SHOW );
    Application.Terminate;
  end;

  Timer1.Enabled := true;

  gEnv.OnState   := OnAppState;
  gEnv.OnLog     := DoLog;
  gEnv.RootDir   := AppDir;
  gEnv.DataDir   := ComposeFilePath([gEnv.RootDir, DIR_DATA]);
  gEnv.OutputDir := ComposeFilePath([gEnv.RootDir, DIR_OUTPUT]);
  gEnv.LogDir    := ComposeFilePath([gEnv.RootDir, DIR_LOG]);
  gEnv.SimulDir  := ComposeFilePath([gEnv.RootDir, DIR_SIMUL]);
  if gEnv.QuoteDir = '' then
    gEnv.QuoteDir  := ComposeFilePath([gEnv.RootDir, DIR_QUOTEFILES]);
  gEnv.TemplateDir  := ComposeFilePath([gEnv.RootDir, DIR_TEMPLATE]);
  gEnv.RecoveryEnd  := false;

  FEngine := TLemonEngine.Create;
  gEnv.Main   := Self;
  gEnv.Engine := FEngine;
  gEnv.CreateTimeSpeeds;

  gLog.Add( lkApplication, 'TOrpMainForm', 'FormCreate', 'start' );
  gEnv.UserType := utNormal;
  //initControls;
  BranchMode;
end;




procedure TOrpMainForm.QuoteTimerProc(Sender: TObject);
var
  stDate : string;

  stLocal, stSystem: SYSTEMTIME;
  dtLocal, dtSystem, dtGap: TDateTime;

  aRect : array [0..3] of TRect;
  stName: array [0..3] of string;
  stTime: array [0..3] of string;
  dtTime: array [0..3] of TDateTime;
  iL, iL2, iH, iTmp, iG, iWid  : integer;
  I: integer;

begin

  if gEnv.RunMode = rtSimulation then
  begin
    stDate  := Format( ' %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', GetQuoteTime)]);
    StatusBar.Panels[1].Text := stDate;
    StatusBar.Panels[2].Text := Format( 'CPU : %.0f %s', [
        gEnv.Engine.QuoteBroker.Timers.CpuUsage, '%']);
  end
  else begin

    if gEnv.RecoveryEnd then
    
    with pb do
    begin
      Canvas.Font.Color := clBlack;
      //Canvas.Font.Style := Canvas.Font.Style +  [fsBold]  ;
      iWid := Width div 4  ;
      iL := 2;
      iH := 10;
      iG := 2;

      stName[0] := '시카고';
      stName[1] := '런던';
      stName[2] := '싱가포르';
      stName[3] := '한국';
      iTmp :=Canvas.TextHeight( stName[0] ) + 1;
      aRect[0]  := Rect( 1, iH, iWid, iH+iTmp );
      aRect[1]  := Rect( aRect[0].Right, iH, aRect[0].Right +iWid, iH+iTmp );
      aRect[2]  := Rect( aRect[1].Right, iH, aRect[1].Right +iWid, iH+iTmp );
      aRect[3]  := Rect( aRect[2].Right, iH, aRect[2].Right +iWid, iH+iTmp );

      Canvas.Font.Style := Canvas.Font.Style + [fsbold];

      for I := 0 to High( stName ) do
      begin
        iTmp := Canvas.TextWidth( stName[i] );
        iL2  := iWid div 2 - iTmp div 2;
        Canvas.TextOut(aRect[i].Left + iL2, iH, stName[i]);
      end;

      Canvas.Font.Style := Canvas.Font.Style - [fsbold];

      dtTime[0] := IncHour( GetQuoteTime, -15);
      dtTime[1] := IncHour( GetQuoteTime, -9);
      dtTime[2] := IncHour( GetQuoteTime, -1);
      dtTime[3] := GetQuoteTime;

      iL := Canvas.Font.Size;
      Canvas.Font.Size := 8;
      for I := 0 to High( stName ) do
      begin
        stTime[i] :=  FormatDateTime('ampm hh:nn:ss', dtTime[i]);
        iTmp := Canvas.TextWidth( stTime[i] );
        iL2  := iWid div 2 - iTmp div 2;
        Canvas.TextOut(aRect[i].Left + iL2, aRect[i].Bottom + iG, stTime[i]);
      end;
      Canvas.Font.Size := iL;

      Canvas.CopyRect( plInfo.ClientRect, Canvas, plInfo.ClientRect );
    end;
  end;

  //SaveProfitNLoss;
end;

procedure TOrpMainForm.SaveProfitNLoss;
var
  i : integer;
begin
  for i := 0 to gEnv.Engine.TradeCore.Accounts.Count - 1 do
    gEnv.Engine.TradeCore.Accounts.Accounts[i].ApplyFill( GetQuoteTime );
end;



//--------------------------------------------------< Emulator event handlers >


procedure TOrpMainForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled  := false;
  if gLogin = nil then
    gEnv.CreateLogin( Self );

  if ParamStr(1) <> '' then
  begin
    gLogin.AutoLogin  := true;
    gLogin.DoAutoLogin;
  end;

  if ( IDCANCEL = gLogin.ShowModal() ) then
  begin
    Close;
    Exit;
  end;//
end;

procedure TOrpMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  show;
end;

procedure TOrpMainForm.QuoteTime(Sender: TObject; Value: TDateTime);
begin
  gEnv.Engine.QuoteBroker.Timers.Feed(Value);
end;

//
// When the KRX Quote Emulator sends a packet through API, not through network,
// the Main form become medium to deliver the packet to the QuoteReceiver.
// Otherwise,
//

//---------------------------------------------------------------------< menu >

procedure TOrpMainForm.OnWindowMenuClick(Sender: TObject);
var
  iTag : integer;
  aItem : TMenuItem;
  aForm : TForm;
begin
   iTag  := TMenuItem( Sender ).Tag;
   aItem := TMenuItem( Sender );
   aForm := gEnv.Engine.FormBroker.FindFormMenu(aItem) as TForm;
   if aForm = nil then exit;
   aForm.WindowState := wsNormal;
   aForm.Show;
end;


procedure TOrpMainForm.SaveEnv( aStorage : TStorage );
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('Left').AsInteger := Left;
  aStorage.FieldByName('Top').AsInteger := Top;
  aStorage.FieldByName('width').AsInteger := Width;
  aStorage.FieldByName('Height').AsInteger := Height;

end;

procedure TOrpMainForm.LoadEnv( aStorage : TStorage );
var
  isSave : boolean;
begin
  if aStorage = nil then Exit;
  Left  := aStorage.FieldByName('Left').AsInteger;
  Top   := aStorage.FieldByName('Top').AsInteger;

  Width := aStorage.FieldByName('width').AsInteger;
  Height:= aStorage.FieldByName('Height').AsInteger;

end;

//-------------------------------------------------------< manage quote files >

function TOrpMainForm.LoadConfig : boolean;
var
  ini : TInitFile;
  incCount, iCount, iPos, i, iUse : integer;
  stTmp2, stTmp : string;
  cUser : char;
  dTmp : double;

begin
  Result := false;

  try
    ini := nil;
    ini := TInitFile.Create(FILE_ENV2);

    if ini = nil then
      Exit; 

    gEnv.ConConfig.UserID     := ini.GetString('CONFIG','USERID');
    gEnv.ConConfig.Password   := ini.GetString('CONFIG','PASSWORD');
    gEnv.ConConfig.ApType := ini.GetString('CONFIG','APTYPE') ;
    
    gEnv.ConConfig.SisAddr    := ini.GetString('CONFIG','SisAddr');
    gEnv.ConConfig.TradeAddr2 := ini.GetString('CONFIG','TradeAddr2');


    iUse  := ini.GetInteger('CONFIG', 'USEMDB');
    if iUse = 1 then
      gEnv.ConConfig.UseMdb := true
    else
      gEnv.ConConfig.UseMdb := false;


    stTmp := ini.GetString('CONFIG', 'QUOTEDIR');
    if stTmp = 'SAURI' then
      gEnv.QuoteDir :=''
    else
      gEnv.QuoteDir := stTmp;

    gEnv.SetRunMode(ini.GetInteger('CONFIG','RUNMODE'));
    gEnv.SetDBMode(ini.GetInteger('CONFIG','DATABASE'));
    stTmp := ini.GetString('CONFIG', 'TRADEDATE');

    if gEnv.RunMode = rtSimulation then
      gEnv.AppDate := EncodeDate(StrToIntDef(Copy(stTmp,1,4), 0),
                           StrToIntDef(Copy(stTmp,5,2), 0),
                           StrToIntDef(Copy(stTmp,7,2), 0))
    else
      gEnv.appDate := Date;



    gEnv.Input.AcntNo     := ini.GetString('INPUT','ACNTNO');
    gEnv.Input.AcntPw   := ini.GetString('INPUT','ACNTPW');

    gEnv.Input.UID     := ini.GetString('INPUT','UID');
    gEnv.Input.MemNo   := ini.GetString('INPUT','MEMNO');
    gEnv.Input.BraNo   := ini.GetString('INPUT','BRANO');
    gEnv.Input.SID     := ini.GetString('INPUT','SID');

    //gEnv.CheckPacketVersion;
    // ftp

    gEnv.ConConfig.FtpIP      := ini.GetString('FTP','IP');
    gEnv.ConConfig.FtpID      := ini.GetString('FTP','ID');
    gEnv.ConConfig.FtpPass    := ini.GetString('FTP','PS');
    gEnv.ConConfig.FtpRemoteD := ini.GetString('FTP','RD');
    gEnv.ConConfig.FtpLocalD  := ini.GetString('FTP','LD');
    // DB
    gEnv.ConConfig.DbIP       := ini.GetString('DB','IP');
    gEnv.ConConfig.DbID       := ini.GetString('DB','ID');
    gEnv.ConConfig.DbPass     := ini.GetString('DB','PASS');
    gEnv.ConConfig.DbSource   := ini.GetString('DB','SOURCE');
    gEnv.ConConfig.Mdb        := ini.GetString('DB','MDBNAME');

    // fees
    gEnv.Cost.FDues := ini.GetString('COST', 'FDues');
    gEnv.Cost.FCost := ini.GetString('COST', 'FMemberCost');
    gEnv.Cost.ODues := ini.GetString('COST', 'ODues');
    gEnv.Cost.OCost := ini.GetString('COST', 'OMemberCost');


    gEnv.ConConfig.StartOrderNo := ini.GetInteger( 'ORDERNO', 'StartOrderNo' );
    gEnv.ConConfig.EndOrderNo := ini.GetInteger( 'ORDERNO', 'EndOrderNo' );
    gEnv.ConConfig.LastOrderNo:=  gEnv.ConConfig.StartOrderNo;
    gEnv.ConConfig.IncCount := 1;
  finally
    ini.Free
  end;
  Result := true;
end;


procedure TOrpMainForm.LoadRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      if ValueExists('SaveInput' ) then  gEnv.ConConfig.SaveInput := ReadBool('SaveInput')
      else gEnv.ConConfig.SaveInput := false;

      if ValueExists('RealMode' ) then  gEnv.ConConfig.RealMode := ReadBool('RealMode')
      else gEnv.ConConfig.RealMode := true;

      if ValueExists('InputID0' ) then  gEnv.ConConfig.SaveID[0] := ReadString('InputID0')
      else gEnv.ConConfig.UserID := '';
      if ValueExists('InputPW0' ) then  gEnv.ConConfig.SavePW[0] := ReadString('InputPW0')
      else gEnv.ConConfig.Password := '';
      if ValueExists('InputCert0' ) then  gEnv.ConConfig.SaveCert[0] := ReadString('InputCert0')
      else gEnv.ConConfig.CertPass := '';

      if ValueExists('InputID1' ) then  gEnv.ConConfig.SaveID[1] := ReadString('InputID1')
      else gEnv.ConConfig.UserID := '';
      if ValueExists('InputPW1' ) then  gEnv.ConConfig.SavePW[1] := ReadString('InputPW1')
      else gEnv.ConConfig.Password := '';
      if ValueExists('InputCert1' ) then  gEnv.ConConfig.SaveCert[1] := ReadString('InputCert1')
      else gEnv.ConConfig.CertPass := '';

      // young_Lee
      if ValueExists('Input0LeeID' ) then  gEnv.ConConfig.Save0LeeID := ReadString('Input0LeeID')
      else gEnv.ConConfig.Save0LeeID := '';
      if ValueExists('Input0LeePW' ) then  gEnv.ConConfig.Save0LeePW := ReadString('Input0LeePW')
      else gEnv.ConConfig.Save0LeePW  := '';
      if ValueExists('InputOLeeCode' ) then  gEnv.ConConfig.Save0LeeCode := ReadString('InputOLeeCode')
      else gEnv.ConConfig.Save0LeeCode := '';
    end;
  finally
    Free;
  end;
end;


procedure TOrpMainForm.SaveRegedit;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    RootKey := RegRootKey;
    if OpenKey(RegOpenKeyIni, True) then begin

      WriteBool('SaveInput', gEnv.ConConfig.SaveInput );
      WriteBool('RealMode', gEnv.ConConfig.RealMode );

      WriteString('InputID0', gEnv.ConConfig.SaveID[0] );
      WriteString('InputPW0', gEnv.ConConfig.SavePW[0]);
      WriteString('InputCert0', gEnv.ConConfig.SaveCert[0]);

      WriteString('InputID1', gEnv.ConConfig.SaveID[1] );
      WriteString('InputPW1', gEnv.ConConfig.SavePW[1]);
      WriteString('InputCert1', gEnv.ConConfig.SaveCert[1]);

      WriteString('Input0LeeID', gEnv.ConConfig.Save0LeeID);
      WriteString('Input0LeePW', gEnv.ConConfig.Save0LeePW );
      WriteString('InputOLeeCode', gEnv.ConConfig.Save0LeeCode );
    end;
  finally
    Free;
  end;
end;


procedure TOrpMainForm.LogInEnd ;
var
  idx : integer;
begin
  if gLogin <> nil then
    gLogin.ModalResult  :=  IDOK;

  if gEnv.ConConfig.SaveInput then
    SaveRegedit;

  idx := ifThen( gEnv.ConConfig.RealMode, 0, 1 );

  gEnv.ConConfig.UserID  := gEnv.ConConfig.SaveID[idx];
  gEnv.ConConfig.Password:= gEnv.ConConfig.SavePW[idx];
  gEnv.ConConfig.CertPass:= gEnv.ConConfig.SaveCert[idx];
end;



procedure TOrpMainForm.OnAppState(asType: TAppStatus);
var MasterFile : string;
  bResult : boolean;
  stTxt : string;
begin

  case asType of
    asError :
      begin
        ShowMessage( Format('Error : %s', [ gEnv.ErrString ] ));
        gEnv.ErrString := '';
      end;
    asInit:
    begin

      FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
      FQuoteTimer.Interval := 200;
      FQuoteTimer.OnTimer := QuoteTimerProc;
      FQuoteTimer.Enabled := True;
      //gEnv.Engine.SymbolCore.SymbolLoader.SetSpecs;
      ExpertCtrl := TAlphaCommX.Create( Self );
      gEnv.Engine.CreateApi( ExpertCtrl );
      gEnv.CreateBoardEnv;
    end;
    asConMaster    :
    begin
      LogInEnd;
      // 종목마스터 로드 한다.
      gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromApi;
      gEnv.Engine.SymbolCore.OptionPrint;
      // 계좌 요청
      gEnv.Engine.SendBroker.RequestAccountData;

    end;
    asRecoveryStart:
    begin
      //
      FAcntLoader:= TAccountLoader.Create( FEngine );
      FAcntLoader.Load;

      gEnv.Engine.TradeCore.LoadFunds;
      gEnv.Engine.SymbolCore.LoadFavorSymbols;

      FEngine.TradeBroker.OnSendOrder := FEngine.SendBroker.Send;
      FEngine.SendBroker.init;
      // 계좌 비밀번호..입력.
      FillAccountPass;

      //gEnv.UserType := utStaff;
      if gEnv.UserType = utStaff then
        DataModule1.Stg.Visible := true;

      if gEnv.Beta  then
        DataModule1.Skew1.Visible := false;
      //gEnv.Info := TFrmServerMessage.Create( Self );
      //gEnv.Info.Hide;

      gLog.Add( lkApplication, '','', '손익및 미체결 주문 리커버리 요청' );
    end;
    asRecoveryEnd: SetpRecoveryEnd;
    asStart:
      begin
        case gEnv.RunMode of
          rtRealTrading : stTxt := 'Real Trading';
          rtSimulUdp : stTxt := 'Sis-Udp Ord-Virtual';
          rtSimulation : stTxt := 'Simulation';
          else
            stTxt := '';
        end;


        if gEnv.RunMode <> rtRealTrading then
          StatusBar.Panels[0].Text := stTxt;

        gEnv.SetAppStatus( asLoad );
        Show;

      end;
    asLoad  :
      // 화면 로드
      begin
        gEnv.SetFees;
        Show;
        initQ;
      end;
    asSimul :
      StepSimulation;
    asLogOut :
    begin
      //FTradeReceiver.FSocket[SOCK_MO].
      //FTradeReceiver.FSocket[SOCK_MO].SocketDisconnect;     khw
    end;
  end;
end;


procedure TOrpMainForm.OrderReset(Sender: TObject; bBack : boolean;Value: Integer);
begin
  gEnv.Engine.TradeCore.Reset( Value, bBack );    
end;

{$ENDREGION}

//------------------------------------------------------------< miscellaneous >

procedure TOrpMainForm.DoLog(Sender: TObject; stLog: String);
begin
   {
  MemoLog.Font.Size := 9;
  if gEnv.RunMode in [ rtSimulUdp, rtSimulation ] then
    MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss]', Now)+ ' ' + stLog);
  }
end;

procedure TOrpMainForm.DoTimeLog(Sender: TObject; stLog: String);
begin
  {
  if MemoLog.Lines.Count > 0 then
    MemoLog.Lines[0]  := stLog
  else
    MemoLog.Lines.Add(stLog );
  }
  //Caption := 'Guru Ver.' + FileVersionToStr(Application.ExeName);
  //Caption := Caption + ' | ' + stLog;

end;

procedure TOrpMainForm.Exit2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TOrpMainForm.AppException(Sender: TObject; E: Exception);
begin
  gEnv.AppMsg( WIN_ERR, 'Application Error : ' + E.Message );
end;

//------------------------------------------------------------< 모드별 분기 >

procedure TOrpMainForm.BranchMode;
var
  bExist : boolean;
  stTxt  : string;
begin

  case gEnv.RunMode of
    rtRealTrading : stTxt := 'Real Trading';
    rtSimulUdp : stTxt := 'Sis-Udp Ord-Virtual';
    rtSimulation : stTxt := 'Simulation';
  end;

  gLog.Add( lkApplication, 'TOrpMainForm', 'Mode', 'Guru Mod is ' + stTxt );

  case gEnv.RunMode of
    rtRealTrading, rtSimulUdp , rtSimulation :
      begin
        gEnv.SetAppStatus( asInit );
      end;
  end;
end;


procedure TOrpMainForm.StepInitSymbolLoad;
var
  bResult : boolean;
begin

  FEngine.Holidays.Load(FILE_HOLIDAYS);

  ForceDirectories(gEnv.DataDir);
  ForceDirectories(gEnv.OutputDir);


  FQuoteTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FQuoteTimer.Interval := 200;
  FQuoteTimer.OnTimer := QuoteTimerProc;
  FQuoteTimer.Enabled := True;

end;


procedure TOrpMainForm.SetpRecoveryEnd;
var
  ivar : integer;
  bGiSis  : boolean;
begin
  case gEnv.RunMode of
    rtRealTrading :
      begin
        FEngine.SymbolCore.MarketsSort;
        //FEngine.SendBroker.SubScribeAccount( true );
        gEnv.SetAppStatus( asStart );
      end;
    rtSimulUdp, rtSimulation :
      begin
        gEnv.SetAppStatus( asStart );
      end;
  end;
  gEnv.RecoveryEnd  := true;
  //LogInEnd( false );
end;

procedure TOrpMainForm.Show1Click(Sender: TObject);
begin
  show;
end;

procedure TOrpMainForm.StepSimulation;
begin
  //gEnv.Engine.SyncFuture.Init;
  //gEnv.Engine.SymbolCore.Prepare;
end;

procedure TOrpMainForm.initQ;
begin

  gLog.Add( lkApplication, 'TOrpMainForm', 'Load', '저장 화면 로드' );

  // 화면 셋팅 백업..

  gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV]));

  BackUpWindows;
  gEnv.Engine.Timers.init;

end;


procedure TOrpMainForm.BackUpWindows;
var
  stDir, stExt : string;
  stNewName, stOldName, stSrcDir : string;
  bRes, bPaste : Boolean;
  iPos : integer;

  iExist, iNew : int64;
  iExistSize, iNewSize : Longint;
  bExist, bNew : boolean;
begin
  stDir := ExtractFilePath( paramstr(0) )+'back';
  stSrcDir := ExtractFilePath( paramstr(0) )+'database';
  if not DirectoryExists( stDir ) then
  begin
    CreateDir(stDir);
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Create Backup Folder..' );
  end;

  stExt := ExtractFileExt( FILE_ENV );
  iPos  := Length( FILE_ENV ) - Length( stExt );
  stOldName := Copy( FILE_ENV, 1, iPos );

  stNewName := Format('%s_%s%s', [ stOldName, FormatDateTime('yyyymmdd', now ), stExt ]);

  stOldName := stSrcDir + '\' + FILE_ENV;
  stNewName := stDir + '\' + stNewName;

  bPaste  := true;
  bRes := CopyFile(  PChar(stOldName), PChar(stNewName), bPaste );

  if bRes then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Backup File to Back folder' )
  else if (not bPaste) and ( not bRes) then
    gLog.Add( lkApplication, 'TOrpMainForm', 'BackUpWindows', '...Failed Move File to Back folder' );

  stOldName := ExtractFilePath( ParamStr(0) ) + FILE_UPDATER;
  stNewName := ExtractFilePath( ParamStr(0) ) + FILE_NEW_UPDATE;

  bExist := FileExists( stOldName );
  bNew   := FileExists( stNewName );

  if ( bExist ) and ( bNew ) then
  begin
    iExist := StrToInt64(FormatDateTime('YYMMDDhhmmss', FileDateToDateTime(FileAge( stOldName))));
    iNew   := StrToInt64(FormatDateTime('YYMMDDhhmmss', FileDateToDateTime(FileAge( stNewName))));

    iExistSize  := GetSizeOfFile( stOldName );
    iNewSize    := GetSizeOfFile( stNewName );

    if ( iExist < iNew ) or ( iExistSize <> iNewSize ) then
      if DeleteFile( stOldName ) then
      begin
        if CopyFile(  PChar(stNewName), PChar(stOldName), bPaste ) then
          gLog.Add( lkApplication, '','',  Format('Sucess CopyFile file %s(%d|%d)  --> %s(%d|%d) ',
          [ stOldName, iExist,iExistSize, stNewName ,iNew,iNewSize   ])   )
        else
          gLog.Add( lkApplication, '','',  Format('failed CopyFile file %s  --> %s ', [ stNewName , stOldName  ])   );
      end else
        gLog.Add( lkApplication, '','',  Format('failed delete file --> %s', [ stOldName ])   );
  end;
end;




end.

