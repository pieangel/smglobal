unit Uconsts;

interface

const

	loginERR	=	$99;		// type : HIWORD(wParam)
	runAXIS		=	$00;		//
	noticePAN	=	$0c;		// text : lParam
	dialogPAN	=	$0d;		// type : HIWORD(wParam), data  : lParam
	menuAXIS	=	$12;		// load menu
	closeAXIS	=	$14;		// terminate AXIS
						// reboot : HIWORD(wParam)
 runDUAL		=	$19;		// [DUAL-SESSION] : DualSession

  DLL_REGI_CALLBACK = 'RegisterCallBack';
  DLL_INIT = 'InitXLap';
  DLL_HCommnad = 'HCommand';
  DLL_Connect  = 'Connect';
  DLL_Encript  = 'Encript';

  DLL_LOGIN  = 'Login';
  DLL_LOGOUT = 'LogOut';
  DLL_REQUEST_ACCOUNT = 'RequestAccount';
  DLL_REQUEST_SYMBOLMASTER  = 'RequestSymbolMaster';


implementation

end.
