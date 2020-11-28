unit CleKrxSymbolMySQLLoader;

interface

uses
  Classes, SysUtils, Dialogs, Math, ADODB,  Forms,  DateUtils,

    // lemon: common
  GleTypes,  GleConsts, Windows,
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
    FConnector: TMySQLConnector;

    FParser: TParser;
    FRecords: TStringList;
    FCodes: TStringList;

    FOnLog: TTextNotifyEvent;
    FTmpMonths: TStringList;

    FIdx : integer;
    Fidx2: integer;
    procedure DoLog(stLog: String);
        // register fixed information
    procedure SetSpecs;
    procedure ImportFutMasterFromApi;
    procedure ImportOptMasterFromApi;


  public
    constructor Create(aConnector: TMySQLConnector);
    destructor Destroy; override;
    // api
    procedure ImportMasterFromApi;
    procedure ImportMasterFromKrApi( stData : string ); overload;
    procedure ImportSymbolListFromApi( iCount: integer; stData : string );

    function ReqMonthSymbol : boolean;
    procedure DeleteArrivedMonthSymbol( aSymbol : TSymbol );
      // properties
    property OnLog: TTextNotifyEvent read FOnLog write FOnLog;
    property TmpMonths : TStringList read FTmpMonths;
    property Idx2 : integer read FIdx2;
    property Idx  : integer read FIdx;
  end;

implementation

uses GAppEnv, GleLib, CleMarkets, Ticks, CleFQN, GAppConsts,
CleQuoteBroker, ApiPacket;

{ TKRXSymbolMySQLLoader }

  function GetExChage( stEx : string ) : string;
  begin
    case StrToInt( stEx ) of
      1: Result := 'CME';
      2: Result := 'CBOT';
      3: Result := 'NYMEX';
      4: Result := 'EUREX';
      5: Result := 'SGX';
      6: Result := 'HKFX';
      7: Result := 'OSE';
      8: Result := 'TSE';
      9: Result := 'LIFFE';
      10: Result := 'TIFFE';
      else Result := '';
    end;
  end;

  function GetSector( stSec : string ) : string;
  begin
    case StrToInt( stSec ) of
      10: Result := '통화';
      20: Result := '채권';
      30: Result := '지수';
      40: Result := '농산물';
      50: Result := '금속';
      60: Result := '에너지';
      80: Result := '지수옵션';
      90: Result := '기타상품';
      else Result := '';
    end;
  end;

  function GetPMUnderCode( stITem : string ) : string;
  begin

    case StrToInt( stITem ) of
      10: Result := CURRENCY_CODE;
      20: Result := BOND_CODE;
      30: Result := INDEX_CODE;
      40: Result := COMMODITY_FARM_CODE;
      50: Result := COMMODITY_METAL_CODE;
      60: Result := COMMODITY_ENERGY_CODE;
      80: Result := INDEX_OPT_CODE;
      90: Result := COMMODITY_SOFT_CODE;
      else Result := '';
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

  function _getCodeMonth( c : char ): integer;
  begin
    case c of
      'F': Result := 1;
      'G': Result := 2;
      'H': Result := 3;
      'J': Result := 4;
      'K': Result := 5;
      'M': Result := 6;
      'N': Result := 7;
      'Q': Result := 8;
      'U': Result := 9;
      'V': Result := 10;
      'X': Result := 11;
      'Z': Result := 12;
      else
        Result := 0;
    end;
  end;

constructor TKRXSymbolMySQLLoader.Create( aConnector: TMySQLConnector);
begin

  FConnector := aConnector;
     // create objects
  FParser := TParser.Create([',']);
  FRecords := TStringList.Create;
  FCodes := TStringList.Create;
  FCodes.Sorted := True;
  FTmpMonths:= TStringList.Create;

    FIdx := 1;
    Fidx2:= 5000;
end;

procedure TKRXSymbolMySQLLoader.DeleteArrivedMonthSymbol(aSymbol: TSymbol);
var
  I: Integer;
  stPM, stCode : string;
begin

  for I := 0 to FTmpMonths.Count - 1 do
  begin
    stPM := aSymbol.Spec.RootCode+'.1';
    stCode := FTmpMonths.Strings[i];
    if stCode = stPM then
    begin
      FTmpMonths.Delete(i);
      break;
    end;
  end;
end;

destructor TKRXSymbolMySQLLoader.Destroy;
begin
  FTmpMonths.Free;
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
begin
end;



//---------------------------------------------------------------------< load >


procedure TKRXSymbolMySQLLoader.ImportSymbolListFromApi(iCount: integer;
  stData: string);
begin
end;

