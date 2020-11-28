program HanaExGuruApi;

uses
  Forms,
  ComObj,
  SysUtils,
  ActiveX,
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
  TleOrderIF in '..\lemon\Engine\trade\TleOrderIF.pas',
  CleFormBroker in '..\lemon\Engine\env\CleFormBroker.pas',
  CleStorage in '..\lemon\Engine\utils\CleStorage.pas',
  GAppForms in 'Main\GAppForms.pas',
  COrderTablet in 'Order\OrderBoard\COrderTablet.pas',
  CTickPainter in 'Order\OrderBoard\CTickPainter.pas',
  DBoardParams in 'Order\OrderBoard\DBoardParams.pas' {BoardParamDialog},
  DBoardPrefs in 'Order\OrderBoard\DBoardPrefs.pas' {BoardPrefDialog},
  COBTypes in 'Order\OrderBoard\COBTypes.pas',
  DBoardOrder in 'Order\OrderBoard\DBoardOrder.pas' {BoardOrderDialog},
  DBoardVolumes in 'Order\OrderBoard\DBoardVolumes.pas' {BoardVolumeDialog},
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
  DVolume in 'Order\OrderBoard\DVolume.pas' {FrmVolume},
  DStandByVolumes in 'Order\OrderBoard\DStandByVolumes.pas' {StandByVolumes},
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
  CleFrontOrder in '..\lemon\Engine\trade\CleFrontOrder.pas',
  FleMiniPositionList in '..\lemon\Engine\trade\FleMiniPositionList.pas' {FrmMiniPosList},
  CleStopOrders in 'Order\OrderBoard\CleStopOrders.pas',
  FAppInfo in 'main\FAppInfo.pas' {FrmAppInfo},
  FleStopOrderList in '..\lemon\Engine\trade\FleStopOrderList.pas' {FrmStopOrderList},
  FAccountDeposit in '..\lemon\Engine\trade\FAccountDeposit.pas' {FrmAccountDeposit},
  FFundConfig in 'main\FFundConfig.pas' {FrmFundConfig},
  FleFundMiniPositionList in 'Order\Stg\FleFundMiniPositionList.pas' {FrmFundMiniPosList},
  DleInterestConfig in 'Order\OrderBoard\DleInterestConfig.pas' {FrmInterestConfig},
  CleTrailingStops in 'Order\CleTrailingStops.pas',
  COrderBoard in 'Order\OrderBoard\COrderBoard.pas',
  FOrderBoard in 'Order\OrderBoard\FOrderBoard.pas' {OrderBoardForm},
  FConfirmLiqMode in 'Order\Stg\FundBoard\FConfirmLiqMode.pas' {FrmLiqMode},
  ApiConsts in '..\Api\Hana\ApiConsts.pas',
  ApiPacket in '..\Api\Hana\ApiPacket.pas',
  CleApiManager in '..\Api\Hana\CleApiManager.pas',
  CleApiReceiver in '..\Api\Hana\CleApiReceiver.pas',
  CleKRXOrderBroker in '..\Api\Hana\CleKRXOrderBroker.pas',
  CleKrxSymbolMySQLLoader in '..\Api\Hana\CleKrxSymbolMySQLLoader.pas',
  ClePriceCrt in '..\Api\Hana\ClePriceCrt.pas',
  DataMenuHana in '..\Api\Hana\DataMenuHana.pas' {DataModuleHana: TDataModule},
  FFundName in '..\Api\Hana\FFundName.pas' {FrmFundName},
  FLogIn in '..\Api\Hana\FLogIn.pas' {FrmLogin},
  FOrpMain in '..\Api\Hana\FOrpMain.pas' {OrpMainForm},
  FServerMessage in '..\Api\Hana\FServerMessage.pas' {FrmServerMessage},
  DleSymbolSelect in '..\Api\Hana\DleSymbolSelect.pas' {SymbolDialog},
  FmLiqSet in 'Order\OrderBoard\FmLiqSet.pas' {FrmLiqSet: TFrame},
  FmQtySet in 'Order\OrderBoard\FmQtySet.pas' {FrmQtySet: TFrame},
  FFundOrderBoard in 'Order\OrderBoard\FFundOrderBoard.pas' {FundBoardForm},
  FLogInYoung in '..\Api\Hana\FLogInYoung.pas' {FrmLoginYoung},
  FAccountPassWord in 'main\FAccountPassWord.pas' {FrmAccountPassWord},
  FSingleOrderBoard in 'Order\OrderBoard\FSingleOrderBoard.pas' {SingleOrderBoardForm},
  FSingleFundOrderBoard in 'Order\OrderBoard\FSingleFundOrderBoard.pas' {SingleFundOrderBoardForm},
  FFundDetailConfig in 'Order\Stg\FundBoard\FFundDetailConfig.pas' {FrmFund};

{$R *.res}
{$R guru.RES}


var
  stOcx, stClass : string;
  bNeedReg: boolean;

begin

  CoInitialize( nil );
  Application.Initialize;
  bNeedReg  := false;
  stClass   := '';
  stOcx     := 'HFCommAgent.dll';

  try
    if SysUtils.FileExists(  ExtractFilePath( paramstr(0) )+ stOcx ) then
    begin
      // �ý��� �������Ϳ�  multicid.ocx �� ����϶�
      ComObj.RegisterComServer( ExtractFilePath( paramstr(0) )+stOcx );
    end;

  except
    ShowMessage( stOcx + ' ��ġ ���� ');
    Application.Terminate;
  end;

  Application.Title := 'HanaExGuruApi';
  Application.CreateForm(TOrpMainForm, OrpMainForm);
  Application.CreateForm(TDataModuleHana, DataModuleHana);
  Application.CreateForm(TFPopupMsg, FPopupMsg);
  Application.CreateForm(TFrmServerMessage, FrmServerMessage);
  //Application.ShowMainForm  := false;
  Application.Run;
end.
