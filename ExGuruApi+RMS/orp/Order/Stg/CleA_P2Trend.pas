unit CleA_P2Trend;
interface

uses
  Classes, SysUtils, DateUtils,

  CleSymbols, CleAccounts, CleFunds, CleOrders, ClePositions, CleQuoteBroker, Ticks,

  CleDistributor,

  GleTypes
  ;

type

  TA50_P2Param = record
    OrdQty  : integer;
    TermCnt : integer;
    ATRMulti: integer;
    E_1 : double;
    L_1, L_2 : double;
    Period : integer;
    CalcCnt: integer;
    StartTime , Endtime : TDateTime;
    EntTime   , EntEndtime : TDateTime;
    ReEntTime   , ReEntEndtime : TDateTime;
    ATRLiqTime  : TDateTime;
    MkStartTime : TDateTime;
    //
    GoalP : integer;
  end;

  TA50_P2_Trend = class
  private
    FSymbol: TSymbol;
    FParam: TA50_P2Param;
    FIsFund: boolean;
    FRun: boolean;
    FFund: TFund;
    FAccount: TAccount;
    FQuote: TQuote;
    FOrders: TOrderList;
    FStarted: boolean;
    FStartOpen: double;
    FOrdSide: integer;
    FCalcedATR: boolean;
    FATR: double;

    FTermCnt: integer;

    FHL: double;        // ����

    FLossCut: boolean;
    FEntryPrice: double;
    FEntLow: double;
    FEntHigh: double;
    FEntTermCnt: integer;

    FParent: TObject;
    FDayOpen: double;


    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure OnQuote(aQuote: TQuote);
    procedure Reset( bTr : boolean = true );

    procedure DoLossCut(aQuote: TQuote); overload;
    procedure DoLossCut; overload;
    procedure DoOrder( aQuote : TQuote; iDir : integer ); overload;
    procedure DoOrder( aQuote : TQuote; aAccount : TAccount; iQty: integer; bLiq : boolean = false ); overload;

    function IsRun: boolean;
    function CheckOrder(aQuote: TQuote): integer;
    function CheckLossCut(aQuote: TQuote): boolean;
    function CheckLiquid(aQuote: TQuote): boolean;

    function GetPL: double;


  public

    OrderCnt  : integer;
    OrderedDir: array [0..4] of integer;

    Constructor Create( aObj : TObject );
    Destructor  Destroy; override;

    procedure DoLiquid; overload;
    procedure DoOrder;  overload;
    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean; overload;
    function init( aFund : TFund; aSymbol : TSymbol ) : boolean; overload;
    procedure CalcHL;
    procedure DoLog( stLog : string );

    property Param : TA50_P2Param read FParam write FParam;
    property Run   : boolean read FRun;
    property IsFund: boolean read FIsFund;

    property Symbol  : TSymbol read FSymbol;  // �ֱٿ���..
    property Quote   : TQuote  read FQuote;   // �ü�
    property Account : TAccount read FAccount;
    property Fund : TFund read FFund;

    property Orders : TOrderList  read FOrders;
    property Parent : TObject read FParent;
    property PL     : double read GetPL;
    // ���� ����
    property CalcedATR : boolean read FCalcedATR; // ���ŵ����͸� ���� TR ��� �ߴ���
    property Started : boolean read FStarted;     // ���۽� ���� ����� ����
    property OrdSide   : integer read FOrdSide;
    property LossCut  : boolean read FLossCut;    // ��������..

    // Value ����
    property ATR  : double read FATR;

    property TermCnt : integer read FTermCnt;
    property StartOpen : double read FStartOpen;  // ���彺ŸƮ �ð� �ð�..
    property DayOpen   : double read FDayOpen;      // ���� �ð� �ð�..( kr �� 01:00)
    property EntryPrice: double read FEntryPrice; // ���԰���
    property EntHigh : double read FEntHigh;      // �������� ����
    property EntLow  : double read FEntLow;       // �������� ����
    property EntTermCnt : integer read FEntTermCnt; // ���� ���� �� ����..
    //

    property HL : double read FHL;    // ���� ������


  end;

implementation

