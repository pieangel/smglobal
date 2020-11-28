unit ESApiExpLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 8291 $
// File generated on 2016-03-24 ¿ÀÀü 11:38:01 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\KrApi\_EsBin\ESApiExp.ocx (1)
// LIBID: {B29C0F0F-B73E-43FC-B2F4-5B059AEB95C4}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ESApiExpLibMajorVersion = 1;
  ESApiExpLibMinorVersion = 0;

  LIBID_ESApiExpLib: TGUID = '{B29C0F0F-B73E-43FC-B2F4-5B059AEB95C4}';

  DIID__DESApiExp: TGUID = '{F8C4EADE-843F-4C2B-BB18-652BB3EE1117}';
  DIID__DESApiExpEvents: TGUID = '{32ADD670-DEC5-4028-B48A-60D3BC3A0FCC}';
  CLASS_ESApiExp: TGUID = '{DD99E84E-5295-4895-970E-4D443E6BCE2E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DESApiExp = dispinterface;
  _DESApiExpEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ESApiExp = _DESApiExp;


// *********************************************************************//
// DispIntf:  _DESApiExp
// Flags:     (4096) Dispatchable
// GUID:      {F8C4EADE-843F-4C2B-BB18-652BB3EE1117}
// *********************************************************************//
  _DESApiExp = dispinterface
    ['{F8C4EADE-843F-4C2B-BB18-652BB3EE1117}']
    function ESExpIsServerConnect: {??Shortint}OleVariant; dispid 1;
    function ESExpDisConnectServer: {??Shortint}OleVariant; dispid 2;
    function ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                const szCertPasswd: WideString; nSvrKind: Smallint): Integer; dispid 3;
    function ESExpGetCommunicationType: WideString; dispid 4;
    function ESExpGetFullCode(const szShortCode: WideString): WideString; dispid 5;
    function ESExpGetCodeIndex(const szShortCode: WideString): WideString; dispid 6;
    function ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString; dispid 7;
    function ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer; dispid 8;
    function ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; bAccount: {??Shortint}OleVariant; 
                                const szAutoKey: WideString): Integer; dispid 9;
    function ESExpGetShortCode(const szFullCode: WideString): WideString; dispid 10;
    function ESExpApiFilePath(const szFilePath: WideString): Integer; dispid 11;
    function ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant; dispid 12;
  end;

// *********************************************************************//
// DispIntf:  _DESApiExpEvents
// Flags:     (4096) Dispatchable
// GUID:      {32ADD670-DEC5-4028-B48A-60D3BC3A0FCC}
// *********************************************************************//
  _DESApiExpEvents = dispinterface
    ['{32ADD670-DEC5-4028-B48A-60D3BC3A0FCC}']
    procedure ESExpServerConnect(nErrCode: Smallint; const strMessage: WideString); dispid 1;
    procedure ESExpServerDisConnect; dispid 2;
    procedure ESExpRecvData(nTrCode: Smallint; const szRecvData: WideString); dispid 3;
    procedure ESExpAcctList(nListCount: Smallint; const szAcctData: WideString); dispid 4;
    procedure ESExpCodeList(nListCount: Smallint; const szCodeData: WideString); dispid 5;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TESApiExp
