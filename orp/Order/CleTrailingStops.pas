unit CleTrailingStops;

interface

uses
  Classes, SysUtils, Math,

  CleSymbols, CleAccounts, ClePositions, CleOrders, CleQuoteBroker,

  CleFunds,

  GleTypes
  ;

type

  TStopParam = record
    BaseTick  : integer;
    PLTick    : integer;
    LCTick    : integer;
    IsMarket  : boolean;
    OrdTick   : integer;
    function GetString : string;
  end;

  //TTrailingStopMessage = procedure( Sender : TObject; iCalc, iMax, iNow : integer ) of object;
  TTrailingStopMessage = procedure( Sender : TObject; iMax, iCalc: integer; dStopPrc : double ) of object;

  TTrailingStop = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FPosition: TPosition;
    FRun: boolean;
    FParam: TStopParam;
    FMaxTick: integer;
    FDone   : boolean;
    FStopPrice : double;

    FOnResult: TResultNotifyEvent;
    FOnMessage: TTrailingStopMessage;
    FFund: TFund;
    FFundPosition: TFundPosition;
    FEx: boolean;
    FBasePrice: double;

    function IsRun : boolean;
    function CalcLCTick: integer; overload;
    function CalcLCTick( iMax : integer): integer; overload;
    procedure DoLiquid( aQuote : TQuote ); overload;
    procedure DoLiquid( aPos : TPosition; aQuote : TQuote ); overload;
    function GetAvgPrice: double;
    function GetVolume: integer;
    function GetSide: integer;
    function GetLogTitle: string;

  public
    TmpParam  : TStopParam;
    Constructor Create( aColl : TCollection ) ; override;
    Destructor  Destroy; override;

    procedure Stop;
    procedure Start;

    procedure init( aPos : TPosition );
    procedure initEx( aPos : TFundPosition );

    function IsImmeOrder( aQuote : TQuote ) : boolean;
    procedure Observer( aQuote : TQuote; bPos : boolean = false );
    function UpdateParam( iDiv, iValue : integer): boolean;
    function CheckParam( aParam : TStopParam) : boolean; overload;
    function CheckParam : boolean; overload;
      // objects
    property Account : TAccount read FAccount;
    property Position: TPosition read FPosition;

    property Fund : TFund read FFund;
    property FundPosition: TFundPosition read FFundPosition;

    property Symbol  : TSymbol  read FSymbol;

      // ����
    property Run  : boolean read FRun;
    property Done : boolean read FDone;
    property Ex   : boolean read FEx;
      // values

    property Param  : TStopParam read FParam write FParam;
    property MaxTick  : integer read FMaxTick;
    property BasePrice: double  read FBasePrice;

    property OnResult : TResultNotifyEvent read FOnResult write FOnResult;
    property OnMessage: TTrailingStopMessage read FOnMessage write FOnMessage;
  end;


  TTrailingStops = class( TCollection )
  private
    FOnResult: TResultNotifyEvent;
    FParam: TStopParam;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function Find( aPos : TPosition ) : TTrailingStop;
    function FindEx( aPos : TFundPosition ) : TTrailingStop;
    function New : TTrailingStop;

    property OnResult : TResultNotifyEvent read FOnResult write FOnResult;
    property Param : TStopParam read FParam write FParam;
  end;


implementation

uses
  GAppEnv , GleLib, GleConsts,
  Dialogs
  ;

{ TTrailingUnit }



constructor TTrailingStop.Create(aColl: TCollection);
begin
  inherited Create( aColl );

  FSymbol   := nil;
  FAccount  := nil;
  FPosition := nil;
  FStopPrice:= 0;

  FFund     := nil;
  FFundPosition := nil;
end;

destructor TTrailingStop.Destroy;
begin

  inherited;
end;

procedure TTrailingStop.DoLiquid( aQuote : TQuote );
var
  I: Integer;
  aPos : TPosition;
begin
  if not FEx then
    DoLiquid( FPosition, aQuote )
  else
    for I := 0 to FFundPosition.Positions.Count - 1 do
    begin
      aPos  := FFundPosition.Positions.Positions[i];
      if ( aPos = nil ) or ( aPos.Volume = 0 ) then continue;
      DoLiquid( aPos, aQuote );
    end;
