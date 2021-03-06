program KrGuruApi;

uses
  Forms,
  ComObj,
  ActiveX,
  SysUtils,
  Dialogs,
  windows,
  GleConsts in '..\lemon\Engine\Common\GleConsts.pas',
  LemonEngine in '..\lemon\Engine\main\LemonEngine.pas',
  CleSymbolCore in '..\lemon\Engine\symbol\CleSymbolCore.pas',
  CleMarkets in '..\lemon\Engine\symbol\CleMarkets.pas',
  CleSymbolParser in '..\lemon\Engine\symbol\CleSymbolParser.pas',
  CleSymbols in '..\lemon\Engine\symbol\CleSymbols.pas',
  CleMarketSpecs in '..\lemon\Engine\symbol\CleMarketSpecs.pas',
  CleFQN in '..\lemon\Engine\symbol\CleFQN.pas',
  GAppEnv in 'Main\GAppEnv.pas',
  GAppConsts in 'Main\GAppConsts.pas',
  CleAssocControls in '..\lemon\Engine\utils\CleAssocControls.pas',
  CleCollections in '..\lemon\Engine\utils\CleCollections.pas',
  CleContour in '..\lemon\Engine\utils\CleContour.pas',
  CleDistributor in '..\lemon\Engine\utils\CleDistributor.pas',
  CleFTPConnector in '..\lemon\Engine\utils\CleFTPConnector.pas',
  CleKeyGen in '..\lemon\Engine\utils\CleKeyGen.pas',
  CleLists in '..\lemon\Engine\utils\CleLists.pas',
  CleListViewPeer in '..\lemon\Engine\utils\CleListViewPeer.pas',
  CleMySQLConnector in '..\lemon\Engine\utils\CleMySQLConnector.pas',
  ClePainter in '..\lemon\Engine\utils\ClePainter.pas',
  CleParsers in '..\lemon\Engine\utils\CleParsers.pas',
  CleStringTree in '..\lemon\Engine\utils\CleStringTree.pas',
  CleQuoteBroker in '..\lemon\Engine\quote\CleQuoteBroker.pas',
  CleQuoteTimers in '..\lemon\Engine\quote\CleQuoteTimers.pas',
  StreamIO in '..\lemon\Engine\imports\StreamIO.pas',
  CleKrxQuoteParser in '..\lemon\Engine\quote\CleKrxQuoteParser.pas',
  CleAccounts in '..\lemon\Engine\trade\CleAccounts.pas',
  CleFunds in '..\lemon\Engine\trade\CleFunds.pas',
  CleOrders in '..\lemon\Engine\trade\CleOrders.pas',
  ClePositions in '..\lemon\Engine\trade\ClePositions.pas',
  CleTradeCore in '..\lemon\Engine\trade\CleTradeCore.pas',
  CleTrades in '..\lemon\Engine\trade\CleTrades.pas',
  CleTradingSystems in '..\lemon\Engine\trade\CleTradingSystems.pas',
  CleFills in '..\lemon\Engine\trade\CleFills.pas',
  CleKrxSymbols in '..\lemon\Engine\symbol\CleKrxSymbols.pas',
  GleLib in '..\lemon\Engine\common\GleLib.pas',
  SynthUtil in '..\lemon\Engine\imports\SynthUtil.pas',
  CleFormTracker in '..\lemon\Engine\utils\CleFormTracker.pas',
  CalcGreeks in '..\lemon\Engine\imports\CalcGreeks.pas',
  CleHolidays in '..\lemon\Engine\symbol\CleHolidays.pas',
  CleTradeBroker in '..\lemon\Engine\trade\CleTradeBroker.pas',
  GleEnv in '..\lemon\Engine\common\GleEnv.pas',
  GleTypes in '..\lemon\Engine\common\GleTypes.pas',
  ClePrograms in '..\lemon\Engine\trade\ClePrograms.pas',
  DleSymbolSelect in '..\lemon\Engine\symbol\DleSymbolSelect.pas' {SymbolDialog},
  TleOrderIF in '..\lemon\Engine\trade\TleOrderIF.pas',
  CleFormBroker in '..\lemon\Engine\env\CleFormBroker.pas',
  CleStorage in '..\lemon\Engine\utils\CleStorage.pas',
  GAppForms in 'Main\GAppForms.pas',
  FOrderBoard in 'Order\OrderBoard\FOrderBoard.pas' {OrderBoardForm},
  COrderTablet in 'Order\OrderBoard\COrderTablet.pas',
  CTickPainter in 'Order\OrderBoard\CTickPainter.pas',
  COrderBoard in 'Order\OrderBoard\COrderBoard.pas',
  DBoardParams in 'Order\OrderBoard\DBoardParams.pas' {BoardParamDialog},
  COBTypes in 'Order\OrderBoard\COBTypes.pas',
  DBoardOrder in 'Order\OrderBoard\DBoardOrder.pas' {BoardOrderDialog},
  CleIni in '..\lemon\Engine\env\CleIni.pas',
  CleLog in '..\lemon\Engine\imports\CleLog.pas',
  FFPopupMsg in 'main\FFPopupMsg.pas' {FPopupMsg},
  EnvFile in '..\lemon\Engine\utils\EnvFile.pas',
  EnvUtil in '..\lemon\Engine\utils\EnvUtil.pas',
  CryptInt in '..\lemon\Engine\utils\CryptInt.pas',
  UMemoryMapIO in '..\lemon\Engine\utils\UMemoryMapIO.pas',
  uCpuUsage in '..\lemon\Engine\utils\uCpuUsage.pas',
  CleAccountLoader in '..\lemon\Engine\trade\CleAccountLoader.pas',
  CleImportCode in '..\lemon\Engine\env\CleImportCode.pas',
  FleOrderList2 in '..\lemon\Engine\trade\FleOrderList2.pas' {FrmOrderList2},
  CleFilltering in '..\lemon\Engine\trade\CleFilltering.pas',
  TimeSpeeds in '..\lemon\Engine\imports\TimeSpeeds.pas',
  CHogaPainter in 'Order\OrderBoard\CHogaPainter.pas',
  CBoardDistributor in 'Order\OrderBoard\CBoardDistributor.pas',
  CBoardEnv in 'Order\OrderBoard\CBoardEnv.pas',
  DBoardEnv in 'Order\OrderBoard\DBoardEnv.pas' {BoardConfig},
  ListSave in '..\lemon\Engine\utils\ListSave.pas',
  Ticks in 'Chart\Common\Ticks.pas',
  CleQuoteParserIf in '..\lemon\Engine\quote\CleQuoteParserIf.pas',
  ClePriceItems in '..\lemon\Engine\quote\ClePriceItems.pas',
  CleFormManager in 'Order\FORM\CleFormManager.pas',
  CleExcelLog in '..\lemon\Engine\utils\CleExcelLog.pas',
  CalcElwIVGreeks in '..\lemon\Engine\imports\CalcElwIVGreeks.pas',
  CleCircularQueue in '..\lemon\Engine\utils\CleCircularQueue.pas',
  CleFORMOrderItems in 'Order\FORM\CleFORMOrderItems.pas',
  CleOtherData in '..\lemon\Engine\quote\CleOtherData.pas',
  CleTimers in '..\lemon\Engine\utils\CleTimers.pas',
  CleQuoteChangeData in '..\lemon\Engine\quote\CleQuoteChangeData.pas',
  CleInvestorData in '..\lemon\Engine\quote\CleInvestorData.pas',
  CleOrderBeHaivors in 'Order\CleOrderBeHaivors.pas',
  CleFrontOrder in '..\lemon\Engine\trade\CleFrontOrder.pas',
  FleMiniPositionList in '..\lemon\Engine\trade\FleMiniPositionList.pas' {FrmMiniPosList},
  CleStopOrders in 'Order\OrderBoard\CleStopOrders.pas',
  FAppInfo in 'main\FAppInfo.pas' {FrmAppInfo},
  FleStopOrderList in '..\lemon\Engine\trade\FleStopOrderList.pas' {FrmStopOrderList},
  DataMenu in '..\Api\Kr\DataMenu.pas' {DataModule1: TDataModule},
  FOrpMain in '..\Api\Kr\FOrpMain.pas' {OrpMainForm},
  CleApiManager in '..\Api\Kr\CleApiManager.pas',
  ApiPacket in '..\Api\Kr\ApiPacket.pas',
  CleApiReceiver in '..\Api\Kr\CleApiReceiver.pas',
  ApiConsts in '..\Api\Kr\ApiConsts.pas',
  FAccountDeposit in '..\lemon\Engine\trade\FAccountDeposit.pas' {FrmAccountDeposit},
  FAccountPassWord in '..\Api\Kr\FAccountPassWord.pas' {FrmAccountPassWord},
  FA50Trend in 'Order\Stg\FA50Trend.pas' {FrmA50Trend},
  FFundConfig in 'main\FFundConfig.pas' {FrmFundConfig},
  CleA50Trend in 'Order\Stg\CleA50Trend.pas',
  FleFundMiniPositionList in 'Order\Stg\FleFundMiniPositionList.pas' {FrmFundMiniPosList},
  FA_P2 in 'Order\Stg\FA_P2.pas' {FrmA_P2},
  CleA_P2Trend in 'Order\Stg\CleA_P2Trend.pas',
  CleKRXOrderBroker in '..\Api\Kr\CleKRXOrderBroker.pas',
  FServerMessage in '..\Api\Kr\FServerMessage.pas' {FrmServerMessage},
  ESApiExpLib_TLB in '..\ocx\kr\ESApiExpLib_TLB.pas',
  CleKrxSymbolMySQLLoader in '..\Api\Kr\CleKrxSymbolMySQLLoader.pas',
  FVolTrading in 'Order\Stg\FVolTrading.pas' {FrmVolTrading},
  CleVolTrading in 'Order\Stg\CleVolTrading.pas',
  FLogIn in '..\Api\Kr\FLogIn.pas' {FrmLogin},
  ClePriceCrt in '..\Api\Kr\ClePriceCrt.pas',
  FConfirmLiqMode in 'Order\Stg\FundBoard\FConfirmLiqMode.pas' {FrmLiqMode},
  DleInterestConfig in 'Order\OrderBoard\DleInterestConfig.pas' {FrmInterestConfig},
  CleTrailingStops in 'Order\CleTrailingStops.pas',
  FmLiqSet in 'Order\OrderBoard\FmLiqSet.pas' {FrmLiqSet: TFrame},
  FmQtySet in 'Order\OrderBoard\FmQtySet.pas' {FrmQtySet: TFrame},
  FFundOrderBoard in 'Order\OrderBoard\FFundOrderBoard.pas' {FundBoardForm},
  FQryTimer in '..\Api\Kr\FQryTimer.pas' {FrmQryTimer},
  FSingleFundOrderBoard in 'Order\OrderBoard\FSingleFundOrderBoard.pas' {SingleFundOrderBoardForm},
  FSingleOrderBoard in 'Order\OrderBoard\FSingleOrderBoard.pas' {SingleOrderBoardForm},
  FFundDetailConfig in 'Order\Stg\FundBoard\FFundDetailConfig.pas' {FrmFund};

