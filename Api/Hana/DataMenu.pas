unit DataMenu;

interface

uses
  SysUtils, Classes, Menus, Controls, Forms, 

  GAppForms, Dialogs,

  CleStorage
  ;

type
  TDataModuleHana = class(TDataModule)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    Research1: TMenuItem;
    Skew1: TMenuItem;
    Order1: TMenuItem;
    OrderBoard1: TMenuItem;
    N3: TMenuItem;
    N20: TMenuItem;
    Orders1: TMenuItem;
    StopOrderList1: TMenuItem;
    OpenDialog: TOpenDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    Multi: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    stg: TMenuItem;
    A50K311: TMenuItem;
    A50P21: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    VolTrade1: TMenuItem;
    procedure concernClick(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    procedure OpenWins;
    procedure FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
    procedure FormOpen(iFormID, iVar: Integer; var aForm: TForm);
    procedure FormReLoad(iFormID: integer; aForm: TForm);
    procedure FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
    { Private declarations }
  public
    { Public declarations }
    procedure init;
  end;

var
  DataModule1: TDataModuleHana;

implementation

uses
  GAppEnv  ,
  CleFormBroker,  GleConsts, FOrpMain, FleStopOrderList,  FAccountPassWord,
  FOrderBoard, FAppInfo, DBoardEnv, FleOrderList2, FleMiniPositionList , FAccountDeposit,
  FFundOrderBoard, FleFundMiniPositionList
  ;

{$R *.dfm}

procedure TDataModuleHana.concernClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TComponent) then Exit;

  if not gEnv.RecoveryEnd then Exit;

  case (Sender as TComponent).Tag of
      // file
    100: OpenWins;
    999: Application.Terminate;
      // skew
    201: gEnv.Engine.FormBroker.Open(ID_SKEW, 0); // skew chart
    202: gEnv.Engine.FormBroker.Open(ID_ACNT_DEPOSIT, 0); // skew chart
    203: gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0); //

      // trade
    302: gEnv.Engine.FormBroker.Open(ID_ORDER_LIST, 0); // order list
    303: gEnv.Engine.FormBroker.Open(ID_POSITION_LIST, 0); // position list
    304: gEnv.Engine.FormBroker.Open(ID_ORDER, 0); // simple order form
    305: gEnv.Engine.FormBroker.Open(ID_ORDERBOARD, 0); // order board
    330: gEnv.Engine.FormBroker.Open(ID_MINI_POSITION_LIST, 0); // position list
    350: gEnv.Engine.FormBroker.Open(ID_STOP_LIST, 0); // stop order list
      // 전략
    411: gEnv.Engine.FormBroker.Open(ID_MULTI_ACNT, 0);
    401: gEnv.Engine.FormBroker.Open(ID_FUND_ORDERBOARD, 0);
    410: gEnv.Engine.FormBroker.Open(ID_FUND_MINI_POS, 0);


    402: gEnv.Engine.FormBroker.Open(ID_A50_TREDN, 0);
    403: gEnv.Engine.FormBroker.Open(ID_A50_P2, 0);
    404: gEnv.Engine.FormBroker.Open(ID_VOLTRADE, 0);

  end;
end;


procedure TDataModuleHana.DataModuleCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := gEnv.RootDir;

  gEnv.Engine.FormBroker.OnOpen := FormOpen;
  gEnv.Engine.FormBroker.OnLoad := FormLoad;
  gEnv.Engine.FormBroker.OnSave := FormSave;
  gEnv.Engine.FormBroker.OnReLoad := FormReLoad;
end;

procedure TDataModuleHana.OpenWins;
var
  stName, stFile, stDir : string;

