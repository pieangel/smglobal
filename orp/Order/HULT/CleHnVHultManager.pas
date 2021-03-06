unit CleHnVHultManager;

interface

uses
  Classes, SysUtils, Forms,

  CleAccounts, ClePositions, CleSymbols, CleQuoteBroker, CleQuoteTimers,

  GleTypes

  ;

type

  THnVHultState = (hvNone, hvRun, hvStop, hvLiquid, hvHalfLiq );
    // tType 을 hvState 상타로 만들기 위해
  THnVHultEvent = procedure( Sender : TObject; tType : TStrategyType;  hvState : THnVHultState ) of object;

  THnVHultItem  = class( TCollectionItem )
  public
    Account   : TAccount;
    Symbol    : TSymbol;
    Position  : TPosition;
    StgType   : TStrategyType;
    HvState   : THnVHultState;
    Target    : THnVHultItem;
    OnHnVHultEvent : THnVHultEvent;
    //
    RiskAmt   : double;
    CondAmt    : double;
    TotAmt    : double;
    // log 용
    MaxPL , MinPL : double;
    MaxTm , MInTm : TDateTime;

    //
    HalfLc : boolean;


    Constructor Create( aColl : TCollection ) ; override;
    procedure init( aState : THnVHultState; bFindPair : boolean = false );
    function GetString : string;

    function GetStg : string;
    function GetHnVH: string;

    procedure OnState( aState : THnVHultState );
    procedure WriteData;
  end;

  THnVHults = class( TCollection )
  private
    FWrited: boolean;
    FTimer : TQuoteTimer;
    FUnList : TList;

    TotPL, MaxPL , MinPL : double;
    MaxTm , MInTm : TDateTime;
    FLogNum: integer;

    function GetHnVHult(i: integer): THnVHultItem;

    procedure CheckProcedure( aItem : THnVHultItem);
    procedure FindPair(aItem: THnVHultItem; tgType: TStrategyType);
    procedure WriteLog;
    procedure WirteData( dPL : double );
    function FindNextPosNew( aAccount : TAccount ): THnVHultItem;
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( tgType : TStrategyType; aAccount : TAccount; aSymbol : TSymbol ) : THnVHultItem;
    function Find(tgType : TStrategyType; aAccount : TAccount; aSymbol : TSymbol ) : THnVHultItem;

    procedure OnQuote( aQuote : TQuote; iType : integer = 0 );
    procedure Liquid(aItem: THnVHultItem; tgType: TStrategyType);
    procedure Reset;

    procedure DeleteItem( aItem : THnVHultItem );
    procedure OnHnVHTimer( Sender : TObject );
    procedure init;

    property HnVHult[ i : integer ] : THnVHultItem read GetHnVHult; default;
    property LogNum : integer read FLogNum write FLogNum;
  end;

  THnVHultGather = class( TCollectionItem )
  private

    FNumber: integer;
    procedure SetNumber(const Value: integer);
  public
    HnVHults: THnVHults;
    constructor Create(Coll: TCollection); override;
    destructor Destroy; override;

    property Number : integer read FNumber write SetNumber;
  end;

  THnVHultManager = class( TCollection )
  private
    FVHultLc: boolean;
    FHultLc: boolean;
    FHControl: boolean;
    FVHnHultLc: boolean;

    FTimer : TQuoteTimer;

    FSameHnVHultLc: boolean;
    FTotPLLC: boolean;
    FVHHalfLc: boolean;
    function GetHnVHults(i: integer): THnVHultGather;

  public
    Constructor Create;
    Destructor  Destroy; override;

    procedure OnHnVHTimer( Sender : TObject );
    procedure init;
    procedure Reset;

    function NewItem( iNum : integer ) : THnVHultGather;
    function FindItem( iNum : integer ) : THnVHultGather;

    function New( iNum : integer; tgType : TStrategyType; aAccount : TAccount; aSymbol : TSymbol ) : THnVHultItem;
    function Find(iNum : integer; tgType : TStrategyType; aAccount : TAccount; aSymbol : TSymbol ) : THnVHultItem;

    procedure Liquid( iNum : integer; aItem: THnVHultItem; tgType: TStrategyType);
    procedure DeleteItem( iNum : integer; aItem : THnVHultItem );

    procedure OnQuote( aQuote : TQuote; iType : integer = 0 );

    property HnVHults[ i : integer] :  THnVHultGather read GetHnVHults; default;

    property HControl: boolean read FHControl write FHControl;
    property VHultLc : boolean read FVHultLc write FVHultLc;
    property HultLc : boolean read FHultLc write FHultLc;
    property VHnHultLc : boolean read FVHnHultLc write FVHnHultLc;
    property SameHnVHultLc : boolean read FSameHnVHultLc write FSameHnVHultLc;
    property VHHalfLc : boolean read FVHHalfLc write FVHHalfLc;
    property TotPLLC  : boolean read FTotPLLC write FTotPLLc;
  end;

   procedure DoLog( strLog : string );

