unit frmmain;

{$mode objfpc}{$H+}

// Define USESYNAPSE if you want to force use of synapse
{ $DEFINE USESYNAPSE}

// For version 2.6.4, synapse is the only option.
{$IFDEF VER2_6}
{$DEFINE USESYNAPSE}
{$ENDIF}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  synautil, googlebase, googleservice, googleclient, googlecalendar,
  opensslsockets, SQLite3Conn, SQLDB, DateUtils;

type

  { TMainForm }
  TAccessTokenState = (acsWaiting,acsOK,acsCancel);

  TMainForm = class(TForm)
    BCancel: TButton;
    BSetAccess: TButton;
    BFetchCalendars: TButton;
    BFetchEvents: TButton;
    Button1: TButton;
    Conn: TSQLite3Connection;
    EAccessCode: TEdit;
    GBAccess: TGroupBox;
    LEvents: TLabel;
    LEAccess: TLabel;
    LBCalendars: TListBox;
    LBEvents: TListBox;
    QTemp: TSQLQuery;
    Trans: TSQLTransaction;
    Memo1:TMemo;
    procedure BCancelClick(Sender: TObject);
    procedure BFetchEventsClick(Sender: TObject);
    procedure BSetAccessClick(Sender: TObject);
    procedure BFetchCalendarsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LBCalendarsSelectionChange(Sender: TObject; User: boolean);
    Procedure DoUserConsent(Const AURL : String; Out AAuthCode : String) ;
  private
    { private declarations }
    fConnName: string;
    FAccessState : TAccessTokenState;
    FClient : TGoogleClient;

    FCalendarAPI: TCalendarAPI;
    calendarList: TCalendarList;
    FCurrentCalendar : TCalendarListEntry;
    events : TEvents;
    procedure LoadAuthConfig;
    procedure SaveRefreshToken;
    procedure ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
    procedure ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
    function ConfigLerStr(CfgTb, Coluna: string): string;
    function ConfigLerInt(CfgTb, Coluna: string): integer;

  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

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
{$ENDIF}
  ;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
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

  // Register calendar resources.
  TCalendarAPI.RegisterAPIResources;
  // Set up google client.
  FClient:=TGoogleClient.Create(Self);
{$IFDEF USESYNAPSE}
  FClient.WebClient:=TSynapseWebClient.Create(Self);
{$ELSE}
  FClient.WebClient:=TFPHTTPWebClient.Create(Self);    s
{$ENDIF}
  FClient.WebClient.RequestSigner:=FClient.AuthHandler;
  FClient.WebClient.LogFile:='requests.log';
  FClient.AuthHandler.WebClient:=FClient.WebClient;
  FClient.AuthHandler.Config.AccessType:=atOffLine;
  // We want to enter a code.
  FClient.OnUserConsent:=@DoUserConsent;
  // Create a calendar API and connect it to the client.
  FCalendarAPI:=TCalendarAPI.Create(Self);
  FCalendarAPI.GoogleClient:=FClient;
  // Load configuration
  LoadAuthConfig;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CalendarList);
  FreeAndNil(Events);
end;

procedure TMainForm.LBCalendarsSelectionChange(Sender: TObject; User: boolean);
begin
  BFetchEvents.Enabled:=User and (LBCalendars.ItemIndex<>-1);
  if BFetchEvents.Enabled then
    begin
    FCurrentCalendar:=LBCalendars.Items.Objects[LBCalendars.ItemIndex] as TCalendarListEntry;
    if (FCurrentCalendar.Summary<>'') then
      LEvents.Caption:='Events for calendar : '+FCurrentCalendar.Summary
    else
      LEvents.Caption:='Events for calendar : '+FCurrentCalendar.ID;
    end
  else
    begin
    LEvents.Caption:='Events for calendar : <select a calendar>';
    LBEvents.Items.Clear;
    FCurrentCalendar:=Nil;
    end;

end;

procedure TMainForm.LoadAuthConfig;
begin
  FClient.AuthHandler.Config.ClientID:=ConfigLerStr('ConfigTB','ClientId');
  FClient.AuthHandler.Config.ClientSecret:=ConfigLerStr('ConfigTB','ClientSecret');
  FClient.AuthHandler.Config.AuthScope:='https://www.googleapis.com/auth/calendar';
  FClient.AuthHandler.Config.RedirectUri:='urn:ietf:wg:oauth:2.0:oob';

  FClient.AuthHandler.Session.RefreshToken:=ConfigLerStr('ConfigTB','RefreshToken');
  FClient.AuthHandler.Session.AccessToken:=ConfigLerStr('ConfigTB','AccessToken');
  FClient.AuthHandler.Session.AuthTokenType:=ConfigLerStr('ConfigTB','AuthTokenType');
//  FClient.AuthHandler.Session.AuthExpires:=ConfigLerStr('ConfigTB','AuthExpires');
  FClient.AuthHandler.Session.AuthExpiryPeriod:=ConfigLerInt('ConfigTB','AuthExpiryPeriod');
end;

procedure TMainForm.SaveRefreshToken;
begin
if FClient.AuthHandler.Session.RefreshToken<>'' then begin
 ConfigSalvarStr('ConfigTB','RefreshToken',FClient.AuthHandler.Session.RefreshToken);
 ConfigSalvarStr('ConfigTB','AccessToken',FClient.AuthHandler.Session.AccessToken);
 ConfigSalvarStr('ConfigTB','AuthTokenType',FClient.AuthHandler.Session.AuthTokenType);
