unit ApiPacket;

interface

type
  // ---------------------  조회  --------------------------

  PCommonHeader = ^TCommonHeader;
  TCommonHeader = record
    WindowID  : array [0..9] of char;
    ReqKey    : char;
    ErrorCode : array [0..3] of char;         // 공백 or 0000  -> 정상
    NextKind  : char;                         // 0 : 다음 없음   1: 다음 있음
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
    DecimalInfo   : array [0..4] of char;      // 소수점정보
    TickSize      : array [0..19] of char;     // 소수점 7자리 포함
    PointValue     : array [0..19] of char;    // 최소가격변동금액 소수점 7자리 포함
  end;

  // 5501, 5502  종목마스터  , 종목현재가

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
    DigitDiv : char;       //          (0.10진법 1.32진법 2.64진법 3:128진법 4.8진법)
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

    ClosePrice1 : array [0..19] of char;      // 본정산가
    ClosePrice2 : array [0..19] of char;      // 전산정가

    ExChangeCode : array [0..4] of char;
    DispDigit    : array [0..9] of char;

    NewOrdMargin  : array [0..19] of char;  // 신규주문 증거금
    CtrtSize      : array [0..19] of char;    // 계약단위

    TickSize      : array [0..19] of char;     // 소수점 7자리 포함
    TickValue     : array [0..19] of char;    // 최소가격변동금액 소수점 7자리 포함
    PrevVolume    : array [0..19] of char;   // 전일거래량
  end;

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
  end;

  TSymbolHogaUnit = record
    BuyNo			: array [0..9] of char;       //	/* 매수번호														*/
    BuyPrice	: array [0..19] of char;      //	/* 매수호가														*/
    BuyQty		: array [0..19] of char;      //  /* 매수수량														*/
    SellNo		: array [0..9] of char;       //	/* 매도번호														*/
    SellPrice	: array [0..19] of char;      //	/* 매도호가														*/
    SellQty		: array [0..19] of char;      //	/* 매도수량
  end;

  POutSymbolHoga = ^TOutSymbolHoga ;
  TOutSymbolHoga = record
	  Header    : TCommonHeader;
		FullCode 		: array [0..31] of char;    //	/* 종목표준코드													*/
		JinbubGb 		: char;                     //	/* 진법 (0.10진법 1.32진법 2.64진법 3.128진법 4.8진법)			*/
    StandarCode 		: array [0..11] of char;    //	/* 종목표준코드													*/
		Time				: array [0..7] of char;     //	/* 시간(HH:MM:SS)												*/
		ClosePrice_1: array [0..19] of char;    //	/* Close Price 1												*/
    Arr	        : array [0..4] of TSymbolHogaUnit;
		TotSellQty	: array [0..19] of char;    //	/* 매도총호가수량9(6)											*/
		TotBuyQty		: array [0..19] of char;    //	/* 매수총호가수량9(6)											*/
		TotSellNo		: array [0..19] of char;    //	/* 매도총호가건수9(5)											*/
		TotBuyNo		: array [0..19] of char;    //	/* 매수총호가건수9(5)
  end;

  // 차트 데이타

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


/////////////////////////////////////////////////////?

