unit ApiPacket;

interface

type
  // ---------------------  조회  --------------------------

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
    // 종목마스터 파일
  POutSymbolMaster = ^TOutSymbolMaster;
  TOutSymbolMaster = record
    code  : Array[1..16] of Char;     //종목 symbol
    ename : Array[1..30] of Char;     //영문종목명
    name  : Array[1..30] of Char;     //종목명(Korean or Japanese)
    exch  : Array[1..2] of Char;      //exchange 구분
                                      //1:CME, 2:CBOT, 3:NYMEX, 4:EUREX, 5:SGX
                                      //6:HKFX, 7:OSE, 8:TSE, 9:LIFFE, 10:TIFFE
    typ   : Char;                     //종목 구분
                                      //F: Futures, O: Options, I: Index, X: Forex
    prod  : Array[1..2] of Char;      //상품구분
                                      //10: Foreign exchange(Currency)-통화
                                      //20: Interest rate-채권
                                      //30: Index(Equity)-지수
                                      //40: Commodity (Agriculture, ...)-농산물
                                      //50: Metals-상품
                                      //60: Energy-상품
                                      //80: Single Stock-지수옵션(현재 미사용)
                                      //90: Etc commodity(현재 미사용)
    Pind  : Char;                      //price type
    trdf  : Byte;                      //상품 매매 가능 여부(1: tradable, 0: N/A)
    onof  : Byte;                      //1: On-Line, 2: Off-Line, 0: N/A
    tickSize  : Array[1..9] of Char;   //Tick Size(include decimal point (ex: 0.01))
    adjv  : Array[1..9] of Char;        //Adjust Value(include decimal point (ex: 0.01))
    unt   : Array[1..4] of Char;        //trading unit(*1000)
    lmon  : Byte;                       //lead month flag(1: Yes, 0: No)
    rtic  : Byte;                       //regular tick type(1: 1/1, 2: 1/2, 4: 1/4)
    cmcd  : Array[1..6] of Char;        //commodity code
    ctym  : Array[1..6] of Char;        //contract year&mon(YYYYMM)
    ochk  : Char;                       //Option의 기초자산(1)
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
    prod  : String;  //상품구분
                                      //10: Foreign exchange(Currency)-통화
                                      //20: Interest rate-채권
                                      //30: Index(Equity)-지수
                                      //40: Commodity (Agriculture, ...)-농산물
                                      //50: Metals-상품
                                      //60: Energy-상품
                                      //80: Single Stock-지수옵션(현재 미사용)
                                      //90: Etc commodity(현재 미사용)
    cmcd  : String;       //commodity code
  end;  
            {
  POutSymbolMarkePrice = ^TOutSymbolMarkePrice;
  TOutSymbolMarkePrice = record
	  Header    : TCommonHeader;
		FullCode  		 : array [0..31] of char ;    //	/* 종목표준코드													*/
		JinbubGb  		 : char;	                    //  /* 진법 (0.10진법 1.32진법 2.64진법 3.128진법 4.8진법)			*/
		ISINCd   			 : array [0..11] of char;     //	/* 종목표준코드													*/
		ClosePrice		 : array [0..19] of char;     //	/* 현재가														*/
		CmpSign				 : char;                      //	/* 대비부호
											                          //  0.보합 1.상한 2.하한 3.상승 4.하락 5.기세상한
											                          //  6.기세하한 7.기세상승 8.기세하락							*/
		CmpPrice			 : array [0..19] of char;	    //  /* 전일대비9(5)V9(2)											*/
		CmpRate				 : array [0..7] of char;	    //  /* 등락율9(5)V9(2) 												*/
		OpenPrice			 : array [0..19] of char;	    //  /* 시가 														*/
		HighPrice			 : array [0..19] of char;	    //  /* 고가 														*/
		LowPrice			 : array [0..19] of char;	    //  /* 저가 														*/
		ContQty				 : array [0..19] of char;	    //  /* 체결량 														*/
		TotQty 				 : array [0..19] of char;	    //  /* 거래량 														*/
		ClosePrice_1	 : array [0..19] of char;	    //  /* Close Price 1
  end;      }

  TSymbolHogaUnit = record
    Hoga	: array [0..14] of char;     // 1차우선호가(매도)	15
    Qty 	: array [0..14] of char;     // 1우선호가잔량(매도)	15
    Count : array [0..14] of char;     //	1차우선호가건수(매도)	15
  end;

  {
  선물 호가 조회
  GroupTR명 : pibo7000
  TR 명     : pibo7012
  입력값 길이  : 16
  TRHeader여부 :	1
  암호화 여부  :  0
  }

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
    ItemCd	: array [0..14] of char;     //   종목코드	16
    Curr	  : array [0..14] of char;     //   현재가	16
    Diff	  : array [0..14] of char;     //   전일 대비	15
    UpDwnRatio : array [0..14] of char;     //   	전일대비등락율(%)	15
    Open	  : array [0..14] of char;     //   시가	15
    High	  : array [0..14] of char;     //   고가	15
    Low	    : array [0..14] of char;     //   저가	15
    PreviousClose	: array [0..14] of char;     //   전일종가	15
    Volume	: array [0..14] of char;     //   거래량	15
    MatchQty  : array [0..14] of char;     //   	체결량(최종)	15
    HogaTime	: array [0..14] of char;     //   호가 시간	15
    SellHoga  : array [0..4] of TSymbolHogaUnit;
    BuyHoga  : array [0..4] of TSymbolHogaUnit;

    SellQtyTotal  : array [0..14] of char;     //   		매도수량합계	15
    BuyQtyTotal	  : array [0..14] of char;     //   	매수수량합계	15
    SellCountTotal: array [0..14] of char;     //   		매도건수합계	15
    BuyCountTotal	: array [0..14] of char;     //   	매수건수합계	15
    Bday	        : array [0..14] of char;     //   	Business Date	15
  end;

  // 차트 데이타
 {
  PReqChartData = ^TReqChartData;
  TReqChartData = record
	  Header    : TCommonHeader;
		JongUp		: char;                   //	/* '5'로 고정													*/
		DataGb		: char;                   //	/* 1:일															*/
                                        //  /* 2:주															*/
                                        //  /* 3:월															*/
                                        //  /* 4:tick봉														*/
                                        //  /* 5:분봉														*/
		DiviGb		: char;                   //	/* 종목, 일별시 액면분할 보정 안한다: '0'으로 고정				*/
		FullCode	: array [0..31] of char;  //	/* 종목표준코드													*/
		Index			: array [0..3] of char;   //	/* 코드 index													*/
		InxDay		: array [0..7] of char;   //	/* 기준일자														*/    분,틱은 제외
		DayCnt		: array [0..3] of char;   //	/* 일자갯수														*/
		Summary		: array [0..2] of char;   //	/* tick, 분에서 모으는 단위										*/
		Linked		: char;                   //	/* 연결선물구분 Y/N(일봉)										*/
		JunBonGb	: char;                   //	/* 1.전산장 2.본장 (분/틱봉)									*/
  end;

  POutChartDataSub = ^TOutChartDataSub;
  TOutChartDataSub = record
    Date				: array [0..7] of char;   //   /* YYYYMMDD														*/
    Time				: array [0..7] of char;   //  /* 시간(HH:MM:SS)												*/
    OpenPrice		: array [0..19] of char;  //   /* 시가 double													*/
    HighPrice		: array [0..19] of char;  //   /* 고가 double													*/
    LowPrice		: array [0..19] of char;  //   /* 저가 double													*/
    ClosePrice	: array [0..19] of char;  //   /* 종가 double													*/
    Volume			: array [0..19] of char;  //   /* 거래량 double
  end;

  POutChartData = ^TOutChartData;
  TOutChartData = record
	  Header    : TCommonHeader;
    FullCode	: array [0..31] of char;    //    /* 종목표준코드													*/
    MaxDataCnt: array [0..3] of char;     //    /* 전체일자 갯수												*/
    DataCnt		: array [0..2] of char;     //    /* 현재송신일자 갯수											*/
    TickCnt		: array [0..1] of char;     //    /* 마지막봉의 tick 갯수											*/
    Today			: array [0..7] of char;     //    /* 당영업일(StockDate[0])										*/
    nonedata	: array [0..3] of char;     //    /* 전일종가 double												*/
    DataGb		: char;            //   /* 1:일															*/
                                  //  /* 2:주															*/
                                  //  /* 3:월															*/
                                  //  /* 4:tick봉														*/
                                  //  /* 5:분봉														*/
    DayCnt		: array [0..3] of char;     //    /* 일자갯수														*/
    Summary		: array [0..2] of char;     //    /* tick, 분에서 모으는 단위										*/
    PrevLast	: array [0..19] of char;    //    /* 전일종가														*/
  end;


  PSendAutoKey = ^TSendAutoKey ;
  TSendAutoKey = record
    header : TCommonHeader;
    AutoKey  : array [0..31] of char;      // /* 계좌의 경우 계좌번호, 시세 경우 종목표준코드
  end;


  ////  시세 자동 업데이트  -----------------------------------------------------------------
  ///



  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..31] of char;    //	/* 종목표준코드													*/
		JinbubGb 		: char;                     //	/* 진법 (0.10진법 1.32진법 2.64진법 3.128진법 4.8진법)			*/
		Time				: array [0..7] of char;     //	/* 시간(HH:MM:SS)												*/
		ClosePrice_1: array [0..19] of char;    //	/* Close Price 1												*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..19] of char;    //	/* 매도총호가수량9(6)											*/
		TotBuyQty		: array [0..19] of char;    //	/* 매수총호가수량9(6)											*/
		TotSellNo		: array [0..19] of char;    //	/* 매도총호가건수9(5)											*/
		TotBuyNo		: array [0..19] of char;    //	/* 매수총호가건수9(5)
  end;

  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
	  Header    : TCommonHeader;
		FullCode	: array [0..31] of char;    //	/* 종목표준코드 												*/
		JinbubGb  : char;                     //	/* 진법 (0.10진법 1.32진법 2.64진법 3.128진법 4.8진법)			*/
		Time			: array [0..7] of char;     //	/* 시간(HH:MM:SS)												*/
		CmpSign		: char;                     //	/* 대비부호
                                          //   1.상한 2.하한 3.상승 4.하락 5.기세상한
                                          //   6, 기세하한 7.기세상승 8.기세하락							*/
		CmpPrice	: array [0..19] of char;    //	/* 전일대비														*/
		ClosePrice  : array [0..19] of char;  //	/* 현재가														*/
		CmpRate			: array [0..7] of char;   //	/* 등락율9(5)V9(2)												*/
		TotQty 			: array [0..19] of char;  //	/* 거래량 														*/
		ContQty			: array [0..19] of char;  //	/* 체결량 														*/
		MatchKind		: char;                   //	/* 현재가의 호가구분 (+.매수 -.매도)							*/
		Date				: array [0..7] of char;     //	/* 일자(YYYYMMDD) 												*/
		OpenPrice		: array [0..19] of char;  //	/* 시가 														*/
		HighPrice		: array [0..19] of char;  //	/* 고가 														*/
		LowPrice		: array [0..19] of char;  //	/* 저가 														*/
		BuyPrice		: array [0..19] of char;  //	/* 매수호가														*/
		SellPrice		: array [0..19] of char;  //	/* 매도호가														*/
		MarketFlag	: char;                   //	/* 장구분 0.본장 1.전산장										*/
		DecLen			: array [0..4] of char;   //	/* 종목 소숫점 정보
  end;
    }