{$R *.res}
{$R guru.RES}


var
  stClass : string;
  FApp    : Variant;
  bNeedReg: boolean ;

begin
  CoInitialize( nil );

  Application.Initialize;
  //bNeedReg  := true;

  bNeedReg  := false;
  stClass   := '';
  try
    stClass := ComObj.ClassIDToProgID(CLASS_ESApiExp);
    if stClass = '' then    
      bNeedReg  := true;
  except
    bNeedReg  := true;
  end;

  try
    if bNeedReg then
    begin
      if SysUtils.FileExists(  ExtractFilePath( paramstr(0) )+'ESApiExp.ocx' ) then
      begin
        // 시스템 레지스터에  multicid.ocx 를 등록하라
        ComObj.RegisterComServer( ExtractFilePath( paramstr(0) )+'ESApiExp.ocx' );
      end;
    end;
  except
    ShowMessage('ESApiExp.ocx 설치 실패 ');
    Application.Terminate;
  end;

  Application.Title := 'KrGuruApi';
  Application.CreateForm(TOrpMainForm, OrpMainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TFPopupMsg, FPopupMsg);
  Application.CreateForm(TFrmServerMessage, FrmServerMessage);
  Application.ShowMainForm  := true;


  {
  if ParamCount > 0 then
  begin
    OrpMainForm.DoLogin(true);
  end;
  }

  Application.Run;
end.
