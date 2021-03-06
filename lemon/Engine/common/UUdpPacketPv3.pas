unit UUdpPacketPv3;

interface
const
  TrFill = 'A3';
  TrRecovery = 'B2';
  TrHoga = 'B6';
  TrElwHoga = 'B7';
  TrFillNHoga = 'G7';
  TrK200  = 'D2';
  TrK200expect = 'EX';
  TrElwGreeks = 'C7';
  TrOptionGreeks = 'N7';
  TrInvestorData = 'H1';

  //H2034 : 미결제약정수량

  TrVKospi = 'J3';
  TrCPPP = 'N0';
  TrK200Risk = 'O8';
  TrFKospi = 'K9';
  TrOpenInterest = 'H2';

  StockNElw = '1';
  IndexDer = '4';
  StockDer = '5';

  OptInfo  = '03';
  FutInfo  = '01';
  VInfo    = '04'; // 변동성 지수

  K200Indust = '029';

  K200Risk6Per  = '711';
  K200Risk8Per  = '712';
  K200Risk10Per = '713';
  K200Risk12Per = '714';

type
  PCommonHeader = ^TCommonHeader;
  TCommonHeader = packed record
    DataDiv : array [0..1] of char;   // 데이타구분  AB6, A3, G7
    InfoDiv : array [0..1] of char;   // 정보구분  01 : 선물 , 03 : 옵션
    MarketDiv : char;                 // 시장구분   5 : 개별 ,  4 : 지수
    //
    Code    : array [0..11] of char;  // 종목코드
  end;

  SFutPriceQtyItem = packed record
    Sign  : char;
    Price : array [0..6] of char;
    Volume: array [0..5] of char;
  end;

  FutPriceQtyItem = packed record
    Sign  : char;
    Price : array [0..4] of char;
    Volume: array [0..5] of char;
  end;

  OptPriceQtyItem = packed record
    Price : array [0..4] of char;
    Volume: array [0..6] of char;
  end;

  SFutCountItem = packed record
    Cnt1:   array[0..3] of Char;
    Cnt2:   array[0..3] of Char;
    Cnt3:   array[0..3] of Char;
    Cnt4:   array[0..3] of Char;
    Cnt5:   array[0..3] of Char;
    Cnt6:   array[0..3] of Char;
    Cnt7:   array[0..3] of Char;
    Cnt8:   array[0..3] of Char;
    Cnt9:   array[0..3] of Char;
    Cnt10:  array[0..3] of Char;
  end;

  DerCountItem = packed record
    Cnt1:   array[0..3] of Char;
    Cnt2:   array[0..3] of Char;
    Cnt3:   array[0..3] of Char;
    Cnt4:   array[0..3] of Char;
    Cnt5:   array[0..3] of Char;
  end;

  // Stock Futures Price & Fill & (price & fill )-------------------------------
  //

  PStockFutPrice = ^TStockFutPrice;
  TStockFutPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..3] of char;
    MarketStat  : array [0..1] of char;
    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..9] of SFutPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..9] of SFutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: SFutCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems: SFutCountItem;
    AcptTime    : array [0..7] of char;
  end;

  PStockFutTick = ^TStockFutTick;
  TStockFutTick = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..3] of char;
    CurSign  : char;
    CurPrice  : array [0..6] of char;
    Volume    : array [0..5] of char;
    TickType  : array [0..1] of char;
    TickTime  : array [0..7] of char;
    NearPrice : array [0..6] of char;
    FarPrice  : array [0..6] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..6] of char;
    HighSign  : char;
    HighPrice : array [0..6] of char;
    LowSign   : char;
    LowPrice  : array [0..6] of char;
    PrevSign  : char;
    PrevPrice : array [0..6] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..14] of char;
    LastLSCode : char;
    RealUpperLimitSign  : char;
    RealUpperLimit : array [0..6] of char;
    RealLowerLimitSign   : char;
    RealLowerLimit  : array [0..6] of char;
  end;

  PStockFutTickPrice = ^TStockFutTickPrice;
  TStockFutTickPrice = packed record
    //Tick  : TStockFutTick;
    Code  : array [0..11] of char;
    Seq   : array [0..3] of char;
    CurSign  : char;
    CurPrice  : array [0..6] of char;
    Volume    : array [0..5] of char;
    TickType  : array [0..1] of char;
    TickTime  : array [0..7] of char;
    NearPrice : array [0..6] of char;
    FarPrice  : array [0..6] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..6] of char;
    HighSign  : char;
    HighPrice : array [0..6] of char;
    LowSign   : char;
    LowPrice  : array [0..6] of char;
    PrevSign  : char;
    PrevPrice : array [0..6] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..14] of char;
    LastLSCode : char;
    //
    MarketStat  : array [0..1] of char;

    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..9] of SFutPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..9] of SFutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: SFutCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems: SFutCountItem;
    RealUpperLimitSign  : char;
    RealUpperLimit : array [0..6] of char;
    RealLowerLimitSign   : char;
    RealLowerLimit  : array [0..6] of char;
    //AcptTime    : array [0..7] of char;
  end;

  //
  // End Stock Futures Price & Fill & (price & fill )---------------------------

  // Kospi2200 Futures Price & Fill & (price & fill )---------------------------
  //

  PFutPrice = ^TFutPrice;
  TFutPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..1]  of char;
    BoardID  : array [0..1] of char;
    SessionID : array[0..1] of char;
    //
    BidTotVol  : array [0..5] of char;
    BidItems   : array [0..4] of FutPriceQtyItem;
    AskTotVol : array [0..5] of char;
    AskItems  : array [0..4] of FutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    AcptTime    : array [0..7] of char;
    ExpectSign  : char;                                 //2012.06.25 적용
    ExpectPrice  : array[0..4] of char;                 //2012.06.25 적용
  end;

  PFutTick  = ^TFutTick;
  TFutTick  = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..1]  of char;
    BoardID : array[0..1] of char;
    CurSign : char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..5] of char;
    SessionID : array[0..1] of char;
    TickTime: array [0..7] of char;
    NearPrice : array [0..4] of char;
    FarPrice  : array [0..4] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..4] of char;
    HighSign  : char;
    HighPrice : array [0..4] of char;
    LowSign   : char;
    LowPrice  : array [0..4] of char;
    PrevSign  : char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..11] of char;  //2011.05.23 11 -> 12byte 변경
    BlockDailyVolume : array [0..6] of char;
    LastLSCode : char;
    RealUpperLimitSign  : char;
    RealUpperLimit : array [0..4] of char;
    RealLowerLimitSign   : char;
    RealLowerLimit  : array [0..4] of char;
    EndText : char;
  end;

  PFutTickPrice = ^TFutTickPrice;
  TFutTickPrice = packed record
    //Tick  : TFutTick;
    Code  : array [0..11] of char;
    Seq   : array [0..1]  of char;
    BoardID : array[0..1] of char;
    CurSign : char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..5] of char;
    SessionID : array[0..1] of char;
    TickTime: array [0..7] of char;
    NearPrice : array [0..4] of char;
    FarPrice  : array [0..4] of char;
    //
    OpenSign  : char;
    OpenPrice : array [0..4] of char;
    HighSign  : char;
    HighPrice : array [0..4] of char;
    LowSign   : char;
    LowPrice  : array [0..4] of char;
    PrevSign  : char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..6] of char;
    DailyPrice  : array [0..11] of char;  //2011.05.23 11 -> 12byte 변경
    BlockDailyVolume : array [0..6] of char;
    LastLSCode : char;

    BidTotVol  : array [0..5] of char;
    BidItems   : array [0..4] of FutPriceQtyItem;
    AskTotVol : array [0..5] of char;
    AskItems  : array [0..4] of FutPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;

    RealUpperLimitSign  : char;
    RealUpperLimit : array [0..4] of char;
    RealLowerLimitSign   : char;
    RealLowerLimit  : array [0..4] of char;
    EndText : char;
  end;

  //
  // End Kospi2200 Futures Price & Fill & (price & fill )-----------------------

  // Kospi2200 Options Price & Fill & (price & fill )---------------------------
  //

  POptPrice = ^TOptPrice;
  TOptPrice = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    BoardID  : array [0..1] of char;
    SessionID : array[0..1] of char;
    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..4] of OptPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..4] of OptPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    AcptTime    : array [0..7] of char;
    ExpectPrice  : array[0..4] of char;                 //2012.06.25 적용
  end;

  POptTick  = ^TOptTick;
  TOptTick  = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    BoardID : array[0..1] of char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..6] of char;
    SessionID : array[0..1] of char;
    TickTime: array [0..7] of char;
    //
    OpenPrice : array [0..4] of char;
    HighPrice : array [0..4] of char;
    LowPrice  : array [0..4] of char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..7] of char;
    DailyPrice  : array [0..10] of char;
    BlockDailyVolume : array [0..7] of char;
    LastLSCode : char;
    RealUpperLimit : array [0..4] of char;
    RealLowerLimit  : array [0..4] of char;
  end;

  POptTickPrice = ^TOptTickPrice;
  TOptTickPrice = packed record
    //Tick  : TOptTick;
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    BoardID : array[0..1] of char;
    CurPrice : array [0..4] of char;
    Volume  : array [0..6] of char;
    SessionID : array[0..1] of char;
    TickTime: array [0..7] of char;
    //
    OpenPrice : array [0..4] of char;
    HighPrice : array [0..4] of char;
    LowPrice  : array [0..4] of char;
    PrevPrice : array [0..4] of char;
    //
    DailyVolume : array [0..7] of char;
    DailyPrice  : array [0..10] of char;
    BlockDailyVolume : array [0..7] of char;
    LastLSCode : char;

    //
    BidTotVol  : array [0..6] of char;
    BidItems   : array [0..4] of OptPriceQtyItem;
    AskTotVol : array [0..6] of char;
    AskItems  : array [0..4] of OptPriceQtyItem;
    //
    BidTotCnt  : array [0..4] of char;
    BidCntItems: DerCountItem;
    AskTotCnt : array [0..4] of char;
    AskCntItems:DerCountItem;
    RealUpperLimit : array [0..4] of char;
    RealLowerLimit  : array [0..4] of char;
  end;

  //
  // End Kospi2200 Options Price & Fill & (price & fill )-----------------------

  TStockPricItem = packed record
    AskPrice  : array [0..8] of char;
    BidPrice   : array [0..8] of char;
    AskVolume : array [0..11] of char;
    BidVolume  : array [0..11] of char;
  end;

  TElwPriceItem = packed record
    PriceItem : TStockPricItem;
    LpAskVolume : array [0..11] of char;
    LpBidVolume  : array [0..11] of char;
  end;

  PStockPrice = ^TStockPrice;
  TStockPrice = packed record
    Code    : array [0..11] of char;
    Seq : array[0..4] of char;
    Volume  : array [0..11] of char;
    PriceItems  : array [0..9] of TStockPricItem;
    AskTotVol : array [0..11] of char;
    BidTotVol  : array [0..11] of char;
    Fillter : array [0..23] of char;    // addy by l.c.s   2010.4.23
    EndAskTotVol : array[0..11] of char;
    EndBidTotVol : array[0..11] of char;
    SessionID  : array [0..1] of char;
    BoardID : array[0..1] of char;
    ExpectPrice  : array [0..8] of char;
    ExpectVolume : array [0..11] of char;
    DirectionType : char;
    Filler : array[0..6] of char;
    EndText : char;
  end;

  PElwPrice = ^TElwPrice;
  TElwPrice = packed record
    Code    : array [0..11] of char;
    Volume  : array [0..11] of char;
    Seq : array[0..4] of char;
    PriceItems  : array [0..9] of TElwPriceItem;
    AskTotVol : array [0..11] of char;
    BidTotVol  : array [0..11] of char;
    Fillter : array[0..23] of char;
    EndAskTotVol : array[0..11] of char;
    EndBidTotVol : array[0..11] of char;
    SessionID  : array [0..1] of char;
    BoardID : array[0..1] of char;
    ExpectPrice  : array [0..8] of char;
    ExpectVolume : array [0..11] of char;
    DirectionType : char;
    Filler : array[0..6] of char;
    EndText : char;
  end;


  PStockTick  = ^TStockTick;
  TStockTick  = packed record
    Code  : array [0..11] of char;
    Seq : array[0..4] of char;
    BoardID : array[0..1] of char;

    ChangeDiv : char;
    Change    : array [0..8] of char;

    Price   : array [0..8] of char;
    Volume  : array [0..9] of char;
    SessionID : array [0..1] of char;

    //
    OpenPrice : array [0..8] of char;
    HighPrice : array [0..8] of char;
    LowPrice  : array [0..8] of char;

    //
    TotACumulVolume : array [0..11] of char;
    TotACumulPrice  : array [0..17] of char;

    Side  : char; // 1 : 매도 , 2 : 매수
    FillSameDiv : char;   // 0 : 판단불가, 1 :일치  2 : 불일치
    FillTime  : array [0..5] of char;
    LpVolume  : array [0..14] of char;

    AskPrice  : array [0..8] of char;
    BidPrice  : array [0..8] of char;
    Filler : array[0..5] of char;
    EndText : char;
  end;

  PElwGreeks = ^TElwGreeks;
  TElwGreeks = packed record
    Code  : array [0..11] of char;
    Time  : array [0..5] of char;
    Theory  : array [0..9] of char;   //  100
    DeltaSign : char;
    Delta : array [0..6] of char;     // 1000000
    GammanSign : char;
    Gamman  : array [0..6] of char;   // 1000000
    ThetaSign : char;
    Theta : array [0..11] of char;    // 1000000
    VegaSign : char;
    Vega  : array [0..11] of char;
    RhoSign : char;
    Rho : array [0..11] of char;
    IV  : array [0..4] of char;       // 100
    Cost : array [0..9] of char;
    Filler : array [0..5] of char;
    TextEnd : char;
  end;


  POptOpenInterest = ^TOptOpenInterest;   // H2034
  TOptOpenInterest = packed record
    Code  : array [0..11] of char;
    Seq         : array [0..2] of char;
    OIDiv       : array [0..1] of char;   // 'MO : 전일확정  오전 7시40분경
    TradeDate   : array [0..7] of char;
    OIQty       : array [0..8] of char;
    TextEnd     : char;
  end;

  PFutOpenInterest = ^TFutOpenInterest;   // H2014
  TFutOpenInterest = packed record
    Code  : array [0..11] of char;
    Seq         : array [0..1] of char;
    OIDiv       : array [0..1] of char;   // MO : 전일확정  오전 7시40분경     M1 : 당일 잠정
    TradeDate   : array [0..7] of char;   // M1 : 당일 확정 장종료후 1시간후
    OIQty       : array [0..8] of char;
    TextEnd     : char;
  end;

  // Index Data ----------------------------------------------------------------
  //

  PIndexData  = ^TIndexData;
  TIndexData  = packed record
    IndustCode  : array [0..2] of char;
    Indextime   : array [0..5] of char;
    IndexPrice  : array [0..7] of char;  //6.2
    Sign        : char;
    Change      : array [0..7] of char;
    Volume      : array [0..7] of char; // 천주
    Amount      : array [0..7] of char; // 백만
  end;

  // 커버드콜_프로텍티브풋지수
  PCP_PPIndexData = ^TCP_PPIndexData;
  TCP_PPIndexData = packed record
    IndustCode  : array [0..2] of char;
    Indextime   : array [0..5] of char;
    CPIndex     : array [0..7] of char;  //6.2
    CPSign      : char;
    CPChange    : array [0..7] of char;
    PPIndex     : array [0..7] of char;  //6.2
    PPSign      : char;
    PPChange    : array [0..7] of char;
  end;

  // Index Data Expect
  PIndexExpectData  = ^TIndexExpectData;
  TIndexExpectData  = packed record
    expectCode  : array [0..5] of char;
    expecttime  : array [0..10] of char;
    expectPrice : array [0..4] of char;  //3.2
  end;

  TOptHoga = packed record
    Price : array [0..4] of char;
    Volume: array [0..6] of char;
    Cnt   : array [0..3] of char;
  end;

  POptSisRecovery = ^TOptSisRecovery;
  TOptSisRecovery = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..2]  of char;
    CurPrice : array [0..4] of char;
    OpenPrice : array [0..4] of char;
    HighPrice : array [0..4] of char;
    LowPrice  : array [0..4] of char;
    OpenInterest : array [0..8] of char;

    DailyVolume : array [0..7] of char;
    DailyPrice  : array [0..10] of char;

    Ask1  : TOptHoga;
    Bid1  : TOptHoga;

    Ask2  : TOptHoga;
    Bid2  : TOptHoga;

    Ask3  : TOptHoga;
    Bid3  : TOptHoga;

    Ask4  : TOptHoga;
    Bid4  : TOptHoga;

    Ask5  : TOptHoga;
    Bid5  : TOptHoga;

    AskTotVolume : array [0..6] of char;
    AskTotCnt    : array [0..4] of char;
    BidTotVolume : array [0..6] of char;
    BidTotCnt    : array [0..4] of char;

    MarketStat  : array [0..1] of char;    // 40 접속
  end;


  POptionGreeks = ^TOptionGreeks;
  TOptionGreeks = packed record
    Code  : array [0..11] of char;
    Seq   : array [0..6]  of char;
    Date  : array [0..7]  of char;
    Time  : array [0..7]  of char;
    cDiv  : char;         // 1: 전일확정, 2: 장중산출, 3: 당일확정, E: 장중완료
    UnderID : array [0..2]  of char;    // K2I

    DeltaSign : char;
    Delta : array [0..17] of char;     // 100000000000.000000
    ThetaSign : char;
    Theta : array [0..17] of char;     // 100000000000.000000
    VegaSign  : char;
    Vega  : array [0..17] of char;     // 100000000000.000000
    GammaSign : char;
    Gamma  : array [0..17] of char;    // 100000000000.000000
    RhoSign : char;
    Rho : array [0..17] of char;
  end;

  PInvestorData = ^TInvestorData;
  TInvestorData = packed record
    Date  : array [0..7]  of char;
    Time  : array [0..5]  of char;
    DataType : array[0..1] of char;
    PrtID : array[0..10] of char;
    cCP : char;
    InvestType : array[0..3] of char;  // 개인 : 8000, 외국인 : 9000, 증권회사 : 1000, 보험회사 : 1200, 자산운용회사 :3000, 은행 : 4000, 종금 : 5000, 연,기금 : 6000
    BidQty : array[0..8] of char;
    AskQty : array[0..8] of char;
    BidAmount : array[0..17] of char;
    AskAmount : array[0..17] of char;
    EndText : char;
  end;

  PInvestorDataFut = ^TInvestorDataFut;
  TInvestorDataFut = packed record
    Date  : array [0..7]  of char;
    Time  : array [0..5]  of char;
    DataType : array[0..1] of char;
    PrtID : array[0..10] of char;

    InvestType : array[0..3] of char;  // 개인 : 8000, 외국인 : 9000, 증권회사 : 1000, 보험회사 : 1200, 자산운용회사 :3000, 은행 : 4000, 종금 : 5000, 연,기금 : 6000
    BidQty : array[0..8] of char;
    AskQty : array[0..8] of char;
    BidAmount : array[0..17] of char;
    AskAmount : array[0..17] of char;

    SFBidQty : array[0..8] of char;
    SFAskQty : array[0..8] of char;
    SFBidAmount : array[0..17] of char;
    SFAskAmount : array[0..17] of char;

    EndText : char;
  end;                 

  ////////////////////////////파생마스터///////////////////////////////////
  PDerMasterpv2 = ^TDerMasterpv2;
  TDerMasterpv2 =  record
     datatype : array[0..4] of char;                          //데이터구분 A0015 : 주식선물, A0014 : 지수선물, A0034 : 지수옵션
     listingqty : array[0..4] of char;                        //종목수
     calldate : array[0..7] of char;                          //영업일자
     code : array[0..11] of char;                             //종목코드
     seq : array[0..5] of char;                               //종목 SEQ
     prdID : array[0..10] of char;                             //파생상품ID(상품구분코드)
     shortcode : array[0..8] of char;                         //선물종목 단축코드
     korname : array[0..79] of char;                          //한글종목명
     shortdesc : array[0..39] of char;                        //종목한글약명
     engname : array[0..79] of char;                          //영문종목명
     shortengname : array[0..39] of char;                     //종목영문약명
     listingdate : array[0..7] of char;                       //상장일
     listclosedate : array[0..7] of char;                     //상장폐지일자
     spreadcode : char;                                       //스프레드기준종목구분코드   F:원월종목, N:근월종목
     settlecode : char;                                       //최종결제방법코드   C:현금결제, D:실물인수도결제
     signhigh : char;                                         //Sign 부호
     highlimit : array[0..11] of char;                        //상한가
     signlow : char;                                          //Sign 부호
     lowlimit : array[0..11] of char;                         //하한가
     baseprice : array[0..11] of char;                        //기준가
     underlyID : array[0..2] of char;                         //기초자산ID
     rightcode : char;                                        //권리행사유형코드  A:미국형,E:유럽형,Z:기타
     spreadtypecode : array[0..1] of char;                    //스프레드유형코드
     spnareprdtID : array[0..11] of char;                     //스프레드 근월물 표준코드
     spfarprdtID : array[0..11] of char;                      //스프레드 원월물 표준코드
     lasttradedate : array[0..7] of char;                     //최종거래일
     lastsettledate : array[0..7] of char;                    //최종결제일자
     monthcode : array[0..2] of char;                         //월물구분코드 1:최근월물,선물스프레드 2:2째월물 3:3째월물 4:4째월물 5:5째월물 6:6째월물 7:7째월물
     maturitydate : array[0..7] of char;                      //만기일자
     strikeprice : array[0..16] of char;                      //행사가격
     adjusttype : char;                                       //조정구분  C:거래단위조정, N:조정없음, O:미결제조정
     priceunit : array[0..16] of char;                        //거래단위   1계약에 해당하는 기초자산수량 (3년국채선물:1억원, 달러선물:5만달러, 엔선물:5백만엔)
     priceunits : array[0..20] of char;                       //거래승수   약정대금 및 결제시 사용하는 계산승수 (KOSPI200선물:50만, KOSPI200옵션:10만,  국채선물:100만, CD선물:125만)
     ismarketmakeissue : char;                                //시장조성구분코드
     listingcode : char;                                      //상장유형코드
     atm : array[0..11] of char;                              //등가격
     adjustcode : array[0..1] of char;                        //조정사유코드
     underlyingcode : array[0..11] of char;                   //기초자산종목코드
     underlyingclose : array[0..11] of char;                  //기초자산종가
     remdays : array[0..6] of char;                           //잔존일수
     adjustprice : array[0..16] of char;                      //조정기준가격
     basepricecode : array[0..1] of char;                     //기준가격구분코드
     tradebasepricecode : char;                               //매매용기준가격구분코드
     signclose : char;                                        //sign 부호
     prevaclose : array[0..16] of char;                       //전일조정종가
     isblocktrade : char;                                     //협의대량매매대상여부
     prevdeposit : array[0..16] of char;                      //전일증거금기준가격
     prevdepositcode : array[0..1] of char;                   //전일증거금기준가격구분코드
     thprice : array[0..14] of char;                          //이론가격(정산가)
     thpricebase : array[0..14] of char;                      //이론가격(기준가)
     prevadjustprice : array[0..16] of char;                  //전일 정산가격
     istradestop : char;                                      //거래정지여부
     cbhigh : array[0..11] of char;                           //C.B. 적용 상한가
     cblow : array[0..11] of char;                            //C.B. 적용 하한가
     sstrikeprice : array[0..16] of char;                     //조회용행사가격
     isatm : char;                                            //ATM구분
     islasttradedate : char;                                  //최종거래일 여부
     prevdividendrate : array[0..14] of char;                 //전일정산가격용배당가치
     signprevclose : char;                                    //sign 부호
     prevclose : array[0..11] of char;                        //전일 종가
     prevcolsetype : char;                                    //전일 종가 구분
     signprevopen : char;                                     //sign 부호
     prevopen : array[0..11] of char;                         //전일 시가
     signprevhigh : char;                                     //sign 부호
     prevhigh : array[0..11] of char;                         //전일 고가
     signprevlow : char;                                      //sign 부호
     prevlow : array[0..11] of char;                          //전일 저가
     settledate : array[0..7] of char;                        //최초체결일자
     prevsettletime : array[0..7] of char;                    //전일최초체결시각
     prevadjustpricetype : array[0..1] of char;               //전일 정산가격 구분
     signdisparateratio : char;                               //sign 부호
     disparateratio : array[0..11] of char;                   //정산가격이론가격괴리율
     prevopenpositions : array[0..9] of char;                 //전일 미결제약정수량
     signbid : char;                                          //sign 부호
     prevbidprice : array[0..11] of char;                     //전일매도우선호가가격
     signask : char;                                          //sign 부호
     prevaskprice : array[0..11] of char;                     //전일매수우선호가가격
     previv : array[0..9] of char;                            //내재변동성
     signlisthigh : char;                                     //sing 부호
     listhigh : array[0..11] of char;                         //상장중 최고가
     signlistlow : char;                                      //sing 부호
     listlow : array[0..11] of char;                          //상장중 최저가
     signyearhigh : char;                                     //sing 부호
     yearhigh : array[0..11] of char;                         //연중최고가
     signyearlow : char;                                      //sing 부호
     yearlow : array[0..11] of char;                          //연중최저가
     listhighdate : array[0..7] of char;                      //상장중 최고가 일자
     listlowdate : array[0..7] of char;                       //상장중 최저가 일자
     yearhighdate : array[0..7] of char;                      //연중 최고가 일자
     yearlowdate : array[0..7] of char;                       //연중 최저가 일자
     yearbaseday : array[0..7] of char;                       //연간기준일수
     monthtradeday : array[0..7] of char;                     //월간거래일수
     yeartradeday : array[0..7] of char;                      //연간거래일수
     prevfillunit : array[0..15] of char;                     //전일체결건수
     prevfillqty : array[0..11] of char;                      //전일체결수량
     prevamt : array[0..21] of char;                          //전일거래대금
     blocktradeqty : array[0..11] of char;                    //전일협의대량매매체결수량
     blocktradeamt : array[0..21] of char;                    //전일협의대량매매거래대금
     cdrate : array[0..5] of char;                            //cd금리
     unsettledmaxcon : array[0..14] of char;                  //미결제 한도 계약수
     attachedprdt : array[0..3] of char;                      //소속 상품군
     prdtoptrate : array[0..8] of char;                       //상품군 옵셋율
     hogatype : array[0..4] of char;                          //지정가호가조건구분코드     BitWise 정의 사용
     mhogatype : array[0..4] of char;                         //시장가호가조건구분코드     BitWise 정의 사용
     chogatype : array[0..4] of char;                         //조건부지정가호가조건구분코드  BitWise 정의 사용
     ahogatype : array[0..4] of char;                         //최유리지정가호가조건구분코드  BitWise 정의 사용
     isEFPTrade : char;                                       //EFP거래대상여부
     isFLEXTrade : char;                                      //FLEX거래대상여부
     prevEFPFillVol : array[0..11] of char;                   //전일EFP체결수량
     prevEFPAmount : array[0..21] of char;                    //전일EFP거래대금
     isHoliday : char;                                        //휴장여부
     isRealPricelimit : char;                                 //실시간가격제한여부
     realHighsign : char;
     realHighGap : array[0..11] of char;                      //실시간상한가간격
     realLowsign : char;
     realLowGap : array[0..11] of char;                       //실시간하한가간격
     filler : array[0..82] of char;
     endtext : char;
  end;

  pSTMasterpv2 = ^TStockMasterpv2;
  TStockMasterpv2 = record
    datatype : array[0..4] of char;                           //데이터구분(A0)
    code : array[0..11] of char;                              //표준코드
    seqno : array[0..7] of char;                              //일련번호
    shortcode : array[0..8] of char;                          //단축코드
    korname : array[0..39] of char;                           //종목이름
    engname : array[0..39] of char;                           //종목이름(영문)
    calldate : array[0..7] of char;                           //영업일자
    infoGroupNo : array[0..4] of char;                        //정보분배그룹번호
    groupID : array[0..1] of char;                            //증권그룹ID
    isunitfill : char;                                        //단위매매체결여부
    rocktype : array[0..1] of char;                           //권배락 구분
    facevaluechange : array[0..1] of char;                    //액면가변경구분코드
    isopenbase : char;                                        //시가기준가격종목여부
    retryCode : array[0..1] of char;                          //재평가종목사유코드
    isbaseprice : char;                                       //기준가격변경종목여부
    isEnd : char;                                             //임의종료가능여부
    isWarn : char;                                            //시장경보위험예고여부
    Warncode : array[0..1] of char;                           //시장경보구분코드
    isStruct : char;                                          //지배구조우량여부
    isadmin : char;                                           //관리종목여부
    isannounce : char;                                        //불성실공시지정여부
    isbackdoorlist : char;                                    //우회상장여부
    istradestop : char;                                       //거래정지여부
    indexbigcode : array[0..2] of char;                       //지수업종대분류코드
    indexmidcode : array[0..2] of char;                       //지수업종중분류코드
    indexsmallcode : array[0..2] of char;                     //지수업종소분류코드
    inducode : array[0..9] of char;                           //표준산업코드
    kospiindu : char;                                         //KOSPI200 세부업종
    AVOLSsizecode : char;                                     //시가총액규모코드
    ismanufact : char;                                        //(유가)제조업여부
    isKrx100 : char;                                          //KRX100종목여부
    isindexissue : char;                                      //(유가)배당지수종목여부
    isstructissue : char;                                     //(유가)지배구조지수종목여부
    investcode : array[0..1] of char;                         //투자기구구분코드
    isKospi : char;                                           //(유가)KOSPI여부
    isKospi100 : char;                                        //(유가)KOSPI100여부
    isKospi50 : char;                                         //(유가)KOSPI50여부
    isKrxauto : char;                                         //KRX섹터지수자동차여부
    isKrxsemi :char;                                          //KRX섹터지수반도체여부
    isKrxbio : char;                                          //KRX섹터지수바이오여부
    isKrxfin : char;                                          //KRX섹터지수금융여부
    isKrxinfo : char;                                         //KRX섹터지수정보통신여부
    isKrxenergy : char;                                       //KRX섹터지수에너지화학여부
    isKrxsteel : char;                                        //KRX섹터지수철강여부
    isKrxproduct : char;                                      //KRX섹터지수필수소비재여부
    isKrxmedia : char;                                        //KRX섹터지수미디어통신여부
    isKrxcons : char;                                         //KRX섹터지수건설여부
    isKrxfinservice : char;                                   //KRX섹터지수금융서비스여부
    isKrxstock : char;                                        //KRX섹터지수증권여부
    isKrxvess : char;                                         //KRX섹터지수선박여부
    baseprice : array[0..8] of char;                          //기준가
    prevclosetype : char;                                     //전일종가구분코드
    prevclose : array[0..8] of char;                          //전일 종가
    prevvol : array[0..11] of char;                           //전일거래량
    prevamount : array[0..17] of char;                        //전일거래대금
    highlimit : array[0..8] of char;                          //상한가
    lowlimit : array[0..8] of char;                           //하한가
    subprice : array[0..8] of char;                           //대용가격
    facevalue : array[0..11] of char;                         //액면가
    strikeprice : array[0..8] of char;                        //발행가
    listdate : array[0..7] of char;                           //상장일
    listshares : array[0..14] of char;                        //상장주식수
    isclear : char;                                           //정리매매여부
    epssign : char;                                           //주당순이익(EPS)부호
    epsprofit : array[0..8] of char;                          //주당순이익(EPS)
    persign : char;                                           //주가수익율(PER)부호
    perprofit : array[0..5] of char;                          //주가수익율(PER)
    epstype : char;                                           //주당순이익산출제외여부
    bpssign : char;                                           //주당순자산가치(BPS)부호
    bpsvalue : array[0..8] of char;                           //주당순자산가치(BPS)
    pbrratesign : char;                                       //주당순자산비율(PBR)부호
    pbrrate : array[0..5] of char;                            //주당순자산비율(PBR)
    bpstype : char;                                           //주당순자산가치산출제외여부
    isloss : char;                                            //결손여부
    dividendprice : array[0..7] of char;                      //주당배당금액
    isdividend : char;                                        //주당배당금액산출제외여부
    dividendrate : array[0..6] of char;                       //배당수익율
    existsdate : array[0..7] of char;                         //존립개시일자
    existedate : array[0..7] of char;                         //존립종료일자
    strikesdate : array[0..7] of char;                        //행사기간개시일자
    stirkeedate : array[0..7] of char;                        //행사기간종료일자
    elwstrikeprice : array[0..11] of char;                    //ELW신주인수권증권 행사가격
    capital : array[0..20] of char;                           //자본금
    iscreditorder : array[0..4] of char;                      //신용주문가능여부
    limitcode : array[0..4] of char;                          //지정가호가조건구분코드
    marketcode : array[0..4] of char;                         //시장가호가조건구분코드
    conditionlimitcode : array[0..4] of char;                 //조건부지정가호가조건구분
    bestcode : array[0..4] of char;                           //최유리지정가호가조건구분
    firstcode : array[0..4] of char;                          //최우선지정가호가조건구분
    incapital : array[0..1] of char;                          //증자구분코드
    firststockcode : char;                                    //종류주권구분코드
    ispeople : char;                                          //국민주여부
    estimateprice : array[0..8] of char;                      //평가가격
    lowhoga : array[0..8] of char;                            //최저호가가격
    highhoga : array[0..8] of char;                           //최고호가가격
    tradeunit : array[0..4] of char;                          //정규장매매수량단위
    overtradeunit : array[0..4] of char;                      //시간외매매수량단위
    ritscode : char;                                          //리츠종류코드
    objectrigthcode : array[0..11] of char;                   //목적주권코드
    etfmarketcode : char;                                     //ETF대상지수소속시장구분
    etfupcode : array[0..2] of char;                          //ETF대상지수업종코드
    etftypecode : char;                                       //ETF구분코드
    etfissueqty : array[0..3] of char;                        //ETF구성종목수
    isocode : array[0..2] of char;                            //통화ISO코드
    nationcode : array[0..2] of char;                         //국가코드
    isLP : char;                                              //시장조성가능여부
    isovertime : char;                                        //시간외매매가능여부
    isovertimelast : char;                                    //장개시전시간외종가가능여부
    isovertimelarge : char;                                   //장개시전시간외대량매매가능
    isovertimebasket : char;                                  //장개시전시간외바스켓가능
    isestimatefill : char;                                    //예상체결가공개여부
    isshort : char;                                           //공매도가능여부
    filler : array[0..214] of char;                           //FILLER
    endtext : char;                                           //end
  end;


  /////////////////////////////ELW마스터///////////////////////////////////////
  pElwMasterpv2 = ^TElwMasterpv2;
  TElwMasterpv2 = packed record
    datatype : array[0..4] of char;                           //데이터구분(A1)
    code : array[0..11] of char;                              //표준코드
    seqno : array[0..7] of char;                              //일련번호
    elwlpkorname : array[0..79] of char;                      //ELW발행시장참가자한글명
    elwlpengname : array[0..79] of char;                      //ELW발행시장참가자영문명
    elwlpkorno : array[0..4] of char;                         //ELW발행시장참가자번호
    elwID1 : array[0..2] of char;                             //ELW구성종목시장ID1
    elwID2 : array[0..2] of char;                             //ELW구성종목시장ID2
    elwID3 : array[0..2] of char;                             //ELW구성종목시장ID3
    elwID4 : array[0..2] of char;                             //ELW구성종목시장ID4
    elwID5 : array[0..2] of char;                             //ELW구성종목시장ID5
    elwund1 : array[0..11] of char;                           //ELW기초자산
    elwund2 : array[0..11] of char;                           //ELW기초자산
    elwund3 : array[0..11] of char;                           //ELW기초자산
    elwund4 : array[0..11] of char;                           //ELW기초자산
    elwund5 : array[0..11] of char;                           //ELW기초자산
    elwundrate1 : array[0..11] of char;                       //ELW기초자산구성비
    elwundrate2 : array[0..11] of char;                       //ELW기초자산구성비
    elwundrate3 : array[0..11] of char;                       //ELW기초자산구성비
    elwundrate4 : array[0..11] of char;                       //ELW기초자산구성비
    elwundrate5 : array[0..11] of char;                       //ELW기초자산구성비
    elwundmarket : char;                                      //지수소속시장구분코드
    elwindexcode : array[0..2] of char;                       //ELW지수업종코드
    elwoptioncode : char;                                     //ELW권리유형코드 C:콜 E:기타 P:풋
    elwoptiontypecode : char;                                 //ELW권리행사유형코드
    elwsettletype : char;                                     //ELW최종결제방법코드
    elwclosingdate : array[0..7] of char;                     //ELW최종거래일
    elwpayday : array[0..7] of char;                          //ELW지급일
    elwundprice : array[0..11] of char;                       //ELW기초자산기초가격
    elwoptioncontent : array[0..199] of char;                 //ELW권리행사내용
    elwconvratio : array[0..11] of char;                      //ELW전환비율
    elwpriceup : array[0..7] of char;                         //ELW가격상승참여율
    elwindemnity : array[0..7] of char;                       //ELW보상율
    elwpayable : array[0..20] of char;                        //ELW확정지급액
    elwpayagent : array[0..79] of char;                       //ELW지급대리인
    elwestimateprice : array[0..199] of char;                 //ELW만기평가가격방식
    elwotypecode : char;                                      //ELW이색옵션구분코드
    elwlpqty : array[0..11] of char;                          //ELWLP보유수량
    filler : array[0..6] of char;                             //FILLER
    endtext : char;                                           //end text
  end;


  /////////////////////////////LP마스터///////////////////////////////////////
  pLpMasterpv2 = ^TLpMasterpv2;
  TLpMasterpv2 = packed record
    datatype : array[0..4] of char;                           //데이터구분(A1)
    code : array[0..11] of char;                              //표준코드
    seqno : array[0..7] of char;                              //일련번호
    lpno : array[0..4] of char;                               //시장참가자번호
    lpsdate : array[0..7] of char;                            //LP개시일자
    lpedate : array[0..7] of char;                            //LP종료일자
    minqty : array[0..10] of char;                            //최소호가수량배수
    maxqty : array[0..10] of char;                            //최대호가수량배수
    limitcode : char;                                         //호가스프레드단위코드
    spreadvalue : array[0..20] of char;                       //호가스프레드값
    restspreadvalue : array[0..10] of char;                   //휴장호가스프레드배수
    dutyhoga : array[0..5] of char;                           //의무호가제출시간간격
    askMin : array[0..20] of char;                            //매도최소호가금액
    bidMin : array[0..20] of char;                            //매수최소호가금액
    filler : array[0..9] of char;                             //FILLER
    endtext : char;                                           //end text
  end;

  PSettleDayMasterpv2 = ^TSettleDayMasterpv2;
  TSettleDayMasterpv2 = packed record
    datatype : array[0..4] of char;                           //데이터구분(A1)
    code : array[0..11] of char;                              //표준코드
    seqno : array[0..7] of char;                              //일련번호
    settleday : array [0..3] of char;                         // 1231, 0630, 0331
  end;



