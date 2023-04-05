unit uInsMarker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TFormInsMarker }

  TFormInsMarker = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  FormInsMarker: TFormInsMarker;

implementation

{$R *.lfm}

{ TFormInsMarker }

procedure TFormInsMarker.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ComboBox1.SetFocus;
end;

end.

