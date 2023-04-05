unit unitCalendChose;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ValEdit, DBGrids;

type

  { TFormCalendChose }

  TFormCalendChose = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBGrid2: TDBGrid;
    DSAgChose: TDataSource;
    QAgChose: TSQLQuery;
    procedure DBGrid2DblClick(Sender: TObject);
  private

  public

  end;

var
  FormCalendChose: TFormCalendChose;

implementation

{$R *.lfm}

{ TFormCalendChose }

procedure TFormCalendChose.DBGrid2DblClick(Sender: TObject);
begin
ModalResult:=mrOk;
end;

end.

