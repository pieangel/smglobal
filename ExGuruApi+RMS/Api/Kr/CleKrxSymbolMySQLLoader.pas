unit CleKrxSymbolMySQLLoader;

interface

uses
  Classes, SysUtils, Dialogs, Math, ADODB,  Forms,  DateUtils,

    // lemon: common
  GleTypes,  GleConsts,
    // lemon: utils
  CleMySQLConnector, CleParsers,
    // lemon: data
  CleMarketSpecs, CleSymbols,
    // lemon: KRX
  CleKrxSymbols
    // simulation
  ;

const
  DBLoadCount = 400;

type
  TKRXSymbolMySQLLoader = class
  private
    //FConnector: TMySQLConnector;

    FParser: TParser;
    FRecords: TStringList;
    FCodes: TStringList;

    FOnLog: TTextNotifyEvent;

    procedure DoLog(stLog: String);

  public
    constructor Create(aConnector: TMySQLConnector);
    destructor Destroy; override;

      // register fixed information
    procedure SetSpecs;
    procedure AddFixedSymbols;

    function MasterFileLoad( stFile : string ) : boolean;
    // pv4
    procedure ImportMasterFromFilepv4( stData : string; dtDate : TDateTime );
    procedure ImportMasterFromFileFOpv4( stData : string; dtDate : TDateTime );
    procedure ImportMasterFromFileCommodity( stData : string; dtDate : TDateTime );

    // api
    procedure ImportMasterFromKrApi( stFullCode, stShortCode,  stIndex, stName, stDecimal : string ); overload;
    procedure ImportMasterFromKrApi( stData : string ); overload;

    procedure ImportSymbolListFromApi( iCount: integer; stData : string );
    // properties
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
  end;

implementation

uses GAppEnv, GleLib, CleMarkets, Ticks, CleFQN, GAppConsts,
CleQuoteBroker, ApiPacket;

{ TKRXSymbolMySQLLoader }

constructor TKRXSymbolMySQLLoader.Create( aConnector: TMySQLConnector);
begin

  //FConnector := aConnector;
     // create objects
  FParser := TParser.Create([',']);
  FRecords := TStringList.Create;
  FCodes := TStringList.Create;
  FCodes.Sorted := True;
end;

destructor TKRXSymbolMySQLLoader.Destroy;
begin

  FRecords.Free;
  FParser.Free;
  FCodes.Free;

  inherited;
end;

procedure TKRXSymbolMySQLLoader.DoLog(stLog: String);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, 'KRX MySQL Symbol Loader: ' + stLog);
end;

//---------------------------------------------------------------< fixed info >

// register market specification using the information
// in the unit CleKRXSymbols
//



procedure TKRXSymbolMySQLLoader.SetSpecs;
const

  SEQ    =  0;  // 순번 ,
  PMCODE =  1;  // 품목코드,
  PMNAME =  2;  // 품목명,
  EXCHG  =  3;  // 거래소,
  SEC    =  4;  // 품목구분
  COUNTRY=  5;  // 국가
  UNDERID=  6;

var
  F: TextFile;
  stTmp, stFile, stFQN, stCode, stSec, stPM, stNm, stExc, stUn, stData: String;
  //aParser: TParser;
  iDiv, iCnt  : integer;
  aSpec : TMarketSpec;
  aSymbol : TSymbol;
  I: Integer;
  pData : PSpecFile;
  aMG : TMarketGroup;
  aMarket: TMarket;
  aFutMarket: TFutureMarket;
  j: Integer;   //


  function GetCountry(stEx: string): string;
  var
    iTag : integer;
  begin
    if stEx = 'CME' then
      Result := 'usa'
    else if stEx = 'ECBOT' then
      Result := 'usa'
    else if stEx = 'SGX' then
      Result := 'sin'
    else if stEx = 'LIFFE' then
      Result := 'gbr'
    else if stEx = 'EUREX' then
      Result := 'ger'
    else if stEx = 'HKFE' then
      Result := 'hkg'
    else if stEx = 'ICE' then
      Result := 'usa'
    else if stEx = 'TSE/OSE' then
      Result := 'jpn'
    else if stEx = 'LME' then
      Result := 'gbr'
    else if stEx = 'BM&F' then
      Result := 'bra';
  end;

  function GetPMUnderCode( stITem : string ) : string;
  begin
    if stItem = '통화' then
      Result := CURRENCY_CODE
    else if stItem = '지수' then
      Result := INDEX_CODE
    else if stItem = '에너지' then
      Result := COMMODITY_ENERGY_CODE
    else if stItem = '채권' then
      Result := BOND_CODE
    else if stITem = '금속' then
      Result := COMMODITY_METAL_CODE
    else if stItem = '농산물' then
      Result := COMMODITY_FARM_CODE;
  end;
