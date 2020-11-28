unit ApiPacket;

interface

type
  // ---------------------  ��ȸ  --------------------------

  POptItem = ^TOptItem;
  TOptItem = record
    comd : array [1..16] of char;       //* symbol code              */
    exnm : array  [1..8] of char;       //* symbol name (english)    */
    exch : array [1..2] of char;        //* exchange section     */
    enam : array [1..30] of char;       //* symbol name (english)    */
    name : array [1..30] of char;       //* symbol name              */
    stype: char;                        //* symbol type('O')         */
    trdf : char;                        //* trading flag (1: tradable)   */
    prod : array [1..2] of char;        //* production section       */
    pind : char;                        //* price indicator      */
    tsiz : array [1..9] of char;        //* tick size            */
    tval : array [1..9] of char;        //* tick value               */
    adjv : array [1..7] of char;        //* adjustment value         */
    csiz : array [1..9] of char;        //* cab tick size            */
    cval : array [1..7] of char;        //* cab value            */
    stid : char;                        //* strike indicator             */
    osty : char;                        //* option style         */
                                        //* 1: American, 2: European */
    onof : char;                        //* on/off line tradable     */
                                        //* 1: on-line, 2: off-Line  */
    fill : array [1..8] of char;        //* Filler           */
    nlne : char;                         //* \n   */
  end;

  POptData = ^TOptData;
  TOptData = record
    comd : string;       //* symbol code              */
    exnm : string;       //* symbol name (english)    */
    exch : string;        //* exchange section     */
    enam : string;       //* symbol name (english)    */
    name : string;       //* symbol name              */
    stype: char;                        //* symbol type('O')         */
    trdf : char;                        //* trading flag (1: tradable)   */
    prod : string;        //* production section       */
    pind : char;                        //* price indicator      */
    tsiz : string;        //* tick size            */
    tval : string;        //* tick value               */
    adjv : string;        //* adjustment value         */
    csiz : string;        //* cab tick size            */
    cval : string;        //* cab value            */
    stid : char;                        //* strike indicator             */
    osty : char;                        //* option style         */
                                        //* 1: American, 2: European */
    onof : char;                        //* on/off line tradable     */
                                        //* 1: on-line, 2: off-Line  */
    fill : string;        //* Filler           */
    nlne : char;                         //* \n   */
  end;


  POptcode = ^TOptcode;
  TOptcode = record
    code : array [1..16] of char;       //* symbol code          */
    fcod : array [1..8] of char;        //* futures code             */
    strk : array [1..8] of char;        //* strike price                 */
    otyp : char;                        //* option type (C:Call, P:Put)  */
    atmf : char;                        //* 1:ATM, 2:ITM, 3:OTM      */
    fill : array [1..8] of char;        //* Filler           */
    nlne : char;                        //* \n   */
  end;
    // ���񸶽��� ����
  POutSymbolMaster = ^TOutSymbolMaster;
  TOutSymbolMaster = record
    code  : Array[1..16] of Char;     //���� symbol
    ename : Array[1..30] of Char;     //���������
    name  : Array[1..30] of Char;     //�����(Korean or Japanese)
    exch  : Array[1..2] of Char;      //exchange ����
                                      //1:CME, 2:CBOT, 3:NYMEX, 4:EUREX, 5:SGX
                                      //6:HKFX, 7:OSE, 8:TSE, 9:LIFFE, 10:TIFFE
    typ   : Char;                     //���� ����
                                      //F: Futures, O: Options, I: Index, X: Forex
    prod  : Array[1..2] of Char;      //��ǰ����
                                      //10: Foreign exchange(Currency)-��ȭ
                                      //20: Interest rate-ä��
                                      //30: Index(Equity)-����
                                      //40: Commodity (Agriculture, ...)-��깰
                                      //50: Metals-��ǰ
                                      //60: Energy-��ǰ
                                      //80: Single Stock-�����ɼ�(���� �̻��)
                                      //90: Etc commodity(���� �̻��)
    Pind  : Char;                      //price type
    trdf  : Byte;                      //��ǰ �Ÿ� ���� ����(1: tradable, 0: N/A)
    onof  : Byte;                      //1: On-Line, 2: Off-Line, 0: N/A
    tickSize  : Array[1..9] of Char;   //Tick Size(include decimal point (ex: 0.01))
    adjv  : Array[1..9] of Char;        //Adjust Value(include decimal point (ex: 0.01))
    unt   : Array[1..4] of Char;        //trading unit(*1000)
    lmon  : Byte;                       //lead month flag(1: Yes, 0: No)
    rtic  : Byte;                       //regular tick type(1: 1/1, 2: 1/2, 4: 1/4)
    cmcd  : Array[1..6] of Char;        //commodity code
    ctym  : Array[1..6] of Char;        //contract year&mon(YYYYMM)
    ochk  : Char;                       //Option�� �����ڻ�(1)
    fill  : Array[1..21] of Char;       //filler
  end;

  PAxCodeInfo = ^TAxCodeInfo;
  TAxCodeInfo = record
    code: string;
    name: string;
    marketGb: string;  // 'A': CME
    codeGb: char;
    priceIndicator: char;
    orderGb: string;
    siseOrigin : String;
    tickSize: double;
    tickValue: double; // not use
    adjustValue: double;
    contractSize : double;
    CodeType : Integer;
    capSize  : Double;
    capValue : Double;
    ndec  : Char;
    prod  : String;  //��ǰ����
                                      //10: Foreign exchange(Currency)-��ȭ
                                      //20: Interest rate-ä��
                                      //30: Index(Equity)-����
                                      //40: Commodity (Agriculture, ...)-��깰
                                      //50: Metals-��ǰ
                                      //60: Energy-��ǰ
                                      //80: Single Stock-�����ɼ�(���� �̻��)
                                      //90: Etc commodity(���� �̻��)
    cmcd  : String;       //commodity code
  end;  
            {
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
  end;      }

  TSymbolHogaUnit = record
    Hoga	: array [0..14] of char;     // 1���켱ȣ��(�ŵ�)	15
    Qty 	: array [0..14] of char;     // 1�켱ȣ���ܷ�(�ŵ�)	15
    Count : array [0..14] of char;     //	1���켱ȣ���Ǽ�(�ŵ�)	15
  end;

  {
  ���� ȣ�� ��ȸ
  GroupTR�� : pibo7000
  TR ��     : pibo7012
  �Է°� ����  : 16
  TRHeader���� :	1
  ��ȣȭ ����  :  0
  }

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
    ItemCd	: array [0..14] of char;     //   �����ڵ�	16
    Curr	  : array [0..14] of char;     //   ���簡	16
    Diff	  : array [0..14] of char;     //   ���� ���	15
    UpDwnRatio : array [0..14] of char;     //   	���ϴ������(%)	15
    Open	  : array [0..14] of char;     //   �ð�	15
    High	  : array [0..14] of char;     //   ��	15
    Low	    : array [0..14] of char;     //   ����	15
    PreviousClose	: array [0..14] of char;     //   ��������	15
    Volume	: array [0..14] of char;     //   �ŷ���	15
    MatchQty  : array [0..14] of char;     //   	ü�ᷮ(����)	15
    HogaTime	: array [0..14] of char;     //   ȣ�� �ð�	15
    SellHoga  : array [0..4] of TSymbolHogaUnit;
    BuyHoga  : array [0..4] of TSymbolHogaUnit;

    SellQtyTotal  : array [0..14] of char;     //   		�ŵ������հ�	15
    BuyQtyTotal	  : array [0..14] of char;     //   	�ż������հ�	15
    SellCountTotal: array [0..14] of char;     //   		�ŵ��Ǽ��հ�	15
    BuyCountTotal	: array [0..14] of char;     //   	�ż��Ǽ��հ�	15
    Bday	        : array [0..14] of char;     //   	Business Date	15
  end;

  // ��Ʈ ����Ÿ
 {
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
    }

