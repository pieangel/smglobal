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
		TranCode		  , //Tr코드
		PrevNextCode	, //연속데이타 구분(0:없음, 1:이전, 2:다음, 3:이전/다음)
		PrevNextKey		, //연속조회키
		MsgCode			  , //메시지코드
		Msg				    , //메시지
		SubMsgCode	  , //부가메시지코드
		SubMsg			  //부가메시지
	);

  TCommNoticeType = (
		Connected = 100,		// 연결 완료
		Connecting = 101,		// 소켓연결중
		Closed = 102,			// 소켓 단절 상태
		Closing = 103,			// 소켓 단절 중
		ReconnectRequest = 104,	// 재접속 요청
		ConnectFail = 105,		// 소켓 연결 실패

		//서버 공지 메시지
		NotifyMultiLogin = 150,	// 다중접속 알림 메시지
		NotifyEmergency = 151	// 긴급공지 메시지
  );

                                // Event Type,  Tag,  pData 안의 데이타 개수
  TCallBackHanaEvent = procedure( iType, iTag, iSize : integer; pData : PChar); cdecl;
                                // 로그 타입 ,  로그
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

  ////  시세 자동 업데이트  -----------------------------------------------------------------
  ///

  TSymbolHogaUnit = record
    Price	: array [0..19] of char;          //	/* 호가														*/
    PriceSign : char;
    Volume    : array [0..11] of char;      //  /* 수량														*/
    Cnt		    : array [0..6] of char;       //  /*  건수													*/
  end;

  TVolumeUd = record
    Volume  : array [0..19] of char;
  end;

  PAutoSymbolHoga = ^TAutoSymbolHoga ;
  TAutoSymbolHoga = record
    PRDT_CD     : array [0..14] of char;      //   종목코드(내부)
    {
    QUOTE_DATE  : array [0..7] of char;       //     호가일자
    QUOTE_TIME  : array [0..5] of char;       //     호가시간
    }
    KQUOTE_DATE : array [0..7] of char;       //     한국호가일자
    KQUOTE_TIME : array [0..5] of char;       //     한국호가시간

    RPT_SEQ     : array [0..7] of char;      //    seq
    TRADE_SESSION_ID : char;                  //   장구분

    Bids        : array [0..4] of  TSymbolHogaUnit;
    BIDSIZE     : array [0..14] of char;      //     매수총호가수량
    BIDCNT      : array [0..9] of char;      //     매수 전체건수

    Asks        : array [0..4] of  TSymbolHogaUnit;
    ASKSIZE     : array [0..14] of char;      //     매도총호가수량
    ASKCNT      : array [0..9] of char;      //      매도 전체건수
    BID_ASK_SIZE_DIFF : array [0..14] of char;//     매수매도 수량차
    {
    BidChgs     : array [0..3] of TVolumeUd;
    BIDSIZE_ICDC : array [0..19] of char;     //     매수총호가수량 증감
    AskChgs      : array [0..3] of TVolumeUd;
    ASKSIZE_ICDC : array [0..19] of char;     //     매도총호가수량 증감
    }
    DATETIME     : array [0..13] of char;     //     수신시간
  end;

  PAutoSymbolPrice = ^TAutoSymbolPrice;
  TAutoSymbolPrice = record
    PRDT_CD     : array[0..14] of char;   //  종목코드(내부), FID=0;
    TR_DT       : array[0..7] of char;    //  현영업일, 거래일자, FID=0;
    //TRADE_DATE  : array[0..7] of char;    //  일자, FID=0;
    //TRADE_TIME  : array[0..5] of char;    //  시간, FID=0;
    KTRADE_DATE : array[0..7] of char;    //  한국일자, FID=0;
    KTRADE_TIME : array[0..5] of char;    //  한국시간, FID=0;
    RPT_SEQ     : array[0..7] of char;    //  seq, FID=0;
    GLOBEX_TP   : char;                   //  전산장구분, FID=0;
    TRDPRC_1    : array[0..19] of char;   //  현재가, FID=0;
    TRDPRC_1_CLR: char;                   //  [TRDPRC_1]색참조(+상승, -하락), FID=0;
    NETCHNG_CLS : char;                   //  전일대비구분, FID=0;
    NETCHNG_1   : array[0..19] of char;   //  전일대비, FID=0;
    //NETCHNG_1_CLR:  char;                 //  [NETCHNG_1]색참조(+상승, -하락), FID=0;
    //PCTCHNG_1   : array[0..5] of char;    //  전일대비율, FID=0;
    //PCTCHNG_1_CLR : char;                 //  [PCTCHNG_1]색참조(+상승, -하락), FID=0;
    TRDVOL_1    : array[0..11] of char;   //  체결수량, FID=0;
    TRDVOL_1_CLR: char;                   //  [TRDVOL_1]색참조(+상승, -하락), FID=0;
    ACVOL_1     : array[0..11] of char;   //  누적체결수량, FID=0;
    OPEN_PRC    : array[0..19] of char;   //  시가, FID=0;
    //OPEN_PRC_CLR: char;                   // 색참조(+상승, -하락), FID=0;
    HIGH_1      : array[0..19] of char;   // 고가, FID=0;
    //HIGH_1_CLR  : char;                   // [HIGH_1]색참조(+상승, -하락), FID=0;
    LOW_1       : array[0..19] of char;   // 저가, FID=0;
    {
    LOW_1_CLR   : char;                   // 색참조(+상승, -하락), FID=0;
    OPEN_TIME   : array[0..5] of char;    // 시가시간, FID=0;
    HIGH_TIME   : array[0..5] of char;    // 고가시간, FID=0;
    LOW_TIME    : array[0..5] of char;    // 저가시간, FID=0;

    BID_EXEC_SUM  : array[0..14] of char; // 당일 누적체결수량(매수성향), FID=0;
    ASK_EXEC_SUM  : array[0..14] of char; // 당일 누적체결수량(매도성향), FID=0;
    BOH_EXEC_SUM  : array[0..14] of char; // 당일 누적체결수량(보합), FID=0;
    EX_BEST_BID1  : array[0..19] of char; // 체결시 매수 1호가(거래소), FID=0;
    EX_BEST_BID1_CLR:char;                // 색참조(+상승, -하락), FID=0;
    EX_BEST_ASK1  : array[0..19] of char; // 체결시 매도 1호가(거래소), FID=0;
    EX_BEST_ASK1_CLR:char;                // 색참조(+상승, -하락), FID=0;
    EX_BEST_BSIZ1 : array[0..11] of char; // 체결시 매수 1수량(거래소), FID=0;
    EX_BEST_ASIZ1 : array[0..11] of char; // 체결시 매도 1수량(거래소), FID=0;
    OPENINTEREST  : array[0..11] of char; // 미결제량, FID=0;
    OP_NETCHNG_1  : array[0..11] of char; // 미체결량대비, FID=0;
    }
  end;


