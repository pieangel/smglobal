unit HFCommAgentLib_TLB;

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
// File generated on 2016-10-11 오전 8:57:42 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\1Q HTS OpenAPI\OpenAPI Package(MFC)\SampleProgram\HFCommAgent.dll (1)
// LIBID: {259EFBE5-C142-4E51-90EE-FAEDD864CB2E}
// LCID: 0
// Helpfile: C:\1Q HTS OpenAPI\OpenAPI Package(MFC)\SampleProgram\HFCommAgent.hlp
// HelpString: HFCommAgent ActiveX 컨트롤 모듈
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
  HFCommAgentLibMajorVersion = 1;
  HFCommAgentLibMinorVersion = 0;

  LIBID_HFCommAgentLib: TGUID = '{259EFBE5-C142-4E51-90EE-FAEDD864CB2E}';

  DIID__DHFCommAgent: TGUID = '{86480093-20A3-449F-AE16-D4CB59FAFFBA}';
  DIID__DHFCommAgentEvents: TGUID = '{22D86ECE-3BC9-4869-B34E-0BD7AB37396A}';
  CLASS_HFCommAgent: TGUID = '{3F33CE3E-64C1-4437-AE66-3EFA980D304A}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DHFCommAgent = dispinterface;
  _DHFCommAgentEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  HFCommAgent = _DHFCommAgent;


// *********************************************************************//
// DispIntf:  _DHFCommAgent
// Flags:     (4096) Dispatchable
// GUID:      {86480093-20A3-449F-AE16-D4CB59FAFFBA}
// *********************************************************************//
  _DHFCommAgent = dispinterface
    ['{86480093-20A3-449F-AE16-D4CB59FAFFBA}']
    function CommInit: Integer; dispid 1;
    procedure CommTerminate(bSocketClose: Integer); dispid 2;
    function CommGetConnectState: Integer; dispid 3;
    function CommLogin(const sUserID: WideString; const sPwd: WideString; const sCertPwd: WideString): Integer; dispid 4;
    function CommLogout(const sUserID: WideString): Integer; dispid 5;
    function GetLoginState: Integer; dispid 6;
    procedure SetLoginMode(nOption: Integer; nMode: Integer); dispid 7;
    function GetLoginMode(nOption: Integer): Integer; dispid 8;
    function LoadTranResource(const strFilePath: WideString): Integer; dispid 10;
    function LoadRealResource(const strFilePath: WideString): Integer; dispid 11;
    function CreateRequestID: Integer; dispid 15;
    function GetCommRecvOptionValue(nOptionType: Integer): WideString; dispid 16;
    function SetTranInputData(nRqId: Integer; const strTrCode: WideString; 
                              const strRecName: WideString; const strItem: WideString; 
                              const strValue: WideString): Integer; dispid 20;
    function RequestTran(nRqId: Integer; const sTrCode: WideString; const sIsBenefit: WideString; 
                         const sPrevOrNext: WideString; const sPrevNextKey: WideString; 
                         const sScreenNo: WideString; const sTranType: WideString; 
                         nRequestCount: Integer): Integer; dispid 21;
    function GetTranOutputRowCnt(const strTrCode: WideString; const strRecName: WideString): Integer; dispid 22;
    function GetTranOutputData(const strTrCode: WideString; const strRecName: WideString; 
                               const strItemName: WideString; nRow: Integer): WideString; dispid 23;
    function SetTranInputArrayCnt(nRqId: Integer; const strTrCode: WideString; 
                                  const strRecName: WideString; nRecCnt: Integer): Integer; dispid 24;
    function SetTranInputArrayData(nRqId: Integer; const strTrCode: WideString; 
                                   const strRecName: WideString; const strItem: WideString; 
                                   const strValue: WideString; nArrayIndex: Integer): Integer; dispid 25;
    function SetFidInputData(nRqId: Integer; const strFID: WideString; const strValue: WideString): Integer; dispid 30;
    function RequestFid(nRqId: Integer; const strOutputFidList: WideString; 
                        const strScreenNo: WideString): Integer; dispid 31;
    function RequestFidArray(nRqId: Integer; const strOutputFidList: WideString; 
                             const strPreNext: WideString; const strPreNextContext: WideString; 
                             const strScreenNo: WideString; nRequestCount: Integer): Integer; dispid 32;
    function GetFidOutputRowCnt(nRequestId: Integer): Integer; dispid 33;
    function GetFidOutputData(nRequestId: Integer; const strFID: WideString; nRow: Integer): WideString; dispid 34;
    function GetCommFidDataBlock(pVVector: Integer): Integer; dispid 35;
    function SetPortfolioFidInputData(nRqId: Integer; const strSymbolCode: WideString; 
                                      const strSymbolMarket: WideString): Integer; dispid 36;
    function RegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer; dispid 40;
    function UnRegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer; dispid 41;
    function AllUnRegisterReal: Integer; dispid 42;
    function GetRealOutputData(const strRealName: WideString; const strItemName: WideString): WideString; dispid 43;
    function GetCommRealRecvDataBlock(pVector: Integer): Integer; dispid 44;
    function GetLastErrMsg: WideString; dispid 50;
    function GetApiAgentModulePath: WideString; dispid 51;
    function GetEncrpyt(const strPlainText: WideString): WideString; dispid 52;
    function GetAccInfo(nOption: Integer; const szAccNo: WideString): WideString; dispid 60;
    function GetUserAccCnt: Integer; dispid 61;
    function GetUserAccNo(nIndex: Integer): WideString; dispid 62;
  end;

