unit uTarefa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  DateTimePicker, SpinEx;

type

  { TFormTarefa }

  TFormTarefa = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DTP: TDateTimePicker;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpHora: TSpinEditEx;
    SpMin: TSpinEditEx;
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  FormTarefa: TFormTarefa;

implementation

{$R *.lfm}

{ TFormTarefa }

procedure TFormTarefa.FormActivate(Sender: TObject);
begin
  Edit1.SetFocus;
end;

end.

