unit uMarc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, CheckLst,
  StdCtrls, ATButtons, UnitRS, Variants;

type

  { TFormMarc }

  TFormMarc = class(TForm)
    ATButton1: TATButton;
    ATButton15: TATButton;
    ATButton2: TATButton;
    BitBtn1: TBitBtn;
    CLB: TCheckListBox;
    procedure ATButton15Click(Sender: TObject);
    procedure ATButton1Click(Sender: TObject);
    procedure ATButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public
  Filtro:Boolean;
  fTB,fTBm,fProjMarcID:String;
  fP,fM:Integer;
  end;

var
  FormMarc: TFormMarc;

implementation
uses Unit1;

{$R *.lfm}

{ TFormMarc }

procedure TFormMarc.FormActivate(Sender: TObject);
begin
  CLB.SetFocus;
end;

procedure TFormMarc.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i:Integer;
begin
if Filtro then Exit;
for i:=0 to CLB.Items.Count-1 do
 if CLB.Checked[i]=True then begin
  Form1.QTemp.Close;
  Form1.QTemp.SQL.Text:='Select ID_Marc from '+fTB+' where Marcador="'+CLB.Items[i]+'"';
  Form1.QTemp.Open;
  fM:=Form1.QTemp.Fields[0].AsInteger;
  if fM=0 then Continue else begin
   Form1.QTemp.Close;
   Form1.QTemp.SQL.Text:='INSERT INTO '+fTBm+' ('+fProjMarcID+',MarcID) values ('+IntToStr(fP)+','+IntToStr(fM)+') ';
   Form1.QTemp.ExecSQL;
   end;
 end;
end;

procedure TFormMarc.ATButton1Click(Sender: TObject);
var S:String;
i:Integer;
begin
if not InputQuery(rs_Marc,rs_LabelMarkNome,S) then Exit;
for i:=0 to CLB.Count-1 do
 if CLB.Items[i]=S then begin
  MessageDlg(rs_MarkExists,mtInformation,[mbOk],0);
  Exit; //Isso meso. Conferido.
  Break;
 end;
Form1.QTemp.Close;
Form1.QTemp.SQL.Text:='INSERT INTO '+fTB+' (Marcador) values ("'+S+'") ';
Form1.QTemp.ExecSQL;
CLB.Items.Insert(0,S);
CLB.Checked[0]:=True;
CLB.ItemIndex:=0;
end;

procedure TFormMarc.ATButton2Click(Sender: TObject);
begin
if CLB.Count=0 then Exit;
if CLB.ItemIndex=-1 then Exit;
if MessageDlg(rs_DeleteMarkerCont,mtConfirmation,[mbOk,mbCancel],0)<>mrOk then Exit;
Form1.QTemp.Close;
Form1.QTemp.SQl.Text:='Select * from '+fTB+' where Marcador="'+CLB.Items[CLB.ItemIndex]+'"';
Form1.QTemp.Open;
//Tem que ser MarcID e não fProjMarcID
Form1.Conn.ExecuteDirect('Delete from '+fTBm+' where MarcID='+Form1.QTemp.Fields[0].AsString);
Form1.QTemp.Delete;
CLB.DeleteSelected;
if CLB.Count>0 then CLB.ItemIndex:=0;
end;

procedure TFormMarc.ATButton15Click(Sender: TObject);
var S:String;
begin
if CLB.Count=0 then Exit;
S:=CLB.Items[CLB.ItemIndex];
if not InputQuery(rs_Marc,rs_LabelMarkNome,S) then Exit;
Form1.Conn.ExecuteDirect('Update '+fTB+' set Marcador="'+S+'" where Marcador="'+CLB.Items[CLB.ItemIndex]+'"');
CLB.Items[CLB.ItemIndex]:=S;
end;

end.

