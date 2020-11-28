unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,

  CleQuoteTimers, ApiPacket,

  GleTypes
  ;

//{$INCLUDE define.txt}

const
  TRAN_IDX = 0;
  REAL_IDX = 1;


type

  TSrvSendItem = class( TCollectionItem )
  public
    TrCode : integer;
    Data   : string;
    Key    : string;
    Size   : integer;
    Index  : integer;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  THanaBuffer = record
    Tmp : array [0..49] of char;
  end;

  TApiManager = class
  private
    FReady: boolean;
    FOnData: TTextNotifyEvent;

    FAutoTimer: TTimer;

    FSendQryCount: integer;
    FRecevier: TApiReceiver;
    FHanaDll : THandle;

  public

    ProcesState : integer;
    aLogin    : pLogin;
    aLogOut   : pLogOut;

    aCallBack : pRegisterCallBack;
    aInitXLap : pInitXLap;

    aRequestOrder : pRequestOrder;
    aRequestData : pRequestData;
    aRegisterReal:pRegisterReal;
    aGetRequestCount:pGetRequestCount;

    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;
    function init : boolean;
    procedure Fin;

    procedure RequestAccountInfo;
    procedure RequestMaster;

    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );

    property Recevier : TApiReceiver read FRecevier;
    property Ready : boolean read FReady ;//write FReady;
    property OnData: TTextNotifyEvent read FOnData write FOnData;

    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;

    // counting
    property SendQryCount : integer read FSendQryCount;

  end;

  procedure OnCallBackHanaEvent( iType, iTag, iSize : integer; pData : PChar); cdecl;
  procedure OnCallBackHanaLog( iType : integer; pData:  PChar); cdecl;


implementation

uses
  GAppEnv, GleLib , SynthUtil,  Dialogs,
  FOrpMain, CleIni,
  Math
  ;

{ TApiManager }

constructor TApiManager.Create(aObj: TObject);
var
  I: Integer;
begin
  FReady  := false;

  FHanaDll := LoadLibrary(DLL_NAME);

  if FHanaDll <= 0 then
  begin
    gLog.Add(lkError,'','',Format('%s Load Failed', [ DLL_NAme ])  );
    exit;
  end;

  ProcesState := 0;

  @aLogin :=  GetProcAddress(FHanaDll, PChar(DLL_LOGIN));
  if @aLogin = nil then Exit;

  @aLogOut  :=GetProcAddress(FHanaDll, PChar(DLL_LOGOUT));
  if @aLogOut = nil then Exit;

  @aCallBack := GetProcAddress(FHanaDll, PChar(DLL_REGI_CALLBACK));
  if @aCallBack = nil then Exit;

  @aInitXLap := GetProcAddress(FHanaDll, PChar(DLL_INIT));
  if @aInitXLap = nil then Exit;

  @aRequestOrder := GetProcAddress(FHanaDll, PChar(DLL_ORDER));
  if @aRequestOrder = nil then Exit;

  @aRequestData := GetProcAddress(FHanaDll, PChar(DLL_REQUEST));
  if @aRequestData = nil then Exit;

  @aRegisterReal := GetProcAddress(FHanaDll, PChar(DLL_REG_REAL));
  if @aRegisterReal = nil then Exit;

  @aGetRequestCount := GetProcAddress(FHanaDll, PChar(DLL_GET_CNT));
  if @aGetRequestCount = nil then Exit;


  {
  FApi := aObj as  THFCommAgent;

  FApi.OnGetTranData  := HFCommAgentOnGetTranData;
  FApi.OnGetFidData   := HFCommAgentOnGetFidData;
  FApi.OnGetRealData  := HFCommAgentOnGetRealData;
  }
  FRecevier:= TApiReceiver.Create;
    {
  FAutoTimer  := TTimer.Create( FApi.Parent );
  FAutoTimer.Interval := 1000;
  FAutoTimer.Enabled  := false;
  FAutoTimer.OnTimer  := TimeProc;
    }

end;

destructor TApiManager.Destroy;
begin
  if FHanaDll > 0 then
    FreeLibrary( FHanaDll );
  FRecevier.Free;
  inherited;
end;


function TApiManager.DoLogIn(stID, stPW, stCert: string; iMode: integer) : integer ;
var
  iLen   : integer;
  pData  : TSignM;
  stMode : string;