{$REGION '계좌조회....'}

  // 5611   계좌 실체결 조회

  PReqAccountFill = ^TREqAccountFill;
  TReqAccountFill = record
    Header    : TCommonHeader;
    Account	 : array [0..10] of char;   //	/* 계좌번호														*/
    Pass		 : array [0..7] of char;    //	/* 비밀번호														*/
    Trd_gb	 : char;      			        //	/* 체결구분 (0:전체 1:체결2:미체결)								*/
    Base_dt	 : array [0..7] of char;    //	/* 주문일자														*/
    Gubn		 : char;                    //  /* 조회순서 (1:정순 2:역순)
  end;

  POutAccountFillSub = ^TOutAccountFillSub;
  TOutAccountFillSub = record
		Ord_No				: array [0..4] of char;	  //  /* 주문주번호													*/
		Org_ord_No		: array [0..4] of char;	  //  /* 원주문부번호													*/
		Trd_cond			: char;                   //	/* 체결조건 (1.FAS 2.FOK 3.FAK)									*/
		ShortCode			: array [0..31] of char;  //	/* 종목단축코드													*/
		Bysl_tp				: char;                   // 	/* 매매구분코드
                                            //  1.매수 2.매도 3.매수정정
                                            //  4.매도정정 5.매수취소 6.매도취소 ' '.기타					*/
		Prce_tp				:char;                    //	/* 가격조건	(1.지정가 2.시장가)									*/
		Ord_q				  : array [0..4] of char;   //	/* 주문수량														*/
		Ord_p				  : array [0..19] of char;  //	/* 주문지수 or 체결지수											*/
		Trd_q				  : array [0..4] of char;   //	/* 체결수량														*/
		Mcg_q				  : array [0..4] of char;   //	/* 미체결수량													*/
		Ord_tp				: char;                   //	/* 주문구분 (1.신규 2.정정 3.취소)								*/
		Stop_p				: array [0..19] of char;  //	/* STOP주문가격													*/
		Ex_ord_tm			: array [0..5] of char;   //	/* 주문시간														*/
		Proc_stat			: char;                   //	/* 주문처리상태 (0.원장접수 1.거래소접수 2.접수거부 3.FEP거부)	*/
		Account				: array [0..10] of char;  //	/* 계좌번호
  end;

  POutAccountFill = ^TOutAccountFill;
  TOutAccountFill = record
    Header    : TCommonHeader;
    Renu			: array [0..4] of char;       //	/* 반복횟수														*/
    Account		: array [0..10] of char;      //	/* 계좌번호														*/
    AcctNm		: array [0..19] of char;      //	/* 계좌명														*/
    Dtno			: array [0..4] of char;       //	/* 반복횟수
  end;

  // 5612   계좌 실잔고 조회

  PReqAccountPos = ^TReqAccountPos;
  TReqAccountPos = record
    Header    : TCommonHeader;
    Account		: array [0..10] of char;    //	/* 계좌번호														*/
    Pass			: array [0..7] of char;     //	/* 비밀번호
  end;

  POutAccountPosSub = ^TOutAccountPosSub;
  TOutAccountPosSub = record
		Base_dt				: array [0..7] of char;   //	/* 생성일자														*/
		FullCode			: array [0..31] of char;  //	/* 종목표준코드													*/
		Bysl_tp				: char;                   //  /*   매매구분	(1.매수 2.매도)										*/
		Trd_no				: array [0..4] of char;   //	/* 체결번호														*/
		Open_q				: array [0..9] of char;	  //  /* 미결제수량													*/
		Avgt_p				: array [0..19] of char;	//  /* 평균가														*/
		Curr_p				: array [0..19] of char;	//  /* 현재가 														*/
		Open_pl				: array [0..19] of char;	//  /* 평가손익														*/
		Rsrb_q				: array [0..9] of char;	  //  /* 청산가능수량													*/
		Trd_amt				: array [0..19] of char;	//  /* 체결금액														*/
		Account				: array [0..10] of char;	//  /* 계좌번호
  end;

  POutAccountPos = ^TOutAccountPos;
  TOutAccountPos = record
	  Header     : TCommonHeader;
		Renu			 : array [0..4] of char;	            //  /* 반복횟수														*/
		Account		 : array [0..10] of char;             //	/* 계좌번호														*/
		AcctNm		 : array [0..19] of char;             //  /* 계좌명														*/
		Dtno			 : array [0..4] of char;              //	/* 반복횟수														*/
  end;

  // 5615  예탁자산및 증거금
  PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountDeposit = record
	  Header     : TCommonHeader;
		Account		 : array [0..10] of char;	          //  /* 계좌번호														*/
		Pass			 : array [0..7] of char;            //	/* 비밀번호														*/
		Crc_cd		 : array [0..2] of char;            //	/* 통화코드	(USD 로 기본으로 사용)
  end;

  ROutAccountDeposit = ^TOutAccountDeposit;
  TOutAccountDeposit = record
	  Header      : TCommonHeader;
		Renu			  : array 	[0..4] of char;         //  /* 반복횟수 													*/
		AcctNm			: array [0..19] of char;	      //  /* 계좌명														*/
		Entr_ch			: array [0..19] of char;	      //  /* 예탁금잔액													*/
		tdy_repl_amt: array [0..19] of char;	      //  /* 원화대용금액(추가)											*/
		repl_use_amt: array [0..19] of char;	      //  /* 원화대용사용금액(추가)										*/
		Fut_rsrb_pl	: array [0..19] of char;	      //  /* 청산손익														*/
		Pure_ote_amt: array [0..19] of char;	      //  /* 평가손익														*/
		Fut_trad_fee: array [0..19] of char;	      //  /* 수수료														*/
		Dfr_amt			: array [0..19] of char;	      //  /* 미수금액														*/
		Te_amt			: array [0..19] of char;	      //  /* 예탁자산평가액												*/
		Open_pos_mgn: array [0..19] of char;	      //  /* 미결제증거금													*/
		Ord_mgn			: array [0..19] of char;	      //  /* 주문증거금													*/
		Trst_mgn		: array [0..19] of char;	      //  /* 위탁증거금													*/
		Mnt_mgn			: array [0..19] of char;	      //  /* 유지증거금													*/
		With_psbl_amt		 : array [0..19] of char;	  //  /* 인출가능금액													*/
		krw_with_psbl_amt: array [0..19] of char;	  //  /* 원화인출가능금액												*/
		Add_mgn				: array [0..19] of char;	    //  /* 추가증거금													*/
		Ord_psbl_amt	: array [0..19] of char;	    //  /* 주문가능금액													*/
		Han_psbl_amt	: array [0..19] of char;	    //  /* 환전대기금액													*/
		Crc_cd				: array [0..2] of char;	      //  /* 통화코드
  end;


  PReqAbleQty = ^TReqAbleQty;
  TReqAbleQty = record
    Header      : TCommonHeader;
    Account			: array [0..10] of char;          //	/* 계좌번호														*/
    Pass				: array [0..7] of char;           //	/* 비밀번호														*/
    ShortCode		: array [0..31] of char;          //	/* 단축코드														*/
    Bysl_tp			: char;                           //	/* 매수/매도구분 (1.매수 2.매도)								*/
  end;

  POutAbleQty = ^TOutAbleQty;
  TOutAbleQty = record
	  Header      : TCommonHeader;
		Renu				: array [0..4] of char;           //	/* 반복횟수														*/
		Account			: array [0..10] of char;          //	/* 계좌번호														*/
		Filler			: array [0..8] of char;
		Ord_q				: array [0..4] of char;           //	/* 가능수량														*/
		Chu_q				: array [0..4] of char;           //	/* 청산수량														*/
  end;

