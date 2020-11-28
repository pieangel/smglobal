unit UTypes;

interface

uses
  Windows
  ;

type

	TApiEventType = (
		AcntList = 0,
		DemoAcntList = 1,
		AcntPos = 2,
		ActiveOrd = 3,
		Deposit = 4,
		SymbolMaster = 6
	);

  pLogin = function( pData : PChar; iType :integer ) : integer ; cdecl;

  TCallBackHanaEvent = procedure( iType, iTag, iSize : integer; pData : PChar); cdecl;
  TCallBackHanaLog   = procedure( iType : integer; pData:  PChar); cdecl;

  pRegisterCallBack = procedure(	cb1 : TCallBackHanaEvent;
	    cb2:TCallBackHanaLog);  cdecl;
  pInitXLap = function : integer; cdecl;
  pHCommand = function( iType : integer; pData : PChar; iSize : integer ) : integer ; cdecl;
  pConnect  = function( cType : char ) : integer; cdecl;
  pEncript  = function( pData : PChar; iType : integer) : PChar;   cdecl;
  //
  pLogOut = function : integer; cdecl;
  pRequestAccount = procedure ; cdecl;
  pRequestSymbolMaster = procedure; cdecl;

  PSignM = ^TSignM;
	TSignM = record
		user : array [0..19] of char;
		pass : array [0..19] of char;
		cpas : array [0..19] of char;
	end;

  PData = ^TData;
  TData = record
		key : array  [0..19] of char;
		pass : array [0..19] of char;
  end;

  PhfcallH = ^ThfcallH;
  ThfcallH = record
		key   : char;			                  // receive key
		stat  : char;		                    //
		bizH  : char;		                    // 1 - ledgerH setting, else ledgerH no setting
		bizK  : array [0..5] of char;		    // if bizH[0] == '1', user data setting
		trx_Name  : array [0..7] of char;		// Tx name : pibotuxq
		svc_Name  : array [0..9] of char;		// service name
		job_cod   : char;		                // '1' setting
		max_row   : array [0..2] of char;		// if need, request data cnt
		next_key  : array [0..49] of char;	// next_key, 	add 2013.01.30
		contf     : char;		                // 연속거래구분 (0:정상, 1:연속거래) add 2013.02.15
  end;

  PledgerH = ^TledgerH;
  TledgerH = record
		tran  : array [0..3] of char;	//   0	tr_code			TR CODE(화면번호)
		svcn  : array [0..9] of char;	//   4	svc_name		TUXEDO Service Name
		svr   : array [0..1] of char;		//  14	src_svr			Channel Server
				//				T1:업무계, T2:Call Center, H1:HTS(영업점), H2:HTS(고객),  W1:Wrap
				//				M1:MTS,    H3:WTS,         I1:인터넷뱅킹,  R1:ARS,        P1:011
				//				P6:016,    P7:017,         P8:018,         P9:019,        N1:AirPost
				//				N2:Micess, K1:방카,        X1:CRM,         E1:ERP,        Z1:RM
				//				N3:PDA,    B1:은행(CD),    B2:은행(기타),  C1:현금지급기, D1:시스템
				//				F1:FIX,    I2:홈페이지
		pgm   : array [0..7] of char;		//  16	pgm_id			Program ID

		idno  : array [0..11] of char;	//  24	id_no			사번
		regno : array [0..12] of char;	//  36	reg_no			사용자 주민등록번호
		group : array [0..1] of char;	//  49	emp_grp			사용자 그룹
		open  : array [0..2] of char;	//  51	open_dept		소속점
		dept  : array [0..2] of char;	//  54	dept_cd			부서 (처리점)
		term  : array [0..7] of char;	//  57	term_id			단말기번호
		ips   : array [0..14] of char;	//  65	ip_no			IP Address

		media : char;	//  80	mdr_cd			입력매체구분 (0:수기, 1:카드, 2:통장, 3:책임자카드)
		gubn  : char;	//  81	job_cd			작업구분 (1:Query, 2:Insert, 3:Update, 4:Delete)
		rows  : array [0..2] of char;	//  82	max_row			GRID MAX ROW
		book  : array [0..9] of char;	//  85	book_seq		통장번호
		card  : array [0..7] of char;	//  95	card_seq		카드일련번호
		report: char;	// 103	rpt_tool_use_cd		레포팅툴 사용구분 (0:TR, 1:Use Tool)

		optp  : char;	// 104	mgr_appr_tp		책임자 승인구분 (0:발생전, 1:대상 및 요청, 2:승인, 3:취소)
		opid  : array [0..4] of char;	// 105	mgr_appr_empno		승인 책임자 사번
		optm  : array [0..7] of char;	// 110	mgr_appr_term_id	책임자승인단말번호
		opno  : array [0..4] of char;	// 118	mgr_appr_seqno		책임자 승인번호
		opn   : char;		// 123	mgr_appr_cnt		책임자승인건수
		opgb  : char;	// 124	mgr_job_cd		책임자 업무구분
		opcd  : char;	// 125	mgr_card_cd		책임자카드구분 (1:지점장, 3:책임자)

		func  : char;	// 126	tr_fnkey		처리기능구분(사용자 지정)
		ecode : array [0..5] of char;	// 127	tr_err_code		에러코드
		etype : char;	// 133	tr_err_cd		에러구분 (0:상태바, 1:메세지박스, 3:메세지처리없음)
		msg   : array [0..129] of char;	// 134	tr_err_msg		에러메시지
		contf : char;	// 264	tr_cont_yn		연속거래구분 (0:정상, 1:연속거래)

		nrec  : array [0..3] of char;	// 265	tr_cnt			처리건수
		keys  : array [0..5] of char;	// 269	lst_key			row 처리 last key
		next  : array [0..49] of char;	// 275	next_key		next key
		svcno : array [0..3] of char;	// 325	svc_no			service no
		mts   : array [0..4] of char;		// 329	mts_key			mts key
	//	rsv[66];	// 334	filler
		rsv   : array [0..59] of char;
		apik  : array [0..5] of char;
  end;


implementation

const
  Len_TledgerH = sizeof( TledgerH );

end.