/////////////////////////////////////////////////////?

{$REGION '계좌조회....'}

  {
  계좌 예탁자산및 증거금
  GroupTR명 : pibo0150
  TR 명     : ph015301
  입력값 길이  : 0
  TRHeader여부 :	1
  암호화 여부  :  1
  }
  POutAccountInfo = ^TOutAccountInfo;
  TOutAccountInfo = record
    Code    : array [0..19] of char;
    Name    : array [0..39] of char;
  end;

  {
  계좌 미체결 조회
  GroupTR명 : paho0200
  TR 명     : ph020201
  입력값 길이  : 99
  TRHeader여부 :	1
  암호화 여부  :  1
  }

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Account	 : array [0..19] of char;   //	/* 계좌번호														*/
    Pass		 : array [0..7] of char;    //	/* 비밀번호														*/
    reg_n_tp : char;                    //    미예약강제청산구분
    code  	 : array [0..29] of char;   //	/* 종목코드													*/
    grnm     : array [0..19] of char;   //     관심그룹명
    csno     : array [0..19] of char;   //     고객번호
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Account				: array [0..19] of char;  //	/* 계좌번호
    AcntName      : array [0..39] of char;  //  /* 계좌명
		Ord_No				: array [0..6] of char;	  //  /* 주문주번호													*/
    o_mtst        : char;                   //  전략유형   1: 일반  2 : OCO
    Prce_tp				:char;                    //	/* 가격조건	(1.지정가 2.시장가 3:STOP_Market 4:stop-limit) 					*/
    Code    			: array [0..29] of char;  //	/* 종목단축코드													*/
    Bysl_tp				: char;                   // 	/* 매매구분코드  //  1.매수 2.매도
    Ord_q				  : array [0..6] of char;   //	/* 주문수량														*/
    Ord_p				  : array [0..14] of char;  //	/* 주문지수 or 체결지수											*/
		Trd_q				  : array [0..6] of char;   //	/* 체결수량														*/
		Mcg_q				  : array [0..6] of char;   //	/* 미체결수량													*/

    Stop_p				: array [0..14] of char;  //	/* STOP주문가격													*/
    o_jmgg        : char;                   //     체결조건
    o_date        : array [0..7] of char;   //     유효일자
    o_mtno        : array [0..6] of char;   //   전략그룹
    o_reg_yn_nm   : char;                   // 행사예약여부
  end;

  {
  계좌 미결제잔고 조회
  GroupTR명 : paho0200
  TR 명     : ph020401
  입력값 길이  : 99
  TRHeader여부 :	1
  암호화 여부  :  1
  }

  PReqAccountPos = ^TREqAccountFill;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
		Account		 : array [0..19] of char;     //	/* 계좌번호														*/
		AcctNm		 : array [0..39] of char;     //  /* 계좌명														*/
		Code       : array [0..29] of char;     //	/* 종목코드														*/
    SettleDiv  : array [0..2] of char;      //  /* 결제통화
    Bysl_tp				: char;                   //  /* 매매구분	(1.매수 2.매도)										*/

    Open_q				: array [0..6] of char;	  //  /* 미결제수량													*/
    PrevOpen_q	  : array [0..6] of char;	  //  /* 전일 미결제수량													*/
		Avgt_p				: array [0..14] of char;	//  /* 평균가														*/
		Curr_p				: array [0..14] of char;	//  /* 현재가 														*/
		Open_pl				: array [0..20] of char;	//  /* 평가손익														*/
		Rsrb_q				: array [0..6] of char;	  //  /* 청산가능수량

    TickSize      : array [0..11] of char;  //
    TickValue     : array [0..11] of char;  //
    Prcfactor     : array [0..11] of char;  //  /* 가격조정계수
    TotbuyAmt     : array [0..14] of char;  //  /* 총매입금액
  end;

  {
  계좌 예탁자산및 증거금
  GroupTR명 : pibo7000
  TR 명     : pibo7012
  입력값 길이  : 39
  TRHeader여부 :	1
  암호화 여부  :  1
  }

  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
		Account		 : array [0..19] of char;	          //  /* 계좌번호														*/
		Pass			 : array [0..7] of char;            //	/* 비밀번호														*/
    Date       : array [0..7] of char;            //  /* 조회일자
		Crc_cd		 : array [0..2] of char;            //	/* 통화코드	(USD 로 기본으로 사용)
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
    date_o	: array [0..7] of char;    //    조회일자	8
    jykm_o	: array [0..14] of char;    //    전일예탁금잔액	15
    ytkm_o	: array [0..14 ] of char;    //    당일예탁금잔액	15
    iokm_o	: array [0..14 ] of char;    //    입출금액	15
    cson_o	: array [0..14 ] of char;    //    청산손익	15
    susu_o	: array [0..14 ] of char;    //    수수료	15
    pson_o	: array [0..14 ] of char;    //    평가손익	15
    ommd_o	: array [0..14 ] of char;    //    옵션매매대금	15
    osjg_o	: array [0..14 ] of char;    //    옵션시장가치	15
    ytpm_o	: array [0..14 ] of char;    //    예탁자산평가액	15
    cgkm_o	: array [0..14 ] of char;    //    인출가능금액	15
    jgkm_o	: array [0..14 ] of char;    //    주문가능금액	15
    misu_o	: array [0..14 ] of char;    //    미수금	15
    ynch_o	: array [0..14 ] of char;    //    연체료	15
    mrg1_o	: array [0..14 ] of char;    //    위특증거금	15
    mrg2_o	: array [0..14 ] of char;    //    유지증거금	15
    mrg3_o	: array [0..14 ] of char;    //    추가증거금필요액	15
  end;

  ROutAccountDepositSub = ^TOutAccountDepositSub;
  TOutAccountDepositSub = record
    curr	: array [0..7] of char;   //      통화코드	3
    jykm	: array [0..14] of char;    //    전전일예탁금잔액	15
    ytkm	: array [0..14] of char;    //    전당일예탁금잔액	15
    iokm	: array [0..14] of char;    //    전입출금액	15
    cson	: array [0..14] of char;    //    전청산손익	15
    susu	: array [0..14] of char;    //    전수수료	15
    pson	: array [0..14] of char;    //    전평가손익	15
    ommd	: array [0..14] of char;    //    전옵션매매대금	15
    osjg	: array [0..14] of char;    //    전옵션시장가치	15
    ytpm	: array [0..14] of char;    //    전예탁자산평가액	15
    cgkm	: array [0..14] of char;    //    전인출가능금액	15
    jgkm	: array [0..14] of char;    //    전주문가능금액	15
    misu	: array [0..14] of char;    //    전미수금	15
    ynch	: array [0..14] of char;    //    전연체료	15
    mrg1	: array [0..14] of char;    //    전위특증거금	15
    mrg2	: array [0..14] of char;    //    전유지증거금	15
    mrg3	: array [0..14] of char;    //    전추가증거금필요액	15
  end;

  {
  상품별 Ticksize 조회
  GroupTR명 : paho8000
  TR 명     : ph800801
  입력값 길이  : 5
  TRHeader여부 :	1
  암호화 여부  :  0
  }

  POutTickSize = ^TOutTickSize;
  TOutTickSize = record
    o_commd_cd    : array [0..4] of char;  //	  상품코드	5
    o_start_price	: array [0..19] of char; //  구간시작가격	20
    o_end_price	  : array [0..19] of char; //  구간종료가격	20
    o_tick_size	  : array [0..19] of char; //  적용 TICK_SIZE	20
    o_ipad	      : array [0..14] of char; //  작업자IP	15
    o_user	      : array [0..29] of char; //  작업자	30
    o_time	      : array [0..22] of char; //  작업일시	23
  end;


  {
  주문가능수량  조회
  GroupTR명 : paho7100
  TR 명     : ph710201
  입력값 길이  : 85
  TRHeader여부 :	1
  암호화 여부  :  1
  }

  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Account			: array [0..19] of char;          //	/* 계좌번호														*/
    Pass				: array [0..7] of char;           //	/* 비밀번호														*/

    code	      : array [0..29] of char;          //  /*종목코드	30
    mdms	      : char;                           //  매매구분	1	1:매수 2:매도
    s_jprc	    : array [0..11] of char;          //  주문가격	12
    jtyp        : char;                           //	주문유형구분	1
    sprc	      : array [0..11] of char;          //   STOP가격	12
    hsbg	      : char;                           //  행사예약	1
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
		Ord_q				: array [0..4] of char;           //	/* 가능수량														*/
		Chu_q				: array [0..4] of char;           //	/* 청산수량														*/
  end;


