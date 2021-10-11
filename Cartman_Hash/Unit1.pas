unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, dateutils;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    TB:    TButton;
    TS:    TEdit;
    procedure TBClick (Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  LogLines: TStringList;

implementation

uses hashcart;

{$R *.dfm}

procedure TForm1.TBClick (Sender: TObject);
var
  str: string;
  hash: array [0..3] of longint;
  hashstr: string;
  i: longint;
begin
  str := ts.Text;
  fillchar(hash, 16, 0);
  hashcart.HCart.update(PChar(str), length(str));
  hashcart.HCart.final(@hash);


  hashstr := '';
  for i := 0 to 3 do
    hashstr := hashstr + ' ' + inttohex(hash[i], 8);
  memo1.Lines.Add(hashstr); 
end;


end.
