unit ApiPacket;

interface

type
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

  POutSymbolMarkePrice = ^TOutSymbolMarkePrice;
  TOutSymbolMarkePrice = record
	  Header    : TCommonHeader;
		FullCode  		 : array [0..31] of char ;    //	/* ����ǥ���ڵ�													*/
		JinbubGb  		 : char;	                    //  /* ���� (0.10���� 1.32���� 2.64���� 3.128���� 4.8����)			*/
		ISINCd   			 : array [0..11] of char;     //	/* ����ǥ���ڵ�													*/
		ClosePrice		 : array [0..19] of char;     //	/* ���簡														*/
		CmpSign				 : char;                      //	/* ����ȣ
											                          //  0.���� 1.���� 2.���� 3.��� 4.�϶� 5.�⼼����
											                          //  6.�⼼���� 7.�⼼��� 8.�⼼�϶�							*/
		CmpPrice			 : array [0..19] of char;	    //  /* ���ϴ��9(5)V9(2)											*/
		CmpRate				 : array [0..7] of char;	    //  /* �����9(5)V9(2) 												*/
		OpenPrice			 : array [0..19] of char;	    //  /* �ð� 														*/
		HighPrice			 : array [0..19] of char;	    //  /* �� 														*/
		LowPrice			 : array [0..19] of char;	    //  /* ���� 														*/
		ContQty				 : array [0..19] of char;	    //  /* ü�ᷮ 														*/
		TotQty 				 : array [0..19] of char;	    //  /* �ŷ��� 														*/
		ClosePrice_1	 : array [0..19] of char;	    //  /* Close Price 1
  end;

  TSymbolHogaUnit = record
    BuyNo			: array [0..9] of char;       //	/* �ż���ȣ														*/
    BuyPrice	: array [0..19] of char;      //	/* �ż�ȣ��														*/
    BuyQty		: array [0..19] of char;      //  /* �ż�����														*/
    SellNo		: array [0..9] of char;       //	/* �ŵ���ȣ														*/
    SellPrice	: array [0..19] of char;      //	/* �ŵ�ȣ��														*/
    SellQty		: array [0..19] of char;      //	/* �ŵ�����
  end;

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..31] of char;    //	/* ����ǥ���ڵ�													*/
		JinbubGb 		: char;                     //	/* ���� (0.10���� 1.32���� 2.64���� 3.128���� 4.8����)			*/
    StandarCode 		: array [0..11] of char;    //	/* ����ǥ���ڵ�													*/
		Time				: array [0..7] of char;     //	/* �ð�(HH:MM:SS)												*/
		ClosePrice_1: array [0..19] of char;    //	/* Close Price 1												*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..19] of char;    //	/* �ŵ���ȣ������9(6)											*/
		TotBuyQty		: array [0..19] of char;    //	/* �ż���ȣ������9(6)											*/
		TotSellNo		: array [0..19] of char;    //	/* �ŵ���ȣ���Ǽ�9(5)											*/
		TotBuyNo		: array [0..19] of char;    //	/* �ż���ȣ���Ǽ�9(5)
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


  PSendAutoKey = ^TSendAutoKey ;
  TSendAutoKey = record
    header : TCommonHeader;
    AutoKey  : array [0..31] of char;      // /* ������ ��� ���¹�ȣ, �ü� ��� ����ǥ���ڵ�
  end;

  ////  �ü� �ڵ� ������Ʈ  -----------------------------------------------------------------
  ///



  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..31] of char;    //	/* ����ǥ���ڵ�													*/
		JinbubGb 		: char;                     //	/* ���� (0.10���� 1.32���� 2.64���� 3.128���� 4.8����)			*/
		Time				: array [0..7] of char;     //	/* �ð�(HH:MM:SS)												*/
		ClosePrice_1: array [0..19] of char;    //	/* Close Price 1												*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..19] of char;    //	/* �ŵ���ȣ������9(6)											*/
		TotBuyQty		: array [0..19] of char;    //	/* �ż���ȣ������9(6)											*/
		TotSellNo		: array [0..19] of char;    //	/* �ŵ���ȣ���Ǽ�9(5)											*/
		TotBuyNo		: array [0..19] of char;    //	/* �ż���ȣ���Ǽ�9(5)
  end;

  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
	  Header    : TCommonHeader;
		FullCode	: array [0..31] of char;    //	/* ����ǥ���ڵ� 												*/
		JinbubGb  : char;                     //	/* ���� (0.10���� 1.32���� 2.64���� 3.128���� 4.8����)			*/
		Time			: array [0..7] of char;     //	/* �ð�(HH:MM:SS)												*/
		CmpSign		: char;                     //	/* ����ȣ
                                          //   1.���� 2.���� 3.��� 4.�϶� 5.�⼼����
                                          //   6, �⼼���� 7.�⼼��� 8.�⼼�϶�							*/
		CmpPrice	: array [0..19] of char;    //	/* ���ϴ��														*/
		ClosePrice  : array [0..19] of char;  //	/* ���簡														*/
		CmpRate			: array [0..7] of char;   //	/* �����9(5)V9(2)												*/
		TotQty 			: array [0..19] of char;  //	/* �ŷ��� 														*/
		ContQty			: array [0..19] of char;  //	/* ü�ᷮ 														*/
		MatchKind		: char;                   //	/* ���簡�� ȣ������ (+.�ż� -.�ŵ�)							*/
		Date				: array [0..7] of char;     //	/* ����(YYYYMMDD) 												*/
		OpenPrice		: array [0..19] of char;  //	/* �ð� 														*/
		HighPrice		: array [0..19] of char;  //	/* �� 														*/
		LowPrice		: array [0..19] of char;  //	/* ���� 														*/
		BuyPrice		: array [0..19] of char;  //	/* �ż�ȣ��														*/
		SellPrice		: array [0..19] of char;  //	/* �ŵ�ȣ��														*/
		MarketFlag	: char;                   //	/* �屸�� 0.���� 1.������										*/
		DecLen			: array [0..4] of char;   //	/* ���� �Ҽ��� ����
  end;