begin

  stFile := ExtractFilePath( paramstr(0) )+'env\'+ FILE_PMITEM;
  if not FileExists(stFile ) then Exit;
  try
    //aParser := TParser.Create([',']);
    AssignFile(F, stFile);
    System.Reset(F);
      // load
    while not Eof(F) do
    begin
        // readln
      Readln(F, stData);

      pData := PSpecFile( stData );
      stPM  := trim(string( pData.PMCode ));
      stExc := trim(string( pData.ExCode ));
      stSec := trim(string( pData.Sector ));
      stNm  := trim( string( pData.PMName ));
      stFQN := Format('%s.future.%s.%s', [ stPM, stExc, GetCountry( stExc )]);

      aSpec  := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
      if aSpec = nil then
      begin
        with gEnv.Engine.SymbolCore.Specs.New( stFQN ) do
        begin
          RootCode := stPM;    // underlying 을 찾기 위해
          Description := stNm;
          Sector   := stSec;
          Currency := CURRENCY_DOLLAR;
        end;
      end;

        // 기초자산 임의 등록...
        // 기초자산 스펙 임의 등록... 구색 맞추기 용이므로..

        stCode  := stPM;//trim(aParser[ PMCODE ]);//GetPMUnderCode( aParser[ UNDERID ]);
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
        if aSymbol = nil then
        begin
          stUn := GetPMUnderCode( stSec  ) ;
          iDiv := StrToINt( stUn );
          case iDiv of
            1 , 2 , 3 :   // 통화 , 지수, 금리 순...
              begin
                stFQN := Format('%s.%s.%s', [ GetPMItemMarket( stUn ), stExc, GetCountry( stExc ) ]);
                case iDiv of
                  1 : begin
                          aSymbol := gEnv.Engine.SymbolCore.Currencies.New(stCode);
                          with aSymbol do
                          begin
                            Spec := gEnv.Engine.SymbolCore.Specs.Find(stFQN);
                            Name := stNm;
                            ShortCode  :=  stCode;
                          end;
                      end;
                  2 : begin
                          aSymbol := gEnv.Engine.SymbolCore.Indexes.New(stCode);
                          with aSymbol do
                          begin
                            Spec := gEnv.Engine.SymbolCore.Specs.Find(stFQN);
                            Name := stNm;
                            ShortCode  :=  stCode;
                          end;
                      end;
                  3 : begin
                          aSymbol := gEnv.Engine.SymbolCore.Bonds.New(stCode);
                          with aSymbol do
                          begin
                            Spec := gEnv.Engine.SymbolCore.Specs.Find(stFQN);
                            Name := stNm;
                            ShortCode  :=  stCode;
                          end;
                      end;
                end;
              end ; // case 1,2,3
            else
              begin
                stFQN := Format('%s.Commodity.%s.%s', [ stSec, stExc, GetCountry( stExc ) ]);
                aSymbol := gEnv.Engine.SymbolCore.Commodities.New(stCode);
                with aSymbol do
                begin
                  Spec := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
                  Name := stNm;
                  ShortCode  :=  stCode;
                end;
              end;
          end;
        end;

        if aSymbol <> nil then
        begin
          if aSymbol.Spec = nil then
          begin
            aSpec := gEnv.Engine.SymbolCore.Specs.New( stFQN );
            with aSpec do
            begin
              RootCode := '';
              Description := Format('%s %s', [ GetCountry( stPM ), stSec ]);
              Sector := stSec;
              Currency := CURRENCY_DOLLAR;
            end;
            aSymbol.Spec := aSpec;
          end;
          gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
        end;
      end;


  finally
    CloseFile(F);
  end;
end;

// rigister index symbols
//
procedure TKRXSymbolMySQLLoader.AddFixedSymbols;
begin

end;

//---------------------------------------------------------------------< load >

function TKRXSymbolMySQLLoader.MasterFileLoad(stFile: string): boolean;
var
  i : integer;
  aFile : TStringList;
  stData : string;
begin
  Result := true;

  AddFixedSymbols;
  aFile := TStringList.Create;
  aFile.LoadFromFile(stFile);

  try
    for i := 0 to aFile.Count - 1 do
    begin
      stData := Copy(aFile[i], 14, Length(aFile[i]));

      if stData = '' then
        Continue;
      ImportMasterFromFilePv4( stData, gEnv.AppDate )   ;
    end;

  finally
  end;
end;

procedure TKRXSymbolMySQLLoader.ImportSymbolListFromApi(iCount: integer;
  stData: string);
var
  pMaster : POutSymbolLIstInfo;
  stCode, stSub   : string;
  aSymbol : TSymbol;
  i : integer;
