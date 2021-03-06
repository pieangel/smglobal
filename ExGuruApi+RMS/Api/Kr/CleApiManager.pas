unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,

  ESApiExpLib_TLB,  CleQuoteTimers, ApiPacket,

  GleTypes
  ;

//{$INCLUDE define.txt}

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
    TrCode : integer;
    Data   : string;
    Key    : string;
    Size   : integer;
    Index  : integer;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  TApiManager = class
  private
    FApi: TESApiExp;
    FReady: boolean;
    FOnData: TTextNotifyEvent;
    FQryList : TList;
    FAutoQuoteList : TList;
    FQryTimer: TTimer;
    FAutoTimer: TTimer;

    FQryCount : array [0..QRY_CNT-1] of integer;
    FLoadStats: TLoadStatsType;
    FSendQryCount: integer;
    FRecevier: TApiReceiver;

    procedure OnESExpServerConnect(ASender: TObject; nErrCode: Smallint;
                                                            const strMessage: WideString);
    procedure OnESExpServerDisConnect(Sender: TObject);

    procedure ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
                                                       const szRecvData: WideString);
    procedure ESApiExpESExpAcctList(ASender: TObject; nListCount: Smallint;
                                                       const szAcctData: WideString);
    procedure ESApiExpESExpCodeList(ASender: TObject; nListCount: Smallint;
                                                       const szCodeData: WideString);

    function GetRecoveryData: boolean;
  public
    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;
    procedure Fin;

    procedure RequestAccountInfo;

    function GetEncodePassword( aAccount : TAccount ) : string;
    function GetErrorMessage( iRes : integer ) : string;

    procedure RequestMaster( stCode, stIndex : string; iTag : integer );
    procedure PushRequest( iTrCode : integer; stData : string; iSize : integer );
    function  RequestData(iTrCode: integer; stReqData: string; iSize : integer ) : integer;
    function  ReqRealTimeQuote(  bSet : boolean; stData : string ) : integer;
    function  ReqRealTimeOrder(  bSet : boolean; stData : string ) : integer;

    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );

    property Api: TESApiExp read FApi;
    property Recevier : TApiReceiver read FRecevier;
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
  GAppEnv, GleLib , SynthUtil,  Dialogs,
  FOrpMain,
  Math
  ;

{ TApiManager }

constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  FReady  := false;
  FApi := aObj as  TESApiExp;

  FApi.OnESExpRecvData  :=  ESApiExpESExpRecvData;
  FApi.OnESExpAcctList  :=  ESApiExpESExpAcctList;
  FApi.OnESExpCodeList  :=  ESApiExpESExpCodeList;

  FApi.OnESExpServerConnect := OnESExpServerConnect;
  FApi.OnESExpServerDisConnect  := OnESExpServerDisConnect;

  FRecevier:= TApiReceiver.Create;

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

  FRecevier.Free;
  inherited;
end;


function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : integer ;
var
  iRes : integer;
  stDir: string;
  bRes : boolean;

  wstID, wstPW, wstCert: widestring;
begin

  Result := 0;

  try
    if FApi.ESExpIsServerConnect then
    begin
      //ShowMessage('접속 !!!');
      FApi.ESExpDisConnectServer;
    end;
  except
    ShowMessage('Dll 에러 발생 다시 접속해주세요');
    gLog.Add( lkError, '','','접속 시 Dll 에러 발생 다시 접속해주세요' );
    Exit;
  end;

  stDir := ExtractFilePath( paramstr(0) );
  FApi.ESExpApiFilePath(stDir);

  try
    if gEnv.UserType = utStaff then
      bRes := FApi.ESExpSetUseStaffMode( true )
    else
      bRes := true;

    if not bRes then
    begin
      ShowMessage('staff 접근 거부');
      gEnv.EnvLog( WIN_ERR, Format('Staff 접근 거부 : %s, %s, %s, %d', [
          stID, stPW, stCert, iMode ]));
      Exit;
    end;

  except
    ShowMessage('staff 접근 에러');
      gEnv.EnvLog( WIN_ERR, Format('Staff 접근 에러 : %s, %s, %s, %d', [
          stID, stPW, stCert, iMode ]));
    Exit;
  end;
  gLog.Add( lkApplication, '','',  Format('로그인시도 : %s, %s, %s, %d', [
    stID, stPW, stCert, iMode  ])
     )     ;
  wstID := stID;
  wstPW := stPW;
  wstCert := stCert;

  Result  :=  FApi.ESExpConnectServer( wstID, wstPW, wstCert, iMode);

end;

procedure TApiManager.ESApiExpESExpAcctList(ASender: TObject;
  nListCount: Smallint; const szAcctData: WideString);
  var
    i, iStart : Integer;
    stData, stSub : string;
    pData : POutAccountInfo;
