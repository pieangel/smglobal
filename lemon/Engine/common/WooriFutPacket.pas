unit WooriFutPacket;

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

  G001 = 'G001';    // login
  G002 = 'G002';    // login / logout 응답
  G003 = 'G003';    // hearbeat
  G004 = 'G004';    // logout
  G100 = 'G100';    // send order
  F101 = 'F101';    // 주문응답
  F102 = 'F102';    // 정상처리
  W101 = 'W101';    // FEP 거부

type

  Px5CommonHead = ^Tx5CommonHead;
  Tx5CommonHead = packed record
    soh : char;                       // 0x01
    msgid : array [0..3] of char;     // 고정
    uid   : array [0..3] of char;     // 고정
    cid   : char;                     // 'A'~'Z'  , 환경변수
    kind  : array [0..3] of char;     // 변수
    seq   : array [0..6] of char;     // space
    enc   : char;                     // 0
    time  : array [0..9] of char;
    dataCnt : char;
    dataSz  : array [0..2] of char;
  end;

  // login G001
  Px5Login = ^ Tx5Login;
  Tx5Login = packed record
    Head  :  Tx5CommonHead;
    sysid : array [0..7] of char;
    syspw : array [0..31] of char;
    acctno  : array [0..5] of char;
    acctpw  : array [0..31] of char;
    uid     : array [0..3] of char;
  end;

  Px5LoginRes = ^ Tx5LoginRes;
  Tx5LoginRes = packed record
    //Head  :  Tx5CommonHead;
    rcode : array [0..2] of char; // 000 : 성공,  801 : id or pw , 802 : account, 803 : id
  end;

  Px5LogOut = ^Tx5LogOut;
  Tx5LogOut = packed record
    Head  :  Tx5CommonHead;
    uid   : array [0..3] of char;
  end;

  Px5LogOutRes = ^Tx5LogOutRes;
  Tx5LogOutRes = packed record
    //Head  :  Tx5CommonHead;
    rcode   : array [0..2] of char;   // 000 : 성공   803 : fail
  end;

  Px5Heartbeat = ^ Tx5Heartbeat;
  Tx5Heartbeat = packed record
    Head  :  Tx5CommonHead;
    hBeat : char;                 // '*'
  end;

  {
  PMemberArea = ^TMemberArea;
  TMemberArea = record
    media_gb  : array [0..1] of char;
    market_gb : char;
    accnt_gb  : char;
    deposit   : char;
    cncl_gb   : char;
    filler1   : array [0..15] of char;
    tops_bg   : array [0..1] of char;
    localNo   : array [0..4] of char; // 유일하게 사용가능한 공간
    filler2   : array [0..30] of char;
  end;
  }

  PMemberArea = ^TMemberArea;
  TMemberArea = record
    filler1   : array [0..39] of char;
    filler2   : array [0..19] of char;  // 사용가능한 20bytes
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

  Px5OrderReject = ^Tx5OrderReject;
  Tx5OrderReject = packed record
    OrderID : array [0..9] of char;
    ResCode : array [0..3] of char;
    ResTime : array [0..8] of char;
  end;


  // 주문 패킷
  Px5OrderPacket = ^Tx5OrderPacket;
  Tx5OrderPacket = packed record
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

  Px5FillPacket = ^Tx5FillPacket;
  Tx5FillPacket = packed record
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

  Px5ConfirmPacket = ^Tx5ConfirmPacket;
  Tx5ConfirmPacket = packed record
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


  Px5DataPacket = ^Tx5DataPacket;
  Tx5DataPacket = packed record
    Header        : Tx5CommonHead;
    OrderPacket   : Tx5OrderPacket;
  end;

  // 거래소 접수 패킷
  Unx5Packet = packed record
    case Integer of
      0: ( x5Ack         :       Tx5OrderPacket; );
      1: ( x5Confirm     :       Tx5ConfirmPacket; );
      2: ( x5Fill        :       Tx5FillPacket; );
      3: ( x5Login       :       Tx5LoginRes; );
      4: ( x5LogOut      :       Tx5LogOutRes; );
      5: ( xReject       :       Tx5OrderReject; );
  end;

  ///  x5 order data
  Px5ReceptPacket = ^Tx5ReceptPacket;
  Tx5ReceptPacket = packed record
    x5Head        : Tx5CommonHead;
    x5UnionPak    : Unx5Packet;
  end;


const
  Len_x5CommonHead = sizeof( Tx5CommonHead ) ; // 36 bytes
  Len_x5Login = sizeof( Tx5Login ) ; // 82 bytes
  Len_x5LogOut = sizeof( Tx5LogOut ) ; // 82 bytes
  Len_x5LoginRes = sizeof( Tx5LoginRes ) ; // 3 bytes

  Len_x5DataPacket  = sizeof( Tx5DataPacket );
  Len_x5OrderPacket = sizeof(  Tx5OrderPacket ); //  261
  Len_x5FillPacket = sizeof( Tx5FillPacket );
  Len_x5ConfirmPacket = sizeof( Tx5ConfirmPacket );


implementation

end.
