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
  IdAntiFreeze, OleCtrls, ESApiExpLib_TLB, IdHTTP, GR32_Image
  ;

{$INCLUDE define.txt}

const
  RegRootKey = HKEY_LOCAL_MACHINE;
  RegOpenKeyIni = '\SOFTWARE\KR\GURU\';


type
  TOrpMainForm = class(TForm)
    MemoLog: TMemo;
    StatusBar: TStatusBar;
    plInfo: TPanel;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N26: TMenuItem;
    Exit2: TMenuItem;

    pb: TPaintBox;
    Timer1: TTimer;
    Bitmap32: TBitmap32List;
    ExpertCtrl: TESApiExp;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Show1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure pbDblClick(Sender: TObject);
  private
    FEngine: TLemonEngine;
    FQuoteTimer: TQuoteTimer;
    FAcntLoader: TAccountLoader;
    FCertSucces: boolean;
    FIsActive: boolean;

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
    function CheckFileDate: boolean;

    { Private declarations }
  public
    { Public declarations }
    m_stIni : string;
    function FindGiComponet( stName : string ) : boolean;
      // ��庰 �б�
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

    property IsActive : boolean read FIsActive;
    // only young_lee
    property CertSucces: boolean read FCertSucces;


  end;

var
  OrpMainForm: TOrpMainForm;

function RunAsAdmin(hWnd: HWND; filename: string; Parameters: string; bNeedReg: boolean): Boolean;

implementation

uses CalcGreeks, CleIni, CleLog,  Registry, CleFQN,CleFormBroker, CleParsers,
  GleConsts, CleExcelLog, CleOrders,
  TLHelp32,  FAppInfo,  FQryTimer,
  DBoardEnv,  FAccountPassWord, FServerMessage
  ;


{$R *.dfm}

function RunAsAdmin(hWnd: HWND; filename: string; Parameters: string; bNeedReg: boolean): Boolean;
var

    sei: TShellExecuteInfo;
    st1, st2 : string;

begin

    st1 := ExtractFilePath( paramstr(0) )+filename;
    st2 := ExtractFilePath( paramstr(0) )+Parameters;
    ZeroMemory(@sei, SizeOf(sei));
    sei.cbSize := SizeOf(TShellExecuteInfo);
    sei.Wnd := hwnd;
    sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
    sei.lpVerb := PChar(st1);
    sei.lpFile := PChar(st2); // PAnsiChar;

    if parameters <> '' then
    begin
      sei.lpParameters := PChar(parameters); // PAnsiChar;
    end;

    sei.nShow := SW_SHOWNORMAL; //Integer;
    Result := ShellExecuteEx(@sei);   

end;

//-----------------------------------------------------------------< init >

procedure TOrpMainForm.FillAccountPass;
var
  aForm : TFrmAccountPassWord;
  aForm2: TFrmQryTimer;
  bQuery: boolean;

begin

  bQuery := false;
  if gEnv.UserType = utStaff then
  begin
    bQuery := true;
  end else
  if gEnv.UserType = utNormal then
  begin
    aForm := TFrmAccountPassWord.Create( Self );
    try
      if aForm.Open then
      begin
        bQuery := true;
      end else gEnv.SetAppStatus( asRecoveryEnd );
    finally
      aForm.Free;
    end;
  end ;

  if bQuery then
  begin
    aForm2:= TFrmQryTimer.Create( Self );
    try
       // �Ѵ� 10������ ��ȸ ���ѵ�.
      FEngine.SendBroker.RequestAccountData;
      FEngine.Api.AcntTimer.Enabled := true;
      if aForm2.Open then
      else gEnv.SetAppStatus( asRecoveryEnd );
    finally
      aForm2.Free;
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
    stLog := Format('��ü�� �ֹ� : %d �� ���� ', [ iCnt ]);

  iVol := 0;
  stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
  bExist := false;
  for i:=0 to gEnv.Engine.TradeCore.Positions.Count-1 do
  begin
    //iVol := iVol +  gEnv.Engine.TradeCore.Positions.Positions[i].Volume;
    if gEnv.Engine.TradeCore.Positions.Positions[i].Volume <> 0 then
    begin
      stLog := stLog + Format('%s : %s �ܰ� %d ����', [ gEnv.Engine.TradeCore.Positions.Positions[i].Symbol.ShortCode,
        ifThenStr( gEnv.Engine.TradeCore.Positions.Positions[i].Volume > 0, '�ż�', '�ŵ�'),
        abs(gEnv.Engine.TradeCore.Positions.Positions[i].Volume)
        ]);
      stLog := stLog + #13+#10+''+#13+#10+''+#13+#10;
      bExist := true;
    end;
  end;

  if (iCnt > 0) or ( bExist ) then
  begin
    stLog  := stLog + '�����Ͻðڽ��ϱ�?';
    if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      Result := true
    else
      Result := false;
  end;

end;

