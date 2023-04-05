unit unitCalend;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, Spin, ColorSpeedButton, rxtooledit, DateUtils;

type

  { TFormCalend }

  TFormCalend = class(TForm)
    BitBtn2: TBitBtn;
    BitBtn6: TBitBtn;
    CheckBox1: TCheckBox;
    ColorSpeedButton1: TColorSpeedButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    DTP1: TRxDateEdit;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ColorSpeedButton1Click(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
  private

  public
  end;

var
  FormCalend: TFormCalend;

implementation

{$R *.lfm}

{ TFormCalend }

procedure TFormCalend.CheckBox1Change(Sender: TObject);
begin
Label3.Visible:=not CheckBox1.Checked;
Label4.Visible:=not CheckBox1.Checked;
SpinEdit1.Visible:=not CheckBox1.Checked;
SpinEdit2.Visible:=not CheckBox1.Checked;
end;

procedure TFormCalend.CheckBox1Click(Sender: TObject);
begin
//SpinEdit1.Value:=0;
//SpinEdit2.Value:=0;
end;

procedure TFormCalend.ColorSpeedButton1Click(Sender: TObject);
begin
ModalResult:=mrYes;
end;

procedure TFormCalend.SpinEdit2Change(Sender: TObject);
begin
if SpinEdit2.Value=60 then begin
 SpinEdit1.Value:=SpinEdit1.Value+1;
 SpinEdit2.Value:=0;
end;
end;

end.