/////////////////////////////////////////////////////?

{$REGION '������ȸ....'}

  {
  ���� ��Ź�ڻ�� ���ű�
  GroupTR�� : pibo0150
  TR ��     : ph015301
  �Է°� ����  : 0
  TRHeader���� :	1
  ��ȣȭ ����  :  1
  }
  POutAccountInfo = ^TOutAccountInfo;
  TOutAccountInfo = record
    Code    : array [0..19] of char;
    Name    : array [0..39] of char;
  end;

  {
  ���� ��ü�� ��ȸ
  GroupTR�� : paho0200
  TR ��     : ph020201
  �Է°� ����  : 99
  TRHeader���� :	1
  ��ȣȭ ����  :  1
  }

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Account	 : array [0..19] of char;   //	/* ���¹�ȣ														*/
    Pass		 : array [0..7] of char;    //	/* ��й�ȣ														*/
    reg_n_tp : char;                    //    �̿��భ��û�걸��
    code  	 : array [0..29] of char;   //	/* �����ڵ�													*/
    grnm     : array [0..19] of char;   //     ���ɱ׷��
    csno     : array [0..19] of char;   //     ����ȣ
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Account				: array [0..19] of char;  //	/* ���¹�ȣ
    AcntName      : array [0..39] of char;  //  /* ���¸�
		Ord_No				: array [0..6] of char;	  //  /* �ֹ��ֹ�ȣ													*/
    o_mtst        : char;                   //  ��������   1: �Ϲ�  2 : OCO
    Prce_tp				:char;                    //	/* ��������	(1.������ 2.���尡 3:STOP_Market 4:stop-limit) 					*/
    Code    			: array [0..29] of char;  //	/* ��������ڵ�													*/
    Bysl_tp				: char;                   // 	/* �Ÿű����ڵ�  //  1.�ż� 2.�ŵ�
    Ord_q				  : array [0..6] of char;   //	/* �ֹ�����														*/
    Ord_p				  : array [0..14] of char;  //	/* �ֹ����� or ü������											*/
		Trd_q				  : array [0..6] of char;   //	/* ü�����														*/
		Mcg_q				  : array [0..6] of char;   //	/* ��ü�����													*/

    Stop_p				: array [0..14] of char;  //	/* STOP�ֹ�����													*/
    o_jmgg        : char;                   //     ü������
    o_date        : array [0..7] of char;   //     ��ȿ����
    o_mtno        : array [0..6] of char;   //   �����׷�
    o_reg_yn_nm   : char;                   // ��翹�࿩��
  end;

  {
  ���� �̰����ܰ� ��ȸ
  GroupTR�� : paho0200
  TR ��     : ph020401
  �Է°� ����  : 99
  TRHeader���� :	1
  ��ȣȭ ����  :  1
  }

  PReqAccountPos = ^TREqAccountFill;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
		Account		 : array [0..19] of char;     //	/* ���¹�ȣ														*/
		AcctNm		 : array [0..39] of char;     //  /* ���¸�														*/
		Code       : array [0..29] of char;     //	/* �����ڵ�														*/
    SettleDiv  : array [0..2] of char;      //  /* ������ȭ
    Bysl_tp				: char;                   //  /* �Ÿű���	(1.�ż� 2.�ŵ�)										*/

    Open_q				: array [0..6] of char;	  //  /* �̰�������													*/
    PrevOpen_q	  : array [0..6] of char;	  //  /* ���� �̰�������													*/
		Avgt_p				: array [0..14] of char;	//  /* ��հ�														*/
		Curr_p				: array [0..14] of char;	//  /* ���簡 														*/
		Open_pl				: array [0..20] of char;	//  /* �򰡼���														*/
		Rsrb_q				: array [0..6] of char;	  //  /* û�갡�ɼ���

    TickSize      : array [0..11] of char;  //
    TickValue     : array [0..11] of char;  //
    Prcfactor     : array [0..11] of char;  //  /* �����������
    TotbuyAmt     : array [0..14] of char;  //  /* �Ѹ��Աݾ�
  end;

  {
  ���� ��Ź�ڻ�� ���ű�
  GroupTR�� : pibo7000
  TR ��     : pibo7012
  �Է°� ����  : 39
  TRHeader���� :	1
  ��ȣȭ ����  :  1
  }

  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
		Account		 : array [0..19] of char;	          //  /* ���¹�ȣ														*/
		Pass			 : array [0..7] of char;            //	/* ��й�ȣ														*/
    Date       : array [0..7] of char;            //  /* ��ȸ����
		Crc_cd		 : array [0..2] of char;            //	/* ��ȭ�ڵ�	(USD �� �⺻���� ���)
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
    date_o	: array [0..7] of char;    //    ��ȸ����	8
    jykm_o	: array [0..14] of char;    //    ���Ͽ�Ź���ܾ�	15
    ytkm_o	: array [0..14 ] of char;    //    ���Ͽ�Ź���ܾ�	15
    iokm_o	: array [0..14 ] of char;    //    ����ݾ�	15
    cson_o	: array [0..14 ] of char;    //    û�����	15
    susu_o	: array [0..14 ] of char;    //    ������	15
    pson_o	: array [0..14 ] of char;    //    �򰡼���	15
    ommd_o	: array [0..14 ] of char;    //    �ɼǸŸŴ��	15
    osjg_o	: array [0..14 ] of char;    //    �ɼǽ��尡ġ	15
    ytpm_o	: array [0..14 ] of char;    //    ��Ź�ڻ��򰡾�	15
    cgkm_o	: array [0..14 ] of char;    //    ���Ⱑ�ɱݾ�	15
    jgkm_o	: array [0..14 ] of char;    //    �ֹ����ɱݾ�	15
    misu_o	: array [0..14 ] of char;    //    �̼���	15
    ynch_o	: array [0..14 ] of char;    //    ��ü��	15
    mrg1_o	: array [0..14 ] of char;    //    ��Ư���ű�	15
    mrg2_o	: array [0..14 ] of char;    //    �������ű�	15
    mrg3_o	: array [0..14 ] of char;    //    �߰����ű��ʿ��	15
  end;

  ROutAccountDepositSub = ^TOutAccountDepositSub;
  TOutAccountDepositSub = record
    curr	: array [0..7] of char;   //      ��ȭ�ڵ�	3
    jykm	: array [0..14] of char;    //    �����Ͽ�Ź���ܾ�	15
    ytkm	: array [0..14] of char;    //    �����Ͽ�Ź���ܾ�	15
    iokm	: array [0..14] of char;    //    ������ݾ�	15
    cson	: array [0..14] of char;    //    ��û�����	15
    susu	: array [0..14] of char;    //    ��������	15
    pson	: array [0..14] of char;    //    ���򰡼���	15
    ommd	: array [0..14] of char;    //    ���ɼǸŸŴ��	15
    osjg	: array [0..14] of char;    //    ���ɼǽ��尡ġ	15
    ytpm	: array [0..14] of char;    //    ����Ź�ڻ��򰡾�	15
    cgkm	: array [0..14] of char;    //    �����Ⱑ�ɱݾ�	15
    jgkm	: array [0..14] of char;    //    ���ֹ����ɱݾ�	15
    misu	: array [0..14] of char;    //    ���̼���	15
    ynch	: array [0..14] of char;    //    ����ü��	15
    mrg1	: array [0..14] of char;    //    ����Ư���ű�	15
    mrg2	: array [0..14] of char;    //    ���������ű�	15
    mrg3	: array [0..14] of char;    //    ���߰����ű��ʿ��	15
  end;

  {
  ��ǰ�� Ticksize ��ȸ
  GroupTR�� : paho8000
  TR ��     : ph800801
  �Է°� ����  : 5
  TRHeader���� :	1
  ��ȣȭ ����  :  0
  }

  POutTickSize = ^TOutTickSize;
  TOutTickSize = record
    o_commd_cd    : array [0..4] of char;  //	  ��ǰ�ڵ�	5
    o_start_price	: array [0..19] of char; //  �������۰���	20
    o_end_price	  : array [0..19] of char; //  �������ᰡ��	20
    o_tick_size	  : array [0..19] of char; //  ���� TICK_SIZE	20
    o_ipad	      : array [0..14] of char; //  �۾���IP	15
    o_user	      : array [0..29] of char; //  �۾���	30
    o_time	      : array [0..22] of char; //  �۾��Ͻ�	23
  end;


  {
  �ֹ����ɼ���  ��ȸ
  GroupTR�� : paho7100
  TR ��     : ph710201
  �Է°� ����  : 85
  TRHeader���� :	1
  ��ȣȭ ����  :  1
  }

  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Account			: array [0..19] of char;          //	/* ���¹�ȣ														*/
    Pass				: array [0..7] of char;           //	/* ��й�ȣ														*/

    code	      : array [0..29] of char;          //  /*�����ڵ�	30
    mdms	      : char;                           //  �Ÿű���	1	1:�ż� 2:�ŵ�
    s_jprc	    : array [0..11] of char;          //  �ֹ�����	12
    jtyp        : char;                           //	�ֹ���������	1
    sprc	      : array [0..11] of char;          //   STOP����	12
    hsbg	      : char;                           //  ��翹��	1
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
		Ord_q				: array [0..4] of char;           //	/* ���ɼ���														*/
		Chu_q				: array [0..4] of char;           //	/* û�����														*/
  end;