implementation

uses
  GAppEnv;

{ THnVHultItem }

constructor THnVHultItem.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  Account   := nil;
  Symbol    := nil;
  Position  := nil;
  HvState   := hvNone;
  StgType   := stNormal;
  OnHnVHultEvent  := nil;

  Target := nil;
  HalfLc := false;

  TotAmt  := 0;

  MaxPL := 0; MinPL := 0;
  MaxTm := 0; MInTm := 0;
end;

function THnVHultItem.GetHnVH: string;
begin
  case HvState of
    hvNone: Result := 'None' ;
    hvRun: Result := 'Run';
    hvStop: Result := 'Stop';
    hvLiquid: Result := 'Liquid';
  end;
end;

function THnVHultItem.GetStg: string;
begin
  case StgType of
    stNormal: Result := 'Normal';
    stHult: Result := 'Hult';
    stBHultOpt: Result := 'VanHult' ;
    else Result := ' No ';
  end;
end;

function THnVHultItem.GetString: string;
begin
  if ( Account = nil ) or ( Symbol = nil ) then
    Result  := 'No Data'
  else
    Result  := Format('%s, %s, %s, %s', [ Account.Code, Symbol.ShortCode, GetStg, GetHnVH ] );
end;

procedure THnVHultItem.init( aState: THnVHultState; bFindPair : boolean );
begin
  HvState   := hvRun;
  Position  := gEnv.Engine.TradeCore.Positions.FindOrNew( Account, Symbol );
  if bFindPair then
    (Collection as  THnVHults).FindPair( Self, stHult );
end;

procedure THnVHultItem.OnState(aState: THnVHultState);
begin
  HvState := aState;
//  DoLog( 'ChangeState : ' + GetString );

  //if Assigned( OnHnVHultEvent ) then
  //  OnHnVHultEvent( Self, HvState );
end;

procedure THnVHultItem.WriteData;
var
  dPL : double;
  dtTime : TDateTime;
begin

  dPL := Position.LastPL;

  if MaxPL < dPL then
  begin
    MaxPL  := dPL;
    MaxTm  := GetQuoteTime;
  end;

  if MinPL > dPL then
  begin
    MinPL := dPL;
    MinTm := GetQuoteTime;
  end;

end;

{ THnVHultManager }


constructor THnVHultManager.Create;
begin
  inherited Create( THnVHultGather );

  Reset;
end;

procedure THnVHultManager.DeleteItem(iNum: integer; aItem: THnVHultItem);
  var
    aGather : THnVHultGather  ;
begin
  aGather := FindItem(iNum) ;
  if aGather <> nil then
    aGather.HnVHults.DeleteItem( aItem  );
end;

destructor THnVHultManager.Destroy;
begin
  FTimer.Enabled := false;

end;



procedure DoLog(strLog: string);
begin
  gEnv.EnvLog( WIN_TEST, strLog );
  if gEnv.HnVH <> nil then
    gEnv.HnVH.AddLog( strLog );
end;

procedure THnVHultManager.init;
begin
  FTimer := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled  := false;
  FTimer.Interval := 100;
  FTimer.OnTimer  := OnHnVHTimer;
end;


procedure THnVHultManager.Liquid(iNum: integer; aItem: THnVHultItem;
  tgType: TStrategyType);
  var
    aGather : THnVHultGather  ;
