unit CleKrxSymbols;

interface

uses
  SysUtils, Math,
    // lemon: common
  GleConsts,
    // lemon: data
  CleFQN, CleMarketSpecs, CleSymbols;

const
{
  KOSPI200_CODE = '01';
  MINI_KOSPI200_CODE = '105';
  //
  BOND3_CODE = 'bond3';
  BOND10_CODE = 'bond10';
  DOLLAR_CODE = 'dollarfut';
 }
  CURRENCY_CODE = '01';
  INDEX_CODE  = '02';
  BOND_CODE  = '03';
  COMMODITY_ENERGY_CODE = '04';
  COMMODITY_METAL_CODE = '05';
  COMMODITY_FARM_CODE = '06';
  COMMODITY_LIVE_CODE = '07';
  INDEX_OPT_CODE = '08';
  COMMODITY_SOFT_CODE = '09';

  KRX_PRICE_EPSILON = 1.0e-8;

  FQN_KRX_INDEX = 'index.krx.kr';
  FQN_KRX_STOCK = 'stock.krx.kr';
  FQN_KRX_BOND = 'bond.krx.kr';
  FQN_KRX_ETF = 'etf.krx.kr';
  FQN_KRX_DOLLAR = 'dollar.krx.kr';

  FQN_KOSPI200_FUTURES = 'kospi200.future.krx.kr';
  FQN_KOSPI200_OPTION  = 'kospi200.option.krx.kr';
  FQN_KOSPI200_FUTURES_SPREAD = 'kospi200.spread.krx.kr';

  // add by 20151123 mini
  FQN_MINI_KOSPI200_FUTURES = 'mini.kospi200.future.krx.kr';
  FQN_MINI_KOSPI200_OPTION = 'mini.kospi200.option.krx.kr';
  FQN_MINI_KOSPI200_FUTURES_SPREAD = 'mini.kospi200.spread.krx.kr';

  FQN_DOLLAR_FUTURES = 'dollar.future.krx.kr';
  FQN_BOND3_FUTURES = 'dond3.future.krx.kr';
  FQN_BOND10_FUTURES = 'dond10.future.krx.kr';

type
  TMarketSpecRec = record
    FQN: String;
    Root: String;
    Desc: String;
    Sector: String;
    Currency: Integer;
    TickSize: Double;
    Frac: Integer;
    Prec: Integer;
    ContractSize: Integer;
    PriceQuote: Double;
  end;

const
  KRX_SPECS: array[0..3] of TMarketSpecRec = (

        // index
      (FQN:FQN_KRX_INDEX; Root:''; Desc: 'KRX Stock Index'; Sector: 'Index';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 2;
       ContractSize: 1; PriceQuote: 1),
        // stock spec
      (FQN:FQN_KRX_STOCK; Root:''; Desc: 'KRX Stock'; Sector: '';
       Currency: CURRENCY_WON; TickSize: 1; Frac: 1; Prec: 0;
       ContractSize: 1; PriceQuote: 1),

      (FQN:FQN_KRX_DOLLAR; Root:''; Desc: 'KRX Dollar'; Sector: 'Commodity';
       Currency: CURRENCY_WON; TickSize: 0.1; Frac: 1; Prec: 2;
       ContractSize: 1; PriceQuote: 1),
        // stock spec
      (FQN:FQN_KRX_BOND; Root:''; Desc: 'Korea Bond'; Sector: 'Commodity';
       Currency: CURRENCY_WON; TickSize: 0.01; Frac: 1; Prec: 0;
       ContractSize: 1; PriceQuote: 1)

    );

//------------------------------------------------------------< quote parsing >




//-----------------------------------------------------------< price routines >

function TicksFromPrice(aSymbol: TSymbol; dPrice: Double; iTicks: Integer): Double;
function CheckPrice(aSymbol: TSymbol; stPrice: String; var stError: String): Boolean;

implementation

function TicksFromPrice(aSymbol: TSymbol; dPrice: Double; iTicks: Integer): Double;
var
  i, iSign : Integer;