{$ENDREGION}


{$REGION '�ֹ�....'}

  {
  �ű��ֹ�
  GroupTR�� : pibo5000
  TR ��     : pibo5001
  �Է°� ����  : 101
  TRHeader���� :	2
  ��ȣȭ ����  :  2
  }

  PSendOrderPacket = ^TSendOrderPacket;
  TSendOrderPacket = record
    acno	: array [0..19] of char;      //���¹�ȣ	20
    pswd	: array [0..7] of char;       //��й�ȣ	8
    code	: array [0..29] of char;      //�����ڵ�	30
    mdms	: char;                       //�ŵ��ż�����(1: BUY,  2: SELL)	1
    jtyp	: char;                       //�ֹ���������(1: MARKET, 2: LIMIT, 3: STOP, 4: STOP LIMIT,5: OCO)jmgb	1
    jmgb	: char;                       //�ֹ�����(0: DAY(����), 1: GTC, 6: GTD)	1
    jqty	: array [0..7] of char;       //�ֹ�����	8
    jprc	: array [0..11] of char;      //�ֹ�����	12
    sprc	: array [0..11] of char;      //STOP����	12
    date	: array [0..7] of char;       //��ȿ����	8
  end;
  {
    hsbg	: char;                       //��翹��	1
    odty	: char;                       //�ŷ������ڵ�(1:�Ϲ�, 2:API�ֹ�, 3:����ֹ�, 4:���߹ݴ�Ÿ�, 5:��v	1
  end;

  {
  ����/����ֹ�
  GroupTR�� : pibo5000
  TR ��     : pibo5002
  �Է°� ����  : 102
  TRHeader���� :	2
  ��ȣȭ ����  :  2
  }


  PSendModifyOrderPacket = ^TSendModifyOrderPacket;
  TSendModifyOrderPacket = record
    acno	: array [0..19] of char;      //���¹�ȣ	20
    pswd	: array [0..7] of char;       //��й�ȣ	8
    jcgb	: char;                       //������ұ���(2:����, 3:���)	1
    ojno	: array [0..6] of char;       //���ֹ���ȣ	7

    code	: array [0..29] of char;      //�����ڵ�	30
    mdms	: char;                       //�ŵ��ż�����(1: BUY,  2: SELL)	1
    jtyp	: char;                       //�ֹ���������(1: MARKET, 2: LIMIT, 3: STOP, 4: STOP LIMIT,5: OCO)jmgb	1

    jqty	: array [0..7] of char;       //�ֹ�����	8
    jprc	: array [0..11] of char;      //�ֹ�����	12
    sprc	: array [0..11] of char;      //STOP����	12
  end;
  {
    hsbg	: char;                       //��翹��	1
    odty	: char;                       //�ŷ������ڵ�(1:�Ϲ�, 2:API�ֹ�, 3:����ֹ�, 4:���߹ݴ�Ÿ�, 5:��v	1
  end;
   }
  POutOrderPacket = ^TOutOrderPacket;
  TOutOrderPacket = record
		Order_No  		: array [0..6] of char;       //	/* �ֹ���ȣ														*/
  end;


{$ENDREGION}


Const
  Len_AccountInfo   = SizeOf( TOutAccountInfo );
  //Len_SymbolListInfo = SizeOf( TOutSymbolListInfo );
  Len_OutSymbolMaster = sizeof( TOutSymbolMaster );
    {
  Len_ReqChartData = sizeof( TReqChartData );
  Len_OutChartData = sizeof( TOutChartData );
  Len_OutChartDataSub = sizeof( TOutChartDataSub );
  }
  // ����
  // �ֹ�����Ʈ ��û
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // �ܰ�
  Len_ReqAccountPos = Len_ReqAccountFill;
  Len_OutAccountPos = sizeof( TOutAccountPOs );

  // ������
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
    {
  // ���ɼ���
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // �ǽð� ��û
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // ü��
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );
     }
  //
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_SendModifyOrderPacket = sizeof( TSendModifyOrderPacket );

implementation

end.
