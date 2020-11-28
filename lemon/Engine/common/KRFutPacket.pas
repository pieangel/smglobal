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
    Length  : array [0..3] of char;     // ����
    ApType  : array [0..5] of char;     // ����
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
    crtid     : array [0..5] of char;   // �ֹ��ܸ� ID
    jmno1     : array [0..9] of char;   // �ֹ���ȣ
    wjmno     : array [0..9] of char;   // ���ֹ� ��ȣ
    virAcntNo : array [0..1] of char;   // ������¹�ȣ
    filler    : array [0..25] of char;
    pid       : array [0..4] of char;   // FEP Port
    trgb      : char;     // APTYPE
  end;

  PCommonData  = ^TCommonData;
  TCommonData = packed record
    hseq        : array [0..10] of char;
    trans_code  : array [0..10] of char;
    board_id    : array [0..1] of char;
    memberno    : array [0..4] of char;           // ȸ����ȣ
    bpno        : array [0..4] of char;           // ������ȣ
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


  // �ֹ� ��Ŷ
  PKrOrderPacket = ^TKrOrderPacket;
  TKrOrderPacket = packed record
    CommonData    : TCommonData;

    mmgubun : char;                               // �ŵ� : 1,  �ż� : 2
    hogagb  : char;                               // �ű� : 1,  ���� : 2,  ��� : 3
    gyejwa  : array [0..11] of char;              // ���¹�ȣ
    cnt     : array [0..9] of char;               // ȣ������
    price   : array [0..10] of char;              // ȣ������
    ord_type  : char;                             // ���尡 : 1, ������ : 2, ���Ǻ� : I, ������ : X, �ֿ켱 : Y( ������ )
    ord_cond  : char;                             // �Ϲ�(FASS) : 0, IOC(FAK) : 3, FOK : 4
    market_ord_num  : array [0..10] of char;      // �Ϲ� : 0
    stock_state_id  : array [0..4] of char;       // �ڻ��ֽŰ��� ID - �ش���� : 0
    stock_trade_code: char;                       // �ڻ��ָŸŹ���ڵ� - �ش���� : 0
    medo_type_code  : array [0..1] of char;       // �ŵ������ڵ� - �ش���� : 00
    singb : array [0..1] of char;                 // �ſ뱸�� - �����Ϲ� : 10
    witak : array [0..1] of char;                 // ��Ź�ڱⱸ�� - ��Ź�Ϲ� : 11,  ��Ź�ּ� : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT���� - �Ϲ� : 00, ���� : 10, ���� : 20
    sub_stock_gyejwa  : array [0..11] of char;    // ����ֱǰ��¹�ȣ

    gyejwa_type_code  : array [0..1] of char;     // ���±����ڵ� - ��Ź�Ϲ� : 31, �ڱ��Ϲ� : 41
    gyejwa_margin_cod : array [0..1] of char;     // �������ű������ڵ� - �������ű� : 11,
    kukga : array  [0..2] of char;                // �����ڵ�
    tocode : array [0..3] of char;                // �����ڱ��� - ����ȸ�� �� ���� : 1000
    foreign: array [0..1] of char;                // �ܱ��� �����ڱ����ڵ� - 00

    meache_bg : char;                             // �ֹ���ü�����ڵ� -
    term_no : array [0..11] of char;              // �ֹ��ڽĺ�����
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // ȸ����
    pgm_gongsi_gb : char;
  end;

  PKrFillPacket = ^TKrFillPacket;
  TKrFillPacket = packed record
    CommonData    : TCommonData2;

    che_no      : array [0..10] of char;          // ü���ȣ
    che_price   : array [0..10] of char;          // ü�ᰡ��
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

    mmgubun     : char;                           // �ŵ� : 1, �ż� : 2
    hogagb      : char;                           // �ű� : 1, ���� : 2, ��� : 3;
    gyejwa      : array [0..11] of char;
    cnt         : array [0..9] of char;
    price       : array [0..10] of char;
    ord_type    : char;
    ord_cond    : char;
    market_ord_num  : array [0..10] of char;

    stock_state_id  : array [0..4] of char;       // �ڻ��ֽŰ��� ID - �ش���� : 0
    stock_trade_code: char;                       // �ڻ��ָŸŹ���ڵ� - �ش���� : 0
    medo_type_code  : array [0..1] of char;       // �ŵ������ڵ� - �ش���� : 00
    singb : array [0..1] of char;                 // �ſ뱸�� - �����Ϲ� : 10
    witak : array [0..1] of char;                 // ��Ź�ڱⱸ�� - ��Ź�Ϲ� : 11,  ��Ź�ּ� : 12
    witakcomp_num : array [0..4] of char;         // space

    pt_type_code  : array [0..1] of char;         // PT���� - �Ϲ� : 00, ���� : 10, ���� : 20
    sub_stock_gyejwa  : array [0..11] of char;    // ����ֱǰ��¹�ȣ

    gyejwa_type_code  : array [0..1] of char;     // ���±����ڵ� - ��Ź�Ϲ� : 31, �ڱ��Ϲ� : 41
    gyejwa_margin_cod : array [0..1] of char;     // �������ű������ڵ� - �������ű� : 11,
    kukga : array  [0..2] of char;                // �����ڵ�
    tocode : array [0..3] of char;                // �����ڱ��� - ����ȸ�� �� ���� : 1000
    foreign: array [0..1] of char;                // �ܱ��� �����ڱ����ڵ� - 00

    meache_bg : char;                             // �ֹ���ü�����ڵ� -
    term_no : array [0..11] of char;              // �ֹ��ڽĺ�����
    mac_addr  : array [0..11] of char;            // MAC Addr
    ord_date  : array [0..7] of char;
    ord_time  : array [0..8] of char;

    hoiwon  : TMemberArea;              // ȸ����
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
  // �ŷ��� ���� ��Ŷ
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