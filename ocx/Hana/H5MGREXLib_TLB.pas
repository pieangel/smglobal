unit H5MGREXLib_TLB;

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
// File generated on 2016-09-28 ¿ÀÀü 9:28:58 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Hi5Pro_2014\exe\H5MgrEx.ocx (1)
// LIBID: {7A5992FB-9FA5-4C7F-8B4B-83E3396EF6BD}
// LCID: 0
// Helpfile: C:\Hi5Pro_2014\exe\H5MgrEx.hlp
// HelpString: H5MgrEx ActiveX Control module
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Errors:
//   Hint: Parameter 'type' of _DH5MgrEx.HFCommand changed to 'type_'
//   Hint: Parameter 'type' of _DH5MgrEx.HFCommandDotNet changed to 'type_'
//   Hint: Parameter 'type' of _DH5MgrEx.HFCommandVB changed to 'type_'
//   Hint: Parameter 'type' of _DH5MgrExEvents.Receive changed to 'type_'
//   Hint: Parameter 'type' of _DH5MgrExEvents.ReceiveDotNet changed to 'type_'
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
  H5MGREXLibMajorVersion = 1;
  H5MGREXLibMinorVersion = 0;

  LIBID_H5MGREXLib: TGUID = '{7A5992FB-9FA5-4C7F-8B4B-83E3396EF6BD}';

  DIID__DH5MgrEx: TGUID = '{04E517F9-FEAF-4BD9-AAAB-6DFA9A1C2653}';
  DIID__DH5MgrExEvents: TGUID = '{3EDE6F27-1E17-4612-88CB-824EF5B3FA59}';
  CLASS_H5MgrEx: TGUID = '{D14DF671-2FFD-49BD-AD49-BF2E436EA6A4}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DH5MgrEx = dispinterface;
  _DH5MgrExEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  H5MgrEx = _DH5MgrEx;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// DispIntf:  _DH5MgrEx
// Flags:     (4112) Hidden Dispatchable
// GUID:      {04E517F9-FEAF-4BD9-AAAB-6DFA9A1C2653}
// *********************************************************************//
  _DH5MgrEx = dispinterface
    ['{04E517F9-FEAF-4BD9-AAAB-6DFA9A1C2653}']
    function HFCommand(type_: Integer; pBytes: Integer; nBytes: Integer): Integer; dispid 1;
    function HFCommandDotNet(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer; dispid 2;
    function HFCommandVB(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer; dispid 3;
    function HFString(value: Integer): WideString; dispid 4;
    function HFStringEx(value: Integer; length: Integer; var dats: WideString): Integer; dispid 5;
    procedure AboutBox; dispid -552;
  end;

// *********************************************************************//
// DispIntf:  _DH5MgrExEvents
// Flags:     (4096) Dispatchable
// GUID:      {3EDE6F27-1E17-4612-88CB-824EF5B3FA59}
// *********************************************************************//
  _DH5MgrExEvents = dispinterface
    ['{3EDE6F27-1E17-4612-88CB-824EF5B3FA59}']
    procedure Receive(type_: Integer; pBytes: Integer; nBytes: Integer); dispid 1;
    procedure ReceiveDotNet(type_: Integer; const pBytes: WideString; nBytes: Integer); dispid 2;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TH5MgrEx
// Help String      : H5MgrEx Control
// Default Interface: _DH5MgrEx
// Def. Intf. DISP? : Yes
// Event   Interface: _DH5MgrExEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TH5MgrExReceive = procedure(ASender: TObject; type_: Integer; pBytes: Integer; nBytes: Integer) of object;
  TH5MgrExReceiveDotNet = procedure(ASender: TObject; type_: Integer; const pBytes: WideString; 
                                                      nBytes: Integer) of object;

  TH5MgrEx = class(TOleControl)
  private
    FOnReceive: TH5MgrExReceive;
    FOnReceiveDotNet: TH5MgrExReceiveDotNet;
    FIntf: _DH5MgrEx;
    function  GetControlInterface: _DH5MgrEx;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function HFCommand(type_: Integer; pBytes: Integer; nBytes: Integer): Integer;
    function HFCommandDotNet(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer;
    function HFCommandVB(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer;
    function HFString(value: Integer): WideString;
    function HFStringEx(value: Integer; length: Integer; var dats: WideString): Integer;
    procedure AboutBox;
    property  ControlInterface: _DH5MgrEx read GetControlInterface;
    property  DefaultInterface: _DH5MgrEx read GetControlInterface;
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
    property OnReceive: TH5MgrExReceive read FOnReceive write FOnReceive;
    property OnReceiveDotNet: TH5MgrExReceiveDotNet read FOnReceiveDotNet write FOnReceiveDotNet;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TH5MgrEx.InitControlData;
const
  CEventDispIDs: array [0..1] of DWORD = (
    $00000001, $00000002);
  CControlData: TControlData2 = (
    ClassID: '{D14DF671-2FFD-49BD-AD49-BF2E436EA6A4}';
    EventIID: '{3EDE6F27-1E17-4612-88CB-824EF5B3FA59}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnReceive) - Cardinal(Self);
end;

procedure TH5MgrEx.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DH5MgrEx;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TH5MgrEx.GetControlInterface: _DH5MgrEx;
begin
  CreateControl;
  Result := FIntf;
end;

function TH5MgrEx.HFCommand(type_: Integer; pBytes: Integer; nBytes: Integer): Integer;
begin
  Result := DefaultInterface.HFCommand(type_, pBytes, nBytes);
end;

function TH5MgrEx.HFCommandDotNet(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer;
begin
  Result := DefaultInterface.HFCommandDotNet(type_, pBytes, nBytes);
end;

function TH5MgrEx.HFCommandVB(type_: Integer; var pBytes: WideString; nBytes: Integer): Integer;
begin
  Result := DefaultInterface.HFCommandVB(type_, pBytes, nBytes);
end;

function TH5MgrEx.HFString(value: Integer): WideString;
begin
  Result := DefaultInterface.HFString(value);
end;

function TH5MgrEx.HFStringEx(value: Integer; length: Integer; var dats: WideString): Integer;
begin
  Result := DefaultInterface.HFStringEx(value, length, dats);
end;

procedure TH5MgrEx.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TH5MgrEx]);
end;

end.