// Help String      : 
// Default Interface: _DESApiExp
// Def. Intf. DISP? : Yes
// Event   Interface: _DESApiExpEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TESApiExpESExpServerConnect = procedure(ASender: TObject; nErrCode: Smallint; 
                                                            const strMessage: WideString) of object;
  TESApiExpESExpRecvData = procedure(ASender: TObject; nTrCode: Smallint; 
                                                       const szRecvData: WideString) of object;
  TESApiExpESExpAcctList = procedure(ASender: TObject; nListCount: Smallint; 
                                                       const szAcctData: WideString) of object;
  TESApiExpESExpCodeList = procedure(ASender: TObject; nListCount: Smallint; 
                                                       const szCodeData: WideString) of object;

  TESApiExp = class(TOleControl)
  private
    FOnESExpServerConnect: TESApiExpESExpServerConnect;
    FOnESExpServerDisConnect: TNotifyEvent;
    FOnESExpRecvData: TESApiExpESExpRecvData;
    FOnESExpAcctList: TESApiExpESExpAcctList;
    FOnESExpCodeList: TESApiExpESExpCodeList;
    FIntf: _DESApiExp;
    function  GetControlInterface: _DESApiExp;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function ESExpIsServerConnect: {??Shortint}OleVariant;
    function ESExpDisConnectServer: {??Shortint}OleVariant;
    function ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                const szCertPasswd: WideString; nSvrKind: Smallint): Integer;
    function ESExpGetCommunicationType: WideString;
    function ESExpGetFullCode(const szShortCode: WideString): WideString;
    function ESExpGetCodeIndex(const szShortCode: WideString): WideString;
    function ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString;
    function ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer;
    function ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; bAccount: {??Shortint}OleVariant; 
                                const szAutoKey: WideString): Integer;
    function ESExpGetShortCode(const szFullCode: WideString): WideString;
    function ESExpApiFilePath(const szFilePath: WideString): Integer;
    function ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant;
    property  ControlInterface: _DESApiExp read GetControlInterface;
    property  DefaultInterface: _DESApiExp read GetControlInterface;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property OnESExpServerConnect: TESApiExpESExpServerConnect read FOnESExpServerConnect write FOnESExpServerConnect;
    property OnESExpServerDisConnect: TNotifyEvent read FOnESExpServerDisConnect write FOnESExpServerDisConnect;
    property OnESExpRecvData: TESApiExpESExpRecvData read FOnESExpRecvData write FOnESExpRecvData;
    property OnESExpAcctList: TESApiExpESExpAcctList read FOnESExpAcctList write FOnESExpAcctList;
    property OnESExpCodeList: TESApiExpESExpCodeList read FOnESExpCodeList write FOnESExpCodeList;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TESApiExp.InitControlData;
const
  CEventDispIDs: array [0..4] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005);
  CControlData: TControlData2 = (
    ClassID: '{DD99E84E-5295-4895-970E-4D443E6BCE2E}';
    EventIID: '{32ADD670-DEC5-4028-B48A-60D3BC3A0FCC}';
    EventCount: 5;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnESExpServerConnect) - Cardinal(Self);
end;

procedure TESApiExp.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DESApiExp;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TESApiExp.GetControlInterface: _DESApiExp;
begin
  CreateControl;
  Result := FIntf;
end;

function TESApiExp.ESExpIsServerConnect: {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpIsServerConnect;
end;

function TESApiExp.ESExpDisConnectServer: {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpDisConnectServer;
end;

function TESApiExp.ESExpConnectServer(const szUserID: WideString; const szPasswd: WideString; 
                                      const szCertPasswd: WideString; nSvrKind: Smallint): Integer;
begin
  Result := DefaultInterface.ESExpConnectServer(szUserID, szPasswd, szCertPasswd, nSvrKind);
end;

function TESApiExp.ESExpGetCommunicationType: WideString;
begin
  Result := DefaultInterface.ESExpGetCommunicationType;
end;

function TESApiExp.ESExpGetFullCode(const szShortCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetFullCode(szShortCode);
end;

function TESApiExp.ESExpGetCodeIndex(const szShortCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetCodeIndex(szShortCode);
end;

function TESApiExp.ESExpGetEncodePassword(const szAcct: WideString; const szSrcPass: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetEncodePassword(szAcct, szSrcPass);
end;

function TESApiExp.ESExpSendTrData(nTrCode: Smallint; const lpszData: WideString; nLen: Smallint): Integer;
begin
  Result := DefaultInterface.ESExpSendTrData(nTrCode, lpszData, nLen);
end;

function TESApiExp.ESExpSetAutoUpdate(bSet: {??Shortint}OleVariant; 
                                      bAccount: {??Shortint}OleVariant; const szAutoKey: WideString): Integer;
begin
  Result := DefaultInterface.ESExpSetAutoUpdate(bSet, bAccount, szAutoKey);
end;

function TESApiExp.ESExpGetShortCode(const szFullCode: WideString): WideString;
begin
  Result := DefaultInterface.ESExpGetShortCode(szFullCode);
end;

function TESApiExp.ESExpApiFilePath(const szFilePath: WideString): Integer;
begin
  Result := DefaultInterface.ESExpApiFilePath(szFilePath);
end;

function TESApiExp.ESExpSetUseStaffMode(bValid: {??Shortint}OleVariant): {??Shortint}OleVariant;
begin
  Result := DefaultInterface.ESExpSetUseStaffMode(bValid);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TESApiExp]);
end;

end.
