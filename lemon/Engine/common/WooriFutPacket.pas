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
  G002 = 'G002';    // login / logout ����
  G003 = 'G003';    // hearbeat
  G004 = 'G004';    // logout
  G100 = 'G100';    // send order
  F101 = 'F101';    // �ֹ�����
  F102 = 'F102';    // ����ó��
  W101 = 'W101';    // FEP �ź�

type

  Px5CommonHead = ^Tx5CommonHead;
  Tx5CommonHead = packed record
    soh : char;                       // 0x01
    msgid : array [0..3] of char;     // ����
    uid   : array [0..3] of char;     // ����
    cid   : char;                     // 'A'~'Z'  , ȯ�溯��
    kind  : array [0..3] of char;     // ����
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
    rcode : array [0..2] of char; // 000 : ����,  801 : id or pw , 802 : account, 803 : id
  end;

  Px5LogOut = ^Tx5LogOut;
  Tx5LogOut = packed record
    Head  :  Tx5CommonHead;
    uid   : array [0..3] of char;
  end;

  Px5LogOutRes = ^Tx5LogOutRes;
  Tx5LogOutRes = packed record
    //Head  :  Tx5CommonHead;
    rcode   : array [0..2] of char;   // 000 : ����   803 : fail
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
    localNo   : array [0..4] of char; // �����ϰ� ��밡���� ����
    filler2   : array [0..30] of char;
  end;
  }

  PMemberArea = ^TMemberArea;
  TMemberArea = record
    filler1   : array [0..39] of char;
    filler2   : array [0..19] of char;  // ��밡���� 20bytes
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

  Px5OrderReject = ^Tx5OrderReject;
  Tx5OrderReject = packed record
    OrderID : array [0..9] of char;
    ResCode : array [0..3] of char;
    ResTime : array [0..8] of char;
  end;


  // �ֹ� ��Ŷ
  Px5OrderPacket = ^Tx5OrderPacket;
  Tx5OrderPacket = packed record
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

  Px5FillPacket = ^Tx5FillPacket;
  Tx5FillPacket = packed record
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

  Px5ConfirmPacket = ^Tx5ConfirmPacket;
  Tx5ConfirmPacket = packed record
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


  Px5DataPacket = ^Tx5DataPacket;
  Tx5DataPacket = packed record
    Header        : Tx5CommonHead;
    OrderPacket   : Tx5OrderPacket;
  end;

  // �ŷ��� ���� ��Ŷ
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