procedure TKRXSymbolMySQLLoader.ImportFutMasterFromApi;
var
  F: TextFile;
  stDate, stTmp, stFile, stFQN, stCode, stSec, stPM, stNm, stExc, stUn, stData: String;
  s: string;
  c: char;
  yy, mm : integer;
  bNew : boolean;
  i, iPre, iDiv : integer;
  aSpec : TMarketSpec;
  aSymbol, aUnder : TSymbol;
  pData : POutSymbolMaster ;

  dAjv, dCtrtSize, dSize : double;
begin

  stFile := StringReplace(LowerCase(GetCurrentDir), 'exe', 'dat', [rfReplaceAll]) + '\fucode.dat';
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

      {
      //  1 단계  기초자산 의 Spec
      }


      pData := POutSymbolMaster( stData );
      stPM  := trim(string( pData.cmcd ));
      stExc := GetExChage( trim(string( pData.exch ))  );
      stSec := GetSector( trim(string( pData.prod )) );
      stNm  := trim( string( pData.ename ));
      stFQN := Format('%s.future.%s.%s', [ stPM, stExc, GetCountry( stExc )]);

      aSpec  := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
      if aSpec = nil then
      begin
        aSpec := gEnv.Engine.SymbolCore.Specs.New( stFQN );
        with aSpec do
        begin
          RootCode := stPM;    // underlying 을 찾기 위해
          Description := stNm;
          Sector   := stSec;
          Currency := CURRENCY_DOLLAR;

          dCtrtSize := StrToFloatDef( trim( string( pdata.unt )),1) ;//* 1000;
          SetPoint( dCtrtSize, 1, integer(pData.Pind) );

          stTmp := trim(string(pData.adjv));
          dAjv  := StrToFloatDef( stTmp, 1);

          stTmp := trim(string(pData.tickSize));
          dSize := StrToFloatDef( stTmp ,0) ;
          SetTickDongBu( dSize, dAjv );

          gEnv.EnvLog( WIN_TEST,
            Format('%s, %s, (%s, %s), %d', [ stPM, stTmp, FloatToStr(aSpec.TickSize),
              FloatToStr(aSpec.AdjustVal),     aSpec.Precision])
          );
         {
          i :=  Pos('.', stTmp );
          if i = 0 then
            Precision := 0
          else
            Precision := Length( stTmp ) - i;
            }
        end;
      end;

      {
      //  2   단계  기초자산
      //  2.1 단계  기초자산 임의 등록...
      //  2.2 단계  기초자산 스펙 임의 등록... 구색 맞추기 용
      }

      stCode  := stPM;//trim(aParser[ PMCODE ]);//GetPMUnderCode( aParser[ UNDERID ]);
      aUnder := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
      if aUnder = nil then
      begin
        stUn := GetPMUnderCode( trim(string( pData.prod )))  ;
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
            Currency := CURRENCY_DOLLAR;

            dSize := StrToFloatDef(trim(string(pData.tickSize)),0);
            if dSize < 1.0 then
              iPre := Length(trim(string(pData.tickSize)))-2
            else
              iPre := 0;

            SetTick( dSize, 1, iPre );
          end;
          aUnder.Spec := aSpec;

        end;
        gEnv.Engine.SymbolCore.RegisterSymbol(aUnder);
      end;

      {
      //  3   단계  종목 등록
      }
      // 동부는 fullcode = shortcode

      stDate := trim( string( pData.ctym ));
      stCode  := trim(string(pData.code));

      if stDate = '000000' then
      begin
        FTmpMonths.AddObject( stCode, nil );
        Continue;
      end;

      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);

      if aSymbol = nil then
      begin
        bNew := true;
        aSpec   := gEnv.Engine.SymbolCore.Specs.Find2( stPM );
        if aSpec = nil then continue;
        aSymbol := gEnv.Engine.SymbolCore.Futures.New(stCode);
        aSymbol.Spec  := aSpec;//aUnder.Spec;
        aSymbol.PriceCrt.SetExpValue( aSpec );

      end else bNew := false;

      with aSymbol do
      begin

        Tradable := pData.trdf = 1;
        Name  := trim(string(pData.name));

        s := Copy(stCode, Length(stCode) - 1, 2);
        if (StrToIntDef(s, -1) >= 4) then
        begin
          c := stCode[Length(stCode) - 2];
          Name := Name + Format('(%d.%d)', [2000 + StrToInt(s), _getcodeMonth(c)]);
        end;

        ShortCode := stCode;
      end;

      with aSymbol as TDerivative do
      begin
        Underlying := aUnder;
        IsTopStep  := pData.lmon = 1;

        stTmp     := trim( string( pData.ctym ));
        yy := StrToINt( Copy( stTmp, 1, 4 ));
        mm := StrToINt( Copy( stTmp, 5, 2 ));
        ExpDate   := EnCodeDate( yy, mm, 1 );
      end;

      if bNew  then
      begin
        gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
        aSymbol.Seq := FIdx;
        if ( aSymbol.Seq  > 200 ) and ( aSymbol.Seq < 220 )  then
          gEnv.EnvLog( WIN_TEST, Format('TEST : %d, %s, %s', [ aSymbol.Seq, aSymbol.Name, aSymbol.Code ])  );
        
        inc( FIdx );
      end;

    end; // while

  finally
    CloseFile(F);
  end;
