unit CleDistributor;

// This class is used to distribute an event to subscribing client objects.
// The keys for subscription are 'Subscriber', 'DataID', 'DataObj'.

interface

uses
  Classes, GleTypes, SysUtils, DateUtils,

  GleLib, CleQuoteTimers, GleConsts;

  {$INCLUDE define.txt}

type
  TDistributorID = 0..255;
  TDistributorIDs = set of TDistributorID;

const
  ANY_EVENT: TDistributorIDs = [];
  //
  MARKET_KEY   = 254;

  ANY_OBJECT: TObject = nil;

  DISTRIBUTE_CAP = 8;

type
  TDistributorEvent = procedure(Sender, Receiver: TObject; DataID: Integer;
    DataObj: TObject; EventID: TDistributorID) of object;

  TDistributorItem = class(TCollectionItem)
  private
    FSubscriber: TObject;
    FDataID: Integer;
    FDataObj: TObject;
    FEventIDs: TDistributorIDs;
    FHandler: TDistributorEvent;
    FPriorityType: TSubscribePriority;
    FLastSendTime: TDateTime;
  public
    property Subscriber: TObject read FSubscriber;
    property DataID: Integer read FDataID;
    property DataObj: TObject read FDataObj;
    property EventIDs: TDistributorIDs read FEventIDs write FEventIDs;
    property Handler: TDistributorEvent read FHandler;
    property PriortyType : TSubscribePriority read FPriorityType write FPriorityType;
    property LastSendTime : TDateTime read FLastSendTime write FLastSendTime;
  end;

  TDistributor = class(TCollection)
  private
    FTimer : TQuoteTimer;
    function NormalInsert(spType: TSubscribePriority): TDistributorItem;
  public
    constructor Create;

    function Subscribe(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      EventIDs: TDistributorIDs; aHandler: TDistributorEvent; spType : TSubscribePriority = spHighest): TDistributorItem;

    function Find(aSubscriber: TObject; iDataID: Integer;
      aDataObj: TObject): TDistributorItem;
    function Distribute(aSender: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID; iFlag : integer = 0): Integer;

    function Distribute2(aSender: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID): Integer;

    function Deliver(aSender, aReceiver: TObject; iDataID: Integer;
      aDataObj: TObject; anEventID: TDistributorID): Boolean;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject;
      anEventID: TDistributorID); overload;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer; aDataObj: TObject); overload;
    procedure Cancel(aSubscriber: TObject; iDataID: Integer); overload;
    procedure Cancel(aSubscriber: TObject); overload;

    //procedure TimerTimer(Sender: TObject);
  end;

implementation

uses GAppEnv, CleQuoteBroker, ClePrograms, ClePositions, CleOrders, CleFills
  ;

{ TDistributor }

constructor TDistributor.Create;
begin
  inherited Create(TDistributorItem);
end;

//------------------------------------------------------------< subscription >

function TDistributor.NormalInsert( spType : TSubscribePriority ) : TDistributorItem;
var
  i, j :integer;
  bFind : boolean;
begin
  Result := nil;
  bFind  := false;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if FPriorityType >= spType then
      begin
        bFind := true;
        break;
      end;

  if not bFind then
    Result := Add as TDistributorItem
  else
    Result := Insert(i) as TDistributorItem;

end;

function TDistributor.Subscribe(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject; EventIDs: TDistributorIDs;
  aHandler: TDistributorEvent; spType : TSubscribePriority): TDistributorItem;
begin
  Result := Find(aSubscriber, iDataID, aDataObj);

  if Result = nil then
  begin
    if spType = spHighest then
      Result := Insert(0) as TDistributorItem
    else if spType = spNormal then begin
      Result := NormalInsert( spType );
      if Result = nil then
        Result := Add as TDistributorItem;
    end
    else if (spType = spLowest) or ( spType = spIdle) then
      Result := Add as TDistributorItem;

    Result.FSubscriber := aSubscriber;
    Result.FDataID := iDataID;
    Result.FDataObj := aDataObj;
    Result.FEventIDs := EventIDs;
    Result.FHandler := aHandler;
    Result.FPriorityType  := spType;
    Result.LastSendTime := 0;
      {
    if aDataObj is TQuote then
      gEnv.EnvLog( WIN_TEST, Format( 'add sub : %s, %s', [
        TQuote( aDataObj ).Symbol.Code,
        aSubscriber.ClassName])  );
        }
  end else
    Result.FEventIDs := Result.FEventIDs + EventIDs;