// *********************************************************************//
// DispIntf:  _DHFCommAgentEvents
// Flags:     (4096) Dispatchable
// GUID:      {22D86ECE-3BC9-4869-B34E-0BD7AB37396A}
// *********************************************************************//
  _DHFCommAgentEvents = dispinterface
    ['{22D86ECE-3BC9-4869-B34E-0BD7AB37396A}']
    procedure OnGetTranData(nRequestId: Integer; const pBlock: WideString; nBlockLength: Integer); dispid 1;
    procedure OnGetFidData(nRequestId: Integer; const pBlock: WideString; nBlockLength: Integer); dispid 2;
    procedure OnGetRealData(const strRealName: WideString; const strRealKey: WideString; 
                            pBlock: {??PWideChar}OleVariant; nBlockLength: Integer); dispid 3;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : THFCommAgent
// Help String      : HFCommAgent Control
// Default Interface: _DHFCommAgent
// Def. Intf. DISP? : Yes
// Event   Interface: _DHFCommAgentEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  THFCommAgentOnGetTranData = procedure(ASender: TObject; nRequestId: Integer; 
                                                          const pBlock: WideString; 
                                                          nBlockLength: Integer) of object;
  THFCommAgentOnGetFidData = procedure(ASender: TObject; nRequestId: Integer; 
                                                         const pBlock: WideString; 
                                                         nBlockLength: Integer) of object;
  THFCommAgentOnGetRealData = procedure(ASender: TObject; const strRealName: WideString; 
                                                          const strRealKey: WideString; 
                                                          pBlock: {??PWideChar}OleVariant; 
                                                          nBlockLength: Integer) of object;

  THFCommAgent = class(TOleControl)
  private
    FOnGetTranData: THFCommAgentOnGetTranData;
    FOnGetFidData: THFCommAgentOnGetFidData;
    FOnGetRealData: THFCommAgentOnGetRealData;
    FIntf: _DHFCommAgent;
    function  GetControlInterface: _DHFCommAgent;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function CommInit: Integer;
    procedure CommTerminate(bSocketClose: Integer);
    function CommGetConnectState: Integer;
    function CommLogin(const sUserID: WideString; const sPwd: WideString; const sCertPwd: WideString): Integer;
    function CommLogout(const sUserID: WideString): Integer;
    function GetLoginState: Integer;
    procedure SetLoginMode(nOption: Integer; nMode: Integer);
    function GetLoginMode(nOption: Integer): Integer;
    function LoadTranResource(const strFilePath: WideString): Integer;
    function LoadRealResource(const strFilePath: WideString): Integer;
    function CreateRequestID: Integer;
    function GetCommRecvOptionValue(nOptionType: Integer): WideString;
    function SetTranInputData(nRqId: Integer; const strTrCode: WideString; 
                              const strRecName: WideString; const strItem: WideString; 
                              const strValue: WideString): Integer;
    function RequestTran(nRqId: Integer; const sTrCode: WideString; const sIsBenefit: WideString; 
                         const sPrevOrNext: WideString; const sPrevNextKey: WideString; 
                         const sScreenNo: WideString; const sTranType: WideString; 
                         nRequestCount: Integer): Integer;
    function GetTranOutputRowCnt(const strTrCode: WideString; const strRecName: WideString): Integer;
    function GetTranOutputData(const strTrCode: WideString; const strRecName: WideString; 
                               const strItemName: WideString; nRow: Integer): WideString;
    function SetTranInputArrayCnt(nRqId: Integer; const strTrCode: WideString; 
                                  const strRecName: WideString; nRecCnt: Integer): Integer;
    function SetTranInputArrayData(nRqId: Integer; const strTrCode: WideString; 
                                   const strRecName: WideString; const strItem: WideString; 
                                   const strValue: WideString; nArrayIndex: Integer): Integer;
    function SetFidInputData(nRqId: Integer; const strFID: WideString; const strValue: WideString): Integer;
    function RequestFid(nRqId: Integer; const strOutputFidList: WideString; 
                        const strScreenNo: WideString): Integer;
    function RequestFidArray(nRqId: Integer; const strOutputFidList: WideString; 
                             const strPreNext: WideString; const strPreNextContext: WideString; 
                             const strScreenNo: WideString; nRequestCount: Integer): Integer;
    function GetFidOutputRowCnt(nRequestId: Integer): Integer;
    function GetFidOutputData(nRequestId: Integer; const strFID: WideString; nRow: Integer): WideString;
    function GetCommFidDataBlock(pVVector: Integer): Integer;
    function SetPortfolioFidInputData(nRqId: Integer; const strSymbolCode: WideString; 
                                      const strSymbolMarket: WideString): Integer;
    function RegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer;
    function UnRegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer;
    function AllUnRegisterReal: Integer;
    function GetRealOutputData(const strRealName: WideString; const strItemName: WideString): WideString;
    function GetCommRealRecvDataBlock(pVector: Integer): Integer;
    function GetLastErrMsg: WideString;
    function GetApiAgentModulePath: WideString;
    function GetEncrpyt(const strPlainText: WideString): WideString;
    function GetAccInfo(nOption: Integer; const szAccNo: WideString): WideString;
    function GetUserAccCnt: Integer;
    function GetUserAccNo(nIndex: Integer): WideString;
    property  ControlInterface: _DHFCommAgent read GetControlInterface;
    property  DefaultInterface: _DHFCommAgent read GetControlInterface;
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
    property OnGetTranData: THFCommAgentOnGetTranData read FOnGetTranData write FOnGetTranData;
    property OnGetFidData: THFCommAgentOnGetFidData read FOnGetFidData write FOnGetFidData;
    property OnGetRealData: THFCommAgentOnGetRealData read FOnGetRealData write FOnGetRealData;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure THFCommAgent.InitControlData;
