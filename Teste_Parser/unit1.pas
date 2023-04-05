unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, StrHolder, SynEdit, SynHighlighterHTML, Html2TextRender;

type
  
  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    HoldTemp: TStrHolder;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel1: TPanel;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var i,Ini,Fim:integer;
S: String;
begin
 HoldTemp.Strings.LoadFromFile('orig.eml');
 S:=HoldTemp.Strings.Text;
 if pos('<html',S)<>0 then begin
  Ini:=pos('<html',S);
  Fim:=pos('</html',S);
  Memo1.Lines.Text := Copy(S,Ini,Fim);
 end;
 Memo2.Lines.Text := RenderHtml2Text(Memo1.Lines.Text);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
end;

end.

