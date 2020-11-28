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
		contf     : char;		                // ���Ӱŷ����� (0:����, 1:���Ӱŷ�) add 2013.02.15
  end;

  PledgerH = ^TledgerH;
  TledgerH = record
		tran  : array [0..3] of char;	//   0	tr_code			TR CODE(ȭ���ȣ)
		svcn  : array [0..9] of char;	//   4	svc_name		TUXEDO Service Name
		svr   : array [0..1] of char;		//  14	src_svr			Channel Server
				//				T1:������, T2:Call Center, H1:HTS(������), H2:HTS(��),  W1:Wrap
				//				M1:MTS,    H3:WTS,         I1:���ͳݹ�ŷ,  R1:ARS,        P1:011
				//				P6:016,    P7:017,         P8:018,         P9:019,        N1:AirPost
				//				N2:Micess, K1:��ī,        X1:CRM,         E1:ERP,        Z1:RM
				//				N3:PDA,    B1:����(CD),    B2:����(��Ÿ),  C1:�������ޱ�, D1:�ý���
				//				F1:FIX,    I2:Ȩ������
		pgm   : array [0..7] of char;		//  16	pgm_id			Program ID

		idno  : array [0..11] of char;	//  24	id_no			���
		regno : array [0..12] of char;	//  36	reg_no			����� �ֹε�Ϲ�ȣ
		group : array [0..1] of char;	//  49	emp_grp			����� �׷�
		open  : array [0..2] of char;	//  51	open_dept		�Ҽ���
		dept  : array [0..2] of char;	//  54	dept_cd			�μ� (ó����)
		term  : array [0..7] of char;	//  57	term_id			�ܸ����ȣ
		ips   : array [0..14] of char;	//  65	ip_no			IP Address

		media : char;	//  80	mdr_cd			�Է¸�ü���� (0:����, 1:ī��, 2:����, 3:å����ī��)
		gubn  : char;	//  81	job_cd			�۾����� (1:Query, 2:Insert, 3:Update, 4:Delete)
		rows  : array [0..2] of char;	//  82	max_row			GRID MAX ROW
		book  : array [0..9] of char;	//  85	book_seq		�����ȣ
		card  : array [0..7] of char;	//  95	card_seq		ī���Ϸù�ȣ
		report: char;	// 103	rpt_tool_use_cd		�������� ��뱸�� (0:TR, 1:Use Tool)

		optp  : char;	// 104	mgr_appr_tp		å���� ���α��� (0:�߻���, 1:��� �� ��û, 2:����, 3:���)
		opid  : array [0..4] of char;	// 105	mgr_appr_empno		���� å���� ���
		optm  : array [0..7] of char;	// 110	mgr_appr_term_id	å���ڽ��δܸ���ȣ
		opno  : array [0..4] of char;	// 118	mgr_appr_seqno		å���� ���ι�ȣ
		opn   : char;		// 123	mgr_appr_cnt		å���ڽ��ΰǼ�
		opgb  : char;	// 124	mgr_job_cd		å���� ��������
		opcd  : char;	// 125	mgr_card_cd		å����ī�屸�� (1:������, 3:å����)

		func  : char;	// 126	tr_fnkey		ó����ɱ���(����� ����)
		ecode : array [0..5] of char;	// 127	tr_err_code		�����ڵ�
		etype : char;	// 133	tr_err_cd		�������� (0:���¹�, 1:�޼����ڽ�, 3:�޼���ó������)
		msg   : array [0..129] of char;	// 134	tr_err_msg		�����޽���
		contf : char;	// 264	tr_cont_yn		���Ӱŷ����� (0:����, 1:���Ӱŷ�)

		nrec  : array [0..3] of char;	// 265	tr_cnt			ó���Ǽ�
		keys  : array [0..5] of char;	// 269	lst_key			row ó�� last key
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