uses
  GAppEnv, GleLib, GleConsts, CleKrxSymbols,

  Math ,

  FA_P2

  ;

{ TA50Trend }

procedure TA50_P2_Trend.Reset( bTr : boolean );
begin
  FCalcedATR  := false;
  FStarted := false;
  //FStartOpen  := 0;
  FOrdSide    := 0;
  FTermCnt    := 0;
  FATr        := 0;
  FEntryPrice := 0;
  FLossCut    := false;
  FEntTermCnt := 0;
  FEntLow   := 0;
  FEntHigh  := 0;

  Orders.Clear;

end;



constructor TA50_P2_Trend.Create( aObj : TObject );
var
  I: Integer;
begin
  FSymbol:= nil;
  FRun:= false;
  FFund:= nil;
  FAccount:= nil;
  FQuote:= nil;

  FOrders := TOrderList.Create;

  FParent := aObj;
  OrderCnt:= 0;

  for I := 0 to High(OrderedDir) do
    OrderedDir[i] := 0;
end;

destructor TA50_P2_Trend.Destroy;
begin

  FOrders.Free;
  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
  inherited;
end;

procedure TA50_P2_Trend.DoLiquid;
begin
  DoLossCut;
  Reset;
end;

procedure TA50_P2_Trend.DoLog(stLog: string);
begin
  if ( FIsFund ) and ( FFund <> nil ) then
    gEnv.EnvLog( WIN_TREND, stLog, false, FFund.Name);

  if ( not FIsFund ) and ( FAccount <> nil ) then
    gEnv.EnvLog( WIN_TREND, stLog, false, Account.Code);
end;

procedure TA50_P2_Trend.DoLossCut;
var
  aPos : TPosition;
  aOrd : TOrder;
  I: Integer;
  aQuote : TQuote;
begin

  if ( FSymbol = nil ) or ( FSymbol.Quote = nil ) then Exit;

  aQuote  := FSymbol.Quote as TQuote;      

  for I := Orders.Count - 1 downto 0 do
  begin
    aOrd  := Orders.Orders[i];
    if (aOrd.Side = FOrdSide ) and ( aOrd.State = osFilled ) then
      DoOrder( aQuote , aOrd.Account, aOrd.FilledQty, true );

    Orders.Delete(i);
  end;

  FLossCut := true;
  DoLog( 'Stop û�� �Ϸ�'  );
end;

procedure TA50_P2_Trend.DoLossCut( aQuote : TQuote );
var
  //aPos : TPosition;
  aOrd : TOrder;
  I: Integer;
begin

  for I := Orders.Count - 1 downto 0 do
  begin
    aOrd  := Orders.Orders[i];
    if (aOrd.Side = FOrdSide ) and ( aOrd.State = osFilled ) then
      DoOrder( aQuote , aOrd.Account, aOrd.FilledQty, true );

    Orders.Delete(i);
  end;

  FLossCut := true;
  DoLog( 'û�� �Ϸ�  ����' );
  Reset( false );
  FStarted := true;
end;

procedure TA50_P2_Trend.DoOrder(aQuote: TQuote; aAccount: TAccount; iQty: integer; bLiq: boolean);
var
  dPrice : double;
  stTxt  : string;
  aTicket: TOrderTicket;
  aOrder : TOrder;
  iSide  : integer;