{$ENDREGION}


{$REGION '주문....'}

  // 5601

  PSendOrderPacket = ^TSendOrderPacket;
  TSendOrderPacket = record
	  Header        : TCommonHeader;
		Account			  : array [0..10] of char;      //	/* 계좌번호														*/
		Pass				  : array [0..7] of char;       //	/* 비밀번호														*/
		Order_Type	  : char;                       //	/* 주문구분	(1.신규주문 2.정정주문 3.취소주문)					*/
		ShortCode		  : array [0..31] of char;      //	/* 종목단축코드													*/
		BuySell_Type  : char;                       //	/* 매도매수구분 (1.매수 2.매도)									*/
	  Price_Type    : char;                       //	/* 가격조건	(1.지정가 2.시장가)									*/
		Trace_Type		: char;                       //	/* 체결조건 (시장가일경우(3) 지정가일경우(1))					*/
	  Order_Price	  : array [0..19] of char;      //	/* 주문가격														*/
	  Order_Volume  : array [0..4] of char;       //	/* 주문수량														*/
		Order_Org_No	: array [0..4] of char;       //	/* 원주문번호 (정정/취소시만)									*/
    Order_Comm_Type		: char;                   //	/* 통신주문구분													*/
		Stop_Type			: char;                       //	/* 주문전략구분 (1.일반주문 2.STOP주문)							*/
		Stop_Price		: array [0..19] of char;      //	/* STOP주문가격 (STOP주문이면 입력 아니면 0 셋팅)				*/
		Oper_Type			: char;                       //	/* 주문구분	(1.신규주문 2.정정주문 3.취소주문)
  end;

  POutOrderPacket = ^TOutOrderPacket;
  TOutOrderPacket = record
	  Header        : TCommonHeader;
		Order_No  		: array [0..4] of char;       //	/* 주문번호														*/
	  Order_Org_No	: array [0..4] of char;       //	/* 원주문번호													*/
		Account				: array [0..10] of char;      //	/* 계좌번호														*/
		Order_Type		: char;                       //	/* 주문구분	(1.신규주문 2.정정주문 3.취소주문)					*/
		ShortCode			: array [0..31] of char;      //	/* 종목단축코드														*/
		BuySell_Type	: char;                       //	/* 매도매수구분 (1.매수 2.매도)									*/
	  Order_Volume	: array [0..4] of char;       //	/* 주문수량														*/
	  Order_Price		: array [0..19] of char;      //	/* 주문가격														*/
	  Price_Type		: char;                       //	/* 가격조건	(1.지정가 2.시장가)									*/
		Trade_Type		: char;                       //	/* 체결조건 (시장가일경우(3) 지정가일경우(1))					*/
		Stop_Price		: array [0..19] of char;      //	/* STOP주문가격
  end;

  PAutoOrderPacket = ^TAutoOrderPacket;
  TAutoOrderPacket = record
	  Header        : TCommonHeader;
		Account				: array [0..10] of char;      // 	/* 계좌번호														*/
		ReplyType			: char;                       //	/* 응답유형
                                                //  1.주문접수 2.체결 3.정정확인 4.취소확인
                                                //  5.신규거부 6.정정거부 7.취소거부 0.원장접수					*/
		FullCode			: array [0..31] of char;      //	/* 종목코드 (원장접수일때 표준코드, 그외 단축코드)				*/
		Side				  : char;                       //	/* 매수/매도구분 (1.매수 2.매도)								*/
		Qty					  : array [0..19] of char;      //	/* 주문수량														*/
		Modality			: char;                       //	/* 가격조건	(1.지정가 2.시장가)									*/
		Price				  : array [0..19] of char;      //	/* 주문가격														*/
		Validity			: char;                       //	/* 체결조건 (1.FAS 2.FOK 3.FAK 4.GTC 5.GTD)						*/
		StopLossLimit	: array [0..19] of char;      //	/* stop order 지정가격											*/
		ExecPrice			: array [0..19] of char;      //	/* 체결가격														*/
		ExecQty				: array [0..19] of char;      //	/* 체결수량														*/
		RemainQty			: array [0..19] of char;      //	/* 주문잔량														*/
		Ord_no				: array [0..4] of char;       //	/* 주문번호														*/
		Orig_ord_no		: array [0..4] of char;       //	/* 원주문번호													*/
		TradeTime			: array [0..7] of char;       //	/* 주문확인,체결,거부 시간										*/
		ExecAmt				: array [0..19] of char;      //	/* 체결금액														*/
		ORD_TP 				: char;                       //	/* 주문구분	(ReplyType==0일때 1.신규 2.정정 3.취소)				*/
	  Trd_no				: array [0..4] of char;       //   /* 체결번호														*/
	  Trd_date			: array [0..7] of char;       //   /* 체결일자														*/
		Rsrb_q				: array [0..9] of char;       //	/* 청산가능수량													*/
		Open_q				: array [0..9] of char;       //	/* 잔고수량														*/
		Open_tp				: char;                       //	/* 잔고포지션구분 (1.매수 2.매도)								*/
	  Ordp_q				: array [0..9] of char;       //   /* 주문가능수량
  end;

{$ENDREGION}


Const
  Len_AccountInfo   = SizeOf( TOutAccountInfo );
  Len_SymbolListInfo = SizeOf( TOutSymbolListInfo );
  Len_OutSymbolMaster = sizeof( TOutSymbolMaster );

  Len_ReqChartData = sizeof( TReqChartData );
  Len_OutChartData = sizeof( TOutChartData );
  Len_OutChartDataSub = sizeof( TOutChartDataSub );
  // 계좌
  // 주문리스트 요청
  Len_ReqAccountFill = sizeof( TReqAccountFill );
  Len_OutAccountFillSub = sizeof( TOutAccountFillSub );
  Len_OutAccountFill  = sizeof( TOutAccountFill );
  // 잔고
  Len_ReqAccountPos = sizeof( TReqAccountPos );
  Len_OutAccountPos = sizeof( TOutAccountPOs );
  Len_OutAccountPosSub = sizeof( TOutAccountPosSub );
  // 예수금
  Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // 가능수량
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  // 실시간 요청
  Len_SendAutoKey = sizeof( TSendAutoKey );
      // 체결
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );

  //
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_AutoOrderPacket = sizeof( TAutoOrderPacket );

implementation

end.