const
  LenSymbolHeader = 5;
  LenCommonHeader = sizeof( TCommonHeader );
  LenStockFutPrice  = sizeof( TStockFutPrice );
  LenStockFutTick   = sizeof( TStockFutTick );
  LenStockFutTickPrice  = sizeof( TStockFutTickPrice ) ;
  LenFutPrice = sizeof( TFutPrice );
  LenFutTick  = sizeof( TFutTick );
  LenFutTickPrice = sizeof( TFutTickPrice );
  LenOptPrice = sizeof( TOptPrice );
  LenOptTick = sizeof( TOptTick );
  LenOptTickPrice = sizeof( TOptTickPrice );
  LenStockPrice  = sizeof( TStockPrice );
  LenElwPrice = sizeof( TElwPrice );
  LenStockTick  = sizeof( TStockTick );
  LenIndex  = sizeof( TIndexData );
  LenExpectIndex = sizeof( TIndexExpectData );
  LenElwGreeks  = sizeof( TElwGreeks );
  LenCP_PPIndexData = sizeof( TCP_PPIndexData );
  LenFutOpenInterest = sizeof( TFutOpenInterest );
  LenOptOpenInterest = sizeof( TOptOpenInterest );
  LenOptRecovery     = sizeof( TOptSisRecovery );
  //
  LenOptionGreeks = sizeof( TOptionGreeks );
  LenInvestorData = sizeof( TInvestorData );
  LenInvestorDataFut = sizeof( TInvestorDataFut );
  LenDerMasterpv2  = sizeof( TDerMasterpv2 );
  LenStockMasterpv2 = sizeof( TStockMasterpv2 );
  LenElwMasterpv2  = sizeof( TElwMasterpv2 );
implementation

end.
