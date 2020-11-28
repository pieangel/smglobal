unit ApiConsts;

interface

const

  DLL_NAME =  'HanaXLap.dll';

  // DLL 함수 이름들..
  DLL_REGI_CALLBACK = 'RegisterCallBack';
  DLL_INIT = 'InitXLap';

  DLL_LOGIN  = 'Login';
  DLL_LOGOUT = 'LogOut';

  DLL_REQUEST = 'RequestData';
  DLL_ORDER   = 'RequestOrder';
  DLL_REG_REAL= 'RegisterReal';

  DLL_GET_CNT = 'GetRequestCount';
  // DLL 로그 타입
	ERR	 = -1;
  INF	 = 1 ;
	DEG	 = 0 ;
  CMF = 2;
	FID = 0;
  TRD = 1;

  END_EVENT = 9999;
  QTE_HOGA  = 10000;
	QTE_FILL  = 10001;

  ORD_ACPT =	10002;
  ORD_FILL =	10003;

implementation


end.
