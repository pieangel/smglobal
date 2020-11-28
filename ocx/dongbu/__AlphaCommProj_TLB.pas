unit AlphaCommProj_TLB;

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
// File generated on 2016-02-17 오후 1:20:06 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\동부증권\HappyPlusGlobal\exe\AlphaComm.ocx (1)
// LIBID: {677F3F8B-1E15-4DF7-ADA4-C26E3B696F1C}
// LCID: 0
// Helpfile: 
// HelpString: AlphaCommProj Library
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
  AlphaCommProjMajorVersion = 1;
  AlphaCommProjMinorVersion = 0;

  LIBID_AlphaCommProj: TGUID = '{677F3F8B-1E15-4DF7-ADA4-C26E3B696F1C}';

  IID_IAlphaCommX: TGUID = '{9F317010-8089-4F12-8AF1-8210A594C701}';
  DIID_IAlphaCommXEvents: TGUID = '{F01A68AC-2D34-4CCC-AD05-93BC4CD7151C}';
  CLASS_AlphaCommX: TGUID = '{B039AA8A-4C52-4D64-9B18-417439DFFFA3}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxActiveFormBorderStyle
type
  TxActiveFormBorderStyle = TOleEnum;
const
  afbNone = $00000000;
  afbSingle = $00000001;
  afbSunken = $00000002;
  afbRaised = $00000003;

// Constants for enum TxPrintScale
type
  TxPrintScale = TOleEnum;
const
  poNone = $00000000;
  poProportional = $00000001;
  poPrintToFit = $00000002;

// Constants for enum TxMouseButton
type
  TxMouseButton = TOleEnum;