begin

  stData  := szAcctData;

  for I := 0 to nListCount - 1 do
  begin
    iStart:= i * Len_AccountInfo + 1;
    stSub := Copy( stData, iStart, Len_AccountInfo );
    pData := POutAccountInfo( stSub );
    gEnv.Engine.TradeCore.Investors.New( trim( string( pData.Code )),
         trim( string( pData.Name )),
         trim( string( pData.Pass))  );
    //gEnv.Engine.TradeCore.CheckVirAccount;
  end;

  gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpAcctList',
    Format('계좌 : %d, %s', [ nListCount, szAcctData ])) ;

end;

procedure TApiManager.ESApiExpESExpCodeList(ASender: TObject;
  nListCount: Smallint; const szCodeData: WideString);
begin
  if ( nListCount > 0 ) and ( szCodeData <> '' ) then
  begin
    gEnv.Engine.SymbolCore.SymbolLoader.ImportSymbolListFromApi(nListCount, szCodeData );
    //gEnv.EnvLog( WIN_GI,  Format('%d 개의 종목리스트 수신', [ nListCount])  );

    gLog.Add( lkApplication, 'TApiManager', 'ESApiExpESExpCodeList',
        Format('%d 개의 종목리스트 수신', [ nListCount])
        ) ;
  end;


end;

procedure TApiManager.ESApiExpESExpRecvData(ASender: TObject; nTrCode: Smallint;
  const szRecvData: WideString);
begin
  try
  case nTrCode of

    ESID_5601 ,
    ESID_5602 ,
    ESID_5603 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d,%139.139s', [ nTrCode, szRecvData]));
        gReceiver.ParseOrderAck( nTrCode, szRecvData);
      end;
    ESID_5501,
    ESID_5502,
    ESID_5503 :
      begin
        gEnv.EnvLog( WIN_GI, Format('%d,%139.139s', [ nTrCode, szRecvData]));
        FQryCount[SYMBOL_QRY] := Max( 0, FQryCount[SYMBOL_QRY] -1 );
        dec( FSendQryCount );
        case nTrCode of
          ESID_5501 : gEnv.Engine.SymbolCore.SymbolLoader.ImportMasterFromKrApi( szRecvData );
          ESID_5502 : gReceiver.ParseMarketPrice( szRecvData );
          ESID_5503 : gReceiver.ParseReqHoga( szRecvData );  	// 종목 호가 실시간
        end;

        if (FSendQryCount <= 5) and ( not gEnv.RecoveryEnd ) then
          gEnv.SetAppStatus( asRecoveryStart );
      end;
    ESID_5522 :  gReceiver.ParseChartData( szRecvData );



    ESID_5611 ,  // 실체결
    ESID_5612,	 // 실잔고
    ESID_5614,	 // 계좌별 주문체결현황
    ESID_5615 :  // 예탁자산및 증거금
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d:%s', [ nTrCode, szRecvData])  );
        dec( FSendQryCount );
        FQryCount[ACCOUNT_QRY] := Max( 0, FQryCount[ACCOUNT_QRY]-1 );

        case nTrCode of
          ESID_5611 : gReceiver.ParseActiveOrder( szRecvData );
          ESID_5612 : gReceiver.ParsePosition(szRecvData);
          ESID_5615 : gReceiver.ParseDeposit( szRecvData );
        end;

        if (FSendQryCount <= 0) and ( not gEnv.RecoveryEnd ) then
          gEnv.SetAppStatus( asRecoveryEnd );
      end;
    ESID_5633 : gReceiver.ParseAbleQty( szRecvData );

    AUTO_0932 : gReceiver.ParseHoga( szRecvData );  	// 종목 호가 실시간
    AUTO_0933	: gReceiver.ParsePrice( szRecvData );   //  종목 시세 실시간
    AUTO_0985 :
      begin
        gEnv.EnvLog( WIN_PACKET, Format('%d,%139.139s', [ nTrCode, szRecvData]));
        gReceiver.ParseOrder( szRecvData);
      end;
  end;

  except
    ShowMessage( 'error : ' + szRecvData );
  end;
end;


procedure TApiManager.Fin;
begin
  if (FApi.ESExpIsServerConnect) then
    FApi.ESExpDisConnectServer;
 end;
function TApiManager.GetEncodePassword(aAccount: TAccount): string;
begin
  REsult := '';
  if ( not FReady ) or ( aAccount = nil ) then Exit;

  //if gEnv.UserType = utNormal then
    Result := FApi.ESExpGetEncodePassword( aAccount.Code, aAccount.PassWord );
  //else
   // Result := aAccount.PassWord;

end;

