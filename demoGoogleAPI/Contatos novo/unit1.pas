unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  //Cuidar com as posições de todos do googleapi
  googlebase, googlepeople, ComCtrls,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  googleservice, googleclient,buttons,     opensslsockets, SQLite3Conn, SQLDB, DateUtils,  ExtCtrls,
  CheckLst, simpleinternet, xquery, internetaccess;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button2: TButton;
    Conn: TSQLite3Connection;
    Button1:TButton;
    Memo3: TMemo;
    PageControl1: TPageControl;
    QTemp: TSQLQuery;
    TabSheet3: TTabSheet;
    Trans: TSQLTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DoUserConsentPeop(const AURL: string; Out AAuthCode: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fConnName: string;
    FClientPeop: TGoogleClient;
    ClientId, ClientSecret, accessTokenGmail, RefreshTokenGmail: string;
    response,response1: xquery.IXQValue;

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
  F:=FClientPeop;
  F.AuthHandler.Config.ClientID := ConfigLerStr('ConfigTB', 'ClientId');
  F.AuthHandler.Config.ClientSecret := ConfigLerStr('ConfigTB', 'ClientSecret');
  if scope = 'Tasks' then S := 'https://www.googleapis.com/auth/tasks' else
   if scope = 'Cal' then S := 'https://www.googleapis.com/auth/calendar' else
    if scope = 'Peop' then S := 'https://www.googleapis.com/auth/contacts';
  F.AuthHandler.Config.AuthScope := S;
  F.AuthHandler.Config.RedirectUri := 'urn:ietf:wg:oauth:2.0:oob';
  F.AuthHandler.Session.RefreshToken := ConfigLerStr('ConfigTB', 'RefreshToken' + scope);
  F.AuthHandler.Session.AccessToken := ConfigLerStr('ConfigTB', 'AccessToken' + scope);
//  F:=nil;
  //  F.AuthHandler.Session.AuthTokenType:=ConfigLerStr('ConfigTB','AuthTokenType');
  //  F.AuthHandler.Session.AuthExpires:=ConfigLerStr('ConfigTB','AuthExpires');
  //  F.AuthHandler.Session.AuthExpiryPeriod:=ConfigLerInt('ConfigTB','AuthExpiryPeriod');
end;

procedure TForm1.SaveRefreshToken(scope: string);
begin
if scope='Peop' then
 if FClientPeop.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope,  FClientPeop.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientPeop.AuthHandler.Session.AccessToken);
 end;
//   ConfigSalvarStr('ConfigTB','AuthTokenType',FClient.AuthHandler.Session.AuthTokenType);
// ConfigSalvarStr('ConfigTB','AuthExpires',FClient.AuthHandler.Session.AuthExpires);
//   ConfigSalvarInt('ConfigTB','AuthExpiryPeriod',FClient.AuthHandler.Session.AuthExpiryPeriod);
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

  ClientId := ConfigLerStr('ConfigTB', 'ClientId');
  ClientSecret := ConfigLerStr('ConfigTB', 'ClientSecret');
  accessTokenGmail := ConfigLerStr('ConfigTB', 'accessTokenGmail');


  TPeopleAPI.RegisterAPIResources; //Tem que ficar antes dos outros dois, sabe-se lá porquê.
  FClientPeop := TGoogleClient.Create(Self);
  FClientPeop.WebClient := TFPHTTPWebClient.Create(Self);
  FClientPeop.WebClient.RequestSigner := FClientPeop.AuthHandler;
  FClientPeop.WebClient.LogFile := 'requestsPeop.log';
  FClientPeop.AuthHandler.WebClient := FClientPeop.WebClient;
  FClientPeop.AuthHandler.Config.AccessType := atOffLine;
  FClientPeop.OnUserConsent := @DoUserConsentPeop;

  FPeopleAPI := TPeopleAPI.Create(Self);
  FPeopleAPI.GoogleClient := FClientPeop;
  LoadAuthConfig('Peop');

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Entry: TPerson;
  Resource: TPeopleConnectionsResource;
  PeopList: TListConnectionsResponse;
  i:integer;
  //people/me
  begin

 // PeopList:=FPeopleAPI.PeopleConnectionsResource.List('me','');
//  SaveRefreshToken('Peop');

{    response := simpleinternet.process(httpRequest('https://people.googleapis.com/v1/people/me/connections?personFields=names,addresses,emailAddresses',
      'code='+S+
      '&client_id='+ClientId+
      '&client_secret='+ClientSecret+ // <- Originalmente tinha EncodeUrl(S) , mas parece que não precisa.
      '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code'),
      '$json'); // <- São 3 partes do httpRequest. Esta é a última. Ver em internetaccess
}




  //  Memo3.Lines.Clear;
  //Resource:=
  //FPeopleAPI.CreatePeopleConnectionsResource.List('me','');
  //Resource.
//  FPlist:=Resource.List('people/me','');

  //  ShowMessage(IntToStr(FPList.GetTotalPropCount));




//TPeopleConnectionsResource.list('','');
//  FTasks:=FTasksAPI.TasksResource.list(FCurrentList.id,'');

//  SaveRefreshToken('tasks');
//  if assigned(FTasks) then
//    for i:= 0 to Length(FTasks.items)-1 do
//      begin
   //   Entry:=FTasks.items[i];
//      EN:=Entry.title;
//      if EN='' then EN:=Entry.id+' ('+Entry.Status+')';
//      if Entry.Completed<>0 then EN:=EN+' (Completed :'+DateToStr(Entry.Completed)+')';
//        Memo2.Lines.AddObject(IntToStr(i)+': '+EN,Entry);

   //Memo2.Lines.Add(Entry.title+': '+DateToStr(Entry.due)+': '+Entry.notes )
//    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var scope, S: String;
begin
scope:='https://www.googleapis.com/auth/contacts';
OpenURL('https://accounts.google.com/o/oauth2/auth?scope='+scope+
 '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=' + ClientId);
if not InputQuery('Entre com o código copiado','Código criado pelo Google GMail',S) then Exit;
Screen.Cursor:=crHourGlass;
response := simpleinternet.process(httpRequest('https://www.googleapis.com/oauth2/v3/token',
  'code='+S+
  '&client_id='+ClientId+
  '&client_secret='+ClientSecret+ // <- Originalmente tinha EncodeUrl(S) , mas parece que não precisa.
  '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code'),
  '$json'); // <- São 3 partes do httpRequest. Esta é a última. Ver em internetaccess
accessTokenGmail := response.getProperty('access_token').toString;
refreshTokenGmail := response.getProperty('refresh_token').toString;
//ConfigSalvarStr('ConfigTB', 'ClientSecret', ClientSecret);
ConfigSalvarStr('ConfigTB', 'accessTokenGmail', accessTokenGmail);
ConfigSalvarStr('ConfigTB', 'refreshTokenGmail', refreshTokenGmail);
Screen.Cursor := crDefault;


response1 := simpleinternet.process(httpRequest('https://people.googleapis.com/v1/people/me/connections',
  'code='+S+
  '&client_id='+ClientId+
  '&client_secret='+ClientSecret+ // <- Originalmente tinha EncodeUrl(S) , mas parece que não precisa.
  '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code'),
  '$json'); // <- São 3 partes do httpRequest. Esta é a última. Ver em internetaccess



MessageDlg('Atenticação com os contatos do Google foi realizada com SUCESSO!', mtInformation, [mbOK], 0);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
//???
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