end;

procedure TKRXSymbolMySQLLoader.ImportMasterFromApi;
var
  I: Integer;
  aSymbol : TSymbol;
begin
  ImportFutMasterFromApi;
  ImportOptMasterFromApi;
  //gEnv.Engine.SendBroker.ReqPMTickSize;
  gEnv.Engine.Api.AutoTimer.Enabled := true;
  //ReqMonthSymbol;
end;

function TKRXSymbolMySQLLoader.ReqMonthSymbol : boolean;
var
  stCode : string;
  iCnt, I: Integer;
begin
  Result := false;
  if FIdx2 < FIdx then
    FIdx2 := FIdx + 10;

  iCnt := 0;
  for I := 0 to FTmpMonths.Count - 1 do
    if FTmpMonths.Objects[i] = nil then
    begin
      stCode := FTmpMonths.Strings[i];
      gEnv.Engine.Api.RequestData( IntToStr( FIdx2 ),'0',
          'pibo7000', 'pibo7012', '16', stCode, '0');

      gEnv.EnvLog( WIN_TEST,  Format('월물 구독 %d - %s', [ FIdx2, stCode ])  );

      inc( FIdx2);
      inc( iCnt );
      FTmpMonths.Objects[i] := self;
      if iCnt > 30 then
        break;
    end;

  if i = FTmpMonths.Count then
    Result := true;

end;



procedure TKRXSymbolMySQLLoader.ImportMasterFromKrApi(stData: string);
var
  vData : POutSymbolMaster;
  stTmp, stFullCode: string;
  aSymbol : TSymbol;
  dTIckValue, dContractSize, dTickSize : double;
  yy, mm, dd : word;
begin
              {
  if Length( stData ) < Len_OutSymbolMaster then Exit;

  try

    vData := POutSymbolMaster( stData );
    stFullCode  := trim(string(vData.FullCode));

    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stFullCode);
    if aSymbol <> nil then
    begin

      if aSymbol.ShortCode = 'NGH6' then
        gEnv.OnLog( Self, 'cnfg');

      dContractSize := StrToFloat( trim( string( vData.CtrtSize )));
      dTickSize     := StrToFloat( trim( string( vDAta.TickSize )));
      dTickValue    := StrToFloat( trim( string( vData.TickValue )));

      aSymbol.Spec.SetPoint( dContractSize, 1, StrToint( vData.DigitDiv ));
      aSymbol.Spec.SetTick( dTickSize, 1, aSymbol.Spec.Precision );

      aSymbol.ListHigh  := StrToFloat( trim( string( vData.ListHighPrice )));
      aSymbol.ListLow   := StrToFloat( trim( string( vData.ListLowPrice )));
      

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
    gEnv.OnLog( SElf, Format('%d,%d,%d', [yy, mm, dd] ));
  end;  }
end;

procedure TKRXSymbolMySQLLoader.ImportOptMasterFromApi;
var
  F: TextFile;
  stTmp, stFile, stFQN, stCode, stSec, stPM, stNm, stExc, stUn, stData: String;
  stSk, s: string;
  c: char;

  bNew : boolean;
  i, iPos, iPre, iDiv, iY, iM : integer;
  aSpec : TMarketSpec;
  aSymbol, aUnder : TSymbol;
  pData : POptItem ;
  pCode : POptcode;
  dAdj, dValue, dSize : double;

  aFutmarket : TFutureMarket;