function TApiManager.GetErrorMessage(iRes: integer): string;
begin
  Result := '';
  case TResultType( iRes ) of
    rtNone          : Result := '정상';
    rtAutokey       : Result := '계좌 자동업데이트 key 미입력';
    rtUserID        : Result := '접속 아이디 미입력';
    rtUserPass      : Result := '접속 비밀번호 미입력';
    rtCertPass      : REsult := '공인인증 비밀번호 미 입력';
    rtSvrSendData   : Result := '서버 전송 오류';
    rtSvrConnect    : Result := '서버 접속 상태';
    rtSvrNoConnect  : Result := '서버 접속 오류';
    rtCerTest       : Result := '인증 데이터 가져오기 실패';
    rtDllNoExist    : Result := 'signkorea dll 파일경로';
    rtTrCode        : Result := '허용되지 않은 TR번호';
  end;
end;

function TApiManager.GetRecoveryData: boolean;
var
  i : integer;
  aInvest : TInvestor;
  stData  : string;

begin
  Result := false;
  if not FReady then Exit;
  {
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    stData  := Format('%11.11s%8.8s',  [ aInvest.Code, '4983    ']);//aInvest.PassWord ]);
    //stData  := Format('%11.11s%8.8s',  [ aInvest.Code, '1004    ']);//aInvest.PassWord ]);
    //iRes := FApi.ESASvrSend( REQ_ACNT_POS,  '200', 'pos',  stData, Length( stData ) );
    PushRequest( REQ_ACNT_POS, '0', 'pos'+aInvest.Code, stData ) ;

  end;

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    stData  := Format('0%11.11s%8.8s%8.8s%8.8s%s%s',  [ aInvest.Code, '1004    ',
    //stData  := Format('0%11.11s%8.8s%8.8s%8.8s%s%s',  [ aInvest.Code, '4983    ',
        FormatDateTime('yyyymmdd', date ), FormatDateTime('yyyymmdd', date ),
        '0','1'
        ]);
    PushRequest( REQ_ACNT_TRADE, '0', 'p'+intToStr(i), stData ) ;
  end;


  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    //stData  := Format('%11.11s%8.8s%s%s%8.8s%s',  [ aInvest.Code, '4983    ','0','2',
    stData  := Format('%11.11s%8.8s%s%s%8.8s%s',  [ aInvest.Code, '1004    ','0','0',
      FormatDateTime('yyyymmdd', date ), '1' ]);//aInvest.PassWord ]);
    PushRequest( REQ_ORDER_LIST, '0', 'o'+IntToStr(i), stData );
  end;

  Result := true;
     }
end;

procedure TApiManager.OnESExpServerConnect(ASender: TObject; nErrCode: Smallint;
                                                            const strMessage: WideString);
var
  rtValue : TResultType;
