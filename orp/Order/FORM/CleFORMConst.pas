unit CleFORMConst;

interface

type

  TDataType = ( dtOrdCancel, dtOrdPosCancel, dtTotalCancel, dtVolStop);

  TFORMParam  = record

    BasisH  : double;
    BasisL  : double;
    BasisA  : double;

    ExUpDown  : double;
    ExUpDownP : double;
    ExIndex   : double;

    BasePrice : double;
    IndexPrice: double;

    AskPrice  : double;
    BidPrice  : double;

    OrderQty  : integer;
    OrderGap  : integer;
    OrderCnt  : integer;
    BidShift  : double;
    AskShift  : double;

    Upper : double;
    Lower : double;
    Delay : double;

    AskShift2 : double;
    BidShift2 : double;

    CancelTime  : TDateTime;
    StartTime   : TDateTime;

    OldVer     : boolean;
    Asks, Bids : integer;
    AskPos, BidPos     : integer;

    Cnt : integer;
    Interval : integer;
    DataType : TDataType;
    StartStop : integer;
  end;

implementation

end.