begin
  aGather := FindItem(iNum) ;
  if aGather <> nil then
    aGather.HnVHults.Liquid( aItem, tgType );

end;

function THnVHultManager.Find(iNum : integer; tgType: TStrategyType; aAccount: TAccount;
  aSymbol: TSymbol): THnVHultItem;
  var
    aGather : THnVHultGather  ;
begin
  aGather := FindItem(iNum) ;
  if aGather <> nil then
    aGather.HnVHults.Find( tgType, aAccount, aSymbol );
end;

function THnVHultManager.FindItem(iNum: integer): THnVHultGather;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if GetHnVHults(i).Number = iNum then
    begin
      Result := GetHnVHults(i);
      break;
    end;
end;

function THnVHultManager.GetHnVHults(i: integer): THnVHultGather;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    REsult := Items[i] as THnVHultGather;
end;

function THnVHultManager.New(iNum : integer; tgType: TStrategyType; aAccount: TAccount;
  aSymbol: TSymbol): THnVHultItem;
begin
  Result := NewItem( iNum ).HnVHults.New( tgType, aAccount, aSymbol );
end;

function THnVHultManager.NewItem(iNum: integer): THnVHultGather;
begin
  Result := FindItem( iNum );
  if Result = nil then
  begin
    Result := Add as THnVHultGather;
    Result.Number := iNum;
  end;
end;


procedure THnVHultManager.OnHnVHTimer(Sender: TObject);
var
  I: Integer;
  aItem : THnVHultItem;
begin
{
  for i:= FUnList.Count - 1 downto 0 do
  begin
    aItem := THnVHultITem( FUnList.Items[i] );
    if aItem <> nil then
      if Assigned( aItem.OnHnVHultEvent ) and ( aItem.Position.Volume <> 0 ) then
      begin
        aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );
        DoLog( Format('미처리규 처리 -> %s(%.0f)', [ aItem.GetString, aItem.Position.LastPL / 1000.0 ]));
        FUnList.Delete(i);
      end;
  end;
  }

end;

