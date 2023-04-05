unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  googlebase, googlepeople, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  googleservice, googleclient, googlecalendar,
  opensslsockets, SQLite3Conn, SQLDB, DateUtils, googletasks, ExtCtrls,
  CheckLst, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    CLBcal: TCheckListBox;
    CLBtask: TCheckListBox;
    Conn: TSQLite3Connection;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    QTemp: TSQLQuery;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Trans: TSQLTransaction;
    procedure Button2Click(Sender: TObject);//  CLBCal.Items.Clear;
    procedure Button3Click(Sender: TObject);//  if CLBCal.ItemIndex<0 then Exit;
    procedure Button4Click(Sender: TObject);//  if CLBCal.ItemIndex<0 then     Exit;
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CLBtaskSelectionChange(Sender: TObject; User: boolean);
    procedure LBcalSelectionChange(Sender: TObject; User: boolean);
    procedure DoUserConsentCal(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentTasks(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentPeop(const AURL: string; Out AAuthCode: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fConnName: string;
    FClientCal,FClientTasks,FClientPeop: TGoogleClient;

    //Calendar
    FCalendarAPI: TCalendarAPI;
    calendarList: TCalendarList;
    FCurrentCalendar: TCalendarListEntry;
    events: TEvents;

    //tasks
    FTasksAPI: TTasksAPI;
    FTaskLists: TTaskLists;
    FCurrentList: TTaskList;
    FTasks: TTasks;

    //People
    FPeopleAPI: TPeopleAPI;

    procedure LoadAuthConfig(scope: string);
    procedure SaveRefreshToken(scope: string);

    procedure ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
    procedure ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
    function ConfigLerStr(CfgTb, Coluna: string): string;
    function ConfigLerInt(CfgTb, Coluna: string): integer;

  public

  end;

var
  Form1: TForm1;

implementation

uses
{$ifdef windows}windows,{$endif}
  jsonparser, // needed
  fpoauth2,
  lclintf,
{$IFDEF USESYNAPSE}
ssl_openssl,
synapsewebclient
{$ELSE}
  fphttpwebclient
{$ENDIF};

{$R *.lfm}

{ TForm1 }

procedure TForm1.LoadAuthConfig(scope: string);
var
  S: string;
  F: TGoogleClient;
begin
  if scope='Cal' then F:=FClientCal else
   if scope='Tasks' then F:=FClientTasks else
    if scope='Peop' then F:=FClientPeop;
  F.AuthHandler.Config.ClientID := ConfigLerStr('ConfigTB', 'ClientId');
  F.AuthHandler.Config.ClientSecret := ConfigLerStr('ConfigTB', 'ClientSecret');
  if scope = 'Tasks' then S := 'https://www.googleapis.com/auth/tasks' else
   if scope = 'Cal' then S := 'https://www.googleapis.com/auth/calendar' else
    if scope = 'Peop' then S := 'https://www.googleapis.com/auth/contacts';
  F.AuthHandler.Config.AuthScope := S;
  F.AuthHandler.Config.RedirectUri := 'urn:ietf:wg:oauth:2.0:oob';
  F.AuthHandler.Session.RefreshToken := ConfigLerStr('ConfigTB', 'RefreshToken' + scope);
  F.AuthHandler.Session.AccessToken := ConfigLerStr('ConfigTB', 'AccessToken' + scope);
  F:=nil;
  //  F.AuthHandler.Session.AuthTokenType:=ConfigLerStr('ConfigTB','AuthTokenType');
  //  F.AuthHandler.Session.AuthExpires:=ConfigLerStr('ConfigTB','AuthExpires');
  //  F.AuthHandler.Session.AuthExpiryPeriod:=ConfigLerInt('ConfigTB','AuthExpiryPeriod');
end;

procedure TForm1.SaveRefreshToken(scope: string);
begin
if scope='Cal' then
 if FClientCal.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope, FClientCal.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientCal.AuthHandler.Session.AccessToken);
 end;
if scope='Tasks' then
 if FClientTasks.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope,  FClientTasks.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientTasks.AuthHandler.Session.AccessToken);
 end;
if scope='Peop' then
 if FClientPeop.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope,  FClientPeop.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientPeop.AuthHandler.Session.AccessToken);
 end;
//   ConfigSalvarStr('ConfigTB','AuthTokenType',FClient.AuthHandler.Session.AuthTokenType);
// ConfigSalvarStr('ConfigTB','AuthExpires',FClient.AuthHandler.Session.AuthExpires);
//   ConfigSalvarInt('ConfigTB','AuthExpiryPeriod',FClient.AuthHandler.Session.AuthExpiryPeriod);
end;

procedure TForm1.DoUserConsentCal(const AURL: string; Out AAuthCode: string);
var S:String;
begin
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
end;

procedure TForm1.DoUserConsentTasks(const AURL: string; Out AAuthCode: string);
var S:String;
begin
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
end;

