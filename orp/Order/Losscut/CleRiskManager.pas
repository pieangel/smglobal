unit CleRiskManager;

interface

uses
  Classes, SysUtils,

  CleSymbols, CleAccounts, ClePositions, CleQuoteBroker, CleOrders,

  CleDistributor,

  GleTypes
  ;

Const
  DEP = 0;
  POS = 1;
  ACT = 2;

type

  TRiskManageItem = class( TCollectionItem )
  private
    FInvest: TInvestor;
    FRun: Boolean;
    FOrderList: TList;

    function CheckLossCut2 : boolean;
    function CheckLossCut(aPos: TPosition = nil): boolean;
    function GetDepType: TDepositType;
    function IsRun : boolean;
    function GetDepositeOTE: double;

    procedure DoLog( stLog : string );
    procedure DoLossCut;
    procedure DoCancel;
    function DoOrder( aTarget : TOrder ) : TOrder;
    function DoLiquid( aAcnt : TAccount; aSymbol : TSymbol; iQty , iSide : integer ) : TOrder;
    function CheckOrder( aPos : TPosition ) : boolean;
    procedure RequestAccountData; overload;
    procedure RequestAccountData( iType : integer  ); overload;

    function GetQueryPer: integer;
    procedure CheckActiveOrder;
  public
    QueryCnt : array [0..2] of integer;

    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    procedure OnTimer( Sender : TObject );
    procedure OnQuote( aQuote : TQuote );
    procedure OnTrade( aData : TObject; iDiv : integer );

    procedure Stop;
    procedure Start;

    property OrderList : TList read FOrderList;
    property Invest : TInvestor read FInvest write FInvest;
    property Run    : Boolean read FRun write FRun;

    property DepositeOTE : double read GetDepositeOTE;
    property DepType: TDepositType read GetDepType;
    property QueryPer: integer read GetQueryPer;
  end;

  TRiskManagers  = class( TCollection )
  private
    FRealTime: boolean;
    FInterval: integer;
    FIsQuery : boolean;
    FDepType: TDepositType;
    FOnResult: TTextNotifyEvent;
    FMarketLiq: boolean;
    FNewPosLiq: boolean;
    FNewOrdCnl: boolean;
    FPosQueryPer: integer;
    function GetRiskItem(i: Integer): TRiskManageItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aInvest : TInvestor ) : TRiskManageItem;
    function Find(aInvest : TInvestor ) : TRiskManageItem;

    procedure Del( aItem : TRiskManageItem ); overload;
    procedure Del( aInvest : TInvestor ); overload;

    procedure OnQuote( aQuote : TQuote ) ;
    procedure OnTrade( aData  : TObject;  iDiv : integer );
    procedure OnTimer( Sender : TObject );
    procedure AllStop;

    property RiskItem[i : Integer] : TRiskManageItem read GetRiskItem; default;

    property Interval : integer read FInterval write FInterval;
    property RealTime : boolean read FRealTime write FRealTime;
    property IsQeury  : boolean read FIsQuery  write FIsQuery;
    property DepType  : TDepositType read FDepType write FDepType;

    property OnResult : TTextNotifyEvent read FOnResult write FOnResult;

    /////////////
    property MarketLiq : boolean read FMarketLiq write FMarketLiq;
    property NewOrdCnl : boolean read FNewOrdCnl write FNewOrdCnl;
    property NewPosLiq : boolean read FNewPosLiq write FNewPosLiq;
    property PosQueryPer : integer read FPosQueryPer write FPosQueryPer;

  end;

implementation

uses
  GAppEnv, GleLib , Gleconsts , ApiPacket
  ;

{ TRiskManageItem }

constructor TRiskManageItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FRun  := false;
  FOrderList:= TList.Create;
  QueryCnt[0] := 0;
  QueryCnt[1] := 0;
  QueryCnt[2] := 0;

end;

destructor TRiskManageItem.Destroy;
begin
  FOrderList.Free;
  inherited;
end;

procedure TRiskManageItem.DoLog(stLog : string);
begin
  if Assigned(  TRiskManagers( Collection ).OnResult ) then
    TRiskManagers( Collection ).OnResult( Self, stLog );
end;

