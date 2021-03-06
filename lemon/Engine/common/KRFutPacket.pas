unit KRFutPacket;

interface

const
  DATA_LENGTH  = 256;
  LENGTH_SIZE  = 4;

  NewHoga = 'TCHODR10001';
  CnlHoga = 'TCHODR10003';
  ModHoga = 'TCHODR10002';
  //
  ConfNormal  = 'TTRODP11301';
  ConfReject  = 'TTRODP11321';
  AutoCancel  = 'TTRODP11303';
  //
  OrderFill   = 'TTRTDP21301';

  preType : array [0..2] of string = ( 'A11', 'A12', 'A14');
  sufType : array [0..2] of string = ( 'TR', 'TS', 'TS');

type

  PKrCommonHead = ^TKrCommonHead;
  TKrCommonHead = packed record
    Stx     : char;                       // 0x02
    Length  : array [0..3] of char;     // 고정
    ApType  : array [0..5] of char;     // 고정
    Date    : array [0..7] of char;
    time    : array [0..8] of char;
    ResCode : array [0..3] of char;
    seq     : array [0..7] of char;     // space
    DataCnt : array [0..1] of char;                     // 0
    Filler  : array [0..17] of char;
  end;


  PKrxHead = ^TKrxHead;
  TKrxHead = packed record
    filler  : array [0..81] of char;
  end;

  PMemberArea = ^TMemberArea;
  TMemberArea = record
    crtid     : array [0..5] of char;   // 주문단말 ID
    jmno1     : array [0..9] of char;   // 주문번호
    wjmno     : array [0..9] of char;   // 원주문 번호
    virAcntNo : array [0..1] of char;   // 가상계좌번호
    filler    : array [0..25] of char;
    pid       : array [0..4] of char;   // FEP Port
    trgb      : char;     // APTYPE
  end;

  PCommonData  = ^TCommonData;
  TCommonData = packed record
    hseq        : array [0..10] of char;
    trans_code  : array [0..10] of char;
    board_id    : array [0..1] of char;
    memberno    : array [0..4] of char;           // 회원번호
    bpno        : array [0..4] of char;           // 지점번호
    ordno : array [0..9] of char;                 // space
    orgordno  : array [0..9] of  char;
    code  : array [0..11] of char;
  end;

  PCommonData2  = ^TCommonData2;
  TCommonData2 = packed record
    hseq        : array [0..10] of char;
    trans_code  : array [0..10] of char;
    me_grp_no   : array [0..1] of char;
    board_id    : array [0..1] of char;
    memberno    : array [0..4] of char;           // 00017
    bpno        : array [0..4] of char;           // space
    ordno : array [0..9] of char;                 // space
    orgordno  : array [0..9] of  char;
    code  : array [0..11] of char;
  end;


  // 주문 패킷
  PKrOrderPacket = ^TKrOrderPacket;
  TKrOrderPacket = packed record
    CommonData    : TCommonData;

    mmgubun : char;                               // 매도 : 1,  매수 : 2
    hogagb  : char;                               // 신규 : 1,  정정 : 2,  취소 : 3
    gyejwa  : array [0..11] of char;              // 계좌번호
    cnt     : array [0..9] of char;               // 호가수량
    price   : array [0..10] of char;              // 호가가격
    ord_type  : char;                             // 시장가 : 1, 지정가 : 2, 조건부 : I, 최유리 : X, 최우선 : Y( 현물만 )
    ord_cond  : char;                             // 일반(FASS) : 0, IOC(FAK) : 3, FOK : 4
    market_ord_num  : array [0..10] of char;      // 일반 : 0
    stock_state_id  : array [0..4] of char;       // 자사주신고서 ID - 해당없음 : 0
    stock_trade_code: char;                       // 자사주매매방법코드 - 해당없음 : 0
    medo_type_code  : array [0..1] of char;       // 매도유형코드 - 해당없음 : 00
    singb : array [0..1] of char;                 // 신용구분 - 보통일반 : 10
    witak : array [0..1] of char;                 // 위탁자기구분 - 위탁일반 : 11,  위탁주선 : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT구분 - 일반 : 00, 차익 : 10, 헤지 : 20
    sub_stock_gyejwa  : array [0..11] of char;    // 대용주권계좌번호

    gyejwa_type_code  : array [0..1] of char;     // 계좌구분코드 - 위탁일반 : 31, 자기일반 : 41
    gyejwa_margin_cod : array [0..1] of char;     // 계좌증거금유형코드 - 사후증거금 : 11,
    kukga : array  [0..2] of char;                // 국가코드
    tocode : array [0..3] of char;                // 투자자구분 - 증권회사 및 선물 : 1000
    foreign: array [0..1] of char;                // 외국인 투자자구분코드 - 00

    meache_bg : char;                             // 주문매체구분코드 -
    term_no : array [0..11] of char;              // 주문자식별정보
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // 회원사
    pgm_gongsi_gb : char;
  end;

  PKrFillPacket = ^TKrFillPacket;
  TKrFillPacket = packed record
    CommonData    : TCommonData2;

    che_no      : array [0..10] of char;          // 체결번호
    che_price   : array [0..10] of char;          // 체결가격
    che_qty     : array [0..9] of char;
    session_id  : array [0..1] of char;

    che_date    : array [0..7] of char;
    che_time    : array [0..8] of char;
    pyakprice   : array [0..10] of char;
    nyakprice   : array [0..10] of char;

    mmgubun     : char;
    gyejwa      : array [0..11] of char;
    market_ord_num  : array [0..10] of char;
    witakcomp_num   : array [0..4] of char;
    sub_stock_gyejwa  : array [0..11] of char;
    hoiwon  : TMemberArea;
  end;

  PKrConfirmPacket = ^TKrConfirmPacket;
  TKrConfirmPacket = packed record
    CommonData    : TCommonData2;

    mmgubun     : char;                           // 매도 : 1, 매수 : 2
    hogagb      : char;                           // 신규 : 1, 정정 : 2, 취소 : 3;
    gyejwa      : array [0..11] of char;
    cnt         : array [0..9] of char;
    price       : array [0..10] of char;
    ord_type    : char;
    ord_cond    : char;
    market_ord_num  : array [0..10] of char;

    stock_state_id  : array [0..4] of char;       // 자사주신고서 ID - 해당없음 : 0
    stock_trade_code: char;                       // 자사주매매방법코드 - 해당없음 : 0
    medo_type_code  : array [0..1] of char;       // 매도유형코드 - 해당없음 : 00
    singb : array [0..1] of char;                 // 신용구분 - 보통일반 : 10
    witak : array [0..1] of char;                 // 위탁자기구분 - 위탁일반 : 11,  위탁주선 : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT구분 - 일반 : 00, 차익 : 10, 헤지 : 20
    sub_stock_gyejwa  : array [0..11] of char;    // 대용주권계좌번호

    gyejwa_type_code  : array [0..1] of char;     // 계좌구분코드 - 위탁일반 : 31, 자기일반 : 41
    gyejwa_margin_cod : array [0..1] of char;     // 계좌증거금유형코드 - 사후증거금 : 11,
    kukga : array  [0..2] of char;                // 국가코드
    tocode : array [0..3] of char;                // 투자자구분 - 증권회사 및 선물 : 1000
    foreign: array [0..1] of char;                // 외국인 투자자구분코드 - 00

    meache_bg : char;                             // 주문매체구분코드 -
    term_no : array [0..11] of char;              // 주문자식별정보
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // 회원사
    acpt_time : array [0..8] of char;
    jungcnt   : array [0..9] of char;
    auto_cancel_type  : char;
    rejcode   : array [0..3] of char;
    pgm_gongsi_gb : char;
  //  pgm_gongsi_gb : char;
  end;     

  PKrDataPacket = ^TKrDataPacket;
  TKrDataPacket = packed record
    KrFepHead     : TKrCommonHead;
    KrxHead       : TKrxHead;
    OrderPacket   : TKrOrderPacket;
  end;
      {
  TKrAckPacket = packed record
    RejectCode  : array [0..3] of char;
    FepSeq      : array [0..10] of char;
    Time        : array [0..8] of char;
    KrAck : TKrOrderPacket;
  end;

  }
  // 거래소 접수 패킷
  UnKrPacket = packed record
    case Integer of
      0: ( KrAck         :       TKrOrderPacket; );
      1: ( KrConfirm     :       TKrConfirmPacket; );
      2: ( KrFill        :       TKrFillPacket; );
  end;

  ///  x5 order data
  PKrReceptPacket = ^TKrReceptPacket;
  TKrReceptPacket = packed record
    KrFepHead     : TKrCommonHead;
    KrxHead       : TKrxHead;
    KrUnionPak    : UnKrPacket;
  end;

const
  Len_KrCommonHead  = sizeof( TKrCommonHead ) ; // 36 bytes
  Len_KrxHead       = sizeof( TKrxHead );

  Len_KrDataPacket  = sizeof( TKrDataPacket );
  Len_Kr5OrderPacket = sizeof(  TKrOrderPacket ); //  261
  Len_KrFillPacket  = sizeof( TKrFillPacket );

  Len_KrConfirmPacket = sizeof( TKrConfirmPacket );


implementation

end.
