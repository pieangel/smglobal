program LoGup;

uses
  Forms,
  testFTP in 'testFTP.pas' {Form1},
  Unit2 in 'Unit2.pas',
  CleIni in '..\lemon\Engine\env\CleIni.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
