unit CleTradeIF;

interface

//{$define MzMemArea }
{$define SMMemArea }

uses
  Classes, SysUtils, Windows, IniFiles, mmsystem, Dialogs, WinSock,ScktComp,SyncObjs,

    // Lemon: Common
  GleLib, NextGenKospiPacket, {TOP2ServerPacket,} KrFutPacket,
    // lemon: data
  CleAccounts, CleSymbols, CleOrders, CleFills, ClePositions,
    // Lemon: Utils
  CleParsers, GleConsts, GleTypes, SynthUtil
    // App: common

  ;

const
  // send/rev constant
  FILL_BUF_SIZE = 1024 * 100;
  TYPE_SEND     = 0;
  TYPE_RECEIVE  = 1;
  TimeGap       = 7;
  TRY_CNT       = 5;

type

  TSocketThread = class( TThread )
  private
    FEvent: TEvent;

    FData, FData2: POrderPacket;

    FPort: integer;
    FSocket: TClientSocket;
    FRcvCnt: integer;
    FSocketState: TSocketState;

    FSockDiv : integer;  //   1 : order  2 : recv  3 : fill   4 : recovery

    FSocketPort: integer;
    FSocketAddress: string;

    FOnLog: TTextNotifyEvent;

    FLiveTime: TDateTime;
    FConnectTry : integer;
    FApType: string;

    procedure SetSockIndex(const Value: integer);
    procedure OnSocketState(ssValue: TSocketState);
    procedure SetPort(const Value: integer);


  protected
    procedure Execute ; override;
    procedure SyncProc;

  public
    FSendMutex    : array [TYPE_SEND..TYPE_RECEIVE] of HWND;
    FReceiveMutex : array [TYPE_SEND..TYPE_RECEIVE] of HWND;
    FSocketMute   : HWND;
    FQueue        : array [TYPE_SEND..TYPE_RECEIVE] of TList;
    FRcvBuf       : array [0..FILL_BUF_SIZE] of char;
    FClientSn     : integer;
    FFEpSn        : integer;

    FCount : integer; // 재접속 회수
    FHeader: TKrCommonHead;

    constructor Create( iSockType : Integer);
    destructor Destroy; override;

    procedure OnConnect(Sender: TObject; aSocket: TCustomWinSocket) ;
    procedure OnRead(Sender: TObject; aSocket: TCustomWinSocket) ;
    procedure OnDisConnect(Sender: TObject; Socket: TCustomWinSocket) ;
    procedure OnError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer) ;

    function SocketSendBuff(Buf: PChar; iSize: Integer): Boolean;
    function SocketConnect : boolean;

    procedure RequestPort( iSocket : integer );
    procedure RequestLink;
    procedure SetConInfo( stIP : string; iPort : integer );

    function MakeHeader(iSize: integer; stTR: string): TKrCommonHead;

    procedure initHeader;
    procedure SocketDisconnect;

    procedure PushQueue(iType, Size: Integer; Packet: PChar);
    function PopQueue(iType: Integer): POrderPacket;
    procedure DoLog(stLog: String);
    procedure ProcessTradePacket(szPacket: PChar; iSize: Integer; iSockDiv : integer);

    function SendTrade(iSize : integer; pData: PChar): boolean;

    function IsOpen: boolean;
    function SendCheckTimer: boolean;
    function GetApType( idx : integer ) : string;

    property SockDiv  : integer read FSockDiv write SetSockIndex;
    property Port     : integer read FPort write SetPort;
    property Socket   : TClientSocket read FSocket;
    property RcvCnt  : integer read FRcvCnt write FRcvCnt;

    property SocketAddress : string read FSocketAddress;
    property SocketPort : integer read FSocketPort;
    property ApType : string read FApType;

    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;

    property LiveTime: TDateTime read FLiveTime write FLiveTime;

    property SocketState : TSocketState read FSocketState write OnSocketState;
    property ConnectTry : integer read FConnectTry write FConnectTry;
  end;

implementation

uses Forms, DateUtils, CleFQN, math, CleKRXTradeReceiver, GAppEnv;

{ TSocketThread }

