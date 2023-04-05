unit uInsProj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ComCtrls, ExtCtrls, EditBtn;

type

  { TfmInsProj }

  TfmInsProj = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DE1: TDirectoryEdit;
    Edit1: TEdit;
    Label1: TLabel;
    Label4: TLabel;
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  fmInsProj: TfmInsProj;

implementation

{$R *.lfm}

{ TfmInsProj }

procedure TfmInsProj.FormActivate(Sender: TObject);
begin
Edit1.SetFocus;
end;

end.