begin
  if ( aAccount = nil ) then Exit;

  if bLiq then
  begin
    // û���
    iSide := -FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 );
  end else
  begin
    // �ű�
    iSide :=  FOrdSide;
    if FOrdSide > 0 then
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
    else
      dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );
  end;

  if ( dPrice < EPSILON ) or ( iQty < 0 ) then
  begin
    DoLog( Format(' �ֹ� ���� �̻� : %s, %s, %d, %.2f ',  [ aAccount.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    aAccount, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send(aTicket);
    Orders.Add( aOrder );
    if FIsFund  then aOrder.FundName := FFund.Name;
    DoLog( Format('%s Send Order : %s, %s, %s, %.*n, %d', [
        ifThenStr( bLiq, 'û��', '�ű�' ),
        aAccount.Code, aQuote.Symbol.ShortCode, ifThenStr( iSide > 0, '�ż�','�ŵ�'),
        aQuote.Symbol.Spec.Precision, dPrice, iQty
      ]));
  end;
end;

function TA50_P2_Trend.GetPL: double;
var
  I: Integer;
  aPos : TPosition;
  aItem: TFundItem;
begin
  Result := 0;
  if FIsFund then
  begin
    if FFund = nil then Exit;

    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aITem := FFund.FundItems.FundItem[i];
      aPos  := gEnv.Engine.TradeCore.Positions.Find( aItem.Account, FSymbol );
      if aPos <> nil then
        Result:= Result + aPos.LastPL;
    end;
  end else
  begin
    if FAccount = nil then Exit;

    aPos := gEnv.Engine.TradeCore.Positions.Find( FAccount, FSymbol );
    if aPos <> nil then
      Result := aPos.LastPL;
  end;
end;

procedure TA50_P2_Trend.DoOrder(aQuote : TQuote; iDir: integer);
var
  iQty, I: Integer;
  aAccount : TAccount;
  aItem : TFundItem;
begin
  FOrdSide := iDir;
  iQty     := FParam.OrdQty;
  if FIsFund then
  begin
    for I := 0 to FFund.FundItems.Count - 1 do
    begin
      aItem := FFund.FundItems.FundItem[i];
      DoOrder( aQuote, aItem.Account, iQty * aItem.Multiple );
    end;
  end else
  begin
    DoOrder( aQuote, FAccount, iQty );
  end;

  inc( Ordercnt );

end;

procedure TA50_P2_Trend.DoOrder;
begin
  DoOrder( FSymbol.Quote as TQuote, 1 );
  FStarted  := true;
  FStartOpen:= FSymbol.Last;
  FEntryPrice := FSymbol.Last;
end;

function TA50_P2_Trend.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  FIsFund := false;
  FAccount:= aAcnt;
  FSymbol := aSymbol;
  FFund   := nil;
  OrderCnt:= 0;
  Reset;
end;

function TA50_P2_Trend.init(aFund: TFund; aSymbol: TSymbol): boolean;
begin
  FIsFund := true;
  FAccount:= nil;
  FSymbol := aSymbol;
  FFund   := aFund;
  OrderCnt:= 0;
  Reset;
end;

function TA50_P2_Trend.IsRun : boolean;
begin
  if ( not Run)
    or (( FIsFund ) and ( Fund = nil ))
    or (( not FIsFund ) and ( Account = nil ))
    or ( FSymbol = nil ) then
    Result := false
  else
    Result := true;
end;

function TA50_P2_Trend.Start: boolean;
var
  iAdd : integer;
begin
  FRun := false;
  if (( FIsFund ) and ( Symbol <> nil ) and ( Fund <> nil ))
    or
    (( not FIsFund ) and ( Symbol <> nil ) and ( Account <> nil )) then
  begin
    FRun := true;
    DoLog( Format('A50_P2 Trend Start %s ', [Symbol.Code ]) );
  end else Exit;

  Result := FRun;

  FQuote  := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, CHART_DATA, QuotePrc );
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc);

  // api ��Ʈ ����Ÿ ��û

  if FQuote <> nil then
  begin
    if  not FQuote.MakeTerm  then
    begin
      if not FQuote.CalcedPrevHL then
      begin
        if  Frac(now) <  Frac( FParam.MkStartTime) then
          iAdd := 0
        else
          iAdd  := HoursBetween( Frac(now) ,  Frac(FParam.MkStartTime) ) +1;
        // ��Ʈ ����Ÿ ��û�� �ؼ�..���� �������� ���Ѵ�.
          gEnv.Engine.SendBroker.ReqChartData( FSymbol, Date, 36+iAdd, 60,'5' );
        //
      end else CalcHL;
    end else CalcHL;
  end;
end;

procedure TA50_P2_Trend.Stop;
begin
  FRun := false;
  DoLossCut;
  DoLog( 'A50_P2 Trend Stop' );

end;

procedure TA50_P2_Trend.CalcHL;
begin

  if FSymbol <> nil then
  begin
    //FHL2  := (FSymbol.PrevH[0] - FSymbol.PrevL[0]) /FParam.E_1; ;  // ������ band
    FHL   := (FSymbol.PrevH[1] - FSymbol.PrevL[1]) /FParam.E_1; ;  // ���� band;
  end;
end;



procedure TA50_P2_Trend.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin

  if ( Receiver <> Self ) or ( DataObj = nil ) then Exit;

  aQuote  := DataObj as TQuote;

  if DataID = CHART_DATA then
  begin
    case integer(EventID) of
      //
      CHART_60 :
        begin
         gEnv.Engine.SendBroker.ReqChartData( FSymbol, Date, 50, FParam.Period ,'5' );
         DoLog(' 60�� ����Ÿ ���� --> 5�е���Ÿ ��û ');
        end;
      CHART_5 , CHART_1: begin
        // ���� ��Ʈ����Ÿ ������..�ǽð� �ҵ����� ����� ON
        DoLog(' 5�� ����Ÿ ���� --> �ǽð� �ҵ����� ����� On ');
        CalcHL;
        aQuote.MakeTerm := true;
        aQuote.Terms.Period := FParam.Period;
        if aQuote.Terms.LastTerm <> nil then
          FATR := aQuote.Terms.LastTerm.ATR;
      end;
    end;
    Exit;
  end;

  OnQuote( aQuote );

end;

function TA50_P2_Trend.CheckOrder( aQuote : TQuote ) : integer;
begin
  Result := 0;

  case OrderCnt of
    0 :
      begin
        if ( aQuote.Last > ( FStartOpen + FHL ))  then
          Result := 1
        else if  (aQuote.Last < ( FStartOpen - FHL )) then
          Result := -1    ;

      end;
    1 :
      begin
        if (aQuote.Last > ( aQuote.Symbol.DawnOpen + FHL )) and (OrderedDir[0]  = -1) then
          Result := 1
        else if (aQuote.Last < ( aQuote.Symbol.DawnOpen - FHL )) and (OrderedDir[0] = 1) then
          Result := -1    ;
      end;
    else Exit;
  end;

  if Result <> 0 then
  begin
    OrderedDir[ OrderCnt ]  := Result;
    FEntryPrice := aQuote.Last;
    FEntLow   := FEntryPrice;
    FEntHigh  := FEntryPrice;
  end;

end;

function TA50_P2_Trend.CheckLiquid(aQuote: TQuote): boolean;
var
  dVal : double;
  stLog: string;
  iPre : integer;
begin
  Result := false;

  if FOrdSide = 0 then Exit;

  dVal := FATR * FParam.ATRMulti  ;
  iPre := aQuote.Symbol.Spec.Precision;

  if FOrdSide > 0 then
  begin

    if aQuote.Last < (FEntHigh -  dVal) then
    begin
      Result := true;
      stLog  := Format('�ż� û�� %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
          iPre, FEntHigh, iPre, dVal ]);
    end;
  end else
  begin
    if aQuote.Last > (FEntLow + dVal) then
    begin
      Result := true;
      stLog  := Format('�ŵ� û�� %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
          iPre, FEntLow, iPre, dVal ]);
    end;
  end;

  if Result  then  
    DoLog( stLog );
