program HanaDll;

uses
  Forms,
  HanaTest in 'HanaTest.pas' {Form1},
  Uconsts in 'Uconsts.pas',
  UTypes in 'UTypes.pas',
  CleParsers in 'CleParsers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