const
  mbLeft = $00000000;
  mbRight = $00000001;
  mbMiddle = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAlphaCommX = interface;
  IAlphaCommXDisp = dispinterface;
  IAlphaCommXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  AlphaCommX = IAlphaCommX;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPUserType1 = ^IFontDisp; {*}
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IAlphaCommX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9F317010-8089-4F12-8AF1-8210A594C701}
// *********************************************************************//
  IAlphaCommX = interface(IDispatch)
    ['{9F317010-8089-4F12-8AF1-8210A594C701}']
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Color: OLE_COLOR; safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    function Get_Font: IFontDisp; safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    procedure _Set_Font(var Value: IFontDisp); safecall;
    function Get_KeyPreview: WordBool; safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    function Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    function Get_Scaled: WordBool; safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    function Get_Active: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_ScreenSnap: WordBool; safecall;
    procedure Set_ScreenSnap(Value: WordBool); safecall;
    function Get_SnapBuffer: Integer; safecall;
    procedure Set_SnapBuffer(Value: Integer); safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Login(var strUserId: OleVariant; var strUserPswd: OleVariant; 
                    var strCertPsw: OleVariant); safecall;
    procedure RequestData(var strWinID: OleVariant; var strFlag: OleVariant; 
                          var strGtrCode: OleVariant; var strTrCode: OleVariant; 
                          var strLen: OleVariant; var strData: OleVariant; 
                          var strEncrypt: OleVariant); safecall;
    procedure ConnectHost(var strIpAddress: OleVariant; var strIpPort: OleVariant); safecall;
    procedure RegistRealData(var lptrcode: OleVariant; var lpkeyCode: OleVariant); safecall;
    procedure GetMasterFile; safecall;
    procedure FreeObject; safecall;
    procedure UnRegistRealData(var strWinID: OleVariant); safecall;
    procedure CloseHost; safecall;
    function GetGridData(var wmid: OleVariant; var btype: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant; safecall;
    function GetRowCount(var wmid: OleVariant): OleVariant; safecall;
    function GetRealOrderData(var wmid: OleVariant; var btype: OleVariant; 
                              var trSymbolcode: OleVariant): OleVariant; safecall;
    function GetSisedata(var wmid: OleVariant; var byte: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant; safecall;
    function GetNextData(var wmid: OleVariant): OleVariant; safecall;
    procedure TempData(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                       var s4: OleVariant); safecall;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property AutoScroll: WordBool read Get_AutoScroll write Set_AutoScroll;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property AxBorderStyle: TxActiveFormBorderStyle read Get_AxBorderStyle write Set_AxBorderStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Color: OLE_COLOR read Get_Color write Set_Color;
    property Font: IFontDisp read Get_Font write Set_Font;
    property KeyPreview: WordBool read Get_KeyPreview write Set_KeyPreview;
    property PixelsPerInch: Integer read Get_PixelsPerInch write Set_PixelsPerInch;
    property PrintScale: TxPrintScale read Get_PrintScale write Set_PrintScale;
    property Scaled: WordBool read Get_Scaled write Set_Scaled;
    property Active: WordBool read Get_Active;
    property DropTarget: WordBool read Get_DropTarget write Set_DropTarget;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property ScreenSnap: WordBool read Get_ScreenSnap write Set_ScreenSnap;
    property SnapBuffer: Integer read Get_SnapBuffer write Set_SnapBuffer;
    property DoubleBuffered: WordBool read Get_DoubleBuffered write Set_DoubleBuffered;
    property AlignDisabled: WordBool read Get_AlignDisabled;
    property VisibleDockClientCount: Integer read Get_VisibleDockClientCount;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
  end;

// *********************************************************************//
// DispIntf:  IAlphaCommXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9F317010-8089-4F12-8AF1-8210A594C701}
// *********************************************************************//
  IAlphaCommXDisp = dispinterface
    ['{9F317010-8089-4F12-8AF1-8210A594C701}']
    property Visible: WordBool dispid 201;
    property AutoScroll: WordBool dispid 202;
    property AutoSize: WordBool dispid 203;
    property AxBorderStyle: TxActiveFormBorderStyle dispid 204;
    property Caption: WideString dispid -518;
    property Color: OLE_COLOR dispid -501;
    property Font: IFontDisp dispid -512;
    property KeyPreview: WordBool dispid 205;
    property PixelsPerInch: Integer dispid 206;
    property PrintScale: TxPrintScale dispid 207;
    property Scaled: WordBool dispid 208;
    property Active: WordBool readonly dispid 209;
    property DropTarget: WordBool dispid 210;
    property HelpFile: WideString dispid 211;
    property ScreenSnap: WordBool dispid 212;
    property SnapBuffer: Integer dispid 213;
    property DoubleBuffered: WordBool dispid 214;
    property AlignDisabled: WordBool readonly dispid 215;
    property VisibleDockClientCount: Integer readonly dispid 216;
    property Enabled: WordBool dispid -514;
    procedure Login(var strUserId: OleVariant; var strUserPswd: OleVariant; 
                    var strCertPsw: OleVariant); dispid 217;
    procedure RequestData(var strWinID: OleVariant; var strFlag: OleVariant; 
                          var strGtrCode: OleVariant; var strTrCode: OleVariant; 
                          var strLen: OleVariant; var strData: OleVariant; 
                          var strEncrypt: OleVariant); dispid 218;
    procedure ConnectHost(var strIpAddress: OleVariant; var strIpPort: OleVariant); dispid 219;
    procedure RegistRealData(var lptrcode: OleVariant; var lpkeyCode: OleVariant); dispid 220;
    procedure GetMasterFile; dispid 221;
    procedure FreeObject; dispid 222;
    procedure UnRegistRealData(var strWinID: OleVariant); dispid 223;
    procedure CloseHost; dispid 224;
    function GetGridData(var wmid: OleVariant; var btype: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant; dispid 225;
    function GetRowCount(var wmid: OleVariant): OleVariant; dispid 226;
    function GetRealOrderData(var wmid: OleVariant; var btype: OleVariant; 
                              var trSymbolcode: OleVariant): OleVariant; dispid 227;
    function GetSisedata(var wmid: OleVariant; var byte: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant; dispid 228;
    function GetNextData(var wmid: OleVariant): OleVariant; dispid 229;
    procedure TempData(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                       var s4: OleVariant); dispid 230;
  end;

// *********************************************************************//
// DispIntf:  IAlphaCommXEvents
// Flags:     (4096) Dispatchable
// GUID:      {F01A68AC-2D34-4CCC-AD05-93BC4CD7151C}
// *********************************************************************//
  IAlphaCommXEvents = dispinterface
    ['{F01A68AC-2D34-4CCC-AD05-93BC4CD7151C}']
    procedure OnActivate; dispid 201;
    procedure OnClick; dispid 202;
    procedure OnCreate; dispid 203;
    procedure OnDblClick; dispid 204;
    procedure OnDestroy; dispid 205;
    procedure OnDeactivate; dispid 206;
    procedure OnKeyPress(var Key: Smallint); dispid 207;
    procedure OnPaint; dispid 208;
    procedure OnReplyLogin(var pstr: OleVariant); dispid 209;
    procedure OnReplyConnect(var pstr: OleVariant); dispid 210;
    procedure OnRecvRQData(var pstr: OleVariant); dispid 211;
    procedure OnRecvRealData(var sRealData: OleVariant); dispid 212;
    procedure OnReplyFileDown(sFileData: Integer); dispid 213;
    procedure OnRecvRealOrdData(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                                var s4: OleVariant; var s5: OleVariant; var s6: OleVariant; 
                                var s7: OleVariant; var s8: OleVariant; var s9: OleVariant; 
                                var s10: OleVariant; var s11: OleVariant; var s12: OleVariant; 
                                var s13: OleVariant; var s14: OleVariant; var s15: OleVariant; 
                                var s16: OleVariant; var s17: OleVariant; var s18: OleVariant; 
                                var s19: OleVariant; var s20: OleVariant; var s21: OleVariant; 
                                var s22: OleVariant); dispid 214;
    procedure OnCloseHost(var pstr: OleVariant); dispid 215;
    procedure OnReceiveRealOrder(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                                 var s4: OleVariant; var s5: OleVariant; var s6: OleVariant; 
                                 var s7: OleVariant; var s8: OleVariant; var s9: OleVariant; 
                                 var s10: OleVariant; var s11: OleVariant; var s12: OleVariant; 
                                 var s13: OleVariant; var s14: OleVariant; var s15: OleVariant; 
                                 var s16: OleVariant); dispid 216;
    procedure OnReceiveRealHoga(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                                var s4: OleVariant; var s5: OleVariant; var s6: OleVariant; 
                                var s7: OleVariant; var s8: OleVariant; var s9: OleVariant; 
                                var s10: OleVariant; var s11: OleVariant; var s12: OleVariant; 
                                var s13: OleVariant; var s14: OleVariant; var s15: OleVariant; 
                                var s16: OleVariant; var s17: OleVariant; var s18: OleVariant; 
                                var s19: OleVariant; var s20: OleVariant; var s21: OleVariant; 
                                var s22: OleVariant; var s23: OleVariant; var s24: OleVariant; 
                                var s25: OleVariant; var s26: OleVariant; var s27: OleVariant; 
                                var s28: OleVariant; var s29: OleVariant; var s30: OleVariant; 
                                var s31: OleVariant; var s32: OleVariant; var s33: OleVariant; 
                                var s34: OleVariant; var s35: OleVariant; var s36: OleVariant; 
                                var s37: OleVariant); dispid 217;
    procedure OnReceRealChegyul(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                                var s4: OleVariant; var s5: OleVariant; var s6: OleVariant; 
                                var s7: OleVariant; var s8: OleVariant; var s9: OleVariant; 
                                var s10: OleVariant; var s11: OleVariant; var s12: OleVariant; 
                                var s13: OleVariant; var s14: OleVariant; var s15: OleVariant; 
                                var s16: OleVariant; var s17: OleVariant; var s18: OleVariant; 
                                var s19: OleVariant; var s20: OleVariant; var s21: OleVariant; 
                                var s22: OleVariant); dispid 218;
    procedure OnRecvRealPositoin(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                                 var s4: OleVariant; var s5: OleVariant; var s6: OleVariant; 
                                 var s7: OleVariant; var s8: OleVariant; var s9: OleVariant; 
                                 var s10: OleVariant; var s11: OleVariant; var s12: OleVariant; 
                                 var s13: OleVariant; var s14: OleVariant; var s15: OleVariant; 
                                 var s16: OleVariant; var s17: OleVariant; var s18: OleVariant; 
                                 var s19: OleVariant; var s20: OleVariant; var s21: OleVariant; 
                                 var s22: OleVariant); dispid 219;
    procedure OnTemp(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; var s4: OleVariant); dispid 220;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TAlphaCommX
// Help String      : AlphaCommX Control
// Default Interface: IAlphaCommX
// Def. Intf. DISP? : No
// Event   Interface: IAlphaCommXEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TAlphaCommXOnKeyPress = procedure(ASender: TObject; var Key: Smallint) of object;
  TAlphaCommXOnReplyLogin = procedure(ASender: TObject; var pstr: OleVariant) of object;
  TAlphaCommXOnReplyConnect = procedure(ASender: TObject; var pstr: OleVariant) of object;
  TAlphaCommXOnRecvRQData = procedure(ASender: TObject; var pstr: OleVariant) of object;
  TAlphaCommXOnRecvRealData = procedure(ASender: TObject; var sRealData: OleVariant) of object;
  TAlphaCommXOnReplyFileDown = procedure(ASender: TObject; sFileData: Integer) of object;
  TAlphaCommXOnRecvRealOrdData = procedure(ASender: TObject; var s1: OleVariant; 
                                                             var s2: OleVariant; 
                                                             var s3: OleVariant; 
                                                             var s4: OleVariant; 
                                                             var s5: OleVariant; 
                                                             var s6: OleVariant; 
                                                             var s7: OleVariant; 
                                                             var s8: OleVariant; 
                                                             var s9: OleVariant; 
                                                             var s10: OleVariant; 
                                                             var s11: OleVariant; 
                                                             var s12: OleVariant; 
                                                             var s13: OleVariant; 
                                                             var s14: OleVariant; 
                                                             var s15: OleVariant; 
                                                             var s16: OleVariant; 
                                                             var s17: OleVariant; 
                                                             var s18: OleVariant; 
                                                             var s19: OleVariant; 
                                                             var s20: OleVariant; 
                                                             var s21: OleVariant; 
                                                             var s22: OleVariant) of object;
  TAlphaCommXOnCloseHost = procedure(ASender: TObject; var pstr: OleVariant) of object;
  TAlphaCommXOnReceiveRealOrder = procedure(ASender: TObject; var s1: OleVariant; 
                                                              var s2: OleVariant; 
                                                              var s3: OleVariant; 
                                                              var s4: OleVariant; 
                                                              var s5: OleVariant; 
                                                              var s6: OleVariant; 
                                                              var s7: OleVariant; 
                                                              var s8: OleVariant; 
                                                              var s9: OleVariant; 
                                                              var s10: OleVariant; 
                                                              var s11: OleVariant; 
                                                              var s12: OleVariant; 
                                                              var s13: OleVariant; 
                                                              var s14: OleVariant; 
                                                              var s15: OleVariant; 
                                                              var s16: OleVariant) of object;
  TAlphaCommXOnReceiveRealHoga = procedure(ASender: TObject; var s1: OleVariant; 
                                                             var s2: OleVariant; 
                                                             var s3: OleVariant; 
                                                             var s4: OleVariant; 
                                                             var s5: OleVariant; 
                                                             var s6: OleVariant; 
                                                             var s7: OleVariant; 
                                                             var s8: OleVariant; 
                                                             var s9: OleVariant; 
                                                             var s10: OleVariant; 
                                                             var s11: OleVariant; 
                                                             var s12: OleVariant; 
                                                             var s13: OleVariant; 
                                                             var s14: OleVariant; 
                                                             var s15: OleVariant; 
                                                             var s16: OleVariant; 
                                                             var s17: OleVariant; 
                                                             var s18: OleVariant; 
                                                             var s19: OleVariant; 
                                                             var s20: OleVariant; 
                                                             var s21: OleVariant; 
                                                             var s22: OleVariant; 
                                                             var s23: OleVariant; 
                                                             var s24: OleVariant; 
                                                             var s25: OleVariant; 
                                                             var s26: OleVariant; 
                                                             var s27: OleVariant; 
                                                             var s28: OleVariant; 
                                                             var s29: OleVariant; 
                                                             var s30: OleVariant; 
                                                             var s31: OleVariant; 
                                                             var s32: OleVariant; 
                                                             var s33: OleVariant; 
                                                             var s34: OleVariant; 
                                                             var s35: OleVariant; 
                                                             var s36: OleVariant; 
                                                             var s37: OleVariant) of object;
  TAlphaCommXOnReceRealChegyul = procedure(ASender: TObject; var s1: OleVariant; 
                                                             var s2: OleVariant; 
                                                             var s3: OleVariant; 
                                                             var s4: OleVariant; 
                                                             var s5: OleVariant; 
                                                             var s6: OleVariant; 
                                                             var s7: OleVariant; 
                                                             var s8: OleVariant; 
                                                             var s9: OleVariant; 
                                                             var s10: OleVariant; 
                                                             var s11: OleVariant; 
                                                             var s12: OleVariant; 
                                                             var s13: OleVariant; 
                                                             var s14: OleVariant; 
                                                             var s15: OleVariant; 
                                                             var s16: OleVariant; 
                                                             var s17: OleVariant; 
                                                             var s18: OleVariant; 
                                                             var s19: OleVariant; 
                                                             var s20: OleVariant; 
                                                             var s21: OleVariant; 
                                                             var s22: OleVariant) of object;
  TAlphaCommXOnRecvRealPositoin = procedure(ASender: TObject; var s1: OleVariant; 
                                                              var s2: OleVariant; 
                                                              var s3: OleVariant; 
                                                              var s4: OleVariant; 
                                                              var s5: OleVariant; 
                                                              var s6: OleVariant; 
                                                              var s7: OleVariant; 
                                                              var s8: OleVariant; 
                                                              var s9: OleVariant; 
                                                              var s10: OleVariant; 
                                                              var s11: OleVariant; 
                                                              var s12: OleVariant; 
                                                              var s13: OleVariant; 
                                                              var s14: OleVariant; 
                                                              var s15: OleVariant; 
                                                              var s16: OleVariant; 
                                                              var s17: OleVariant; 
                                                              var s18: OleVariant; 
                                                              var s19: OleVariant; 
                                                              var s20: OleVariant; 
                                                              var s21: OleVariant; 
                                                              var s22: OleVariant) of object;
  TAlphaCommXOnTemp = procedure(ASender: TObject; var s1: OleVariant; var s2: OleVariant; 
                                                  var s3: OleVariant; var s4: OleVariant) of object;

  TAlphaCommX = class(TOleControl)
  private
    FOnActivate: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnKeyPress: TAlphaCommXOnKeyPress;
    FOnPaint: TNotifyEvent;
    FOnReplyLogin: TAlphaCommXOnReplyLogin;
    FOnReplyConnect: TAlphaCommXOnReplyConnect;
    FOnRecvRQData: TAlphaCommXOnRecvRQData;
    FOnRecvRealData: TAlphaCommXOnRecvRealData;
    FOnReplyFileDown: TAlphaCommXOnReplyFileDown;
    FOnRecvRealOrdData: TAlphaCommXOnRecvRealOrdData;
    FOnCloseHost: TAlphaCommXOnCloseHost;
    FOnReceiveRealOrder: TAlphaCommXOnReceiveRealOrder;
    FOnReceiveRealHoga: TAlphaCommXOnReceiveRealHoga;
    FOnReceRealChegyul: TAlphaCommXOnReceRealChegyul;
    FOnRecvRealPositoin: TAlphaCommXOnRecvRealPositoin;
    FOnTemp: TAlphaCommXOnTemp;
    FIntf: IAlphaCommX;
    function  GetControlInterface: IAlphaCommX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure Login(var strUserId: OleVariant; var strUserPswd: OleVariant; 
                    var strCertPsw: OleVariant);
    procedure RequestData(var strWinID: OleVariant; var strFlag: OleVariant; 
                          var strGtrCode: OleVariant; var strTrCode: OleVariant; 
                          var strLen: OleVariant; var strData: OleVariant; 
                          var strEncrypt: OleVariant);
    procedure ConnectHost(var strIpAddress: OleVariant; var strIpPort: OleVariant);
    procedure RegistRealData(var lptrcode: OleVariant; var lpkeyCode: OleVariant);
    procedure GetMasterFile;
    procedure FreeObject;
    procedure UnRegistRealData(var strWinID: OleVariant);
    procedure CloseHost;
    function GetGridData(var wmid: OleVariant; var btype: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant;
    function GetRowCount(var wmid: OleVariant): OleVariant;
    function GetRealOrderData(var wmid: OleVariant; var btype: OleVariant; 
                              var trSymbolcode: OleVariant): OleVariant;
    function GetSisedata(var wmid: OleVariant; var byte: OleVariant; var stSymbolcode: OleVariant; 
                         var index: OleVariant): OleVariant;
    function GetNextData(var wmid: OleVariant): OleVariant;
    procedure TempData(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                       var s4: OleVariant);
    property  ControlInterface: IAlphaCommX read GetControlInterface;
    property  DefaultInterface: IAlphaCommX read GetControlInterface;
    property Visible: WordBool index 201 read GetWordBoolProp write SetWordBoolProp;
    property Active: WordBool index 209 read GetWordBoolProp;
    property DropTarget: WordBool index 210 read GetWordBoolProp write SetWordBoolProp;
    property HelpFile: WideString index 211 read GetWideStringProp write SetWideStringProp;
    property ScreenSnap: WordBool index 212 read GetWordBoolProp write SetWordBoolProp;
    property SnapBuffer: Integer index 213 read GetIntegerProp write SetIntegerProp;
    property DoubleBuffered: WordBool index 214 read GetWordBoolProp write SetWordBoolProp;
    property AlignDisabled: WordBool index 215 read GetWordBoolProp;
    property VisibleDockClientCount: Integer index 216 read GetIntegerProp;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp;
  published
    property Anchors;
    property  ParentColor;
    property  ParentFont;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property AutoScroll: WordBool index 202 read GetWordBoolProp write SetWordBoolProp stored False;
    property AutoSize: WordBool index 203 read GetWordBoolProp write SetWordBoolProp stored False;
    property AxBorderStyle: TOleEnum index 204 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Caption: WideString index -518 read GetWideStringProp write SetWideStringProp stored False;
    property Color: TColor index -501 read GetTColorProp write SetTColorProp stored False;
    property Font: TFont index -512 read GetTFontProp write SetTFontProp stored False;
    property KeyPreview: WordBool index 205 read GetWordBoolProp write SetWordBoolProp stored False;
    property PixelsPerInch: Integer index 206 read GetIntegerProp write SetIntegerProp stored False;
    property PrintScale: TOleEnum index 207 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Scaled: WordBool index 208 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnKeyPress: TAlphaCommXOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnReplyLogin: TAlphaCommXOnReplyLogin read FOnReplyLogin write FOnReplyLogin;
    property OnReplyConnect: TAlphaCommXOnReplyConnect read FOnReplyConnect write FOnReplyConnect;
    property OnRecvRQData: TAlphaCommXOnRecvRQData read FOnRecvRQData write FOnRecvRQData;
    property OnRecvRealData: TAlphaCommXOnRecvRealData read FOnRecvRealData write FOnRecvRealData;
    property OnReplyFileDown: TAlphaCommXOnReplyFileDown read FOnReplyFileDown write FOnReplyFileDown;
    property OnRecvRealOrdData: TAlphaCommXOnRecvRealOrdData read FOnRecvRealOrdData write FOnRecvRealOrdData;
    property OnCloseHost: TAlphaCommXOnCloseHost read FOnCloseHost write FOnCloseHost;
    property OnReceiveRealOrder: TAlphaCommXOnReceiveRealOrder read FOnReceiveRealOrder write FOnReceiveRealOrder;
    property OnReceiveRealHoga: TAlphaCommXOnReceiveRealHoga read FOnReceiveRealHoga write FOnReceiveRealHoga;
    property OnReceRealChegyul: TAlphaCommXOnReceRealChegyul read FOnReceRealChegyul write FOnReceRealChegyul;
    property OnRecvRealPositoin: TAlphaCommXOnRecvRealPositoin read FOnRecvRealPositoin write FOnRecvRealPositoin;
    property OnTemp: TAlphaCommXOnTemp read FOnTemp write FOnTemp;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TAlphaCommX.InitControlData;
const
  CEventDispIDs: array [0..19] of DWORD = (
    $000000C9, $000000CA, $000000CB, $000000CC, $000000CD, $000000CE,
    $000000CF, $000000D0, $000000D1, $000000D2, $000000D3, $000000D4,
    $000000D5, $000000D6, $000000D7, $000000D8, $000000D9, $000000DA,
    $000000DB, $000000DC);
  CTFontIDs: array [0..0] of DWORD = (
    $FFFFFE00);
  CControlData: TControlData2 = (
    ClassID: '{B039AA8A-4C52-4D64-9B18-417439DFFFA3}';
    EventIID: '{F01A68AC-2D34-4CCC-AD05-93BC4CD7151C}';
    EventCount: 20;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $0000001D;
    Version: 401;
    FontCount: 1;
    FontIDs: @CTFontIDs);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnActivate) - Cardinal(Self);
end;

procedure TAlphaCommX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IAlphaCommX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TAlphaCommX.GetControlInterface: IAlphaCommX;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TAlphaCommX.Login(var strUserId: OleVariant; var strUserPswd: OleVariant; 
                            var strCertPsw: OleVariant);
begin
  DefaultInterface.Login(strUserId, strUserPswd, strCertPsw);
end;

procedure TAlphaCommX.RequestData(var strWinID: OleVariant; var strFlag: OleVariant; 
                                  var strGtrCode: OleVariant; var strTrCode: OleVariant; 
                                  var strLen: OleVariant; var strData: OleVariant; 
                                  var strEncrypt: OleVariant);
begin
  DefaultInterface.RequestData(strWinID, strFlag, strGtrCode, strTrCode, strLen, strData, strEncrypt);
end;

procedure TAlphaCommX.ConnectHost(var strIpAddress: OleVariant; var strIpPort: OleVariant);
begin
  DefaultInterface.ConnectHost(strIpAddress, strIpPort);
end;

procedure TAlphaCommX.RegistRealData(var lptrcode: OleVariant; var lpkeyCode: OleVariant);
begin
  DefaultInterface.RegistRealData(lptrcode, lpkeyCode);
end;

procedure TAlphaCommX.GetMasterFile;
begin
  DefaultInterface.GetMasterFile;
end;

procedure TAlphaCommX.FreeObject;
begin
  DefaultInterface.FreeObject;
end;

procedure TAlphaCommX.UnRegistRealData(var strWinID: OleVariant);
begin
  DefaultInterface.UnRegistRealData(strWinID);
end;

procedure TAlphaCommX.CloseHost;
begin
  DefaultInterface.CloseHost;
end;

function TAlphaCommX.GetGridData(var wmid: OleVariant; var btype: OleVariant; 
                                 var stSymbolcode: OleVariant; var index: OleVariant): OleVariant;
begin
  Result := DefaultInterface.GetGridData(wmid, btype, stSymbolcode, index);
end;

function TAlphaCommX.GetRowCount(var wmid: OleVariant): OleVariant;
begin
  Result := DefaultInterface.GetRowCount(wmid);
end;

function TAlphaCommX.GetRealOrderData(var wmid: OleVariant; var btype: OleVariant; 
                                      var trSymbolcode: OleVariant): OleVariant;
begin
  Result := DefaultInterface.GetRealOrderData(wmid, btype, trSymbolcode);
end;

function TAlphaCommX.GetSisedata(var wmid: OleVariant; var byte: OleVariant; 
                                 var stSymbolcode: OleVariant; var index: OleVariant): OleVariant;
begin
  Result := DefaultInterface.GetSisedata(wmid, byte, stSymbolcode, index);
end;

function TAlphaCommX.GetNextData(var wmid: OleVariant): OleVariant;
begin
  Result := DefaultInterface.GetNextData(wmid);
end;

procedure TAlphaCommX.TempData(var s1: OleVariant; var s2: OleVariant; var s3: OleVariant; 
                               var s4: OleVariant);
begin
  DefaultInterface.TempData(s1, s2, s3, s4);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TAlphaCommX]);
end;

end.
