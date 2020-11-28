unit ApiPacket;

interface

type

	TApiEventType = (
    rtNone = 0,
    rtAcntList = 1,
    rtDemoList = 2,
    rtAcntPos = 3,
    rtDeposit = 4,
    rtActiveOrd = 5,
    rtSymbolMaster = 6,
    rtSymbolInfo = 7,
    rtQuote = 8,
    rtOrderAck = 9,
    rtOrder = 10,
    rtNotice = 11
	);

  TCommRecvOpt = (
		TranCode		  , //Tr�ڵ�
		PrevNextCode	, //���ӵ���Ÿ ����(0:����, 1:����, 2:����, 3:����/����)
		PrevNextKey		, //������ȸŰ
		MsgCode			  , //�޽����ڵ�
		Msg				    , //�޽���
		SubMsgCode	  , //�ΰ��޽����ڵ�
		SubMsg			  //�ΰ��޽���
	);

  TCommNoticeType = (
		Connected = 100,		// ���� �Ϸ�
		Connecting = 101,		// ���Ͽ�����
		Closed = 102,			// ���� ���� ����
		Closing = 103,			// ���� ���� ��
		ReconnectRequest = 104,	// ������ ��û
		ConnectFail = 105,		// ���� ���� ����

		//���� ���� �޽���
		NotifyMultiLogin = 150,	// �������� �˸� �޽���
		NotifyEmergency = 151	// ��ް��� �޽���
  );

                                // Event Type,  Tag,  pData ���� ����Ÿ ����
  TCallBackHanaEvent = procedure( iType, iTag, iSize : integer; pData : PChar); cdecl;
                                // �α� Ÿ�� ,  �α�
  TCallBackHanaLog   = procedure( iType : integer; pData:  PChar); cdecl;


  pLogin = function( pData : PChar; iType :integer ) : integer ; cdecl;

  pRegisterCallBack = procedure(	cb1 : TCallBackHanaEvent;
	    cb2:TCallBackHanaLog);  cdecl;
  pInitXLap = function : integer; cdecl;
  pHCommand = function( iType : integer; pData : PChar; iSize : integer ) : integer ; cdecl;
  pConnect  = function( cType : char ) : integer; cdecl;
  pEncript  = function( pData : PChar; iType : integer) : PChar;   cdecl;
  //
  pLogOut = function : integer; cdecl;

  pRequestData = procedure( iDiv, iType, iCnt : integer; pData : PChar ); cdecl;
  pRequestOrder = function( iTag, iCnt : integer; pData : PChar ) : integer ; cdecl;
  pRegisterReal = function( iVal : integer; pData : PChar ) : integer; cdecl;
  pGetRequestCount = function( iDiv, iType : integer ) : integer; cdecl;

  PSignM = ^TSignM;
	TSignM = record
		user : array [0..19] of char;
		pass : array [0..19] of char;
		cpas : array [0..19] of char;
	end;

  PReqSymbolData = ^TReqSymbolData;
  TReqSymbolData = record
    MarketCode : array [0..1] of char;
    GID        : array [0..3] of char;
    Code       : array [0..11] of char;
  end;

  PRegisterData = ^TRegisterData;
  TRegisterData = record
  	resName : array [0..2] of char;
	  regCode : array [0..19] of char;
  end;

  // ---------------------  ��ȸ  --------------------------

  PCommonHeader = ^TCommonHeader;
  TCommonHeader = record
    WindowID  : array [0..9] of char;
    ReqKey    : char;
    ErrorCode : array [0..3] of char;         // ���� or 0000  -> ����
    NextKind  : char;                         // 0 : ���� ����   1: ���� ����
    filler    : array [0..14] of char;
  end;

  PErrorData = ^TErrorData;
  TErrorData = record
    Header : TCommonHeader;
    ErrorMsg  : array [0..99] of char;
  end;    

  POutAccountInfo = ^TOutAccountInfo;
  TOutAccountInfo = record
    Code    : array [0..10] of char;
    Name    : array [0..29] of char;
    Pass    : array [0..7] of char;
  end;

  PSpecFile = ^TSpecFile;
  TSpecFile = record
    PMCode : array [0..2] of char;
    PMName : array [0..29] of char;
    ExCode : array [0..4] of char;
    Sector : array [0..7] of char;
  end;

  POutSymbolListInfo = ^TOutSymbolLIstInfo;
  TOutSymbolLIstInfo = record
    FullCode  : array [0..31] of char;
    ShortCode : array [0..4] of char;
    Index   : array [0..3] of char;
    Name    : array [0..31] of char;
    DecimalInfo   : array [0..4] of char;      // �Ҽ�������
    TickSize      : array [0..19] of char;     // �Ҽ��� 7�ڸ� ����
    PointValue     : array [0..19] of char;    // �ּҰ��ݺ����ݾ� �Ҽ��� 7�ڸ� ����
  end;

  // 5501, 5502  ���񸶽���  , �������簡

  PReqSymbolMaster = ^TReqSymbolMaster;
  TReqSymbolMaster = record
    header : TCommonHeader;
    FullCode  : array [0..31] of char;
    Index     : array [0..3] of char;
  end;

  POutSymbolMaster = ^TOutSymbolMaster;
  TOutSymbolMaster = record
    Header    : TCommonHeader;
    FullCode  : array [0..31] of char;
    DigitDiv : char;       //          (0.10���� 1.32���� 2.64���� 3:128���� 4.8����)
    StandardCode  : array [0..11] of char;

    LimitHighPrice  : array [0..19] of char;
    LimitLowPrice   : array [0..19] of char;
    RemainDays      : array [0..4] of char;
    LastDate        : array [0..7] of char;
    ExpireDate      : array [0..7] of char;

    ListHighPrice : array [0..19] of char;
    ListHighDate  : array [0..7] of char;
    ListLowPrice  : array [0..19] of char;
    ListLowDate   : array [0..7] of char;

    ClosePrice1 : array [0..19] of char;      // �����갡
    ClosePrice2 : array [0..19] of char;      // ��������

    ExChangeCode : array [0..4] of char;
    DispDigit    : array [0..9] of char;

    NewOrdMargin  : array [0..19] of char;  // �ű��ֹ� ���ű�
    CtrtSize      : array [0..19] of char;    // ������

    TickSize      : array [0..19] of char;     // �Ҽ��� 7�ڸ� ����
    TickValue     : array [0..19] of char;    // �ּҰ��ݺ����ݾ� �Ҽ��� 7�ڸ� ����
    PrevVolume    : array [0..19] of char;   // ���ϰŷ���
  end;


  // ��Ʈ ����Ÿ

  PReqChartData = ^TReqChartData;
  TReqChartData = record
	  Header    : TCommonHeader;
		JongUp		: char;                   //	/* '5'�� ����													*/
		DataGb		: char;                   //	/* 1:��															*/
                                        //  /* 2:��															*/
                                        //  /* 3:��															*/
                                        //  /* 4:tick��														*/
                                        //  /* 5:�к�														*/
		DiviGb		: char;                   //	/* ����, �Ϻ��� �׸���� ���� ���Ѵ�: '0'���� ����				*/
		FullCode	: array [0..31] of char;  //	/* ����ǥ���ڵ�													*/
		Index			: array [0..3] of char;   //	/* �ڵ� index													*/
		InxDay		: array [0..7] of char;   //	/* ��������														*/    ��,ƽ�� ����
		DayCnt		: array [0..3] of char;   //	/* ���ڰ���														*/
		Summary		: array [0..2] of char;   //	/* tick, �п��� ������ ����										*/
		Linked		: char;                   //	/* ���ἱ������ Y/N(�Ϻ�)										*/
		JunBonGb	: char;                   //	/* 1.������ 2.���� (��/ƽ��)									*/
  end;

  POutChartDataSub = ^TOutChartDataSub;
  TOutChartDataSub = record
    Date				: array [0..7] of char;   //   /* YYYYMMDD														*/
    Time				: array [0..7] of char;   //  /* �ð�(HH:MM:SS)												*/
    OpenPrice		: array [0..19] of char;  //   /* �ð� double													*/
    HighPrice		: array [0..19] of char;  //   /* �� double													*/
    LowPrice		: array [0..19] of char;  //   /* ���� double													*/
    ClosePrice	: array [0..19] of char;  //   /* ���� double													*/
    Volume			: array [0..19] of char;  //   /* �ŷ��� double
  end;

  POutChartData = ^TOutChartData;
  TOutChartData = record
	  Header    : TCommonHeader;
    FullCode	: array [0..31] of char;    //    /* ����ǥ���ڵ�													*/
    MaxDataCnt: array [0..3] of char;     //    /* ��ü���� ����												*/
    DataCnt		: array [0..2] of char;     //    /* ����۽����� ����											*/
    TickCnt		: array [0..1] of char;     //    /* ���������� tick ����											*/
    Today			: array [0..7] of char;     //    /* �翵����(StockDate[0])										*/
    nonedata	: array [0..3] of char;     //    /* �������� double												*/
    DataGb		: char;            //   /* 1:��															*/
                                  //  /* 2:��															*/
                                  //  /* 3:��															*/
                                  //  /* 4:tick��														*/
                                  //  /* 5:�к�														*/
    DayCnt		: array [0..3] of char;     //    /* ���ڰ���														*/
    Summary		: array [0..2] of char;     //    /* tick, �п��� ������ ����										*/
    PrevLast	: array [0..19] of char;    //    /* ��������														*/
  end;

  ////  �ü� �ڵ� ������Ʈ  -----------------------------------------------------------------
  ///

  TSymbolHogaUnit = record
    Price	: array [0..19] of char;          //	/* ȣ��														*/
    PriceSign : char;
    Volume    : array [0..11] of char;      //  /* ����														*/
    Cnt		    : array [0..6] of char;       //  /*  �Ǽ�													*/
  end;

  TVolumeUd = record
    Volume  : array [0..19] of char;
  end;

  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
    PRDT_CD     : array [0..14] of char;      //   �����ڵ�(����)
    {
    QUOTE_DATE  : array [0..7] of char;       //     ȣ������
    QUOTE_TIME  : array [0..5] of char;       //     ȣ���ð�
    }
    KQUOTE_DATE : array [0..7] of char;       //     �ѱ�ȣ������
    KQUOTE_TIME : array [0..5] of char;       //     �ѱ�ȣ���ð�

    RPT_SEQ     : array [0..7] of char;      //    seq
    TRADE_SESSION_ID : char;                  //   �屸��

    Bids        : array [0..4] of  TSymbolHogaUnit;
    BIDSIZE     : array [0..14] of char;      //     �ż���ȣ������
    BIDCNT      : array [0..9] of char;      //     �ż� ��ü�Ǽ�

    Asks        : array [0..4] of  TSymbolHogaUnit;
    ASKSIZE     : array [0..14] of char;      //     �ŵ���ȣ������
    ASKCNT      : array [0..9] of char;      //      �ŵ� ��ü�Ǽ�
    BID_ASK_SIZE_DIFF : array [0..14] of char;//     �ż��ŵ� ������
    {
    BidChgs     : array [0..3] of TVolumeUd;
    BIDSIZE_ICDC : array [0..19] of char;     //     �ż���ȣ������ ����
    AskChgs      : array [0..3] of TVolumeUd;
    ASKSIZE_ICDC : array [0..19] of char;     //     �ŵ���ȣ������ ����
    }
    DATETIME     : array [0..13] of char;     //     ���Žð�
  end;

  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
    PRDT_CD     : array[0..14] of char;   //  �����ڵ�(����), FID=0;
    TR_DT       : array[0..7] of char;    //  ��������, �ŷ�����, FID=0;
    //TRADE_DATE  : array[0..7] of char;    //  ����, FID=0;
    //TRADE_TIME  : array[0..5] of char;    //  �ð�, FID=0;
    KTRADE_DATE : array[0..7] of char;    //  �ѱ�����, FID=0;
    KTRADE_TIME : array[0..5] of char;    //  �ѱ��ð�, FID=0;
    RPT_SEQ     : array[0..7] of char;    //  seq, FID=0;
    GLOBEX_TP   : char;                   //  �����屸��, FID=0;
    TRDPRC_1    : array[0..19] of char;   //  ���簡, FID=0;
    TRDPRC_1_CLR: char;                   //  [TRDPRC_1]������(+���, -�϶�), FID=0;
    NETCHNG_CLS : char;                   //  ���ϴ�񱸺�, FID=0;
    NETCHNG_1   : array[0..19] of char;   //  ���ϴ��, FID=0;
    //NETCHNG_1_CLR:  char;                 //  [NETCHNG_1]������(+���, -�϶�), FID=0;
    //PCTCHNG_1   : array[0..5] of char;    //  ���ϴ����, FID=0;
    //PCTCHNG_1_CLR : char;                 //  [PCTCHNG_1]������(+���, -�϶�), FID=0;
    TRDVOL_1    : array[0..11] of char;   //  ü�����, FID=0;
    TRDVOL_1_CLR: char;                   //  [TRDVOL_1]������(+���, -�϶�), FID=0;
    ACVOL_1     : array[0..11] of char;   //  ����ü�����, FID=0;
    OPEN_PRC    : array[0..19] of char;   //  �ð�, FID=0;
    //OPEN_PRC_CLR: char;                   // ������(+���, -�϶�), FID=0;
    HIGH_1      : array[0..19] of char;   // ��, FID=0;
    //HIGH_1_CLR  : char;                   // [HIGH_1]������(+���, -�϶�), FID=0;
    LOW_1       : array[0..19] of char;   // ����, FID=0;
    {
    LOW_1_CLR   : char;                   // ������(+���, -�϶�), FID=0;
    OPEN_TIME   : array[0..5] of char;    // �ð��ð�, FID=0;
    HIGH_TIME   : array[0..5] of char;    // ���ð�, FID=0;
    LOW_TIME    : array[0..5] of char;    // �����ð�, FID=0;

    BID_EXEC_SUM  : array[0..14] of char; // ���� ����ü�����(�ż�����), FID=0;
    ASK_EXEC_SUM  : array[0..14] of char; // ���� ����ü�����(�ŵ�����), FID=0;
    BOH_EXEC_SUM  : array[0..14] of char; // ���� ����ü�����(����), FID=0;
    EX_BEST_BID1  : array[0..19] of char; // ü��� �ż� 1ȣ��(�ŷ���), FID=0;
    EX_BEST_BID1_CLR:char;                // ������(+���, -�϶�), FID=0;
    EX_BEST_ASK1  : array[0..19] of char; // ü��� �ŵ� 1ȣ��(�ŷ���), FID=0;
    EX_BEST_ASK1_CLR:char;                // ������(+���, -�϶�), FID=0;
    EX_BEST_BSIZ1 : array[0..11] of char; // ü��� �ż� 1����(�ŷ���), FID=0;
    EX_BEST_ASIZ1 : array[0..11] of char; // ü��� �ŵ� 1����(�ŷ���), FID=0;
    OPENINTEREST  : array[0..11] of char; // �̰�����, FID=0;
    OP_NETCHNG_1  : array[0..11] of char; // ��ü�ᷮ���, FID=0;
    }
  end;


