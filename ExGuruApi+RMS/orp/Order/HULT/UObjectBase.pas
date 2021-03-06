unit UObjectBase;

interface

uses
  Classes,

  CleAccounts, CleSymbols, ClePositions, CleOrders, CleQuoteBroker,

  CleDistributor, GleTypes

  ;

type
  TTradeBase = class( TCollectionItem )
  private
    FSymbol: TSymbol;
    FAccount: TAccount;
    FPosition: TPosition;
    FTradeSpeices: integer;
    FRun: boolean;

  public
    Constructor Create( aColl : TCollection ); override;

    procedure init( aAcnt : TAccount; aSymbol : TSymbol;  aType : integer ); virtual;
    procedure init2( aSymbol : TSymbol;  aType : integer ); virtual;

    procedure OnQuote( aQuote : TQuote; iData : integer ); virtual; abstract;
    procedure OnOrder( aOrder : TOrder; EventID : TDistributorID ); virtual; abstract;
    procedure OnPosition( aPosition : TPosition; EventID : TDistributorID  ); virtual; abstract;

    property Symbol  : TSymbol read FSymbol;
    property Account : TAccount read FAccount ;
    property Position: TPosition read FPosition;
    property TradeSpecies : integer read FTradeSpeices;

    property Run : boolean read FRun write FRun;

  end;

implementation

uses
  GAppEnv
  ;

{ TObjectBase }

constructor TTradeBase.Create(aColl: TCollection);
begin
  inherited Create( aColl );
  FSymbol   := nil;
  FAccount  := nil;
  FPosition := nil;
  FRun      := false;
end;

procedure TTradeBase.init(aAcnt : TAccount; aSymbol : TSymbol; aType : integer);
begin
  if (aAcnt = nil) or ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FAccount  := aAcnt;
  FTradeSpeices := aType;

  FPosition := gEnv.Engine.TradeCore.Positions.Find( aAcnt, aSymbol );
  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.Positions.New( aAcnt, aSymbol );

end;


procedure TTradeBase.init2(aSymbol: TSymbol; aType: integer);
begin
  if ( aSymbol = nil ) then Exit;

  FSymbol   := aSymbol;
  FTradeSpeices := aType;

  FPosition := nil;
  FAccount  := nil;
end;

end.
