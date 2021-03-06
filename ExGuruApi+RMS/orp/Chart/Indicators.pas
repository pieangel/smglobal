unit Indicators;

interface

uses
  Indicator, Indicators1, Indicators2, Indicators3, Indicators4,
  TyIndicators;

procedure RegisterExtraIndicators;

implementation

procedure RegisterIndicators;
begin

  // in order of 가나다 & ABC
  AddIndicator('미결제 약정', 'TOpenPositions', TOpenPositions);  // TYIndicators
  {
  //AddIndicator('베이시스', 'TBasis' , TBasis);                  // TYIndicators
  AddIndicator('이격도', 'TDisparity', TDisparity);               // Indicators2
  AddIndicator('일목균형표', 'TIchimoku', TIchimoku);             // Indicators3
  AddIndicator('투자심리선', 'TPsychoLine', TPsychoLine);         // Indicators3
  AddIndicator('Bollinger Bands', 'TBollinger', TBollinger);      // Indicators2
  AddIndicator('Color Tick','TColorTick', TColorTick);           // Indicators3
  AddIndicator('Commodity Channel Index(CCI)', 'TCCI', TCCI);     // Indicators1
  AddIndicator('Directional Movement Index(DMI)', 'TDMI', TDMI); // Indicators2
  AddIndicator('Exponential Moving Average(EMA)', 'TEMA', TEMA);  // Indicators1
  AddIndicator('MACD', 'TMACD', TMACD);                           // Indicators1
  AddIndicator('MidPoint','TMidPoint',TMidPoint);                 // Indicators2
  AddIndicator('Momentum', 'TMomentum', TMomentum);               // Indicators1
  AddIndicator('Moving Average(MA)', 'TMA', TMA);                 // Indicators1
  AddIndicator('Moving Average 2 Lines(MA2)', 'TMA2', TMA2);      // Indicators1
  AddIndicator('Moving Average 3 Lines(MA3)', 'TMA3', TMA3);      // Indicators1
  AddIndicator('Moving Average Oscillator(MAO)', 'TMAO', TMAO);   // Indicators1
  AddIndicator('On Balance Volume(OBV)', 'TOBV', TOBV);          // Indicators2

  AddIndicator('PercentR', 'TPercentR', TPercentR);               // Indicators2
  AddIndicator('Rate of Change(ROC)', 'TRoc', TRoc);             // Indicators2
  AddIndicator('Relative Strength Index(RSI)', 'TRSI', TRSI);    // Indicators2
  AddIndicator('Relative Position from the Lowest(RPL)','TRPL', TRPL);   // Indicators3
  AddIndicator('Relative Position from the Highest(RPH)','TRPH', TRPH);  // Indicators3
  //AddIndicator('SONAR Momentum','TSonar',TSonar);               // Indicators3
  }
  AddIndicator('Parabolic', 'TParabolic', TParabolic);            // Indicators1
  AddIndicator('Parabolic2', 'TParabolic2', TParabolic2);         // Indicators1
  AddIndicator('Standard Deviation', 'TStdDev', TStdDev);         // Indicators1
  AddIndicator('Stochastic Classic', 'TStochastic', TStochastic); // Indicators2
  AddIndicator('Stochastic Slow', 'TStochasticSlow', TStochasticSlow); // Indicators2
  AddIndicator('Tick Volume','TTickVolume', TTickVolume);        // Indicators3
  AddIndicator('TRIX', 'TTrix', TTrix);                           // Indicators2
  AddIndicator('Volume', 'TVolume', TVolume);                     // Indicators1
  AddIndicator('Volume Average', 'TVolumeMA', TVolumeMA);         // Indicators1

  AddIndicator('Weighted Moving Average(WMA)', 'TWMA', TWMA);     // Indicators1
  AddIndicator('William''s %R','TWilliamR', TWilliamR);           // Indicators3
  AddIndicator('Market Fill Volume','TMarketTermFillSum', TMarketTermFillSum);           // Indicators3

  AddIndicator('Profit and Loss','TProfitNLoss', TProfitNLoss);     // Indicators4
  AddIndicator('Profit and Loss2','TProfitNLoss2', TProfitNLoss2);     // Indicators4
  AddIndicator('Side Volume','TTickSideVolume', TTickSideVolume);     // Indicators4
  AddIndicator('UpD Volume','TUpDownVolume', TUpDownVolume);     // Indicators4
  AddIndicator('VKospi Spread','TVKospiSpread', TVKospiSpread);     // Indicators4
  AddIndicator('VKospi Spread','TVKospiSpread', TVKospiSpread);     // Indicators4
  AddIndicator('Future Total Count','TSymbolTotalCount', TSymbolTotalCount);     // Indicators4

end;

procedure RegisterExtraIndicators;
begin
end;

initialization
  RegisterIndicators;

end.