{$ENDREGION}


{$REGION '주문....'}

  {
  신규주문
  GroupTR명 : pibo5000
  TR 명     : pibo5001
  입력값 길이  : 101
  TRHeader여부 :	2
  암호화 여부  :  2
  }

  PSendOrderPacket = ^TSendOrderPacket;
  TSendOrderPacket = record
    acno	: array [0..19] of char;      //계좌번호	20
    pswd	: array [0..7] of char;       //비밀번호	8
    code	: array [0..29] of char;      //종목코드	30
    mdms	: char;                       //매도매수구분(1: BUY,  2: SELL)	1
    jtyp	: char;                       //주문유형구분(1: MARKET, 2: LIMIT, 3: STOP, 4: STOP LIMIT,5: OCO)jmgb	1
    jmgb	: char;                       //주문구분(0: DAY(당일), 1: GTC, 6: GTD)	1
    jqty	: array [0..7] of char;       //주문수량	8
    jprc	: array [0..11] of char;      //주문가격	12
    sprc	: array [0..11] of char;      //STOP가격	12
    date	: array [0..7] of char;       //유효일자	8
  end;
  {
    hsbg	: char;                       //행사예약	1
    odty	: char;                       //거래유형코드(1:일반, 2:API주문, 3:비상주문, 4:장중반대매매, 5:추v	1
  end;

  {
  정정/취소주문
  GroupTR명 : pibo5000
  TR 명     : pibo5002
  입력값 길이  : 102
  TRHeader여부 :	2
  암호화 여부  :  2
  }


  PSendModifyOrderPacket = ^TSendModifyOrderPacket;
  TSendModifyOrderPacket = record
    acno	: array [0..19] of char;      //계좌번호	20
    pswd	: array [0..7] of char;       //비밀번호	8
    jcgb	: char;                       //정정취소구분(2:정정, 3:취소)	1
    ojno	: array [0..6] of char;       //원주문번호	7

    code	: array [0..29] of char;      //종목코드	30
    mdms	: char;                       //매도매수구분(1: BUY,  2: SELL)	1
    jtyp	: char;                       //주문유형구분(1: MARKET, 2: LIMIT, 3: STOP, 4: STOP LIMIT,5: OCO)jmgb	1

    jqty	: array [0..7] of char;       //주문수량	8
    jprc	: array [0..11] of char;      //주문가격	12
    sprc	: array [0..11] of char;      //STOP가격	12
  end;
  {
    hsbg	: char;                       //행사예약	1
    odty	: char;                       //거래유형코드(1:일반, 2:API주문, 3:비상주문, 4:장중반대매매, 5:추v	1
  end;
   }
  POutOrderPacket = ^TOutOrderPacket;
  TOutOrderPacket = record
		Order_No  		: array [0..6] of char;       //	/* 주문번호														*/
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
  // 계좌
  // 주문리스트 요청
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // 잔고
  Len_ReqAccountPos = Len_ReqAccountFill;
  Len_OutAccountPos = sizeof( TOutAccountPOs );

  // 예수금
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
    {
  // 가능수량
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // 실시간 요청
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // 체결
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );
     }
  //
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_SendModifyOrderPacket = sizeof( TSendModifyOrderPacket );

implementation

end.
