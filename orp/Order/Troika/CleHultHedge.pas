unit CleHultHedge;

interface


uses
  Classes, SysUtils, Math,

  GleTypes,

  CleSymbols, CleOrders, CleQuotebroker, CleDistributor, CleQuoteTimers,

  CleAccounts, ClePositions , CleKrxSymbols, CleInvestorData
  ;

type

  THedgeOrder = class( TCollectionItem )
  public
    Order   : TOrder;
    LiqOrder: TOrder;
    OrdDir  : integer;    // �ֹ� ����
    UseFut  : boolean;

    MinPrc, MaxPrc : double;
    EntryPrc : double ; // �ɼ��϶� ���  �ֳ�..���� ���ݺ��� û���ϱⶫ��
    ManualQty : integer; // ���� û�� ����..

    Constructor Create( aColl : TCollection ) ; override;
  end;

  THedgeOrders = class( TCollection )
  private
    function GetOrdered(i: Integer): THedgeOrder;
  public
    OrdCnt  : array [TPositionType] of integer;
    OptOrdCnt  : array [TPositionType] of integer;

    Constructor Create;
    Destructor  Destroy; override;

    function New( aOrder : TOrder ) : THedgeOrder;
    procedure Del( aOrder: TOrder );
    function IsOrder( iSide : integer ) : boolean;

    property Ordered[i : Integer] : THedgeOrder read GetOrdered;
  end;

  THultHedgeParam = record
    StartTime1, StartTime2, EndTime : TDateTime;
    OptQty, Qty : integer;
    E1, L1, L2, LC : double;
    ConPlus : double;    // ��/���� ��� �÷��� ����
    Run : boolean;

    UseFut, UseOpt : boolean;
    dBelow, dAbove : double;
    OptCnt : integer;
    AscIdx : integer; // 0 : ��������  , 1 : ��������
  end;

  THultHedgeItem = class( TCollectionItem )
  private
    FRun: boolean;
    FSymbol: TSymbol;
    FParam: THultHedgeParam;
    FAccount: TAccount;
    FHedgeOrders: THedgeOrders;
    FNo: integer;
    FOrdDir : integer;
    FEntryCnt: integer;
    function IsRun : boolean;
    procedure Reset ;
    procedure OnQuote(aQuote: TQuote);
    function CheckSide(aQuote: TQuote): integer;

    procedure DoLog( stLog : string );
    procedure NewOrder( iSide : integer; aQuote : TQuote );
    function DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
    procedure CheckLiquid(aQuote: TQuote; bTerm: boolean);
    function CheckLiquid2(aH: THedgeOrder; aQuote: TQuote;
      bTerm: boolean): boolean;

  public
    Constructor Create( aColl : TCollection ); override;
    Destructor  Destroy; override;

    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;
    function Start : boolean;
    Procedure Stop;

    property Symbol  : TSymbol read FSymbol;  // �ֱٿ���..
    property Account : TAccount read FAccount;
    property Param   : THultHedgeParam read FParam write FParam;
    property No : integer read FNo write FNo;
    property EntryCnt : integer read FEntryCnt write FEntryCnt;

    property HedgeOrders : THedgeOrders read FHedgeOrders;
  end;

  THultHedgeItems = class( TCollection )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    function GetHedgeItem(i: Integer): THultHedgeItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    procedure TradePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    function Start : boolean;
    Procedure Stop;
    function init( aAcnt : TAccount; aSymbol : TSymbol ) : boolean;

    function New( iNo : integer ) : THultHedgeItem;

    property HedgeItem[i : Integer] : THultHedgeItem read GetHedgeItem;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Account : TAccount read FAccount write FAccount;
  end;

implementation

uses
  GAppEnv, GleLib,
  Ticks
  ;

{ THultHedgeItem }

constructor THultHedgeItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FHedgeOrders:= THedgeOrders.Create;
  FRun    := false;
  FSymbol := nil;
  FAccount:=nil;
  FNo := -1;
  FOrdDir := 0;
  FEntryCnt := 0;
end;

destructor THultHedgeItem.Destroy;
begin
  FHedgeOrders.Free;
  inherited;
