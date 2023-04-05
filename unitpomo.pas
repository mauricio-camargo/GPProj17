unit unitPomo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  Buttons, LCLIntf;

type

  { TFormPomo }

  TFormPomo = class(TForm)
    BitBtn1: TBitBtn;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label31: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    procedure Label20Click(Sender: TObject);
    procedure Label21Click(Sender: TObject);
  private

  public

  end;

var
  FormPomo: TFormPomo;

implementation

{$R *.lfm}

{ TFormPomo }

procedure TFormPomo.Label20Click(Sender: TObject);
begin
OpenURL('https://francescocirillo.com/pages/pomodoro-technique');
end;

procedure TFormPomo.Label21Click(Sender: TObject);
begin
OpenURL('https://pt.wikipedia.org/wiki/Técnica_pomodoro');
end;

end.