constructor TSocketThread.Create( iSockType : Integer );
var ivar : integer;     stName : string;
begin

  FSockDiv  := iSockType;

  FreeOnTerminate := True;
  FEvent  := TEvent.Create( nil, False, False, '');
  FSocket := TClientSocket.Create( nil);
  FSocketState := ssClosed;

  FSocketAddress := gEnv.ConConfig.FutureIP;
  // 나중에 포트 늘어나면 배열로 처리하자
  case FSockDiv of
    MAST_SOCK : FSocketPort := gEnv.ConConfig.OrderPort;
    //RECV_SOCK : FSocketPort := gEnv.ConConfig.RecvPort;
    //QURY_SOCK : FSocketPort := gEnv.ConConfig.QuryPort;
  end;

  if FSockDiv <> MAST_SOCK then  
    FApType := GetApType( FSockDiv );

  gEnv.EnvLog( WIN_APP, Format('Conn Info : %s, %d', [ FSocketAddress, FSocketPort ]) );

  for ivar := 0 to 1 do
  begin
    stName  := Format('Send_%d_%d', [ ivar, FSockDiv]);
    FSendMutex[ivar]    := CreateMutex( nil, False, PChar(stName) );
    stName  := Format('Recv_%d_%d', [ ivar, FSockDiv]);
    FReceiveMutex[ivar] := CreateMutex( nil, False, PChar(stName) );
    FQueue[ivar] := TList.Create;
  end;

  FRcvCnt   := 0;
  FCount    := 0;
  FLiveTime := 0;
  FClientSn := 0;
  FFEpSn    := 0;

  FConnectTry := 0;

  initHeader;

  inherited Create( true );
  Priority  := tpHigher;

  FSocket.OnConnect := OnConnect;
  FSocket.OnRead    := OnRead;
  FSocket.OnDisconnect  := OnDisconnect;
  FSocket.OnError       := OnError;

  FEvent.SetEvent;
  Resume;

end;

destructor TSocketThread.Destroy;
var ivar : integer;
begin
  for ivar := 0 to 1 do
  begin
    FQueue[ivar].Free;
    CloseHandle(FSendMutex[ivar]);
    CloseHandle(FReceiveMutex[ivar]);
  end;

  FSocket.Free;
  FEvent.Free;

  //inherited Destroy;
end;

procedure TSocketThread.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    OnLog(Self, stLog);
end;


procedure TSocketThread.Execute;
var
  vSend: Boolean;
  iSleep : integer;
begin
  while not Terminated do begin
    while FQueue[TYPE_SEND].Count > 0 do begin
      FData2 := PopQueue(TYPE_SEND);
      if FData2 <> nil then begin
        vSend := False;
        iSleep := 0;
        while not vSend do begin
          vSend := SocketSendBuff(@(FData2.Packet)[0], FData2.Size);
          if iSleep > 10 then begin
            socket.Close;
            break;
          end;
          if not vSend then Sleep(100);
          inc( iSleep );
        end;
        Dispose(FData2);
      end;
    end;

    if not(FEvent.WaitFor(INFINITE) in [wrSignaled]) then Continue;

    while FQueue[TYPE_RECEIVE].Count > 0 do begin
      FData := PopQueue(TYPE_RECEIVE);
      if FData <> nil then begin
        Synchronize(SyncProc);
        Dispose(FData);
      end;
      Application.ProcessMessages;
    end;
  end;
end;


function TSocketThread.GetApType(idx: integer): string;
begin
  Result:= preType[idx]+gEnv.ConConfig.ApType+sufType[idx];

end;

procedure TSocketThread.OnConnect(Sender: TObject; aSocket: TCustomWinSocket);
var
  bNodelay, bAlive : boolean;
  iRes : integer;