begin
  stDir := ExtractFilePath( paramstr(0) )+'back';

  if not DirectoryExists( stDir ) then
    stDir := ExtractFilePath( paramstr(0) ) ;

  OpenDialog.InitialDir := stDir;

  if OpenDialog.Execute then
    stFile := OpenDialog.FileName;


  if stFile <> '' then
  begin
    stName := ExtractFileName( stFile );
    if MessageDlg(stName + ' 파일로 화면설정 하시겠습니까?',
          mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    gEnv.Engine.FormBroker.CloseWindow;
    gEnv.Engine.FormBroker.Load(stFile);
  end;
end;

procedure TDataModuleHana.FormOpen(iFormID, iVar: Integer; var aForm: TForm);
var
  bForm : TForm;
begin
  aForm := nil;

  case iFormID of
    //ID_SKEW: aForm := TSkewForm.Create(Self);
    ID_SKEW:
      aForm :=TFrmAppInfo.Create( OrpMainForm );
    ID_MULTI_ACNT:
      begin
        aForm :=TFrmAppInfo.Create( OrpMainForm );
        TFrmAppInfo(aForm).AppPage.ActivePageIndex := 2;
        TFrmAppInfo(aForm).AppPageChange( TFrmAppInfo(aForm).AppPage  );
      end;

    ID_ACNT_DEPOSIT:
      aForm := TFrmAccountDeposit.Create( OrpMainForm);


    ID_ORDERBOARD: aForm := TOrderBoardForm.Create(OrpMainForm);
    ID_ORDER:;

    ID_ORDER_LIST:
      begin
        aForm := TFrmOrderList2.Create(OrpMainForm);

      end;

    ID_ACNT_PASSWORD:
      aForm := TFrmAccountPassWord.Create( OrpMainForm );

    ID_MINI_POSITION_LIST:
        aForm := TFrmMiniPosList.Create(OrpMainForm);

    ID_STOP_LIST:
        aForm := TFrmStopOrderList.Create( OrpMainForm );


    ID_FUND_ORDERBOARD:
        aForm := TFundBoardForm.Create( OrpMainform );
    ID_FUND_MINI_POS :
        aForm := TFrmFundMiniPosList.Create( OrpMainForm);


  end;
end;

procedure TDataModuleHana.FormReLoad(iFormID: integer; aForm: TForm);
begin
  case iFormID of
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).ReLoad;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).ReLoad;
        {
    ID_MINI_POSITION_LIST:
      if aForm is TFrmMiniPosList then
        (aForm as TFrmMiniPosList).ReLoad;
        }
  end;

end;

procedure TDataModuleHana.FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
var
  aItem : TForm;
begin
    // create/get form


   if (iFormID = ID_VIRTUAL_TRADE) and ( not gEnv.Simul ) then
    Exit;

  if (( iFormID = ID_SKEW ) or ( iFormID = ID_MULTI_ACNT )) then
    Exit;

  if ( iFormID = ID_QUOTE_SIMULATION ) and ( gEnv.RunMode = rtSimulation ) then
    Exit;

  if iFormID = ID_GURU_MAIN then
  begin
    if OrpMainForm <> nil then
      OrpMainForm.LoadEnv( aStorage );
    Exit;
  end;

  if gEnv.UserType = utNormal then
    if (iFormID = ID_A50_TREDN ) or  
       (iFormID = ID_A50_P2 ) or
       (iFormID = ID_VOLTRADE )
        then
      Exit;

  FormOpen(iFormID, 0, aForm);
    //
  if aForm = nil then Exit;

    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).LoadEnv(aStorage);
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).LoadEnv(aStorage);

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).LoadEnv( aStorage );

    ID_FUND_ORDERBOARD:
        if aForm is TFundBoardForm  then
        ( aForm as TFundBoardForm).LoadEnv( aStorage );

    ID_FUND_MINI_POS :
        if aForm is TFrmFundMiniPosList  then
        ( aForm as TFrmFundMiniPosList).LoadEnv( aStorage );



  end;
end;

procedure TDataModuleHana.FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
begin
    //
  if aForm = nil then Exit;

    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).SaveEnv(aStorage);
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).SaveEnv(aStorage);

    ID_GURU_MAIN  :
      if OrpMainForm <> nil then
        OrpMainForm.SaveEnv( aStorage );

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).SaveEnv( aStorage );

    ID_FUND_ORDERBOARD:
        if aForm is TFundBoardForm  then
        ( aForm as TFundBoardForm).SaveEnv( aStorage );

    ID_FUND_MINI_POS :
        if aForm is TFrmFundMiniPosList  then
        ( aForm as TFrmFundMiniPosList).SaveEnv( aStorage );


  end;
end;

procedure TDataModuleHana.Help1Click(Sender: TObject);
var
  iTag : integer;
  aItem : TMenuItem;
  aForm : TForm;
begin
  iTag  := TMenuItem( Sender ).Tag;
  aItem := TMenuItem( Sender );
  aForm := gEnv.Engine.FormBroker.FindFormMenu(aItem) as TForm;
  if aForm = nil then exit;
  aForm.WindowState := wsNormal;
  aForm.Show;
end;

procedure TDataModuleHana.init;
begin

end;

procedure TDataModuleHana.N7Click(Sender: TObject);
begin
  if gEnv.Info <> nil then
    gEnv.Info.Show;
end;

end.