end;

function TA50_P2_Trend.CheckLossCut( aQuote : TQuote ) : boolean;
var
  dVal, dVal2 : double;
  dH, dL : double;
  stLog: string;
  iPre : integer;
begin
  Result := false;
  if FOrdSide = 0 then Exit;

  try
    ////................
    ///  �������� 1
    dVal :=  FEntryPrice * FParam.L_1;
    iPre := aQuote.Symbol.Spec.Precision;
    if FOrdSide > 0 then
    begin
      if aQuote.Last < (FEntryPrice - dVal) then
      begin
        Result := true;
        stLog  := Format('�ż� ���� L_1 :  %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
            iPre, FEntryPrice, iPre, dVal ]);
      end;
    end else
    begin
      if aQuote.Last > (FEntryPrice + dVal) then
      begin
        Result := true;
        stLog  := Format('�ŵ� ���� L_1 : %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
            iPre, FEntryPrice, iPre, dVal ]);
      end;
    end;

    ////............
    ///  �������� 2
    if Result then Exit;
    if FOrdSide > 0 then
    begin
      dH := Max(FEntHigh, aQuote.High) ;
      dVal  := dH - ( dH * FParam.L_2 );

      if aQuote.Last < dVal then
      begin
        Result := true;
        stLog  := Format('�ż� ���� L_2 :  %.*n  < ( %.*n - %.*n )',[  iPre, aQuote.Last,
            iPre, dH, iPre, dVal ]);
      end;
    end
    else begin
      dL := Min(FEntLow, aQuote.Low) ;
      dVal  := dL + ( dL * FParam.L_2 );

      if aQuote.Last > dVal then
      begin
        Result := true;
        stLog  := Format('�ŵ� ���� L_2 : %.*n  > ( %.*n + %.*n )',[  iPre, aQuote.Last,
            iPre, dL, iPre, dVal ]);
      end;
    end;

    ////............
    ///  Traiing stop
    if Result then Exit;

    if FOrdSide > 0 then
      dVal  := aQuote.Last - FEntryPrice
    else
      dVal  := FEntryPrice - aQuote.Last;

    if (dVal > FParam.GoalP) then
    begin
      Result := true;
      stLog  := Format('%s ���� ��ž %.*n --> %.*n --> *.*n', [
        ifThenStr( FOrdSide > 0,'�ż�','�ŵ�'),
        iPre, FEntryPrice,iPre, aQuote.Last]);
    end;


  finally
    if Result then DoLog( stLog );
  end;