procedure TOrpMainForm.FormActivate(Sender: TObject);
begin
  if ( FEngine <> nil ) and ( not FIsActive ) then
  begin
   // Timer1Timer( Timer1 );
    Application.BringToFront;
    //Application.ActiveFormHandle
    BranchMode;
    FIsActive := true;
    gLog.Add( lkApplication,'','','Guru Mode Start');

  end;
end;

procedure TOrpMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
  bClose : boolean;
begin

    // save the working environment
  if gEnv.Engine <> nil then
  begin
    bClose := CheckRemainActiveOrder;
    if not bClose then
    begin
      Action := caNone;
      Exit;
    end;

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

  end;

  CoUnInitialize;

  Action  := caFree;

end;

procedure TOrpMainForm.FormDestroy(Sender: TObject);
begin
  //

end;

function TOrpMainForm.CheckFileDate : boolean;
var
  dtDate, dtAdd : TDateTime;
  iDay : integer;
begin
  try
    Result  := true;
    dtDate  := EnCodeDate( 2017, 1, 1 );
    dtAdd   := IncMonth( dtDate, 2 );

    if dtDate > Date then
    begin
      Result := false;
      ShowMessage(  Format('PC �ð��� �߸��Ǿ� �ֽ��ϴ�.  pc ���� : %s ', [
        FormatDateTime( 'yyyy-mm-dd', Date ) ]));
      Exit;
    end;

    iDay  := GetDayBetween( Date, dtAdd );

    if dtAdd < Date then
    begin
      Result := false;
      ShowMessage(  Format('�Ⱓ�� ���� �����մϴ�.  ������ : %s ', [
        FormatDateTime( 'yyyy-mm-dd', dtAdd ) ]));

    end else
    if iDay < 10 then
      ShowMessage(  Format('��밡�� ���ڰ� %d �� ���ҽ��ϴ�. ������ : %s', [ iDay ,
        FormatDateTime( 'yyyy-mm-dd', dtAdd )]));

  except
  end;

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

  FIsActive := false;

  gEnv.CreateAppLog;
  gEnv.Log       := TLogThread.Create;

  // ini ���� �б�
  if not LoadConfig then
  begin
    ShowMessage('�����ڿ��� �����ϼ��� ������ �����մϴ�.');
    close;
  end;
  // ������Ʈ�� �б�
  LoadRegedit;
  // ��ó���� �Ѿ�� �α��� ���� �б�
  gEnv.LoadLoginInfo;

  gEnv.YoungLee := false;
  gEnv.Beta := false;
{$IFDEF YOUNG_LEE}
  gEnv.YoungLee := true;
{$ENDIF}
{$IFDEF MY_GURU}
  gEnv.YoungLee := false;
  {$IFDEF Beta}
    gEnv.Beta := true;
  {$ENDIF}

{$ENDIF}

  if ( gEnv.YoungLee ) and ( ParamCount <= 0 ) then
  begin
    ShowMessage('����Ʈ���̵�  ������ �ʿ��մϴ�.' );
    WinExec( 'grLauncher.exe', SW_SHOW );
    Application.Terminate;
  end;

  if ( gEnv.Beta ) and ( ParamCount <= 0 ) then
  begin
    ShowMessage('����� ������ �ʿ��մϴ�.' );
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
  gEnv.EnvDir    := ComposeFilePath([gEnv.RootDir, DIR_ENV]);
  if gEnv.QuoteDir = '' then
    gEnv.QuoteDir  := ComposeFilePath([gEnv.RootDir, DIR_QUOTEFILES]);
  gEnv.TemplateDir  := ComposeFilePath([gEnv.RootDir, DIR_TEMPLATE]);
  gEnv.RecoveryEnd  := false;

  FEngine := TLemonEngine.Create;

  gEnv.Engine := FEngine;
  gEnv.Main   := Self;
  gEnv.CreateTimeSpeeds;

  gLog.Add( lkApplication, 'TOrpMainForm', 'FormCreate', 'start' );
  gEnv.UserType := utNormal;

  Application.HintPause := 100;

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

      stName[0] := '��ī��';
      stName[1] := '����';
      stName[2] := '�̰�����';
      stName[3] := '�ѱ�';
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
var
  st : string;
begin
  Timer1.Enabled  := false;

  if gLogin = nil then
    gEnv.CreateLogin( Self );

  st  := ParamStr(1);
  if st <> '' then
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
  stTmp2, stTmp, stSection : string;
  cUser : char;
  dTmp : double;

begin
  Result := false;

  try
    ini := nil;
    ini := TInitFile.Create(FILE_ENV2);

    if ini = nil then
      Exit;
         {
    stSection  := 'TITLE';
    gEnv.ConConfig.MktCode   := ini.GetString(stSection,'MKT');
    gEnv.ConConfig.CmpCode   := ini.GetString(stSection,'CMP');
    gEnv.ConConfig.CtyCode   := ini.GetString(stSection, 'CTY');

    gEnv.ConConfig.MockVisible  := ini.GetInteger('Config','ShowMock') = 1;
        }

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


  finally
    ini.Free
  end;
  Result := true;