/////////////////////////////////////////////////////?

{$REGION '������ȸ....'}

  /////  Hana Open API
  ///  START
  ///
  //PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountInfo = record
		Account		 : array [0..8] of char;	          //  /* ���հ��¹�ȣ														*/
		PrdtCode	 : array [0..2] of char;            //	/* ��ǰ��ȣ
    Password   : array [0..11] of char;
  end;

  PReqAccountComm = ^TReqAccountComm;
  TReqAccountComm  = record
		trCode: array [0..10] of char;
	  date  : array [0..7] of char;
	  cnt   : array [0..2] of char;
  end;

  PReqAccountData = ^TReqAccountData;
  TReqAccountData  = record
		Comm  : TReqAccountComm;
    Data  : array [0..19] of TReqAccountInfo;
  end;



  /////  Hana Open API
  ///    End

  // 5611   ���� ��ü�� ��ȸ

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Header    : TCommonHeader;
    Account	 : array [0..10] of char;   //	/* ���¹�ȣ														*/
    Pass		 : array [0..7] of char;    //	/* ��й�ȣ														*/
    Trd_gb	 : char;      			        //	/* ü�ᱸ�� (0:��ü 1:ü��2:��ü��)								*/
    Base_dt	 : array [0..7] of char;    //	/* �ֹ�����														*/
    Gubn		 : char;                    //  /* ��ȸ���� (1:���� 2:����)
  end;

  POutAccountFillSub = ^TOutAccountFillSub;
  TOutAccountFillSub = record
		Ord_No				: array [0..4] of char;	  //  /* �ֹ��ֹ�ȣ													*/
		Org_ord_No		: array [0..4] of char;	  //  /* ���ֹ��ι�ȣ													*/
		Trd_cond			: char;                   //	/* ü������ (1.FAS 2.FOK 3.FAK)									*/
		ShortCode			: array [0..31] of char;  //	/* ��������ڵ�													*/
		Bysl_tp				: char;                   // 	/* �Ÿű����ڵ�
                                            //  1.�ż� 2.�ŵ� 3.�ż�����
                                            //  4.�ŵ����� 5.�ż���� 6.�ŵ���� ' '.��Ÿ					*/
		Prce_tp				:char;                    //	/* ��������	(1.������ 2.���尡)									*/
		Ord_q				  : array [0..4] of char;   //	/* �ֹ�����														*/
		Ord_p				  : array [0..19] of char;  //	/* �ֹ����� or ü������											*/
		Trd_q				  : array [0..4] of char;   //	/* ü�����														*/
		Mcg_q				  : array [0..4] of char;   //	/* ��ü�����													*/
		Ord_tp				: char;                   //	/* �ֹ����� (1.�ű� 2.���� 3.���)								*/
		Stop_p				: array [0..19] of char;  //	/* STOP�ֹ�����													*/
		Ex_ord_tm			: array [0..5] of char;   //	/* �ֹ��ð�														*/
		Proc_stat			: char;                   //	/* �ֹ�ó������ (0.�������� 1.�ŷ������� 2.�����ź� 3.FEP�ź�)	*/
		Account				: array [0..10] of char;  //	/* ���¹�ȣ
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Header    : TCommonHeader;
    Renu			: array [0..4] of char;       //	/* �ݺ�Ƚ��														*/
    Account		: array [0..10] of char;      //	/* ���¹�ȣ														*/
    AcctNm		: array [0..19] of char;      //	/* ���¸�														*/
    Dtno			: array [0..4] of char;       //	/* �ݺ�Ƚ��
  end;

  // 5612   ���� ���ܰ� ��ȸ

  PReqAccountPos = ^TReqAccountPos;
  TReqAccountPos = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;    //	/* ���¹�ȣ														*/
    Pass			: array [0..7] of char;     //	/* ��й�ȣ
  end;

  POutAccountPosSub = ^TOutAccountPosSub;
  TOutAccountPosSub = record
		Base_dt				: array [0..7] of char;   //	/* ��������														*/
		FullCode			: array [0..31] of char;  //	/* ����ǥ���ڵ�													*/
		Bysl_tp				: char;                   //  /*   �Ÿű���	(1.�ż� 2.�ŵ�)										*/
		Trd_no				: array [0..4] of char;   //	/* ü���ȣ														*/
		Open_q				: array [0..9] of char;	  //  /* �̰�������													*/
		Avgt_p				: array [0..19] of char;	//  /* ��հ�														*/
		Curr_p				: array [0..19] of char;	//  /* ���簡 														*/
		Open_pl				: array [0..19] of char;	//  /* �򰡼���														*/
		Rsrb_q				: array [0..9] of char;	  //  /* û�갡�ɼ���													*/
		Trd_amt				: array [0..19] of char;	//  /* ü��ݾ�														*/
		Account				: array [0..10] of char;	//  /* ���¹�ȣ
  end;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
	  Header     : TCommonHeader;
		Renu			 : array [0..4] of char;	            //  /* �ݺ�Ƚ��														*/
		Account		 : array [0..10] of char;             //	/* ���¹�ȣ														*/
		AcctNm		 : array [0..19] of char;             //  /* ���¸�														*/
		Dtno			 : array [0..4] of char;              //	/* �ݺ�Ƚ��														*/
  end;

  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Header      : TCommonHeader;
    Account			: array [0..10] of char;          //	/* ���¹�ȣ														*/
    Pass				: array [0..7] of char;           //	/* ��й�ȣ														*/
    ShortCode		: array [0..31] of char;          //	/* �����ڵ�														*/
    Bysl_tp			: char;                           //	/* �ż�/�ŵ����� (1.�ż� 2.�ŵ�)								*/
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
	  Header      : TCommonHeader;
		Renu				: array [0..4] of char;           //	/* �ݺ�Ƚ��														*/
		Account			: array [0..10] of char;          //	/* ���¹�ȣ														*/
		Filler			: array [0..8] of char;
		Ord_q				: array [0..4] of char;           //	/* ���ɼ���														*/
		Chu_q				: array [0..4] of char;           //	/* û�����														*/
  end;