// ConfigSalvarStr('ConfigTB','AuthExpires',FClient.AuthHandler.Session.AuthExpires);
 ConfigSalvarInt('ConfigTB','AuthExpiryPeriod',FClient.AuthHandler.Session.AuthExpiryPeriod);
end;
end;

procedure TMainForm.BFetchCalendarsClick(Sender: TObject);

var
  Entry: TCalendarListEntry;
  Resource : TCalendarListResource;
  EN : String;
  i:integer;

begin
  LBCalendars.Items.Clear;
  FreeAndNil(CalendarList);
  Resource:=Nil;
  try
    Resource:=FCalendarAPI.CreateCalendarListResource;
    CalendarList:=Resource.list('');
    SaveRefreshToken;
    I:=0;
    if assigned(calendarList) then
      for Entry in calendarList.items do
        begin
        Inc(i);
        EN:=Entry.Summary;
        if EN='' then
          EN:=Entry.id+' ('+Entry.description+')';
        LBCalendars.Items.AddObject(IntToStr(i)+': '+EN,Entry);
        end;
     BFetchEvents.Enabled:=LBCalendars.Items.Count>0;
  finally
    FreeAndNil(Resource);
  end;
end;

//https://lists.lazarus-ide.org/pipermail/lazarus/2020-June/238085.html
procedure TMainForm.Button1Click(Sender: TObject);
var
  Entry     : TEvent;
  Insert    : TEvent;
  start_e   : TEventDateTime;
  end_e     : TEventDateTime;
begin
  if LBCalendars.ItemIndex<0 then
    Exit;

  start_e := TEventDateTime.Create();
  end_e   := TEventDateTime.Create();

  start_e.dateTime   := EncodeDateTime(2022,4,25,19,0,0,0);
  start_e.timeZone   := 'Europe/London';
  end_e.dateTime     := IncHour(start_e.dateTime,2);
  end_e.timeZone     := 'Europe/London';

  Entry := TEvent.Create();
  Entry.summary               := 'My test';
  Entry.description           := 'My test';
  Entry.location              := 'My location';
  Entry.start                 := start_e;
  Entry._end                  := end_e;

  Entry.guestsCanInviteOthers   := false;
  Entry.guestsCanSeeOtherGuests := false;

  Entry.colorId := '';

  Insert := FCalendarAPI.EventsResource.Insert(FCurrentCalendar.id,Entry);

  SaveRefreshToken;


  Entry.Free;
  Entry:=nil;

  ShowMessage('Insert ' + Insert.id);

  Insert.Free;
  Insert:=nil;
end;


procedure TMainForm.BSetAccessClick(Sender: TObject);
begin
  FAccessState:=acsOK;
  GBAccess.Visible:=False;
end;

procedure TMainForm.BCancelClick(Sender: TObject);
begin
  FAccessState:=acsCancel;
  GBAccess.Visible:=False;
end;

procedure TMainForm.BFetchEventsClick(Sender: TObject);
var
  Entry: TEvent;
  EN : String;
  i:integer;

begin
  if LBCalendars.ItemIndex<0 then
    Exit;
  LBEvents.Items.Clear;
  FreeAndNil(Events);
  Events:=FCalendarAPI.EventsResource.list(FCurrentCalendar.id,'timeMin=2019-04-01T00:00:01Z&timeMax=2019-04-30T00:00:01Z');
  SaveRefreshToken;
  I:=0;
  if assigned(Events) then
    for Entry in Events.items do
      begin
      Inc(i);
      EN:=Entry.Summary;
//      Memo1.Lines.Add(IntToStr(i)+': '+EN);
      if EN='' then
        EN:=Entry.id+' ('+Entry.description+')';
      if Assigned(Entry.Start) then
        if Entry.start.date<>0 then
          EN:=DateToStr(Entry.start.date)+' : '+EN
        else if Entry.start.dateTime<>0 then
          EN:=DateTimeToStr(Entry.start.datetime)+' : '+EN
        else
          EN:='(unspecified time) '+EN;
      LBEvents.Items.AddObject(IntToStr(i)+': '+EN,Entry);
      end;
end;

Procedure TMainForm.DoUserConsent(Const AURL: String; Out AAuthCode: String);

begin
  GBAccess.Visible:=True;
  EAccessCode.Text:='<enter code here>';
  FAccessState:=acsWaiting;
  OpenUrl(AURL);
  While (FAccessState=acsWaiting) do
    Application.ProcessMessages;
  if FAccessState=acsOK then
    AAuthCode:=EAccessCode.Text;
  GBAccess.Visible:=False;
end;

procedure TMainForm.ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
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

procedure TMainForm.ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
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


function TMainForm.ConfigLerStr(CfgTb, Coluna: string): string;
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  Result := QTemp.FieldByName(Coluna).AsString;
  QTemp.Close;
end;

function TMainForm.ConfigLerInt(CfgTB, Coluna: string): integer;
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  Result := QTemp.FieldByName(Coluna).AsInteger;
  QTemp.Close;
end;

end.

