unit CleApiManager;

interface

uses
  Classes, SysUtils, ExtCtrls, Windows,

  CleQuoteBroker, CleApiReceiver, ApiConsts,

  CleAccounts,  DateUtils,

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
    ReqDiv : integer;
    Data   : string;
    pData  : PChar;
    Key    : string;
    Cnt    : integer;
    Index  : integer;

    Constructor Create( aColl : TCollection ) ; overload;
  end;

  TSrvSendItems = class( TCollection )
  private
    FReqCount: integer;
    FApiType: TApiEventType;
    FLastTime: TDateTime;
  public
    Constructor Create( aType : TApiEventType); overload;
    Destructor  Destroy; override;

    function New( reqDiv : integer ) : TSrvSendItem;
    // 동일 tran 에 대해서 200 이라고 해놓고선  
    // 1초에  

    property ReqCount : integer read FReqCount write FReqCount;
    property ApiType  : TApiEventType read FApiType;
    
  end;


  TApiManager = class
  private
    FParent : TObject;
    FReady: boolean;
    FOnData: TTextNotifyEvent;

    FAutoTimer: TTimer;

    FSendQryCount: integer;
    FRecevier: TApiReceiver;
    FHanaDll : THandle;
    FAcntTimer: TTimer;
    FLastSendTime : TDateTime;
    procedure SendRequest(aItem: TSrvSendItem; aType : TApiEventType);

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

    SendItems : array [TApiEventType] of TSrvSendItems;

    Constructor Create( aObj : TObject ); overload;
    Destructor  Destroy; override;

    function DoLogIn( stID, stPW, stCert : string ; iMode : integer ) : integer;
    function init : boolean;
    procedure Fin;

    procedure RequestAccountInfo;
    procedure RequestMaster;

    procedure TimeProc( Sender : TObject );
    procedure TimeProc2( Sender : TObject );
    procedure PushData(iDiv : integer; aType : TApiEventType; iCnt: integer; stData: string ); overload;
    procedure PushData(iDiv : integer; aType : TApiEventType; iCnt: integer; aData : Pchar ); overload;

    function GetQCount : integer;
    function IsRequest( aType : TApiEventType ) : boolean;

    property Recevier : TApiReceiver read FRecevier;
    property Ready : boolean read FReady ;//write FReady;
    property OnData: TTextNotifyEvent read FOnData write FOnData;

    property AutoTimer: Ttimer read FAutoTimer write FAutoTimer;
    property AcntTimer: TTimer read FAcntTimer write FAcntTimer;    

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
  I: TApiEventType;
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

  FAcntTimer  := TTimer.Create( aObj as TComponent );
  FAcntTimer.Interval := 100;
  FAcntTimer.Enabled  := false;
  FAcntTimer.OnTimer  := TimeProc;

  FLastSendTime := now;

  for I := rtNone to High( TApiEventType) do
    SendItems[i] := TSrvSendItems.Create( i);

end;

destructor TApiManager.Destroy;
var
  I: TApiEventType;
begin
  for I := rtNone to High( TApiEventType) do
    SendItems[i].Free;

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


function TApiManager.GetQCount: integer;
var
  I: TApiEventType;
begin
  Result := 0;
  for I := rtNone to High( TApiEventType) do
    Result := Result + SendItems[i].Count;
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



function TApiManager.IsRequest(aType: TApiEventType): boolean;
begin
  if SendItems[aType].ReqCount >= 50 then
    Result := false
  else
    Result := true;
end;

procedure TApiManager.PushData(iDiv: integer; aType: TApiEventType;
  iCnt: integer; aData: Pchar);
var
  aItem : TSrvSendItem;
begin

  aItem := SendITems[aType].New(iDiv);
  aItem.pData := aData;
  aItem.Cnt   := iCnt;

  gEnv.EnvLog( WIN_TEST,  Format('pushData - type : %s, %s', [
    ApieEventName[ aType], aData ]) );

end;

procedure TApiManager.PushData(iDiv : integer; aType : TApiEventType; iCnt: integer; stData: string);
var
  aItem : TSrvSendItem;
begin

  aItem := SendITems[aType].New(iDiv);
  aItem.Data  := stData;
  aItem.Cnt   := iCnt;

  gEnv.EnvLog( WIN_TEST,  Format('pushData (%d) - type : %s, %s', [  SendITems[aType].ReqCount,
    ApieEventName[ aType], stData ]) );

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
var
  i : TApiEventType;
  j, iGap : integer;
  aItem : TSrvSendItem; 
begin                

  iGap := MilliSecondsBetween( now, FLastSendTime );

  if iGap > 200 then  

  for i := rtAcntList to High( TApiEventType) do
  begin
    for j :=SendItems[i].Count-1 downto 0 do begin
      //aItem := SendItems[i].Pop(j);
      //if aItem = nil then break

      aItem := TSrvSendItem( SendItems[i].Items[j] );
      if aItem = nil then Continue      
      else begin        
        SendRequest( aItem, SendItems[i].ApiType );        
        SendItems[i].Delete(j);
        Exit;
      end;
    end;
  end;
  

end;

procedure TApiManager.SendRequest( aItem : TSrvSendItem; aType : TApiEventType );
begin
    
  gEnv.EnvLog( WIN_TEST,  Format('SendData - type : %s, %s', [
    ApieEventName[ aType], Copy(aItem.Data, 1, 20 ) ]) );
    
  aRequestData( aItem.ReqDiv, integer( aType ), aItem.Cnt, PChar(aItem.Data) );

  FLastSendTime := now;
end;


procedure TApiManager.TimeProc2(Sender: TObject);
begin

end;

{ TSrvSendItem }

constructor TSrvSendItem.Create(aColl: TCollection);
begin
  ReqDiv := 1;
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

{ TSrvSendItems }

constructor TSrvSendItems.Create( aType : TApiEventType );
begin
  inherited Create( TSrvSendItem );
  FApiType  := aType;
  FReqCount := 0;
end;

destructor TSrvSendItems.Destroy;
begin

  inherited;
end;

function TSrvSendItems.New(reqDiv : integer): TSrvSendItem;
begin
  Result := Insert(0) as TSrvSendItem;
  Result.ReqDiv := reqDiv;

  inc(FReqCount);
end;



end.
