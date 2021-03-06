unit ApiConsts;

interface

const

// 계좌 관련
 ESID_5601	 =			5601 ;	// 신규주문
 ESID_5602	 =			5602 ;	// 정정주문
 ESID_5603	 =			5603 ;	// 취소주문
 ESID_5611	 =			5611 ;	// 실체결
 ESID_5612	 =			5612 ;	// 실잔고
 ESID_5614	 =			5614 ;	// 계좌별 주문체결현황
 ESID_5615	 =			5615 ;	// 예탁자산및 증거금
 ESID_5633	 =			5633 ;	// 해외선물 청산가능수량 조회

 // 시세 관련
 ESID_5501	 =			5501 ;	// 종목 Master
 ESID_5502	 =			5502 ;	// 종목 시세
 ESID_5503	 =			5503 ;	// 종목 호가
 ESID_5511	 =			5511 ;	// 종목 체결내역
 ESID_5522	 =		  5522 ;	// 선물 CHART DATA

// 자동업데이트
 AUTO_0931	 =			 931 ;	// 종목 Master 실시간
 AUTO_0932	 =			 932 ;	// 종목 호가 실시간
 AUTO_0933	 =			 933 ;	// 종목 시세 실시간
 AUTO_0985	 =			 985 ;	// 잔고/체결 실시간

type

  TResultType = ( rtNone, rtAutokey, rtUserID, rtUserPass, rtCertPass, rtSvrSendData,
    rtSvrConnect, rtSvrNoConnect, rtCerTest, rtDllNoExist, rtTrCode );

implementation



end.