/////////////////////////////////////////////////////?

{$REGION '������ȸ....'}

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

  // 5615  ��Ź�ڻ�� ���ű�
  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;	          //  /* ���¹�ȣ														*/
		Pass			 : array [0..7] of char;            //	/* ��й�ȣ														*/
		Crc_cd		 : array [0..2] of char;            //	/* ��ȭ�ڵ�	(USD �� �⺻���� ���)
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
	  Header      : TCommonHeader;
		Renu			  : array 	[0..4] of char;         //  /* �ݺ�Ƚ�� 													*/
		AcctNm			: array [0..19] of char;	      //  /* ���¸�														*/
		Entr_ch			: array [0..19] of char;	      //  /* ��Ź���ܾ�													*/
		tdy_repl_amt: array [0..19] of char;	      //  /* ��ȭ���ݾ�(�߰�)											*/
		repl_use_amt: array [0..19] of char;	      //  /* ��ȭ�����ݾ�(�߰�)										*/
		Fut_rsrb_pl	: array [0..19] of char;	      //  /* û�����														*/
		Pure_ote_amt: array [0..19] of char;	      //  /* �򰡼���														*/
		Fut_trad_fee: array [0..19] of char;	      //  /* ������														*/
		Dfr_amt			: array [0..19] of char;	      //  /* �̼��ݾ�														*/
		Te_amt			: array [0..19] of char;	      //  /* ��Ź�ڻ��򰡾�												*/
		Open_pos_mgn: array [0..19] of char;	      //  /* �̰������ű�													*/
		Ord_mgn			: array [0..19] of char;	      //  /* �ֹ����ű�													*/
		Trst_mgn		: array [0..19] of char;	      //  /* ��Ź���ű�													*/
		Mnt_mgn			: array [0..19] of char;	      //  /* �������ű�													*/
		With_psbl_amt		 : array [0..19] of char;	  //  /* ���Ⱑ�ɱݾ�													*/
		krw_with_psbl_amt: array [0..19] of char;	  //  /* ��ȭ���Ⱑ�ɱݾ�												*/
		Add_mgn				: array [0..19] of char;	    //  /* �߰����ű�													*/
		Ord_psbl_amt	: array [0..19] of char;	    //  /* �ֹ����ɱݾ�													*/
		Han_psbl_amt	: array [0..19] of char;	    //  /* ȯ�����ݾ�													*/
		Crc_cd				: array [0..2] of char;	      //  /* ��ȭ�ڵ�
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

  PSendOrderPacket = ^TSendOrderPacket;
  TSendOrderPacket = record
	  Header        : TCommonHeader;
		Account			  : array [0..10] of char;      //	/* ���¹�ȣ														*/
		Pass				  : array [0..7] of char;       //	/* ��й�ȣ														*/
		Order_Type	  : char;                       //	/* �ֹ�����	(1.�ű��ֹ� 2.�����ֹ� 3.����ֹ�)					*/
		ShortCode		  : array [0..31] of char;      //	/* ��������ڵ�													*/
		BuySell_Type  : char;                       //	/* �ŵ��ż����� (1.�ż� 2.�ŵ�)									*/
	  Price_Type    : char;                       //	/* ��������	(1.������ 2.���尡)									*/
		Trace_Type		: char;                       //	/* ü������ (���尡�ϰ��(3) �������ϰ��(1))					*/
	  Order_Price	  : array [0..19] of char;      //	/* �ֹ�����														*/
	  Order_Volume  : array [0..4] of char;       //	/* �ֹ�����														*/
		Order_Org_No	: array [0..4] of char;       //	/* ���ֹ���ȣ (����/��ҽø�)									*/
    Order_Comm_Type		: char;                   //	/* ����ֹ�����													*/
		Stop_Type			: char;                       //	/* �ֹ��������� (1.�Ϲ��ֹ� 2.STOP�ֹ�)							*/
		Stop_Price		: array [0..19] of char;      //	/* STOP�ֹ����� (STOP�ֹ��̸� �Է� �ƴϸ� 0 ����)				*/
		Oper_Type			: char;                       //	/* �ֹ�����	(1.�ű��ֹ� 2.�����ֹ� 3.����ֹ�)
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
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;      // 	/* ���¹�ȣ														*/
		ReplyType			: char;                       //	/* ��������
                                                //  1.�ֹ����� 2.ü�� 3.����Ȯ�� 4.���Ȯ��
                                                //  5.�ű԰ź� 6.�����ź� 7.��Ұź� 0.��������					*/
		FullCode			: array [0..31] of char;      //	/* �����ڵ� (���������϶� ǥ���ڵ�, �׿� �����ڵ�)				*/
		Side				  : char;                       //	/* �ż�/�ŵ����� (1.�ż� 2.�ŵ�)								*/
		Qty					  : array [0..19] of char;      //	/* �ֹ�����														*/
		Modality			: char;                       //	/* ��������	(1.������ 2.���尡)									*/
		Price				  : array [0..19] of char;      //	/* �ֹ�����														*/
		Validity			: char;                       //	/* ü������ (1.FAS 2.FOK 3.FAK 4.GTC 5.GTD)						*/
		StopLossLimit	: array [0..19] of char;      //	/* stop order ��������											*/
		ExecPrice			: array [0..19] of char;      //	/* ü�ᰡ��														*/
		ExecQty				: array [0..19] of char;      //	/* ü�����														*/
		RemainQty			: array [0..19] of char;      //	/* �ֹ��ܷ�														*/
		Ord_no				: array [0..4] of char;       //	/* �ֹ���ȣ														*/
		Orig_ord_no		: array [0..4] of char;       //	/* ���ֹ���ȣ													*/
		TradeTime			: array [0..7] of char;       //	/* �ֹ�Ȯ��,ü��,�ź� �ð�										*/
		ExecAmt				: array [0..19] of char;      //	/* ü��ݾ�														*/
		ORD_TP 				: char;                       //	/* �ֹ�����	(ReplyType==0�϶� 1.�ű� 2.���� 3.���)				*/
	  Trd_no				: array [0..4] of char;       //   /* ü���ȣ														*/
	  Trd_date			: array [0..7] of char;       //   /* ü������														*/
		Rsrb_q				: array [0..9] of char;       //	/* û�갡�ɼ���													*/
		Open_q				: array [0..9] of char;       //	/* �ܰ����														*/
		Open_tp				: char;                       //	/* �ܰ������Ǳ��� (1.�ż� 2.�ŵ�)								*/
	  Ordp_q				: array [0..9] of char;       //   /* �ֹ����ɼ���
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
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // ���ɼ���
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // �ǽð� ��û
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // ü��
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );

  //
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_AutoOrderPacket = sizeof( TAutoOrderPacket );

implementation

end.