end;

procedure TTrailingStop.DoLiquid(aPos : TPosition; aQuote: TQuote);
var
  iQty : integer;
  dPrice : double;
  aOrder : TOrder;
  aTicket: TOrderTicket;
  pcValue: TPriceControl;
begin

  iQty  := aPos.Volume * -1;

  if FParam.IsMarket then begin
    pcValue := pcMarket;
    dPrice  := 0;
  end else begin
    pcValue := pcLimit;
    dPrice  := aQuote.GetHitPrice( -aPos.Side , FParam.OrdTick, FStopPrice  );
    if dPrice < EPSILON then
    begin
      gEnv.EnvLog( WIN_TRDSTOP, Format('[%s,%s] ���ݿ��� --> %s, %s( %s ) %d', [
        aPos.Account.Name, aPos.Symbol.ShortCode,
        ifThenStr( iQty > 0, '�ż�','�ŵ�') , FSymbol.PriceToStr( FStopPrice),
        FSymbol.PriceToStr( aQuote.Last), FParam.OrdTick
        ]));
      Exit;
    end;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  aOrder  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx(
    gEnv.ConConfig.UserID, aPos.Account, aPos.Symbol, iQty,
    pcValue, dPrice, tmGTC, aTicket  );

  if aOrder <> nil then
  begin
    gEnv.Engine.TradeBroker.Send( aTicket );
    gEnv.EnvLog( WIN_TRDSTOP, Format('[%s,%s] û���ֹ� --> %s, %.*f, %d', [
        aPos.Account.Name, aPos.Symbol.ShortCode,
        aOrder.GetOrderName, FSymbol.Spec.Precision, aOrder.Price, aOrder.OrderQty
        ]));
    FDone := true;
  end;

end;

procedure TTrailingStop.init(aPos: TPosition);
begin
  FSymbol  := aPos.Symbol;
  FAccount := aPos.Account;
  FPosition:= aPos;
  FFundPosition := nil;
  FEx      := false;
end;

procedure TTrailingStop.initEx(aPos: TFundPosition);
begin
  FFundPosition := aPos;
  FFund         := aPos.Fund;
  FSymbol       := aPos.Symbol;
  FPosition     := nil;
  FEx           := true;
end;

function TTrailingStop.IsRun: boolean;
begin

  if FEx then
  begin

    if ( FFund = nil ) or ( FSymbol = nil ) or ( FFundPosition = nil ) or ( not FRun ) then
      Result := false
    else
      Result := true;

  end else
  begin

    if ( FAccount = nil ) or ( FSymbol = nil ) or ( FPosition = nil ) or ( not FRun ) then
      Result := false
    else
      Result := true;

  end;
end;

function TTrailingStop.CalcLCTick : integer;
var
  iIncPLTick  : integer;
begin

  if FParam.PLTick = 0 then
    iIncPLTick := 0
  else
    iIncPLTick  := FMaxTick div FParam.PLTick;

  Result  := FParam.LCTick * iIncPLTick;
end;

// üũ������ ��� --> TmpParam �� ���
function TTrailingStop.CalcLCTick( iMax : integer): integer;
var
  iIncPLTick  : integer;
begin

  if TmpParam.PLTick = 0 then
    iIncPLTick := 0
  else
    iIncPLTick  := iMax div TmpParam.PLTick;

  Result  := TmpParam.LCTick * iIncPLTick;

end;



function TTrailingStop.GetLogTitle : string;
begin
  if FEx then
    Result := Format('[F] %s, %s', [ FFund.Name, FSymbol.ShortCode ])
  else
    Result := Format('%s, %s', [ FAccount.Name, FSymbol.ShortCode ])
end;


function TTrailingStop.GetVolume : integer;
begin
  if FEx then
    Result := FFundPosition.Volume
  else
    Result := FPosition.Volume;
end;

function TTrailingStop.GetAvgPrice : double;
begin
  if FEx then
    Result := FFundPosition.AvgPrice
  else
    Result := FPosition.AvgPrice;
end;