const
  CEventDispIDs: array [0..2] of DWORD = (
    $00000001, $00000002, $00000003);
  CControlData: TControlData2 = (
    ClassID: '{3F33CE3E-64C1-4437-AE66-3EFA980D304A}';
    EventIID: '{22D86ECE-3BC9-4869-B34E-0BD7AB37396A}';
    EventCount: 3;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnGetTranData) - Cardinal(Self);
end;

procedure THFCommAgent.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DHFCommAgent;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function THFCommAgent.GetControlInterface: _DHFCommAgent;
begin
  CreateControl;
  Result := FIntf;
end;

function THFCommAgent.CommInit: Integer;
begin
  Result := DefaultInterface.CommInit;
end;

procedure THFCommAgent.CommTerminate(bSocketClose: Integer);
begin
  DefaultInterface.CommTerminate(bSocketClose);
end;

function THFCommAgent.CommGetConnectState: Integer;
begin
  Result := DefaultInterface.CommGetConnectState;
end;

function THFCommAgent.CommLogin(const sUserID: WideString; const sPwd: WideString; 
                                const sCertPwd: WideString): Integer;
begin
  Result := DefaultInterface.CommLogin(sUserID, sPwd, sCertPwd);
end;

function THFCommAgent.CommLogout(const sUserID: WideString): Integer;
begin
  Result := DefaultInterface.CommLogout(sUserID);