end;

procedure TA50_P2_Trend.OnQuote( aQuote : TQuote );
var
  dtNow : TDateTime;
  bTerm , bRes: boolean;
  iDir  : integer;
begin
  dtNow := Frac( now );
  bTerm := false;

  if aQuote.AddTerm then
  begin
    bTerm := true;
    FATR := aQuote.Terms.LastTerm.ATR;
    if FOrdSide <> 0 then
      inc(FEntTermCnt);
  end;


  if not IsRun then Exit;
  // ����
  if dtNow < FParam.StartTime then Exit;
   // Stop
  if dtNow >= FParam.Endtime then
  begin
    // û��
    TFrmA_P2( FParent).cbRun.Checked := false;
    //FRun := false;
    Exit;
  end;

  if FLossCut then Exit;

  if FOrdSide <> 0 then
  begin
    FEntHigh := Max( FEntHigh, aQuote.Last );
    FEntLow  := Min( FEntLow,  aQuote.Last );
  end;

  if ( not FStarted ) and ( bTerm ) then
  begin
    if aQuote.Last < DOUBLE_EPSILON then Exit;
    if aQuote.Terms.PrevTerm <> nil then
    begin
      FStarted    := true;
      FStartOpen  := aQuote.Terms.PrevTerm.C;
      DoLog( Format('�ð� ���� %.*n', [ FSymbol.Spec.Precision, FStartOpen]));
    end;
  end;

  // �ð��� DOUBLE_EPSILON ���� ������ ����
  if ( not FStarted ) or ( FStartOpen < DOUBLE_EPSILON ) then
  begin
    FStarted  := false;
    Exit;
  end;

  // ���� or ������
  if (( dtNow >= FParam.EntTime ) and ( dtNow < FParam.EntEndtime ) and ( OrderCnt = 0 )) or
     (( dtNow >= FParam.ReEntTime ) and ( dtNow < FParam.ReEntEndtime ) and ( OrderCnt > 0 )) then
    if ( FOrdSide = 0) then
    begin
      iDir := CheckOrder( aQuote );
      if iDir <> 0 then begin
        DoOrder( aQuote, iDir );
        Exit;
      end;
    end;

  FLossCut := CheckLossCut( aQuote );

  if FLossCut then
  begin
    DoLossCut( aQuote );
    Exit;
  end;
    // û�����
  if( FEntTermCnt > FParam.TermCnt ) and ( dtNow >= FParam.ATRLiqTime )  then
  begin
    FLossCut := CheckLiquid( aQuote );
    if FLossCut then
    begin
      DoLossCut( aQuote );
      Exit;
    end;
  end;

end;

procedure TA50_P2_Trend.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;



end.