end;


procedure THultHedgeItem.DoLog(stLog: string);
begin
  if FAccount <> nil then
    gEnv.EnvLog( WIN_ENTRY, stLog, false,
      Format('HultHedge_%s', [ Account.Code]) );
end;

function THultHedgeItem.DoOrder(iQty, iSide: integer; aQuote: TQuote): TOrder;
var
  aTicket : TOrderTicket;
  dPrice  : double;
  stErr   : string;
  bRes    : boolean;
begin
  Result := nil;

  if aQuote = nil then Exit;  

  if iSide > 0 then
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, 3 )
  else
    dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -3 );

  bRes   := CheckPrice( aQuote.Symbol, Format('%.*n', [aQuote.Symbol.Spec.Precision, dPrice]),
    stErr );

  if (iQty = 0 ) or ( not bRes ) then
  begin
    DoLog( Format(' �ֹ� ���� �̻� : %s, %s, %d, %.2f - %s',  [ Account.Code,
      aQuote.Symbol.ShortCode, iQty, dPrice, stErr ]));
    Exit;
  end;

  aTicket := gEnv.Engine.TradeCore.OrderTickets.New( Self );
  Result  := gEnv.Engine.TradeCore.Orders.NewNormalOrderEx( gEnv.ConConfig.UserID,
    Account, aQuote.Symbol, iQty * iSide , pcLimit, dPrice, tmGTC, aTicket );

  if Result <> nil then
  begin
    Result.OrderSpecies := opTrend2;
    //if Result.Symbol.ShortCode[1] = '1' then
    //  DoLog( Format('�ֹ� ���� �ð� %s ', [ FormatDateTime( 'hh:nn:ss.zzz', Result.SentTime ) ]));
    gEnv.Engine.TradeBroker.Send(aTicket);
  end;

end;

function THultHedgeItem.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
begin
  Result := false;
  if (aAcnt = nil) or ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FAccount  := aAcnt;

  Result := true;
  Reset;
end;

function THultHedgeItem.IsRun: boolean;
begin
  if ( not FRun) or  (FAccount = nil) or ( FSymbol = nil ) or ( not FParam.Run ) then
    Result := false
  else
    Result := true;
end;

procedure THultHedgeItem.NewOrder(iSide: integer; aQuote: TQuote);
var
  aOrder : TOrder;
  aItem : THedgeOrder;
  aList : TList;
  I, iCnt: Integer;
  aSymbol : TSymbol;
  bOrdered: boolean;