begin

  bNodelay := true;
  iRes  := setsockopt(FSocket.Socket.SocketHandle, IPPROTO_TCP, TCP_NODELAY,
    PChar(@bNodelay), SizeOf(bNodelay));

  if iRes = SOCKET_ERROR then
    raise Exception.Create('setsockopt TCP_NODELAY Error!! ' + IntToStr(WSAGetLastError));

  bAlive := true;
  iRes := setsockopt(FSocket.Socket.SocketHandle, SOL_SOCKET, SO_KEEPALIVE,
     PChar(@bAlive), sizeof(bAlive));

  if iRes = SOCKET_ERROR then
    raise Exception.Create('setsockopt SO_KEEPALIVE Error!! ' + IntToStr(WSAGetLastError));

  FRcvCnt := 0;
  FillChar(FRcvBuf, FILL_BUF_SIZE, #0);
  OnSocketState(ssConnected);

end;

procedure TSocketThread.OnDisConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  OnSocketState( ssClosed );
end;

procedure TSocketThread.OnError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  var stLog : string;
begin
  try
    FillChar(FRcvBuf, FILL_BUF_SIZE, #0);
    stLog := Format('소켓에러[%d] : %d ', [FSockDiv, ErrorCode]);
    gLog.Add( lkError, 'TSocketThread','OnError',stLog);
    ErrorCode := 0;
    FRcvCnt := 0;
    OnSocketState(ssClosed);
  except
  end;
end;

procedure TSocketThread.OnRead(Sender: TObject; aSocket: TCustomWinSocket);
var
  RcvBuffer: array[0..FILL_BUF_SIZE - 1] of Char;
  iRcvSize, iPacketLength, iFree, iStart, iHeadSize, iError: Integer;
  pComHead : PKrCommonHead;
  stSize   : String;
  stTmp, stTest, stPacket    : string;
  cSTXType : char;

  vPacket : PStReceptPacket;
  ivar, iCookie : integer;
begin

  iFree := FILL_BUF_SIZE - RcvCnt;
  iRcvSize := aSocket.ReceiveBuf( FRcvBuf[RcvCnt], iFree );

  // 수신받은 전체를 찍자
  if iRcvSize >= Len_KrCommonHead then
  begin
    stPacket := Format('TOT_RECV[%d] : (%d)[%s],%d',[ FSockDiv, iRcvSize, FRcvBuf , RcvCnt ]);
    gEnv.EnvLog( WIN_PACKET, stPacket);
  end;

  RcvCnt := RcvCnt + iRcvSize;
  iStart := 0;
  iPacketLength := 0;

  try
    while RcvCnt > 0 do begin

      pComHead := PKrCommonHead(@FRcvBuf[iStart]);

      iPacketLength := StrToIntDef( string(pComHead.Length), 0 );

      if iPacketLength <= 0 then begin
        inc(iStart);
        dec(FRcvCnt);
        Continue;
      end;

      if iPacketLength > RcvCnt then break;

      FillChar(RcvBuffer, iPacketLength, #0);
      Move(FRcvBuf[iStart], RcvBuffer[0], iPacketLength );

      PushQueue(TYPE_RECEIVE, iPacketLength, @RcvBuffer[0]);

      SetString( stTest, FRcvBuf+iStart, iPacketLength);
      stPacket := Format('    RECV[%d] : (%d)[%s],%d',[ FSockDiv, iPacketLength, stTest , RcvCnt]);
      gEnv.EnvLog( WIN_PACKET, stPacket);

      Inc(iStart, iPacketLength );
      RcvCnt  := RcvCnt - iPacketLength;
    end;

  Except
    on E : Exception do begin
      stTest := Format('%s', [ FRcvBuf ]);
      gLog.Add( lkError, 'TSocketThread', 'OnRead',
        Format( 'RcvCnt : %d iPacketLength : %d iStart : %d %d  %s', [RcvCnt,  iPacketLength, iStart, iFree,
        stTest]) );
    end;
  end;

  Move(FRcvBuf[iStart], FRcvBuf[0], RcvCnt);
  FillChar(FRcvBuf[RcvCnt], FILL_BUF_SIZE - RcvCnt, #0);
end;

procedure TSocketThread.RequestLink;
var
  aFep   : PKrCommonHead;
  aHead  : TKrCommonHead;
  Buffer: array of Char ;
begin

  SetLength( Buffer, Len_KrCommonHead );
  FillChar( Buffer[0], Len_KrCommonHead, ' ' );

  aFep  := PKrCommonHead( Buffer );

  // 해더 채워넣기
  aHead := MakeHeader( Len_KrCommonHead , TYPE_LINK );
  Move(FHeader, Buffer[0], Len_KrCommonHead );
  MovePacket( Format('%6.6s', [ FApType ]), aFep.ApType );
  // 센드큐에 담는다.
  PushQueue( TYPE_SEND, Len_KrCommonHead, @Buffer[0]);

end;


procedure TSocketThread.RequestPort(iSocket: integer);
var
  aFep   : PKrCommonHead;
  aHead  : TKrCommonHead;
  Buffer: array of Char ;   
begin
  if not FSocket.Active then
    Exit;

  SetLength( Buffer, Len_KrCommonHead );
  FillChar( Buffer[0], Len_KrCommonHead, ' ' );

  aFep  := PKrCommonHead( Buffer );
  // 해더 채워넣기
  aHead := MakeHeader( Len_KrCommonHead , TYPE_CON );
  Move(aHead, Buffer[0], Len_KrCommonHead );

  MovePacket( Format('%6.6s', [ GetApType( iSocket ) ]), aFep.ApType );
  // 센드큐에 담는다.
  PushQueue( TYPE_SEND, Len_KrCommonHead, @Buffer[0]);

end;

procedure TSocketThread.OnSocketState(ssValue: TSocketState);
var stTmp : string;
  aKind : TLogKind;
begin
  FSocketState := ssValue;
  aKind := lkDebug;
  case ssValue of
    ssClosed:
      begin

        aKind := lkError;
        stTmp := 'socket DisConnect : '+IntToStr( SockDiv );
        if SockDiv <> MAST_SOCK then
        begin
          gEnv.ShowMsg( WIN_ERR, 'Order DisConnect : '+IntToStr( SockDiv ), false );
          gEnv.SetSocketState( stTmp ,0);
        end;

      end;
    ssConnectPend:  ;
    ssConnected:
      begin

        aKind := lkApplication;
        stTMp := Format('%d th Socket Connected', [FSockDiv]);
        gEnv.SetSocketState( stTmp,0);
        //RequestLink;


        case SockDiv of
          3 :  // master session
            gReceiver.RequestPort;
            {
            begin
              if FCount = 0 then
              begin
                // 최초접속일경우..
                inc( FCount );
                gEnv.SetAppStatus( asConFut ) ;
              end;
            end;   }
          else begin
            RequestLink;
          end;
        end;

      end;
    ssRecovering: ;
    ssOpen:
      begin
        aKind := lkApplication;
        stTMp := Format('%d th Socket Open', [FSockDiv]);
      end;
  end;

  if aKind <> lkDebug then
    gLog.Add( aKind, 'TSocketThread','OnSocketState',stTmp , nil, true );

end;

function TSocketThread.PopQueue(iType: Integer): POrderPacket;
var
  SendBuffer: array[0..FILL_BUF_SIZE - 1] of Char;
  vResultData, vTempData: POrderPacket;
begin
  Result := nil;

  if FQueue[iTYpe].Count < 1 then exit;
  case iType of
    TYPE_SEND: begin
      FillChar(SendBuffer, FILL_BUF_SIZE, #0);
      New(vResultData);
      vResultData.Size := 0;

      while FQueue[iTYpe].Count > 0 do begin
        vTempData := POrderPacket(FQueue[iTYpe].Items[0]);
        if (vResultData.Size + vTempData.Size) < FILL_BUF_SIZE then begin
          WaitForSingleObject(FSendMutex[iType], INFINITE);
          Move((vTempData.Packet)[0], SendBuffer[vResultData.Size], vTempData.Size);
          vResultData.Size := vResultData.Size + vTempData.Size;
          FQueue[iTYpe].Delete(0);
          Dispose(vTempData);
          ReleaseMutex(FSendMutex[iType]);
        end else break;
      end;

      SetLength(vResultData.Packet, vResultData.Size);
      Move(SendBuffer[0], (vResultData.Packet)[0], vResultData.Size);

      Result := vResultData;
    end;
    TYPE_RECEIVE: begin
      WaitForSingleObject(FReceiveMutex[iType], INFINITE);
      Result := POrderPacket(FQueue[iTYpe].Items[0]);
      FQueue[iTYpe].Delete(0);
      ReleaseMutex(FReceiveMutex[iType]);
    end;
  end;
end;

procedure TSocketThread.PushQueue(iType, Size: Integer; Packet: PChar);
var
  vCommonData: POrderPacket;
  ivar: Integer;
  tStr: String;
  lwResult : LongWord;
begin
  New(vCommonData);
  vCommonData.Size := Size;
  SetLength(vCommonData.Packet, Size);
  Move(Packet[0], (vCommonData.Packet)[0], Size);

  case iType of
    TYPE_SEND:
      begin
        WaitForSingleObject(FSendMutex[iType], INFINITE);
        FQueue[iTYpe].Add(vCommonData);
        ReleaseMutex(FSendMutex[iType]);
      end;
    TYPE_RECEIVE:
      begin
        //gClock.GetNowTime( iMi );
        lwResult := WaitForSingleObject(FReceiveMutex[iType], INFINITE);
        FQueue[iTYpe].Add(vCommonData);
        ReleaseMutex(FReceiveMutex[iType]);
      end;
  end;
  FEvent.SetEvent;
end;

function TSocketThread.SendTrade(iSize : integer; pData: PChar): boolean;
var
  pComHead : TKrCommonHead;
  pEx : PKrDataPacket;
begin
  //iTotSize := Len_TopsHeader + iSize + LENGTH_SIZE ;
  pComHead := MakeHeader( iSize, TYPE_DATA );
  MovePacket( Format('%6.6s', [ FApType ]), pComHead.ApType );
  try
  //SetLength(Buffer, iSize );
  //Move(pComHead, Buffer[0], LenCommonHead);
    Move(pComHead, pData[0], Len_KrCommonHead);
  except
    On  E: Exception do
    begin
    //gEnv.EnvLog( WIN_ERR, format('%s, %d', [ E.Message, E.HelpContext]));
    //Exit;
    end;

  end;

  pEx := PKrDataPacket( pData );
 // gEnv.OnLog(self, string( pEx.Header.msgid));
  PushQueue( TYPE_SEND, iSize, pData );//@Buffer[0]);

end;    

procedure TSocketThread.SetConInfo(stIP: string; iPort: integer);
begin
  //FSocketAddress  := stIP;
  FSocketPort     := iPort;
  if FSockDiv = SEND_SOCK then
    gEnv.ConConfig.SendPort := iPort;
end;

procedure TSocketThread.SetPort(const Value: integer);
begin
  FPort := Value;
end;

procedure TSocketThread.SetSockIndex(const Value: integer);
begin
  FSockDiv := Value;
end;

function TSocketThread.SocketConnect: boolean;
begin

  if FSocket.Active then
    SocketDisconnect;

  OnSocketState(ssConnectPend);

  with FSocket do begin
    Address := FSocketAddress;
    Port := FSocketPort;
    Open;
  end;
end;

procedure TSocketThread.SocketDisconnect;
begin
  if FSocket.Active then
    FSocket.Close;
end;

function TSocketThread.SocketSendBuff(Buf: PChar; iSize: Integer): Boolean;
var
  iResult, ivar: Integer;
  Path, tStr: String;
begin

  if FSocketState in [ssClosed, ssConnectpend] then begin
    FSocket.Close();
    exit;
  end;

  Result := False;

  iResult := FSocket.Socket.SendBuf(PChar(@Buf[0])^, iSize);

  if iResult > 0 then begin
    Result := True;
    SetString( Path, Buf, iResult );
    tStr := Format('Send[%d] : (%d)%s',[ FSockDiv, iResult,Path ]);
    gEnv.EnvLog( WIN_PACKET, tStr);
    FLiveTime := now;
  end
  else if iResult = SOCKET_ERROR then
    gEnv.EnvLog( WIN_ERR, 'Send : Error' + InttoStr(GetLastError()));
end;

procedure TSocketThread.SyncProc;
begin
  ProcessTradePacket(@(FData.Packet)[0], FData.Size, FSockDiv );
end;

procedure TSocketThread.initHeader;
var
  x : Byte;
begin
  
  FillChar( FHeader, sizeof( TKrCommonHead ), ' ' );
  x := $02;
  move( x, FHeader.Stx, 1 );
  //MovePacket( FApType, FHeader.ApType );
  MovePacket( FormatDateTime('yyyymmdd', Date ), FHeader.Date );
  MovePacket( '0000', FHeader.ResCode );

end;

function TSocketThread.MakeHeader(iSize : integer; stTR: string): TKrCommonHead;
var
  iSeq : integer;
begin

  MovePacket( Format('%4.4d', [ iSize]), FHeader.Length );
  //MovePacket( FApType, FHeader.ApType );
  MovePacket( FormatDateTime('hhnnsszzz', now ), FHeader.time );

  iSeq  := 0;
  if stTR = TYPE_DATA then
  begin
    inc( FClientSn );
    iSeq := FClientSn;
  end;

  MovePacket( Format('%8.8d', [ iSeq ] ), FHeader.seq );
  MovePacket( stTR, FHeader.DataCnt );

  Result  := FHeader;

end;

function TSocketThread.IsOpen: boolean;
begin
  Result := false;
  if FSocketState = ssOpen then
    Result := true;
end;


function TSocketThread.SendCheckTimer: boolean;
var
  iSec : integer;
begin
  iSec := SecondsBetween( now, FLiveTime  );
  if iSec > TimeGap then
  begin
  //  SendPollAck;
    FLiveTime := now;
  end;
end;


procedure TSocketThread.ProcessTradePacket(szPacket: PChar; iSize,
  iSockDiv: integer);
var
  pHeader : PKrReceptPacket;
  stData, stTmp, stResCode, stTR  : string;
  iLocalNo, iSeq : integer;
  iOrdNo  : int64;
begin

  pHeader   := @szPacket[0];
  stTR      := trim( string( pHeader.KrFepHead.DataCnt ));
  stResCode := trim( string( pHeader.KrFepHead.ResCode ));
  iSeq      := StrToInt( trim( string( pHeader.KrFepHead.seq )));

  if (stTR = TYPE_CON) then // and ( iSockDiv = MAST_SOCK ) then
  begin

    //FSocketPort := StrToInt( string( pHeader.KrFepHead.seq));
    gReceiver.SetConInfo( string(pHeader.KrFepHead.ApType), string( pHeader.KrFepHead.seq));
    //socketConnect;
  end else
  if stTR = TYPE_LINK then  // heartbeat
  begin
    FFEpSn := iSeq;

    if stResCode = '0000' then
    begin
      stTmp := Format( '%s sucsess : %d, %s', [ TYPE_LINK, SockDiv, stResCode ] );
      gLog.Add( lkApplication,'TSocketThread','ProcessTradePacket', stTmp );

      if gEnv.Engine.AppStatus <> asLoad then
      begin
        if iSockDiv = FILL_SOCK then
        begin
          gEnv.SetAppStatus( asRecoveryEnd );
          gReceiver.SetTimer(true);
        end else
          gReceiver.startConnect( iSockDiv + 1 )  ;
      end;

    end else
    begin
      stTmp := Format( '%s faill : %d, %s', [ TYPE_LINK, SockDiv, stResCode ] );
      gLog.Add( lkError,'TSocketThread','ProcessTradePacket', stTmp );
      gEnv.ErrString  := stTmp;
      gEnv.SetAppStatus( asError );
      SocketDisconnect;
    end;
  end else
  if stTR = TYPE_DATA then
  begin
  {
    stResCode2    := '0000';
    if RECV_SOCK = iSockDiv then
      stResCode2  := trim( string (pHeader.KrUnionPak.KrAck.RejectCode))   ;

    stTmp := '0000';
    if ( stResCode2 = '0000' ) and ( stResCode = '0000' ) then
      stTmp := '0000'
    else begin
      if stResCode2 <> '0000' then
        stTmp := stResCode2
      else if stResCode <> '0000' then
        stTmp := stResCode
    end;


    if RECV_SOCK = iSockDiv then
      SetString( stData, szPacket + Len_KrCommonHead  + Len_KrxHead + ( 4+11+9),  iSize - ( Len_KrCommonHead + Len_KrxHead + ( 4+11+9) ) )
    else  }
    SetString( stData, szPacket + Len_KrCommonHead  + Len_KrxHead,  iSize - ( Len_KrCommonHead + Len_KrxHead ) );

    if Length( stData ) <= Len_KrCommonHead then Exit;
      gReceiver.DataReceived(stData, stResCode );
  end;


end;

end.
