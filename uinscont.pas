unit uinscont;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls;

type

  { TFormInsCont }

  TFormInsCont = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  FormInsCont: TFormInsCont;

implementation

{$R *.lfm}

{ TFormInsCont }

procedure TFormInsCont.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
Edit1.SetFocus;
end;

end.