procedure TRiskManageItem.DoCancel;
var
  I: Integer;
  rOrder, aOrder : TOrder;
begin
  for I := 0 to gEnv.Engine.TradeCore.Orders.ActiveOrders.Count - 1 do
  begin
    aOrder  := gEnv.Engine.TradeCore.Orders.ActiveOrders.Orders[i];
    if ( aOrder <> nil ) and  ( aOrder.Account.InvestCode = FInvest.Code ) and
       ( not aOrder.Modify ) and  ( aOrder.OrderType = otNormal ) and
       ( aOrder.ActiveQty > 0 ) and ( aOrder.PriceControl <> pcMarket ) then
    begin
      rOrder  := DoOrder( aOrder );
      if rOrder <> nil then
        DoLog( Format('%s 취소주문 %s, %s, %s, %d', [ ifThenStr( FInvest.BCutOff, '자동',''),
          rOrder.Symbol.Code,
          rOrder.SideToStr, rOrder.Symbol.PriceToStr( aOrder.Price ), rOrder.OrderQty ]));
    end;
  end;
end;

function TRiskManageItem.DoOrder(aTarget: TOrder): TOrder;
var
  aTicket : TOrderTicket;
begin

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);
  Result  := gEnv.Engine.TradeCore.Orders.NewCancelOrderEx( aTarget,
    aTarget.ActiveQty, aTicket ) ;

  if Result <> nil then
    gEnv.Engine.TradeBroker.Send( aTicket );

end;

function TRiskManageItem.DoLiquid(aAcnt : TAccount; aSymbol: TSymbol; iQty, iSide: integer) : TOrder;
var
  aTicket : TOrderTicket;