procedure TForm1.DoUserConsentPeop(const AURL: string; Out AAuthCode: string);
var S:String;
begin
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF UNIX}  // Linux
   {$IFNDEF DARWIN}
  //  SQLiteDefaultLibrary := 'libsqlite3.so'; //Não funciona no Linux
   {$ENDIF}
   {$IFDEF DARWIN}
    SQLiteLibraryName:='/usr/lib/libsqlite3.dylib';
   {$ENDIF}
  {$ENDIF}
  {$IFDEF WINDOWS} // Windows
    SQLiteLibraryName := 'sqlite3.dll';
  {$ENDIF}
  {$IFDEF LINUX}
  fConnName := ExtractFilePath(ParamStr(0))+'gpp.db'; //Mesma pasta do executável
  {$ENDIF}
  {$IFDEF WINDOWS}
   fConnName := ExtractFilePath(ParamStr(0))+'gpp.db'; //Mesma pasta do executável
  {$ENDIF}
  Conn.DatabaseName := fConnName;

  TPeopleAPI.RegisterAPIResources; //Tem que ficar antes dos outros dois, sabe-se lá porquê.
  TCalendarAPI.RegisterAPIResources;
  TTasksAPI.RegisterAPIResources;
  FClientCal:= TGoogleClient.Create(Self); // <- Uma só vez não rola.
  FClientTasks := TGoogleClient.Create(Self);
  FClientPeop := TGoogleClient.Create(Self);
  FClientCal.WebClient := TFPHTTPWebClient.Create(Self);
  FClientTasks.WebClient := TFPHTTPWebClient.Create(Self);
  FClientPeop.WebClient := TFPHTTPWebClient.Create(Self);
  FClientCal.WebClient.RequestSigner := FClientCal.AuthHandler;
  FClientTasks.WebClient.RequestSigner := FClientTasks.AuthHandler;
  FClientPeop.WebClient.RequestSigner := FClientPeop.AuthHandler;
  FClientCal.WebClient.LogFile := 'requestsCal.log';
  FClientTasks.WebClient.LogFile := 'requestsTasks.log';
  FClientPeop.WebClient.LogFile := 'requestsPeop.log';
  FClientCal.AuthHandler.WebClient := FClientCal.WebClient;
  FClientTasks.AuthHandler.WebClient := FClientTasks.WebClient;
  FClientPeop.AuthHandler.WebClient := FClientPeop.WebClient;
  FClientCal.AuthHandler.Config.AccessType := atOffLine;
  FClientTasks.AuthHandler.Config.AccessType := atOffLine;
  FClientPeop.AuthHandler.Config.AccessType := atOffLine;
  FClientCal.OnUserConsent := @DoUserConsentCal;
  FClientTasks.OnUserConsent := @DoUserConsentTasks;
  FClientPeop.OnUserConsent := @DoUserConsentPeop;

  FCalendarAPI := TCalendarAPI.Create(Self);
  FCalendarAPI.GoogleClient := FClientCal;
  LoadAuthConfig('Cal');

  FTasksAPI := TTasksAPI.Create(Self);
  FTasksAPI.GoogleClient := FClientTasks;
  LoadAuthConfig('Tasks');

  FPeopleAPI := TPeopleAPI.Create(Self);
  FPeopleAPI.GoogleClient := FClientPeop;
  LoadAuthConfig('Peop');

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Entry: TCalendarListEntry;
  Resource: TCalendarListResource;
  EN: string;
  i: integer;
begin
  CLBCal.Items.Clear;
  FreeAndNil(CalendarList);
  Resource := nil;
  try
    try
     Resource := FCalendarAPI.CreateCalendarListResource;
     CalendarList := Resource.list('');
    except on exception do begin
      MessageDlg('Reinicie o programa e tente novamente!',mtError,[mbOk],0);
      Exit;
      end;
    end;
    SaveRefreshToken('Cal');
    I := 0;
    if assigned(calendarList) then
      for Entry in calendarList.items do
      begin
        Inc(i);
        EN := Entry.Summary;
        if EN = '' then
          EN := Entry.id + ' (' + Entry.description + ')';
        CLBCal.Items.AddObject(IntToStr(i) + ': ' + EN, Entry);
      end;
    Button4.Enabled := CLBCal.Items.Count > 0;
  finally
    FreeAndNil(Resource);
  end;
end;

//https://lists.lazarus-ide.org/pipermail/lazarus/2020-June/238085.html
procedure TForm1.Button3Click(Sender: TObject);
var
  Entry, Insert: TEvent;
  start_e, end_e: TEventDateTime;
begin
  if CLBCal.ItemIndex < 0 then Exit;
  start_e := TEventDateTime.Create();
  end_e := TEventDateTime.Create();
  start_e.dateTime := EncodeDateTime(2022, 4, 25, 19, 0, 0, 0);
  start_e.timeZone := 'Europe/London';
  end_e.dateTime := IncHour(start_e.dateTime, 2);
  end_e.timeZone := 'Europe/London';
  Entry := TEvent.Create();
  Entry.summary := 'My test';
  Entry.description := 'My test';
  Entry.location := 'My location';
  Entry.start := start_e;
  Entry._end := end_e;
  Entry.guestsCanInviteOthers := False;
  Entry.guestsCanSeeOtherGuests := False;
  Entry.colorId := '';
  Insert := FCalendarAPI.EventsResource.Insert(FCurrentCalendar.id, Entry);
  SaveRefreshToken('Cal');
  Entry.Free;
  Entry := nil;
  ShowMessage('Insert ' + Insert.id);
  Insert.Free;
  Insert := nil;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  Entry: TEvent;
  EN: string;
  i: integer;