function TTrailingStop.GetSide : integer;
begin
  if FEx then begin
    if FFundPosition.Volume > 0 then
      Result := 1
    else if FFundPosition.Volume < 0 then
      Result := -1
    else
      Result := 0;
  end
  else
    Result := FPosition.Side;
end;


procedure TTrailingStop.Observer( aQuote : TQuote ; bPos : boolean );
var
  iVal, iTmp, iNow, iSide, iTick, iCalcLCTick : integer;
  stLog : string;
  dBase, dCalcBase, dStopPrice, dMaxPrice : double;
begin
  if not IsRun then Exit;

  if GetVolume = 0 then Exit;
  if FSymbol.Spec.TickSize = 0 then Exit;
  if FDone then Exit;

  iSide := GetSide;
  dBase := Round( GetAvgPrice /FSymbol.Spec.TickSize+EPSILON2)*FSymbol.Spec.TickSize;

  // ��մܰ��� ���ҽÿ���..
  if  not IsEqual( dBase, FBasePrice )  then
  begin
    if bPos then begin
      gEnv.EnvLog( WIN_TRDSTOP, Format('%s : ��� ��ȭ�� ���� �ʱ�ȭ  ( %s --> %s ) (%d --> 0) (%s, %d )',
        [ GetLogTitle,  FSymbol.PriceToStr( FBasePrice ), FSymbol.PriceToStr( dBase )  ,
          FMaxTick,
          ifThenStr( GetSide > 0, '�ż�', '�ŵ�'), GetVolume ]) );
      FMaxTick    := 0;
    end;
    FBasePrice  := dBase;
  end;

  iTick := Round(( aQuote.Last - dBase ) / FSymbol.Spec.TickSize ) * iSide;

  FMaxTick    := Max( FMaxTick, iTick );
  iCalcLCTick := CalcLCTick;

  dCalcBase   := dBase + ( FSymbol.Spec.TickSize * iCalcLCTick ) * iSide;
  dStopPrice  := dCalcBase - ( FSymbol.Spec.TickSize * FParam.BaseTick )* iSide ;
  dMaxPrice   := dBase + ( FSymbol.Spec.TickSize * FMaxTick ) * iSide;

  iTick := Round(( aQuote.Last - dCalcBase ) / FSymbol.Spec.TickSize ) * iSide;

  stLog := Format('[%s �ܰ�(%s, %d) (L:%s  A:%s S:%s ] - [Max:%d , Now:%d, Clc:%d] ( %d, %d, %d )]', [
    GetLogTitle,
    ifThenStr( GetSide > 0, '�ż�', '�ŵ�'), GetVolume,
      FSymbol.PriceToStr( aQuote.Last), FSymbol.PriceToStr( dBase ), FSymbol.PriceToStr( dStopPrice ),
      FMaxTick, iTick, iCalcLCTick,
      FParam.BaseTick, FParam.PLTick, FParam.LCTick  ]);

  if -FParam.BaseTick >= iTick then
  begin
    // ����..
    FStopPrice  := dStopPrice;
    DoLiquid( aQuote );
    gEnv.EnvLog( WIN_TRDSTOP,  Format('���� --> %s ', [ stLog ])   );
    dStopPrice  := 0;
  end else
    FStopPrice  := dStopPrice;

  if Assigned( FOnMessage ) then
    FOnMessage( Self, FMaxTick, iCalcLCTick, dStopPrice  );

  if FDone and ( Assigned( FOnResult )) then
    FOnResult( Self, false );

end;

// ���� or ���� ����� �ٷ� �ֹ��� �������� üũ..
function TTrailingStop.IsImmeOrder(aQuote: TQuote) : boolean;
var
  iVal, iTmp, iNow, iSide, iTick, iCalcLCTick, iMaxTick : integer;
  stLog : string;
  dBase, dCalcBase, dStopPrice, dMaxPrice : double;
begin
  Result := false;