begin

  bOrdered  := false;

  if FParam.UseFut then
  begin
    aOrder  := DoOrder( FParam.Qty, iSide, aQuote );
    if aOrder <> nil then
    begin
      aItem := FHedgeOrders.New( aOrder );
      aItem.OrdDir  := iSide;
      aItem.MinPrc  := aQuote.Last;
      aItem.MaxPrc  := aQuote.Last;

      bOrdered  := true;

      DoLog( Format('%d(%d) th �߼� %s %s �ֹ� ����: %.2f, ����: %d  ( �ð�:%.2f > ���簡:%.2f ) ', [
        //FHedgeOrders.Count,
        FEntryCnt, FNo, aQuote.Symbol.ShortCode,
        ifThenStr( iSide > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty,
        FSymbol.DayOpen, aQuote.Last
        ]));
    end;
  end;

  if FParam.UseOpt then
  begin

    {
      ��簡 ������������ ���ĵǾ� ����.. �����ź��� ������
      ǲ�� �����ʱⰪ��  Count-1 , ���� 0 ����..�ϸ��
    }

    try
      aList := TList.Create;
      if iSide > 0 then
      begin
        gEnv.Engine.SymbolCore.GetCurCallList( FParam.dBelow, FParam.dAbove, 10 , aList );

        if FParam.AscIdx = 0 then // �������� : ���� �����ͺ��� �ֹ�
        begin
          iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := 0 to iCnt - 1 do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;
              //
              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th �߼� %s %s �ֹ� ����: %.2f, ����: %d  ( �ð�:%.2f > ���簡:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;

        end
        else begin
          iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          for I := aList.Count-1 downto iCnt do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th �߼� %s %s �ֹ� ����: %.2f, ����: %d  ( �ð�:%.2f > ���簡:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;
        end;
      end
      else begin
        gEnv.Engine.SymbolCore.GetCurPutList( FParam.dBelow, FParam.dAbove, 10 , aList );

        if FParam.AscIdx = 0 then // �������� : ���� �����ͺ��� �ֹ�
        begin
          //iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := 0 to iCnt-1 do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;

              bOrdered  := true;

              DoLog( Format('%d(%d) th �߼� %s %s �ֹ� ����: %.2f, ����: %d  ( �ð�:%.2f > ���簡:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;
        end
        else begin
          iCnt  := Max( 0, aList.Count - FParam.OptCnt  );
          //iCnt  := Min( FParam.OptCnt, aList.Count );
          for I := aList.Count-1 downto iCnt  do
          begin
            aSymbol := TSymbol( aList.Items[i] );
            if aSymbol = nil then Continue;
            aOrder  := DoOrder( FParam.OptQty, 1, aSymbol.Quote as TQuote );

            if aOrder <> nil then
            begin
              aItem := FHedgeOrders.New( aOrder );
              aItem.OrdDir  := iSide;
              aItem.MinPrc  := aQuote.Last;
              aItem.MaxPrc  := aQuote.Last;

              aItem.UseFut    := false;
              aItem.EntryPrc  := aQuote.Last;              

              bOrdered  := true;

              DoLog( Format('%d(%d) th �߼� %s %s �ֹ� ����: %.2f, ����: %d  ( �ð�:%.2f > ���簡:%.2f ) ', [
                //FHedgeOrders.Count,
                FEntryCnt, FNo, aSymbol.ShortCode,
                ifThenStr( iSide > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty,
                FSymbol.DayOpen, aQuote.Last
                ]));
            end;
          end;

        end;
      end;

    finally
      aList.Free;
    end;
  end;

  if bOrdered then
  begin
    FOrdDir := iSide;
    if iSide > 0 then
      FHedgeOrders.OrdCnt[ptLong] := FHedgeOrders.OrdCnt[ptLong] + 1
    else
      FHedgeOrders.OrdCnt[ptShort] := FHedgeOrders.OrdCnt[ptShort] + 1;
  end;
end;

function THultHedgeItem.CheckSide( aQuote : TQuote ) : integer;
var
  dRes : double;
begin
  Result := 0;
  dRes   := aQuote.Last - FSymbol.DayOpen;
  if abs( dRes ) > FParam.E1 then
    if dRes > 0 then
      Result := 1
    else
      Result := -1;
end;

procedure THultHedgeItem.OnQuote(aQuote: TQuote);
var
  iSide : integer;
  aOrder : TOrder;
  aItem : THedgeOrder;
begin
  if not IsRun then Exit;

  if Frac( FParam.StartTime1 ) > Frac( GetQuoteTime ) then Exit;

  try
    if FOrdDir = 0 then
    begin
      iSide := CheckSide( aQuote );
      if iSide <> 0 then
      begin

        if FEntryCnt = 0 then
        begin
          NewOrder( iSide, aQuote );
          inc(FEntryCnt );
        end
        else begin
          // 2��° ������ ù��°�� �ٸ� ���� StartTime2 ���� Ŭ��..
          if ( FEntryCnt = 1) then
            if Frac( FParam.StartTime2 ) < Frac( GetQuoteTime ) then
            begin
              if ( iSide > 0 ) and ( FHedgeOrders.OrdCnt[ptLong] = 0 ) then
              // Entry
                NewOrder( iSide, aQuote )
              else if ( iSide < 0 ) and  ( FHedgeOrders.OrdCnt[ptShort] = 0 ) then
                NewOrder( iSide, aQuote );
            end;
        end;

        {
        if FHedgeOrders.Count = 0 then
        begin
          // Entry
          NewOrder( iSide, aQuote );
        end
        else begin
          // 2��° ������ ù��°�� �ٸ� ���� StartTime2 ���� Ŭ��..
          if ( FHedgeOrders.Count = 1) then
            if Frac( FParam.StartTime2 ) < Frac( GetQuoteTime ) then
            begin
              if ( iSide > 0 ) and ( FHedgeOrders.OrdCnt[ptLong] = 0 ) then
              // Entry
                NewOrder( iSide, aQuote )
              else if ( iSide < 0 ) and  ( FHedgeOrders.OrdCnt[ptShort] = 0 ) then
                NewOrder( iSide, aQuote );
            end;
        end;
        }
      end;
    end
    else begin
      // û��....
      CheckLiquid( aQuote, aQuote.AddTerm );
    end;

  except
  end;
end;

procedure THultHedgeItem.CheckLiquid( aQuote : TQuote; bTerm : boolean );
var
  iCnt, I: Integer;
  aH : THedgeOrder;
begin
  //
  for I := 0 to FHedgeOrders.Count - 1 do
  begin
    aH  := FHedgeOrders.Ordered[i];
    if aH.LiqOrder <> nil then Continue;

    if aH.Order.State = osFilled then
      CheckLiquid2( aH, aQuote, bTerm );
  end;

  // �ɼ��� �߰��Ʊ� ������..û������� �˸��� ���� �߰�.
  iCnt := 0;
  for i := 0 to FhedgeOrders.Count - 1 do
  begin
    aH  := FHedgeOrders.Ordered[i];
    if aH.LiqOrder <> nil then
      inc( iCnt );
  end;

  if (EntryCnt > 0 ) and ( FHedgeOrders.Count > 0 ) and ( FHedgeOrders.Count = iCnt ) then
  begin
    FOrdDir := 0;
    DoLog( Format('��� û��� -> %d, %d, %d', [ EntryCnt, FHedgeOrders.Count , iCnt ]));
  end;

end;

  // û�� ����
  // ���� û��
  // 1. ���� ��� L1 �̻� ���̳���
  // 2. 1.8 P  ������ û��
  // 3. 3�ÿ� û��
  // ����
  // 1. 1��������..�ð����� ���ų� ������ û��
  // 2. ���� ���ݰ� ����. 0.8 ���̳���
function THultHedgeItem.CheckLiquid2( aH : THedgeOrder; aQuote : TQuote; bTerm : boolean ) : boolean;
var
  dGap, dGap2 : double;
  aTerm :TSTermItem;
  aOrder: TOrder;
begin
  if Frac( FParam.EndTime ) < Frac( GetQuoteTime ) then
    Result := true
  else begin

    Result := false;

    aH.MinPrc := Min( aH.MinPrc, aQuote.Last );
    aH.MaxPrc := Max( aH.MaxPrc, aQuote.Last );

    dGap := 0;
    // �ż��϶� ----------------------------------------------------------------
    if aH.OrdDir > 0 then
    begin
      // ����
      if FSymbol.DayOpen < aQuote.Last then
      begin
        dGap  := aH.MaxPrc - aQuote.Last;
        // 1�� ����
        if dGap > FParam.L1 then begin
          // ������� FParam.L1 �����Դ�
          // ������ �ּ� FParam.ConPlus ��ŭ �ö󰡾� �Ѵ�.
          if ( FSymbol.DayOpen + FParam.ConPlus + FParam.E1 ) <= aH.MaxPrc  then
          begin
            Result := true;
            DoLog( Format('�ż� ���� û�� ->  ���� %.2f ��� ���簡 %.2f  %.2f(%.2f) ����Ʈ �϶�',  [
              aH.MaxPrc, aQuote.Last, dGap, FParam.L1    ]));
          end;
        end;
        // 2�� ����
        if (not Result)  then
        begin
          //dGap  := aQuote.Last - ( FSymbol.DayOpen + FParam.E1 );
          if aH.UseFut then          
            dGap  := aQuote.Last - aH.Order.FilledPrice
          else
            dGap  := aQuote.Last - aH.EntryPrc;    // �ɼ��϶�..

          if dGap > FParam.L2 then begin
            Result := true;

            if aH.UseFut then            
              DoLog( Format('�ż� ���� û�� ->  ���԰� %.2f ���� ���� ���簡 %.2f  %.2f(%.2f) ����Ʈ ���',  [
                aH.Order.FilledPrice, aQuote.Last, dGap, FParam.L2    ]))
            else
              DoLog( Format('�ż� ���� û�� ->  ���԰� %.2f ���� ���� ���簡 %.2f  %.2f(%.2f) ����Ʈ ���',  [
                aH.EntryPrc, aQuote.Last, dGap, FParam.L2    ]))
          end;
        end;
      end
      else begin
      // ����
        if bTerm then
        begin
          aTerm := aQuote.Terms.XTerms[ aQuote.Terms.Count -2 ];
          if aTerm <> nil then
            if aTerm.C < FSymbol.DayOpen then
            begin
              Result := True;
              DoLog( Format('�ż� ���� -> �ð� %.2f ���� ���� 1�� ���� %.2f( c: %.2f)  ', [
                FSymbol.DayOpen, aTerm.C, aQuote.Last ]));
            end;
        end;

        if not Result then
        begin
          dGap  := (FSymbol.DayOpen + FParam.E1 ) - aQuote.Last;
          if dGap > FParam.LC then
          begin
            Result := true;
            DoLog( Format('�ż� ���� -> ���� %.2f ���� ���簡 %.2f , %.2f(%.2f) ����Ʈ  ���� ', [
                FSymbol.DayOpen + FParam.E1,aQuote.Last, dGap, FParam.LC ]));
          end;
        end;
      end;
    end
    else begin
    // �ŵ��϶� ----------------------------------------------------------------
      // ����
      if FSymbol.DayOpen > aQuote.Last then
      begin
        dGap  := aQuote.Last - aH.MinPrc;
        // 1�� ����
        if dGap > FParam.L1 then begin
          // ���� ��� FParam.L1 �ö�Դ�
          if ( FSymbol.DayOpen - FParam.ConPlus - FParam.E1 ) >= aH.MinPrc then
          begin
            Result := true;
            DoLog( Format('�ŵ� ���� û�� ->  ���� %.2f ��� ���簡 %.2f  %.2f(%.2f) ����Ʈ ���',  [
              aH.MinPrc, aQuote.Last, dGap, FParam.L1    ]));
          end;
        end;
        // 2�� ����
        if (not Result)  then
        begin
          //dGap  := (FSymbol.DayOpen - FParam.E1) -aQuote.Last;
          if aH.UseFut then          
            dGap  := aH.Order.FilledPrice -aQuote.Last
          else
            dGap  := aH.EntryPrc - aQuote.Last;

          if dGap > FParam.L2 then begin
            Result := true;
            if aH.UseFut then            
              DoLog( Format('�ŵ� ���� û�� ->  ���԰� %.2f ���� ���� ���簡 %.2f  %.2f(%.2f) ����Ʈ �϶�',  [
                aH.Order.FilledPrice, aQuote.Last, dGap, FParam.L2    ]))
            else
              DoLog( Format('�ŵ� ���� û�� ->  ���԰� %.2f ���� ���� ���簡 %.2f  %.2f(%.2f) ����Ʈ �϶�',  [
                aH.EntryPrc, aQuote.Last, dGap, FParam.L2    ]))

          end;
        end;
      end
      else begin
      // ����
        if bTerm then
        begin
          aTerm := aQuote.Terms.XTerms[ aQuote.Terms.Count -2 ];
          if aTerm <> nil then
            if aTerm.C > FSymbol.DayOpen then
            begin
              Result := True;
              DoLog( Format('�ŵ� ���� -> �ð� %.2f ���� ���� 1�� ���� %.2f( c: %.2f)  ', [
                FSymbol.DayOpen, aTerm.C, aQuote.Last ]));
            end;
        end;

        if not Result then
        begin
          dGap  := aQuote.Last - (FSymbol.DayOpen - FParam.E1 );
          if dGap > FParam.LC then
          begin
            Result := true;
            DoLog( Format('���� ���� -> ���� %.2f ���� ���簡 %.2f , %.2f(%.2f) ����Ʈ  ��� ', [
                FSymbol.DayOpen - FParam.E1,aQuote.Last, dGap, FParam.LC ]))
          end;
        end;
      end;
    end;
  end;

  if Result then
  begin
    aOrder  := DoOrder( aH.Order.FilledQty, -aH.Order.Side, aH.Order.Symbol.Quote as TQuote );
    if aOrder <> nil then
    begin
      DoLog( Format('%s %s û�� ����: %.2f, ����: %d ', [  aOrder.Symbol.ShortCode,
        ifThenStr( aOrder.Side > 0, '�ż�','�ŵ�'), aOrder.Price, aOrder.OrderQty  ]));
      aH.OrdDir := 0;
      aH.LiqOrder := aOrder;
    end;
  end;
end;

procedure THultHedgeItem.Reset;
begin
  FOrdDir := 0;
  FHedgeOrders.Clear;
end;

function THultHedgeItem.Start: boolean;
begin
  Result := IsRun;

  if ( Symbol = nil ) or ( Account = nil ) then Exit;
  FRun  := true;

  DoLog( format('%d Hult Hedge start ', [ FNo ]) );

end;

procedure THultHedgeItem.Stop;
begin
  FRun  := false;

  DoLog( format('%d Hult Hedge Stop ', [ FNo ]) );
end;

{ THedgeOrder }

constructor THedgeOrder.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Order   := nil;
  LiqOrder:= nil;
  OrdDir  := 0;
  ManualQty := 0;
  EntryPrc  := 0;
  UseFut    := true;
end;

{ THedgeOrders }

constructor THedgeOrders.Create;
begin
  inherited Create(  THedgeOrder );

  OrdCnt[ptLong]  := 0;
  OrdCnt[ptShort] := 0;

  OptOrdCnt[ptLong]  := 0;
  OptOrdCnt[ptShort] := 0;

end;

procedure THedgeOrders.Del(aOrder: TOrder);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetOrdered(i).Order = aOrder then
    begin
      Delete(i);
      break;
    end;
end;

destructor THedgeOrders.Destroy;
begin

  inherited;
end;

function THedgeOrders.GetOrdered(i: Integer): THedgeOrder;
begin
  if (i<0) or ( i>= Count) then
    Result := nil
  else
    Result := Items[i] as THedgeOrder;
end;

function THedgeOrders.IsOrder(iSide: integer): boolean;
begin
  if Count = 0 then
    Result := true
  else begin

  end;
end;

function THedgeOrders.New(aOrder: TOrder): THedgeOrder;
begin
  Result := Add as THedgeOrder;
  Result.Order  := aOrder;
  //Result.Symbol := aOrder.Symbol;
end;

{ THultHedgeItems }

constructor THultHedgeItems.Create;
begin
  inherited Create( THultHedgeItem );
  FSymbol := nil;
  FAccount:= nil;
end;

destructor THultHedgeItems.Destroy;
begin

  inherited;
end;

function THultHedgeItems.GetHedgeItem(i: Integer): THultHedgeItem;
begin
  if (i<0) or ( i>=Count )  then
    Result := nil
  else
    Result := Items[i] as THultHedgeItem;
end;

function THultHedgeItems.init(aAcnt: TAccount; aSymbol: TSymbol): boolean;
var
  i : integer;
begin
  for I := 0 to Count - 1 do
    GetHedgeItem(i).init( aAcnt, aSymbol );

  FSymbol := aSymbol;
  FAccount:= aAcnt;
end;

function THultHedgeItems.New(iNo: integer): THultHedgeItem;
begin
  Result := Add as THultHedgeItem;
  Result.No := Count;
end;

procedure THultHedgeItems.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  I: Integer;
begin
  if (Receiver <> Self ) or ( DataObj = nil ) then Exit;
  
  for I := 0 to Count - 1 do
    GetHedgeItem(i).OnQuote( DataObj as TQuote);
end;

function THultHedgeItems.Start: boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Result := GetHedgeItem(i).Start;

  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuotePrc );
  gEnv.Engine.TradeBroker.Subscribe( Self, TradePrc );
end;

procedure THultHedgeItems.Stop;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    GetHedgeItem(i).Stop;

  gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure THultHedgeItems.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin

end;

end.