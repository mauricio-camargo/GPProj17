program GPProj17;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, rxnew, rx, indylaz, lazcontrols, datetimectrls,
  Unit1, Unitrs, uInsProj, unitModelos, uTarefa, unitLink, uInsMarker, uMarc,
  uinscont, list_utils, unitPomo, unitCalend, unitCalendChose, uTarGoo,
  uLerEmail, unit2;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfmInsProj, fmInsProj);
  Application.CreateForm(TFormModelos, FormModelos);
  Application.CreateForm(TFormTarefa, FormTarefa);
  Application.CreateForm(TFormLink, FormLink);
  Application.CreateForm(TFormInsMarker, FormInsMarker);
  Application.CreateForm(TFormMarc, FormMarc);
  Application.CreateForm(TFormInsCont, FormInsCont);
  Application.CreateForm(TFormPomo, FormPomo);
  Application.CreateForm(TFormCalend, FormCalend);
  Application.CreateForm(TFormCalendChose, FormCalendChose);
  Application.CreateForm(TFormTarGoo, FormTarGoo);
  Application.CreateForm(TFormLerEmail, FormLerEmail);
  Application.Run;
end.