//  if not IsRun then Exit;

  if GetVolume = 0 then Exit;
  if FSymbol.Spec.TickSize = 0 then Exit;
  if FDone then Exit;

  iSide := GetSide;
  dBase := Round( GetAvgPrice /FSymbol.Spec.TickSize+EPSILON2)*FSymbol.Spec.TickSize;

  // ��մܰ��� ���ҽÿ���..
  if  not IsEqual( dBase, FBasePrice )  then
  begin
    FBasePrice  := dBase;
  end;

  iTick := Round(( aQuote.Last - dBase ) / FSymbol.Spec.TickSize ) * iSide;

  iMaxTick    := Max( FMaxTick, iTick );
  iCalcLCTick := CalcLCTick( iMaxTick );

  dCalcBase   := dBase + ( FSymbol.Spec.TickSize * iCalcLCTick ) * iSide;
  dStopPrice  := dCalcBase - ( FSymbol.Spec.TickSize * FParam.BaseTick )* iSide ;
  dMaxPrice   := dBase + ( FSymbol.Spec.TickSize * iMaxTick ) * iSide;

  iTick := Round(( aQuote.Last - dCalcBase ) / FSymbol.Spec.TickSize ) * iSide;

  stLog := Format('[%s �ܰ�(%s, %d) (L:%s  A:%s S:%s ] - [Max:%d , Now:%d, Clc:%d] ( %d, %d, %d )]', [
    GetLogTitle,
    ifThenStr( GetSide > 0, '�ż�', '�ŵ�'), GetVolume,
      FSymbol.PriceToStr( aQuote.Last), FSymbol.PriceToStr( dBase ), FSymbol.PriceToStr( dStopPrice ),
      iMaxTick, iTick, iCalcLCTick,
      TmpParam.BaseTick, TmpParam.PLTick, TmpParam.LCTick  ]);

  if -TmpParam.BaseTick >= iTick then
  begin
    Result := true;
    gEnv.EnvLog( WIN_TRDSTOP,  Format('�ù� --> %s ', [ stLog ])   );
  end;
end;

procedure TTrailingStop.Start;
begin

  if FEx then begin
    if ( FFund = nil ) or ( FSymbol = nil ) or ( FFundPosition = nil ) then Exit;
  end else begin
    if ( FAccount = nil ) or ( FSymbol = nil ) or ( FPosition = nil ) then Exit;
  end;

  FMaxTick  := 0;
  FBasePrice := 0;
  FDone     := false;
  FRun      := true;

  if FSymbol.Quote <> nil then
    Observer( FSymbol.Quote as TQuote );

  gEnv.EnvLog( WIN_TRDSTOP,  Format('%s ���� --> %s, %d ', [ GetLogTitle,
    ifThenStr( GetSide > 0, '�ż�', '�ŵ�'), GetVolume ]) );
end;


procedure TTrailingStop.Stop;
begin
  FRun  := false;
end;

function TTrailingStop.CheckParam: boolean;
var
  bRes : boolean;
  stLog: string;
begin
  Result := true;

  {
  if TmpParam.LCTick > TmpParam.PLTick then
  begin
    ShowMessage('����ƽ�� ����ƽ���� ũ�� �ȵ�');
    Result := false;
    Exit;
  end;
  }

  if FSymbol.Quote <> nil then
  begin

    if IsImmeOrder( FSymbol.Quote as TQuote ) then begin

      stLog := ifThenStr( FRun , '���� �����', '�� �������� �����ϸ�' );
      bRes :=  MessageDlgLE( nil,
       stLog + ' ��ž �ֹ��� �ٷ� �����ϴ�.' + #13+#10 + '����Ͻðڽ��ϱ�?"',
        mtConfirmation, [mbOK, mbCancel]) = 1;

      if bRes  then begin
        gEnv.EnvLog( WIN_TRDSTOP, Format('%s change param - ��� �ֹ� ��� ���� ', [ GetLogTitle ]));
        FParam  := TmpParam;
        if FRun then
          Observer( FSymbol.Quote as TQuote );
      end
      else begin
        gEnv.EnvLog( WIN_TRDSTOP, Format('%s change param - ��� �ֹ� ���� ���� ���� ', [ GetLogTitle ]));
        Result := false;
      end;
    end
    else begin
      FParam  := TmpParam;
      if FRun then
        Observer( FSymbol.Quote as TQuote );
    end;
  end;

  if IsRun then
    gEnv.EnvLog( WIN_TRDSTOP, Format('%s check param  %s ', [GetLogTitle, FParam.GetString ]));

end;