begin

  ////////////////////////////////////////////////////////////////////////////////////

  // 다행히 옵션 spec 파일이..있다.
  // opitem.dat 파일을 통해 spec 을 만든다..


  stFile := StringReplace(LowerCase(GetCurrentDir), 'exe', 'dat', [rfReplaceAll]) + '\opitem.dat';

  if not FileExists(stFile ) then Exit;
  try
    AssignFile(F, stFile);
    System.Reset(F);
      // load

    while not Eof(F) do
    begin
        // readln
      Readln(F, stData);
      pData := POptItem( stData );

      stPM  := trim( string( pData.comd ));
      stExc := GetExChage( trim( string( pData.exch )));
      stSec := GetSector( trim( string( pData.prod )));
      stNm  := trim(string(pData.enam ));
      stFQN := Format('%s.option.%s.%s', [ stPM, stExc, GetCountry( stExc )]);

      aSpec  := gEnv.Engine.SymbolCore.Specs.Find( stFQN );
      if aSpec = nil then
      begin
        aSpec := gEnv.Engine.SymbolCore.Specs.New( stFQN );
        with aSpec do
        begin
          RootCode := stPM;    // underlying 을 찾기 위해
          Description := stNm;
          Sector   := stSec;
          Currency := CURRENCY_DOLLAR;

          dValue  := StrToFloatDef(trim( string( pData.tval )), 1);
          SetPoint( dValue / TickSize, 1, integer(pData.Pind));

          stTmp := trim(string(pData.tsiz));
          dSize := StrToFloatDef( stTmp ,0);
          dAdj  := StrToFloatDef( trim(string(pData.adjv)), 1);
          SetTickDongbu( dSize, dAdj );
                    
          IsUpdate  := true;
        end;

        gEnv.EnvLog( WIN_GI,
          format('OptSpec :%s, %.*n, %f  ( %s, %s, %s ) ',[
            stPM,  aSpec.Precision, aSpec.TickSize, dValue,  string( pData.csiz), string(pData.cval),
            string( pData.adjv )
          ])
        );

      end;
    end;
  finally
    CloseFile(F);
  end;

  stFile := StringReplace(LowerCase(GetCurrentDir), 'exe', 'dat', [rfReplaceAll]) + '\opcode.dat';
  if not FileExists(stFile ) then Exit;

  try
    AssignFile(F, stFile);
    System.Reset(F);
      // load

      try

    while not Eof(F) do
    begin
      Readln(F, stData);
      pCode := POptcode( stData );

      stCode  := trim(string(pCode.code ));
      aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
      stTmp   := trim(string( pCode.fcod));
      stUn    := copy( stTmp, 2, Length( stTmp ) - 1 );

      aUnder  := gEnv.Engine.SymbolCore.Symbols.FindCode(stUn);

      if aUnder = nil then
      begin
        aFutmarket := gEnv.Engine.SymbolCore.FindFutureMarket( stUn );
        if aFutMarket = nil then Continue;

        aUnder     := aFutmarket.FindNearSymbol( stUn );
        if aUnder = nil then
        begin
          //gEnv.EnvLog( WIN_GI, Format('기초자산 not find : %s, %s', [ stUn, string(pCode.code )])  );
          Continue;
        end
        else
          //gEnv.EnvLog( WIN_GI, Format('기초자산 대체 find : %s, %s,--> %s', [ stUn, string(pCode.code ), aUnder.Code ])  );
      end;

      if aSymbol = nil then
      begin
        bNew := true;
        i := pos('_', stCode );
        stPM := Copy( stCode,1, i-4 );

        aSpec   := gEnv.Engine.SymbolCore.Specs.Find2( stPM );
        if aSpec = nil then
        begin
          //gEnv.EnvLog( WIN_GI, Format('spec not find : %s, %s', [ stPM, string( pCode.code)])  );
          Continue;
        end;

        aSymbol := gEnv.Engine.SymbolCore.Options.New(stCode);
        aSymbol.Spec  := aSpec;//aUnder.Spec;
        aSymbol.PriceCrt.SetExpValue( aSpec );

      end else bNew := false;

      with aSymbol as TDerivative do
      begin
        Underlying := aUnder;

        c   := stCode[ i - 3 ];
        iY  := 2000 + StrToInt( Copy( stCode, i -2 , 2 ));
        iM  := _getcodeMonth(c);
        stSk:= Copy( stCode, i+1, Length( stCode ) - i );
        aSymbol.Name  := Format('%s %s(%d.%02d)', [ aSpec.Description , stSk, iY, iM ]);
        aSymbol.ShortCode := stCode;

        ExpDate   := EnCodeDate( iY, iM, 1 );
      end;

      with aSymbol as TOption do
      begin
        CallPut := pCode.otyp;
        StrikePrice := StrToFloat( string( pCode.strk ));
        IsATM       := pCode.atmf = '1';
      end;

      if bNew  then
      begin
        gEnv.Engine.SymbolCore.RegisterSymbol(aSymbol);
        aSymbol.Seq := FIdx;
        inc( FIdx );
      end;

    end;
      except
        //ShowMessage( Format('%s', [ stCode ]));
      end;
  finally
    CloseFile(F);
  end;


end;




end.