{$ENDREGION}


{$REGION '�ֹ�....'}

  // 5601

  POrderAck = ^TOrderAck;
  TOrderAck = record
    OrderNo : array [0..19] of char;
    OrderID : array [0..9]  of char;
    ErrCode : array [0..9]  of char;
    ErrMsg  : array [0..59] of char;
  end;

  PSendOrderPacket = ^TSendOrderPacket;
  TSendOrderPacket = record

    Order_kind    : char;                        // N, M, C
    ResCode       : array [0..11] of char;
    OrderID       : array [0..9] of char;

		Account			  : array [0..8] of char;       //	/* ���¹�ȣ														*/
    AnctPrd       : array [0..2] of char;       //  ���»�ǰ��ȣ
		Pass				  : array [0..31] of char;       //	/* ��й�ȣ														*/
    PrdtCode      : array [0..31] of char;      // ��ǰ�ڵ�
    BuySell_Type  : char;                       //	/* �ŵ��ż����� (S: �ŵ�, B:�ż�)									*/
    Price_Type    : char;                       //	/* �������Ǳ����ڵ�	(1.������ 2.���尡 3.��ž)									*/

    Order_Price	  : array [0..19] of char;      //	/* �ֹ�����														*/
    Order_Volume  : array [0..4] of char;       //	/* �ֹ�����														*/
    Stop_Price		: array [0..19] of char;      //	/* STOP�ֹ����� (STOP�ֹ��̸� �Է� �ƴϸ� 0 ����)				*/
    Control_Type  : char;                       //	/* �ֹ����۱����ڵ� (C:�Ϲ��ֹ�, M:�ݴ�Ÿ�, F:����û��, D:FND�ݴ�Ÿ�)					*/
		Order_Div	  : char;                         //	/* �ֹ�����  ( O.�ڵ�û��  C.����û��
    EtcOrd_type   : array [0..2] of char;       //     ��Ÿ�ֹ��ڵ�
    Trace_Type    : char;                       //     ü������ (1:FAS(DAY), 6:GTD)

    Order_Org_No	: array [0..15] of char;       //	/* ���ֹ� ��ȣ (					*/
		Position_No	  : array [0..14] of char;       //	/* û�������ǹ�ȣ (					*/
    Order_ExpDay  : array [0..7] of char;        //	/* �ֹ���������												*/

  end;

  POutOrderPacket = ^TOutOrderPacket;
  TOutOrderPacket = record
	  Header        : TCommonHeader;
		Order_No  		: array [0..4] of char;       //	/* �ֹ���ȣ														*/
	  Order_Org_No	: array [0..4] of char;       //	/* ���ֹ���ȣ													*/
		Account				: array [0..10] of char;      //	/* ���¹�ȣ														*/
		Order_Type		: char;                       //	/* �ֹ�����	(1.�ű��ֹ� 2.�����ֹ� 3.����ֹ�)					*/
		ShortCode			: array [0..31] of char;      //	/* ��������ڵ�														*/
		BuySell_Type	: char;                       //	/* �ŵ��ż����� (1.�ż� 2.�ŵ�)									*/
	  Order_Volume	: array [0..4] of char;       //	/* �ֹ�����														*/
	  Order_Price		: array [0..19] of char;      //	/* �ֹ�����														*/
	  Price_Type		: char;                       //	/* ��������	(1.������ 2.���尡)									*/
		Trade_Type		: char;                       //	/* ü������ (���尡�ϰ��(3) �������ϰ��(1))					*/
		Stop_Price		: array [0..19] of char;      //	/* STOP�ֹ�����
  end;

  PAutoOrderPacket = ^TAutoOrderPacket;
  TAutoOrderPacket = record
    rltm_dpch_dcd       : char;                     //    �ǽð��뺸�����ڵ�, FID=0;
    usr_id			        : array [0..19] of char;    //   �����ID, FID=0;
    rltm_dpch_prcs_dcd	: array [0..1] of char;     //    �ǽð��뺸ó�������ڵ�, FID=0;
    cano			          : array [0..7] of char;     //    ���հ��¹�ȣ, FID=0;
    ctno			          : array [0..8] of char;     //    ���հ��´�ü��ȣ, FID=0;
    apno			          : array [0..2] of char;     //    ���»�ǰ��ȣ, FID=0;
    prdt_cd			        : array [0..31] of char;    //    ��ǰ�ڵ�, FID=0;
    odrv_ordr_tp_dcd	  : char;                     //     �ؿ��Ļ��ֹ����������ڵ�, FID=0;
    ordr_stts_dcd		    : char;                     //     �ֹ����±����ڵ�, FID=0;
    odrv_odno		        : array [0..15] of char;    //    �ؿ��Ļ��ֹ���ȣ, FID=0;
    odrv_or_odno		    : array [0..15] of char;    //    �ؿ��Ļ����ֹ���ȣ, FID=0;
    ordr_dt		  	      : array [0..7] of char;     //    �ֹ�����, FID=0;
    //cust_nm			: array [0..50] of char;    //    ����, FID=0;
    odrv_sell_buy_dcd	  : char;                      //    �ؿ��Ļ��ŵ��ż������ڵ�, FID=0;
    odrv_ordr_prc_ctns	: array [0..19] of char;    //    �ؿ��Ļ��ֹ����ݳ���, FID=0;
    ordr_qnt_ctns		    : array [0..19] of char;    //    �ֹ���������, FID=0;
    odrv_prc_dcd		    : char;                     //     �ؿ��Ļ����ݱ����ڵ�, FID=0;
    cncs_cnd_dcd		    : char;                     //    ü�����Ǳ����ڵ�, FID=0;
    cnd_prc_ctns		    : array [0..19] of char;    //    ���ǰ��ݳ���, FID=0;
    comm_mdia_dcd		    : array [0..2] of char;     //    ��Ÿ�ü�����ڵ�, FID=0;
    acpt_tm			        : array [0..5] of char;     //    �����ð�, FID=0;
    excg_cncs_tm		    : array [0..5] of char;     //    �ŷ���ü��ð�, FID=0;
    acpl_acpt_tm		    : array [0..5] of char;     //    ���������ð�, FID=0;
    cncs_tm			        : array [0..5] of char;     //    ü��ð�, FID=0;
    cncs_dt			        : array [0..7] of char;     //    ü������, FID=0;
    odrv_cncs_no		    : array [0..7] of char;     //    �ؿ��Ļ�ü���ȣ, FID=0;
    cncs_qnt_ctns		    : array [0..19] of char;    //    ü���������, FID=0;
    odrv_cncs_prc_ctns	: array [0..19] of char;    //    �ؿ��Ļ�ü�ᰡ�ݳ���, FID=0;
    //odrv_cncs_amt_ctns	: array [0..29] of char;    //    �ؿ��Ļ�ü��ݾ׳���, FID=0;
    crry_cd			        : array [0..2] of char;     //    ��ȭ�ڵ�, FID=0;
    ordr_rmn_qnt_ctns	  : array [0..19] of char;    //    �ֹ��ܿ���������, FID=0;
    acnt_dcd		        : char;                     //    ���±����ڵ�, FID=0;
    entr_clr_dcd		    : char;                     //     ����û�걸���ڵ�, FID=0;
    clr_pst_no		      : array [0..15] of char;    //    û�������ǹ�ȣ, FID=0;
    pst_no			        : array [0..15] of char;    //    �����ǹ�ȣ, FID=0;
  end;


  PAutoOrderResponse = ^TPAutoOrderResponse;
  TPAutoOrderResponse = record
    rltm_dpch_dcd       : char;				                    //  �ǽð��뺸�����ڵ�;
    usr_id              : array [0..19] of char;					//  �����ID;
    rltm_dpch_prcs_dcd  : array [0..1] of char;		        //  �ǽð��뺸ó�������ڵ�;
    cano                : array [0..7] of char;					  //  ���հ��¹�ȣ;
    ctno                : array [0..8] of char;					  //  ���հ��´�ü��ȣ;
    apno                : array [0..2] of char;					  //  ���»�ǰ��ȣ;
    odrv_odno           : array [0..15] of char;				  //  �ؿ��Ļ��ֹ���ȣ;
    prdt_cd             : array [0..31] of char;				  //  ��ǰ�ڵ�;
    odrv_or_odno        : array [0..15] of char;		    	//  �ؿ��Ļ����ֹ���ȣ;
    odrv_mo_odno        : array [0..15] of char;		    	//  �ؿ��Ļ����ֹ���ȣ;
    ordr_grup_no        : array [0..15] of char;			    //  �ֹ��׷��ȣ;
    ordr_dt             : array [0..7] of char;				  	//  �ֹ�����;
    //cust_nm             : array [0..49] of char;			  	//  ����;
    odrv_sell_buy_dcd   : char;		                      	//  �ؿ��Ļ��ŵ��ż������ڵ�;
    odrv_ordr_prc_ctns  : array [0..19] of char;		      //  �ؿ��Ļ��ֹ����ݳ���;
    ordr_qnt_ctns       : array [0..19] of char;			    //  �ֹ���������;
    rvse_qnt_ctns       : array [0..19] of char;			    //  ������������;
    cncl_qnt_ctns       : array [0..19] of char;			    //  ��Ҽ�������;
    cncs_qnt_smm_ctns   : array [0..19] of char;	      	//  ü������հ賻��;
    ordr_rmn_qnt_ctns   : array [0..19] of char;		      //  �ֹ��ܿ���������;
    odrv_prc_dcd        : char;				                    //  �ؿ��Ļ����ݱ����ڵ�;
    cncs_cnd_dcd        : char;				                    //  ü�����Ǳ����ڵ�;
    cnd_prc_ctns        : array [0..19] of char;			    //  ���ǰ��ݳ���;
    avr_cncs_prc_ctns   : array [0..19] of char;		      //  ���ü�ᰡ�ݳ���;
    odrv_pv_ctns        : array [0..19] of char;			    //  �ؿ��Ļ����簡����;
    cncs_rt_ctns        : array [0..19] of char;			    //  ü��������;
    comm_mdia_dcd       : array [0..2] of char;			      //  ��Ÿ�ü�����ڵ�;
    odrv_ordr_tp_dcd    : char;			                      //  �ؿ��Ļ��ֹ����������ڵ�;
    ordr_stts_dcd       : char;				                    //  �ֹ����±����ڵ�;
    //fcm_odno            : array [0..59] of char;				  //  FCM�ֹ���ȣ;
    //athz_ip_addr        : array [0..38] of char;			    //  ����IP�ּ�;
    acpt_tm             : array [0..5] of char;					  //  �����ð�;
    excg_cncs_tm        : array [0..5] of char;			      //  �ŷ���ü��ð�;
    acpl_acpt_tm        : array [0..5] of char;			      //  ���������ð�;
    cncs_tm             : array [0..5] of char;					  //  ü��ð�;
    crry_cd             : array [0..2] of char;					  //  ��ȭ�ڵ�;
    cncs_qnt_ctns       : array [0..19] of char;			    //  ü���������;
    ordr_expr_dt        : array [0..7] of char;			      //  �ֹ���������;
    acnt_dcd            : char;					                  //   ���±����ڵ�;
    entr_clr_dcd        : char;				                    //  ����û�걸���ڵ�;
    clr_pst_no          : array [0..15] of char;				  //  û�������ǹ�ȣ;
  end;