end;

function THFCommAgent.GetLoginState: Integer;
begin
  Result := DefaultInterface.GetLoginState;
end;

procedure THFCommAgent.SetLoginMode(nOption: Integer; nMode: Integer);
begin
  DefaultInterface.SetLoginMode(nOption, nMode);
end;

function THFCommAgent.GetLoginMode(nOption: Integer): Integer;
begin
  Result := DefaultInterface.GetLoginMode(nOption);
end;

function THFCommAgent.LoadTranResource(const strFilePath: WideString): Integer;
begin
  Result := DefaultInterface.LoadTranResource(strFilePath);
end;

function THFCommAgent.LoadRealResource(const strFilePath: WideString): Integer;
begin
  Result := DefaultInterface.LoadRealResource(strFilePath);
end;

function THFCommAgent.CreateRequestID: Integer;
begin
  Result := DefaultInterface.CreateRequestID;
end;

function THFCommAgent.GetCommRecvOptionValue(nOptionType: Integer): WideString;
begin
  Result := DefaultInterface.GetCommRecvOptionValue(nOptionType);
end;

function THFCommAgent.SetTranInputData(nRqId: Integer; const strTrCode: WideString; 
                                       const strRecName: WideString; const strItem: WideString; 
                                       const strValue: WideString): Integer;
begin
  Result := DefaultInterface.SetTranInputData(nRqId, strTrCode, strRecName, strItem, strValue);
end;

function THFCommAgent.RequestTran(nRqId: Integer; const sTrCode: WideString; 
                                  const sIsBenefit: WideString; const sPrevOrNext: WideString; 
                                  const sPrevNextKey: WideString; const sScreenNo: WideString; 
                                  const sTranType: WideString; nRequestCount: Integer): Integer;
begin
  Result := DefaultInterface.RequestTran(nRqId, sTrCode, sIsBenefit, sPrevOrNext, sPrevNextKey, 
                                         sScreenNo, sTranType, nRequestCount);
end;

function THFCommAgent.GetTranOutputRowCnt(const strTrCode: WideString; const strRecName: WideString): Integer;
begin
  Result := DefaultInterface.GetTranOutputRowCnt(strTrCode, strRecName);
end;

function THFCommAgent.GetTranOutputData(const strTrCode: WideString; const strRecName: WideString; 
                                        const strItemName: WideString; nRow: Integer): WideString;
begin
  Result := DefaultInterface.GetTranOutputData(strTrCode, strRecName, strItemName, nRow);
end;

function THFCommAgent.SetTranInputArrayCnt(nRqId: Integer; const strTrCode: WideString; 
                                           const strRecName: WideString; nRecCnt: Integer): Integer;
begin
  Result := DefaultInterface.SetTranInputArrayCnt(nRqId, strTrCode, strRecName, nRecCnt);
end;

function THFCommAgent.SetTranInputArrayData(nRqId: Integer; const strTrCode: WideString; 
                                            const strRecName: WideString; 
                                            const strItem: WideString; const strValue: WideString; 
                                            nArrayIndex: Integer): Integer;