begin
  try
    for I := 0 to iCount - 1 do
    begin
      stSub := Copy( stData, i*Len_SymbolListInfo+1 , Len_SymbolListInfo );
      // 테스트 결과  tick size, ticv value 는 안오는걸로...
      gEnv.EnvLog( WIN_GI, Format('%d(%d):%s', [ i, iCount, stSub ]));           

      pMaster := POutSymbolLIstInfo( stSub );
      ImportMasterFromKrApi( trim(string(pMaster.FullCode)),
          trim(string(pMaster.ShortCode)),
          trim(string(pMaster.Index)),
          trim(string(pMaster.Name)),
          trim(string(pMaster.DecimalInfo))  );

      gEnv.Engine.Api.RequestMaster(
        trim(string(pMaster.FullCode)),
        trim(string(pMaster.Index)) , i
        );
    end;

    gEnv.Engine.SymbolCore.OptionPrint;
  except
  end;

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFileCommodity(stData: string;
  dtDate: TDateTime);
begin


end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFileFOpv4(stData: string;
  dtDate: TDateTime);

begin

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromFilepv4(stData: string;
  dtDate: TDateTime);
begin

end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromKrApi(stData: string);
var
  vData : POutSymbolMaster;
  stTmp, stFullCode: string;
  aSymbol : TSymbol;
  dTIckValue, dContractSize, dTickSize : double;
  yy, mm, dd , i, iPre: word;
begin

  if Length( stData ) < Len_OutSymbolMaster then Exit;

  try

    vData := POutSymbolMaster( stData );
    stFullCode  := trim(string(vData.FullCode));

    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stFullCode);
    if aSymbol <> nil then
    begin

      dContractSize := StrToFloat( trim( string( vData.CtrtSize )));
      dTickSize     := StrToFloat( trim( string( vDAta.TickSize )));
      dTickValue    := StrToFloat( trim( string( vData.TickValue )));

      stTmp := trim( string( vDAta.TickSize ));
      i :=  Pos('.', stTmp );
      if i = 0 then
        iPre := 0
      else
        iPre := Length( stTmp ) - i;

      aSymbol.Spec.SetPoint( dContractSize, 1, StrToint( vData.DigitDiv ));
      aSymbol.Spec.SetTick( dTickSize, 1, iPre);//aSymbol.Spec.Precision );

      if aSymbol.ShortCode = 'CLZ6' then
        gEnv.OnLog( self, '');

      aSymbol.ListHigh  := StrToFloatDef( trim( string( vData.ListHighPrice )),0);
      aSymbol.ListLow   := StrToFloatDef( trim( string( vData.ListLowPrice )),0);
      // 본장종가를 전일종가로 한다..
      aSymbol.PrevClose := StrToFloatDef( trim( string( vData.ClosePrice1 )),0);
      aSymbol.PrevVolume:= StrToInt64Def( trim( string( vData.PrevVolume )),0);

      with aSymbol as TDerivative do
      begin
        DaysToExp := StrToInt( string(vData.RemainDays) );
        stTmp     := trim( string( vData.ExpireDate ));
        yy := StrToINt( Copy( stTmp, 1, 4 ));
        mm := StrToINt( Copy( stTmp, 5, 2 ));
        dd := StrToINt( Copy( stTmp, 7, 2 ));
        ExpDate   := EnCodeDate( yy, mm, dd );

      end;

      // timer 에 태우기 위해 true 인자 추가
      gEnv.Engine.SendBroker.RequestMarketPrice( aSymbol.Code, aSymbol.Seq, true);
      //gEnv.Engine.SendBroker.RequestMarketHoga( aSymbol.Code, aSymbol.Seq, true);
      //aSymbol.DoSubscribe := true;
    end;

  except
    gEnv.OnLog( SElf, Format('%d,%d,%s, %s', [yy, mm, stTmp, trim( string( vData.ExpireDate ))] ));
  end;
end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromKrApi(stFullCode, stShortCode,  stIndex,
    stName, stDecimal: string);
  var
    bNew : boolean;
    aUnder , aSymbol : TSymbol;
    aSpec : TMarketSpec;
    stPM : string;

begin
   try
      bNew := false;
      stPM := '';

      if Length( stShortCode ) = 4 then
        stPM  := Copy( stShortCode, 1, 2 )
      else
        stPM  := Copy( stShortCode, 1, 3 );

      //if stPM = 'ZT' then
      //  stPM := 'ZT';

      aSpec   := gEnv.Engine.SymbolCore.Specs.Find2( stPM );
      if aSpec = nil then Exit;
      aUnder  := gEnv.Engine.SymbolCore.Symbols.FindCode(aSpec.RootCode);
      if aUnder = nil then Exit;

      aSpec.Precision := StrToInt( stDecimal );
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stFullCode);

      if aSymbol = nil then
      begin
        bNew := true;
        aSymbol := gEnv.Engine.SymbolCore.Futures.New(stFullCode);
        aSymbol.Spec  := aSpec;
      end   // if aSymbol = nil then
      else bNew := false;

      with aSymbol do
      begin
        Name      := stName;
        ShortCode := stShortCode;
        Seq       := StrToInt( stIndex );
      end;

      with aSymbol as TDerivative do
      begin
        Underlying := aUnder;
      end;

      if bNew then
        gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);

   except
   end;

end;




end.