procedure THnVHultManager.OnQuote(aQuote: TQuote; iType: integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if GetHnVHults(i) <> nil then
      GetHnVHults(i).HnVHults.OnQuote( aQuote, iType );
end;

procedure THnVHultManager.Reset;
begin
  Clear;
  FVHultLC  := true; 
end;

{ THnVHults }


constructor THnVHults.Create;
begin
  inherited Create( THnVHultItem );
  FUnList := TList.Create;
  Reset;
end;

procedure THnVHults.DeleteItem(aItem: THnVHultItem);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (Items[i] as THnVHultItem) = aItem then
    begin
      Delete(i);
      break;
    end;
  end;

end;

destructor THnVHults.Destroy;
begin

  inherited;
end;

function THnVHults.Find(tgType: TStrategyType; aAccount: TAccount;
  aSymbol: TSymbol): THnVHultItem;
var
  I: Integer;
begin
  Result  := nil;

  for I := 0 to Count - 1 do
    if ( GetHnVHult(i).StgType = tgType ) and ( GetHnVHult(i).Account = aAccount ) and
      ( GetHnVHult(i).Symbol = aSymbol )  then
    begin
      Result := GetHnVHult(i);
      break;
    end;

end;

function THnVHults.FindNextPosNew(aAccount: TAccount): THnVHultItem;
var
  I: Integer;
  aItem : THnVHultItem;
  bAdd : boolean;
begin
  if Count = 0 then begin
    Result := Add as THnVHultItem;
    Exit;
  end;

  bAdd := false;
  for I := 0 to Count - 1 do
  begin
    aItem := GetHnVHult(i);
    if aAccount.LogIdx < aItem.Account.LogIdx then
    begin
      Result := Insert(i) as THnVHultItem;
      bAdd := true;
      break;
    end;
  end;

  if not bAdd then
    Result := Add as THnVHultItem;


end;

procedure THnVHults.FindPair(aItem: THnVHultItem; tgType: TStrategyType);
var
  dPL, dGap : double;
  i, iTarget, iOwn : integer;
  pItem, tgItem : THnVHultItem ;
begin
  // Hult 손익이 젤 큰거부터 스탑시킨다.
  if aItem = nil then Exit;

  dPL := 0; dGap := 0; tgItem := nil;
  iTarget := -1; iOwn := -1;

  for I := 0 to Count - 1 do
  begin
    pItem := GetHnVHult(i);
    if ( pItem = nil ) then Continue;
    if pItem.Position = nil then Continue;
    if pItem = aItem then iOwn := i;
       // 헐트이면서 동작중인거 상태인것중에서
       // -> 헐트이면서 페어가 없는거 중에서. 반헐트가 나가기전 손절날수도 있으므로...
    if (pItem.StgType = tgType) {and ( pItem.HvState = hvRun )} and
       (pItem.Target = nil ) then
    begin
      dPL :=  pItem.Position.LastPL ;
      if dPL < dGap then
      begin
        dGap    := dPL;
        tgItem  := GetHnVHult(i);
        iTarget := i;
      end;
    end;
  end;

  if (tgItem <> nil) and ( iTarget >= 0) and ( iOwn >= 0) then
  begin
    tgItem.Target     := aItem;
    aItem.Target      := tgItem;
    //tgItem.TargetIdx  := iOwn;
    //aItem.TargetIdx   := iTarget;
    DoLog(format(
      'Pair -> %s(%.0f)  , %s(%.0f)', [aItem.GetString, aItem.Position.LastPL,
         tgItem.GetString, tgItem.Position.LastPL ])      );

  end;

end;

function THnVHults.GetHnVHult(i: integer): THnVHultItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as THnVHultItem;
end;

procedure THnVHults.init;
begin

end;

procedure THnVHults.Liquid(aItem: THnVHultItem; tgType: TStrategyType);
var
  tItem : THnVHultItem;
begin

  if aItem = nil  then Exit;
  tItem := aItem.Target; //GetHnVHult( aItem.TargetIdx );
  if ( tItem = nil ) or ( tItem.HvState = hvLiquid )  then  Exit;

  if Assigned( tItem.OnHnVHultEvent ) then
    try
      tItem.OnHnVHultEvent( tItem, tItem.StgType, hvLiquid );
      DoLog( format(
        '반헐트 청산으로 인한 헐트 손절 ->(%.0f)  %s(%.0f) ', [ aItem.Position.LastPL,
          tItem.GetString,  tItem.Position.LastPL / 1000.0  ])
      );
    except
    end;

end;

function THnVHults.New(tgType: TStrategyType; aAccount: TAccount;
  aSymbol: TSymbol): THnVHultItem;
  var
    i : integer;

begin
  Result  := Find( tgType, aAccount, aSymbol );

  if Result = nil then
  begin

    Result := FindNextPosNew( aAccount );//Add as THnVHultItem;
    Result.StgType    := tgType;
    Result.Account    := aAccount;
    Result.Symbol     := aSymbol;
    for I := 0 to Count - 1 do
      gEnv.EnvLog( WIN_TEST, IntToStr(i) + ' : ' + GetHnVHult(i).Account.Code );

  end;

end;

procedure THnVHults.OnHnVHTimer(Sender: TObject);
begin

end;

procedure THnVHults.OnQuote(aQuote: TQuote; iType: integer);
var
  aItem : THnVHultItem;
  I: Integer;
  dPL : double;
begin
  if iType = 300 then
    WriteLog;

  dPL := 0;
  for I := 0 to Count - 1 do
  begin
    aItem := GetHnVHult(i);
    if aItem = nil then Continue;
    if aItem.Symbol = aQuote.Symbol then
      CheckProcedure( aItem );
    aItem.WriteData;
    dPL := dPL + aItem.Position.LastPL;
  end;

  WirteData( dPL );

end;

procedure THnVHults.Reset;
begin
  TotPL := 0; MaxPL := 0;  MinPL := 0;
  MaxTm := 0; MInTm := 0;
  FWrited := false;

  FUnList.Clear;
end;

procedure THnVHults.WirteData(dPL: double);
begin
  if MaxPL < dPL then
  begin
    MaxPL  := dPL;
    MaxTm  := GetQuoteTime;
  end;

  if MinPL > dPL then
  begin
    MinPL := dPL;
    MinTm := GetQuoteTime;
  end;

  TotPL := dPL;
end;

procedure THnVHults.WriteLog;
var
  stData, st1 : string;
  i : integer;
  aItem : THnVHultItem;
begin

  if FWrited then Exit;

  stData := '';

  st1 := Format(',%.0f, %.0f, %.0f, %s, %s,', [
      TotPL / 1000.0 , MaxPL/ 1000.0, MinPL/ 1000.0,
      FormatDateTime('hh:nn:ss', MaxTm ), FormatDateTime('hh:nn:ss', MInTm ) ] );

  for I := 0 to Count - 1 do
  begin
    aItem := GetHnVHult(i);
    if ( aItem = nil ) or ( aItem.Position = nil ) then  Continue;

    stData := stData + Format(',%.0f, %.0f, %.0f, %s, %s,', [
      aItem.Position.LastPL/ 1000.0, aItem.MaxPL/ 1000.0, aItem.MinPL/ 1000.0,
      FormatDateTime('hh:nn:ss', aItem.MaxTm ), FormatDateTime('hh:nn:ss', aItem.MInTm ) ] );
  end;

  if stData <> '' then
  begin
    stData  := FormatDateTime('yy-mm-dd', gEnv.AppDate ) + st1 + stData;
    gEnv.EnvLog( WIN_TEST, stData, true, IntToStr( FLogNum ) + '_HnVHult_'+ FormatDateTime('yyyy-mm-dd', date )+'.csv');

    FWrited := true;
  end;
end;


procedure THnVHults.CheckProcedure(aItem: THnVHultItem);
var
  tItem : THnVHultItem;
begin
 // if aItem.TargetIdx < 0 then Exit;

  case aItem.StgType of
    stHult:
      begin
        tItem :=  aItem.Target;// GetHnVHult( aItem.TargetIdx );
        //if (tItem = nil) or ( tItem.StgType <> stBHultOpt ) then Exit;

        // 헐트 손절..............................
        if ( aItem.Position.LastPL <= (aItem.RiskAmt * -10000 )) and ( aItem.HvState <> hvLiquid ) then
        begin

          if tItem = nil then
          begin
            //반헐트가 드가지도 않았는데..손절 난 경우....
            if Assigned( aItem.OnHnVHultEvent )  and (  gEnv.Engine.TradeCore.HnVHults.HultLc ) then
              try
                aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );
                DoLog( format(
                  '헐트만  손절 -> %s(%.0f) ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0  ])
                );
              except
              end;

          end
          else begin
            // 반헐트가 먼저 청산 된경우는....헐트는 300 에 손절
            if tItem.HvState = hvLiquid  then
            begin
              if Assigned( aItem.OnHnVHultEvent ) then
                try
                  aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );
                  DoLog( format(
                    '헐트 손절 -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                    tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                  );
                except
                end;
            end else
            if ( tItem.HvState = hvRun ) and ( gEnv.Engine.TradeCore.HnVHults.HultLC )  then
            begin
            // 반헐트가 살아 있는 경우..
              if Assigned( aItem.OnHnVHultEvent ) then
                try
                  aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );

                  if Assigned( tItem.OnHnVHultEvent ) then
                    if ( tItem.Position.Volume = 0 ) then
                    begin
                      FUnList.Add( tItem );
                      DoLog( Format('반헐트 청산 큐 Add : %s(%.0f)', [ tItem.GetString, tItem.Position.LastPL / 1000.0 ]));
                    end
                    else
                      tItem.OnHnVHultEvent( tItem, tItem.StgType, hvLiquid );

                DoLog( format(
                  '헐트 손절로 모두 청산 -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
                except
                end;
            end else
            if ( tItem.HvState = hvRun ) and ( gEnv.Engine.TradeCore.HnVHults.VHHalfLc ) and
             ( not tItem.HalfLc )  then
            begin
              // 헐트는 손절안하고..반헐트만 절반 청산
              if Assigned( tItem.OnHnVHultEvent ) then
              begin
                tItem.OnHnVHultEvent( tItem, tItem.StgType, hvHalfLiq );
                DoLog( format(
                  '반헐트 반청산  -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ]));

              end;
            end;


          end;    // if tItem <> nil
        end;   // if ( aItem.Position.LastPL <= (aItem.RiskAmt * -10000 )) and ( aItem.HvState <> hvLiquid ) then

      end;
    stBHultOpt:
      begin
        tItem := aItem.Target;// GetHnVHult( aItem.TargetIdx );
        if (tItem = nil) or ( tItem.StgType <> stHult ) then Exit;

        // 헐트 + 반헐트 > TotAmt 일때 모두 청산
        if ( aItem.HvState = hvRun ) and ( gEnv.Engine.TradeCore.HnVHults.TotPLLc ) then
          if  ( aItem.Position.LastPL + tItem.Position.LastPL ) > (aItem.TotAmt * 10000 ) then
          begin
            if Assigned( aItem.OnHnVHultEvent ) then
            begin
              try
                aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );
                DoLog( format(
                  'Van Hult Liquid -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
              except
              end;
            end;

            if (tItem.HvState <> hvLiquid ) and Assigned( tItem.OnHnVHultEvent ) then
            begin
              try
                tItem.OnHnVHultEvent( tItem, tItem.StgType, hvLiquid );
                DoLog( format(
                  'Hult Stop -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
              except
              end;
            end;

            DoLog( Format(' 이익청산 -> H:%.0f + v:%.0f = T: %.0f ', [ tItem.Position.LastPL,
              aItem.Position.LastPL, ( aItem.Position.LastPL + tItem.Position.LastPL ) ]));
          end;

        // 헐트 Stop 시킨다..
        if ( aItem.HvState = hvRun ) and ( tItem.HvState = hvRun )  then
          if  aItem.Position.LastPL > (aItem.CondAmt * 10000 ) then
          begin
            if Assigned( tItem.OnHnVHultEvent ) then
            begin
              try
                tItem.OnHnVHultEvent( tItem, tItem.StgType, hvStop );
                DoLog( format(
                  'Hult Stop -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
              except
              end;
            end;
          end;

        // 반헐트 손절 시키고 헐트 한도를 -300 으로 바꾼다.
        if (aItem.HvState = hvRun ) and ( aItem.Position.LastPL <= (aItem.RiskAmt * -10000) ) and
          ( gEnv.Engine.TradeCore.HnVHults.VHultLC ) then
        begin
            if Assigned( aItem.OnHnVHultEvent ) then
            begin
              try
                aItem.OnHnVHultEvent( aItem, aItem.StgType, hvLiquid );
                DoLog( format(
                  'Van Hult Liquid -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
                //tItem.RiskAmt := 300;//aItem.CondAmt;
              except
              end;
            end;

            if (tItem.HvState <> hvLiquid ) and Assigned( tItem.OnHnVHultEvent ) and
              ( gEnv.Engine.TradeCore.HnVHults.SameHnVHultLc ) then
            begin
              try
                tItem.OnHnVHultEvent( tItem, tItem.StgType, hvLiquid );
                DoLog( format(
                  'Hult Liquid -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
              except
              end;
            end;

        end;

        // 헐트  Re Stop 시킨다..
        if (aItem.HvState = hvRun ) and ( tItem.HvState = hvStop ) and
          ( gEnv.Engine.TradeCore.HnVHults.HControl ) then
        begin
          if aItem.Position.LastPL < ( aItem.CondAmt * -10000 ) then
            if Assigned( tItem.OnHnVHultEvent ) then
            begin
              try
                tItem.OnHnVHultEvent( tItem, tItem.StgType, hvRun );
                DoLog( format(
                  'Hult Re Start -> %s(%.0f) %s(%.0f)  ', [ aItem.GetString,  aItem.Position.LastPL / 1000.0,
                  tItem.GetString, tItem.Position.LastPL / 1000.0 ])
                );
              except
              end;
            end;
        end;

      end;
    else Exit;
  end;
end;

{ THnVHultGather }

constructor THnVHultGather.Create(Coll: TCollection);
begin
  inherited Create( Coll );
  HnVHults:= THnVHults.Create;
  FNumber := -1;
end;

destructor THnVHultGather.Destroy;
begin
  HnvHults.Free;
  inherited;
end;

procedure THnVHultGather.SetNumber(const Value: integer);
begin
  HnVHults.LogNum := Value;
  FNumber := Value;
end;

end.
