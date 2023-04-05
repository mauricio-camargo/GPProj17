unit unitLink;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TFormLink }

  TFormLink = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  FormLink: TFormLink;

implementation

{$R *.lfm}

{ TFormLink }

procedure TFormLink.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
Edit1.SetFocus;
end;

end.

