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
    procedure ImportMasterFromKrApi(stData: string);

  public
    constructor Create(aConnector: TMySQLConnector);
    destructor Destroy; override;

      // register fixed information
    procedure SetSpecs;
    procedure AddFixedSymbols;

    function MasterFileLoad( stFile : string ) : boolean;

    // api
    procedure ImportSymbolListFromApi( iCount: integer; stData : string );
    procedure ImportSymbolMasterFromApi( iCount : integer; stData : string );
    // properties
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
  end;

  function GetCountry(stEx: string): string;
  function GetPMUnderCode( stITem : string ) : string;
  function GetCurrency( stCurr : string ) : integer;


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


// rigister index symbols
//
procedure TKRXSymbolMySQLLoader.AddFixedSymbols;
begin

end;

//---------------------------------------------------------------------< load >

procedure TKRXSymbolMySQLLoader.ImportSymbolListFromApi(iCount: integer;
  stData: string);
begin

end;

procedure TKRXSymbolMySQLLoader.ImportSymbolMasterFromApi(iCount: integer;
  stData: string);
  var
    aParse : TParser;
    iCnt   : integer;
    stTmp, stFQN, stCode, stSec, stPM, stNm, stExc, stUn, stDate: String;
    aSpec : TMarketSpec;
    aUnder, aSymbol : TSymbol;
    bNew : boolean;
    dTIckValue, dContractSize, dTickSize : double;
    yy, mm, dd , i, iDiv, iPre, iDigit: word;
begin

  try
    try
      aParse  := TParser.Create( [ Chr(9) ]);
      iCnt  := aParse.Parse( stData );

      if iCnt = iCount then
      begin

      {
      //  1 단계  Spec 만들기
      }

        stCode  := aParse[1];
        stPM    := aParse[3];
        stExc   := aParse[7];
        stSec   := aParse[8];
        stNm    := aParse[4];
        stFQN   := Format('%s.future.%s.%s', [ stPM, stExc, GetCountry( stExc )]);

        aSpec  := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
        if aSpec = nil then
        begin
          with gEnv.Engine.SymbolCore.Specs.New( stFQN ) do
          begin
            RootCode := stPM;    // underlying 을 찾기 위해
            Description := stNm;
            Sector   := stSec;
            Currency := GetCurrency( aParse[19] );

            if Currency = 0 then
              gEnv.EnvLog( WIN_TEST, '없는 통화 : ' + aParse[19] );

            iPre          := StrToInt( trim( aParse[9] ));
            iDigit        := StrToInt( trim( aParse[10] ));
            dTickSize     := StrToFloat( trim( aParse[11] ));
            dTickValue    := StrToFloat( trim( aParse[12] ));   // 가격변동금액 , TickValue
            dContractSize := {StrToFloat( trim( aParse[14] ));}   dTickValue / dTickSize;            // 계약단위

            SetPoint( dContractSize, 1,  iDigit );
            SetTick( dTickSize, 1, iPre );

            //gEnv.EnvLog( WIN_TEST,  Format('%s', [  Represent   ]));

          end;
        end;


        {
        //  2   단계  기초자산
        //  2.1 단계  기초자산 임의 등록...
        //  2.2 단계  기초자산 스펙 임의 등록... 구색 맞추기 용
        }

        stCode := stPM;//trim(aParser[ PMCODE ]);//GetPMUnderCode( aParser[ UNDERID ]);
        aUnder := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
        if aUnder = nil then
        begin
          stUn := GetPMUnderCode( stSec )  ;
          iDiv := StrToINt( stUn );
          case iDiv of
            1 , 2 , 3 :   // 통화 , 지수, 금리 순...
              begin
                stFQN := Format('%s.%s.%s', [ GetPMItemMarket( stUn ), stExc, GetCountry( stExc ) ]);
                case iDiv of
                  1 : begin
                          aUnder := gEnv.Engine.SymbolCore.Currencies.New(stCode);
                          with aUnder do
                          begin
                            Spec := gEnv.Engine.SymbolCore.Specs.Find(stFQN);
                            Name := stNm;
                            ShortCode  :=  stCode;
                          end;
                      end;
                  2 : begin
                          aUnder := gEnv.Engine.SymbolCore.Indexes.New(stCode);
                          with aUnder do
                          begin
                            Spec := gEnv.Engine.SymbolCore.Specs.Find(stFQN);
                            Name := stNm;
                            ShortCode  :=  stCode;
                          end;
                      end;
                  3 : begin
                          aUnder := gEnv.Engine.SymbolCore.Bonds.New(stCode);
                          with aUnder do
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
                aUnder := gEnv.Engine.SymbolCore.Commodities.New(stCode);
                with aUnder do
                begin
                  Spec := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
                  Name := stNm;
                  ShortCode  :=  stCode;
                end;
              end;
          end;
        end;

        if aUnder <> nil then
        begin
          if aUnder.Spec = nil then
          begin
            aSpec := gEnv.Engine.SymbolCore.Specs.New( stFQN );
            with aSpec do
            begin
              RootCode := '';
              Description := Format('%s %s', [ GetCountry( stExc ), stSec ]);
              Sector := stSec;
              Currency := GetCurrency( aParse[19] );
              SetTick( 1, 1, 0 );
            end;
            aUnder.Spec := aSpec;
          end;
          gEnv.Engine.SymbolCore.RegisterSymbol(aUnder);
        end;


        {
        //  3   단계  종목 등록
        }
        // 동부는 fullcode = shortcode
        stCode  := aParse[1];
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);

        if aSymbol = nil then
        begin
          bNew := true;
          aSpec   := gEnv.Engine.SymbolCore.Specs.Find2( stPM );
          if aSpec = nil then Exit;
          aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
          aSymbol.Spec  := aSpec;//aUnder.Spec;
          aSymbol.PriceCrt.SetExpValue( aSpec );

        end else bNew := false;

        with aSymbol do
        begin
          //Tradable := pData.trdf = 1;
          Name  := trim( aParse[2] );
          ShortCode := stCode;
          Base  := StrToFloatDef( trim( aParse[23] ) ,0);
          PrevClose := StrToFloatDef( trim( aParse[24] ),0 );
          PrevVolume:= StrToIntDef( trim( aParse[25] ), 0 );
          Last      := PrevClose;
        end;

        with aSymbol as TDerivative do
        begin
          Underlying := aUnder;
          stTmp := Trim( aparse[22] );
          IsTopStep :=  stTmp[1] = '1';

          stTmp     := trim( aParse[15] );
          yy := StrToINt( Copy( stTmp, 1, 4 ));
          mm := StrToINt( Copy( stTmp, 5, 2 ));
          dd := StrToInt( Copy( stTmp, 7, 2 ));
          ExpDate   := EnCodeDate( yy, mm, dd );
          DspExpDate:= trim( aParse[17] );
        end;

        if bNew  then
        begin
          gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
          //aSymbol.Seq := FIdx;
          //inc( FIdx );
          //gEnv.EnvLog( WIN_TEST, Format('%s: %.*f', [ aSymbol.Code, aSymbol.Spec.Precision, aSymbol.PrevClose ] ));
        end;



      end else
        gLog.Add( lkError, '','ImportSymbolMasterFromApi', Format('수신데이타 이상 %d:%s', [ iCount, iCnt, stData ]) );
    finally
      aParse.Free;
    end;
  except
    gLog.Add( lkError, '','ImportSymbolMasterFromApi', Format('파싱 에러  %d:%d:%s', [ iCount, iCnt, stData ]) );
  end;

