unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, Grids, StdCtrls, ExtCtrls,

  CleSymbols, CleQuoteBroker, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient  ,

  CleStorage, cleDistributor,

  GleTypes
  ;

type
  PSendExPacket = ^TSendExPacket;
  TSendExPacket = packed record
    Code  : array [0..9] of char;
    Name  : array [0..29] of char;
    Precision : array [0..3] of char;   // 소수점

    Open : array [0..19] of char;
    High : array [0..19] of char;
    Low  : array [0..19] of char;
    Last : array [0..19] of char;

    BidTotCnt : array [0..9] of char;
    AskTotCnt : array [0..9] of char;
    BidTotVol : array [0..9] of char;
    AskTotvol : array [0..9] of char;
  end;


  TForm2 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    sgSymbol: TStringGrid;
    sbtnSend: TSpeedButton;
    udpSend: TIdUDPClient;
    Button1: TButton;
    procedure sbtnSendClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure RecvSymbol(aSymbol: TSymbol);
    procedure AddSymbol(aSymbol: TSymbol);
    procedure UpdateData(aSymbol: TSymbol; iRow : Integer);
    procedure SendData(aSymbol: TSymbol);
    { Private declarations }
  public
    { Public declarations }
    procedure WMSymbolSelected(var msg: TMessage); message WM_SYMBOLSELECTED;
    procedure QuotePrc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  Form2: TForm2;

implementation

uses
  GAppEnv , GleLib
  ;

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var
  a : TPoint;
begin

  a := GetMousePoint;
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    //gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  gSymbol.ShowWindow( Handle);

  gSymbol.Left := a.X+10;
  gSymbol.Top  := a.Y;

end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  //
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;


procedure TForm2.QuotePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
    iRow   : integer;
begin
  if ( DataObj = nil ) or ( Sender <> Self ) then Exit;

  aQuote  := DataObj as TQuote;
  iRow  := sgSymbol.Cols[0].IndexOfObject( aQuote.Symbol);

  if iRow > 0 then begin
    UpdateData( aQuote.Symbol, iRow );
    SendData( aQuote.Symbol );
  end;

end;

procedure TForm2.sbtnSendClick(Sender: TObject);
begin
  if sbtnSend.Down then begin
    Caption := '보내는중';
  end else
  begin
    Caption := '';
  end;

end;

procedure TForm2.RecvSymbol( aSymbol : TSymbol );
begin
  if aSymbol <> nil then
    AddSymbol(aSymbol );
end;

procedure TForm2.SaveEnv(aStorage: TStorage);
var
  i, iCnt : integer;
  aSymbol : TSymbol;
begin

  if aStorage = nil then Exit;

  iCnt := 0;

  with sgSymbol do
  for I := 1 to RowCount - 1 do
  begin
    if Objects[0, i] = nil then Continue;
    
    aSymbol := TSymbol( Objects[ 0, i] );
    aStorage.FieldByName('Symbol_'+IntToStr(iCnt)).AsString := aSymbol.Code;
    inc( iCnt );
  end;

  aStorage.FieldByName('Count').AsInteger := iCnt;
end;

procedure TForm2.LoadEnv(aStorage: TStorage);
var
  i, iCnt : integer;
  stCode  : string;
  aSymbol : TSymbol;
begin
  if aStorage = nil then Exit;

  iCnt  := aStorage.FieldByName('Count').AsIntegerDef(0);

  for I := 0 to iCnt - 1 do
  begin
    stCode  := aStorage.FieldByName('Symbol_'+IntToStr(i)).AsStringDef('');
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
    if aSymbol <> nil then
      AddSymbol( aSymbol );
  end;
end;

procedure TForm2.WMSymbolSelected(var msg: TMessage);
var
  aSymbol : TSymbol;
begin

  aSymbol := TSymbol( Pointer( msg.LParam ));

  if aSymbol <> nil then

  case msg.WParam of
    0 : RecvSymbol( aSymbol ) ;
  end;

end;

procedure TForm2.AddSymbol( aSymbol : TSymbol );
var
  iRow : integer;
begin
  iRow := sgSymbol.Cols[0].IndexOfObject( aSymbol );

  if iRow > 0 then
    Exit
  else begin
    iRow := 1;
    InsertLine( sgSymbol, iRow );

    sgSymbol. Objects[0, iRow]  := aSymbol;
    UpdateData( aSymbol, iRow );
    gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, QuotePrc)  ;
  end;
end;

procedure TForm2.UpdateData( aSymbol : TSymbol; iRow : Integer );
begin
    with sgSymbol do
    begin
      Cells[0, iRow]    := aSymbol.Code;
      Cells[1, iRow]    := aSymbol.Name;
      Cells[2, iRow]    := aSymbol.PriceToStr( aSymbol.DayOpen );
      Cells[3, iRow]    := aSymbol.PriceToStr( aSymbol.DayHigh );
      Cells[4, iRow]    := aSymbol.PriceToStr( aSymbol.DayLow );
      Cells[5, iRow]    := aSymbol.PriceToStr( aSymbol.Last );
    end;
end;

const  bufSize = 1024;

procedure TForm2.SendData( aSymbol : TSymbol );
var
  Buffer : array [0..bufSize-1] of char;
  pData  : PSendExPacket;
begin

  FillChar( Buffer, bufSize, ' ');


end;

end.
