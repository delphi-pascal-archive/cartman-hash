program hashcart_test;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  hashcart in 'hashcart.pas',
  hccartman in 'hccartman.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
