unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, registry;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var reg: TRegistry;
S:String;
begin
reg := TRegistry.Create;
reg.OpenKey('Software', true);
reg.WriteString('test', 'aqui mesmo');
S:=reg.ReadString('test');
reg.Free;
ShowMessage(S);
end;

end.