begin
  Result := dPrice;

  if (iTicks = 0)
     or (aSymbol = nil)
     or (aSymbol.Spec = nil) then Exit;

  case aSymbol.Spec.Market of
    mtNotAssigned: ;
    mtIndex: ; // no service
    mtBond: ;  // no service
    mtETF: ;   // no service
    mtFutures:
      with aSymbol as TFuture do
      begin
        if (Underlying <> nil)  and (Underlying.Spec <> nil)
           and (Underlying.Spec.Market = mtStock) then
        begin
          iSign := iTicks div Abs(iTicks);

          for i:=1 to Abs(iTicks) do
          if iSign > 0 then
          begin
            if Result > 500000.0 - EPSILON then
              Result := Result + 500
            else if Result > 100000 - EPSILON then
              Result := Result + 250
            else if Result > 50000 - EPSILON then
              Result := Result + 50
            else if Result > 10000 - EPSILON then
              Result := Result + 25
            else
              Result := Result + 5;
          end else
          begin
            if Result < 10000 + EPSILON then
              Result := Result - 5
            else if Result < 50000 + EPSILON then
              Result := Result - 25
            else if Result < 100000 + EPSILON then
              Result := Result - 50
            else if Result < 500000 + EPSILON then
              Result := Result - 250
            else
              Result := Result - 500;
          end;
        end else
        begin
          Result := dPrice + iTicks * aSymbol.Spec.TickSize;
        end;
      end;
    mtOption:
      begin
        if aSymbol.Spec.TSizes <> nil then
        begin
          iSign := iTicks div Abs(iTicks);
          for I := 1 to abs(iTicks) do
            Result  := aSymbol.Spec.NextPrice( Result, iSign );
        end else
          Result := dPrice + iTicks * aSymbol.Spec.TickSize;
      end;
    mtStock,
    mtELW:
      begin
        iSign := iTicks div Abs(iTicks);

        for i:=1 to Abs(iTicks) do
        if iSign > 0 then
        begin
          if Result > 500000.0 - EPSILON then
            Result := Result + 1000
          else if Result > 100000 - EPSILON then
            Result := Result + 500
          else if Result > 50000 - EPSILON then
            Result := Result + 100
          else if Result > 10000 - EPSILON then
            Result := Result + 50
          else if Result > 5000 - EPSILON then
            Result := Result + 10
          else
            Result := Result + 5;
        end else
        begin
          if Result < 5000 + EPSILON then
            Result := Result - 5
          else if Result < 10000 + EPSILON then
            Result := Result - 10
          else if Result < 50000 + EPSILON then
            Result := Result - 50
          else if Result < 100000 + EPSILON then
            Result := Result - 100
          else if Result < 500000 + EPSILON then
            Result := Result - 500
          else
            Result := Result - 1000;
        end;
      end;
    mtSpread: Result := dPrice + iTicks * aSymbol.Spec.TickSize;
  end;
end;

function CheckPrice(aSymbol: TSymbol; stPrice: String; var stError: String): Boolean;
var
  dPrice: Double;
  stFloat: String;
  iLen, iPos, iEnd: Integer;
begin
  Result := False;

    // check
  if (aSymbol = nil) or (aSymbol.Spec = nil) then Exit;

    // check I -- conversion
  stPrice := Trim(stPrice);
  try
    dPrice := StrToFloat(stPrice);
  except
    stError := '가격 입력이 잘못 되었습니다';
    Exit;
  end;

    // check II -- price range
  if aSymbol.Spec.Market in [mtFutures, mtOption, mtELW] then
    if (dPrice < aSymbol.LimitLow - EPSILON) or (dPrice > aSymbol.LimitHigh + EPSILON) then
  begin
    stError := Format('가격이 상하한가 범위(%.2f-%.2f) 밖입니다',
                        [aSymbol.LimitLow, aSymbol.LimitHigh]);
    Exit;
  end;

    // check III -- Price unit (호가단위)
  if aSymbol.Spec.Market in [mtFutures, mtOption, mtELW] then
  begin
      // get floating part
    iPos := Pos('.', stPrice);
    if iPos <= 0 then
    begin
      Result := True;
      Exit; // no floating point
    end;
    stFloat := Copy(stPrice, iPos+1, Length(stPrice)-iPos);
      // longer or shorter than 2 float point?
    iLen := Length(stFloat);
    if (iLen > 2) and
       (StrToIntDef(Copy(stFloat,3,iLen-2),-1) <> 0) then
    begin
      stError := '가격은 소숫점 둘째자리까지 입력하십시오';
      Exit;
    end;

    if iLen < 2 then
    begin
      Result := True;
      Exit;
    end;

      // final check
    iEnd := StrToInt(stFloat[2]);
    if ((aSymbol.Spec.Market = mtOption)
         and (((CompareStr(aSymbol.Spec.FQN, FQN_KOSPI200_OPTION) = 0)
              and (dPrice < 3.0 - EPSILON))))
       or (iEnd mod 5 = 0) then
      Result := True
    else
      stError := '가격이 호가단위(0.05)에 맞지 않습니다';
  end else
  if aSymbol.Spec.Market = mtStock then
  begin
    if aSymbol.Spec.TickSize < EPSILON then Exit;

    if Abs(Round(dPrice/aSymbol.Spec.TickSize) * aSymbol.Spec.TickSize - dPrice)
        < EPSILON then
      Result := True
    else
      stError := Format('호가단위(%.0n)가 맞지 않습니다', [aSymbol.Spec.TickSize]);
  end;
end;

end.