begin
  //ShowMessage( Format('접속결과(%d) : %s' , [ nErrCode,  strMessage]) );

  //gEnv.EnvLog( WIN_TEST, Format('%d %s',[ nErrCode, strMessage]) );
  rtValue := TResultType( nErrCode );

  if rtValue in [ rtNone] then
  begin
    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('접속성공 %d %s',[ nErrCode, strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, Format('%d %s',[ nErrCode, strMessage]) );

    FReady := true;
    gEnv.SetAppStatus( asConMaster );
    QryTimer.Enabled  := true;
  end else
  begin
    ShowMessage( Format('접속에러(%d) : %s' , [ nErrCode,  strMessage]) );
    gLog.Add( lkApplication, 'TApiManager', 'DoInit', Format('접속에러(%d) : %s' , [ nErrCode,  strMessage]) ) ;
    gEnv.EnvLog( WIN_TEST, strMessage);
  end;
end;

procedure TApiManager.OnESExpServerDisConnect(Sender: TObject);
var
  stTmp : string;
  iRes  : integer;
begin
  FReady := false;
  gLog.Add( lkApplication, 'TApiManager', 'DoInit', '접속 종료' );
  gEnv.EnvLog( WIN_TEST, '접속 종료');  

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



procedure TApiManager.PushRequest(iTrCode : integer; stData : string; iSize : integer);
var
  aItem : TSrvSendItem;
begin

  case iTrCode of
    ESID_5601 ,
    ESID_5602 ,   // 주문만 바로 보내고..나머지 조회는 카운팅을 한당..
    ESID_5603 : RequestData( iTrCode, stData, iSize );
    AUTO_0933 :
      begin
        aItem := TSrvSendItem.Create( nil );
        aItem.TrCode  := iTrCode;
        aItem.Data    := stData;
        aItem.Size    := iSize;
        FAutoQuoteList.Insert(0, aItem );
      end
    else
      begin
        aItem := TSrvSendItem.Create( nil );
        aItem.TrCode  := iTrCode;
        aItem.Data    := stData;
        aItem.Size    := iSize;
        FQryList.Insert(0, aItem );

        inc( FSendQryCount );
      end;
  end;
end;




procedure TApiManager.RequestAccountInfo;
begin

end;

function TApiManager.RequestData(iTrCode: integer; stReqData: string; iSize : integer): integer;
begin
  if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  try
    Result := FApi.ESExpSendTrData( iTrCode, stReqData, iSize);
    if Result <> 0  then{
      gEnv.EnvLog( WIN_TEST, Format('%d 요청 성공 : %s', [ iTrCode, stReqData]) )
    else                }
      gEnv.EnvLog( WIN_TEST, Format('%d 요청 실패 : %d %s', [ iTrCode, Result, stReqData]) );
  except
    Result := -1;
    gEnv.EnvLog( WIN_TEST, Format('%d 요청 에러 : %s', [ iTrCode,stReqData]) );
  end;
end;


function TApiManager.ReqRealTimeOrder( bSet: boolean; stData: string): integer;
begin
 if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  Result := FApi.ESExpSetAutoUpdate( bSet, True, stData );

  if  Result = 0 then
    gEnv.EnvLog( WIN_TEST, Format('계좌 자동 요청 성공 : %s', [ stData]) )
  else
    gEnv.EnvLog( WIN_TEST, Format('계좌 자동 요청 실패 : %s', [ stData]) );

end;

function TApiManager.ReqRealTimeQuote(bSet: boolean;  stData: string): integer;
begin
 if not FReady then
  begin
    gEnv.ErrString := '접속이 끊겼음';
    gEnv.SetAppStatus( asError );
    Exit;
  end;

  Result := FApi.ESExpSetAutoUpdate( bSet, false, stData );

  if Result = 0 then
    gEnv.EnvLog( WIN_TEST, Format('시세 %s 성공 : %s', [ ifThenSTr( bSet, '구독','구독취소'), stData]) )
  else
    gEnv.EnvLog( WIN_TEST, Format('시세 %s 실패 : %s', [ ifThenSTr( bSet, '구독','구독취소'), stData]) );
end;


procedure TApiManager.RequestMaster(stCode, stIndex: string; iTag : integer );
var
  Buffer  : array of char;
  aData   : PReqSymbolMaster;
  //aData   : PSendAutoKey;
  stData  : string;

begin
  SetLength( Buffer , Sizeof( TReqSymbolMaster ));
  FillChar( Buffer[0], Sizeof( TReqSymbolMaster), ' ' );

  aData   := PReqSymbolMaster( Buffer );
  // - 를 붙여 앞으로 정렬
  MovePacket( Format('%-10.10d', [ iTag ]),  aData.header.WindowID );
  MovePacket( Format('%-32.32s', [ stCode ]), aData.FullCode );
  MovePacket( Format('%4.4s',   [ stIndex]), aData.Index );

  SetString( stData, PChar(@Buffer[0]), Sizeof( TReqSymbolMaster ) );
  PushRequest( ESID_5501, stData,  Sizeof( TReqSymbolMaster ));

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

      idx := -1;
      case aItem.TrCode of
        ESID_5501, ESID_5502, ESID_5503 : idx :=  SYMBOL_QRY;
        ESID_5611,   // 실체결
        ESID_5612,	 // 실잔고
        ESID_5614,	 // 계좌별 주문체결현황
        ESID_5615 :  idx := ACCOUNT_QRY; // 예탁자산및 증거금
      end;

      if idx >= 0 then
        if FQryCount[idx] > MAX_CNT then
          break;

      RequestData( aItem.TrCode, aItem.Data, aitem.Size );

      if idx >= 0 then
        inc(FQryCount[idx]);

      FQryList.Delete(i);
      aItem.Free;
    end;

  finally
  end;

end;


procedure TApiManager.TimeProc2(Sender: TObject);
var
  aItem : TSrvSendItem;
  I, iCnt, idx : Integer;
begin

  if FAutoQuoteList.Count <= 0 then  Exit;

  try
    iCnt := 0;
    for I := FAutoQuoteList.Count - 1 downto 0 do
    begin

      aItem := TSrvSendItem(  FAutoQuoteList.Items[i] );
      if aItem = nil then Continue;

      if iCnt >= MAX_CNT2 then
        break;

      ReqRealTimeQuote( true, aItem.Data );

      FAutoQuoteList.Delete(i);
      aItem.Free;
      inc( iCnt );
    end;

  except
  end;

end;

{ TSrvSendItem }

constructor TSrvSendItem.Create(aColl: TCollection);
begin
  TrCode := -1;
  Data   := '';
  Index  := - 1;
  Key    := '';
end;

end.
