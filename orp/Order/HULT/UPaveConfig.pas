unit UPaveConfig;

interface

uses
  SysUtils, CleAccounts
  ;

const
  RETRY_CNT = 60;
  Tot_Cnt = 3;

type

  TSAREvent = procedure( Sender : TObject; Value : integer ) of Object;
  TZPDTState = ( zsNone, zsOrder, zsPosOK, zsReEntryReady, zsReEntry );

  TPaveData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�����
    AskHoga : integer;      // ����ȣ��
    BidHoga : integer;      // ����ȣ��
    Profit  : integer;
    UseAutoLiquid : boolean;
    LiquidTime : TDateTime;
    // add by 20140425
    MaxNet  : integer;
    LCNet   : integer;
    LiqOTE  : integer;
  end;

  THultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    QuotingQty : integer;
    UseBetween : boolean;
    SPos : integer;         //���̻��� ���� ���� �����Ǽ���
    EPos : integer;         //���̻��� ���� ���� �����Ǽ���
    STick : integer;
    UsePause : boolean;
    StartTime : TDateTime;
  end;

  THultCompData = record
    OrdQty : integer;
    Period : integer;
    AFValue: double;
    Tick   : integer;
    UseLsCut : boolean;
    UseTime  : boolean;
    DivVal   : integer;
  end;

  TPrevHLParam = record
    Qty : integer;
    LossCutTick : integer;
    StartTime, EndTime : TDateTime;
    EntrySec : integer;
    LiqSec   : integer;
    Period   : integer;
    MoveTick : integer;
    ProfitTick : integer;
    function  GetDesc : string;
  end;


  THultOptData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    QuotingQty : integer;
    OptPrice : double;
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    RiskAmt : double;
    LiquidTime    : TDateTime;
    CallPut : integer;
  end;

  TBHultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�ȸ��
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    ClearPos : integer;
    // only ex use
    TargetPos : integer;
    AfValue   : double;
  end;

  TJarvisData = record
    // �⺻
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OrdCnt  : integer;      // �ֹ�ȸ��

    // �ڵ�û��
    UseAutoLiquid : boolean;
    UseAutoStop   : boolean;
    UseParaLiquid : boolean;
    PLCount , LCCount : integer;
    PLTick : array [0..2] of integer;
    LCTick : array [0..2] of integer;

    // ����
    UsePara , UseForFutQty, UseHultPos : boolean;
    ParaSymbol, ForFutQty : integer;
    AfValue    : double;
    TargetTick, TargetPos : integer;
    //
    StartTime, EndTime : TDateTime;
  end;

  TBHultOptData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    OptPrice : double;
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    Band : double;
    Term : integer;
    StartTime : TDateTime;
    HultAccount : TAccount;
    HultPL : double;
    AddEntry : double;
    AddEntryCnt : integer;
    QtyDiv : integer;
    HultGap : integer;
    HultCalS : boolean;
  end;

  TZombiPDT = record
    Below, Above : double;

    FstStartTime : TDateTime;
    FstLiquidTime: TDateTime;

    OrdReCount : integer;  // �ֹ� ȸ��
    AscIdx : integer; // 0 : ��������  , 1 : ��������

    EntryAmt : string;
    dEntryAmt: double;
    InitQty: integer;
    AddQty : integer;
    RiskAmt : double;
    DecAmt  : double;
    MarginAmt : double;
    PLAmt     : double;
    PLAbove   : double;
    LiqPer  : integer;

    ToVal : array of double;
    FromVal : array of double;
    EntVal : array of double;
    Ordered: array of boolean;
    TermCnt : integer;

    UseTargetQty : boolean;
    UseTerm      : boolean;
    UseFut       : boolean;
    UseOptSell   : boolean;
    UseVer2      : boolean;
    UseVer2R     : boolean;

    EntryMode     : integer;
    UseFixPL      : boolean;
    //

  end;

  TShortHultData = record
    OrdQty  : integer;      // �ֹ�����
    OrdGap  : integer;      // �ֹ�����
    UseAllCnlNStop : boolean;
    UseAutoLiquid : boolean;
    LiquidTime    : TDateTime;
    RiskAmt : double;
    ProfitAmt : double;
    QtyLimit  : integer;
    ClearPos : integer;
    UseAPI : boolean;
    SPoint : double;
  end;


implementation

{ TPrevHLParam }

function TPrevHLParam.GetDesc: string;
begin
  Result := Format( 'Qty:%d, EntrySec:%d, LiqSec:%d, LossTick:%d, Cnt:%d, Period:%d ',
    [ Qty, EntrySec, LiqSec, LossCutTick, MoveTick, Period ]);
end;

end.