function TTrailingStop.CheckParam(aParam: TStopParam ): boolean;
var
  bRes : boolean;
  stLog: string;
begin
  Result := true;
   {
  if aParam.LCTick > aParam.PLTick then
  begin
    ShowMessage('����ƽ�� ����ƽ���� ũ�� �ȵ�');
    Result := false;
    Exit;
  end;
   }
  if FSymbol.Quote <> nil then
  begin
    TmpParam  := aParam;

    if IsImmeOrder( FSymbol.Quote as TQuote ) then begin

      stLog := ifThenStr( FRun , '���� �����', '�� �������� �����ϸ�' );
      bRes :=  MessageDlgLE( nil,
       stLog + ' ��ž �ֹ��� �ٷ� �����ϴ�.' + #13+#10 + '����Ͻðڽ��ϱ�?"',
        mtConfirmation, [mbOK, mbCancel]) = 1;

      if bRes  then begin
        gEnv.EnvLog( WIN_TRDSTOP, Format('%s change param - ��� �ֹ� ��� ���� ', [ GetLogTitle ]));
        FParam  := aParam;
        if FRun then
          Observer( FSymbol.Quote as TQuote );
      end
      else begin
        gEnv.EnvLog( WIN_TRDSTOP, Format('%s change param - ��� �ֹ� ���� ���� ���� ', [ GetLogTitle ]));
        Result := false;
      end;
    end
    else begin
      FParam  := aParam;
      if FRun then
        Observer( FSymbol.Quote as TQuote );
    end;
  end;

  if IsRun then
    gEnv.EnvLog( WIN_TRDSTOP, Format('%s check param  %s ', [
      GetLogTitle, FParam.GetString ]));

end;

function TTrailingStop.UpdateParam(iDiv, iValue: integer) : boolean;
var
  bCalc : boolean;
  stLog : string;
  bRes  : boolean;
begin

  TmpParam  := FParam;
  bCalc     := true;

  case iDiv of
    1 : begin TmpParam.IsMarket := iValue = 0; bCalc := false; stLog := 'price type'; end;
    4 : begin TmpParam.BaseTick := iValue; stLog := 'base tick'; end;
    5 : begin TmpParam.PLTick   := iValue; stLog := 'PL tick'; end;
    6 : begin TmpParam.LCTick   := iValue; stLog := 'LC tick'; end;
    7 : begin TmpParam.OrdTick  := iValue; bCalc := false; stLog := 'stop tick'; end;
  end;

  if not bCalc then
    FParam.OrdTick  := TmpParam.OrdTick;
    //Observer( FSymbol.Quote as TQuote );

  if IsRun then
  begin
    gEnv.EnvLog( WIN_TRDSTOP, Format('%s change param  %s, %d', [
      GetLogTitle, stLog, iValue ]));
  end;

end;

{ TTrailingStops }

constructor TTrailingStops.Create;
begin
  inherited Create( TTrailingStop );
end;

destructor TTrailingStops.Destroy;
begin

  inherited;
end;

function TTrailingStops.Find(aPos: TPosition): TTrailingStop;
var
  I: Integer;
  aItem : TTrailingStop;
begin
  Result := nil;
  if aPos = nil then Exit;
  for I := 0 to Count - 1 do
  begin
    aItem := Items[i] as TTrailingStop;
    if (aItem.Position = aPos) and ( aItem.Run ) then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function TTrailingStops.FindEx(aPos: TFundPosition): TTrailingStop;
var
  I: Integer;
  aItem : TTrailingStop;
begin
  Result := nil;
  if aPos = nil then Exit;
  for I := 0 to Count - 1 do
  begin
    aItem := Items[i] as TTrailingStop;
    if (aItem.FundPosition = aPos) and ( aItem.Run ) then
    begin
      Result := aItem;
      break;
    end;
  end;

end;

function TTrailingStops.New : TTrailingStop;
begin
  Result  := Add as TTrailingStop;
end;



{ TStopParam }

function TStopParam.GetString: string;
begin
  Result  := Format('base :%d, PL:%d, LC:%d, %s (%d)', [
    BaseTick, PLTick, LCTick, ifThenStr( IsMarket, '���尡','������'), OrdTick ]);
end;

end.