{$ENDREGION}


Const
  Len_AccountInfo   = SizeOf( TOutAccountInfo );
  Len_SymbolListInfo = SizeOf( TOutSymbolListInfo );
  Len_OutSymbolMaster = sizeof( TOutSymbolMaster );

  Len_ReqChartData = sizeof( TReqChartData );
  Len_OutChartData = sizeof( TOutChartData );
  Len_OutChartDataSub = sizeof( TOutChartDataSub );
  // ����
  // �ֹ�����Ʈ ��û
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFillSub = sizeof( TOutAccountFillSub );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // �ܰ�
  Len_ReqAccountPos = sizeof( TReqAccountPos );
  Len_OutAccountPos = sizeof( TOutAccountPOs );
  Len_OutAccountPosSub = sizeof( TOutAccountPosSub );
  // ������
  //Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  //Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // ���ɼ���
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  

      //  �ü�
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );

      //  �ֹ�
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_AutoOrderPacket = sizeof( TAutoOrderPacket );
  Len_AutoOrderResponse = sizeof( TPAutoOrderResponse );


  ApieEventName : array [ TApiEventType ] of string = ('None', 'AcntList',
    'DemoList','AcntPos','Deposit','ActiveOrd','SymbolMaster','SymbolInfo',
    'Qutoe','OrderAck','Order','Notice' );  


implementation



end.