end;

function TKRXSymbolMySQLLoader.MasterFileLoad(stFile: string): boolean;
begin

end;

procedure TKRXSymbolMySQLLoader.SetSpecs;
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
        {
                                  StrToINt( Copy( stTmp, 1, 4 )),
                                  StrToInt( Copy( stTMp, 5,2)),
                                  STrToInt( Copy( stTMp, 8, 2)));\
        }
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
    else if (stEx = 'HKFE') or ( stEx = 'HKEX') then
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
    Result := '';
    if stItem = '통화' then
      Result := CURRENCY_CODE
    else if stItem = '지수' then
      Result := INDEX_CODE
    else if stItem = '에너지' then
      Result := COMMODITY_ENERGY_CODE
    else if (stItem = '채권') or ( stItem = '금리') then
      Result := BOND_CODE
    else if stITem = '금속' then
      Result := COMMODITY_METAL_CODE
    else if stITem = '축산물' then
      Result := COMMODITY_LIVE_CODE
    else if stItem = '농산물' then
      Result := COMMODITY_FARM_CODE;


    if Result = '' then
      gEnv.EnvLog( WIN_TEST, '없는 언더코드 : ' + stItem );
  end;

  function GetCurrency( stCurr : string ) : integer;
  begin

    if stCurr = 'USD' then
      Result := CURRENCY_DOLLAR
    else if stCurr = 'HKD' then
      Result := CURRENCY_HK_DOLLAR
    else if stCurr = 'JPY' then
      Result := CURRENCY_YEN
    else if stCurr = 'EUR' then
      Result := CURRENCY_EURO
    else if stCurr = 'CNH' then
      Result := CURRENCY_YUAN
    else
      Result := 0;
  end;


end.