end;

//--------------------------------------------------------------------< find >

function TDistributor.Find(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject): TDistributorItem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (FSubscriber = aSubscriber)
         and (FDataID = iDataID)
         and (FDataObj = aDataObj) then
      begin
        Result := Items[i] as TDistributorItem;
        Break;
      end;
end;

//---------------------------------------------------< distribute or deliver >

function TDistributor.Distribute(aSender: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID; iFlag : integer ): Integer;
var
  i: Integer;
  stLog : string;

begin
  Result := 0;

{$IFDEF HANA_STOCK }

  //if TRD_DATA = iDataID then
  //  gEnv.Engine.RMS.OnTrade( aDataObj, integer(anEventID) ) ;

{$ENDIF}

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (iDataID = FDataID)
         and ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj))
         and ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        //if FPriorityType >= spLowest then
        //  Break;

        //if FPriorityType = spHighest then
        if Assigned( FHandler ) then
        begin
        //  if iFlag = 1 then
        //    gEnv.EnvLog(WIN_TEST, Format('%d:%s,%s', [ i, (aSender as TQuote).Symbol.Code, (Items[i] as TDistributorItem).FSubscriber.ClassName])   );
          if iFlag = 1 then
            FHandler(aSender, FSubscriber, 100, aDataObj, anEventID)
          else
            FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID);

        end;
        //else
        Inc(Result);
      except
          {
        stLog := '';
        if ( FDataObj <> nil ) and ( FDataObj is TQuote ) then
          stLog := TQuote( FDataObj ).Symbol.Code;

        stLog := stLog + Format( ' %d : %s , %d(%d)', [
          iDataID,
          (Items[i] as TDistributorItem).FSubscriber.ClassName,
          Count, i
          ]);
        gLog.Add( lkError, 'TDistributor', 'Distribute', stLog );
        }
      end;
end;

function TDistributor.Distribute2(aSender: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID): Integer;
var
  i: Integer;
  stLog : string;
begin
  Result := 0;

  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj)) and
         ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID) ;
        Inc(Result);
      except
        stLog := Format( '%d : %s , %d(%d)', [
          iDataID,
          (Items[i] as TDistributorItem).FSubscriber.ClassName,
          Count, i
          ]);
      end;
end;


function TDistributor.Deliver(aSender, aReceiver: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID): Boolean;
var
  i: Integer;
begin
  Result := False;


  for i := 0 to Count - 1 do
    with Items[i] as TDistributorItem do
      if (aReceiver = FSubscriber)
         and (iDataID = FDataID)
         and ((FDataObj = ANY_OBJECT) or (FDataObj = aDataObj))
         and ((FEventIDs = ANY_EVENT) or (anEventID in FEventIDs)) then
      try
        FHandler(aSender, FSubscriber, iDataID, aDataObj, anEventID);
        Result := True;
      finally

      end;
end;

//------------------------------------------------------------------< cancel >

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject; anEventID: TDistributorID);
var
  aItem: TDistributorItem;
begin
  aItem := Find(aSubscriber, iDataID, aDataObj);
  if aItem <> nil then
    aItem.FEventIDs := aItem.FEventIDs - [anEventID];
end;

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer;
  aDataObj: TObject);
var
  aItem: TDistributorItem;
begin
  aItem := Find(aSubscriber, iDataID, aDataObj);
  {
  if aDataObj is TQuote  then
  gEnv.EnvLog( WIN_TEST, format( 'cnl sub : %s, %s'  , [
    TQuote( aDataObj ).Symbol.Code, aSubscriber.ClassName]) );
  }
  if aItem <> nil then
    aItem.Free;
end;

procedure TDistributor.Cancel(aSubscriber: TObject; iDataID: Integer);
var
  i: Integer;
begin
  for i := Count-1 downto 0 do
    with Items[i] as TDistributorItem do
      if (FSubscriber = aSubscriber)
         and (FDataID = iDataID) then
        Items[i].Free;
end;

procedure TDistributor.Cancel(aSubscriber: TObject);
var
  i: Integer;
begin

  //gEnv.EnvLog( WIN_TEST, format( 'all cnl sub :  %s'  , [
  //  aSubscriber.ClassName]) );
  for i := Count-1 downto 0 do
    with Items[i] as TDistributorItem do
      if FSubscriber = aSubscriber then
        Items[i].Free;
end;

end.
