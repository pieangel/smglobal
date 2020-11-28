unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,

  AlphaCommProj_TLB,  CleQuoteTimers, ApiPacket,

  GleTypes
  ;

const
  MAX_CNT = 35;
  MAX_CNT2 = 2;
  QRY_CNT = 2;

  ACCOUNT_QRY = 1;
  SYMBOL_QRY  = 0;
  AUOTE_QUOTE = 2;
type

  TLoadStatsType = ( lstNone, lstSymbol, lstAccount, lstEnd );

  TSrvSendItem = class( TCollectionItem )
  public
    strWinID, strFlag, strGtrCode, strTrCode, strLen,
    strData, strEncrypt : string;
  end;

  TApiManager = class
  private
    FApi: TAlphaCommX;
    FReady: boolean;
    FOnData: TTextNotifyEvent;
    FQryList : TList;
    FAutoQuoteList : TList;
    FQryTimer: TTimer;
    FAutoTimer: TTimer;

    FQryCount : array [0..QRY_CNT-1] of integer;
    FLoadStats: TLoadStatsType;
    FSendQryCount: integer;

    function CheckError( stData : string ): boolean;
    //** events
    procedure axCommReplyLogin(ASender: TObject; var pstr: OleVariant);
    procedure axCommXOnReplyConnect(ASender: TObject; var pstr: OleVariant);
    procedure axCommRecvRealData(ASender: TObject;
      var sRealData: OleVariant);
    procedure axCommReceiveRealHoga(ASender: TObject; var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33,
      s34, s35, s36, s37: OleVariant);
    procedure axCommReceRealChegyul(ASender: TObject; var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
    procedure axCommRecvRQData(ASender: TObject; var pstr: OleVariant);
    procedure axCommRecvRealOrdData(ASender: TObject; var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
    procedure axCommRecvRealPositoin(ASender: TObject; var s1, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19,
      s20, s21, s22: OleVariant);
    procedure axCommReplyFileDown(ASender: TObject; sFileData: Integer);
    procedure axCommCloseHost(ASender: TObject; var pstr: OleVariant);
    //** events End

    function GetRecoveryData: boolean;



  public
    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    procedure DoLogIn( stID, stPW, stCert : string );
    procedure Fin;

    procedure RequestAccountInfo;

    function GetEncodePassword( aAccount : TAccount ) : string;
    procedure PushRequest(strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt: string);
    function  RequestData(strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt: string): boolean;
    function  ReqRealTimeQuote(  bSet : boolean; stData : string ) : boolean;
    function  ReqRealTimeOrder(  bSet : boolean; stData : string ) : boolean;

    procedure UnRegistData( iWinID : integer ) ;

    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );
    procedure Disconnect;

    function GetDataCount( var wmid: OleVariant): OleVariant;
    function GetGridString(winID, flag, symbol: OleVariant;  row: integer): string;
    function GetDouble(winID, symbol: string): double;
    function GetString(winID, symbol: OleVariant): string;
    function GetInt(winID, symbol: string): integer;

    property Api: TAlphaCommX read FApi;
    property Ready : boolean read FReady ;//write FReady;
    property OnData: TTextNotifyEvent read FOnData write FOnData;
    property QryTimer : TTimer read FQryTimer write FQryTimer;
    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;
    property LoadStats : TLoadStatsType read FLoadStats write FLoadStats;

    // counting
    property SendQryCount : integer read FSendQryCount;
  end;


implementation

uses
  GAppEnv, GleLib , SynthUtil,  Dialogs, Windows,
  FOrpMain,
  Math
  ;

{ TApiManager }

{$REGION '   동부 EVENTS....'}

procedure TApiManager.axCommCloseHost(ASender: TObject; var pstr: OleVariant);
var
  stTmp : string;
  iRes : integer;
begin
  //ShowMessage('서버로부터 연결이 끊겼습니다.');

  stTmp := '주문접속이 끊겼습니다  자동재접속하시겠습니까?';
  iRes := MessageBox(gEnv.Main.Handle, PChar(stTmp), '접속확인', MB_YESNO+MB_SYSTEMMODAL+MB_APPLMODAL	);
  if iRes = IDYES then
  begin
    gEnv.SaveLoginInfo;
    gEnv.Main.Close;
    WinExec( 'grLauncher.exe AutoConnect', SW_SHOWNORMAL );
  end
  else
  begin
    ShowMessage( '프로그램을 종료합니다' );
    gEnv.Main.Close;
  end;
end;

procedure TApiManager.axCommReceiveRealHoga(ASender: TObject; var s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35,
  s36, s37: OleVariant);
begin
  try
  gReceiver.ParseHoga( s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35,
  s36, s37);

  except
   // ShowMessage( 'axCommReceiveRealHoga' );
  end;
end;

procedure TApiManager.axCommReceRealChegyul(ASender: TObject; var s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22: OleVariant);
begin
  try
  gReceiver.ParsePrice( s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22 );
  except
    //ShowMessage( 'axCommReceRealChegyul' );
  end;
end;

procedure TApiManager.axCommRecvRealData(ASender: TObject;
  var sRealData: OleVariant);
var
  winID, msg: string;
begin

  winID := Trim(Copy(sRealData, 1, 5));
  //msg := Trim(Copy(sRealData, 6, 50));
  gReceiver.ParseReqHoga( winID );

  gEnv.EnvLog( WIN_GI, sRealData );
  {
  case StrToIntDef(winID, 0) of
    REQ_SYMBOL_PRICE:
  end;
  }
end;

procedure TApiManager.axCommRecvRealOrdData(ASender: TObject; var s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22: OleVariant);
begin
  try

  gEnv.EnvLog( WIN_ORD, format('RealOrdData : %s, %s, %s, %s, %s', [  s14, s15, s4, s5, s7 ]) );

  gReceiver.ParseOrder(s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22);

  except
    //ShowMessage( 'axCommRecvRealOrdData' );
  end;
      {
  gEnv.EnvLog( WIN_TEST ,

  format(' RealOrdData : %s, %s, %s,' +
         '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, ' +
         '%s, %s',[
    s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22])
  );    }
end;

procedure TApiManager.axCommRecvRealPositoin(ASender: TObject; var s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22: OleVariant);
begin

  try
  gReceiver.ParseRealPos(
    s1, s2, s3,
    s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
    s21, s22);

  except
    //ShowMessage( 'axCommRecvRealPositoin' );
  end;
              {
  gEnv.EnvLog( WIN_TEST ,

  format(' RealPosData : %s, %s, %s,' +
         '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, ' +
         '%s, %s',[
    s1, s2, s3,
  s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20,
  s21, s22])
  );            }
end;

procedure TApiManager.axCommRecvRQData(ASender: TObject; var pstr: OleVariant);
var
  bDec  : boolean;
  iID, idx : integer;
begin

  try
    iID   := StrToIntDef( Trim(Copy(pstr, 2, 5)), 0 ) ;
    // 주문 응답
    if iID > REQ_MAX then
      gReceiver.ParseOrderAck( iID, pStr )
    else begin

      if not CheckError( pstr ) then
        Exit;
      bDec  := false;
      case iID of
        REQ_ACNT_LIST : gReceiver.ProcessAccountList;
        REQ_TICK_SIZE : gReceiver.ParseTickSize;
      end;

      case iID of
        REQ_POS_LIST,
        REQ_ACTIVE_ORD :
          begin
            dec( FSendQryCount );
            bDec  := true;
            case iID of
              REQ_POS_LIST: gReceiver.ParsePosition;
              REQ_ACTIVE_ORD: gReceiver.ParseActiveOrder;
            end;
          end ;
        else
          if iID <=  REQ_ACNT_DEPOSIT then
          begin
            dec( FSendQryCount );
            bDec := true;
            // 계좌번호 인덱스...이런 꼼수를 쓰는 이유는 --> 응답으로 계좌번호를 안준다.
            // 여러계좌 동시 조회시 어느계좌인지 알수가 없음..
            idx := iID mod REQ_ACNT_DEPOSIT;
            gReceiver.ParseDeposit( idx ); //** 예탁자산현황 조회
          end;
      end;
      if (bDec ) and (FSendQryCount <= 0) and ( not gEnv.RecoveryEnd ) then
      begin
        gLog.Add( lkApplication, '','' , Format('recv %d send cnt -> %d', [ iId, FSendQryCount])   );
        gEnv.SetAppStatus( asRecoveryEnd );
      end else
        gLog.Add( lkApplication, '','' , Format('recv %d send cnt -> %d', [ iId, FSendQryCount])   );
    end;
  except
    gEnv.EnvLog( WIN_TEST, 'axCommRecvRQData error : ' + pstr );
  end;

end;

procedure TApiManager.axCommReplyFileDown(ASender: TObject; sFileData: Integer);
begin

end;


procedure TApiManager.axCommReplyLogin(ASender: TObject; var pstr: OleVariant);
begin
  try
  gLogin.TryConnet  := false;
  if not CheckError( pstr ) then
    Exit;
  gLog.Add( lkApplication, '','', 'Login success');
  // 로긴컨트롤 visible = false 시키고
  gEnv.SetAppStatus( asConMaster );
  QryTimer.Enabled  := true;
  except
    //ShowMessage( pstr );
  end;
end;

procedure TApiManager.axCommXOnReplyConnect(ASender: TObject;
  var pstr: OleVariant);
begin
  try
    if not CheckError( pstr ) then
      Exit;
    gLog.Add( lkApplication, '','', 'Connected');

    except
    //ShowMessage( pstr );
  end;
end;

{$ENDREGION}

function TApiManager.CheckError(stData: string): boolean;
var
  bFailed: boolean;
  sIsError, sMessage : string;
begin
  Result := true;

  sIsError := Trim(Copy(stData, 1, 1));
  bFailed := (sIsError <> '1');// or (pstr = '접속 되었습니다.');

  if bFailed then
  begin
    sMessage := Trim(Copy(stData, 2, Length(stData) - 1));
    gLog.Add( lkError,'', '', sMessage) ;
    Result := false;
  end

end;

constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  FReady  := false;
  FApi := aObj as  TAlphaCommX;

  with FApi do
  begin
    OnRecvRQData := axCommRecvRQData;
    OnRecvRealData := axCommRecvRealData;
    OnReplyFileDown := axCommReplyFileDown;
    OnRecvRealOrdData := axCommRecvRealOrdData;
    OnCloseHost := axCommCloseHost;
    OnReceiveRealHoga := axCommReceiveRealHoga;
    OnReceRealChegyul := axCommReceRealChegyul;
    OnRecvRealPositoin := axCommRecvRealPositoin;

    OnReplyLogin      := axCommReplyLogin;
    OnReplyConnect    := axCommXOnReplyConnect;
  end;

  FQryList := TList.Create;
  FAutoQuoteList := TList.Create;;

  QryTimer  := TTimer.Create( nil );
  QryTimer.Interval := 50;
  QryTimer.Enabled  := false;
  QryTimer.OnTimer  := TimeProc;


  FAutoTimer  := TTimer.Create( nil );
  FAutoTimer.Interval := 200;
  FAutoTimer.Enabled  := false;
  FAutoTimer.OnTimer  := TimeProc2;

  for I := 0 to High( FQryCount ) do
    FQryCount[i]  := 0;

  FSendQryCount := 0;

end;

destructor TApiManager.Destroy;
begin
  QryTimer.Enabled  := false;
  QryTimer.Free;

  FAutoTimer.Enabled := false;
  FAutoTimer.Free;
  //Fin;
  FQryList.Free;
  FAutoQuoteList.Free;
  inherited;
end;


procedure TApiManager.Disconnect;
begin
  FApi.CloseHost;
end;

procedure TApiManager.DoLogIn(stID, stPW, stCert: string);
var
  userID, password, certPassword: OleVariant;
begin

  try
    if FReady then
      FApi.CloseHost;
  except
    ShowMessage('Dll 에러 발생 다시 접속해주세요');
    gLog.Add( lkError, '','','접속 시 Dll 에러 발생 다시 접속해주세요' );
    Exit;
  end;

  userID  := stID;
  password:= stPW;
  certPassword:= stCert;

  FApi.Login(userID, password, certPassword );

end;


procedure TApiManager.Fin;
begin
  FApi.CloseHost();;
 end;
function TApiManager.GetDataCount(var wmid: OleVariant): OleVariant;
begin
  Result := FApi.GetRowCount( wmid );
end;

function TApiManager.GetGridString(winID, flag, symbol: OleVariant; row: integer): string;
var
  idx: OleVariant;
begin
  idx := row;
  Result := FApi.GetGridData(winID, flag, symbol, idx);
end;

function TApiManager.GetDouble(winID, symbol: string): double;
begin
  Result := StrToFloatDef(GetString(winID, symbol), 0);
end;

function TApiManager.GetInt(winID, symbol: string): integer;
begin
  Result := StrToIntDef(GetString(winID, symbol), 0);
end;

function TApiManager.GetString(winID, symbol: OleVariant): string;
var
  flag: OleVariant;
  idx: OleVariant;
begin
  flag := '1';
  idx := 0;
  Result := FApi.GetSisedata(winID, flag, symbol, idx);
end;

function TApiManager.GetEncodePassword(aAccount: TAccount): string;
begin
  REsult := '';
  if ( not FReady ) or ( aAccount = nil ) then Exit;

end;

function TApiManager.GetRecoveryData: boolean;
var
  i : integer;
  aInvest : TInvestor;
  stData  : string;

begin
  Result := false;
  if not FReady then Exit;

end;

procedure TApiManager.PushRequest(strWinID, strFlag, strGtrCode, strTrCode, strLen,
  strData, strEncrypt: string);
var
  aItem : TSrvSendItem;
begin


  if StrToInt(strWinID) > REQ_MAX then
       // 주문만 바로 보내고..나머지 조회는 카운팅을 한당..
    RequestData( strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt )
  else begin

    aItem := TSrvSendItem.Create( nil );
    aItem.strWinID    := strWinID;
    aItem.strFlag     := strFlag;
    aItem.strGtrCode  := strGtrCode;
    aItem.strTrCode   := strTrCode;
    aItem.strLen      := strLen;
    aItem.strData     := strData;
    aItem.strEncrypt  := strEncrypt;

    FQryList.Insert(0, aItem );

    inc( FSendQryCount );
  end;
end;




procedure TApiManager.RequestAccountInfo;
begin

end;

function TApiManager.RequestData(strWinID, strFlag, strGtrCode, strTrCode, strLen,
  strData, strEncrypt: string) : boolean;
var
  winID: OleVariant;
  flag: OleVariant;
  gtrCode: OleVariant;
  trCode: OleVariant;
  len: OleVariant;
  data: OleVariant;
  encrypt: OleVariant;
begin
  winID := strWinID;
  flag := strFlag;
  gtrCode := strGtrCode;
  trCode := strTrCode;
  len := strLen;
  data := strData;
  encrypt := strEncrypt;

  try
     FApi.RequestData(winID, flag, gtrCode, trCode, len, data, encrypt);
     //FApi.RequestData( strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt);
     gEnv.EnvLog( WIN_TEST, Format('RequestData %s,%s(%s):%s,%s,%s,%s', [ strGtrCode, strTrCode,
      strLen,  strData, strWinID, strFlag, strEncrypt]) );
  except
    gEnv.EnvLog( WIN_TEST, Format('RequestData 에러 : %s,%s', [ strGtrCode, strTrCode]) );
  end;
end;


function TApiManager.ReqRealTimeOrder( bSet: boolean; stData: string): boolean;
begin
 if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  //Result := FApi.ESExpSetAutoUpdate( bSet, True, stData );

  if  Result  then
    gEnv.EnvLog( WIN_TEST, Format('계좌 자동 요청 성공 : %s', [ stData]) )
  else
    gEnv.EnvLog( WIN_TEST, Format('계좌 자동 요청 실패 : %s', [ stData]) );

end;

function TApiManager.ReqRealTimeQuote(bSet: boolean;  stData: string): boolean;
begin
 if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  //Result := FApi.ESExpSetAutoUpdate( bSet, false, stData );

  if Result  then
    gEnv.EnvLog( WIN_TEST, Format('시세 %s 성공 : %s', [ ifThenSTr( bSet, '구독','구독취소'), stData]) )
  else
    gEnv.EnvLog( WIN_TEST, Format('시세 %s 실패 : %s', [ ifThenSTr( bSet, '구독','구독취소'), stData]) );
end;


procedure TApiManager.TimeProc(Sender: TObject);
var
  aItem : TSrvSendItem;
  I, iCnt, idx : Integer;
begin

  if FQryList.Count <= 0 then  Exit;

  try
    iCnt := 0;
    for I := FQryList.Count - 1 downto 0 do
    begin

      aItem := TSrvSendItem(  FQryList.Items[i] );
      if aItem = nil then Continue;

      idx := ACCOUNT_QRY;

      if idx >= 0 then
        if FQryCount[idx] > MAX_CNT then
          break;

      with aItem do
        RequestData( strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt );

      if idx >= 0 then
        inc(FQryCount[idx]);

      FQryList.Delete(i);
      aItem.Free;
    end;

  finally
  end;
end;


procedure TApiManager.TimeProc2(Sender: TObject);
begin
  if gEnv.Engine.SymbolCore.SymbolLoader.ReqMonthSymbol then
    AutoTimer.Enabled := false;
end;

procedure TApiManager.UnRegistData(iWinID: integer);
var
  oWinID : OleVariant;
begin
  // 시세 구독 취소 처리
  oWinID := IntToStr(iWinID );
  FApi.UnRegistRealData( oWinID );
end;

end.