begin
  if CLBCal.ItemIndex < 0 then  Exit;
  Memo1.Lines.Clear;
  FreeAndNil(Events);
  Events := FCalendarAPI.EventsResource.list(FCurrentCalendar.id,'timeMin=2019-04-01T00:00:01Z&timeMax=2019-04-30T00:00:01Z');
  SaveRefreshToken('Cal');
  I := 0;
  if assigned(Events) then
    for Entry in Events.items do
    begin
      Inc(i);
      EN := Entry.Summary;
      if EN = '' then
        EN := Entry.id + ' (' + Entry.description + ')';
      if Assigned(Entry.Start) then
        if Entry.start.date <> 0 then
          EN := DateToStr(Entry.start.date) + ' : ' + EN
        else if Entry.start.dateTime <> 0 then
          EN := DateTimeToStr(Entry.start.datetime) + ' : ' + EN
        else
          EN := '(Tempo não especificado.) ' + EN;
      Memo1.Lines.AddObject(IntToStr(i) + ': ' + EN, Entry);
    end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  Entry: TTaskList;
  Resource: TTaskListsResource;
  EN: string;
  i: integer;
begin
  CLBtask.Items.Clear;
  FreeAndNil(FTaskLists);
  Resource := nil;
  try
    Resource := FTasksAPI.CreateTaskListsResource;
    FTaskLists := Resource.list('');
    SaveRefreshToken('Tasks');
    if assigned(FTaskLists) then
      for i := 0 to Length(FTaskLists.items) - 1 do
      begin
        Entry := FTaskLists.items[i];
        EN := Entry.title;
        CLBTask.Items.AddObject(IntToStr(i) + ': ' + EN, Entry);
      end;
    Button7.Enabled := CLBtask.Items.Count > 0;
  finally
    FreeAndNil(Resource);
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  Entry: TTask;
  i:integer;
begin
  if CLBTask.ItemIndex<0 then Exit;
  Memo2.Lines.Clear;
  FreeAndNil(FTasks);
  FTasks:=FTasksAPI.TasksResource.list(FCurrentList.id,'');

  SaveRefreshToken('tasks');
  if assigned(FTasks) then
    for i:= 0 to Length(FTasks.items)-1 do
      begin
      Entry:=FTasks.items[i];
//      EN:=Entry.title;
//      if EN='' then EN:=Entry.id+' ('+Entry.Status+')';
//      if Entry.Completed<>0 then EN:=EN+' (Completed :'+DateToStr(Entry.Completed)+')';
//        Memo2.Lines.AddObject(IntToStr(i)+': '+EN,Entry);

   Memo2.Lines.Add(Entry.title+': '+DateToStr(Entry.due)+': '+Entry.notes )
    end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
FTasksAPI.TasksResource.Delete(FTasks.items[2].id,FTaskLists.items[2].id);
ShowMessage('foi');
end;

procedure TForm1.CLBtaskSelectionChange(Sender: TObject; User: boolean);
begin
  if  Button7.Enabled then begin
    FCurrentList:=CLBTask.Items.Objects[CLBTask.ItemIndex] as TTaskList;
   end else begin
     Memo2.Lines.Clear;
     FCurrentList:=Nil;
    end;
end;

procedure TForm1.LBcalSelectionChange(Sender: TObject; User: boolean);
begin
  if Button4.Enabled then begin
    FCurrentCalendar := CLBCal.Items.Objects[CLBCal.ItemIndex] as TCalendarListEntry;
    if (FCurrentCalendar.Summary <> '') then
      Label1.Caption := 'Events for calendar : ' + FCurrentCalendar.Summary
    else
      Label1.Caption := 'Events for calendar : ' + FCurrentCalendar.ID;
  end else begin
    Label1.Caption := 'Events for calendar : <select a calendar>';
    Memo1.Lines.Clear;
    FCurrentCalendar := nil;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTaskLists);
  FreeAndNil(FTasks);
  FreeAndNil(CalendarList);
  FreeAndNil(Events);
end;

procedure TForm1.ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  if not QTemp.IsEmpty then QTemp.Edit
  else
    QTemp.Insert;
  QTemp.FieldByName(Coluna).AsInteger := Valor;
  QTemp.Post;
  QTemp.Close;
end;

procedure TForm1.ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  if not QTemp.IsEmpty then QTemp.Edit
  else
    QTemp.Insert;
  QTemp.FieldByName(Coluna).AsString := Valor;
  QTemp.Post;
  QTemp.Close;
end;


function TForm1.ConfigLerStr(CfgTb, Coluna: string): string;
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  Result := QTemp.FieldByName(Coluna).AsString;
  QTemp.Close;
end;

function TForm1.ConfigLerInt(CfgTB, Coluna: string): integer;
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  Result := QTemp.FieldByName(Coluna).AsInteger;
  QTemp.Close;
end;

end.