begin
  Result := nil;

  if iQty <= 0 then
  begin
    DoLog( Format('주문수량 이상  %s, %s, %d', [ aSymbol.Code,
      ifThenStr( iSide > 0,'매수','매도'), iQty ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New(Self);

  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
              gEnv.ConConfig.UserID, aAcnt, aSymbol,
              //iVolume, pcLimit, dPrice, tmFOK, aTicket) ;
              iSide * iQty, pcMarket, 0.0, tmGTC, aTicket);  //
  if Result <> nil then
    gEnv.Engine.TradeBroker.Send(aTicket);
end;

function TRiskManageItem.CheckOrder( aPos : TPosition ) : boolean;
var
  iQty, i, iSide : integer;
  aOrder : TOrder;
begin
  if aPos.Volume > 0 then
    iSide := 1
  else
    iSide := -1;

  iQty  := 0;

  for i := 0 to FOrderList.Count - 1 do
  begin
    aOrder  := TOrder( FOrderList.Items[i] );
    if (aOrder.Symbol <> aPos.Symbol) or ( aOrder.Account <> aPos.Account) then
      Continue;

    if (iSide + aOrder.Side ) <> 0 then
      Continue;

    case aOrder.State of
      osActive : iQty := iQty + aOrder.ActiveQty;
      osSent, osReady, osSrvAcpt  :  iQty := iQty + aOrder.OrderQty;
    end;
  end;

  if iQty = 0 then
    Result := true
  else begin
    Result := false;
    {
    DoLog( Format('%s 손절주문 스킵 : %s, %s, %s, (%d | %d )', [ ifThenStr( FInvest.BCutOff, '자동',''),
       aPos.Account.Code, aPos.Symbol.Code, aPos.SideToStr, aPos.Volume , iQty ]));
    }
  end;

end;

procedure TRiskManageItem.DoLossCut;
var
  I : Integer;
  aPos  : TPosition;
  aOrder: TOrder;
begin

  for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
  begin
    aPos := gEnv.Engine.TradeCore.Positions.Positions[i];
    if ( aPos.Volume <> 0 ) and ( aPos.Account.InvestCode = FInvest.Code ) and
       ( CheckOrder( aPos )) then
    begin
      // 이미 청산주문이 나가 있는 상태
      aOrder  := DoLiquid( aPos.Account, aPos.Symbol, abs(aPos.Volume), aPos.Side * -1 );
      if aOrder <> nil then
      begin
        aPos.Liquidated := true;
        FOrderList.Add( aOrder );
        DoLog( Format('%s 손절주문 %s, %s, %d', [ ifThenStr( FInvest.BCutOff, '자동',''),
           aOrder.Symbol.Code, aOrder.SideToStr, aOrder.OrderQty ]));
      end;
    end;
  end;

end;



function TRiskManageItem.GetDepositeOTE: double;
var
  aPos : TPosition;
  I: Integer;
  dFee, dTot : double;
begin
  dTot := 0;
  for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
  begin
    aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
    if aPos.Account = FInvest then
      dTot := dTot + aPos.LastPL;
  end;

  dFee := FInvest.GetFee;

  if DepType = dtWON then
  begin
    dFee := dFee * FInvest.ExchangeRate[dtUSD];
    dTot := dTot * FInvest.ExchangeRate[dtUSD];
  end;

  Result := FInvest.Deposit[DepType] + FInvest.FixedPL[DepType] - dFee
     + dTot + FInvest.UnBackAmt[DepType];

end;

function TRiskManageItem.GetDepType: TDepositType;
begin
  Result := TRiskManagers( Collection ).DepType;
end;

function TRiskManageItem.GetQueryPer: integer;
begin
  Result := TRiskManagers( Collection ).PosQueryPer;
end;

function TRiskManageItem.IsRun: boolean;
begin
  Result := false;

  if not FRun then Exit;
  if FInvest = nil then Exit;

  Result := true;
end;



function TRiskManageItem.CheckLossCut( aPos : TPosition ) : boolean;
begin

  if FInvest.BCutOff then
  begin

    if TRiskManagers( Collection ).NewPosLiq then
      DoLossCut;
    if TRiskManagers( Collection ).NewOrdCnl then
      DoCancel;
  end;

end;

function TRiskManageItem.CheckLossCut2: boolean;
begin
  if not FInvest.BCutOff then
    if ( FInvest.DepositOTE[DepType] < FInvest.LossCutAmt[DepType] )then
    begin

      try
        DoLog(
          Format( '한도에 의한 손절 시도 (%s) --> (%.0f)  < %.0f ', [
            ifThenStr( DepType = dtUSD,'달러','원화'), FInvest.DepositOTE[DepType],
            FInvest.LossCutAmt[DepType]] )
          );
      except
      end;
      FInvest.BCutOff := true;
      Result := true;
      //
    end;

  if FInvest.BCutOff then
    RequestAccountData;
end;

procedure TRiskManageItem.RequestAccountData;
begin
  //  유지증거금 > 0  or  평가손익 <> 0  --> 잔고 조회
  if (FInvest.HoldMargin[DepType] > 0) or ( FInvest.OpenPL[DepType] <> 0 ) then
    RequestAccountData( POS );

  // 위탁 증거금 > 0  --> 미체결 조회
  if FInvest.TrustMargin[DepType] > 0 then
    RequestAccountData( ACT );
end;

procedure TRiskManageItem.OnQuote(aQuote: TQuote);
var
  I: Integer;
  aPos : TPosition;
  bHave: boolean;
begin

  if not IsRun then Exit;

  bHave := false;

  if aQuote.LastEvent = qtTimeNSale then
    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
      if ( aPos <> nil ) and ( aPos.Account.InvestCode = FInvest.Code ) and
         ( aPos.Volume <> 0) then
      begin
      // 하나는 조회베이스이기 때문에..실시간 체크는 빼자
        //if aPos.Symbol = aQuote.Symbol then begin
        //  CheckLossCut( aPos );
          //bHave := true;// CheckLossCut( aPos );
          //break;
        //end;
      end;
    end;

  // 보유한 포지션의 시세가 왔을때만..체크
  //if bHave then
  //  CheckLossCut( aPos );

end;


procedure TRiskManageItem.OnTrade(aData: TObject; iDiv: integer);
var
  aOrder : TOrder;
  bRes   : boolean;
begin
  if not IsRun then Exit;

  case iDiv of
    // 미체결 주문과  포지션 처리.
    ORDER_ACCEPTED   ,
    POSITION_NEW     : if aData = FInvest then CheckLossCut;
    ACCOUNT_DEPOSIT  : if aData = FInvest then CheckLossCut2;
  end;


  {
  // 실시간일때만.
  try
    if aData is TOrder then
    begin
      aOrder  := aData as TOrder;
      if aOrder.State in  [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
        FOrderList.Remove( aOrder )
    end;
  except
  end;
  }

end;

procedure TRiskManageItem.CheckActiveOrder;
var
  i : integer;
  aOrder : TOrder;
begin
  for I := FOrderList.Count-1 downto 0 do
  begin
    aOrder  := TOrder( FOrderList.Items[i] );
    if aOrder <> nil then
      if aOrder.State in [ osSrvRjt,osRejected, osFilled, osCanceled, osConfirmed, osFailed] then  // 전량체결/죽은주문
        FOrderList.Delete(i);
  end;
end;

procedure TRiskManageItem.RequestAccountData(iType: integer);
begin

  case iType of
    DEP : gEnv.Engine.SendBroker.RequestAccountData( FInvest, rtDeposit);
    POS : gEnv.Engine.SendBroker.RequestAccountData( FInvest, rtAcntPos );
    ACT : gEnv.Engine.SendBroker.RequestAccountData( FInvest, rtActiveOrd );
    else Exit;
  end;

  inc(QueryCnt[iType]);

end;

procedure TRiskManageItem.OnTimer(Sender: TObject);
begin

  if (FInvest <> nil) and ( FInvest.IsSucc )  then
  begin
    RequestAccountData( DEP );
  end;
  CheckActiveOrder;
end;


procedure TRiskManageItem.Start;
begin
  FRun := true;
  CheckLossCut;
end;

procedure TRiskManageItem.Stop;
begin
  FRun := false;
end;

{ TRiskManagers }

procedure TRiskManagers.AllStop;
var
  I: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    if GetRiskItem(i) <> nil then
      GetRiskItem(i).Stop;
  end;
end;

constructor TRiskManagers.Create;
begin
  inherited Create( TRiskManageItem );

  FRealTime:= false;
  // 1초에 한번 조회
  FInterval:= 1000;
  FIsQuery := true;
  FDepType := dtUSD;
  FPosQueryPer := 70;
end;

procedure TRiskManagers.Del(aInvest: TInvestor);
var
  I: Integer;
begin

  for I := 0 to Count - 1 do
  begin
    if GetRiskItem(i).Invest = aInvest then
    begin
      GetRiskItem(i).Stop;
      Delete(i);
      break;
    end;
  end;

end;

procedure TRiskManagers.Del(aItem: TRiskManageItem);
var
  I: Integer;
begin

  for I := 0 to Count - 1 do
  begin
    if GetRiskItem(i) = aItem then
    begin
      Delete(i);
      break;
    end;
  end;

end;

destructor TRiskManagers.Destroy;
begin

  inherited;
end;

function TRiskManagers.Find(aInvest: TInvestor): TRiskManageItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if GetRiskItem(i).Invest = aInvest then
    begin
      Result := GetRiskItem(i);
      break;
    end;
  end;
end;

function TRiskManagers.GetRiskItem(i: Integer): TRiskManageItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := ITems[i] as  TRiskManageItem;
end;

function TRiskManagers.New(aInvest: TInvestor): TRiskManageItem;
begin
  Result := Find( aInvest );

  if Result = nil then
  begin
    Result := Add as TRiskManageItem;
    Result.Invest := aInvest;
  end;
end;

procedure TRiskManagers.OnQuote(aQuote: TQuote);
var
  I: Integer;
begin
  if aQuote = nil then Exit;

  for I := 0 to Count - 1 do
    GetRiskItem(i).OnQuote( aQuote );
end;

procedure TRiskManagers.OnTimer(Sender: TObject);
var
  iMod, i : integer;
begin
  for I := 0 to Count - 1 do
  begin
    iMod  := i mod 5;
    GetRiskItem(i).OnTimer( Sender );
    if ( i > 0 ) and ( iMod = 0 ) then
      Sleep(1);
  end;
end;

procedure TRiskManagers.OnTrade(aData: TObject; iDiv: integer);
var
  i : integer;
begin
  for I := 0 to Count - 1 do
    GetRiskItem(i).OnTrade( aData, iDiv );
end;

end.