/////////////////////////////////////////////////////?

{$REGION '계좌조회....'}

  /////  Hana Open API
  ///  START
  ///
  //PReqAccountDeposit = ^TReqAccountDeposit;
  TReqAccountInfo = record
		Account		 : array [0..8] of char;	          //  /* 종합계좌번호														*/
		PrdtCode	 : array [0..2] of char;            //	/* 상품번호
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

		Account			  : array [0..8] of char;       //	/* 계좌번호														*/
    AnctPrd       : array [0..2] of char;       //  계좌상품번호
		Pass				  : array [0..31] of char;       //	/* 비밀번호														*/
    PrdtCode      : array [0..31] of char;      // 상품코드
    BuySell_Type  : char;                       //	/* 매도매수구분 (S: 매도, B:매수)									*/
    Price_Type    : char;                       //	/* 가격조건구분코드	(1.지정가 2.시장가 3.스탑)									*/

    Order_Price	  : array [0..19] of char;      //	/* 주문가격														*/
    Order_Volume  : array [0..4] of char;       //	/* 주문수량														*/
    Stop_Price		: array [0..19] of char;      //	/* STOP주문가격 (STOP주문이면 입력 아니면 0 셋팅)				*/
    Control_Type  : char;                       //	/* 주문조작구분코드 (C:일반주문, M:반대매매, F:강제청산, D:FND반대매매)					*/
		Order_Div	  : char;                         //	/* 주문구분  ( O.자동청산  C.지정청산
    EtcOrd_type   : array [0..2] of char;       //     기타주문코드
    Trace_Type    : char;                       //     체결조건 (1:FAS(DAY), 6:GTD)

    Order_Org_No	: array [0..15] of char;       //	/* 원주문 번호 (					*/
		Position_No	  : array [0..14] of char;       //	/* 청산포지션번호 (					*/
    Order_ExpDay  : array [0..7] of char;        //	/* 주문만료일자												*/

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
    rltm_dpch_dcd       : char;                     //    실시간통보구분코드, FID=0;
    usr_id			        : array [0..19] of char;    //   사용자ID, FID=0;
    rltm_dpch_prcs_dcd	: array [0..1] of char;     //    실시간통보처리구분코드, FID=0;
    cano			          : array [0..7] of char;     //    종합계좌번호, FID=0;
    ctno			          : array [0..8] of char;     //    종합계좌대체번호, FID=0;
    apno			          : array [0..2] of char;     //    계좌상품번호, FID=0;
    prdt_cd			        : array [0..31] of char;    //    상품코드, FID=0;
    odrv_ordr_tp_dcd	  : char;                     //     해외파생주문유형구분코드, FID=0;
    ordr_stts_dcd		    : char;                     //     주문상태구분코드, FID=0;
    odrv_odno		        : array [0..15] of char;    //    해외파생주문번호, FID=0;
    odrv_or_odno		    : array [0..15] of char;    //    해외파생원주문번호, FID=0;
    ordr_dt		  	      : array [0..7] of char;     //    주문일자, FID=0;
    //cust_nm			: array [0..50] of char;    //    고객명, FID=0;
    odrv_sell_buy_dcd	  : char;                      //    해외파생매도매수구분코드, FID=0;
    odrv_ordr_prc_ctns	: array [0..19] of char;    //    해외파생주문가격내용, FID=0;
    ordr_qnt_ctns		    : array [0..19] of char;    //    주문수량내용, FID=0;
    odrv_prc_dcd		    : char;                     //     해외파생가격구분코드, FID=0;
    cncs_cnd_dcd		    : char;                     //    체결조건구분코드, FID=0;
    cnd_prc_ctns		    : array [0..19] of char;    //    조건가격내용, FID=0;
    comm_mdia_dcd		    : array [0..2] of char;     //    통신매체구분코드, FID=0;
    acpt_tm			        : array [0..5] of char;     //    접수시각, FID=0;
    excg_cncs_tm		    : array [0..5] of char;     //    거래소체결시각, FID=0;
    acpl_acpt_tm		    : array [0..5] of char;     //    현지접수시각, FID=0;
    cncs_tm			        : array [0..5] of char;     //    체결시각, FID=0;
    cncs_dt			        : array [0..7] of char;     //    체결일자, FID=0;
    odrv_cncs_no		    : array [0..7] of char;     //    해외파생체결번호, FID=0;
    cncs_qnt_ctns		    : array [0..19] of char;    //    체결수량내용, FID=0;
    odrv_cncs_prc_ctns	: array [0..19] of char;    //    해외파생체결가격내용, FID=0;
    //odrv_cncs_amt_ctns	: array [0..29] of char;    //    해외파생체결금액내용, FID=0;
    crry_cd			        : array [0..2] of char;     //    통화코드, FID=0;
    ordr_rmn_qnt_ctns	  : array [0..19] of char;    //    주문잔여수량내용, FID=0;
    acnt_dcd		        : char;                     //    계좌구분코드, FID=0;
    entr_clr_dcd		    : char;                     //     진입청산구분코드, FID=0;
    clr_pst_no		      : array [0..15] of char;    //    청산포지션번호, FID=0;
    pst_no			        : array [0..15] of char;    //    포지션번호, FID=0;
  end;


  PAutoOrderResponse = ^TPAutoOrderResponse;
  TPAutoOrderResponse = record
    rltm_dpch_dcd       : char;				                    //  실시간통보구분코드;
    usr_id              : array [0..19] of char;					//  사용자ID;
    rltm_dpch_prcs_dcd  : array [0..1] of char;		        //  실시간통보처리구분코드;
    cano                : array [0..7] of char;					  //  종합계좌번호;
    ctno                : array [0..8] of char;					  //  종합계좌대체번호;
    apno                : array [0..2] of char;					  //  계좌상품번호;
    odrv_odno           : array [0..15] of char;				  //  해외파생주문번호;
    prdt_cd             : array [0..31] of char;				  //  상품코드;
    odrv_or_odno        : array [0..15] of char;		    	//  해외파생원주문번호;
    odrv_mo_odno        : array [0..15] of char;		    	//  해외파생모주문번호;
    ordr_grup_no        : array [0..15] of char;			    //  주문그룹번호;
    ordr_dt             : array [0..7] of char;				  	//  주문일자;
    //cust_nm             : array [0..49] of char;			  	//  고객명;
    odrv_sell_buy_dcd   : char;		                      	//  해외파생매도매수구분코드;
    odrv_ordr_prc_ctns  : array [0..19] of char;		      //  해외파생주문가격내용;
    ordr_qnt_ctns       : array [0..19] of char;			    //  주문수량내용;
    rvse_qnt_ctns       : array [0..19] of char;			    //  정정수량내용;
    cncl_qnt_ctns       : array [0..19] of char;			    //  취소수량내용;
    cncs_qnt_smm_ctns   : array [0..19] of char;	      	//  체결수량합계내용;
    ordr_rmn_qnt_ctns   : array [0..19] of char;		      //  주문잔여수량내용;
    odrv_prc_dcd        : char;				                    //  해외파생가격구분코드;
    cncs_cnd_dcd        : char;				                    //  체결조건구분코드;
    cnd_prc_ctns        : array [0..19] of char;			    //  조건가격내용;
    avr_cncs_prc_ctns   : array [0..19] of char;		      //  평균체결가격내용;
    odrv_pv_ctns        : array [0..19] of char;			    //  해외파생현재가내용;
    cncs_rt_ctns        : array [0..19] of char;			    //  체결율내용;
    comm_mdia_dcd       : array [0..2] of char;			      //  통신매체구분코드;
    odrv_ordr_tp_dcd    : char;			                      //  해외파생주문유형구분코드;
    ordr_stts_dcd       : char;				                    //  주문상태구분코드;
    //fcm_odno            : array [0..59] of char;				  //  FCM주문번호;
    //athz_ip_addr        : array [0..38] of char;			    //  공인IP주소;
    acpt_tm             : array [0..5] of char;					  //  접수시각;
    excg_cncs_tm        : array [0..5] of char;			      //  거래소체결시각;
    acpl_acpt_tm        : array [0..5] of char;			      //  현지접수시각;
    cncs_tm             : array [0..5] of char;					  //  체결시각;
    crry_cd             : array [0..2] of char;					  //  통화코드;
    cncs_qnt_ctns       : array [0..19] of char;			    //  체결수량내용;
    ordr_expr_dt        : array [0..7] of char;			      //  주문만료일자;
    acnt_dcd            : char;					                  //   계좌구분코드;
    entr_clr_dcd        : char;				                    //  진입청산구분코드;
    clr_pst_no          : array [0..15] of char;				  //  청산포지션번호;
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
  //Len_ReqAccountDeposit = sizeof( TReqAccountDeposit );
  //Len_OutAccountDeposit = sizeof( TOutAccountDeposit );
  // 가능수량
  Len_ReqAbleQty = sizeof( TReqAbleQty );
  Len_OutAbleQty = sizeof( TOutAbleQty );
  

      //  시세
  Len_AutoSymbolPrice = sizeof( TAutoSymbolPrice );
  Len_AutoSymbolHoga  = sizeof( TAutoSymbolHoga );

      //  주문
  Len_SendOrderPacket = sizeof( TSendOrderPacket );
  Len_AutoOrderPacket = sizeof( TAutoOrderPacket );
  Len_AutoOrderResponse = sizeof( TPAutoOrderResponse );


  ApieEventName : array [ TApiEventType ] of string = ('None', 'AcntList',
    'DemoList','AcntPos','Deposit','ActiveOrd','SymbolMaster','SymbolInfo',
    'Qutoe','OrderAck','Order','Notice' );  


implementation



end.