end;


procedure TOrpMainForm.LoadRegedit;
var
  Reg: TRegistry;
  stToDay : string;
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

      if ValueExists('SaveDate' ) then  gEnv.BoardCon.SaveDate := ReadString('SaveDate')
      else gEnv.BoardCon.SaveDate := '';

      stToday := FormatDateTime('yyyymmdd', Date );
      if gEnv.BoardCon.SaveDate <> stToday then
        gEnv.BoardCon.TodayNoShowDlg := false
      else
        if ValueExists('TodayNoShowDlg' ) then  gEnv.BoardCon.TodayNoShowDlg := ReadBool('TodayNoShowDlg')
        else gEnv.BoardCon.TodayNoShowDlg := false;
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

      WriteBool('ShowToday', gEnv.BoardCon.TodayNoShowDlg );
      if gEnv.BoardCon.TodayNoShowDlg then
        WriteString('SaveDate', gEnv.BoardCon.SaveDate )

    end;
  finally
    Free;
  end;
end;




procedure TOrpMainForm.LogInEnd;
var
  idx : integer;
begin
  if gLogin <> nil then
  begin
    gLogIn.SaveLoginData ;
    gLogin.ModalResult  :=  IDOK;
  end;

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
      // spec �ε�
      gEnv.Engine.SymbolCore.SymbolLoader.SetSpecs;
      gEnv.CreateBoardEnv;
      gEnv.Engine.CreateApi( ExpertCtrl );

    end;
    asConMaster    : LogInEnd;
    asRecoveryStart:
    begin
      //
      FAcntLoader:= TAccountLoader.Create( FEngine );
      FAcntLoader.Load;

      gEnv.Engine.TradeCore.LoadFunds;
      gEnv.Engine.SymbolCore.LoadFavorSymbols;

      FEngine.TradeBroker.OnSendOrder := FEngine.SendBroker.Send;
      FEngine.SendBroker.init;
      // ���� ��й�ȣ..�Է�.
      FillAccountPass;
           {
      if (gEnv.ConConfig.UserID ='jslight7') and
          (gEnv.ConConfig.Password ='khc6931') then
          gEnv.UserType := utStaff;
               }
      if gEnv.UserType = utStaff then
        DataModule1.Stg.Visible := true;

      if (gEnv.UserType = utNormal) and ( gEnv.Beta )  then
        DataModule1.Skew1.Visible := false;      

      gEnv.Info := TFrmServerMessage.Create( Self );
      gEnv.Info.Hide;

      gLog.Add( lkApplication, '','', '���͹� ��ü�� �ֹ� ��Ŀ���� ��û' );
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
        {
      if (gEnv.ConConfig.UserID ='jslight7') and
          (gEnv.ConConfig.Password ='khc6931') then
          gEnv.UserType := utStaff;
            }
        if gEnv.RunMode <> rtRealTrading then
          StatusBar.Panels[0].Text := stTxt;

        // �ü��� � �޳Ŀ� ����..
        case gEnv.RunMode of
          rtRealTrading,
          rtSimulUdp :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;
          rtSimulation :
            begin
              gEnv.SetAppStatus( asLoad );
              Show;
            end;

        end;
      end;
    asLoad  :
      // ȭ�� �ε�
      begin
        if gEnv.RunMode = rtSimulation then
        begin
          gEnv.SetFees;
          initQ;
          Exit;
        end;
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

procedure TOrpMainForm.pbDblClick(Sender: TObject);
begin
  gEnv.Engine.Api.Fin;
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
  gEnv.EnvLog( WIN_ERR, Format('%d %s', [ integer(gEnv.Engine.AppStatus),  ifThenStr( gEnv.Engine.Api.Ready,'��','��') ]) );
  gEnv.AppMsg( WIN_ERR, 'Application Error : ' + E.Message );
end;

//------------------------------------------------------------< ��庰 �б� >

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
        FEngine.SendBroker.SubScribeAccount( true );
        gEnv.SetAppStatus( asStart );
      end;
    rtSimulUdp, rtSimulation :
      begin
        gEnv.SetAppStatus( asStart );
      end;
  end;
  gEnv.RecoveryEnd  := true;
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

  gLog.Add( lkApplication, 'TOrpMainForm', 'Load', '���� ȭ�� �ε�' );

  
  // ȭ�� ���� ���..

  if gEnv.RunMode <> rtSimulation then
  begin
    //gEnv.Engine.SymbolCore.Prepare;
  end;

  gEnv.Engine.FormBroker.Load(ComposeFilePath([gEnv.DataDir, FILE_ENV]));

  BackUpWindows;
  gEnv.Engine.Timers.init;

  FormStyle := fsNormal;

end;




procedure TOrpMainForm.BackUpWindows;
var
  stDir, stExt : string;
  stNewName, stOldName, stSrcDir : string;
  bRes, bPaste : Boolean;
  iPos : integer;
  //
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