begin

  iLen  :=  sizeof( TSignM);
  FillChar( pData, iLen , ' ');

  move( stID[1], pData.user, sizeof( pData.user ));
  move( stPW[1], pData.pass, sizeof( pData.pass ));
  if iMode = 0 then
    move( stCert[1], pData.cpas, sizeof( pData.cpas));

  case iMode of
    0 : stMode := '실거래';
    1 : stMode := '국내';
    2 : stMode := '모의';
  end;

  Result := aLogin( @pData, iMode );

  if Result < 0 then
    gLog.Add( lkError, '','', Format('로그인에러 %s %s', [ stID, stMode ]) )
  else begin
    gLog.Add( lkApplication, '','', Format('로그인성공 %s %s', [ stID, stMode ]) );
    gEnv.SetAppStatus( asConMaster );
  end;

end;

procedure TApiManager.Fin;
begin

end;


function TApiManager.init: boolean;
var
  iRes : integer;
  pData: PChar;
  stData : widestring;
  I: Integer;
begin
  Result := false;

  aCallBack( OnCallBackHanaEvent,  OnCallBackHanaLog );
  if aInitXLap >= 0 then begin
    Result := true;
    FReady := true;
  end
  else begin
    gLog.Add( lkError, '','init', 'DLL 초기화 실패');
    gEnv.ErrString  := 'Dll 초기화 실패 재설치 하세요';
    gEnv.SetAppStatus( asError );
  end;

end;



procedure TApiManager.RequestAccountInfo;
begin

  if gEnv.ConConfig.RealMode then
    aRequestData( TRD, integer(rtAcntList), 0, nil )
  else
    aRequestData( TRD, integer(rtDemoList), 0, nil )

end;


procedure TApiManager.RequestMaster;
begin
  aRequestData( FID, integer(rtSymbolMaster), 0, nil );
end;


procedure TApiManager.TimeProc(Sender: TObject);
begin
end;


procedure TApiManager.TimeProc2(Sender: TObject);
begin

end;

{ TSrvSendItem }

constructor TSrvSendItem.Create(aColl: TCollection);
begin
  TrCode := -1;
  Data   := '';
  Index  := - 1;
  Key    := '';
end;


procedure OnCallBackHanaEvent( iType, iTag, iSize : integer; pData : PChar);
var
  aType : TApiEventType;
  stData : string;
begin

  aType :=  TApiEventType( iType );

  if not (aType in [ rtQuote, rtSymbolMaster, rtSymbolInfo, rtDeposit ]) then
    if aType = rtOrder then begin
      SetString( stData, pData, iSize );
      gLog.Add( lkDebug, '','OnCallBackHanaEvent', Format( '%s,%d,%d:%s', [
        ApieEventName[aType], iTag, iSize, stData ])   )
    end
    else
      gLog.Add( lkDebug, '','OnCallBackHanaEvent', Format( '%s,%d,%d:%s', [
        ApieEventName[aType], iTag, iSize, pData ])   );

  case  aType  of
		rtAcntList ,
		rtDemoList : gReceiver.ParseAccount( pData ) ;
		rtAcntPos  : gReceiver.ParsePosition( iTag, iSize, pData );
		rtActiveOrd: gReceiver.ParseActiveOrder( iTag, iSize, pData ) ;
		rtDeposit  : gReceiver.ParseDeposit( iTag, iSize, pData ) ;
		rtSymbolMaster :
        if iTag = END_EVENT then
          gEnv.SetAppStatus( asRecoveryStart)
        else
          gEnv.Engine.SymbolCore.SymbolLoader.ImportSymbolMasterFromApi( iSize, pData);
    rtSymbolInfo : gReceiver.ParseReqHoga( iSize, pData);
    rtQuote :
      if iTag = QTE_HOGA then
        gReceiver.ParseHoga( iSize, pData)
      else
        gReceiver.ParsePrice( iSize, pData);
    rtOrderAck : gReceiver.ParseOrderAck( iSize, pData);
    rtOrder    :
      if iTag = ORD_ACPT then
        gReceiver.ParseOrder( iSize, pData )
      else if iTag = ORD_FILL then
        gReceiver.ParseOrderFill( iSize, pData);
    rtNotice   : gReceiver.ParseNotice( iTag, iSize, pData );
  end;

end;


procedure OnCallBackHanaLog( iType : integer; pData:  PChar);
var
  aType : TLogKind;
begin
  if gLog <> nil then
  case iType of
    ERR : aType := lkError;
    INF : aType := lkApplication;
    DEG : exit;// aType := lkDebug;
    //CMF : aType := lkError;
    else exit;
  end;
  gLog.Add( aType, '','CallBackHanaLog', pData);
end;

end.