begin
  Result := DefaultInterface.SetTranInputArrayData(nRqId, strTrCode, strRecName, strItem, strValue, 
                                                   nArrayIndex);
end;

function THFCommAgent.SetFidInputData(nRqId: Integer; const strFID: WideString; 
                                      const strValue: WideString): Integer;
begin
  Result := DefaultInterface.SetFidInputData(nRqId, strFID, strValue);
end;

function THFCommAgent.RequestFid(nRqId: Integer; const strOutputFidList: WideString; 
                                 const strScreenNo: WideString): Integer;
begin
  Result := DefaultInterface.RequestFid(nRqId, strOutputFidList, strScreenNo);
end;

function THFCommAgent.RequestFidArray(nRqId: Integer; const strOutputFidList: WideString; 
                                      const strPreNext: WideString; 
                                      const strPreNextContext: WideString; 
                                      const strScreenNo: WideString; nRequestCount: Integer): Integer;
begin
  Result := DefaultInterface.RequestFidArray(nRqId, strOutputFidList, strPreNext, 
                                             strPreNextContext, strScreenNo, nRequestCount);
end;

function THFCommAgent.GetFidOutputRowCnt(nRequestId: Integer): Integer;
begin
  Result := DefaultInterface.GetFidOutputRowCnt(nRequestId);
end;

function THFCommAgent.GetFidOutputData(nRequestId: Integer; const strFID: WideString; nRow: Integer): WideString;
begin
  Result := DefaultInterface.GetFidOutputData(nRequestId, strFID, nRow);
end;

function THFCommAgent.GetCommFidDataBlock(pVVector: Integer): Integer;
begin
  Result := DefaultInterface.GetCommFidDataBlock(pVVector);
end;

function THFCommAgent.SetPortfolioFidInputData(nRqId: Integer; const strSymbolCode: WideString; 
                                               const strSymbolMarket: WideString): Integer;
begin
  Result := DefaultInterface.SetPortfolioFidInputData(nRqId, strSymbolCode, strSymbolMarket);
end;

function THFCommAgent.RegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer;
begin
  Result := DefaultInterface.RegisterReal(strRealName, strRealKey);
end;

function THFCommAgent.UnRegisterReal(const strRealName: WideString; const strRealKey: WideString): Integer;
begin
  Result := DefaultInterface.UnRegisterReal(strRealName, strRealKey);
end;

function THFCommAgent.AllUnRegisterReal: Integer;
begin
  Result := DefaultInterface.AllUnRegisterReal;
end;

function THFCommAgent.GetRealOutputData(const strRealName: WideString; const strItemName: WideString): WideString;
begin
  Result := DefaultInterface.GetRealOutputData(strRealName, strItemName);
end;

function THFCommAgent.GetCommRealRecvDataBlock(pVector: Integer): Integer;
begin
  Result := DefaultInterface.GetCommRealRecvDataBlock(pVector);
end;

function THFCommAgent.GetLastErrMsg: WideString;
begin
  Result := DefaultInterface.GetLastErrMsg;
end;

function THFCommAgent.GetApiAgentModulePath: WideString;
begin
  Result := DefaultInterface.GetApiAgentModulePath;
end;

function THFCommAgent.GetEncrpyt(const strPlainText: WideString): WideString;
begin
  Result := DefaultInterface.GetEncrpyt(strPlainText);
end;

function THFCommAgent.GetAccInfo(nOption: Integer; const szAccNo: WideString): WideString;
begin
  Result := DefaultInterface.GetAccInfo(nOption, szAccNo);
end;

function THFCommAgent.GetUserAccCnt: Integer;
begin
  Result := DefaultInterface.GetUserAccCnt;
end;

function THFCommAgent.GetUserAccNo(nIndex: Integer): WideString;
begin
  Result := DefaultInterface.GetUserAccNo(nIndex);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [THFCommAgent]);
end;

end.
