{
VERSÃO 1.7
- Implementação de Tregistry da unit registry
- Melhorar novos emails

TODO
- links gravam em Windows e Linux mas um não abre do outro
- Agenda básico
- busca arquivos está correto com PtWin e PtLnx?
-

https://console.cloud.google.com
Criar projeto
Ativar API em APIs e serviços ativados.
Criar tela de permissão de OAuth -> Adicionar escopos - Adicionar usuários de teste
Criar credenciais -> Criar ID do cliente do OAuth

Client ID
502080815718-1r1iseasap01bovrrs35rrq9053sfke9.apps.googleusercontent.com
Client secret
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

-> Hackear googlepeople que fica na raiz do GPProj na linha 3166 pois não reconhecer o people/me que é sempre o mesmo.

-> Se aparecer o erro: "Error lazarus.pp while linhking" apagar todo o diretório home/mauricio/.lazarus e dar um build Lazarus.
   Precisa reinstalar todos os componentes.

-> simpleinternet.pas vem do pacote InternetTools.
   - Tem que baixar lpk em https://benibela.de/sources_en.html#internettools
   - Descompactar em C:\Users\camar\AppData\Local\lazarus\onlinepackagemanager\packages\internettootls
   - Abrir o lpk e compilar.
   - Se faltar PasDblStrUtils.pas, copiar em https://github.com/BeRo1985/pasdblstrutils/blob/master/src/PasDblStrUtils.pas
       e salvar em ..\packages\internettootls
   - Se não rolar (faltar httpsend em Linux), faltou colocar no lpk (Inspetor de projetos) como dependência o pacote laz_synapse.
   Use > Add to Project
   Colocar em Options>Path o caminho .../internetools/internet

-> Para o executável funcionar:
   - Colocar sqlite3.dll e sqlite3.def copiados do site da SQlite na pasta do executável e também em C:\Windows
   - No Linux, instalar sudo apt-get install libsqlite3-dev, senão o TSQLite3DataSet não funciona. Então não precisa.

-> ShellCtrls: para funcionar ordem inversa em ShellTreeView, hackear ShellCtrls.pas
   em /usr/share/lazarus/2.0.10/lcl
   function FilesSortFoldersFirst(p1,p2: Pointer): Integer;
   ...
   Result:=FilesSortAlphabet(p2,p1)

-> SMTPSend só funciona com libssl-dev no Linux.
   - sudo apt-get install -y libssl-dev

-> Panel10.height tem que ser sempre igual a 44

-> ATButtons.pas
   Linha 400 Comentar:
   //  if not Theme^.EnableColorBgOver then
   //    FOver:= false;

   Linha 419
   if FOver then
     NColorBg:=clSilver
     //      NColorBg:= Theme^.ColorBgOver
   Linha 494
   //Comentar a linha para acomodar modo escuro no Linux (clDefault)
   //  C.Font.Color:= ColorToRGB(IfThen(Enabled, Theme^.ColorFont, Theme^.ColorFontDisabled));

-> Terminar instalação do Synapse (Ubuntu 20.04 não precisa)
     Instalar o Synapse pelo Online Package Manager.
     Entrar em Projeto>Opções>Caminhos e incluir o caminho da pasta:
     C:\Users\camar\AppData\Local\lazarus\onlinepackagemanager\packages\synapse40.1
      ou
     /home/mauricio/.lazarus/onlinepackagemanager/packages/synapse40.1

-> Icons by
   https://icons8.com.br/icons/set/filtrar
   https://icons.iconarchive.com/
   https://iconscout.com/icon-pack/navigation-14

-> Como colocar ícones iniciáveis no desktop (GPProj):
  - Entrar em /usr/share/applications e criar um .desktop copiando de outro
  - copie o arquivo para /home/mauricio/.local/share/applications
  Pressione Super, procure GPProj e Botão direito>Adicionar aos favoritos
  - Não é preciso copiar o arquivo para /usr/share/applications
}

unit Unit1;

{$mode objfpc}{$H+}


interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, googlegmail {Tem que ficar antes de StdCtrls, senão não compila.},
 StdCtrls, DBGrids, Buttons, ComCtrls, ColorSpeedButton, UniqueInstance,
 ATButtons, ATLinkLabel, Process, DB, SQLDB, SQLite3Conn, ShellCtrls, Menus,
 CheckLst, DateUtils, googlepeople, googleservice, googleclient, googlecalendar,
 googletasks, googledrive, EditBtn, StrHolder, SMTPSend, Unitrs, lazFileUtils,
 FileUtil, lazutf8, synautil, xquery, simpleinternet,{Tem que ficar antes de ssl_openssl, ou não envia email.}
 ssl_openssl, lcltranslator, ListViewFilterEdit, StrUtils,
 list_utils, Variants, RxSwitch, uInsProj, unitModelos, lclintf, LCLType,
 ActnList, uTarefa, uHistory, Clipbrd, DBCtrls, IdMessage, unitLink, registry,
 uinsmarker, umarc, uinscont, IdCoderMIME, idMessageParts, idAttachment, idText, MIMEMess,
 MIMEPart, lconvencoding, FileCtrl, Grids, UnitPomo, Math, UnitCalendChose,
 UnitCalend, Types, synachar,  opensslsockets,{Compila, mas precisa para ler emails do Gmail}
 uTarGoo, Html2TextRender, uplaysound {$IFDEF Windows} ,mmsystem {$ENDIF}
 {internetaccess,IdSSLOpenSSL}; //Não precisou.

type

  TMailDescription = Record
    Subject : String;
    Sender : String;
    From : String;
    Recipient : String;
    Received : String;
    Snippet : String;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    actlNota1: TActionList;
    actlNota2: TActionList;
    actlNota3: TActionList;
    actlNota4: TActionList;
    actlNotaNM: TActionList;
    actlNotaMail: TActionList;
    actlNotaP: TActionList;
    actnCopy1: TAction;
    actnCopy2: TAction;
    actnCopy3: TAction;
    actnCopy4: TAction;
    actnCopyNM: TAction;
    actnCopyMail: TAction;
    actnCopyP: TAction;
    actnCut1: TAction;
    actnCut2: TAction;
    actnCut3: TAction;
    actnCut4: TAction;
    actnCutNM: TAction;
    actnCutMail: TAction;
    actnCutP: TAction;
    actnDelete1: TAction;
    actnDelete2: TAction;
    actnDelete3: TAction;
    actnDelete4: TAction;
    actnDeleteNM: TAction;
    actnDeleteMail: TAction;
    actnDeleteP: TAction;
    actnPaste1: TAction;
    actnPaste2: TAction;
    actnPaste3: TAction;
    actnPaste4: TAction;
    actnPasteNM: TAction;
    actnPasteMail: TAction;
    actnPasteP: TAction;
    actnRedo1: TAction;
    actnRedo2: TAction;
    actnRedo3: TAction;
    actnRedo4: TAction;
    actnRedoNM: TAction;
    actnRedoMail: TAction;
    actnRedoP: TAction;
    actnSelectAll1: TAction;
    actnSelectAll2: TAction;
    actnSelectAll3: TAction;
    actnSelectAll4: TAction;
    actnSelectAllNM: TAction;
    actnSelectAllMail: TAction;
    actnSelectAllP: TAction;
    actnUndo1: TAction;
    actnUndo2: TAction;
    actnUndo3: TAction;
    actnUndo4: TAction;
    actnUndoNM: TAction;
    actnUndoMail: TAction;
    actnUndoP: TAction;
    ATButton100: TATButton;
    ATButton101: TATButton;
    ATButton109: TATButton;
    ATButton16: TATButton;
    ATButton17: TATButton;
    ATButton60: TATButton;
    ATButton75: TATButton;
    ATButton78: TATButton;
    ATButton8: TATButton;
    ATButton9: TATButton;
    ATButton110: TATButton;
    ATButton10: TATButton;
    ATButton15: TATButton;
    ATButton18: TATButton;
    ATButton20: TATButton;
    ATButton21: TATButton;
    ATButton25: TATButton;
    ATButton27: TATButton;
    ATButton28: TATButton;
    ATButton30: TATButton;
    ATButton31: TATButton;
    ATButton34: TATButton;
    ATButton36: TATButton;
    ATButton38: TATButton;
    ATButton42: TATButton;
    ATButton48: TATButton;
    ATButton55: TATButton;
    ATButton59: TATButton;
    ATButton61: TATButton;
    ATButton62: TATButton;
    ATButton76: TATButton;
    ATButton77: TATButton;
    ATButton7: TATButton;
    ATButton99: TATButton;
    ATLabelLink1: TATLabelLink;
    Bevel1: TBevel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Bevel15: TBevel;
    Bevel16: TBevel;
    Bevel17: TBevel;
    Bevel19: TBevel;
    Bevel2: TBevel;
    Bevel20: TBevel;
    Bevel21: TBevel;
    Bevel23: TBevel;
    Bevel24: TBevel;
    Bevel25: TBevel;
    Bevel26: TBevel;
    Bevel27: TBevel;
    Bevel28: TBevel;
    Bevel29: TBevel;
    Bevel3: TBevel;
    Bevel30: TBevel;
    Bevel31: TBevel;
    Bevel32: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button3: TButton;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox2x: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox8: TCheckBox;
    CheckT: TCheckBox;
    CLB3: TCheckListBox;
    CLBbusca: TCheckListBox;
    ColorSpeedButton1: TColorSpeedButton;
    ColorSpeedButton10: TColorSpeedButton;
    ColorSpeedButton100: TColorSpeedButton;
    ColorSpeedButton101: TColorSpeedButton;
    ColorSpeedButton102: TColorSpeedButton;
    ColorSpeedButton103: TColorSpeedButton;
    ColorSpeedButton104: TColorSpeedButton;
    ColorSpeedButton105: TColorSpeedButton;
    ColorSpeedButton106: TColorSpeedButton;
    ColorSpeedButton107: TColorSpeedButton;
    ColorSpeedButton108: TColorSpeedButton;
    ColorSpeedButton109: TColorSpeedButton;
    ColorSpeedButton11: TColorSpeedButton;
    ColorSpeedButton110: TColorSpeedButton;
    ColorSpeedButton111: TColorSpeedButton;
    ColorSpeedButton112: TColorSpeedButton;
    ColorSpeedButton113: TColorSpeedButton;
    ColorSpeedButton114: TColorSpeedButton;
    ColorSpeedButton115: TColorSpeedButton;
    ColorSpeedButton116: TColorSpeedButton;
    ColorSpeedButton117: TColorSpeedButton;
    ColorSpeedButton118: TColorSpeedButton;
    ColorSpeedButton119: TColorSpeedButton;
    ColorSpeedButton12: TColorSpeedButton;
    ColorSpeedButton120: TColorSpeedButton;
    ColorSpeedButton121: TColorSpeedButton;
    ColorSpeedButton122: TColorSpeedButton;
    ColorSpeedButton123: TColorSpeedButton;
    ColorSpeedButton124: TColorSpeedButton;
    ColorSpeedButton13: TColorSpeedButton;
    ColorSpeedButton15: TColorSpeedButton;
    ColorSpeedButton16: TColorSpeedButton;
    ColorSpeedButton17: TColorSpeedButton;
    ColorSpeedButton2: TColorSpeedButton;
    ColorSpeedButton34: TColorSpeedButton;
    ColorSpeedButton38: TColorSpeedButton;
    ColorSpeedButton37: TColorSpeedButton;
    ColorSpeedButton18: TColorSpeedButton;
    ColorSpeedButton19: TColorSpeedButton;
    ColorSpeedButton20: TColorSpeedButton;
    ColorSpeedButton21: TColorSpeedButton;
    ColorSpeedButton22: TColorSpeedButton;
    ColorSpeedButton23: TColorSpeedButton;
    ColorSpeedButton24: TColorSpeedButton;
    ColorSpeedButton25: TColorSpeedButton;
    ColorSpeedButton26: TColorSpeedButton;
    ColorSpeedButton30: TColorSpeedButton;
    ColorSpeedButton31: TColorSpeedButton;
    ColorSpeedButton32: TColorSpeedButton;
    ColorSpeedButton33: TColorSpeedButton;
    ColorSpeedButton35: TColorSpeedButton;
    ColorSpeedButton36: TColorSpeedButton;
    ColorSpeedButton39: TColorSpeedButton;
    ColorSpeedButton4: TColorSpeedButton;
    ColorSpeedButton40: TColorSpeedButton;
    ColorSpeedButton41: TColorSpeedButton;
    ColorSpeedButton42: TColorSpeedButton;
    ColorSpeedButton43: TColorSpeedButton;
    ColorSpeedButton44: TColorSpeedButton;
    ColorSpeedButton45: TColorSpeedButton;
    ColorSpeedButton46: TColorSpeedButton;
    ColorSpeedButton51: TColorSpeedButton;
    ColorSpeedButton52: TColorSpeedButton;
    ColorSpeedButton53: TColorSpeedButton;
    ColorSpeedButton54: TColorSpeedButton;
    ColorSpeedButton55: TColorSpeedButton;
    ColorSpeedButton56: TColorSpeedButton;
    ColorSpeedButton57: TColorSpeedButton;
    ColorSpeedButton58: TColorSpeedButton;
    ColorSpeedButton59: TColorSpeedButton;
    ColorSpeedButton60: TColorSpeedButton;
    ColorSpeedButton61: TColorSpeedButton;
    ColorSpeedButton62: TColorSpeedButton;
    ColorSpeedButton63: TColorSpeedButton;
    ColorSpeedButton64: TColorSpeedButton;
    ColorSpeedButton65: TColorSpeedButton;
    ColorSpeedButton66: TColorSpeedButton;
    ColorSpeedButton67: TColorSpeedButton;
    ColorSpeedButton68: TColorSpeedButton;
    ColorSpeedButton69: TColorSpeedButton;
    ColorSpeedButton7: TColorSpeedButton;
    ColorSpeedButton70: TColorSpeedButton;
    ColorSpeedButton71: TColorSpeedButton;
    ColorSpeedButton72: TColorSpeedButton;
    ColorSpeedButton73: TColorSpeedButton;
    ColorSpeedButton74: TColorSpeedButton;
    ColorSpeedButton75: TColorSpeedButton;
    ColorSpeedButton76: TColorSpeedButton;
    ColorSpeedButton77: TColorSpeedButton;
    ColorSpeedButton78: TColorSpeedButton;
    ColorSpeedButton79: TColorSpeedButton;
    ColorSpeedButton8: TColorSpeedButton;
    ColorSpeedButton80: TColorSpeedButton;
    ColorSpeedButton81: TColorSpeedButton;
    ColorSpeedButton82: TColorSpeedButton;
    ColorSpeedButton83: TColorSpeedButton;
    ColorSpeedButton84: TColorSpeedButton;
    ColorSpeedButton85: TColorSpeedButton;
    ColorSpeedButton86: TColorSpeedButton;
    ColorSpeedButton87: TColorSpeedButton;
    ColorSpeedButton88: TColorSpeedButton;
    ColorSpeedButton89: TColorSpeedButton;
    ColorSpeedButton9: TColorSpeedButton;
    ColorSpeedButton90: TColorSpeedButton;
    ColorSpeedButton91: TColorSpeedButton;
    ColorSpeedButton92: TColorSpeedButton;
    ColorSpeedButton93: TColorSpeedButton;
    ColorSpeedButton94: TColorSpeedButton;
    ColorSpeedButton95: TColorSpeedButton;
    ColorSpeedButton96: TColorSpeedButton;
    ColorSpeedButton97: TColorSpeedButton;
    ColorSpeedButton98: TColorSpeedButton;
    ColorSpeedButton99: TColorSpeedButton;
    DBEdit1: TDBEdit;
    DBGrid1: TDBGrid;
    DBGrid10: TDBGrid;
    DBGrid11: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBGrid5: TDBGrid;
    DBGrid6: TDBGrid;
    DBGrid7: TDBGrid;
    DBGrid8: TDBGrid;
    DBGrid9: TDBGrid;
    DBMemo2: TDBMemo;
    DBMemoMail: TDBMemo;
    DCal: TDrawGrid;
    DE8: TDirectoryEdit;
    DSAgenda: TDataSource;
    DSBusca: TDataSource;
    DSContAll: TDataSource;
    DSContProj: TDataSource;
    DSLinks: TDataSource;
    DSMail: TDataSource;
    DSMarcCont: TDataSource;
    DSMarcProj: TDataSource;
    DSRascu: TDataSource;
    DSRascuAnx: TDataSource;
    DSRascuCont: TDataSource;
    DSTarAF: TDataSource;
    DSTarFin: TDataSource;
    DSTl: TDataSource;
    EdBusca: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    FlowPanel1: TFlowPanel;
    FlowPanel2: TFlowPanel;
    FLV1: TListViewFilterEdit;
    FLV2: TListViewFilterEdit;
    FLV3: TListViewFilterEdit;
    FLV4: TListViewFilterEdit;
    GroupBox1: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    HoldAvisos1: TStrHolder;
    HoldEML: TStrHolder;
    HoldNotasCel1: TStrHolder;
    HoldPath1: TStrHolder;
    HoldPath2: TStrHolder;
    HoldSelect: TStrHolder;
    HoldTL: TStrHolder;
    IdMessage1: TIdMessage;
    Image2: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Img3: TImageList;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label25x: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9x: TLabel;
    LBCalGoo: TListBox;
    LBTarGoo: TListBox;
    ListBox1: TListBox;
    ListBox1x: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListViewFilterEdit1: TListViewFilterEdit;
    ListViewFilterEdit2: TListViewFilterEdit;
    LV1: TListView;
    LV2: TListView;
    LV3: TListView;
    LVAudio: TListView;
    LVFiles: TListView;
    LVMessages: TListView;
    LVPeopGoo: TListView;
    MemMail: TMemo;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    MemoTmpAudio: TMemo;
    MemoPj: TMemo;
    MemTemp: TMemo;
    MemTempX: TMemo;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    Separator2: TMenuItem;
    MenuNM: TPopupMenu;
    MenuMail: TPopupMenu;
    N20: TMenuItem;
    N22: TMenuItem;
    Notebook2: TNotebook;
    Page10: TPage;
    Page5: TPage;
    Page6: TPage;
    Page7: TPage;
    Page8: TPage;
    Page9: TPage;
    PageControl5: TPageControl;
    Panel10: TPanel;
    Panel100: TPanel;
    Panel101: TPanel;
    Panel102: TPanel;
    Panel104: TPanel;
    Panel105: TPanel;
    Panel106: TPanel;
    Panel107: TPanel;
    Panel108: TPanel;
    Panel109: TPanel;
    Panel11: TPanel;
    Panel110: TPanel;
    Panel111: TPanel;
    Panel112: TPanel;
    Panel113: TPanel;
    Panel114: TPanel;
    Panel115: TPanel;
    Panel116: TPanel;
    Panel117: TPanel;
    Panel118: TPanel;
    Panel119: TPanel;
    Panel12: TPanel;
    Panel120: TPanel;
    Panel121: TPanel;
    Panel122: TPanel;
    Panel123: TPanel;
    Panel124: TPanel;
    Panel125: TPanel;
    Panel126: TPanel;
    Panel127: TPanel;
    Panel128: TPanel;
    Panel129: TPanel;
    Panel13: TPanel;
    Panel130: TPanel;
    Panel131: TPanel;
    Panel132: TPanel;
    Panel133: TPanel;
    Panel134: TPanel;
    Panel135: TPanel;
    Panel136: TPanel;
    Panel137: TPanel;
    Panel138: TPanel;
    Panel139: TPanel;
    Panel14: TPanel;
    Panel140: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel42: TPanel;
    Panel43: TPanel;
    Panel44: TPanel;
    Panel45: TPanel;
    Panel46: TPanel;
    Panel47: TPanel;
    Panel48: TPanel;
    Panel49: TPanel;
    Panel50: TPanel;
    Panel51: TPanel;
    Panel52: TPanel;
    Panel6: TPanel;
    Panel62: TPanel;
    Panel63: TPanel;
    Panel64: TPanel;
    Panel7: TPanel;
    Panel71: TPanel;
    Panel72: TPanel;
    Panel82: TPanel;
    Panel83: TPanel;
    Panel84: TPanel;
    Panel85: TPanel;
    Panel86: TPanel;
    Panel87: TPanel;
    Panel88: TPanel;
    Panel89: TPanel;
    Panel90: TPanel;
    Panel91: TPanel;
    Panel92: TPanel;
    Panel93: TPanel;
    Panel94: TPanel;
    Panel95: TPanel;
    Panel96: TPanel;
    Panel97: TPanel;
    Panel98: TPanel;
    Panel99: TPanel;
    PanelAvisos: TPanel;
    PgNovoEmail: TPage;
    PgPomo: TPage;
    PgTimeLine: TPage;
    pmiCopyNM: TMenuItem;
    pmiCopyMail: TMenuItem;
    pmiCutNM: TMenuItem;
    pmiCutMail: TMenuItem;
    pmiDeleteNM: TMenuItem;
    pmiDeleteMail: TMenuItem;
    pmiPasteNM: TMenuItem;
    pmiPasteMail: TMenuItem;
    pmiRedoNM: TMenuItem;
    pmiRedoMail: TMenuItem;
    pmiSelectAllNM: TMenuItem;
    pmiSelectAllMail: TMenuItem;
    pmiSeparater6: TMenuItem;
    pmiSeparater7: TMenuItem;
    pmiUndoNM: TMenuItem;
    pmiUndoMail: TMenuItem;
    QAgenda: TSQLQuery;
    QBusca: TSQLQuery;
    QTl: TSQLQuery;
    Radio1proj: TRadioButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton7x: TRadioButton;
    RadioButton8x: TRadioButton;
    RadioTodos: TRadioButton;
    RadioTodosAt: TRadioButton;
    SBCal: TScrollBox;
    SBTar: TScrollBox;
    Separator1: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuNota1: TPopupMenu;
    MenuNota2: TPopupMenu;
    MenuNota3: TPopupMenu;
    MenuNota4: TPopupMenu;
    N10: TMenuItem;
    N11: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N2: TMenuItem;
    N21: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel103: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    Panel29: TPanel;
    Panel30: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    Panel33: TPanel;
    Panel34: TPanel;
    Panel35: TPanel;
    Panel36: TPanel;
    Panel37: TPanel;
    Panel38: TPanel;
    Panel39: TPanel;
    Panel4: TPanel;
    Panel40: TPanel;
    Panel41: TPanel;
    Panel53: TPanel;
    Panel54: TPanel;
    Panel55: TPanel;
    Panel56: TPanel;
    Panel57: TPanel;
    Panel58: TPanel;
    Panel59: TPanel;
    Panel60: TPanel;
    Panel61: TPanel;
    Panel65: TPanel;
    Panel66: TPanel;
    Panel67: TPanel;
    Panel68: TPanel;
    Panel69: TPanel;
    Panel70: TPanel;
    Panel73: TPanel;
    Panel74: TPanel;
    Panel75: TPanel;
    Panel76: TPanel;
    Panel77: TPanel;
    Panel78: TPanel;
    Panel79: TPanel;
    Panel80: TPanel;
    Panel81: TPanel;
    pmiCopy1: TMenuItem;
    pmiCopy2: TMenuItem;
    pmiCopy3: TMenuItem;
    pmiCopy4: TMenuItem;
    pmiCut1: TMenuItem;
    pmiCut2: TMenuItem;
    pmiCut3: TMenuItem;
    pmiCut4: TMenuItem;
    pmiDelete1: TMenuItem;
    pmiDelete2: TMenuItem;
    pmiDelete3: TMenuItem;
    pmiDelete4: TMenuItem;
    pmiPaste1: TMenuItem;
    pmiPaste2: TMenuItem;
    pmiPaste3: TMenuItem;
    pmiPaste4: TMenuItem;
    pmiRedo1: TMenuItem;
    pmiRedo2: TMenuItem;
    pmiRedo3: TMenuItem;
    pmiRedo4: TMenuItem;
    pmiSelectAll1: TMenuItem;
    pmiSelectAll2: TMenuItem;
    pmiSelectAll3: TMenuItem;
    pmiSelectAll4: TMenuItem;
    pmiSeparater2: TMenuItem;
    pmiSeparater3: TMenuItem;
    pmiSeparater4: TMenuItem;
    pmiSeparater5: TMenuItem;
    pmiUndo1: TMenuItem;
    pmiUndo2: TMenuItem;
    pmiUndo3: TMenuItem;
    pmiUndo4: TMenuItem;
    PopTar1: TPopupMenu;
    PopupEmailProj: TPopupMenu;
    PopupEmailProj1: TPopupMenu;
    PopupEmailTd: TPopupMenu;
    PopupLV1: TPopupMenu;
    PopupLV2: TPopupMenu;
    PopupMenu1: TPopupMenu;
    PopupPathSTV2: TPopupMenu;
    PopupPluginSpecial: TPopupMenu;
    QContAll: TSQLQuery;
    QContProj: TSQLQuery;
    QLinks: TSQLQuery;
    QMail: TSQLQuery;
    QMailAnx: TSQLQuery;
    QMailPess: TSQLQuery;
    QMarcCont: TSQLQuery;
    QMarcProj: TSQLQuery;
    QNotas: TSQLQuery;
    QRascu: TSQLQuery;
    QRascuAnx: TSQLQuery;
    QRascuCont: TSQLQuery;
    QTarAF: TSQLQuery;
    QTarFin: TSQLQuery;
    QTemp2: TSQLQuery;
    QTemp3: TSQLQuery;
    BitBtn1: TBitBtn;
    ColorSpeedButton14: TColorSpeedButton;
    ColorSpeedButton27: TColorSpeedButton;
    ColorSpeedButton29: TColorSpeedButton;
    ColorSpeedButton3: TColorSpeedButton;
    ColorSpeedButton47: TColorSpeedButton;
    ColorSpeedButton48: TColorSpeedButton;
    ColorSpeedButton49: TColorSpeedButton;
    ColorSpeedButton5: TColorSpeedButton;
    ColorSpeedButton50: TColorSpeedButton;
    ColorSpeedButton6: TColorSpeedButton;
    ComboBox1: TComboBox;
    Conn: TSQLite3Connection;
    Edit1: TEdit;
    HoldAvisos: TStrHolder;
    HoldNotasCel: TStrHolder;
    Image1: TImage;
    Image3: TImage;
    ImageList1: TImageList;
    Img1: TImageList;
    Img2: TImageList;
    Img4: TImageList;
    Label1: TLabel;
    Label24: TLabel;
    Label9: TLabel;
    Panel8: TPanel;
    PgBusca: TPage;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    Page3: TPage;
    Page4: TPage;
    Panel18: TPanel;
    Panel19: TPanel;
    playsound1: Tplaysound;
    QSTempx1: TSQLQuery;
    MenuItem39: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    N1: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    NB1: TNotebook;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    Panel9: TPanel;
    PgAgenda: TPage;
    PgAnota: TPage;
    PgArq: TPage;
    PgConfig: TPage;
    PgCont: TPage;
    PgEmail: TPage;
    PgIni: TPage;
    PgLink: TPage;
    PgTar: TPage;
    PopupMenuTV: TPopupMenu;
    QProj: TSQLQuery;
    QSQx: TSQLQuery;
    QTemp: TSQLQuery;
    QTemp1: TSQLQuery;
    RxSwitch1: TRxSwitch;
    SB1: TScrollBox;
    Separator3: TMenuItem;
    SGTl: TStringGrid;
    spBp1: TSpeedButton;
    spBp10: TSpeedButton;
    spBp11: TSpeedButton;
    spBp12: TSpeedButton;
    spBp13: TSpeedButton;
    spBp14: TSpeedButton;
    spBp15: TSpeedButton;
    spBp16: TSpeedButton;
    spBp17: TSpeedButton;
    spBp18: TSpeedButton;
    spBp19: TSpeedButton;
    spBp2: TSpeedButton;
    spBp20: TSpeedButton;
    spBp3: TSpeedButton;
    spBp4: TSpeedButton;
    spBp5: TSpeedButton;
    spBp6: TSpeedButton;
    spBp7: TSpeedButton;
    spBp8: TSpeedButton;
    spBp9: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton59: TSpeedButton;
    SpeedButton60: TSpeedButton;
    SpeedButton62: TSpeedButton;
    SpeedButton63: TSpeedButton;
    Splitter1: TSplitter;
    Splitter10: TSplitter;
    Splitter11: TSplitter;
    Splitter12: TSplitter;
    Splitter14: TSplitter;
    Splitter15: TSplitter;
    Splitter16: TSplitter;
    Splitter17: TSplitter;
    Splitter18: TSplitter;
    Splitter2: TSplitter;
    Splitter20: TSplitter;
    Splitter21: TSplitter;
    Splitter22: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    Splitter6: TSplitter;
    Splitter7: TSplitter;
    Splitter8: TSplitter;
    Splitter9: TSplitter;
    HoldTemp: TStrHolder;
    STV1: TShellTreeView;
    STV2: TShellTreeView;
    STV3: TShellTreeView;
    T1: TTimer;
    T2: TTimer;
    TabSheet21: TTabSheet;
    TabSheet22: TTabSheet;
    Temp: TPage;
    TimerAvisos: TTimer;
    TimerDown: TTimer;
    TimerPanel: TTimer;
    TimerCreate: TTimer;
    TL: TTimer;
    TrackBar1: TTrackBar;
    Trans: TSQLTransaction;
    TV: TTreeView;
    TVa: TTreeView;
    TVb: TTreeView;
    TVc: TTreeView;
    TVFolders: TTreeView;
    TVGmail: TTreeView;
    UniqueInstance1: TUniqueInstance;
    procedure ATButton100Click(Sender: TObject);
    procedure ATButton101Click(Sender: TObject);
    procedure ATButton109Click(Sender: TObject);
    procedure ATButton10Click(Sender: TObject);
    procedure ATButton110Click(Sender: TObject);
    procedure ATButton17Click(Sender: TObject);
    procedure ATButton60Click(Sender: TObject);
    procedure ATButton8Click(Sender: TObject);
    procedure ATButton9Click(Sender: TObject);
    procedure ATButton15Click(Sender: TObject);
    procedure ATButton16Click(Sender: TObject);
    procedure ATButton18Click(Sender: TObject);
    procedure ATButton20Click(Sender: TObject);
    procedure ATButton21Click(Sender: TObject);
    procedure ATButton25Click(Sender: TObject);
    procedure ATButton27Click(Sender: TObject);
    procedure ATButton28Click(Sender: TObject);
    procedure ATButton30Click(Sender: TObject);
    procedure ATButton31Click(Sender: TObject);
    procedure ATButton34Click(Sender: TObject);
    procedure ATButton36Click(Sender: TObject);
    procedure ATButton38Click(Sender: TObject);
    procedure ATButton42Click(Sender: TObject);
    procedure ATButton48Click(Sender: TObject);
    procedure ATButton55Click(Sender: TObject);
    procedure ATButton59Click(Sender: TObject);
    procedure ATButton62Click(Sender: TObject);
    procedure ATButton75Click(Sender: TObject);
    procedure ATButton76Click(Sender: TObject);
    procedure ATButton77Click(Sender: TObject);
    procedure ATButton78Click(Sender: TObject);
    procedure ATButton7Click(Sender: TObject);
    procedure ATButton99Click(Sender: TObject);
    procedure ATLabelLink1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox11Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox2xChange(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckTChange(Sender: TObject);
    procedure ColorSpeedButton100Click(Sender: TObject);
    procedure ColorSpeedButton101Click(Sender: TObject);
    procedure ColorSpeedButton102Click(Sender: TObject);
    procedure ColorSpeedButton103Click(Sender: TObject);
    procedure ColorSpeedButton104Click(Sender: TObject);
    procedure ColorSpeedButton105Click(Sender: TObject);
    procedure ColorSpeedButton106Click(Sender: TObject);
    procedure ColorSpeedButton107Click(Sender: TObject);
    procedure ColorSpeedButton108Click(Sender: TObject);
    procedure ColorSpeedButton109Click(Sender: TObject);
    procedure ColorSpeedButton110Click(Sender: TObject);
    procedure ColorSpeedButton111Click(Sender: TObject);
    procedure ColorSpeedButton112Click(Sender: TObject);
    procedure ColorSpeedButton113Click(Sender: TObject);
    procedure ColorSpeedButton114Click(Sender: TObject);
    procedure ColorSpeedButton115Click(Sender: TObject);
    procedure ColorSpeedButton116Click(Sender: TObject);
    procedure ColorSpeedButton117Click(Sender: TObject);
    procedure ColorSpeedButton118Click(Sender: TObject);
    procedure ColorSpeedButton119Click(Sender: TObject);
    procedure ColorSpeedButton120Click(Sender: TObject);
    procedure ColorSpeedButton17Click(Sender: TObject);
    procedure ColorSpeedButton34Click(Sender: TObject);
    procedure ColorSpeedButton36Click(Sender: TObject);
    procedure ColorSpeedButton37Click(Sender: TObject);
    procedure ColorSpeedButton38Click(Sender: TObject);
    procedure ColorSpeedButton39Click(Sender: TObject);
    procedure ColorSpeedButton40Click(Sender: TObject);
    procedure ColorSpeedButton45Click(Sender: TObject);
    procedure ColorSpeedButton51Click(Sender: TObject);
    procedure ColorSpeedButton64Click(Sender: TObject);
    procedure ColorSpeedButton65Click(Sender: TObject);
    procedure ColorSpeedButton66Click(Sender: TObject);
    procedure ColorSpeedButton77Click(Sender: TObject);
    procedure ColorSpeedButton78Click(Sender: TObject);
    procedure ColorSpeedButton84Click(Sender: TObject);
    procedure ColorSpeedButton86Click(Sender: TObject);
    procedure ColorSpeedButton93Click(Sender: TObject);
    procedure ColorSpeedButton94Click(Sender: TObject);
    procedure ColorSpeedButton95Click(Sender: TObject);
    procedure ColorSpeedButton96Click(Sender: TObject);
    procedure ColorSpeedButton97Click(Sender: TObject);
    procedure ColorSpeedButton98Click(Sender: TObject);
    procedure ColorSpeedButton99Click(Sender: TObject);
    procedure DBGrid4GetCellHint(Sender: TObject; Column: TColumn;
      var AText: String);
    procedure DBGrid5GetCellHint(Sender: TObject; Column: TColumn;
      var AText: String);
    procedure DBGrid7DblClick(Sender: TObject);
    procedure DBGrid9DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DBGrid9DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DBMemo2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DE10EditingDone(Sender: TObject);
    procedure DE6EditingDone(Sender: TObject);
    procedure DE7EditingDone(Sender: TObject);
    procedure DE8EditingDone(Sender: TObject);
    procedure DE9EditingDone(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure LBCalGooSelectionChange(Sender: TObject; User: boolean);
    procedure ColorSpeedButton10Click(Sender: TObject);
    procedure ColorSpeedButton11Click(Sender: TObject);
    procedure ColorSpeedButton12Click(Sender: TObject);
    procedure ColorSpeedButton13Click(Sender: TObject);
    procedure ColorSpeedButton14Click(Sender: TObject);
    procedure ColorSpeedButton16Click(Sender: TObject);
    procedure ColorSpeedButton1Click(Sender: TObject);
    procedure ColorSpeedButton27Click(Sender: TObject);
    procedure ColorSpeedButton29Click(Sender: TObject);
    procedure ColorSpeedButton2Click(Sender: TObject);
    procedure ColorSpeedButton30Click(Sender: TObject);
    procedure ColorSpeedButton31Click(Sender: TObject);
    procedure ColorSpeedButton32Click(Sender: TObject);
    procedure ColorSpeedButton33Click(Sender: TObject);
    procedure ColorSpeedButton35Click(Sender: TObject);
    procedure ColorSpeedButton3Click(Sender: TObject);
    procedure ColorSpeedButton41Click(Sender: TObject);
    procedure ColorSpeedButton42Click(Sender: TObject);
    procedure ColorSpeedButton43Click(Sender: TObject);
    procedure ColorSpeedButton44Click(Sender: TObject);
    procedure ColorSpeedButton46Click(Sender: TObject);
    procedure ColorSpeedButton47Click(Sender: TObject);
    procedure ColorSpeedButton48Click(Sender: TObject);
    procedure ColorSpeedButton49Click(Sender: TObject);
    procedure ColorSpeedButton4Click(Sender: TObject);
    procedure ColorSpeedButton50Click(Sender: TObject);
    procedure ColorSpeedButton52Click(Sender: TObject);
    procedure ColorSpeedButton53Click(Sender: TObject);
    procedure ColorSpeedButton54Click(Sender: TObject);
    procedure ColorSpeedButton55Click(Sender: TObject);
    procedure ColorSpeedButton56Click(Sender: TObject);
    procedure ColorSpeedButton57Click(Sender: TObject);
    procedure ColorSpeedButton58Click(Sender: TObject);
    procedure ColorSpeedButton59Click(Sender: TObject);
    procedure ColorSpeedButton5Click(Sender: TObject);
    procedure ColorSpeedButton60Click(Sender: TObject);
    procedure ColorSpeedButton61Click(Sender: TObject);
    procedure ColorSpeedButton62Click(Sender: TObject);
    procedure ColorSpeedButton63Click(Sender: TObject);
    procedure ColorSpeedButton67Click(Sender: TObject);
    procedure ColorSpeedButton69Click(Sender: TObject);
    procedure ColorSpeedButton6Click(Sender: TObject);
    procedure ColorSpeedButton72Click(Sender: TObject);
    procedure ColorSpeedButton73Click(Sender: TObject);
    procedure ColorSpeedButton75Click(Sender: TObject);
    procedure ColorSpeedButton76Click(Sender: TObject);
    procedure ColorSpeedButton7Click(Sender: TObject);
    procedure ColorSpeedButton80Click(Sender: TObject);
    procedure ColorSpeedButton81Click(Sender: TObject);
    procedure ColorSpeedButton82Click(Sender: TObject);
    procedure ColorSpeedButton88Click(Sender: TObject);
    procedure ColorSpeedButton8Click(Sender: TObject);
    procedure ColorSpeedButton9Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DBGrid10DblClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid4CellClick(Column: TColumn);
    procedure DBGrid5CellClick(Column: TColumn);
    procedure DBGrid6DblClick(Sender: TObject);
    procedure DBGrid6KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure DBGrid7TitleClick(Column: TColumn);
    procedure DBGrid8DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure DBGrid8DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure DBGrid8TitleClick(Column: TColumn);
    procedure DBGrid9TitleClick(Column: TColumn);
    procedure DCalClick(Sender: TObject);
    procedure DCalDblClick(Sender: TObject);
    procedure DCalDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure DCalDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure DCalDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DE10AcceptDirectory(Sender: TObject; var Value: string);
    procedure DE6AcceptDirectory(Sender: TObject; var Value: string);
    procedure DE7AcceptDirectory(Sender: TObject; var Value: string);
    procedure DE8AcceptDirectory(Sender: TObject; var Value: string);
    procedure DE9AcceptDirectory(Sender: TObject; var Value: string);
    procedure DSContAllDataChange(Sender: TObject; Field: TField);
    procedure DSContProjDataChange(Sender: TObject; Field: TField);
    procedure DSMailDataChange(Sender: TObject; Field: TField);
    procedure DSRascuDataChange(Sender: TObject; Field: TField);
    procedure DSRascuStateChange(Sender: TObject);
    procedure EdBuscaKeyPress(Sender: TObject; var Key: char);
    procedure Edit1Change(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure Edit8Change(Sender: TObject);
    procedure FLV1ButtonClick(Sender: TObject);
    procedure FLV1KeyPress(Sender: TObject; var Key: char);
    procedure FLV2ButtonClick(Sender: TObject);
    procedure FLV2KeyPress(Sender: TObject; var Key: char);
    procedure FLV3ButtonClick(Sender: TObject);
    procedure FLV3KeyPress(Sender: TObject; var Key: char);
    procedure FLV4ButtonClick(Sender: TObject);
    procedure FLV4KeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LBPeopGooSelectionChange(Sender: TObject; User: boolean);
    procedure LBTarGooSelectionChange(Sender: TObject; User: boolean);
    procedure ListBox1DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure ListBox1DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure ListBox1xClick(Sender: TObject);
    procedure ListBox2DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure ListBox2DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure ListViewFilterEdit1Change(Sender: TObject);
    procedure ListViewFilterEdit2Change(Sender: TObject);
    procedure LV1DblClick(Sender: TObject);
    procedure LV1DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure LV1DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure LV2DblClick(Sender: TObject);
    procedure LV2DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure LV2DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure LV2KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure LVAudioDblClick(Sender: TObject);
    procedure LVMessagesClick(Sender: TObject);
    procedure LVMessagesDblClick(Sender: TObject);
    procedure LVMessagesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Memo1KeyPress(Sender: TObject; var Key: char);
    procedure Memo2KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Memo2KeyPress(Sender: TObject; var Key: char);
    procedure Memo3KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Memo3KeyPress(Sender: TObject; var Key: char);
    procedure Memo4KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Memo4KeyPress(Sender: TObject; var Key: char);
    procedure MemoPjKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure MemoPjKeyPress(Sender: TObject; var Key: char);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem31Click(Sender: TObject);
    procedure MenuItem34Click(Sender: TObject);
    procedure MenuItem36Click(Sender: TObject);
    procedure MenuItem37Click(Sender: TObject);
    procedure MenuItem38Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem40Click(Sender: TObject);
    procedure MenuItem41Click(Sender: TObject);
    procedure MenuItem43Click(Sender: TObject);
    procedure MenuItem44Click(Sender: TObject);
    procedure MenuItem45Click(Sender: TObject);
    procedure MenuItem46Click(Sender: TObject);
    procedure MenuItem47Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure PanelAvisosClick(Sender: TObject);
    procedure PanelAvisosDblClick(Sender: TObject);
    procedure QLinksBeforePost(DataSet: TDataSet);
    procedure QProjAfterScroll(DataSet: TDataSet);
    procedure QProjBeforeScroll(DataSet: TDataSet);
    procedure QRascuAfterPost(DataSet: TDataSet);
    procedure QTarAFAfterInsert(DataSet: TDataSet);
    procedure RadioButton7xChange(Sender: TObject);
    procedure RadioButton8xChange(Sender: TObject);
    procedure RxSwitch1Click(Sender: TObject);
    procedure SGTlDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure spBp11Click(Sender: TObject);
    procedure spBp1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton59Click(Sender: TObject);
    procedure SpeedButton60Click(Sender: TObject);
    procedure SpeedButton62Click(Sender: TObject);
    procedure SpeedButton63Click(Sender: TObject);
    procedure Splitter5Moved(Sender: TObject);
    procedure STV1Change(Sender: TObject; Node: TTreeNode);
    procedure STV1GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure STV1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure STV2Change(Sender: TObject; Node: TTreeNode);
    procedure STV2GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure STV2GetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure STV2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure STV3Change(Sender: TObject; Node: TTreeNode);
    procedure STV3GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure STV3GetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure T1Timer(Sender: TObject);
    procedure T2Timer(Sender: TObject);
    procedure TimerAvisosTimer(Sender: TObject);
    procedure TimerCreateTimer(Sender: TObject);
    procedure TimerDownTimer(Sender: TObject);
    procedure TimerPanelTimer(Sender: TObject);
    procedure TLTimer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TVaChange(Sender: TObject; Node: TTreeNode);
    procedure TVaDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure TVaDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure TVbDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure TVbDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure TVcDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure TVcDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure TVChange(Sender: TObject; Node: TTreeNode);
    procedure TVChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: boolean);
    procedure TVDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure TVDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure CriarHistory();

    procedure DoUserConsentGmail(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentCal(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentTasks(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentPeop(const AURL: string; Out AAuthCode: string);
    procedure DoUserConsentDrive(const AURL: string; Out AAuthCode: string);
    procedure TVFoldersSelectionChanged(Sender: TObject);
    procedure TVGmailSelectionChanged(Sender: TObject);

  private
    PastaLxWnVazia, FirstUse: boolean;
    PastaDrop, PastaDown, PastaDropCelTar, PastaDropAudio, PastaModels,
    ArqTarefasNoSimpleText, ArqPersistNoSimpleText: string;
    Magic, fConnName: string;
    TLTime, AvisoCnt: integer;
    PastaProj,PastaProjAtual: string;
    NaoVeioDaGrid: boolean;
    History1, History2, History3, History4, HistoryP, HistoryNM, HistoryMail: THistory;
    MudouMemos: boolean;
    LastSearch: string;
    DaysLeft, TR, VR, DiaClick: integer;
    DDate: System.TDate; // googlepeople tem TDate, o que confunde tudo.
    PassaDireto: boolean;
    DiasColRow: array [0..6, 0..6] of integer;
    ClientId, ClientSecret, accessTokenGmail, RefreshTokenGmail: string;
//    messageRFC2822: string;
    response: xquery.IXQValue;
    FClientGmail,FClientCal,FClientTasks,FClientPeop,FClientDrive: TGoogleClient;

    //GMail
    FGmailAPI: TGmailAPI;

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

    //Drive
    FDriveAPI: TDriveAPI;

    MemoTarGooStr: String;
    MemoTarGooInt: Integer;

    LastTempMail: Integer;

    procedure AtlzRegRascu();
    procedure LerContAll(OrderBy: string);
    procedure STV2DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure STV2DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: boolean);
    procedure PopTV();
    procedure AbrirProj();
    procedure RefazerPosicaoProj();
    procedure MudarSituacao(NovaSituacao: integer);
    procedure PopTVx();
    function ContarReg(Situacao: integer): string;
    procedure ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
    procedure ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
    procedure ConfigSalvarBol(CfgTb, Coluna: string; Valor: boolean);
    function ConfigLerStr(CfgTb, Coluna: string): string;
    function ConfigLerInt(CfgTb, Coluna: string): integer;
    function ConfigLerBol(CfgTb, Coluna: string): boolean;
    function criptografar(const key, texto: string): string;
    function descriptografar(const key, texto: string): string;
    procedure Ler_Audios();
    procedure Ler_PastaAudios();
    procedure AddFilesToLV(FLV: TListViewFilterEdit; LV: TListView; FilePathName: string);
    procedure AcaoBut(SitTo: string; TreeFrom: TTreeNode);
    procedure RefazerPosicaoX(Situa: string);
    procedure Ler_ArqProj();
    procedure CheckPastaLxWn();
    procedure LV1Abrir;
    procedure LV2Abrir;
    procedure RefazerPosicoesTar(AF, Fin: boolean);
    procedure LerTar();
    procedure actnTextExecute(Sender: TObject);
    procedure actnUndoUpdate(Sender: TObject);
    procedure actnCutUpdate(Sender: TObject);
    procedure AbrirLinks();
    procedure AddMarker(Sender: TObject);
    procedure OrgMarker(Sender: TObject);
    procedure LerContProj(OrderBy: string);
    procedure LerMarcsProj();
    procedure LerMarcsCont();
    function SendToRaw1(const MailFrom, MailTo, SMTPHost: string;
      const MailData: TStrings; const Username, Password: string): Boolean;
    function MyFindInMemo(AMemo: TCustomMemo; AString: string; arr: integer): integer;
    procedure LerEmail(OrderBy: string);
    function RemoveAspasDuplas(S: string): string;
    procedure btnClickEvent(Sender: TObject);
    procedure LerRascu();
    procedure LerRascuCont();
    procedure LerRascuAnx();
    procedure AtualizarAnalogico(x: integer);
    procedure FillCalendChose(); //É chamado nos botões Delete e Edit da Agenda
    function DTtoJulian(D: System.TDateTime; Ano, Mes, Dia, H, Mn, Seg, mS: word): string;
    procedure LerAgendaMes();
    function IntToMes(i: integer): string;
    procedure AjeitarTamanhoColunasAgenda;
    procedure ContarNotas();
    procedure Salvar_Tl();
    procedure Ler_Tl();
    function IntToLetra(M: System.TDate): string;
    function EncodeUrl(url: string): string;
    procedure LoadAuthConfig(scope: string);
    procedure SaveRefreshToken(scope: string);
    function ExtDiaSemana(D:System.TDate): String;
    procedure panCalMouseEnter(Sender: TObject);
    procedure panCalMouseLeave(Sender: TObject);
    procedure panCalDoubleClick(Sender: TObject);
    procedure MemTarKeyPress(Sender: TObject; var Key: char);
    procedure MemTarOnEnter(Sender: TObject);
    procedure MemTarOnExit(Sender: TObject);
    procedure ClearTreeViewGmail;
    procedure ClearTreeViewDrive;
    procedure AddLabels;
    function CreateNodeWithTextPath(TextPath: string): TTreeNode;
    procedure BRefreshFilesClick(Sender: TObject);
    procedure ShowLabelGmail(ALabelID: String);
    procedure ClearMailListView;
    Procedure CreateDescGmail(E : TMessage; var Desc : TMailDescription);
    procedure AbrirEmailEML(HldSrc: TStrHolder; Decode: Bool);
    procedure AddFolders(AParent: TTreeNode; AFolderID: String);
    procedure ShowFolder(AFolderID : String);
    procedure ClearFileListView;
    procedure SalvarRegistro(Chave,Str: String);
    function LerRegistro(Chave: String): String;
    function TirarAcento(St:String):String;
  public
    ProjAtual, ProjAnterior: integer;
  end;

var
  Form1: TForm1;
  StartingPoint: TPoint;
  SearchAfterPos: array[0..3] of integer;

implementation

uses
  fphttpwebclient,
  jsonparser, // needed
  fpjson,
  fpoauth2,
  fpwebclient;


{$R *.lfm}

{ TForm1 }

type
  TShellTreeViewOpener = class(TShellTreeView); //Necessário para drag&drop nos ShellTreeView

function CreateFileDropSite(const AControl: TControl; //Necessário para dropfile no LV2
  const ADropFilesEvent: TDropFilesEvent): TForm;
begin
  Result := TForm.Create(AControl);
  Result.AllowDropFiles := True;
  Result.BorderStyle := bsNone;
  Result.BoundsRect := AControl.BoundsRect;
  Result.Align := AControl.Align;
  Result.Parent := AControl.Parent;
  Result.OnDropFiles := ADropFilesEvent;
  AControl.Parent := Result;
  AControl.Align := alClient;
  Result.Visible := True;
end;


//Esse procedimento abaixo não pode colocar TForm1 na frente, se não dá merda.
//Tem que ficar antes dos procedimentos que o chamam.
procedure DrawPieSlice(const Canvas: TCanvas; const Center: TPoint;
  const Radius: integer; const StartDegrees, StopDegrees: double);
// Get inhttps://stackoverflow.com/questions/41635622/delphi-draw-a-arc-in-high-resolution
const
  Offset = 90;
var
  X1, X2, X3, X4: integer;
  Y1, Y2, Y3, Y4: integer;
begin
  X1 := Center.X - Radius;
  Y1 := Center.Y - Radius;
  X2 := Center.X + Radius;
  Y2 := Center.Y + Radius;
  X4 := Center.X + Round(Radius * Cos(DegToRad(Offset + StartDegrees)));
  Y4 := Center.y - Round(Radius * Sin(DegToRad(Offset + StartDegrees)));
  X3 := Center.X + Round(Radius * Cos(DegToRad(Offset + StopDegrees)));
  Y3 := Center.y - Round(Radius * Sin(DegToRad(Offset + StopDegrees)));
  Canvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TForm1.SalvarRegistro(Chave,Str: String);
var reg: TRegistry;
begin
reg := TRegistry.Create;
reg.OpenKey('Software\GPProj', true);
reg.WriteString(Chave, Str);
reg.Free;
end;

function TForm1.LerRegistro(Chave: String): String;
var reg: TRegistry;
begin
reg := TRegistry.Create;
reg.OpenKey('Software\GPProj', true);
Result:=reg.ReadString(Chave);
reg.Free;
end;

function DecodeUrl(url: string): string;
var
  x: integer;
  ch: string;
  sVal: string;
  Buff: string;
begin
  //Init
  Buff := '';
  x := 1;
  while x <= Length(url) do
  begin
    //Get single char
    ch := url[x];

    if ch = '+' then
    begin
      //Append space
      Buff := Buff + ' ';
    end
    else if ch <> '%' then
    begin
      //Append other chars
      Buff := Buff + ch;
    end
    else
    begin
      //Get value
      sVal := Copy(url, x + 1, 2);
      //Convert sval to int then to char
      Buff := Buff + char(StrToInt('$' + sVal));
      //Inc counter by 2
      Inc(x, 2);
    end;
    //Inc counter
    Inc(x);
  end;
  //Return result
  Result := Buff;
end;

function TForm1.EncodeUrl(url: string): string;
var
  x: integer;
  sBuff: string;
const
  SafeMask = ['A'..'Z', '0'..'9', 'a'..'z', '*', '@', '.', '_', '-'];
begin
  sBuff := '';
  for x := 1 to Length(url) do
  begin
    if url[x] in SafeMask then
    begin
      sBuff := sBuff + url[x];
    end
    else if url[x] = ' ' then
    begin
      sBuff := sBuff + '+';
    end
    else
    begin
      sBuff := sBuff + '%' + IntToHex(Ord(url[x]), 2);
    end;
  end;
  Result := sBuff;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  P: TProcess;
begin
  P := TProcess.Create(nil);
  P.Executable := 'qt5ct';
  P.Execute;
  P.Active := True;
  P.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
//Testando envio de e-mails. Botão permanece invisível.
var
 P:TMimePart;
 M:TMimeMess;
 i,j,lh:integer;
 UserEmailx,UserPasswx,S,login,dest,Prefix:String;
begin
dest:='camargo.ufpr@gmail.com';
try
 M:=TMimeMess.Create;
 M.header.Subject:='Teste de subject do 17';
 M.header.Date:=Now;
 M.header.ToList.Add(dest);
 P:=M.AddPartMultipart('mixed',nil);
 P.ConvertCharset:=False;
 M.AddPartTextEx(Memo1.lines,P,TMimeChar.UTF_8,false,TMimeEncoding.ME_BASE64);
 M.EncodeMessage;
 UserEmailx:='camargofurg@gmail.com';

 UserPasswx:='rteldubqtkffkzoz';  //Senha de App. ToDo: ler do banco de dados
 UserPasswx:='pzdouwtazqfzfuix';  //Ambas funcionam

 login:=copy(UserEmailx,1,pos('@',UserEmailx)-1);
 if SendToRaw1(UserEmailx,dest,'smtp.gmail.com:465&SSL',M.Lines,login,UserPasswx) then begin
  MessageDlg('E-mail enviado com SUCESSO!!!',mtInformation,[mbOk],0);
 end else begin
  MessageDlg('E-mail NÃO ENVIADO.',mtInformation,[mbOk],0);
 end;
finally begin
 Screen.Cursor:=CrDefault;
 M.Free;
end;
end;
end;

procedure TForm1.CheckBox11Click(Sender: TObject);
var
  F, P: string;
begin
  F := STV1.Root; //Único jeito de atualizar
  P := STV1.Path;
  STV1.Root := '';
  //FileSortType foi mudado na fonte. VER ISSO.
  if STV1.FileSortType = fstAlphabet then STV1.FileSortType := fstFoldersFirst
  else
    STV1.FileSortType := fstAlphabet;
  STV1.Root := F;
  STV1.Path := P;
end;

procedure TForm1.ATButton16Click(Sender: TObject);
begin
  ShowMessage(rs_AjudaConfig);
end;

procedure TForm1.ATButton18Click(Sender: TObject);
var
  d: System.TDateTime;
begin
  if TV.Items.Count = 0 then Exit;

  FormTarefa.Edit1.Text := '';
  FormTarefa.DTP.Date := Date + 1;

  if FormTarefa.ShowModal <> mrOk then Exit;

  if FormTarefa.Edit1.Text = '' then
  begin
    MessageDlg(rs_NoTextInf, mtError, [mbOK], 0);
    Exit;
  end;

  NaoVeioDaGrid := True;

  QTarFin.Close; //Vai abrir com LerTar()

  if not QTarAF.Active then QTarAF.Open;

  QTarAF.First;
  d := FormTarefa.DTP.Date;
  QTarAF.Insert;
  QTarAF.FieldByName('Tarefa').AsString := FormTarefa.Edit1.Text;
  QTarAF.FieldByName('ProjID').AsInteger := QProj.Fields[0].AsInteger;
  QTarAF.FieldByName('Prazo').AsDateTime :=
    EncodeDateTime(YearOf(d), MonthOf(d), DayOf(d), FormTarefa.SpHora.Value,
    FormTarefa.SpMin.Value, 0, 0);
  QTarAF.FieldByName('DataCriacao').AsDateTime := Now;
  QTarAF.FieldByName('Situacao').AsInteger := 1;
  QTarAF.FieldByName('Posicao').AsInteger := -1;
  QTarAF.Post;
  RefazerPosicoesTar(True, False);
  LerTar();
end;

//Tirado não sei de onde.
//A função substitui SendToRaw da Unit SMTPSend1.
//Ela é chamada para enviar e-mails
function TForm1.SendToRaw1(const MailFrom, MailTo, SMTPHost: string;
  const MailData: TStrings; const Username, Password: string): Boolean;
var
  SMTP: TSMTPSend;
  s, t, hos, por, SSL: string;
  nps, nss: integer;
begin
  // modified by Patyi
  //   SMTPHost parameter is expanded with TLS/SSLx enable part, example :
  //   for GMail host parameter: 'smtp.gmail.com:465&SSL'
  // where ':' is port separator as before, '&' is the new for TLS/SSLx enabling separator.

  Result := False;
  SMTP := TSMTPSend.Create;
  try
    s := Trim(SMTPHost); // string represent host, port and TLS/SSLx option
    nps := Pos(':', s);  // ':' port separator position
    nss := Pos('&', s);  // '&' TLS/SSLx  separator position
    if (nps = 0) and (nss = 0) then begin // only host is given, no port, no TLS/SSLx
      hos := s;
      por := '';  // default port is 25
      SSL := '';
    end else if (nps > 0) and (nss = 0) then begin // host and port is given, no TLS/SSLx
      hos := Trim(Copy(s, 1, nps-1));
      por := Trim(Copy(s, nps+1, 10));  // users port
      SSL := '';
    end else if (nps = 0) and (nss > 0) then begin // host and TLS/SSLx is given, no port
      hos := Trim(Copy(s, 1, nss-1));
      por := '587'; // if TLS then default port is 587
      SSL := Trim(Copy(s, nss+1, 10)); // TLS or SSLx
      if Pos('SSL', SSL) > 0 then
        por := '465'; // if SSLx then default port is 465
    end else if (nps > 0) and (nss > 0) then begin // host, port and TLS/SSLx given
      hos := Trim(Copy(s, 1, nps-1));
      por := Trim(Copy(s, nps+1, nss-nps-1)); // users port
      SSL := Trim(Copy(s, nss+1, 10));  // TLS or SSLx for enabling TLS/SSLx
    end;

    // if you need SOCKS5 support, uncomment next lines:
//    SMTP.Sock.SocksIP := '127.0.0.1';
//    SMTP.Sock.SocksPort := '1080';
    if Pos('TLS', SSL) > 0 then  // if TLS is enabled
      SMTP.AutoTLS := True;
    if Pos('SSL', SSL) > 0 then  // if SSLx is enabled
      SMTP.FullSSL := True;

    SMTP.TargetHost := hos;
    if por > '' then  // if different port is given
      SMTP.TargetPort := por;
    SMTP.Username := Username;
    SMTP.Password := Password;

    if SMTP.Login then begin
        if SMTP.MailFrom(GetEmailAddr(MailFrom),
                       Length(MailData.Text)) then begin
        s := MailTo;
        repeat
          t := GetEmailAddr(Trim(FetchEx(s, ',', '"')));
          if t <> '' then
            Result := SMTP.MailTo(t);
          if not Result then
            Break;
        until s = '';
        if Result then begin
         //Screen.Cursor:=crDefault;
         //Application.ProcessMessages; //Não funciona
          Result := SMTP.MailData(MailData);
        end;
      end;
      SMTP.Logout;
    end;
  finally
    SMTP.Free;
  end;
end;

procedure TForm1.ATButton109Click(Sender: TObject);
var
  S: string;
begin
  CheckPastaLxWn();
  if LV1.ItemFocused = nil then
    if LV1.Items.Count > 0 then
      LV1.ItemFocused := LV1.Items[0]
    else
      Exit;
  if MessageDlg(rs_DelFile + LV1.ItemFocused.Caption + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    S := STV1.Path + LV1.ItemFocused.Caption;
    if not FileExistsUTF8(S) then Exit;
    DeleteFile(S);
    ATButton34Click(Self);
  end;
end;

procedure TForm1.ATButton100Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  FillCalendChose();
  if not PassaDireto then if FormCalendChose.ShowModal <> mrOk then Exit;
  FormCalendChose.QAgChose.Delete;
  LerAgendaMes();
end;

procedure TForm1.ATButton101Click(Sender: TObject);
var
  Dt: System.TDateTime;
  H, M: integer;
begin
  if TV.Items.Count = 0 then Exit;
  FillCalendChose();

  if not PassaDireto then if FormCalendChose.ShowModal <> mrOk then Exit;

  FormCalend.Edit1.Text := FormCalendChose.QAgChose.FieldByName('Evento').AsString;
  FormCalend.DTP1.Date := FormCalendChose.QAgChose.FieldByName('Data').AsDateTime;
  FormCalend.SpinEdit1.Value := HourOf(FormCalendChose.QAgChose.FieldByName(
    'Data').AsDateTime);
  FormCalend.SpinEdit2.Value := MinuteOf(FormCalendChose.QAgChose.FieldByName(
    'Data').AsDateTime);
  if (FormCalend.SpinEdit1.Value = 0) and (FormCalend.SpinEdit2.Value = 0) then
    FormCalend.CheckBox1.Checked := True
  else
    FormCalend.CheckBox1.Checked := False;

  if FormCalend.ShowModal <> mrOk then Exit;

  Dt := FormCalend.DTP1.Date;
  if FormCalend.CheckBox1.Checked then
  begin
    H := 0;
    M := 0;
  end
  else
  begin
    H := FormCalend.SpinEdit1.Value;
    M := FormCalend.SpinEdit2.Value;
  end;

  Dt := EncodeDateTime(YearOf(Dt), MonthOf(Dt), DayOf(Dt), H, M, 0, 0);

  FormCalendChose.QAgChose.Edit;
  FormCalendChose.QAgChose.FieldByName('Evento').AsString := FormCalend.Edit1.Text;
  FormCalendChose.QAgChose.FieldByName('Data').AsDateTime := Dt;
  FormCalendChose.QAgChose.Post;

  LerAgendaMes();

end;

procedure TForm1.ATButton10Click(Sender: TObject);
begin
  OrgMarker(Sender);
end;

procedure TForm1.ATButton110Click(Sender: TObject);
begin
  STV2.Root := STV1.Root;
  ATButton36Click(Self);
end;

procedure TForm1.ATButton17Click(Sender: TObject);
begin
ConfigSalvarStr('ConfigTB', 'UserEmail', Edit3.Text);
ConfigSalvarStr('ConfigTB', 'UserPassw', Edit7.Text);
end;

procedure TForm1.ATButton60Click(Sender: TObject);
begin
Edit6.Text:='';
end;

procedure TForm1.ATButton8Click(Sender: TObject);
begin
QProj.Edit;
QProj.FieldByName('ProjInfo').AsString := MemoPj.Lines.Text;
QProj.Post;
end;

procedure TForm1.ATButton9Click(Sender: TObject);
//Filtros para marcadores de projetos
var
  i, j: integer;
  S: string;
begin
  FormMarc.Caption := rs_FiltProj;
  FormMarc.ATButton1.Visible := True;
  FormMarc.ATButton2.Visible := True;
  FormMarc.ATButton15.Visible := True;
  FormMarc.CLB.Clear;
  QTemp.Close;
  QTemp.SQL.Text := 'Select distinct Marcador from MarcsProjTB order by Marcador COLLATE NOCASE';
  QTemp.Open;
  while not QTemp.EOF do
  begin
    FormMarc.CLB.Items.Add(QTemp.FieldByName('Marcador').AsString);
    QTemp.Next;
  end;

  ATButton9.Checkable := False;

  if ATButton9.Checked then
  begin
    QProj.Close;
    QProj.SQL.Text := 'Select * from ProjsTB where Situacao=1 order by Posicao COLLATE NOCASE';
    QProj.Open;
    PopTV();
    AbrirProj;
    ATButton9.Checked := False;
    Panel3.Visible := True;
    Exit;
  end;

  j := 0;

  FormMarc.Filtro := True;

  if FormMarc.ShowModal <> mrOk then
  begin
    ATButton9.Checked := False;
    Panel1.Visible := True;
    Exit;
  end
  else
  begin
    S := '';
    for i := 0 to FormMarc.CLB.Items.Count - 1 do
      if FormMarc.CLB.Checked[i] = True then
      begin
        S := S + ' ((MarcsProjTB.Marcador)="' + FormMarc.CLB.Items[i] + '") OR ';
        j := j + 1;
      end;
    S := Copy(S, 1, Length(S) - 3);
    if j = 0 then
    begin
      ATButton9.Checked := False;
      Panel3.Visible := True;
      Exit;
    end
    else
    begin
      //  S:='SELECT distinct * '+ //Não funciona. Tem que discriminar todos os campos.
      S := 'SELECT Distinct ProjsTB.ID_Proj,ProjsTB.Posicao,ProjsTB.ProjName,ProjsTB.ProjInfo,ProjsTB.ProjDate,ProjsTB.Icons,ProjsTB.PastaLx,ProjsTB.PastaWd,ProjsTB.PastaMc,ProjsTB.Situacao ' + 'FROM ProjsTB INNER JOIN (MarcsProjTB INNER JOIN ProjMarcTBm ON MarcsProjTB.ID_Marc = ProjMarcTBm.MarcID) ON ProjsTB.ID_Proj = ProjMarcTBm.ProjID ' + ' WHERE (' + S + ') order by ProjsTB.ProjName COLLATE NOCASE';
      QProj.Close;
      QProj.SQL.Text := S;
      QProj.Open;
      PopTV();
      AbrirProj();
      ATButton9.Checked := True;
      Panel3.Visible := False;
    end;
  end;
end;

procedure TForm1.ATButton20Click(Sender: TObject);
var
  d: System.TDateTime;
  S: string;
begin
  S := QTarAF.FieldByName('Tarefa').AsString;
  if S = '' then Exit;
  d := QTarAF.FieldByName('Prazo').AsDateTime;
  FormTarefa.Edit1.Text := S;
  FormTarefa.DTP.Date := d;
  FormTarefa.SpHora.Value := HourOf(d);
  FormTarefa.SpMin.Value := MinuteOf(d);
  if FormTarefa.ShowModal <> mrOk then Exit;
  d := FormTarefa.DTP.Date;
  QTarAF.Edit;
  QTarAF.FieldByName('Tarefa').AsString := FormTarefa.Edit1.Text;
  QTarAF.FieldByName('Prazo').AsDateTime :=
    EncodeDateTime(YearOf(d), MonthOf(d), DayOf(d), FormTarefa.SpHora.Value,
    FormTarefa.SpMin.Value, 0, 0);
  QTarAF.FieldByName('Posicao').AsInteger := -1;
  QTarAF.Post;

  LerTar();

end;

procedure TForm1.ATButton21Click(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(QTarFin.Fields[0].AsInteger);
  QTarFin.Close;
  QTarAF.Close;
  Conn.ExecuteDirect('Delete from TarefasTB where ID_Tarefa=' + S);
  LerTar();
end;

procedure TForm1.ATButton25Click(Sender: TObject);
var
  r, p: integer;
begin
  if QTarAF.IsEmpty then Exit;
  r := QTarAF.RecNo;
  p := QTarAF.FieldByName('Posicao').AsInteger;
  QTarAF.Edit;
  QTarAF.FieldByName('Posicao').AsInteger := p - 1;
  QTarAF.Post;
  QTarAF.Prior;
  p := QTarAF.FieldByName('Posicao').AsInteger;
  QTarAF.Edit;
  QTarAF.FieldByName('Posicao').AsInteger := p + 1;
  QTarAF.Post;
  LerTar;
  if r > 1 then
    QTarAF.RecNo := r - 1
  else
    QTarAF.First;
end;

procedure TForm1.ATButton27Click(Sender: TObject);
begin
  STV1.Root := GetUserDir;
  STV1.Items[0].Selected := True;
end;

procedure TForm1.ATButton28Click(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  STV1.Root := PastaDown;
  STV1.Items[0].Selected := True;
  LV1.AutoSort := False;
  LV1.AutoSortIndicator := False;
  LV1.SortColumn := -1; //Não funciona aqui, só nas outras situações
  LV1.SortColumn := 2;
  LV1.AutoSort := True;
  LV1.AutoSortIndicator := True;
  TimerDown.Enabled := True;
  Screen.Cursor := crDefault;
end;

procedure TForm1.ATButton30Click(Sender: TObject);
var
  lowerLeft: TPoint;
begin
  lowerLeft := Point(0, ATButton30.Height);
  lowerLeft := ATButton30.ClientToScreen(lowerLeft);
  PopupPluginSpecial.Popup(lowerLeft.X, lowerLeft.Y);
end;

procedure TForm1.ATButton31Click(Sender: TObject);
var
  r, p: integer;
begin
  r := QTarAF.RecNo;
  if r = QTarAF.RecordCount then Exit; //EOF não funciona.
  p := QTarAF.FieldByName('Posicao').AsInteger;
  QTarAF.Edit;
  QTarAF.FieldByName('Posicao').AsInteger := p + 1;
  QTarAF.Post;
  QTarAF.Next;
  p := QTarAF.FieldByName('Posicao').AsInteger;
  QTarAF.Edit;
  QTarAF.FieldByName('Posicao').AsInteger := p - 1;
  QTarAF.Post;
  LerTar();
  if r = 1 then
  begin
    QTarAF.RecNo := 2;
    Exit;
  end;
  if r > 1 then
    QTarAF.RecNo := r + 1
  else
    QTarAF.Last;
end;

procedure TForm1.ATButton34Click(Sender: TObject);
var
  F, P: string;
begin
  STV1.Items[0].Selected := True;
  F := STV1.Root; //Único jeito de atualizar
  P := STV1.Path;
  STV1.Root := '';
  STV1.Root := F;
  STV1.Path := P;
end;

procedure TForm1.ATButton36Click(Sender: TObject);
begin
  //CheckPastaLxWn();  ão precisa
  Ler_ArqProj();
end;

procedure TForm1.ATButton38Click(Sender: TObject);
begin
  STV1.Root := STV2.Root;
  ATButton34Click(Self);
end;

procedure TForm1.ATButton42Click(Sender: TObject);
begin
  MyFindInMemo(Memo1, Edit2.Text, 0);
  MyFindInMemo(Memo1, 'xplkw', 0);
  //Qualquer coisa para zerar seleção.DEve ter um jeito direto pelo TMemo.
  MyFindInMemo(Memo2, Edit2.Text, 0);
  MyFindInMemo(Memo2, 'xplky', 0);
  MyFindInMemo(Memo3, Edit2.Text, 0);
  MyFindInMemo(Memo3, 'xplkz', 0);
  MyFindInMemo(Memo4, Edit2.Text, 0);
  MyFindInMemo(Memo4, 'xplkk', 0);
end;

procedure TForm1.ATButton48Click(Sender: TObject);
var
  P: TProcess;
begin
  //Tirado do programa SetBamboo
{$IFDEF Linux}
 P:=TProcess.Create(nil);
 P.Executable:='nautilus';
 P.Parameters.Add(STV2.Path);
 P.Execute;
 P.Active:=True;
 P.Free;  //Se colocar isso a janela não vem para frente. Será?
{$ELSE}
  OpenDocument(STV2.Path);
{$ENDIF}
end;

procedure TForm1.ATButton55Click(Sender: TObject);
begin
  OrgMarker(Sender);
end;

procedure TForm1.ATButton59Click(Sender: TObject);
begin
  Edit4.Clear;
end;

procedure TForm1.ATButton62Click(Sender: TObject);
var
  r: integer;
begin
  r := QContAll.RecNo;
  AddMarker(Sender);
  QContAll.RecNo := r;
end;

//Pega uma stringlist (no Holder) vinda de arquivo ou de email baixado do Google e lê partes do email no formato eml.
//https://www.board4all.biz/threads/read-eml-and-download-attachments.725839/
procedure TForm1.AbrirEmailEML(HldSrc: TStrHolder; Decode: Bool);
var
  S,S1,S2,MsgOrig: string;
  i,Ini,Fim: integer;
  MsgPart: TidMessagePart;
  idAttch: TidAttachment;
  iso: boolean;
  w, ch, Sx: utf8string;
  j: SizeInt;
  fs: TFileStream;
  sub,outFileName: String;
  myMime : TIdDecoderMIME;
begin
Screen.Cursor := crHourGlass;

outFileName:=GetTempDir+'temp'+IntToSTr(Random(1000000))+'.eml';

if Decode then  //True vem do Google API. False vem de arquivo eml do disco.
 begin
  // --> Decodificando base64 meio que manualmente. Usando a unit base64 do Lazarus não dá certo.
  //http://www.delphigroups.info/2/a6/188783.html
  fs := TFileStream.Create(outFileName, fmCreate);
  myMime := TIdDecoderMIME.Create(Nil);
  try
    for i := 0 to HldSrc.Strings.Count -1 do
      begin
        sub := HldSrc.Strings[i];
        while (Length(Sub) mod 4) > 0 do sub := sub+'=';
        myMime.DecodeStream(sub, fs);
      end;
  finally
    begin
      myMime.Free;
      fs.Free;
    end;
  end;
  HoldTemp.Strings.LoadFromFile(outFileName); //Já criou e salvou antes.
 end else
  HoldTemp.Strings:=HldSrc.Strings;

{Depois de decodificar, alguns endereços aparecem com ? ao invés de >
Exemplo:
From: =?UTF-8?Q?Maur=C3=ADcio_Camargo?= <camargo.ufpr@gmail.com?
Tem que fazer a tramoia abaixo para deixar como gmail.com>
}
//--------------------------------------------------------------------

try
for i:=0 to HoldTemp.Strings.Count-1 do
 if Copy(HoldTemp.Strings[i],1,5)='From:' then Ini:=i else
  if Copy(HoldTemp.Strings[i],1,13)='Content-Type:' then begin
    Fim:=i;
    Break;
  end;
for i:=Ini to Fim-1 do begin
 S1:='';
 S2:='';
 S:=HoldTemp.Strings[i];
 while Pos('<',S)>0 do begin
  S1:=S1+Copy(S,1,Pos('<',S));
  Delete(S,1,Pos('<',S));
  if (Pos('?',S)>0) and ((Pos('?',S)<Pos('>',S)) or (Pos('>',S)=0)) then begin
   S2:=Copy(S,1,Pos('?',S)-1);
   Delete(S,1,Pos('?',S));
   S1:=S1+S2+'>';
  end;
 end;
 HoldTemp.Strings[i]:=S1+S
end;
except
 on exception do //Do nothing. Testar muito ainda.
//  ShowMessage('Deu erro.');
end;

MsgOrig:=HoldTemp.Strings.Text;

try
  if Pos('charset="iso-8859-1"', HoldTemp.Strings.Text) > 0 then
    begin
      for i := 0 to HoldTemp.Strings.Count - 1 do
        if Pos('Content-Transfer-Encoding', HoldTemp.Strings[i]) <> 0 then
          Break;
      HoldTemp.Strings.Delete(i);
      iso:=True;
    end else iso:=False;

  HoldTemp.Strings.SaveToFile(outFileName);

  IdMessage1.LoadFromFile(outFileName);

  if not QMail.Active then QMail.Open;
  QMail.Last;
  QMail.Insert;
  QMail.FieldByName('ProjID').AsInteger := QProj.Fields[0].AsInteger;
  QMail.FieldByName('ER').AsString := 'R';
  QMail.FieldByName('DePara').AsString := RemoveAspasDuplas(IdMessage1.From.Text);
  QMail.FieldByName('Assunto').AsString := IdMessage1.Subject;
  QMail.FieldByName('Data').AsString := DateTimeToStr(IdMessage1.Date);
  QMail.Post; //O post vai ser lá embaixo de novo, depois de editar para incluir a Msg.
  LastTempMail:=QMail.Fields[0].AsInteger;
  HoldTemp.Clear;
  MemMail.Clear;

  for i := IdMessage1.MessageParts.Count - 1 downto 0 do
   begin
    if IdMessage1.MessageParts.Items[i] is TidText then
     begin
        TidText(IdMessage1.MessageParts.Items[i]).CharSet := 'utf-8';
        TidText(IdMessage1.MessageParts.Items[i]).ContentType := 'text/html';
        S := TidText(IdMessage1.MessageParts.Items[i]).Body.Text;
//        ShowMessage(S);
        // S:=RenderHtml2Text(S); //Jeito novo funciona igualzinho
       if pos('<div', S) <> 0 then Continue
        else
       if iso then
          begin
          S := StringReplace(S, '=E2', 'â', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=C2', 'Â', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=E1', 'á', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=C1', 'Á', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=E9', 'é', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=C9', 'É', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=ED', 'í', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=CD', 'Í', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=E7', 'ç', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=C7', 'Ç', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=E3', 'ã', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=C3', 'Ã', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=F3', 'ó', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=D3', 'Ó', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=EA', 'ê', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=CA', 'Ê', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=F5', 'õ', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=D5', 'Õ', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=F1', 'ñ', [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, '=D1', 'Ñ', [rfReplaceAll, rfIgnoreCase]);
        end;
//        end;
        HoldTemp.Strings.Add(S);
     end;
//    end;
    MsgPart := IdMessage1.MessageParts[i];
    if (MsgPart is TIdAttachment) then
    begin
      idAttch := TidAttachment(MsgPart);
      idAttch.ContentType := 'text/plain';
      idAttch.CharSet := 'utf-8';
      Sx := idAttch.FileName;

      //Nova maneira. No Linux não precisa.
      //https://wiki.lazarus.freepascal.org/Multiplatform_Programming_Guide#Text_encoding
      {$IFDEF Windows}
      if not PastaLxWnVazia then
       idAttch.SaveToFile(UTF8ToISO_8859_1(STV2.Path+Sx));
      {$ENDIF}
      {$IFDEF Linux}
      if not PastaLxWnVazia then
       idAttch.SaveToFile(STV2.Path+Sx);
      {$ENDIF}

      if not PastaLxWnVazia then
      begin
        QMailAnx.Append; //Foi aberto no AbrirProj()
        QMailAnx.FieldByName('MailID').AsInteger := QMail.Fields[0].AsInteger;
        QMailAnx.FieldByName('Anexo').AsString := STV2.Path + Sx;
        QMailAnx.Post;
      end
      else
      begin
        MessageDlg(rs_ErroSalvarArqEmail, mtError, [mbOK], 0);
      end;
     end;

    end;
    //Ler_ArqProj(); //Atualizar STV2

    //Tentativa de consertar quando vem texto vazio da IdMessage1 ou quando está em html
    S:=HoldTemp.Strings.Text;
    if (S='') and (Pos('</html',MsgOrig)<>0) then begin //Se S vier vazio e a mensagem contiver código html, ele lê o html em txt.
     S:=RenderHtml2Text(MsgOrig);
     HoldTemp.Strings.Text:=S;
    end;

    for i := HoldTemp.Strings.Count - 1 downto 0 do
      MemMail.Lines.Insert(0, HoldTemp.Strings[i]);

    QMail.Edit;
    QMail.FieldByName('Msg').AsString := MemMail.Lines.Text;
    QMail.Post;

    QMailPess.Close;
    QMailPess.SQL.Text := 'Insert into MailsPessTB (MailID,NomeEmail) values ('+
      IntToStr(QMail.Fields[0].AsInteger)+',"'+RemoveAspasDuplas(IdMessage1.From.Text)+'")';
    QMailPess.ExecSQL;

    for i := 0 to IdMessage1.BccList.Count - 1 do
    begin
      QMailPess.SQL.Text := 'Insert into MailsPessTB (MailID,NomeEmail) values (' +
        IntToStr(QMail.Fields[0].AsInteger) + ',"' + RemoveAspasDuplas(
        IdMessage1.BccList.Items[i].Text) + '")';
      QMailPess.ExecSQL;
    end;

    for i := 0 to IdMessage1.CCList.Count - 1 do
    begin
      QMailPess.SQL.Text := 'Insert into MailsPessTB (MailID,NomeEmail) values (' +
        IntToStr(QMail.Fields[0].AsInteger) + ',"' + RemoveAspasDuplas(
        IdMessage1.CCList.Items[i].Text) + '")';
      QMailPess.ExecSQL;
    end;

    //Pega o próprio nome
    for i := 0 to IdMessage1.Recipients.Count - 1 do
    begin
      QMailPess.SQL.Text := 'Insert into MailsPessTB (MailID,NomeEmail) values (' +
        IntToStr(QMail.Fields[0].AsInteger) + ',"' + RemoveAspasDuplas(
        IdMessage1.Recipients.Items[i].Text) + '")';
      QMailPess.ExecSQL;
    end;

//    AbrirProj(); //A maneira como vai abrir vai depender de quem solicita a Procedure

  finally
    DeleteFile(outFileName);
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.ATButton75Click(Sender: TObject);
var
  i: integer;
  S, Nome, Email, id: string;
begin
  for i := 0 to CLB3.Count - 1 do
    if CLB3.Checked[i] then
    begin
      S := CLB3.Items[i];
      Nome := Copy(S, 1, Pos('<', S) - 1);
      Email := Copy(S, Pos('<', S) + 1, Length(S) - Pos('<', S) - 1);
      QTemp.Close;
      QTemp.SQL.Text := 'Select * from ContatosTB ';
      QTemp.Open;
      if not QTemp.Locate('Nome;Email', VarArrayOf([Nome, Email]), []) then
      begin
        QTemp.Close;
        QTemp.SQL.Text := 'Insert into ContatosTB (Nome,Email) values ("' + Nome + '","' + Email + '")';
        QTemp.ExecSQL;
        QTemp.Close;
        QTemp.SQL.Text := 'Select max(ID_Contato) from ContatosTB';
        QTemp.Open;
        id := IntToStr(QTemp.Fields[0].AsInteger);
      end
      else
        id := IntToStr(QTemp.Fields[0].AsInteger);
      QContAll.Close;
      QContAll.Open;
      QTemp.Close;
      QTemp.SQL.Text := 'Select * from ProjContTBm';
      QTemp.Open;
      if not QTemp.Locate('ContID;ProjID', VarArrayOf(
        [id, IntToStr(QProj.Fields[0].AsInteger)]), []) then
      begin
        QTemp.Close;
        QTemp.SQL.Text := 'Insert into ProjContTBm (ContID,ProjID) values (' + id +
          ',' + IntToStr(QProj.Fields[0].AsInteger) + ')';
        QTemp.ExecSQL;
        QContProj.Close;
        QContProj.Open;
      end;
    end;
  MessageDlg(rs_ContCopy, mtInformation, [mbOK], 0);
  ColorSpeedButton9Click(Self);
  ColorSpeedButton9.Down:=True;
end;

procedure TForm1.ATButton76Click(Sender: TObject);
begin
  MenuItem16Click(Self);
end;

procedure TForm1.ATButton77Click(Sender: TObject);
begin
  MenuItem12Click(Self);
end;

procedure TForm1.ATButton78Click(Sender: TObject);
var
  i, j: integer;
  S, Nome, Email, id: string;
begin
  j := 0;
  for i := 0 to CLB3.Count - 1 do
    if CLB3.Checked[i] then
    begin
      S := CLB3.Items[i];
      Nome := Copy(S, 1, Pos('<', S) - 1);
      Email := Copy(S, Pos('<', S) + 1, Length(S) - Pos('<', S) - 1);
      ListBox1.Items.Append(Nome + '<' + Email + '>');
      j := j + 1;
    end;

  if j = 0 then Exit;

  if QRascu.IsEmpty then QRascu.Insert
   else QRascu.Edit;

  //  DBEdit1.Text:=QMail.FieldByName('Assunto').AsString; // Problema na hora de clicar no DBEdit1. Some tudo. Como abaixo resolve.
  QRascu.FieldByName('Assunto').AsString:='Re: '+QMail.FieldByName('Assunto').AsString;
  //  DBMemo2.Text:=QMail.FieldByName('Msg').AsString; //Tanto faz assim ou abaixo
  QRascu.FieldByName('Msg').AsString:=QMail.FieldByName('Msg').AsString;
  for i:=0 to DBMemo2.Lines.Count - 1 do
   DBMemo2.Lines[i]:='>'+DBMemo2.Lines[i];
  DBMemo2.Lines.Insert(0,'');
  DBMemo2.Lines.Insert(0,'');
  NB1.PageIndex := 13;
  DBMemo2.SetFocus;

end;

procedure TForm1.ATButton7Click(Sender: TObject);
begin
AddMarker(Sender);
end;

procedure TForm1.ATButton99Click(Sender: TObject);
var Dt: System.TDateTime;
begin
  if TV.Items.Count = 0 then Exit;
  FormCalend.Caption := rs_FormCalendCapInsert;
  //FormCalend.Edit1.Text := Edt;
  FormCalend.DTP1.Date := DDate;
  FormCalend.CheckBox1.Checked := True;
  FormCalend.SpinEdit1.Value := 0;
  FormCalend.SpinEdit2.Value := 0;

  if FormCalend.ShowModal = mrOk then
  begin
    if FormCalend.Edit1.Text = '' then Exit;

    Dt := FormCalend.DTP1.Date;
    Dt := EncodeDateTime(YearOf(Dt), MonthOf(Dt), DayOf(Dt), FormCalend.SpinEdit1.Value,
      FormCalend.SpinEdit2.Value, 0, 0);

    QAgenda.Close;
    QAgenda.SQL.Text := 'Select * from AgendaTB';
    QAgenda.Open;

    QAgenda.Insert;
    QAgenda.FieldByName('ProjID').AsInteger := QProj.Fields[0].AsInteger;
    QAgenda.FieldByName('Evento').AsString := FormCalend.Edit1.Text;
    QAgenda.FieldByName('Data').AsDateTime := Dt;
    QAgenda.Post;
    // ShowMessage(DateTimeToStr(QAgenda.FieldByName('Data').AsDateTime));
    LerAgendaMes();
  end;
end;

procedure TForm1.ATLabelLink1Click(Sender: TObject);
begin
  OpenURL(ATLabelLink1.Caption);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
    DBGrid11.DataSource := DSContAll
  else
    DBGrid11.DataSource := DSContProj;
end;

procedure TForm1.CheckBox2xChange(Sender: TObject);
begin
  Label9x.Visible := not Label9x.Visible;
  Image6.Visible := not Image6.Visible;
  Label38.Visible := not Label38.Visible;
  if CheckBox2x.Caption = 'Digital' then
  begin
    CheckBox2x.Caption := rs_analogico;
  end
  else
  begin
    CheckBox2x.Caption := 'Digital';
  end;
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked then
    CLB3.CheckAll(cbChecked, False, False)
  else
    CLB3.CheckAll(cbUnchecked, False, False);
end;

procedure TForm1.CheckBox4Change(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  LerAgendaMes();
  DCal.Invalidate;
end;

procedure TForm1.CheckBox6Click(Sender: TObject);
begin
if CheckBox6.Checked then
 STV3.Root:=PastaDown
else STV3.Root:=PastaProj;
STV3.TopItem.Selected:=True;
end;

procedure TForm1.CheckBox8Click(Sender: TObject);
var
  F, P: string;
begin
  F := STV2.Root; //Único jeito de atualizar
  P := STV2.Path;
  STV2.Root := '';
  //FileSortType foi mudado na fonte. Ok.
  if STV2.FileSortType = fstAlphabet then STV2.FileSortType := fstFoldersFirst
  else
    STV2.FileSortType := fstAlphabet;
  STV2.Root := F;
  STV2.Path := P;
end;

procedure TForm1.CheckTChange(Sender: TObject);
begin
  if CheckT.Checked then
    CLBBusca.CheckAll(cbChecked, False, False)
  else
    CLBBusca.CheckAll(cbUnchecked, False, False);
end;

procedure TForm1.ColorSpeedButton100Click(Sender: TObject);
var S:String;
begin
if not InputQuery('Adicionar email', 'Email', S) then Exit;
Checkbox2.Checked:=True;
Edit6.Text:=S;
Panel123.Visible := True;
end;

procedure TForm1.ColorSpeedButton101Click(Sender: TObject);
var i: integer;
begin
if ListBox1.Items.Count = 0 then Exit;
if ListBox1.ItemIndex = -1 then Exit;
i := ListBox1.ItemIndex;
if QRascuCont.IsEmpty then begin
    ListBox1.DeleteSelected;
    ListBox1.SetFocus;
    Exit;
end;
QRascuCont.Delete;
ListBox1.DeleteSelected;
LerRascuCont();
ListBox1.SetFocus;
if ListBox1.Items.Count = 0 then Exit;
ListBox1.Items[i];
end;

procedure TForm1.ColorSpeedButton102Click(Sender: TObject);
begin
OpenDialog1.InitialDir := STV2.Root;
OpenDialog1.Filter := 'Texto|*.txt|' + rs_AllFiles + '|*.*';
if OpenDialog1.Execute then
begin
  if QRascu.State = dsBrowse then QRascu.Edit;
  DBMemo2.Lines.LoadFromFile(OpenDialog1.FileName);
  // QRascu.Post;
end;
end;

function TForm1.TirarAcento(St:String):String;
var S:String;
begin
S := StringReplace(St,'â','a', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Â','A', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'á','a', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Á','A', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'é','e', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'É','E', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'í','i', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Í','I', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ç','c', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ç','C', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ã','a', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ã','A', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ó','o', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ó','O', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ê','e', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ê','E', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'õ','o', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Õ','O', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ñ','n', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ñ','N', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ü','u', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ü','U', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'ö','o', [rfReplaceAll, rfIgnoreCase]);
S := StringReplace(S,'Ö','O', [rfReplaceAll, rfIgnoreCase]);
Result:=S;
end;

//Enviar email - Funciona! (foi extraído de GPProj14). Lá no Google foi criado uma chave de aplicativo, que funciona.
procedure TForm1.ColorSpeedButton103Click(Sender: TObject);
var
 P:TMimePart;
 M:TMimeMess;
 i,j,lh:integer;
 S,S1,login,dest,Prefix:String;
 UserEmail, UserPassw: string;
 begin
 Screen.Cursor:=crHourGlass;
//Testando remetentes
if ListBox1.Count=0 then begin
 ShowMessage(rs_mess4);
 Screen.Cursor:=crDefault;
 Exit;
end;

dest:='';
for i:=0 to ListBox1.Count-1 do dest:=dest+ListBox1.Items[i]+',';

lh:=length(dest);
dest:=Copy(dest,1,lh-1);

//Criando os tipos Mime para mandar pelo função SendToRaw

try
 Screen.Cursor:=crHourGlass;
 M:=TMimeMess.Create;
 M.Header.CharsetCode := UTF_8; //Não sei se serve para muita coisa.
 M.header.Subject:=UTF8Encode(DBEdit1.Text);
 M.header.Date:=Now;
 M.header.ToList.Add(dest);
 P:=M.AddPartMultipart('mixed',nil); //Sem isso dá GPF
 // P.ConvertCharset:=True;

 //Isso não funciona
 // M.AddPartText(MemNovoMail.lines,P);

 //Isso faz a mágica de transformar tudo em UTF-8, usando a unit synachar.
 M.AddPartTextEx(DBMemo2.lines,P,TMimeChar.UTF_8,True,TMimeEncoding.ME_BASE64);

 for i:=0 to ListBox2.Count-1 do begin
  S:=ListBox2.Items[i];
//  ShowMessage(ReplaceAccent1(S));

  S1:=GetTempDir(False)+TirarAcento(ExtractFileName(S));
  CopyFile(S,S1);

  M.AddPartBinaryFromFile(S1,P);
 end;

 M.EncodeMessage;

 UserEmail:=ConfigLerStr('ConfigTB','UserEmail');
 UserPassw:=ConfigLerStr('ConfigTB','UserPassw');

 login:=copy(UserEmail,1,pos('@',UserEmail)-1);

 Screen.Cursor:=crHourGlass;

 if SendToRaw1(UserEmail,dest,'smtp.gmail.com:465&SSL',M.Lines,login,UserPassw) then begin
  //Copia para Emails
  if not QMail.Active then QMail.Open;
  QMail.Insert;
  QMail.FieldByName('ProjID').AsInteger:=QProj.Fields[0].AsInteger;
  QMail.FieldByName('ER').AsString:='E';
  QMail.FieldByName('DePara').AsString:=ListBox1.Items[0];
  QMail.FieldByName('Assunto').AsString:=DBEdit1.Text;
  QMail.FieldByName('Data').AsDateTime:=Now;
  QMail.FieldByName('Msg').AsString:=DBMemo2.Lines.Text;
  QMail.Post;

  //Copia Pessoas
  if not QMailPess.Active then QMailPess.Open;
  for i:=0 to ListBox1.Count-1 do begin
   QMailPess.Insert;
   QMailPess.FieldByName('MailID').AsInteger:=QMail.Fields[0].AsInteger;
   QMailPess.FieldByName('NomeEmail').AsString:=ListBox1.Items[i];
   QMailPess.Post;
  end;

  //Copia anexos
  if not QMailAnx.Active then QMailAnx.Open;
  for i:=0 to ListBox2.Count-1 do begin
   QMailAnx.Insert;
   QMailAnx.FieldByName('MailID').AsInteger:=QMail.Fields[0].AsInteger;
   QMailAnx.FieldByName('Anexo').AsString:=ListBox2.Items[i];
   QMailAnx.Post;
  end;

  ColorSpeedButton106Click(Self); //Apaga o rascunho
  Screen.Cursor:=crDefault;
  MessageDlg(rs_MailSend,mtInformation,[mbOk],0);
 end else begin
  MessageDlg(rs_MailNotSend,mtInformation,[mbOk],0);
 end;
finally begin
 Screen.Cursor:=CrDefault;
 M.Free;
end;
end;
end;

//Enviar email - Não funciona mais
{
procedure TForm1.ColorSpeedButton103Click(Sender: TObject);
var
 P, Px: TMimePart;
 M, Mx: TMimeMess;
// dest: string;
 i, lh: integer;
// messageRFC2822:String;
begin
if accessTokenGmail = '' then begin
 MessageDlg('Você será direcionado para as configurações de Email.',mtInformation, [mbOK], 0);
 NB1.PageIndex := 8;
 Notebook1.PageIndex := 1;
end else begin
 Screen.Cursor := crHourGlass;
 //Testando remetentes
 if ListBox1.Count = 0 then begin
  ShowMessage(rs_mess4);
  Screen.Cursor := crDefault;
  Exit;
 end;

 //Jeito Velho. Ver abaixo.
 {dest := '';
 for i := 0 to ListBox1.Count - 1 do dest := dest + ListBox1.Items[i] + ',';

 lh := length(dest);
 dest := Copy(dest, 1, lh - 1);
 }

 try
  M := TMimeMess.Create;
  M.Header.CharsetCode := UTF_8; //Não sei se serve para muita coisa.

  //M.header.From:='camargo.ufpr@gmail.com'; //Não precisa pois o from já vem da autenticação do OAuth2

  M.header.Subject := UTF8Encode(DBEdit1.Text); //UTF8 é fundamental aqui.

  M.header.Date := Now; //Desnecessário também, acho.

  //Jeito novo e testado. Antes só mandava para o primeiro da lista. 09/08/22
  for i := 0 to ListBox1.Count - 1 do   M.header.ToList.Add(ListBox1.Items[i]);

  //Jeito Velho
  //  M.header.ToList.Add(dest);

  P := M.AddPartMultipart('mixed', nil);
  P.ConvertCharset := False; //Não sei se serve para muita coisa.
  //Isso faz a mágica de transformar tudo em UTF-8, usando a unit synachar -> Se for False abaixo não funciona.
  M.AddPartTextEx(DBMEmo2.Lines, P, TMimeChar.UTF_8, True, TMimeEncoding.ME_BASE64);

  //Anexos
  for i := 0 to ListBox2.Count - 1 do M.AddPartBinaryFromFile(ListBox2.Items[i], P);

  M.EncodeMessage;
//  messageRFC2822 := M.Lines.Text;
  defaultInternet.additionalHeaders.Text := 'Content-Type: message/rfc822';

//  try
   {ShowMessage(accessTokenGmail);
   ShowMessage(refreshTokenGmail);
   Exit;
   }
    httpRequest('https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?access_token='
    +EncodeUrl(accessTokenGmail)+'&refresh_token='+EncodeUrl(refreshTokenGmail), M.Lines.Text);
//     + EncodeUrl(accessTokenGmail), messageRFC2822);

{  except begin
   Screen.Cursor := crDefault;
   MessageDlg('Autenticação falhou. Tente autenticar novamente nas configurações.',mtError, [mbOK], 0);
   NB1.PageIndex := 8;
   Notebook1.PageIndex := 1;
   Exit;
  end;
 end;
}
  defaultInternet.additionalHeaders.Text := ''; //reset headers
  Screen.Cursor := crDefault;
  MessageDlg('Email enviado com SUCESSO!', mtInformation, [mbOK], 0);

  //Copia para Emails
  if not QMail.Active then QMail.Open;
  QMail.Insert;
  QMail.FieldByName('ProjID').AsInteger := QProj.Fields[0].AsInteger;
  QMail.FieldByName('ER').AsString := 'E';
  QMail.FieldByName('DePara').AsString := ListBox1.Items[0];
  QMail.FieldByName('Assunto').AsString := DBEdit1.Text;
  QMail.FieldByName('Data').AsDateTime := Now;
  QMail.FieldByName('Msg').AsString := DBMemo2.Lines.Text;
  QMail.Post;

  //Copia Pessoas
  if not QMailPess.Active then QMailPess.Open;
  for i := 0 to ListBox1.Count - 1 do begin
   QMailPess.Insert;
   QMailPess.FieldByName('MailID').AsInteger := QMail.Fields[0].AsInteger;
   QMailPess.FieldByName('NomeEmail').AsString := ListBox1.Items[i];
   QMailPess.Post;
  end;

  //Copia anexos
  if not QMailAnx.Active then QMailAnx.Open;
  for i := 0 to ListBox2.Count - 1 do begin
   QMailAnx.Insert;
   QMailAnx.FieldByName('MailID').AsInteger := QMail.Fields[0].AsInteger;
   QMailAnx.FieldByName('Anexo').AsString := ExtractFileName(ListBox2.Items[i]); //Guarda o nome anexo do email que foi enviado. Tem que estar na pasta do Projeto.
   QMailAnx.Post;
  end;

  ColorSpeedButton106Click(Self); //Apaga o rascunho

  finally
   M.Free;
  end;
 end;
end;
}

procedure TForm1.ColorSpeedButton104Click(Sender: TObject);
var
  i: integer;
  S, Nome, Email: string;
begin
  if (QRascu.State = dsEdit) or (QRascu.State = dsInsert) then
  begin
    QRascu.Post;
    //Primeiro apaga todos os Contatos, caso haja...
    if ListBox1.Count > 0 then
    begin
      QTemp.SQL.Text := 'Delete from RascuContTB where RascuID=' + QRascu.Fields[0].AsString;
      QTemp.ExecSQL;
    end;
    //...depois coloca tudo de novo.
    for i := 0 to ListBox1.Count - 1 do
    begin
      S := ListBox1.Items[i];
      Nome := Copy(S, 1, Pos('<', S) - 1);
      Email := Copy(S, Pos('<', S) + 1, Pos('>', S) - Pos('<', S) - 1);
      QTemp.SQL.Text := 'Insert into RascuContTB (RascuID,Nome,Email) values (' +
        QRascu.Fields[0].AsString + ',"' + Nome + '","' + Email + '")';
      QTemp.ExecSQL;
    end;
    LerRascuCont();
    //Primeiro apaga todos os Anexos, caso haja...
    if ListBox2.Count > 0 then
    begin
      QTemp.SQL.Text := 'Delete from RascuAnxTB where RascuID=' + QRascu.Fields[0].AsString;
      QTemp.ExecSQL;
    end;
    //...depois coloca tudo de novo.
    for i := 0 to ListBox2.Count - 1 do
    begin
      S := ListBox2.Items[i];
      QTemp.SQL.Text := 'Insert into RascuAnxTB (RascuID,Anexo) values (' +
        QRascu.Fields[0].AsString + ',"' + S + '")';
      QTemp.ExecSQL;
    end;
    LerRascuAnx();
  end;
end;

procedure TForm1.ColorSpeedButton105Click(Sender: TObject);
begin
  if not QRascu.IsEmpty then ColorSpeedButton104Click(Self); //Salva se estiver aberta.
  if (QRascu.State = dsEdit) or (QRascu.State = dsInsert) then QRascu.Post;
  QRascu.Insert;
  LerRascuCont();
  DBEdit1.SetFocus;
end;

procedure TForm1.ColorSpeedButton106Click(Sender: TObject);
begin
  if not QRascu.IsEmpty then
  begin
    QTemp.SQL.Text := 'Delete from RascuContTB where RascuID=' + IntToStr(
      QRascu.fields[0].AsInteger);
    QTemp.ExecSQL;
    LerRascuCont();
    QTemp.SQL.Text := 'Delete from RascuAnxTB where RascuID=' + IntToStr(
      QRascu.fields[0].AsInteger);
    QTemp.ExecSQL;
    QRascu.Delete;
    LerRascu();
  end;
end;

procedure TForm1.ColorSpeedButton107Click(Sender: TObject);
begin
Panel124.Visible := True;
end;

procedure TForm1.ColorSpeedButton108Click(Sender: TObject);
var
  i: integer;
begin
  if ListBox2.Items.Count = 0 then Exit;
  if ListBox2.ItemIndex = -1 then Exit;
  i := ListBox2.ItemIndex;
  if QRascuCont.IsEmpty then
  begin
    ListBox2.DeleteSelected;
    ListBox2.SetFocus;
    Exit;
  end;
  if not QRascuCont.IsEmpty then QRascuAnx.Delete;
  ListBox2.DeleteSelected;
  LerRascuAnx();
  ListBox2.SetFocus;
  if ListBox2.Items.Count = 0 then Exit;
  ListBox2.Items[i];
end;

procedure TForm1.ColorSpeedButton109Click(Sender: TObject);
begin
  if not QRascu.Active then Exit;
  QRascu.Prior;
  LerRascuCont();
  LerRascuAnx();
end;

procedure TForm1.ColorSpeedButton110Click(Sender: TObject);
begin
  if not QRascu.Active then Exit;
  QRascu.Next;
  LerRascuCont();
  LerRascuAnx();
end;

procedure TForm1.ColorSpeedButton111Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  OpenDialog1.InitialDir := PastaDown;
  OpenDialog1.Filter := 'E-mails (eml)|*.eml|' + rs_AllFiles + '|*.*';
  if not OpenDialog1.Execute then Exit;
  HoldEML.Strings.LoadFromFile(OpenDialog1.FileName);
  AbrirEmailEML(HoldEML,False);
end;

procedure TForm1.ColorSpeedButton112Click(Sender: TObject);
begin
  if (QMail.State = dsInsert) or (QMail.State = dsEdit) then QMail.Post;
end;

procedure TForm1.ColorSpeedButton113Click(Sender: TObject);
begin
  if MessageDlg('Apagar e-mail?',mtConfirmation,[mbYes, mbNo], 0) = mrNo then Exit;
  if ColorSpeedButton37.Down then begin
  if MessageDlg(rs_DelEmail, mtConfirmation, [mbOK, mbNo], 0) <> mrOk then Exit;
  QMail.Delete;
  end;
  QMail.Edit;
  QMail.FieldByName('ER').AsString:='L';
  Qmail.Post;
  CLB3.Clear;
  LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.ColorSpeedButton114Click(Sender: TObject);
begin
Edit8.Clear;
end;

procedure TForm1.ColorSpeedButton115Click(Sender: TObject);
begin
STV3.BeginUpdate;
STV3.Root:=ExtractFilePath(ExcludeTrailingPathDelimiter(STV3.Path));
STV3.Selected := STV3.TopItem;
STV3.EndUpdate;
end;

procedure TForm1.ColorSpeedButton116Click(Sender: TObject);
var
  S: string;
begin
  if not InputQuery(rs_InsProj, rs_NomeProj, S) then Exit;

  CreateDir(PastaProj + PathDelim + S);
  if QProj.Locate('ProjName', VarArrayOf([S]), [loCaseInsensitive]) then
  begin
    MessageDlg(rs_ProjExists + ' : ' + S, mtError, [mbOK], 0);
    Exit;
  end;

  Edit1.Clear;

  QProj.DisableControls;
  QProj.First;
  //Importante para inserir no início, já que vai circular e colocar posição de novo ali embaixo
  QProj.Insert;
  QProj.FieldByName('ProjName').AsString := S;
  QProj.FieldByName('Posicao').AsInteger := -1;
  QProj.FieldByName('Situacao').AsInteger := 1;
  QProj.Post;
  QProj.EnableControls;
  QProj.Close;
  QProj.SQL.Text := 'Select * from ProjsTB where Situacao=1 order by ProjsTB.Posicao';
  //Significa que a qualquer hora é possível adicionar um Projeto, e sempre vai voltar para o início de tudo
  QProj.Open;
  RefazerPosicaoProj();
  Edit1.Text := '';
  ProjAnterior := ProjAtual;
  PopTVx();
  PopTV();
  AbrirProj();

end;

procedure TForm1.ColorSpeedButton117Click(Sender: TObject);
begin
ColorSpeedButton13.Down:=True;
NB1.PageIndex := 13;           //Novo e-mail
end;

procedure TForm1.ColorSpeedButton118Click(Sender: TObject);
begin
ColorSpeedButton9.Down:=True;
ColorSpeedButton9Click(Sender);
ColorSpeedButton60Click(Sender);  //Novo contato
end;

procedure TForm1.ColorSpeedButton119Click(Sender: TObject);
begin
ColorSpeedButton7.Down:=True;
ColorSpeedButton7Click(Self);
ATButton99Click(Self);
end;

procedure TForm1.ColorSpeedButton120Click(Sender: TObject);
begin
ColorSpeedButton12Click(Self);
ColorSpeedButton12.Down:=True;
ColorSpeedButton56Click(Self);
end;

procedure TForm1.ColorSpeedButton17Click(Sender: TObject);
begin
LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.ColorSpeedButton34Click(Sender: TObject);
begin
LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.ColorSpeedButton36Click(Sender: TObject);
begin
  Notebook2.PageIndex:=5;
  if Panel127.Width=45 then
  begin
   TimerPanel.Enabled := True;
   Screen.Cursor:=crHourGlass;

      try
        LoadAuthConfig('Drive');
        ClearTreeViewDrive;
        ClearFileListView;
        AddFolders(Nil,'root');
        ShowFolder('root');

      except on exception do begin
     MessageDlg('É necessário solicitar nova autorização ao Google!',mtError,[mbOk],0);
     ConfigSalvarStr('ConfigTB', 'accessTokenDrive', '');
     ConfigSalvarStr('ConfigTB', 'refreshTokenDrive', '');
     Screen.Cursor:=crDefault;
     Panel127.Width:=45;
     Exit;
     end;
   end;



   Screen.Cursor:=crDefault;
  end else begin
   Panel127.Width := 45;
 end;
end;

procedure TForm1.ColorSpeedButton37Click(Sender: TObject);
begin
LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.ColorSpeedButton38Click(Sender: TObject);
begin
NB1.PageIndex := 13;
end;

procedure TForm1.ColorSpeedButton39Click(Sender: TObject);
begin
LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.ColorSpeedButton40Click(Sender: TObject);
var
  RdBtWhe, Pjt, Pt, Ph, S: string;
  i: integer;
begin

  //FALTA TARApp e Audios

  if EdBusca.Text = '' then Exit;
  Screen.Cursor := crHourGlass;
  QBusca.Close;
  QBusca.SQL.Text := 'Delete from BuscaTB';
  QBusca.ExecSQL;
  QBusca.Close;

  RdBtWhe := '';
  if RadioTodos.Checked then
    if CheckBox5.Checked then
      RdBtWhe := ''
    else
      RdBtWhe := ' and (ProjsTB.Situacao=1 or ProjsTB.Situacao=2)';
  if RadioTodosAt.Checked then RdBtWhe := ' and (ProjsTB.Situacao=1)';
  if Radio1Proj.Checked then RdBtWhe :=
      ' and (ProjsTB.ID_Proj=' + QProj.Fields[0].AsString + ')';

  //Contatos e seus marcadores
  if (CLBbusca.Checked[4]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text :=
      'SELECT distinct ID_Contato,Nome FROM ContatosTB where ((ContatosTB.Nome like "%' +
      EdBusca.Text + '%") or (ContatosTB.Email like "%' + EdBusca.Text + '%")) ' +
      'UNION SELECT distinct ID_Contato,Nome FROM ContatosTB INNER JOIN (MarcsContTB INNER JOIN ContMarcTBm ON MarcsContTB.ID_Marc = ContMarcTBm.MarcID) ON ContatosTB.ID_Contato = ContMarcTBm.ContID ' + 'WHERE (MarcsContTB.Marcador Like "%' + EdBusca.Text + '%") ';
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("Todos","Contato","' +
        QTemp.Fields[1].AsString + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  //Projetos e seus marcadores
  if (CLBbusca.Checked[0]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text :=
      'SELECT distinct ID_Proj,ProjName FROM ProjsTB where (ProjsTB.ProjName like "%' +
      EdBusca.Text + '%") ' + RdBtWhe +
      ' UNION SELECT distinct ID_Proj,ProjName FROM ProjsTB INNER JOIN (MarcsProjTB INNER JOIN ProjMarcTBm ON MarcsProjTB.ID_Marc = ProjMarcTBm.MarcID) ON ProjsTB.ID_Proj = ProjMarcTBm.ProjID ' + 'WHERE (MarcsProjTB.Marcador Like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[1].AsString + '","Projeto (nome)","' + QTemp.Fields[0].AsString + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  //Arquivos
  if (CLBbusca.Checked[1]) or (CheckT.Checked) then begin
    Qtemp.Close;
    if CheckBox5.Checked then
      Qtemp.SQL.Text := 'Select * from ProjsTB'
    else
      Qtemp.SQL.Text := 'Select * from ProjsTB where ' + Copy(RdBtWhe, 5, Length(RdBtWhe));
    Qtemp.Open;

    if (RadioTodos.Checked) or (RadioTodosAt.Checked) then
    begin
      while not QTemp.EOF do
      begin
        Pjt := QTemp.FieldByName('ProjName').AsString;
        Ph := PastaProj+PathDelim+Pjt;
        HoldTemp.Strings := FindAllFiles(Ph);
        if Ph <> '' then //Novo, antes da v1.1
          for i := 0 to HoldTemp.Strings.Count - 1 do
          begin
            if Pos(AnsiUpperCase(EdBusca.Text), AnsiUpperCase(HoldTemp.Strings[i])) > 0 then
            begin  //AnsiUpperCase para case insensitive
              QBusca.Close;
              QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' + Pjt +
                '","Arquivo (' + ExtractFileExt(HoldTemp.Strings[i]) + ')","' + HoldTemp.Strings[i] + '")';
              QBusca.ExecSQL;
            end;
          end;
        QTemp.Next;
      end;
      MemTemp.Lines := HoldTemp.Strings;
    end
    else
    begin
      QTemp.Locate('ProjName', QProj.FieldByName('ProjName').AsString, []);
      Pjt := QTemp.FieldByName('ProjName').AsString;
      Ph := QTemp.FieldByName(Pt).AsString;
      HoldTemp.Strings := FindAllFiles(Ph);
      if Ph <> '' then
        for i := 0 to HoldTemp.Strings.Count - 1 do
        begin
          if Pos(EdBusca.Text, HoldTemp.Strings[i]) > 0 then
          begin
            QBusca.Close;
            QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
              Pjt + '","Arquivo (' + ExtractFileExt(HoldTemp.Strings[i]) + ')","' + HoldTemp.Strings[i] + '")';
            QBusca.ExecSQL;
          end;
        end;
      QTemp.Next;
    end;
  end;

  //Emails
  if (CLBbusca.Checked[2]) or (CheckT.Checked) then
  begin

    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Mail,DePara,Assunto,Msg,ProjID ' +
      'FROM ProjsTB INNER JOIN MailsTB ON ID_Proj = ProjID ' +
      'WHERE ((DePara like "%' + EdBusca.Text + '%") or ' +
      '(Assunto like "%' + EdBusca.Text + '%") or(Msg like "%' + EdBusca.Text + '%")) ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","E-mail","' + QTemp.FieldByName('ID_Mail').AsString + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  //Agenda
  if (CLBbusca.Checked[6]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Agenda,Evento,Data,ProjID ' +
      'FROM ProjsTB INNER JOIN AgendaTB ON ID_Proj = ProjID ' +
      'WHERE (Evento like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Agenda","' + QTemp.FieldByName('Data').AsString + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  //Notas
  if (CLBbusca.Checked[3]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Nota,Nota1,ProjID ' +
      'FROM ProjsTB INNER JOIN NotasTB ON ID_Proj = ProjID ' +
      'WHERE (Nota1 like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Anotações","Nota 1")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Nota,Nota2,ProjID ' +
      'FROM ProjsTB INNER JOIN NotasTB ON ID_Proj = ProjID ' +
      'WHERE (Nota2 like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Anotações","Nota 2")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Nota,Nota3,ProjID ' +
      'FROM ProjsTB INNER JOIN NotasTB ON ID_Proj = ProjID ' +
      'WHERE (Nota3 like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Anotações","Nota 3")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Nota,Nota4,ProjID ' +
      'FROM ProjsTB INNER JOIN NotasTB ON ID_Proj = ProjID ' +
      'WHERE (Nota4 like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Anotações","Nota 4")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;

  end;

  //Tarefas
  if (CLBbusca.Checked[5]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Tarefa,Tarefa,TarefasTB.Situacao,ProjID ' +
      'FROM ProjsTB INNER JOIN TarefasTB ON ID_Proj = ProjID ' +
      'WHERE (Tarefa like "%' + EdBusca.Text + '%") ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      if QTemp.FieldByName('Situacao').AsInteger = 1 then
        S := 'Ativa'
      else
        S := 'Finalizada';
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Tarefas","' + S + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  //Links
  if (CLBbusca.Checked[7]) or (CheckT.Checked) then
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'SELECT ProjName,ID_Link,Link,Descricao,ProjID ' +
      'FROM ProjsTB INNER JOIN LinksTB ON ID_Proj = ProjID ' +
      'WHERE ((Link like "%' + EdBusca.Text + '%") or (Descricao like "%' +
      EdBusca.Text + '%")) ' + RdBtWhe;
    QTemp.Open;
    while not QTemp.EOF do
    begin
      QBusca.Close;
      QBusca.SQL.Text := 'Insert into BuscaTB (Projeto,Onde,Ref) values ("' +
        QTemp.Fields[0].AsString + '","Link","' + QTemp.FieldByName('Link').AsString + '")';
      QBusca.ExecSQL;
      QTemp.Next;
    end;
  end;

  QBusca.Close;
  QBusca.SQL.Text := 'Select * from BuscaTB';
  QBusca.Open;

  Screen.Cursor := crDefault;

end;

procedure TForm1.ColorSpeedButton45Click(Sender: TObject);
var
  Od, Ref: string;
begin
if not QBusca.Active then Exit;
if QBusca.IsEmpty then Exit;
Od := QBusca.FieldByName('Onde').AsString;
Ref := QBusca.FieldByName('Ref').AsString;

if pos('Projeto (', Od) > 0 then begin                 //Projeto
 QProj.Locate('ProjName', QBusca.FieldByName('Projeto').AsString, []);
 TV.Selected := TV.Items.FindNodeWithText(QBusca.FieldByName('Projeto').AsString);
 ColorSpeedButton4Click(Self);
 ColorSpeedButton4.Down:=True;
end;
if pos('Contato', Od) > 0 then begin                 //Projeto
 ColorSpeedButton9Click(Self);
 ColorSpeedButton9.Down:=True;
 Edit4.Text := Ref;
end;
if pos('Arquivo (', Od) > 0 then begin               //Arquivos
 if FileExists(Ref) then OpenDocument(Ref);
 ColorSpeedButton11Click(Self);
 ColorSpeedButton11.Down:=True;
end;
if pos('E-mail', Od) > 0 then begin                    //E-mails
 QMail.Close;
 QMail.SQL.Text := 'Select * from MailsTB where ID_Mail=' + Ref;
 QMail.Open;
 ColorSpeedButton13Click(Self);
 ColorSpeedButton13.Down:=True;
end;
if pos('Agenda', Od) > 0 then begin                    //Agenda
 //Tem que localizar o Proj e o TV para abrir a agenda
 QProj.Locate('ProjName', QBusca.FieldByName('Projeto').AsString, []);
 TV.Selected := TV.Items.FindNodeWithText(QBusca.FieldByName('Projeto').AsString);
 DDate := QBusca.FieldByName('Ref').AsDateTime;
 LerAgendaMes();
 ColorSpeedButton7Click(Self);
 ColorSpeedButton7.Down:=True;
end;
if pos('Anota', Od) > 0 then begin                    //Anotações -> abre projeto
  QProj.Locate('ProjName', QBusca.FieldByName('Projeto').AsString, []);
  TV.Selected := TV.Items.FindNodeWithText(QBusca.FieldByName('Projeto').AsString);
  ColorSpeedButton8Click(Self);
  ColorSpeedButton8.Down:=True;
end;
if pos('Tarefa', Od) > 0 then begin                    //Tarefas
 //Tem que localizar o Proj e o TV para abrir a agenda
 QProj.Locate('ProjName', QBusca.FieldByName('Projeto').AsString, []);
 TV.Selected := TV.Items.FindNodeWithText(QBusca.FieldByName('Projeto').AsString);
 ColorSpeedButton10Click(Self);
 ColorSpeedButton10.Down:=True;
end;
if pos('Link', Od) > 0 then begin                    //Link
 //Tem que localizar o Proj e o TV para abrir a agenda
 QProj.Locate('ProjName', QBusca.FieldByName('Projeto').AsString, []);
 TV.Selected := TV.Items.FindNodeWithText(QBusca.FieldByName('Projeto').AsString);
 ColorSpeedButton12Click(Self);
 ColorSpeedButton12.Down:=True;
end;

end;

procedure TForm1.ColorSpeedButton51Click(Sender: TObject);
begin
FormPomo.ShowModal;
end;

//Importar Gmail
procedure TForm1.ColorSpeedButton64Click(Sender: TObject);
var
  Tp:TPerson;
  Pessoas: TListConnectionsResponse;
  i,n:integer;
  Nome,Email,Fone,Bio,S: String;
begin
 Screen.Cursor:=crHourGlass;

  if MessageDlg('Apagar todos os contatos antes de prosseguir?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
   begin
     QTemp.Close;
     QTemp.SQL.Text:='delete from ContatosTB';
     QTemp.ExecSQL;
     LerContAll(' order by Nome COLLATE NOCASE ASC');
     Screen.Cursor:=crDefault;
   end;

  Pessoas:=FPeopleAPI.PeopleConnectionsResource.List('people/me',
  'personFields=names,emailAddresses,PhoneNumbers,biographies&pageSize=1000&sortOrder=FIRST_NAME_ASCENDING');
  n:=Length(Pessoas.connections);
  Screen.Cursor:=crDefault;
  if n=0 then
  begin
    Exit;
    ShowMessage('Não há mensagens para baixar do Google?');
  end;
  Screen.Cursor:=crHourGlass;
  i:=0;
  QContProj.Close;

  for Tp in Pessoas.connections do
  begin
   Inc(i);
   if Length(Tp.emailAddresses)>0 then Email:=Tp.emailAddresses[0].value else Email:='';
   if Length(Tp.Names)>0 then Nome:=Tp.Names[0].displayName else Nome:=Email;
   if Length(Tp.PhoneNumbers)>0 then Fone:=Tp.PhoneNumbers[0].value else Fone:='';
   if Length(Tp.biographies)>0 then Bio:=Tp.biographies[0].value else Bio:='';
   if Email='' then Continue else
   begin
     QTemp.Close;
     QTemp.SQL.Text:='Insert into ContatosTB (Nome,Email,Celular,Obs) values ("'+Nome+'","'+Email+'","'+Fone+'","'+Bio+'")';
     QTemp.ExecSQL;
   end;
  end;
  // Testando se tem mais de 1000 contatos
  if Pessoas.nextPageToken='' then
  begin
    Screen.Cursor:=crDefault;
    Exit;
  end;
  S:='&pageToken='+Pessoas.nextPageToken;

  Pessoas:=FPeopleAPI.PeopleConnectionsResource.List('people/me',
  'personFields=names,emailAddresses,PhoneNumbers,biographies&pageSize=1000&sortOrder=FIRST_NAME_ASCENDING'+S);
  n:=n+Length(Pessoas.connections);
  Screen.Cursor:=crDefault;
  if n=0 then
  begin
    Exit;
    ShowMessage('Não há mensagens para baixar do Google?');
  end;
  ShowMessage('Importar '+IntToStr(n)+' contatos do Google?');
  Screen.Cursor:=crHourGlass;
  i:=0;
  QContProj.Close;

  for Tp in Pessoas.connections do
  begin
   Inc(i);
   if Length(Tp.emailAddresses)>0 then Email:=Tp.emailAddresses[0].value else Email:='';
   if Length(Tp.Names)>0 then Nome:=Tp.Names[0].displayName else Nome:=Email;
   if Length(Tp.PhoneNumbers)>0 then Fone:=Tp.PhoneNumbers[0].value else Fone:='';
   if Length(Tp.biographies)>0 then Bio:=Tp.biographies[0].value else Bio:='';
   QTemp.Close;
   QTemp.SQL.Text:='Insert into ContatosTB (Nome,Email,Celular,Obs) values ("'+Nome+'","'+Email+'","'+Fone+'","'+Bio+'")';
   QTemp.ExecSQL;
  end;

  SaveRefreshToken('Peop');
  LerContAll(' order by Nome COLLATE NOCASE ASC');
  LerContProj(' order by Nome COLLATE NOCASE ASC');
  Screen.Cursor:=crDefault;
end;

procedure TForm1.ColorSpeedButton65Click(Sender: TObject);
var
  T: shortstring;
begin
  if ColorSpeedButton65.Caption = rs_Start then
  begin
    VR := 60;
    TR := StrToInt(FormPomo.SpinEdit1.Text);
    if TR <= 9 then T := '0' + IntToStr(TR)
    else
      T := IntToStr(TR);
    Label9x.Caption := T + ':00';
    T1.Enabled := True;
    Label36.Caption := rs_Working;
    CheckBox2x.Enabled := True;
    //Label32.Caption := FormPomo.SpinEdit1.Caption + ' min';
    AtualizarAnalogico(100);
  end
  else
  begin
    T1.Enabled := True;
    ColorSpeedButton65.Caption := rs_Start;
    CheckBox2x.Enabled := False;
  end;
end;

procedure TForm1.ColorSpeedButton66Click(Sender: TObject);
begin
Label9x.Caption := '00:00';
Form1.Caption := rs_FORM1CAPTION;
T1.Enabled := False;
T2.Enabled := False;
Label36.Caption := rs_Time;
ColorSpeedButton65.Caption := rs_Start;
end;

procedure TForm1.ColorSpeedButton77Click(Sender: TObject);
begin
  Notebook2.PageIndex:=4;
  if Panel127.Width=45 then
  begin
    Screen.Cursor:=crHourGlass;
    TimerPanel.Enabled := True;

    if TVGmail.TopItem <> nil then begin
      Screen.Cursor:=crDefault;
      Exit;
    end;

    LoadAuthConfig('Gmail');
    ClearTreeViewGmail;
    AddLabels;
    Screen.Cursor:=crDefault;

  end else begin
  Panel127.Width := 45;
 end;
end;

//Listar contatos API People
procedure TForm1.ColorSpeedButton78Click(Sender: TObject);
var Item: TListItem;
 Nome,Email,Fone,Bio,S: String;
 Tp:TPerson;
 Pessoas: TListConnectionsResponse;
 i,n:integer;
begin
  Notebook2.PageIndex:=3;
  if Panel127.Width=45 then
  begin
   TimerPanel.Enabled := True;
   Screen.Cursor:=crHourGlass;

   try
     Pessoas:=FPeopleAPI.PeopleConnectionsResource.List('people/me',
     'personFields=names,emailAddresses,PhoneNumbers,biographies&pageSize=1000&sortOrder=FIRST_NAME_ASCENDING');
   except on exception do begin
     MessageDlg('É necessário solicitar nova autorização ao Google!',mtError,[mbOk],0);
     ConfigSalvarStr('ConfigTB', 'accessTokenPeop', '');
     ConfigSalvarStr('ConfigTB', 'refreshTokenPeop', '');
     Screen.Cursor:=crDefault;
     Panel127.Width:=45;
     Exit;
     end;
   end;

   n:=Length(Pessoas.connections);
   Label17.Caption:='CONTATOS ('+IntToStr(n)+')';
   if n=0 then
   begin
    Screen.Cursor:=crDefault;
    Exit;
    ShowMessage('Não há Contatos para baixar do Google.');
   end;
   Screen.Cursor:=crHourGlass;
   LVPeopGoo.Visible:=False;
   i:=0;
   for Tp in Pessoas.connections do
   begin
    Inc(i);
    if Length(Tp.emailAddresses)>0 then Email:=Tp.emailAddresses[0].value else Email:='';
    if Length(Tp.Names)>0 then Nome:=Tp.Names[0].displayName else Nome:=Email;
    if Length(Tp.PhoneNumbers)>0 then Fone:=Tp.PhoneNumbers[0].value else Fone:='';
    if Length(Tp.biographies)>0 then Bio:=Tp.biographies[0].value else Bio:='';
    Item:=LVPeopGoo.Items.Add;
    Item.Caption := Nome;
    Item.Subitems.Add(Email);
    Item.Subitems.Add(Fone);
    Item.Subitems.Add(Bio);
   end;

   // Testando se tem mais de 1000 contatos
   if Pessoas.nextPageToken='' then
   begin
     Screen.Cursor:=crDefault;
     Exit;
   end;
   S:='&pageToken='+Pessoas.nextPageToken;

   //Pegando os próximos mil e acabou!
   Pessoas:=FPeopleAPI.PeopleConnectionsResource.List('people/me',
   'personFields=names,emailAddresses,PhoneNumbers,biographies&pageSize=1000&sortOrder=FIRST_NAME_ASCENDING'+S);
   n:=n+Length(Pessoas.connections);
   Label17.Caption:='CONTATOS ('+IntToStr(n)+')';

   if n=0 then
   begin
     Screen.Cursor:=crDefault;
     Exit;
     ShowMessage('Não há Contatos para baixar do Google.');
   end;
   Screen.Cursor:=crHourGlass;
   LVPeopGoo.Visible:=False;
   i:=0;
   for Tp in Pessoas.connections do
   begin
    Inc(i);
    if Length(Tp.Names)>0 then Nome:=Tp.Names[0].displayName;
    if Length(Tp.emailAddresses)>0 then Email:=Tp.emailAddresses[0].value;
    if Length(Tp.PhoneNumbers)>0 then Fone:=Tp.PhoneNumbers[0].value;
    if Length(Tp.biographies)>0 then Bio:=Tp.biographies[0].value;
    Item:=LVPeopGoo.Items.Add;
    Item.Caption := Nome;
    Item.Subitems.Add(Email);
    Item.Subitems.Add(Fone);
    Item.Subitems.Add(Bio);
   end;

   SaveRefreshToken('Peop');
   LVPeopGoo.Visible:=True;

   Screen.Cursor:=crDefault;
  end else begin
   Panel127.Width := 45;
 end;
end;

//Tentativa de criar um contato, mas falhou
procedure TForm1.Button2Click(Sender: TObject);
var Tp:TPerson;
Pr:  TPeopleResource;
body,accessTokenPeop: String;
begin
Tp:=TPerson.Create;
//FPeopleAPI.

//  accessTokenPeop:=ConfigLerStr('ConfigTB', 'accessTokenPeop');
  //accessTokenGmail :=  ConfigLerStr('ConfigTB', 'accessTokenPeop');
  //refreshTokenGmail := ConfigLerStr('ConfigTB', 'refreshTokenPeop');

//  body:='body={"names": [ {"givenName": "Samkit" } ], "phoneNumbers": [{"value": "8600086024"}],"emailAddresses": [{"value": "samkit5495@gmail.com" } ]}';

//  defaultInternet.additionalHeaders.Text := 'Content-Type: message/rfc822';
//  httpRequest('https://people.googleapis.com/v1/people?'+
 //  {'access_token='+ EncodeUrl(accessTokenPeop)+}'&personFields=names', body);

//Tp:=FPeopleAPI.PeopleResource.Get('people/me','personFields=names&'+body);
//Memo5.Clear;
//Memo5.Lines.Add(Tp.names[0].displayName);
end;

procedure TForm1.ColorSpeedButton84Click(Sender: TObject);
begin
Notebook2.PageIndex:=2;
  if Panel127.Width=45 then begin
    TimerPanel.Enabled := True;
    //Só mostrar. Tudo já foi preenchido.
end else begin
    Panel127.Width := 45;
  end;
end;

procedure TForm1.ColorSpeedButton86Click(Sender: TObject);
var S: String;
begin
Forminscont.Edit1.Text:=QContAll.FieldByName('Nome').AsString;
Forminscont.Edit2.Text:=QContAll.FieldByName('Email').AsString;
Forminscont.Edit3.Text:=QContAll.FieldByName('Celular').AsString;
Forminscont.Memo1.Text:=QContAll.FieldByName('Obs').AsString;
if Forminscont.ShowModal = mrOk then
begin
  S := QContAll.FieldByName('ID_Contato').AsString;
  QContAll.Close;
  QTemp.Close;
  QTemp.SQL.Text := 'update ContatosTB set Nome="'+Forminscont.Edit1.Text+'",Email="'+
   Forminscont.Edit2.Text+'",Celular="'+Forminscont.Edit3.Text+'",Obs="'+Forminscont.Memo1.Text+'" '+
   'where ID_Contato='+S;
  QTemp.ExecSQL;
  QContAll.Open;
  QContAll.Locate('ID_Contato',S,[]);
end;
end;

//Deletar email do Google
procedure TForm1.ColorSpeedButton93Click(Sender: TObject);
var
  Resource : TUsersMessagesResource;
begin
  Resource:=Nil;
  try
    Resource:=FGmailAPI.CreateusersMessagesResource(Self);
    if TVGmail.Selected.Text='INBOX' then
    Resource.Trash(LVMessages.Selected.SubItems[3],'me') else
     if TVGmail.Selected.Text='TRASH' then
       if MessageDlg('Deletar definitivamente a mensagem?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
       Resource.Delete(LVMessages.Selected.SubItems[3],'me');
  finally
    Resource.Free;
    ShowLabelGmail(googlegmail.TLabel(TVGmail.Selected.Data).id);
  end;
end;

//Atualizar email do Google
procedure TForm1.ColorSpeedButton94Click(Sender: TObject);
begin
ShowLabelGmail(googlegmail.TLabel(TVGmail.Selected.Data).id);
end;

procedure TForm1.ColorSpeedButton95Click(Sender: TObject);
begin
if T1.Enabled = True then
begin
  T1.Enabled := False;
  ColorSpeedButton65.Caption := cs_Retorna;
end;
end;

//Timeline - Ranking dos projetos do ano
procedure TForm1.ColorSpeedButton96Click(Sender: TObject);
begin
  if Sender = ColorSpeedButton96 then
  begin
    if ColorSpeedButton97.Pressed then ColorSpeedButton97.Pressed := False;
    ColorSpeedButton96.Pressed := not ColorSpeedButton96.Pressed;
    DBGrid2.Columns[1].Visible := False;
  end;
  if Sender = ColorSpeedButton97 then
  begin
    if ColorSpeedButton96.Pressed then ColorSpeedButton96.Pressed := False;
    ColorSpeedButton97.Pressed := not ColorSpeedButton97.Pressed;
    DBGrid2.Columns[1].Visible := True;
  end;
  if (ColorSpeedButton96.Pressed) or (ColorSpeedButton97.Pressed) then
  begin
    // Panel95.Visible:=False;
    DBGrid2.Visible := True;
    // DBGrid2.Align:=alClient;
    // DBGrid2.DataSource:=DSTl;
    QTl.Close;
    if Sender = ColorSpeedButton97 then
      QTl.SQL.Text := 'SELECT strftime(''%Y'',Dia) AS "Ano", ' +
        'strftime(''%m'',Dia) AS "Mês", ProjName AS "Projeto", sum(Tempo)/999.9999/60/60 AS "Horas trabalhadas" '
        +
        //999.999 é para não dividir por 1000, o que seria sempre um número inteiro, mas preciso de um float.
        'FROM ProjsTB INNER JOIN TimeLineTB ON ' +
        'ProjsTB.ID_Proj=TimeLineTB.ProjID WHERE (strftime(''%Y'',Dia)="' +
        ListBox1x.Items[ListBox1x.ItemIndex] + '")  ' +  //Tem que ter as aspas entre os listbox
        'GROUP BY ProjName,Mês ORDER BY Ano,Mês,"Horas trabalhadas" DESC'
    else
      QTl.SQL.Text :=
        'SELECT (strftime(''%Y'',Dia)) AS "Ano",ProjName AS "Projeto", sum(Tempo)/999.9999/60/60 as "Horas trabalhadas" FROM ProjsTB INNER JOIN TimeLineTB ON ' + //999.999 é para não dividir por 1000, o que seria sempre um número inteiro, mas preciso de um float.
        'ProjsTB.ID_Proj=TimeLineTB.ProjID WHERE (strftime(''%Y'',Dia)="' +
        ListBox1x.Items[ListBox1x.ItemIndex] + '") ' +  //Tem que ter as aspas entre os listbox
        'GROUP BY ProjName ORDER BY "Horas trabalhadas" DESC';
    QTl.Open;
  end
  else
  begin
    // Panel95.Visible:=True;
    DBGrid2.Visible := False;
    // Panel95.Align:=alClient;
    // DBGrid2.DataSource:=Nil;
  end;
end;

procedure TForm1.ColorSpeedButton97Click(Sender: TObject);
begin
ColorSpeedButton96Click(Sender);
end;

procedure TForm1.ColorSpeedButton98Click(Sender: TObject);
var i:Integer;
begin
i:=ListBox1.ItemIndex;
if (i=0) or (i=-1) then Exit;
ListBox1.Items.Move(i,i-1);
ListBox1.ItemIndex:=i-1;
end;

procedure TForm1.ColorSpeedButton99Click(Sender: TObject);
var i:Integer;
begin
i:=ListBox1.ItemIndex;
if (i=ListBox1.Count-1) or (i=-1) then Exit;
ListBox1.Items.Move(i,i+1);
ListBox1.ItemIndex:=i+1;
end;

procedure TForm1.DBGrid4GetCellHint(Sender: TObject; Column: TColumn;
  var AText: String);
begin
if Column=nil then Exit; //GPF se não colocar.
if Column.FieldName = 'Tarefa' then
 if QTarAF.Active then
 AText := QTarAF.Fields[2].AsString;
end;

procedure TForm1.DBGrid5GetCellHint(Sender: TObject; Column: TColumn;
  var AText: String);
begin
if Column=nil then Exit; //GPF se não colocar.
if Column.FieldName = 'Tarefa' then
 if QTarFin.Active then
 AText := QTarFin.Fields[2].AsString;
end;

procedure TForm1.DBGrid7DblClick(Sender: TObject);
begin
  ColorSpeedButton86Click(Self);
end;

Procedure TForm1.CreateDescGmail(E : TMessage; var Desc : TMailDescription);
  var H : TMessagePartHeader;
  begin
    Desc.Subject:='';
    Desc.Sender:='';
    Desc.Received:='';
    Desc.from:='';
    Desc.Recipient:='';
    Desc.Snippet:=E.snippet;
    If Assigned(E.payload) then
      For H in E.payload.headers do
        Case LowerCase(h.name) of
          'subject' : Desc.Subject:=H.value;
          'sender' : Desc.Sender:=H.value;
          'received' : Desc.Received:=H.Value;
          'date' : Desc.Received:=H.Value;
          'from' : Desc.from:=H.Value;
          'to' : Desc.Recipient:=H.Value;
        end;
  end;

procedure TForm1.DBGrid9DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Entry: Tmessage;
  Resource : TUsersMessagesResource;
begin
  Resource:=Nil;
  try
    Resource:=FGmailAPI.CreateusersMessagesResource(Self);
    Entry:=Resource.Get(LVMessages.Selected.SubItems[3],'me','format=raw');
    HoldEML.Strings.Text:=Entry.Raw;
    AbrirEmailEML(HoldEML,True);
    QMail.Close;
    QMail.OPen;
    QMail.Locate('ID_Mail',VarArrayOf([LastTempMail]),[]);
  finally
    Resource.Free;
  end;
end;

procedure TForm1.DBGrid9DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
Accept := Source = LVMessages;
end;

procedure TForm1.DBMemo2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(DBMemo2, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(DBMemo2, LastSearch, 0);
end;

procedure TForm1.DE10EditingDone(Sender: TObject);
begin
{ConfigSalvarStr('CfgLnxTB', 'PastaProj', DE10.Text);
{$IFDEF LINUX}
PastaProj:=DE10.Text;
AbrirProj();
{$ENDIF}
}end;

procedure TForm1.DE6EditingDone(Sender: TObject);
begin
//ConfigSalvarStr(CFGTB, 'PastaModels', DE6.Text);
//PastaModels := DE6.Text;
end;

procedure TForm1.DE7EditingDone(Sender: TObject);
begin
{ConfigSalvarStr(CFGTB, 'PastaDown', DE7.Text);
PastaDown := DE7.Text;
STV1.Root := PastaDown;
}end;

procedure TForm1.DE8EditingDone(Sender: TObject);
begin
// ConfigSalvarStr(CFGTB, 'PastaDrop', DE8.Text);
// PastaDrop := DE8.Text;
end;

procedure TForm1.DE9EditingDone(Sender: TObject);
begin
{ConfigSalvarStr('CfgWinTB', 'PastaProj', DE9.Text);
{$IFDEF WINDOWS}
PastaProj:=DE9.Text;
AbrirProj();
{$ENDIF}
}end;

procedure TForm1.Edit6Change(Sender: TObject);
var
  S: string;
begin
if not CheckBox2.Checked then Exit;

QContAll.Close;
if Edit6.Text = '' then
  QContAll.SQL.Text := 'Select * from ContatosTB order by Nome COLLATE NOCASE'
else
  QContAll.SQL.Text :=
    'SELECT distinct ID_Contato,Nome,Email,Celular,Obs FROM ContatosTB where ((ContatosTB.Nome like "%'+
    Edit6.Text+'%") or (ContatosTB.Email like "%' + Edit6.Text + '%")) ' +
    'UNION SELECT distinct ID_Contato,Nome,Email,Celular,Obs FROM ContatosTB INNER JOIN (MarcsContTB INNER JOIN '+
    'ContMarcTBm ON MarcsContTB.ID_Marc = ContMarcTBm.MarcID) ON ContatosTB.ID_Contato = ContMarcTBm.ContID ' +
    'WHERE (MarcsContTB.Marcador Like "%' + Edit6.Text + '%") order by Nome COLLATE NOCASE';
QContAll.Open;
//LerMarcsCont();
end;

procedure TForm1.LBCalGooSelectionChange(Sender: TObject; User: boolean);
var
  Entry: TEvent;
  i: integer;
  lab1,lab2,LabT:TLabel;
  pan:TPanel;
  Dini,Dfim:TDateTime;
begin
  FCurrentCalendar := LBCalGoo.Items.Objects[LBCalGoo.ItemIndex] as TCalendarListEntry;

  if LBCalGoo.ItemIndex < 0 then  Exit;
  Screen.Cursor:=crHourGLass;
  FreeAndNil(Events);
  Events := FCalendarAPI.EventsResource.list(FCurrentCalendar.id,
    'timeMin='+IntToStr(YearOf(Now-1))+'-'+IntToStr(MonthOf(Now-1))+'-'+IntToStr(DayOf(Now-1))+
    'T00:00:01Z&timeMax='+IntToStr(YearOf(Now)+1)+'-'+IntToStr(MonthOf(Now))+'-'+IntToStr(DayOf(Now))+'T23:59:59Z');

  SaveRefreshToken('Cal');
  i := 0;
  //Guarda tudo numa tabela para ordenar e recuperar as informações depois
  QTemp.SQL.Text:='delete from AuxCalGoo';
  QTemp.ExecSQL;
  for i:=0 to length(Events.items)-1 do begin
   Entry:=Events.items[i];
   QTemp.Close;
   QTemp.SQL.Text:='select id,data_ini,data_fim,desc,suma from AuxCalGoo';
   QTemp.Open;
   QTemp.Insert;
   QTemp.Fields[0].AsString:=Entry.id;
   if Entry.start.date <> 0 then
    QTemp.Fields[1].AsDateTime:=Entry.start.date else
     QTemp.Fields[1].AsDateTime:=Entry.start.datetime;
   QTemp.Fields[2].AsDateTime:=Entry._end.datetime;
   QTemp.Fields[3].AsString:=Entry.summary;
   QTemp.Fields[4].AsString:=Entry.description;
   QTemp.Post;
  end;
  QTemp.Close;
  QTemp.SQL.Text:='select id,data_ini,data_fim,desc,suma from AuxCalGoo order by data_ini desc';
  QTemp.Open;

  for i := 0 to SBCal.ControlCount - 1 do SBCal.Controls[0].Free;
  QTemp.DisableControls;
  SBCal.Visible:=False;
  QTemp.First;
  while not QTemp.EOF do begin
   Dini:=QTemp.Fields[1].AsDateTime;
   Dfim:=QTemp.Fields[2].AsDateTime;

   pan := TPanel.Create(SBCal);
   pan.Parent := SBCal;
   pan.Align:=alTop;
   pan.Height := 90;
   pan.Color:=$0046A25E;
   pan.Caption:='';
   pan.Hint:=QTemp.Fields[0].AsString; //Guardando a id
   pan.OnMouseEnter:=@panCalMouseEnter;
   pan.OnMouseLeave:=@panCalMouseLeave;
   pan.OnDblClick:=@panCalDoubleClick;

   labT:=TLabel.Create(nil);
   labT.Parent:=pan;
   labT.Align:=alTop;
   labT.Font.Size:=13;
   labT.Caption:='           '+ExtDiaSemana(Dini)+', '+DateToStr(Dini);

   lab1:=TLabel.Create(nil);
   lab1.Parent:=pan;
   lab1.Top:=32;
   lab1.Font.Size:=11;
   lab1.Font.Style:=[fsBold];
   lab1.Font.Color:=clWhite;
   lab1.Caption:=' '+QTemp.Fields[3].AsString;

   lab2:=TLabel.Create(nil);
   lab2.Parent:=pan;
   lab2.Top:=60;
   lab2.Font.Size:=10;
   lab2.Font.Color:=clWhite;
   if HourOf(Dini)=0 then
     lab2.Caption:=' Dia todo' else
      lab2.Caption:=' '+FormatDateTime('hh:nn',Dini)+' até '+FormatDateTime('hh:nn',Dfim);

   QTemp.Next;
  end;
  QTemp.EnableControls;
  SBCal.Visible:=True;
  Screen.Cursor:=crDefault;
end;


procedure TForm1.ColorSpeedButton10Click(Sender: TObject);
begin
  NB1.PageIndex := 3;
  ConfigSalvarInt('ConfigTB', 'LastButton', 3);
end;

procedure TForm1.ColorSpeedButton11Click(Sender: TObject);
begin
  NB1.PageIndex := 1;
  ConfigSalvarInt('ConfigTB', 'LastButton', 1);
end;

procedure TForm1.ColorSpeedButton12Click(Sender: TObject);
begin
  NB1.PageIndex := 5;
  ConfigSalvarInt('ConfigTB', 'LastButton', 5);
end;

procedure TForm1.ColorSpeedButton13Click(Sender: TObject);
begin
  NB1.PageIndex := 4;
  ConfigSalvarInt('ConfigTB', 'LastButton', 4);
end;

procedure TForm1.ColorSpeedButton14Click(Sender: TObject);
var
  p, r: integer;
begin
  if (TV.Selected = nil) or (TV.Selected = TV.BottomItem) or (QProj.EOF) then Exit;
  r := QProj.RecNo;
  p := QProj.FieldByName('Posicao').AsInteger;
  QProj.Edit;
  QProj.FieldByName('Posicao').AsInteger := p + 1;
  QProj.Post;
  QProj.Next;
  p := QProj.FieldByName('Posicao').AsInteger;
  QProj.Edit;
  QProj.FieldByName('Posicao').AsInteger := p - 1;
  QProj.Post;
  QProj.Close;
  QProj.Open;
  PopTV();
  if r > 1 then
    QProj.RecNo := r
  else
    QProj.Last;
  TV.Selected := TV.Items[r];
  TV.SetFocus;
end;

procedure TForm1.ColorSpeedButton16Click(Sender: TObject);
begin
  NB1.PageIndex := 12;
  Ler_tl;
end;

procedure TForm1.ColorSpeedButton1Click(Sender: TObject);
begin
  NB1.PageIndex := 10;
end;

//Botão Close, mas usado para testes
//Tentativa de upload no Google Drive
procedure TForm1.ColorSpeedButton27Click(Sender: TObject);
{Var
  Entry : TFile;
  Request : TWebClientRequest;
  Responsex: TWebClientResponse;
  Bound,URL,LFN, FileName: ansiString;
  Resource: TFilesResource;
  List : TFileList;
  S:String;
}begin
Close;
  {  LoadAuthConfig('Drive');
      Resource:=Nil;
      try
         Resource:=FDriveAPI.CreateFilesResource(Self);
         Resource.na
         List:=Resource.list('root');
         Request:=FClientDrive.WebClient.CreateRequest;
         FileName:= 'bbb.txt';
         Bound := 'foo_bar_baz';
         try
             URL:= 'https://www.googleapis.com/upload/drive/v3/files?uploadType=media';
             Request.Headers.Add('Authorization: Bearer ' + FClientDrive.AuthHandler.Session.AccessToken);
             Request.Headers.Add('Content-Type: multipart/related; boundary="'+Bound+'"');
             Request.Headers.Add('Accept: application/json');
             s := #13 + '--' + Bound + #13 ;
             s := s + 'Content-Type: application/json; charset=UTF-8' + #13  ;
             s := s + '{' + #13;
             s := s + '"name": "' + ExtractFileName(FileName)+ '"' + #13;
             s := s + '}' + #13;
             s := s + '--' + bound + #13 ;
             s := s + 'Content-Type: text/html' + #13 + #13;
             s := s + 'Agora testando por aqui! Agora testando por aqui! Agora testando por aqui! Agora testando por aqui!'+ #13;
             s := s + '--' + bound + '--'+ #13 ;
             Request.SetContentFromString(S);
             Request.Content.;
             Request.Headers.Add('Content-Length: '+(S.Length).ToString);

             Responsex:=FClientDrive.WebClient.ExecuteSignedRequest('POST',URL,Request);
             try
                  Memo7.Lines.LoadFromStream(Responsex.Content);
             finally     end;
         finally
              Request.Free;
         end;
      finally
          FreeAndNil(Resource);
      end;
}
end;

procedure TForm1.ColorSpeedButton29Click(Sender: TObject);
var
  Si: string;
begin
  Si := QProj.Fields[0].AsString;
  QProj.Close;
  QTemp.Close;
  QTemp.SQL.Text := 'Update ProjsTB set Posicao=-1 where ID_Proj=' + Si;
  QTemp.ExecSQL;
  Edit1.Clear;
  RefazerPosicaoProj();
  PopTV();
  TV.Selected := TV.TopItem;
end;

procedure TForm1.RefazerPosicaoProj();
var
  i: integer;
begin
  i := 0;
  if QProj.Active = False then QProj.Open;
  QProj.First;
  while not QProj.EOF do
  begin
    QProj.Edit;
    QProj.FieldByName('Posicao').AsInteger := i;
    QProj.Post;
    i := i + 1;
    QProj.Next;
  end;
end;

procedure TForm1.ColorSpeedButton2Click(Sender: TObject);
begin
  NB1.PageIndex := 8;
end;

procedure TForm1.ColorSpeedButton30Click(Sender: TObject);
begin
  if TVb.Selected = nil then Exit;
  AcaoBut('1', TVb.Selected);
end;

procedure TForm1.ColorSpeedButton31Click(Sender: TObject);
begin
  if TVa.Selected = nil then Exit;
  AcaoBut('2', TVa.Selected);
end;

procedure TForm1.ColorSpeedButton32Click(Sender: TObject);
begin
  if TVc.Selected = nil then Exit;
  AcaoBut('2', TVc.Selected);
end;

procedure TForm1.ColorSpeedButton33Click(Sender: TObject);
begin
  if TVb.Selected = nil then Exit;
  AcaoBut('3', TVb.Selected);
end;

procedure TForm1.AcaoBut(SitTo: string; TreeFrom: TTreeNode);
var
  x: string;
begin
  if SitTo = '1' then x := '0';
  if SitTo = '2' then x := '27';
  if SitTo = '3' then x := '28';
  QSQx.Close;
  QSQx.SQL.Text := 'Update ProjsTB set Situacao=' + SitTo + ',Icons=' + x +
    ',Posicao=-1 where ProjName="' + TreeFrom.Text + '"';
  QSQx.ExecSQL;
  RefazerPosicaoX('1');
  RefazerPosicaoX('2');
  RefazerPosicaoX('3');
  PopTVx();
  Edit1.Text := '';
  QProj.Close;
  QProj.Open;
  PopTV();
end;

procedure TForm1.RefazerPosicaoX(Situa: string);
var
  i, ni: integer;
begin
  QSTempx1.Close;
  QSTempx1.SQL.Text := 'Select * from ProjsTB where Situacao=' + Situa + ' order by Posicao';
  QSTempx1.Open;
  QSTempx1.First;
  i := 0;
  QSQx.Close;
  QSQx.SQL.Text := 'Select * from ProjsTB where Situacao=' + Situa + ' order by Posicao';
  QSQx.Open;
  QSQx.First;
  i := 0;

  while not QSTempx1.EOF do
  begin
    if Situa = '3' then ni := 0
    else
      ni := i;
    QSQx.Locate('ID_Proj', VarArrayOf([QSTempx1.Fields[0].AsInteger]), []);
    Form1.Conn.ExecuteDirect('Update ProjsTB set Posicao=' + IntToStr(ni) +
      ' where ID_Proj=' + IntToStr(QSTempx1.FieldByName('ID_Proj').AsInteger));
    i := i + 1;
    QSTempx1.Next;
  end;
end;

procedure TForm1.ColorSpeedButton35Click(Sender: TObject);
begin
NB1.PageIndex := 9;
EdBusca.SetFocus;
end;

procedure TForm1.ColorSpeedButton3Click(Sender: TObject);
var
  lowerLeft: TPoint;
begin
  lowerLeft := Point(0, ColorSpeedButton3.Height);
  lowerLeft := ColorSpeedButton3.ClientToScreen(lowerLeft);
  PopupMenu1.Popup(lowerLeft.X, lowerLeft.Y);
end;

procedure TForm1.ColorSpeedButton41Click(Sender: TObject);
begin
  Ler_Audios();
end;

procedure TForm1.ColorSpeedButton42Click(Sender: TObject);
var
  S: string;
begin
  if LVAudio.ItemFocused = nil then
    if LVAudio.Items.Count > 0 then
      LVAudio.ItemFocused := LVAudio.Items[0]
    else
      Exit;
  if MessageDlg('Deletar arquivo de áudio?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    S := PastaDropAudio + PathDelim + LVAudio.ItemFocused.Caption;
    if not FileExistsUTF8(S) then Exit;
    DeleteFile(S);
    Ler_Audios();
  end;
end;

procedure TForm1.ColorSpeedButton43Click(Sender: TObject);
var
  S, S1: String;
begin
  if LVAudio.ItemFocused = nil then Exit;
  //Não funciona com acentos. Vamos copiar um arquivo para um nome aleatótio, executar, guardar num memo e deletar no FormDestroy
  S := PastaDropAudio + LVAudio.ItemFocused.Caption;
  if (pos('â', S) > 0) or (pos('Â', S) > 0) or (pos('á', S) > 0) or (pos('Á', S) > 0) or
    (pos('é', S) > 0) or (pos('É', S) > 0) or (pos('í', S) > 0) or (pos('Í', S) > 0) or
    (pos('ç', S) > 0) or (pos('Ç', S) > 0) or (pos('ã', S) > 0) or (pos('Ã', S) > 0) or
    (pos('ó', S) > 0) or (pos('Ó', S) > 0) or (pos('ê', S) > 0) or (pos('Ê', S) > 0) or
    (pos('õ', S) > 0) or (pos('Õ', S) > 0) or (pos('ñ', S) > 0) or (pos('Ñ', S) > 0) or
    (pos('ü', S) > 0) or (pos('Ü', S) > 0) or (pos('ö', S) > 0) or (pos('Ö', S) > 0) then
  begin
    Randomize;
    S1:=GetTempDir+'t' + IntToStr(Random(1000000)) + '.tmp';
    CopyFile(S, S1);
    PlaySound1.SoundFile := S1;
    MemoTmpAudio.Lines.Add(S1);
  end
  else
    PlaySound1.SoundFile := S;
  {$IFDEF Windows}
// playsound1.PlayCommand:='sndPlaySound';  //Parou de funcionar. A solução está em:
//https://forum.lazarus.freepascal.org/index.php/topic,52252.msg384811.html#msg384811

 MCISendStringW(PWideChar(UTF8Decode('OPEN "'+PlaySound1.SoundFile+'" TYPE mpegvideo alias '+S1)), nil, 0, 0);
 MCISendStringW(PWideChar(UTF8Decode('PLAY '+S1)), nil, 0, 0);
 MCISendStringW(PWideChar(UTF8Decode('CLOSE ANIMATION')), nil, 0, 0);

{$ELSE}
 PlaySound1.PlayCommand := 'ffplay';
{$ENDIF}
PlaySound1.Execute;
end;

procedure TForm1.ColorSpeedButton44Click(Sender: TObject);
begin
{$IFDEF Windows}
 MCISendStringW(PWideChar(UTF8Decode('CLOSE ANIMATION')), nil, 0, 0); //Não funciona
//PlaySound1.StopSound;
{$ELSE}
  PlaySound1.StopSound;
{$ENDIF}
end;

procedure TForm1.ColorSpeedButton46Click(Sender: TObject);
begin
  ShowMessage('Não implementado ainda!');
end;

procedure TForm1.ColorSpeedButton47Click(Sender: TObject);
begin
  Notebook1.PageIndex := 0;
end;

procedure TForm1.ColorSpeedButton48Click(Sender: TObject);
begin
  Notebook1.PageIndex := 1;
end;

procedure TForm1.ColorSpeedButton49Click(Sender: TObject);
begin
  Notebook1.PageIndex := 2;
end;

procedure TForm1.ColorSpeedButton4Click(Sender: TObject);
begin
  NB1.PageIndex := 0;
  ConfigSalvarInt('ConfigTB', 'LastButton', 0);
end;

procedure TForm1.ColorSpeedButton50Click(Sender: TObject);
begin
  Notebook1.PageIndex := 3;
end;

procedure TForm1.ColorSpeedButton52Click(Sender: TObject);
begin
  ColorSpeedButton16Click(Self);
end;

procedure TForm1.ColorSpeedButton53Click(Sender: TObject);
var
  i: string;
begin
  if TVc.Items.Count = 0 then Exit;
  if MessageDlg('Tem certeza que deseja deletar definitivamente o Projeto '+TVc.Selected.Text+'?',
    mtConfirmation, [mbNo, mbYes], 0) <> mrYes then Exit;

  QSQx.Close;
  QSQx.SQL.Text := 'Select ID_Proj from ProjsTB where ProjName="' + TVc.Selected.Text + '"';
  QSQx.Open;
  i := QSQx.Fields[0].AsString;

  QSQx.Close;
  QSQx.SQL.Text := 'Delete from TimeLineTB where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from TarefasTB where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from ProjMarcTBm where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from ProjContTBm where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from NotasTB where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from LinksTB where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from AgendaTB where ProjID=' + i;
  QSQx.ExecSQL;
  QSQx.Close;
  QSQx.SQL.Text := 'Delete from MailsTB where ProjID=' + i;
  QSQx.ExecSQL;

  QSQx.Close;
  QSQx.SQL.Text := 'Delete from ProjsTB where ProjName="' + TVc.Selected.Text + '"';
  QSQx.ExecSQL;

  if MessageDlg('Apagar diretório','Apagar a pasta do Projeto?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
   DeleteDirectory(PastaProj+PathDelim+TVc.Selected.Text, False);

  PopTVx();
end;

procedure TForm1.ColorSpeedButton54Click(Sender: TObject);
var
 S: string;
 i: integer;
begin
S := QProj.FieldByName('ProjName').AsString;
if not InputQuery('Editar nome do Projeto', 'Novo nome do Projeto:', S) then Exit;
if (TV.Selected = nil) or (TV.Items.Count = 0) then Exit;
if S='' then Exit;

QProj.DisableControls;
QProj.Edit;
QProj.FieldByName('ProjName').AsString := S;
QProj.Post;
QProj.EnableControls;
if RenameFile(PastaProjAtual,PastaProj+PathDelim+S) then
 ShowMessage('Pasta de arquivos foi renomeada para '+PastaProj+PathDelim+S) else
  ShowMessage('Mudança de nome da pasta falhou!');
QProj.Close;
QProj.Open;
PopTV();
PopTVx();
QProj.Locate('ProjName',S,[]);
for i:=0 to TVa.Items.Count-1 do
 if TVa.Items[i].Text=S then
  TVa.Items[i].Selected:=True;
//AbrirProj();
end;

procedure TForm1.ColorSpeedButton55Click(Sender: TObject);
begin
QNotas.Close;
QNotas.SQL.Text := 'delete from NotasTB where ProjID=' + IntToStr(
 QProj.FieldByName('ID_Proj').AsInteger);
QNotas.ExecSQL;
QNotas.Close;
QNotas.SQL.Text := 'insert into NotasTB (ProjID,Nota1,Nota2,Nota3,Nota4) values (' +
  IntToStr(QProj.FieldByName('ID_Proj').AsInteger) + ',"' + Memo1.Lines.Text +
  '","' + Memo2.Lines.Text + '","' + Memo3.Lines.Text + '","' + Memo4.Lines.Text + '")';
QNotas.ExecSQL;
QNotas.Close;
QNotas.SQL.Text := 'select * from NotasTB where ProjID=' + IntToStr(
  QProj.FieldByName('ID_Proj').AsInteger);
QNotas.Open;
ContarNotas();
end;

procedure TForm1.ColorSpeedButton56Click(Sender: TObject);
begin
  FormLink.Edit1.Text := '';
  FormLink.Edit2.Text := '';
  if FormLink.ShowModal = mrOk then
  begin
    QLinks.Close;
    QLinks.SQL.Text := 'insert into LinksTB (ProjID,Descricao,Link) values (' +
      IntToStr(QProj.FieldByName('ID_Proj').AsInteger) + ',"' + FormLink.Edit1.Text +
      '","' + FormLink.Edit2.Text + '")';
    QLinks.ExecSQL;
    AbrirLinks();
  end;
  DBGrid6.SetFocus;
end;

procedure TForm1.ColorSpeedButton57Click(Sender: TObject);
begin
  if MessageDlg('Apagar link?', mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
    QLinks.Delete;
end;

procedure TForm1.ColorSpeedButton58Click(Sender: TObject);
var
  Si: string;
  r: integer;
begin
  r := QLinks.RecNo;
  Si := QLinks.Fields[0].AsString;
  FormLink.Edit1.Text := QLinks.FieldByName('Descricao').AsString;
  FormLink.Edit2.Text := QLinks.FieldByName('Link').AsString;
  ;
  if FormLink.ShowModal = mrOk then
  begin
    QLinks.Close;
    QLinks.SQL.Text := 'update LinksTB set Descricao="' + FormLink.Edit1.Text +
      '",Link="' + FormLink.Edit2.Text + '" where ID_Link=' + Si;
    QLinks.ExecSQL;
    AbrirLinks();
    QLinks.RecNo := r;
  end;
end;

procedure TForm1.ColorSpeedButton59Click(Sender: TObject);
var
  P: TProcess;
  S: string;
begin
  S := QLinks.FieldByName('Link').AsString;
  if FileExists(S) then begin
    OpenDocument(S) end else
   if DirectoryExists(S) then  begin
    {$IFDEF Linux}
    P:=TProcess.Create(nil);
    P.Executable:='nautilus';
    P.Parameters.Add(S);
    P.Execute;
    P.Active:=True;
    P.Free;  //Se colocar isso a janela não vem para frente. Será?
    {$ELSE}
    OpenDocument(S);
    {$ENDIF}
   end else
  if (Pos('http', S) > 0) or (Pos('www', S) > 0) then
    OpenURL(S)
  else
    OpenURL('http://' + S);
end;

procedure TForm1.AbrirLinks();
begin
  QLinks.Close;
  QLinks.SQL.Text := 'Select * from LinksTB where ProjID=' + IntToStr(
    QProj.FieldByName('ID_Proj').AsInteger) + ' order by ID_Link desc';
  QLinks.Open;
  ColorSpeedButton12.Caption := 'Links (' + IntToStr(QLinks.RecordCount) + ')';
end;

procedure TForm1.ColorSpeedButton5Click(Sender: TObject);
begin
  if MudouMemos then ColorSpeedButton55Click(Self);
  Edit1.Clear;
end;

procedure TForm1.ColorSpeedButton60Click(Sender: TObject);
begin
  Forminscont.Edit1.Clear;
  Forminscont.Edit2.Clear;
  Forminscont.Edit3.Clear;
  Forminscont.Memo1.Clear;
  if Forminscont.ShowModal = mrOk then
  begin
    QContAll.Close;
    QContAll.SQL.Text := 'insert into ContatosTB (Nome,Email,Celular,Obs) values ("' +
      Forminscont.Edit1.Text + '","' + Forminscont.Edit2.Text + '","' + Forminscont.Edit3.Text + '","'+
      Forminscont.Memo1.Text+'")';
    QContAll.ExecSQL;
    DBGrid7TitleClick(DBGrid7.Columns[0]);
  end;
end;

procedure TForm1.ColorSpeedButton61Click(Sender: TObject);
var
  S: string;
begin
  if (not QContAll.Active) or (QContAll.IsEmpty) then Exit;
  if QContAll.State = dsBrowse then
  //  if MessageDlg(rs_DelCont1 + QContAll.FieldByName('Nome').AsString + '"?',
 //     mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
    begin
      S := QContAll.FieldByName('ID_Contato').AsString;
      QTemp.Close;
      QTemp.SQL.Text := 'Delete from ContMarcTBm where ContID=' + S;
      QTemp.ExecSQL;
      QTemp.Close;
      QTemp.SQL.Text := 'Delete from ContatosTB where ID_Contato=' + S;
      QTemp.ExecSQL;
      QContAll.Close;
      QContAll.Open;
      QMarcCont.Close;
      QMarcCont.Open;
      DBGrid8TitleClick(DBGrid8.Columns[0]);
    end;
end;

procedure TForm1.ColorSpeedButton62Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  QTemp.Close;
  QTemp.SQL.Text := 'Delete from ProjContTBm where (ContID=' +
    QContProj.FieldByName('ID_Contato').AsString + ') and (ProjID=' + QProj.Fields[0].AsString + ')';
  QTemp.ExecSQL;
  LerContAll(' order by Nome COLLATE NOCASE ASC');
  LerContProj(' order by Nome COLLATE NOCASE ASC');
end;

procedure TForm1.ColorSpeedButton63Click(Sender: TObject);
begin
  DBGrid8DragDrop(Self, Self, 0, 0);
end;

//Conectar com Gmail
procedure TForm1.ColorSpeedButton67Click(Sender: TObject);
var scope, S: String;
begin
scope:='https://mail.google.com/';
OpenURL('https://accounts.google.com/o/oauth2/auth?scope='+scope+
 '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=' + ClientId);

if not InputQuery('Entre com o código copiado','Código criado pelo Google GMail',S) then Exit;
Screen.Cursor:=crHourGlass;
//ShowMessage('foi2');
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
MessageDlg('Atenticação no Google GMail realizada com SUCESSO!', mtInformation, [mbOK], 0);
end;

procedure TForm1.ColorSpeedButton69Click(Sender: TObject);
begin
NB1.PageIndex := 13;
end;

procedure TForm1.ColorSpeedButton6Click(Sender: TObject);
var
  p, r: integer;
begin
  if (TV.Selected = nil) or (TV.Selected = TV.TopItem) or (QProj.BOF) then Exit;
  r := QProj.RecNo;
  p := QProj.FieldByName('Posicao').AsInteger;
  QProj.Edit;
  QProj.FieldByName('Posicao').AsInteger := p - 1;
  QProj.Post;
  QProj.Prior;
  p := QProj.FieldByName('Posicao').AsInteger;
  QProj.Edit;
  QProj.FieldByName('Posicao').AsInteger := p + 1;
  QProj.Post;
  QProj.Close;
  QProj.Open;
  PopTV();
  if r > 1 then
    QProj.RecNo := r
  else
    QProj.First;
  TV.Selected := TV.Items[r - 2];
  TV.SetFocus;
end;

procedure TForm1.ColorSpeedButton72Click(Sender: TObject);
begin
  Panel123.Visible := not Panel123.Visible;
  Panel124.Visible := not Panel124.Visible;
end;

procedure TForm1.ColorSpeedButton73Click(Sender: TObject);
begin
  NB1.PageIndex := 11;
  ConfigSalvarInt('ConfigTB', 'LastButton', 11);
end;

//Conectar com a agenda do Google
procedure TForm1.ColorSpeedButton75Click(Sender: TObject);
var scope, S: String;
begin
scope:='https://www.googleapis.com/auth/calendar';
OpenURL('https://accounts.google.com/o/oauth2/auth?scope='+scope+
 '&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=' + ClientId);
if not InputQuery('Entre com o código copiado','Código criado pelo Google Calendar',S) then Exit;
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
MessageDlg('Atenticação no Google GMail realizada com SUCESSO!', mtInformation, [mbOK], 0);
end;

//Botão Tarefas na barra do Google
procedure TForm1.ColorSpeedButton76Click(Sender: TObject);
var
  Entry: TTaskList;
  Resource: TTaskListsResource;
  EN: string;
  i: integer;
begin
Notebook2.PageIndex:=0;
if Panel127.Width=45 then begin
  TimerPanel.Enabled := True;
  Screen.Cursor:=crHourGlass;
  LBTarGoo.Items.Clear;
  FreeAndNil(FTaskLists);
  Resource := nil;
  try

    try
      Resource := FTasksAPI.CreateTaskListsResource;
      FTaskLists := Resource.list('');
    except on exception do begin
      MessageDlg('É necessário solicitar nova autorização ao Google!',mtError,[mbOk],0);
      ConfigSalvarStr('ConfigTB', 'accessTokenTasks', '');
      ConfigSalvarStr('ConfigTB', 'refreshTokenTasks', '');
      Screen.Cursor:=crDefault;
      Panel127.Width:=45;
      Exit;
      end;
    end;

    SaveRefreshToken('Tasks');
    if assigned(FTaskLists) then
      for i := 0 to Length(FTaskLists.items) - 1 do begin
        Entry := FTaskLists.items[i];
        EN := Entry.title;
        LBTarGoo.Items.AddObject(IntToStr(i) + ': ' + EN, Entry);
      end;
    if LBTarGoo.Items.Count>0 then begin
      LBTarGoo.ItemIndex:=0;
      LBTarGooSelectionChange(Self,True);
    end;
    Screen.Cursor:=crDefault;
  finally begin
    FreeAndNil(Resource);
   end;
  end;
end else begin
  Panel127.Width := 45;
  for i := 0 to SBCal.ControlCount - 1 do SBCal.Controls[0].Free;
end;

end;

procedure TForm1.ColorSpeedButton7Click(Sender: TObject);
begin
  NB1.PageIndex := 6;
  ConfigSalvarInt('ConfigTB', 'LastButton', 6);
  LerAgendaMes();
  AjeitarTamanhoColunasAgenda;
end;

//Adicionar tarefa
procedure TForm1.ColorSpeedButton80Click(Sender: TObject);
var Tk,Tkn:Ttask;
Tstr,Nstr: String;
i: integer;
Mm: TMemo;
begin
if ColorSpeedButton80.Caption='Adicionar uma tarefa' then
  begin
    Screen.Cursor:=crHourGlass;

    Tkn:=TTask.Create;
    FTasksAPI.TasksResource.Insert(FCurrentList.id,Tkn);

    ColorSpeedButton80.Caption:='Atualizar';
    LBTarGooSelectionChange(Self,True);
    Screen.Cursor:=crDefault;

  end else
if ColorSpeedButton80.Caption='Atualizar' then
  begin
    Screen.Cursor:=crHourGlass;
    Mm:=(FindComponent('MemoTarGoo'+IntToStr(MemoTarGooInt))) as TMemo;
    if not Assigned(Mm) then Exit;
    Tstr:=Mm.Lines[0];
    Nstr:='';
    for i:=1 to Mm.Lines.Count-1 do Nstr:=Nstr+Mm.Lines[i]+#13;
    Tk:=TTask.Create;
    Tk.title:=Tstr;
    Tk.notes:=Nstr;
    //update não rola. Tem que apagar e inserir de novo. E não tem como manter a posição.
    FTasksAPI.TasksResource.Delete(FTasks.items[MemoTarGooInt].id,FTaskLists.items[LBTarGoo.ItemIndex].id);
    FTasksAPI.TasksResource.Insert(FCurrentList.id,Tk);

    LBTarGooSelectionChange(Self,True);
    ColorSpeedButton80.Caption:='Adicionar uma tarefa';
    Screen.Cursor:=crDefault;
  end;
end;

procedure TForm1.ColorSpeedButton81Click(Sender: TObject);
var
  Entry: TCalendarListEntry;
  Resource: TCalendarListResource;
  EN: string;
  i: integer;
begin
Notebook2.PageIndex:=1;
if Panel127.Width=45 then begin
 Screen.Cursor:=crHourGlass;
 TimerPanel.Enabled := True;
 LBCalGoo.Items.Clear;
 FreeAndNil(CalendarList);
 Resource := nil;
 try
   try
    Resource := FCalendarAPI.CreateCalendarListResource;
    CalendarList := Resource.list('');
   except on exception do begin
     MessageDlg('É necessário solicitar nova autorização ao Google!',mtError,[mbOk],0);
     ConfigSalvarStr('ConfigTB', 'accessTokenCal', '');
     ConfigSalvarStr('ConfigTB', 'refreshTokenCal', '');
     Screen.Cursor:=crDefault;
     Panel127.Width:=45;
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
       LBCalGoo.Items.AddObject(IntToStr(i) + ': ' + EN, Entry);
     end;
 finally
   FreeAndNil(Resource);
 end;
 Screen.Cursor:=crDefault;

end else begin
 Panel127.Width := 45;
end;
end;

procedure TForm1.ColorSpeedButton8Click(Sender: TObject);
begin
  NB1.PageIndex := 2;
  ConfigSalvarInt('ConfigTB', 'LastButton', 2);
end;

procedure TForm1.ColorSpeedButton9Click(Sender: TObject);
begin
  LerContAll(' order by Nome COLLATE NOCASE ASC');
  NB1.PageIndex := 7;
  ConfigSalvarInt('ConfigTB', 'LastButton', 7);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  S: string;
begin
  S := ComboBox1.Text;
  if pos('en-us', S) > 0 then
  begin
    SetDefaultLang('en-us');
    ConfigSalvarStr('ConfigTB', 'Idioma', 'en-us');
  end
  else
  if pos('pt-br', S) > 0 then
  begin
    SetDefaultLang('pt-br');
    ConfigSalvarStr('ConfigTB', 'Idioma', 'pt-br');
  end;

  Form1.Caption := rs_FORM1CAPTION;
{DBGrid9.Columns[0].Title.Caption:=rs_SGEmail_ER;
DBGrid9.Columns[1].Title.Caption:=rs_SGEmail_De;
DBGrid9.Columns[2].Title.Caption:=rs_SGEmail_Assunto;
DBGrid9.Columns[3].Title.Caption:=rs_SGEmail_Data;
DBGrid7.Columns[0].Title.Caption:=rs_Nome;
DBGrid7.Columns[2].Title.Caption:=rs_cel;
DBGrid1.Columns[0].Title.Caption:=rs_Marc;
DBGrid8.Columns[0].Title.Caption:=rs_Nome;
DBGrid8.Columns[2].Title.Caption:=rs_cel;
DBGrid4.Columns[1].Title.Caption:=rs_Task;
DBGrid4.Columns[2].Title.Caption:=rs_Prazo;
DBGrid5.Columns[1].Title.Caption:=rs_Task;
DBGrid5.Columns[2].Title.Caption:=rs_Prazo;
DBGrid6.Columns[0].Title.Caption:=rs_Desc;
Edit1.TextHint:=rs_Edit1Hint;
Edit8.TextHint:=rs_Search;
Edit3.TextHint:=rs_Search;
Edit4.TextHint:=rs_Search;
Edit2.TextHint:=rs_Search;
Edit5.TextHint:=rs_Search;
}
  AbrirProj;

end;

//Botão deletar Tarefa do Google
procedure TForm1.ColorSpeedButton82Click(Sender: TObject);
begin
if not assigned(FTasks) then Exit;
if MessageDlg('Excluir a tarefa selecionada?',mtConfirmation,[mbOk,mbCancel],0)<>mrOk then Exit;
Screen.Cursor:=crHourGlass;
FTasksAPI.TasksResource.Delete(FTasks.items[MemoTarGooInt].id,FTaskLists.items[LBTarGoo.ItemIndex].id);
LBTarGooSelectionChange(Self,True);
Screen.Cursor:=crDefault;
end;

procedure TForm1.ColorSpeedButton88Click(Sender: TObject);
var
  Entry, Insert: TEvent;
  start_e, end_e: TEventDateTime;
  D: System.TDate;
begin
if LBCalGoo.ItemIndex < 0 then Exit;
FormCalend.Edit1.Text:='';
FormCalend.Memo1.Clear;
FormCalend.DTP1.Date:=Date;
FormCalend.CheckBox1.Checked:=True;
if FormCalend.ShowModal<>mrOk then Exit;
start_e := TEventDateTime.Create();
end_e := TEventDateTime.Create();
D:=FormCalend.DTP1.Date;
if FormCalend.CheckBox1.Checked then begin
 start_e.datetime:=EncodeDateTime(YearOf(D), MonthOf(D), DayOf(D),0,0,0,0);
 end_e.datetime := start_e.datetime;
 end else begin
  start_e.dateTime := EncodeDateTime(YearOf(D), MonthOf(D), DayOf(D), FormCalend.SpinEdit1.Value, FormCalend.SpinEdit2.Value, 0, 0);
  end_e.dateTime := IncHour(start_e.dateTime, 1);
 end;
//start_e.timeZone := 'America/Sao_Paulo'; //Não funciona
//end_e.timeZone := 'America/Sao_Paulo';  //Não funciona
start_e.dateTime:=IncHour(start_e.dateTime, 3); //Nossa timezone
end_e.dateTime:=IncHour(end_e.dateTime, 3); //Nossa timezone

Entry := TEvent.Create();
Entry.summary := FormCalend.Edit1.Text;
Entry.description := FormCalend.Memo1.Text;
Entry.start := start_e;
Entry._end := end_e;
Insert := FCalendarAPI.EventsResource.Insert(FCurrentCalendar.id, Entry);
SaveRefreshToken('Cal');
Entry.Free;
Entry := nil;
Insert.Free;
Insert := nil;
LBCalGooSelectionChange(Self,False);
end;

procedure TForm1.DBGrid10DblClick(Sender: TObject);
begin
ColorSpeedButton45Click(Self);
end;

procedure TForm1.DBGrid1DblClick(Sender: TObject);
begin
  if QMarcCont.IsEmpty then
    ATButton62Click(Sender)
  else
    ATButton55Click(Sender);
end;

procedure TForm1.DBGrid4CellClick(Column: TColumn);
begin
  if Column.Index = 0 then
  begin
    QTarAF.Edit;
    QTarAF.FieldByName('Situacao').AsInteger := 2;
    QTarAF.FieldByName('Posicao').AsInteger := -1;
    QTarAF.Post;
    RefazerPosicoesTar(True, False);
    LerTar();
  end;
end;

procedure TForm1.DBGrid5CellClick(Column: TColumn);
begin
  if Column.Index = 0 then
  begin
    QTarFin.Edit;
    QTarFin.FieldByName('Situacao').AsInteger := 1;
    QTarFin.FieldByName('Posicao').AsInteger := -1;
    QTarFin.Post;
    RefazerPosicoesTar(False, True);
    LerTar();
  end;
end;

procedure TForm1.DBGrid6DblClick(Sender: TObject);
begin
  ColorSpeedButton58Click(Self);
end;

procedure TForm1.DBGrid6KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then ColorSpeedButton58Click(Self);
  if Key = VK_DOWN then
    if QLinks.RecNo = QLinks.RecordCount then
      ColorSpeedButton56Click(self);
end;

procedure TForm1.DBGrid7TitleClick(Column: TColumn);
var
  S: string;
begin
  S := QContAll.SQL.Text;
  if Pos('ASC', S) > 0 then
    LerContAll(' order by ' + Column.FieldName + ' COLLATE NOCASE DESC')
  else
    LerContAll(' order by ' + Column.FieldName + ' COLLATE NOCASE ASC');
end;

procedure TForm1.DBGrid8DragDrop(Sender, Source: TObject; X, Y: integer);
begin
  if QProj.IsEmpty then
  begin
    MessageDlg(rs_NoProjAberto, mtInformation, [mbOK], 0);
    Exit;
  end;
  if QContProj.Locate('Nome', QContAll.FieldByName('Nome').AsString, []) then
  begin
    MessageDlg(rs_ContExProj, mtInformation, [mbOK], 0);
    Exit;
  end;
  QTemp.Close;
  QTemp.SQL.Text := 'Insert into ProjContTBm (ContID,ProjID) Values (' +
    IntToStr(QContAll.Fields[0].AsInteger) + ',' + IntToStr(QProj.Fields[0].AsInteger) + ')';
  QTemp.ExecSQL;
  QContProj.Close;
  QContProj.Open;
  QContProj.Last;
end;

procedure TForm1.DBGrid8DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := Source = DBGrid7;
end;

procedure TForm1.DBGrid8TitleClick(Column: TColumn);
var
  S: string;
begin
  S := QContProj.SQL.Text;
  if Pos('ASC', S) > 0 then
    LerContProj(' order by ' + Column.FieldName + ' COLLATE NOCASE DESC')
  else
    LerContProj(' order by ' + Column.FieldName + ' COLLATE NOCASE ASC');
end;

procedure TForm1.DBGrid9TitleClick(Column: TColumn);
var
  S: string;
begin
  S := QMail.SQL.Text;
  if Pos('ASC', S) > 0 then
    LerEmail(' order by ' + Column.FieldName + ' COLLATE NOCASE DESC')
  else
    LerEmail(' order by ' + Column.FieldName + ' COLLATE NOCASE ASC');
end;

procedure TForm1.DCalClick(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  ;
  if DCal.Row = 0 then Abort; //Tem que ser Abort.
  DiaClick := DiasColRow[DCal.Row][DCal.Col];
  if IsValidDate(YearOf(DDate), MonthOf(DDate), DiaClick) then
    DDate := EncodeDate(YearOf(DDate), MonthOf(DDate), DiaClick)
  else
    Abort; //Tem que ser Abort.
  LerAgendaMes();
end;

procedure TForm1.DCalDblClick(Sender: TObject);
begin
ATButton99Click(Self);
end;

procedure TForm1.DCalDragDrop(Sender, Source: TObject; X, Y: integer);
//var
//  ColD, RowD: integer;
//  S: string;
begin
  //resolvi tirar, mas fica de exemplo difícil
{  DCal.MouseToCell(X, Y, ColD, RowD);
  DiaClick := DiasColRow[RowD][ColD];
  if IsValidDate(YearOf(DDate), MonthOf(DDate), DiaClick) then
    DDate := EncodeDate(YearOf(DDate), MonthOf(DDate), DiaClick)
  else
    Abort; //Tem que ser Abort?

  if Source = DBGrid4 then S := QTarAF.FieldByName('Tarefa').AsString;

  ATButton99Click(Self, S); //É só criar a nova propriedada quando precisar
}end;

procedure TForm1.DCalDragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := (Source = DBGrid4);
end;

procedure TForm1.DCalDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
var
  D: System.TDate;
  Ini, TopD, DiasNoMes: integer;
  i, R, C, j: integer;
  S: string;
begin

  //Primeiro pinta tudo de cinza.
  DCal.Canvas.Brush.Color := clBtnFace;
  DCal.Canvas.FillRect(aRect);

  DCal.Canvas.Font.Style := [fsBold];
  DCal.Canvas.Font.Size := 10;

  if ((aCol = 0) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_domingo);
  if ((aCol = 1) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Segunda);
  if ((aCol = 2) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Terca);
  if ((aCol = 3) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Quarta);
  if ((aCol = 4) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Quinta);
  if ((aCol = 5) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Sexta);
  if ((aCol = 6) and (aRow = 0)) then
    DCal.Canvas.TextOut(aRect.Left + (aRect.Width div 4), aRect.Top +
      (aRect.Height div 4), rs_Sabado);

  //Encontra o dia da semana do primeiro dia do mês
  D := EncodeDate(YearOf(DDate), MonthOf(DDate), 1);
  Ini := DayOfWeek(D);
  DiasNoMes := DaysInAMonth(YearOf(D), MonthOf(D));

  R := 1;
  C := Ini - 1;

  for i := 1 to DiasNoMes do
  begin
    if (aRow = R) and (aCol = C) then
    begin

      DCal.Canvas.Font.Size := 8;
      DiasColRow[R][C] := i;
      DCal.Canvas.Brush.Color := clWhite;
      if (i = DiaClick) then DCal.Canvas.Brush.Color := clGradientActiveCaption;
      DCal.Canvas.FillRect(aRect);

      DCal.Canvas.Font.Size := 9;
      D := EncodeDate(YearOf(DDate), MonthOf(DDate), i);
      Ini := DayOfWeek(D);
      DCal.Canvas.Font.Style := [fsBold];
      if (Ini = 1) or (Ini = 7) then //sábado ou domingo
        DCal.Canvas.Font.Color := clRed
      else
        DCal.Canvas.Font.Color := clBlack;
      DCal.Canvas.TextOut(aRect.Left, aRect.Top, IntToStr(i));

      DCal.Canvas.Font.Size := 8;
      //3D para o dia atual
      if (i = DayOf(Date)) and (MonthOf(DDate) = MonthOf(Date)) and (YearOf(DDate) = YearOf(Date))
      then DCal.Canvas.Frame3D(aRect, clDefault, clDefault, 1);

      TopD := 23;
      //Lendo a seleção de eventos do Mês
      for j := 0 to HoldSelect.Strings.Count - 1 do
      begin
        DCal.Canvas.Font.Style := [fsItalic];
        DCal.Canvas.Brush.Color := clMoneyGreen;
        S := HoldSelect.Strings[j];
        if i = StrToInt(Copy(S, 7, 2)) then
        begin //Pegando o dia
          if j > 0 then
            if Copy(HoldSelect.Strings[j], 1, 8) = Copy(HoldSelect.Strings[j - 1], 1, 8) then
              TopD := TopD + 21;
          DCal.Canvas.Rectangle(aRect.Left, aRect.Top + TopD - 1, aRect.Left + 200, aRect.Top + TopD + 23);
          if Copy(S, Pos('T', S) + 1, 4) = '0000' then
            DCal.Canvas.TextOut(aRect.Left, aRect.Top + TopD, Copy(S, Pos(' ', S), Length(S)))
          else
            DCal.Canvas.TextOut(aRect.Left, aRect.Top + TopD, Copy(S, Pos('T', S) + 1, 2) +
              ':' + Copy(S, Pos('T', S) + 3, 2) + ' ' + Copy(S, Pos(' ', S), Length(S)));
        end;
      end;
    end;
    Inc(C);
    if C = 7 then
    begin
      C := 0;
      Inc(R);
    end;
  end;

end;

procedure TForm1.DE6AcceptDirectory(Sender: TObject; var Value: string);
begin
  SalvarRegistro('PastaModels',Value);
//  ConfigSalvarStr(CFGTB, 'PastaModels', Value);
  PastaModels := Value;
end;

procedure TForm1.DE7AcceptDirectory(Sender: TObject; var Value: string);
begin
  SalvarRegistro('PastaDown',Value);
//  ConfigSalvarStr(CFGTB, 'PastaDown', Value);
  PastaDown := Value;
  STV1.Root := PastaDown;
end;

procedure TForm1.DE8AcceptDirectory(Sender: TObject; var Value: string);
begin
  SalvarRegistro('PastaDrop',Value);
  //  ConfigSalvarStr(CFGTB, 'PastaDrop', Value);
  PastaDrop := Value;

  //LerNotasCelArq();
end;

procedure TForm1.DE9AcceptDirectory(Sender: TObject; var Value: string);
begin
SalvarRegistro('PastaProj', Value);
PastaProj:=Value;
{  ConfigSalvarStr('CfgWinTB', 'PastaProj', Value);
{$IFDEF WINDOWS}
 PastaProj:=Value;
 AbrirProj();
{$ENDIF}
}end;

procedure TForm1.DSContAllDataChange(Sender: TObject; Field: TField);
begin
  LerMarcsCont();
end;

procedure TForm1.DSContProjDataChange(Sender: TObject; Field: TField);
begin
  //Melhor tirar?
  QContAll.Locate('Nome', QContProj.FieldByName('Nome').AsString, []);
end;

procedure TForm1.DSMailDataChange(Sender: TObject; Field: TField);
var
  btn: TSpeedButton;
  i: integer;
begin
  QMailAnx.Close;
  QMailAnx.SQL.Text := 'Select * from MailsAnxTB where MailID=' + IntToStr(
    QMail.Fields[0].AsInteger);
  QMailAnx.Open;

  for i := 0 to SB1.ControlCount - 1 do SB1.Controls[0].Free;

  while not QMailAnx.EOF do
  begin
    btn := TSpeedButton.Create(nil);
    btn.Parent := SB1;
    btn.Align := alTop;
    btn.Flat := True;
    btn.Margin := 0;
    btn.Height := 40;
    btn.Width := 287;
    btn.Images := Img3;
    btn.ImageIndex := 16;
    btn.Caption :={Isso vem do FileCtrl}MinimizeName(
      ExtractFileName(QMailAnx.FieldByName('Anexo').AsString), btn.Canvas, btn.Width);
    btn.Hint := ExtractFileName(QMailAnx.FieldByName('Anexo').AsString);
    //btn.Show := True; //Parou de funcionar, mas não precisa.
    btn.OnClick := @btnClickEvent;
    QMailAnx.Next;
  end;

  QMailPess.Close;
  QMailPess.SQL.Text := 'Select * from MailsPessTB where MailID=' + IntToStr(
    QMail.Fields[0].AsInteger) + ' order by NomeEmail COLLATE NOCASE';
  QMailPess.Open;

  CLB3.Clear;
  while not QMailPess.EOF do
  begin
    CLB3.Items.Add(QMailPess.FieldByName('NomeEmail').AsString);
    QMailPess.Next;
  end;
  if CLB3.Count > 0 then CLB3.ItemIndex := 0;
end;

procedure TForm1.DSRascuDataChange(Sender: TObject; Field: TField);
begin
  AtlzRegRascu();
end;

procedure TForm1.DSRascuStateChange(Sender: TObject);
begin
  DBEdit1.Font.Italic := (DSRascu.State = dsInsert) or (DSRascu.State = dsEdit);
  ListBox1.Font.Italic := DBEdit1.Font.Italic;
  DBMemo2.Font.Italic := DBEdit1.Font.Italic;
  ListBox2.Font.Italic := DBEdit1.Font.Italic;
  if QRascu.State = dsEdit then Label34.Caption := rs_editing;
  if QRascu.State = dsInsert then Label34.Caption := rs_inserting;
  if QRascu.State = dsBrowse then Label34.Caption := '';
end;

procedure TForm1.EdBuscaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then ColorSpeedButton40Click(Self);
end;

procedure TForm1.DE10AcceptDirectory(Sender: TObject; var Value: string);
begin
{ConfigSalvarStr('CfgLnxTB', 'PastaProj', Value);
{$IFDEF LINUX}
 PastaProj:=Value;
 AbrirProj();
{$ENDIF}
}end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
if Edit1.Text = '' then begin
  QProj.Close;
  QProj.SQL.Text := 'Select * from ProjsTB where ProjsTB.Situacao=1 order by ProjsTB.Posicao';
  QProj.Open;
  PopTV();
  AbrirProj();
end else begin
  QProj.Close;
  QProj.SQL.Text :=
    'Select * from ProjsTB where (ProjsTB.Situacao=1) and (ProjsTB.ProjName like "%' +
    Edit1.Text + '%") order by ProjsTB.ProjName COLLATE NOCASE';
  QProj.Open;
  PopTV();
  AbrirProj();
end;
end;

procedure TForm1.Edit4Change(Sender: TObject);
begin
  DBGrid7TitleClick(DBGrid7.Columns[0]);
end;

procedure TForm1.Edit5Change(Sender: TObject);
begin
  DBGrid8TitleClick(DBGrid8.Columns[0]);
end;

procedure TForm1.Edit8Change(Sender: TObject);
begin
  DBGrid9TitleClick(DBGrid9.Columns[1]);
end;

procedure TForm1.FLV1ButtonClick(Sender: TObject);
begin
  ATButton34Click(Sender);
end;

procedure TForm1.FLV1KeyPress(Sender: TObject; var Key: char);
begin
  ATButton34Click(Sender);
end;

procedure TForm1.FLV2ButtonClick(Sender: TObject);
begin
  CheckPastaLxWn();
  Ler_ArqProj();
end;

procedure TForm1.FLV2KeyPress(Sender: TObject; var Key: char);
begin
  CheckPastaLxWn();
  Ler_ArqProj();
end;

procedure TForm1.FLV3ButtonClick(Sender: TObject);
begin
  Ler_Audios();
end;

procedure TForm1.FLV3KeyPress(Sender: TObject; var Key: char);
begin
  Ler_Audios();
end;

procedure TForm1.FLV4ButtonClick(Sender: TObject);
begin
  CheckPastaLxWn();
  Ler_ArqProj();
end;

procedure TForm1.FLV4KeyPress(Sender: TObject; var Key: char);
begin
  CheckPastaLxWn();
  Ler_ArqProj();
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
if MudouMemos then begin
  ColorSpeedButton55Click(Self);
  ATButton8Click(Self);
end;
if Label36.Caption = rs_Working then
  if MessageDlg('Pomodoro ativo. Fechar mesmo assim?', mtConfirmation,
    [mbYes, mbNo], 0) = mrNo then
     CloseAction:=Forms.caNone;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  d, a, ah, i: integer;
  VersionWinStore: boolean;
begin
  {$IFDEF UNIX}  // Linux
 {$IFNDEF DARWIN}
  //SQLiteDefaultLibrary := 'libsqlite3.so'; //Não funciona no Linux
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

  //Necessário para drag&drop nos ShellTreeView STV2
  with TShellTreeViewOpener(STV2) do
  begin
    OnDragDrop := @STV2DragDrop;
    OnDragOver := @STV2DragOver;
  end;

  Conn.DatabaseName := fConnName;

  FirstUse := False;
  if not fileexists(Conn.DatabaseName) then
  begin
    FirstUse := True;
    Trans.StartTransaction;
    Conn.Open;
    Conn.ExecuteDirect(
      'CREATE TABLE ProjsTB ' +
      '(ID_Proj Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Posicao integer, ' + 'ProjName VarChar(100), ' + 'ProjInfo Text, ' +
      'ProjDate Datetime, ' + 'Icons integer, ' + 'PastaLx VarChar(200), ' +
      'PastaWd VarChar(200), ' + 'PastaMc VarChar(200), ' + 'Situacao integer, ' +
      'ExtraInt integer, ' + 'ExtraStr VarChar(100) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE TarefasTB ' +
      '(ID_Tarefa Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID integer, ' + 'Tarefa VarChar(140), ' + 'Situacao integer, ' +
      //0: a fazer; 1: finalizadas
      'Posicao integer, ' +
      'DataCriacao Datetime, ' + 'Prazo Datetime, ' + 'DataFinaliza Datetime ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE LinksTB ' +
      '(ID_Link Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID integer, ' + 'Link VarChar(240), ' + 'Descricao VarChar(140) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE NotasTB ' +
      '(ID_Nota Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID Integer, ' + 'Nota1 Text, ' + 'Nota2 Text, '+'Nota3 Text, '+'Nota4 Text'+'  ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE ContatosTB ' +
      '(ID_Contato Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Nome VarChar(80), ' + 'Email VarChar(80), ' + 'Celular VarChar(15), '+'Obs VarChar(400)  '+ '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE MarcsContTB ' +
      '(ID_Marc Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Marcador VarChar(60) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE ContMarcTBm ' +
      '(ID_ContMarc Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'MarcID Integer, ' + 'ContID Integer, ' +
      '	FOREIGN KEY (ContID) REFERENCES ContatosTB(ID_Contato), ' +
      '	FOREIGN KEY (MarcID) REFERENCES MarcsContTB(ID_Marc) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE MarcsProjTB ' +
      '(ID_Marc Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Marcador VarChar(60) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE ProjMarcTBm ' +
      '(ID_ProjMarc Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'MarcID Integer, ' + 'ProjID Integer, ' +
      '	FOREIGN KEY (ProjID) REFERENCES ProjsTB(ID_Proj), ' +
      '	FOREIGN KEY (MarcID) REFERENCES MarcsProjTB(ID_Marc) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE ProjContTBm ' +
      '(ID_ProjCont Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ContID Integer, ' + 'ProjID Integer, ' +
      '	FOREIGN KEY (ProjID) REFERENCES ProjsTB(ID_Proj), ' +
      '	FOREIGN KEY (ContID) REFERENCES ContatosTB(ID_Contato) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE ConfigTB ' +
      '(ID_Config Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'UserEmail VarChar(60), ' + 'UserPassw VarChar(60), ' + 'Magic VarChar(50), ' +
      'Idioma VarChar(5), ' +'LastButton integer, '+'PageControl2Idx integer, ' + 'PageControl3Idx integer, ' +
      'PageControl4Idx integer, ' + 'MostrarPomodoro integer, ' + // 0 e 1
      'MostrarAudios integer, ' + // 0 e 1
      'MostrarTarCel integer, ' + // 0 e 1
      'MostrarInspCell integer, ' + // 0 e 1
      'MostrarRitos integer, ' + // 0 e 1
      'RitosIntensid integer, ' + // 3 a 21
      'MsgPersiste integer, ' + // 0 e 1
      'Panel7Wd integer, ' + // Cada coluna uma posição de janela: Documentar aqui.
      'Panel8Ht integer, ' + 'Panel2Wd integer, ' + 'PageControl3Ht integer, ' +
      'DBGrid3Ht integer, ' + 'CLB1Count integer, ' + 'ExtraInt integer, ' +
      'ExtraStr VarChar(100), ' +'ClientId VarChar(300), '+'ClientSecret VarChar(300), '+
      'accessTokenCal VarChar(300), '+'refreshTokenCal VarChar(300), '+
      'accessTokenTasks VarChar(300), '+'refreshTokenTasks VarChar(300), '+
      'accessTokenPeop VarChar(300), '+'refreshTokenPeop VarChar(300), '+
      'accessTokenGmail VarChar(300), '+'refreshTokenGmail VarChar(300), '+
      'accessTokenDrive VarChar(300), '+'refreshTokenDrive VarChar(300) '+' ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE CfgLnxTB ' +
      '(ID_Config Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'PastaModels VarChar(160), ' + 'PastaDown VarChar(160), ' +
      'PastaDrop VarChar(160), ' + 'ExtraInt integer, ' +
      'ExtraStr VarChar(100) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE CfgWinTB ' +
      '(ID_Config Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'PastaModels VarChar(160), ' + 'PastaDown VarChar(160), ' +
      'PastaDrop VarChar(160), ' + 'ExtraInt integer, ' +
      'ExtraStr VarChar(100) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE CfgMacTB ' +
      '(ID_Config Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'PastaModels VarChar(160), ' + 'PastaDown VarChar(160), ' +
      'PastaDrop VarChar(160), ' + 'ExtraInt integer, ' + 'ExtraStr VarChar(100) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE MailsTB ' +
      '(ID_Mail Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID integer, ' + 'ER VarChar(1), ' + 'DePara VarChar(80), ' +
      'Assunto VarChar(250), ' + 'Data DateTime, ' + 'Msg Text ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE MailsAnxTB ' +
      '(ID_MailAnx Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'MailID integer, ' + 'Anexo VarChar(180) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE MailsPessTB ' +
      '(ID_MailPess Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'MailID integer, ' + 'NomeEmail VarChar(100) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE RascuTB ' +
      '(ID_Rascu Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Assunto VarChar(250), ' + 'Msg Text ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE RascuContTB ' +
      '(ID_RascuCont Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'RascuID integer, ' + 'Nome VarChar(100), ' + 'Email VarChar(100), ' +
      'FOREIGN KEY (RascuID) REFERENCES RascuTB(ID_Rascu) ON DELETE CASCADE' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE RascuAnxTB ' +
      '(ID_RascuAnx Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'RascuID integer, ' + 'Anexo VarChar(200), ' +
      'FOREIGN KEY (RascuID) REFERENCES RascuTB(ID_Rascu) ON DELETE CASCADE' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE AgendaTB ' +
      '(ID_Agenda Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID integer, ' + 'Evento VarChar(200), ' + 'Data DateTime ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE BuscaTB ' +
      '(ID_Busca Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Projeto VarChar(200), ' + 'Onde VarChar(25), ' + 'Ref VarChar(300) ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE TimeLineTB ' +
      '(ID_TL Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'ProjID integer, ' + 'Dia Date, ' + 'Tempo Integer ' + '	 ); ');
    Conn.ExecuteDirect(
      'CREATE TABLE RitosTB ' +
      '(ID_Rito Integer PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL, ' +
      'Data Date, ' + 'Rep integer, ' + 'Noite Integer ' + '	 ); ');
    Trans.Commit;
  end;

  TGmailAPI.RegisterAPIResources;
  TPeopleAPI.RegisterAPIResources; //Tem que ficar antes dos outros dois, sabe-se lá porquê.
  TCalendarAPI.RegisterAPIResources;
  TTasksAPI.RegisterAPIResources;
  TDriveAPI.RegisterAPIResources;
  FClientGmail:=TGoogleClient.Create(Self);
  FClientCal:= TGoogleClient.Create(Self); // <- Uma só vez não rola.
  FClientTasks := TGoogleClient.Create(Self);
  FClientPeop := TGoogleClient.Create(Self);
  FClientDrive := TGoogleClient.Create(Self);
  FClientGmail.WebClient:=TFPHTTPWebClient.Create(Self);
  FClientCal.WebClient := TFPHTTPWebClient.Create(Self);
  FClientTasks.WebClient := TFPHTTPWebClient.Create(Self);
  FClientPeop.WebClient := TFPHTTPWebClient.Create(Self);
  FClientDrive.WebClient := TFPHTTPWebClient.Create(Self);
  FClientGmail.WebClient.RequestSigner:=FClientGmail.AuthHandler;
  FClientCal.WebClient.RequestSigner := FClientCal.AuthHandler;
  FClientTasks.WebClient.RequestSigner := FClientTasks.AuthHandler;
  FClientPeop.WebClient.RequestSigner := FClientPeop.AuthHandler;
  FClientDrive.WebClient.RequestSigner := FClientDrive.AuthHandler;
//  FClientGmail.WebClient.LogFile:='requestsGmail.log';
//  FClientCal.WebClient.LogFile := 'requestsCal.log';
//  FClientTasks.WebClient.LogFile := 'requestsTasks.log';
//  FClientPeop.WebClient.LogFile := 'requestsPeop.log';
//  FClientDrive.WebClient.LogFile := 'requestsDrive.log';
  FClientGmail.AuthHandler.WebClient:=FClientGmail.WebClient;
  FClientCal.AuthHandler.WebClient := FClientCal.WebClient;
  FClientTasks.AuthHandler.WebClient := FClientTasks.WebClient;
  FClientPeop.AuthHandler.WebClient := FClientPeop.WebClient;
  FClientDrive.AuthHandler.WebClient := FClientDrive.WebClient;
  FClientGmail.AuthHandler.Config.AccessType:=atOffLine;
  FClientCal.AuthHandler.Config.AccessType := atOffLine;
  FClientTasks.AuthHandler.Config.AccessType := atOffLine;
  FClientPeop.AuthHandler.Config.AccessType := atOffLine;
  FClientDrive.AuthHandler.Config.AccessType := atOffLine;
  FClientGmail.OnUserConsent:=@DoUserConsentGmail;
  FClientCal.OnUserConsent := @DoUserConsentCal;
  FClientTasks.OnUserConsent := @DoUserConsentTasks;
  FClientPeop.OnUserConsent := @DoUserConsentPeop;
  FClientDrive.OnUserConsent := @DoUserConsentDrive;

  FGmailAPI:=TGmailAPI.Create(Self);
  FGmailAPI.GoogleClient:=FClientGmail;
  LoadAuthConfig('Gmail');

  FCalendarAPI := TCalendarAPI.Create(Self);
  FCalendarAPI.GoogleClient := FClientCal;
  LoadAuthConfig('Cal');

  FTasksAPI := TTasksAPI.Create(Self);
  FTasksAPI.GoogleClient := FClientTasks;
  LoadAuthConfig('Tasks');

  FPeopleAPI := TPeopleAPI.Create(Self);
  FPeopleAPI.GoogleClient := FClientPeop;
  LoadAuthConfig('Peop');

  FDriveAPI := TDriveAPI.Create(Self);
  FDriveAPI.GoogleClient := FClientDrive;
  LoadAuthConfig('Drive');


  Panel124.Align := alClient;//Contatos dos novos emails
  Panel123.Align := alClient;//Contatos dos novos emails

  ClientId := ConfigLerStr('ConfigTB', 'ClientId');
  ClientSecret := ConfigLerStr('ConfigTB', 'ClientSecret');
  accessTokenGmail := ConfigLerStr('ConfigTB', 'accessTokenGmail');

//  UserEmail := ConfigLerStr('ConfigTB', 'UserEmail');
//  UserPassw := descriptografar(PSWKEY, ConfigLerStr('ConfigTB', 'UserPassw'));
  Magic := descriptografar(PSWKEY, ConfigLerStr('ConfigTB', 'Magic'));

  AvisoCnt := 0; //Sobrou das notas. Precisa?

//  PopTVx(); Passei ali para baixo, pois no Linux não funciona aqui.

  STV1.Root := GetUserdir;
  if STV1.Items.Count > 0 then STV1.Items[0].Selected := True;

  STV2.Root := STV1.Root; //Só pra garantir. Vai preencher de novo em AbrirProj()
  if STV2.Items.Count > 0 then STV2.Items[0].Selected := True;
  STV2.Visible := False; //Vai ficar visible lá no AbrirProj
  LV2.Visible := False;

  //Zerando pra garantir timeline
{DBGrid2.DataSource:=nil;
DBGrid2.Visible:=False;
Panel95.Align:=alClient;
}

  PopTVx();

  Caption := rs_FORM1CAPTION;

  //Se teve problema antes, reconstroi as posicoes (começando com Posicao=2).
  QProj.Close;
  QProj.SQL.Text := 'Select * from ProjsTB where Situacao=2 order by Posicao';
  QProj.Open;
  RefazerPosicaoProj();
  //Abre a Posicao=1 e fica aberta
  QProj.Close;
  QProj.SQL.Text := 'Select * from ProjsTB where Situacao=1 order by Posicao';
  QProj.Open;
  RefazerPosicaoProj();

  //Todos os contatos (Não muda com a mudança do Projeto e fica aqui no Create, não no AbrirProj)
  LerContAll(' order by Nome COLLATE NOCASE ASC');

  LerRascu();

  //Inicializar agenda. Parte visual entá em TimerCreate
  DDate := Date;
  DiaClick := DayOf(DDate);

  //Tem que ficar no final
  if QProj.IsEmpty then Exit
  else
    PopTV(); //Cuidado com esse EXIT
  if TV.Items.Count > 0 then
  begin
    TV.Selected := TV.Items[0];

//    DE9.Text := ConfigLerStr('CfgWinTB', 'PastaProj');
//    DE10.Text := ConfigLerStr('CfgLnxTB', 'PastaProj');

{{$IFDEF WINDOWS}
PastaProj:=DE9.Text;
{$ENDIF}
{$IFDEF LINUX}
PastaProj:=DE10.Text;
{$ENDIF}
}


PastaProj:=LerRegistro('PastaProj');

    NB1.PageIndex := ConfigLerInt('ConfigTB', 'LastButton');
    if NB1.PageIndex = 0 then ColorSpeedButton4.Down := True;
    if NB1.PageIndex = 1 then ColorSpeedButton11.Down := True;
    if NB1.PageIndex = 3 then ColorSpeedButton10.Down := True;
    if NB1.PageIndex = 2 then ColorSpeedButton8.Down := True;
    if NB1.PageIndex = 4 then ColorSpeedButton13.Down := True;
    if NB1.PageIndex = 5 then ColorSpeedButton12.Down := True;
    if NB1.PageIndex = 7 then ColorSpeedButton9.Down := True;
    if NB1.PageIndex = 6 then ColorSpeedButton7.Down := True;
  end;

  AbrirProj();

  TL.Enabled := True; //Definitivamente tem que ser aqui

end;

procedure TForm1.FormDestroy(Sender: TObject);
var i: integer;
begin
  History1.Free;
  History2.Free;
  History3.Free;
  History4.Free;
  HistoryP.Free;
  HistoryNM.Free;
  HistoryMail.Free;
  for i:=0 to MemoTmpAudio.Lines.Count-1 do
   DeleteFile(MemoTmpAudio.Lines[i]);
  //Limpando emails temporários
  if QProj.Locate('ProjName', 'Temp', []) then begin
   QTemp.SQL.Text:='delete from MailsTB where ProjID='+IntToStr(QProj.Fields[0].AsInteger);
   QTemp.ExecSQL;
  end;
end;

procedure TForm1.LBPeopGooSelectionChange(Sender: TObject; User: boolean);
begin
//
end;

procedure TForm1.LBTarGooSelectionChange(Sender: TObject; User: boolean);
var
 Entry: TTask;
 SeqDB,i,n: integer;
 idTask,T,Nt,S: String;
 Mem: TMemo;
begin
Screen.Cursor:=crHourGlass;
FCurrentList:=LBTarGoo.Items.Objects[LBTarGoo.ItemIndex] as TTaskList;
FreeAndNil(FTasks);
FTasks:=FTasksAPI.TasksResource.list(FCurrentList.id,'');

SaveRefreshToken('tasks');

n:=Length(FTasks.items); //Essa é a chave de tudo.
//isso aqui tudo para fazer colocar as tarefas na posição original (Entry.Position)
QTemp.Close;
QTemp.SQL.Text:='Delete from AuxTarGoo';
QTemp.ExecSQL;
for i:=0 to n-1 do begin               //Isso aqui abaixo para reduzir a string de origem 000000000000023 para 23.
 QTemp.Close;
 QTemp.SQL.Text:='insert into AuxTarGoo (seqDB,idTask,posTask) values ('+IntToStr(i)+',"'+FTasks.items[i].id+'",'+IntToStr(StrToInt(FTasks.items[i].Position))+')';
 QTemp.ExecSQL;
end;
QTemp.Close;
QTemp.SQL.Text:='select seqDB,idTask,posTask from AuxTarGoo order by posTask desc';
QTemp.Open;
S:='';
for i:=0 to SBTar.ControlCount-1 do SBTar.Controls[0].Free;
SeqDB:=0;
if assigned(FTasks) then
 while not QTemp.EOF do begin
  S:='';
  idTask:=QTemp.FieldByName('idTask').AsString;
  SeqDB:=QTemp.FieldByName('seqDB').AsInteger;
  Entry:=FTasks.items[SeqDB];
  T:=Entry.Title;
  Nt:=Entry.Notes;
  if T<>'' then S:=S+T+#13;
  if Nt<>'' then S:=S+Nt+#13+#13 else S:=S+#13;

  Mem:=nil;
  if s<>'' then begin
   Mem := TMemo.Create(self); //Ou SBTar?
   Mem.Parent := SBTar;
   Mem.Name:='MemoTarGoo'+IntToStr(SeqDB);
   Mem.Hint:=idTask;  //Guardando id do Task
   Mem.Tag:=SeqDB;
   Mem.Align:=alTop;
   Mem.Height := 130;
   Mem.Font.Size:=11;

   Mem.OnKeyPress:=@MemTarKeyPress; //Itálico
   Mem.OnEnter:=@MemTarOnEnter; //Muda a cor
   Mem.OnExit:=@MemTarOnExit; //Volta a cor original

   Mem.Lines.Text:=S; //Tem que ser .Text. Não pode ser .add senão os parágafos não saem.
  end;
  if Assigned(Mem) then Mem.SetFocus;;
  Inc(SeqDB);
  QTemp.Next;
 end;

if S<>'' then ColorSpeedButton82.Enabled:=True;
Screen.Cursor:=crDefault;
end;

procedure TForm1.ListBox1DragDrop(Sender, Source: TObject; X, Y: integer);
begin
//  ShowMessage(DBGrid11.DataSource.DataSet.FieldByName('Email').AsString);
if Source=DBGrid11 then
   ListBox1.Items.Append(DBGrid11.DataSource.DataSet.FieldByName(
     'Nome').AsString + '<' + DBGrid11.DataSource.DataSet.FieldByName('Email').AsString + '>');
  if Source=LVPeopGoo then
   ListBox1.Items.Append(LVPeopGoo.Selected.Caption+'<'+LVPeopGoo.Selected.SubItems[0]+'>');

  if QRascu.IsEmpty then QRascu.Insert
   else QRascu.Edit;
  DBEdit1.SetFocus;
end;

procedure TForm1.ListBox1DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := (Source = DBGrid11) or (Source = LVPeopGoo);
end;

procedure TForm1.ListBox1SelectionChange(Sender: TObject; User: boolean);
//var
//  S, Nome, Email: string;
begin
{  S := ListBox1.Items[ListBox1.ItemIndex];
  Nome := Copy(S, 1, Pos('<', S) - 1);
  Email := Copy(S, Pos('<', S) + 1, Pos('>', S) - Pos('<', S) - 1);
  if not QRascuCont.Active then QRascuCont.Open;
  if QRascuCont.Locate('Nome;Email', VarArrayOf([Nome, Email]), []) then;
}end;

procedure TForm1.ListBox1xClick(Sender: TObject);
begin
  Ler_Tl();
end;

procedure TForm1.ListBox2DragDrop(Sender, Source: TObject; X, Y: integer);
begin
    ListBox2.Items.Append(STV3.Path + LV3.Selected.Caption);
  if QRascu.IsEmpty then QRascu.Insert
  else
    QRascu.Edit;
  DBEdit1.SetFocus;
end;

procedure TForm1.ListBox2DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := Source = LV3;
end;

procedure TForm1.ListViewFilterEdit1Change(Sender: TObject);
begin
  ListViewFilterEdit1.FilteredListview := LVPeopGoo;
end;

procedure TForm1.ListViewFilterEdit2Change(Sender: TObject);
begin
  ListViewFilterEdit2.FilteredListview := LVMessages;
end;

procedure TForm1.LV1DblClick(Sender: TObject);
var
  PathS: string;
begin
  PathS := STV1.Path + PathDelim + LV1.ItemFocused.Caption;
  OpenDocument(PathS);
end;

procedure TForm1.LV1DragDrop(Sender, Source: TObject; X, Y: integer);
begin                                         //Ver comentários em SLV2DragDrop
  if Source = LV2 then
  begin
    CopyFile(STV2.Path + LV2.ItemFocused.Caption, STV1.Path + PathDelim + LV2.ItemFocused.Caption);
    ATButton34Click(Self);
  end;
end;

procedure TForm1.LV1DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := False;
  if Source = LV2 then Accept := True;
end;

procedure TForm1.LV2DblClick(Sender: TObject);
begin
  LV2Abrir;
end;

procedure TForm1.LV2DragDrop(Sender, Source: TObject; X, Y: integer);
Var
  Entry: TFile;
  Request: TWebClientRequest;
  ResponseF: TWebClientResponse;
  S,URL,LFN: String;
  D: TJSONEnum;
begin
if Source=LVFiles then
  begin
    Screen.Cursor:=crHourGlass;
    If not (Assigned(LVFiles.Selected) and Assigned(LVFiles.Selected.Data)) then Exit;
    Entry:=TFile(LVFiles.Selected.Data);
    URL:=TDriveAPI.APIBaseURL+'files/'+Entry.ID+'?alt=media';

    ResponseF:=Nil;
    Request:=FClientDrive.WebClient.CreateRequest;

    try
      ResponseF:=FClientDrive.WebClient.ExecuteSignedRequest('GET',URL,Request);
      With TFileStream.Create(STV2.Path+PathDelim+Entry.name,fmCreate) do
        try
          CopyFrom(ResponseF.Content,0);
        finally
          Free;
        end;
    finally
      ResponseF.Free;
      Request.Free;
    end;
    ATButton36Click(Self);
    Screen.Cursor:=crDefault;
  end;

if Source=LV1 then
  begin
    CheckPastaLxWn();
    if Source = LV1 then
    begin
      CopyFile(STV1.Path + PathDelim + LV1.ItemFocused.Caption, STV2.Path + LV1.ItemFocused.Caption);
      Ler_ArqProj();
    end;
  end;

end;

procedure TForm1.LV2DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := False;
  if (Source = LV1) or (Source = LVFiles) then Accept := True; //Não funciona mais em 03/2022
end;

procedure TForm1.LV2KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    LV2.Repaint;
    MenuItem12Click(Self);
  end;
  if Key = VK_RETURN then LV2Abrir;
  if Key = VK_F5 then Ler_ArqProj();
  if (key = VK_F2) and (LV2.Focused) then
  begin //Se não botar LV2.Focused executa 2x.
    MenuItem13Click(Sender);
    Abort;
  end;
end;

procedure TForm1.LVAudioDblClick(Sender: TObject);
begin
  ColorSpeedButton43Click(Self);
end;

procedure TForm1.LVMessagesClick(Sender: TObject);
begin
//Só funciona aqui no onClick no Windows. Não adianta colocar lá no onChange ou onSelectItem
Memo5.Text:=LVMessages.Selected.SubItems[4];
end;

procedure TForm1.LVMessagesDblClick(Sender: TObject);
var
  Entry: Tmessage;
  Resource : TUsersMessagesResource;
begin
Edit1.Text:='';
if QProj.Locate('ProjName','Temp',[])= False then
begin
 MessageDlg('É necessário um projeto chamado "Temp" para baixar o email.',mtInformation,[mbOk],0);
 Exit;
end;
Screen.Cursor:=crHourGlass;
ColorSpeedButton13Click(Self);
ColorSpeedButton13.Down:=True;
Edit1.Text:='Temp';
Resource:=Nil;
try
  Resource:=FGmailAPI.CreateusersMessagesResource(Self);
  Entry:=Resource.Get(LVMessages.Selected.SubItems[3],'me','format=raw');
  HoldEML.Strings.Text:=Entry.Raw;
  ColorSpeedButton13.Pressed:=True;
  AbrirEmailEML(HoldEML,True); //Não precisa AbrirProj nem LerEmail
  QMail.Close;
  QMail.Open;
  QMail.Locate('ID_Mail',VarArrayOf([LastTempMail]),[]);

finally
  Resource.Free;
end;
Screen.Cursor:=crDefault;
end;

procedure TForm1.LVMessagesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if ((Button = mbLeft) and not (ssDouble in Shift)) then //DragMode não pode ser dmAutomatic se não dá problema no DlbClick
     begin
       LVMessages.BeginDrag(False, 5);
     end;
end;

procedure TForm1.Memo1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(Memo1, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(Memo1, LastSearch, 0);
end;

procedure TForm1.Memo1KeyPress(Sender: TObject; var Key: char);
begin
  if Key='"' then Key:=''''; //Aspas duplas dá erro no Banco de dados
  MudouMemos := True;
end;

procedure TForm1.Memo2KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(Memo2, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(Memo2, LastSearch, 0);
end;

procedure TForm1.Memo2KeyPress(Sender: TObject; var Key: char);
begin
  if Key='"' then Key:='''';
  MudouMemos := True;
end;

procedure TForm1.Memo3KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(Memo3, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(Memo3, LastSearch, 0);
end;

procedure TForm1.Memo3KeyPress(Sender: TObject; var Key: char);
begin
  if Key='"' then Key:='''';
  MudouMemos := True;
end;

procedure TForm1.Memo4KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(Memo4, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(Memo4, LastSearch, 0);
end;

procedure TForm1.Memo4KeyPress(Sender: TObject; var Key: char);
begin
  if Key='"' then Key:='''';
  MudouMemos := True;
end;

procedure TForm1.MemoPjKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    if not InputQuery('Procurar', 'Procurando', LastSearch) then Exit;
    MyFindInMemo(MemoPj, LastSearch, 0);
  end;
  if Key = VK_F3 then MyFindInMemo(MemoPj, LastSearch, 0);
end;

procedure TForm1.MemoPjKeyPress(Sender: TObject; var Key: char);
begin
  MudouMemos := True;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  //LV2Abrir;
  if LV2.ItemFocused <> nil then
    //Assim é possivel abrir txt,py,etc no programa padrão do SO, e não no meu viewer
    OpenDocument(STV2.Path + LV2.ItemFocused.Caption);
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
var
  S: string;
begin
  CheckPastaLxWn();
  if LV2.ItemFocused = nil then
    if LV2.Items.Count > 0 then
      LV2.ItemFocused := LV2.Items[0]
    else
      Exit;
  if MessageDlg(rs_DelFile + LV2.ItemFocused.Caption + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    S := STV2.Path + LV2.ItemFocused.Caption;
    if not FileExistsUTF8(S) then Exit;
    DeleteFile(S);
    Ler_ArqProj();
  end;
end;

procedure TForm1.MenuItem13Click(Sender: TObject);
var
  S, PathOld, PathNew: string;
  i: integer;
begin
  CheckPastaLxWn();
  S := ExtractFileName(STV2.Path + LV2.ItemFocused.Caption);
  i := LV2.ItemIndex;
  if InputQuery(rs_Rename, rs_NovoNome, S) then
  begin
    PathOld := STV2.Path + LV2.ItemFocused.Caption;
    PathNew := ExtractFilePath(PathOld) + S;
    RenameFile(PathOld, PathNew);
    ATButton36Click(Self);
    Sleep(1);
    LV2.ItemIndex := i;
  end;
end;

procedure TForm1.MenuItem16Click(Sender: TObject);
var
  i: integer;
begin
  CheckPastaLxWn();
  try
    if PastaModels = '' then
    begin
      MessageDlg(rs_PastaModelos, mtInformation, [mbOK], 0);
      Exit;
    end;
    FormModelos := TFormModelos.Create(Self);
    HoldTemp.Strings := FindAllFiles(PastaModels, '', False);
    for i := 0 to HoldTemp.Strings.Count - 1 do
    begin
      FormModelos.CheckListBox1.Items.Add(ExtractFileName(HoldTemp.Strings[i]));
    end;
    if FormModelos.ShowModal = mrOk then
    begin
      for i := 0 to FormModelos.CheckListBox1.Items.Count - 1 do
      begin
        if FormModelos.CheckListBox1.Checked[i] then
          CopyFile(PastaModels + PathDelim + FormModelos.CheckListBox1.Items[i],
            STV2.Path + FormModelos.CheckListBox1.Items[i]);
      end;
    end;
  finally
    FreeAndNil(FormModelos);
    Ler_ArqProj();
  end;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
  if Panel1.Width < 100 then
    Panel1.Width := 395
  else
    Panel1.Width := 60;
end;

procedure TForm1.MenuItem27Click(Sender: TObject);
var
  S: string;
begin
  if not QLinks.Active then Exit;
  S := STV2.Path + LV2.ItemFocused.Caption;
  QLinks.Insert;
  QLinks.FieldByName('Link').AsString := S;
  QLinks.FieldByName('Descricao').AsString := ExtractFileName(S);
  QLinks.Post;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  NB1.PageIndex := 10;
end;

procedure TForm1.MenuItem31Click(Sender: TObject);
var S:String;
begin
  S:=DBMemoMail.SelText;
  if (Pos('http', S) > 0) or (Pos('www', S) > 0) then
      OpenURL(S)
    else
      OpenURL('http://' + S);
end;

procedure TForm1.MenuItem34Click(Sender: TObject);
begin
  STV1.Root := PastaDrop + PathDelim + 'Projetos';
  ATButton34Click(Self);
end;

procedure TForm1.MenuItem36Click(Sender: TObject);
begin
  STV1.Root := PastaDrop + PathDelim + 'Temp';
  ATButton34Click(Self);
end;

procedure TForm1.MenuItem37Click(Sender: TObject);
begin
  STV1.Root := PastaDrop;
  ATButton34Click(Self);
end;

procedure TForm1.MenuItem38Click(Sender: TObject);
begin
  STV1.Root := '/media/mauricio/OS/Users/camar/OneDrive/BIB_MEND_Novas';
  ATButton34Click(Self);
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
var S,S1: string;
begin
CheckPastaLxWn();
S := STV2.Path + LV2.ItemFocused.Caption;
S1:=STV2.Path+ExtractFileNameOnly(LV2.ItemFocused.Caption) + ' - Copia'+ExtractFileExt(S);
CopyFile(S, S1);
ATButton36Click(Self);
end;

procedure TForm1.MenuItem40Click(Sender: TObject);
var Si: string;
begin
if TV.Items.Count = 0 then Exit;
if MessageDlg(rs_TransProjLix, mtConfirmation, [mbNo, mbYes], 0) <> mrYes then Exit;
if Edit1.Text = '' then begin
 if TV.Selected <> nil then begin
  MudarSituacao(3);
  PopTVx();
 end;
end else begin
 Si := QProj.Fields[0].AsString;
 QProj.Close;
 QTemp.Close;
 QTemp.SQL.Text := 'Update ProjsTB set Situacao=3 where ID_Proj=' + Si;
 QTemp.ExecSQL;
 PopTV();
 QProj.Open;
 Edit1.Clear;
 TV.Selected := TV.TopItem;
 PopTVx();
end;
LerEmail('order by Data COLLATE NOCASE DESC');
end;

procedure TForm1.MenuItem41Click(Sender: TObject);
begin
  STV1.Root := '/media/mauricio/OS/Users/camar/OneDrive/Livros';
  ATButton34Click(Self);
end;

procedure TForm1.MenuItem43Click(Sender: TObject);
begin
  Edit1.Clear;
end;

procedure TForm1.MenuItem44Click(Sender: TObject);
begin
  ColorSpeedButton29Click(Self);
end;

procedure TForm1.MenuItem45Click(Sender: TObject);
begin
  LV1Abrir;
end;

procedure TForm1.MenuItem46Click(Sender: TObject);
begin
  if MessageDlg(rs_DelFile + LV1.ItemFocused.Caption + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    DeleteFile(STV1.Path + PathDelim + LV1.ItemFocused.Caption);
    ATButton34Click(Self);
  end;
end;

procedure TForm1.MenuItem47Click(Sender: TObject);
var
  S, PathOld, PathNew: string;
begin
  //Às vezes funciona, ás vezes não com F2
  S := ExtractFileName(STV1.Path + PathDelim + LV1.ItemFocused.Caption);
  if not InputQuery(rs_Rename, rs_NovoNome, S) then Exit;
  PathOld := STV1.Path + PathDelim + LV1.ItemFocused.Caption;
  PathNew := ExtractFilePath(PathOld) + S;
  RenameFile(PathOld, PathNew);
  ATButton34Click(Self);
  Abort;
end;

procedure TForm1.LV1Abrir;
begin
  OpenDocument(STV1.Path + PathDelim + LV1.ItemFocused.Caption);
end;

procedure TForm1.LV2Abrir;
var
  PathS: string;
begin
  PathS := STV2.Path + LV2.ItemFocused.Caption;
  if LV2.ItemFocused <> nil then OpenDocument(PathS);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  ColorSpeedButton54Click(Self);
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  if not QLinks.Active then Exit;
  QLinks.Insert;
  QLinks.FieldByName('Link').AsString := STV2.Root;
  QLinks.FieldByName('Descricao').AsString := rs_EnvGerArq;
  QLinks.Post;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
var
  S, F, P: string;
begin
  if InputQuery(rs_NovaPasta, rs_NNovaPasta, S) then
  begin
    CreateDir(STV2.Path + S);
    F := STV2.Root; //Único jeito de atualizar
    P := STV2.Path;
    STV2.Root := '';
    STV2.Root := F;
    STV2.Path := P + PathDelim + S;
  end;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
var
  S, F: string;
begin
  S := STV2.Path;
  if InputQuery(rs_RenameFolder, rs_NRenameFolder, S) then
  begin
    RenameFile(STV2.Path, S);
    F := STV2.Root; //Único jeito de atualizar
    STV2.Root := '';
    STV2.Root := F;
    STV2.Path := S;
  end;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
var
  F: string;
begin
  if DirectoryExists(STV2.Path) then
    if MessageDlg(rs_Mess6 + #13#13 + rs_Mess8, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      DeleteDirectory(STV2.Path, False);
      //Se gravar a path antes não vai abrir depois, como em botão37
      F := STV2.Root; //Único jeito de atualizar
      STV2.Root := '';
      STV2.Root := F;
    end;
end;

procedure TForm1.PanelAvisosClick(Sender: TObject);
begin
  TimerAvisos.Enabled := not TimerAvisos.Enabled;
end;

procedure TForm1.PanelAvisosDblClick(Sender: TObject);
begin
  ShowMessage(HoldAvisos.Strings.Text);
end;

procedure TForm1.QLinksBeforePost(DataSet: TDataSet);
begin
  QLinks.Fields[0].AsInteger := QProj.Fields[0].AsInteger;
end;

procedure TForm1.QProjAfterScroll(DataSet: TDataSet);
begin
  ProjAtual := QProj.Fields[0].AsInteger;
end;

procedure TForm1.QProjBeforeScroll(DataSet: TDataSet);
begin
  ProjAnterior := QProj.Fields[0].AsInteger;
end;

procedure TForm1.QRascuAfterPost(DataSet: TDataSet);
begin
  AtlzRegRascu();
end;

procedure TForm1.QTarAFAfterInsert(DataSet: TDataSet);
begin
  if NaoVeioDaGrid = True then
  begin
    NaoVeioDaGrid := False;
    Exit;
  end
  else
  begin
    DataSet.Edit;
    DataSet.FieldByName('ProjID').AsInteger := QProj.FieldByName('ID_Proj').AsInteger;
    DataSet.FieldByName('Situacao').AsInteger := 1;
    DataSet.FieldByName('Prazo').AsDateTime := Now + 1;
    DataSet.Post;
  end;
end;

procedure TForm1.RadioButton7xChange(Sender: TObject);
begin
  Ler_Tl();
  ColorSpeedButton96Click(Sender);
end;

procedure TForm1.RadioButton8xChange(Sender: TObject);
begin
  Ler_Tl();
  ColorSpeedButton96Click(Sender);
end;

procedure TForm1.RxSwitch1Click(Sender: TObject);
begin
  PopTVx();
end;

procedure TForm1.SGTlDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
var
  Ano, C, L, i, j, n: integer;
  d, DateTl: System.TDate;
  Last, nTl, w: integer;
  Parou: boolean;
  S: string;
begin
  if HoldTl.Strings.Count = 0 then Exit;

  Last := HoldTl.Strings.Count - 1;
  Ano := StrToInt(ListBox1x.Items[ListBox1x.ItemIndex]);

  for w := 0 to HoldTl.Strings.Count - 1 do
  begin
    nTl := StrToInt(Copy(HoldTl.Strings[w], 12, Length(HoldTl.Strings[w])));
    d := EncodeDate(Ano, 1, 1);
    n := DayOfWeek(d);

    S := HoldTl.Strings[w];
    DateTl := EncodeDate(StrToInt(Copy(S, 1, 4)), StrToInt(Copy(S, 6, 2)), StrToInt(Copy(S, 9, 2)));

    Parou := False;

    for j := 1 to 53 do
    begin
      for i := n to 7 do
      begin
        if d = DateTl then
        begin
          C := j;
          L := i;
          Parou := True;
          Break;
        end;
        d := d + 1;
      end;
      if Parou = True then Break;
      n := 1;
    end;

    if ((aCol = C) and (aRow = L)) then
    begin
      if (nTl > 0) and (nTl <= 1800000) then SGTl.Canvas.Brush.Color := $D7FEEB;
      //<30 min
      if (nTl > 1800000) and (nTl <= 3600000) then SGTl.Canvas.Brush.Color := $9CFCCE;        //1h
      if (nTl > 3600000) and (nTl <= 5400000) then SGTl.Canvas.Brush.Color := $4DF9A6;
      //1.5h
      if (nTl > 5400000) and (nTl <= 7200000) then SGTl.Canvas.Brush.Color := $09EC7E;        //2h
      if (nTl > 7200000) and (nTl <= 9000000) then SGTl.Canvas.Brush.Color := $08D974;
      //2.5h
      if (nTl > 9000000) and (nTl <= 10800000) then SGTl.Canvas.Brush.Color := $06B15F;       //3h
      if (nTl > 10800000) and (nTl <= 12600000) then SGTl.Canvas.Brush.Color := $058A4A;   //3.5h
      if (nTl > 12600000) and (nTl <= 14400000) then SGTl.Canvas.Brush.Color := $046235;   //4h
      if (nTl > 14400000) and (nTl <= 16200000) then SGTl.Canvas.Brush.Color := $023B20;   //4.5h
      if nTl > 16200000 then SGTl.Canvas.Brush.Color := $01140B;
      //>4.5h (ou 5h como no botão)

      SGTl.Canvas.FillRect(aRect);

      if nTl <= 10800000 then
        SGTl.Canvas.Font.Color := clBlack
      else
        SGTl.Canvas.Font.Color := clWhite;

      SGTl.Canvas.Font.Size := 7;

      SGTl.Canvas.TextOut(aRect.Left + 3, aRect.Top + 4, IntToStr(DayOf(d)));

    end;
  end;
end;

procedure TForm1.spBp11Click(Sender: TObject);
var
  n, i: integer;
  P, S: string;
begin
  P := PathDelim;
  S := HoldPath1.Strings[0];
  n := (Sender as TSpeedButton).Tag;
  for i := 1 to n do
    S := S + P + HoldPath1.Strings[i];
  STV1.Root := S;
  STV1.Selected := STV1.TopItem;
end;

procedure TForm1.spBp1Click(Sender: TObject);
var
  n, i: integer;
  P, S: string;
begin
  P := PathDelim;
  S := HoldPath2.Strings[0];
  n := (Sender as TSpeedButton).Tag;
  for i := 1 to n do
    S := S + P + HoldPath2.Strings[i];
  STV2.Root := S;
  STV2.Selected := STV2.TopItem;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  P: TProcess;
begin
  //Tirado do programa SetBamboo
{$IFDEF Linux}
 P:=TProcess.Create(nil);
 P.Executable:='nautilus';
 P.Parameters.Add(STV1.Path);
 P.Execute;
 P.Active:=True;
 P.Free;  //Se colocar isso a janela não vem para frente. Será?
{$ELSE}
  OpenDocument(STV1.Path);
{$ENDIF}
end;

procedure TForm1.SpeedButton59Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  DDate:=IncMonth(DDate,-1);
  LerAgendaMes();
end;

procedure TForm1.SpeedButton60Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  DDate:=IncMonth(DDate,1);
  LerAgendaMes();
end;

procedure TForm1.SpeedButton62Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  DDate := EncodeDate(YearOf(DDate) - 1, MonthOf(DDAte), DayOf(DDate));
  LerAgendaMes();
end;

procedure TForm1.SpeedButton63Click(Sender: TObject);
begin
  if TV.Items.Count = 0 then Exit;
  DDate := EncodeDate(YearOf(DDate) + 1, MonthOf(DDAte), DayOf(DDate));
  LerAgendaMes();
end;

procedure TForm1.Splitter5Moved(Sender: TObject);
begin
  if NB1.PageIndex = 6 then
    AjeitarTamanhoColunasAgenda;
end;

procedure TForm1.STV1Change(Sender: TObject; Node: TTreeNode);
var
  S, Path: string;
  i: integer;
begin
  //Não sei porque o node aqui retorna '/' ao invés de '\'.
  //Isso não acontece em STV1.
{$IFDEF Windows}
 S:=Node.GetTextPath+PathDelim;
 S:=StringReplace(S,'/','\',[rfReplaceAll]);
 AddFilesToLV(FLV1,LV1,S);
 {$ELSE}
  AddFilesToLV(FLV1, LV1, Node.GetTextPath + PathDelim);
{$ENDIF}
  LV1.AutoSort := False;
  LV1.AutoSortIndicator := False;
  LV1.SortColumn := -1; //Precisa mudar para fazer efeito e ordenar pela coluna 2 (Data)
  LV1.SortColumn := 2;
  LV1.AutoSort := True;
  LV1.AutoSortIndicator := True;

  //Barra de path
  if Copy(STV1.Path, 1, Length(STV1.Path) - 1) = '' then Path := STV1.Root
  else
    Path := Copy(STV1.Path, 1, Length(STV1.Path) - 1);
  HoldPath1.Clear;
  HoldPath1.Strings.Text := ReplaceText(Path, PathDelim, #13#10);  //#13#10 ou #13? Ver isso.
  i := HoldPath1.Strings.Count - 1;
  spBp11.Visible := False;
  spBp12.Visible := False;
  spBp13.Visible := False;
  spBp14.Visible := False;
  spBp15.Visible := False;
  spBp16.Visible := False;
  spBp17.Visible := False;
  spBp18.Visible := False;
  spBp19.Visible := False;
  spBp20.Visible := False;

  if i >= 1 then
  begin
    spBp11.Caption := HoldPath1.Strings[1];
    spBp11.Visible := True;
  end;
  if i >= 2 then
  begin
    spBp12.Caption := HoldPath1.Strings[2];
    spBp12.Visible := True;
  end;
  if i >= 3 then
  begin
    spBp13.Caption := HoldPath1.Strings[3];
    spBp13.Visible := True;
  end;
  if i >= 4 then
  begin
    spBp14.Caption := HoldPath1.Strings[4];
    spBp14.Visible := True;
  end;
  if i >= 5 then
  begin
    spBp15.Caption := HoldPath1.Strings[5];
    spBp15.Visible := True;
  end;
  if i >= 6 then
  begin
    spBp16.Caption := HoldPath1.Strings[6];
    spBp16.Visible := True;
  end;
  if i >= 7 then
  begin
    spBp17.Caption := HoldPath1.Strings[7];
    spBp17.Visible := True;
  end;
  if i >= 8 then
  begin
    spBp18.Caption := HoldPath1.Strings[8];
    spBp18.Visible := True;
  end;
  if i >= 9 then
  begin
    spBp19.Caption := HoldPath1.Strings[9];
    spBp19.Visible := True;
  end;
  if i >= 10 then
  begin
    spBp20.Caption := HoldPath1.Strings[10];
    spBp20.Visible := True;
  end;

end;

procedure TForm1.STV1GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.ImageIndex := 2;
end;

procedure TForm1.STV1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := 1;
end;

procedure TForm1.STV2Change(Sender: TObject; Node: TTreeNode);
var
  S, Path: string;
  i: integer;
begin
  //Não sei porque o node aqui retorna '/' ao invés de '\'.
  //Isso não acontece em STV1.
{$IFDEF Windows}
 S:=Node.GetTextPath+PathDelim;
 S:=StringReplace(S,'/','\',[rfReplaceAll]);
 AddFilesToLV(FLV2,LV2,S);
{$ELSE}
  AddFilesToLV(FLV2, LV2, Node.GetTextPath + PathDelim);
{$ENDIF}
  LV2.AutoSort := False;
  LV2.AutoSortIndicator := False;
  LV2.SortColumn := -1; //Precisa mudar para fazer efeito e ordenar pela coluna 2 (Data)
  LV2.SortColumn := 2;
  LV2.AutoSort := True;
  LV2.AutoSortIndicator := True;
  if LV2.Items.Count > 0 then LV2.ItemIndex := 0;

  //Barra de path
  if Copy(STV2.Path, 1, Length(STV2.Path) - 1) = '' then Path := STV2.Root
  else
    Path := Copy(STV2.Path, 1, Length(STV2.Path) - 1);
  HoldPath2.Clear;
  HoldPath2.Strings.Text := ReplaceText(Path, PathDelim, #13#10);
  i := HoldPath2.Strings.Count - 1;
  spBp1.Visible := False;
  spBp2.Visible := False;
  spBp3.Visible := False;
  spBp4.Visible := False;
  spBp5.Visible := False;
  spBp6.Visible := False;
  spBp7.Visible := False;
  spBp8.Visible := False;
  spBp9.Visible := False;
  spBp10.Visible := False;

  if i >= 1 then
  begin
    spBp1.Caption := HoldPath2.Strings[1];
    spBp1.Visible := True;
  end;
  if i >= 2 then
  begin
    spBp2.Caption := HoldPath2.Strings[2];
    spBp2.Visible := True;
  end;
  if i >= 3 then
  begin
    spBp3.Caption := HoldPath2.Strings[3];
    spBp3.Visible := True;
  end;
  if i >= 4 then
  begin
    spBp4.Caption := HoldPath2.Strings[4];
    spBp4.Visible := True;
  end;
  if i >= 5 then
  begin
    spBp5.Caption := HoldPath2.Strings[5];
    spBp5.Visible := True;
  end;
  if i >= 6 then
  begin
    spBp6.Caption := HoldPath2.Strings[6];
    spBp6.Visible := True;
  end;
  if i >= 7 then
  begin
    spBp7.Caption := HoldPath2.Strings[7];
    spBp7.Visible := True;
  end;
  if i >= 8 then
  begin
    spBp8.Caption := HoldPath2.Strings[8];
    spBp8.Visible := True;
  end;
  if i >= 9 then
  begin
    spBp9.Caption := HoldPath2.Strings[9];
    spBp9.Visible := True;
  end;
  if i >= 10 then
  begin
    spBp10.Caption := HoldPath2.Strings[10];
    spBp10.Visible := True;
  end;

end;

procedure TForm1.STV2GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
Node.ImageIndex := 2;
end;

procedure TForm1.STV2GetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := 1;
end;

procedure TForm1.STV2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbLeft then STV2.BeginDrag(False);
end;

procedure TForm1.STV3Change(Sender: TObject; Node: TTreeNode);
var
  S, Path: string;
  i: integer;
begin
  //Não sei porque o node aqui retorna '/' ao invés de '\'.
  //Isso não acontece em STV1.
{$IFDEF Windows}
 S:=Node.GetTextPath+PathDelim;
 S:=StringReplace(S,'/','\',[rfReplaceAll]);
 AddFilesToLV(FLV4,LV3,S);
{$ELSE}
  AddFilesToLV(FLV4, LV3, Node.GetTextPath + PathDelim);
{$ENDIF}
  LV3.AutoSort := False;
  LV3.AutoSortIndicator := False;
  LV3.SortColumn := -1; //Precisa mudar para fazer efeito e ordenar pela coluna 2 (Data)
  LV3.SortColumn := 2;
  LV3.AutoSort := True;
  LV3.AutoSortIndicator := True;
  if LV3.Items.Count > 0 then LV3.ItemIndex := 0;
end;

procedure TForm1.STV3GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.ImageIndex := 2;
end;

procedure TForm1.STV3GetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := 1;
end;

procedure TForm1.T1Timer(Sender: TObject);
var
  T: integer;
  rz: integer;
  S, R: shortstring;
begin
  Dec(VR);
  if VR < 0 then
  begin
    Dec(TR);
    VR := 59;
    rz := Round(100 / StrToInt(FormPomo.SpinEdit1.Caption));
    AtualizarAnalogico(TR * rz);
    Label36.Caption := IntToStr(TR) + ' min';
  end;
  T := TR - 1;
  if T <= 9 then R := '0' + IntToStr(T)
  else
    R := IntToStr(T);
  if VR <= 9 then S := '0' + IntToStr(VR)
  else
    S := IntToStr(VR);
  Label9x.Caption := R + ':' + S;
  Form1.Caption := rs_FORM1CAPTION + ' (Pomodoro -> ' + R + ':' + S + ')';
  if T < 0 then
  begin
    T1.Enabled := False;
    Label9x.Caption := '00:00';
    Form1.Caption := rs_FORM1CAPTION;
    MessageDlg(rs_Intervalo + FormPomo.SpinEdit2.Text + rs_Minute, mtInformation, [mbOK], 0);
    VR := 60;
    TR := StrToInt(FormPomo.SpinEdit2.Text);
    T2.Enabled := True;
    Label36.Caption := rs_InInterval;
    //Label32.Caption := FormPomo.SpinEdit2.Caption + ' min';
  end;
end;

procedure TForm1.T2Timer(Sender: TObject);
var
  T: integer;
  S, R: shortstring;
  rz: integer;
begin
  Dec(VR);
  if VR < 0 then
  begin
    Dec(TR);
    VR := 59;
    rz := Round(100 / StrToInt(FormPomo.SpinEdit2.Caption));
    AtualizarAnalogico(TR * rz);
    Label32.Caption := IntToStr(TR) + ' min';
  end;
  T := TR - 1;
  if T <= 9 then R := '0' + IntToStr(T)
  else
    R := IntToStr(T);
  if VR <= 9 then S := '0' + IntToStr(VR)
  else
    S := IntToStr(VR);
  Label9x.Caption := R + ':' + S;
  Form1.Caption := rs_FORM1CAPTION + '(Pomodoro -> ' + R + ':' + S + ')';
  if T < 0 then
  begin
    T2.Enabled := False;
    Label9x.Caption := '00:00';
    Form1.Caption := rs_FORM1CAPTION;
    MessageDlg(rs_EndInterval, mtInformation, [mbOK], 0);
    Label36.Caption := rs_TempoInt;
  end;
end;

procedure TForm1.TimerAvisosTimer(Sender: TObject);
var
  c: integer;
begin
  c := HoldAvisos.Strings.Count;
  AvisoCnt := AvisoCnt + 1;
  if AvisoCnt >= c then AvisoCnt := 0;
  PanelAvisos.Caption := HoldAvisos.Strings[AvisoCnt];
end;

procedure TForm1.TimerCreateTimer(Sender: TObject);
var
  S, S1: string;
  d, m, a, dh, mh, ah, i, j: integer;
  DataExp: System.TDateTime;
  Expirou, FoiAvisoCfg: boolean;
begin
  TimerCreate.Enabled := False;

  ColorSpeedButton4.Caption := rs_Projs + ' (' + ContarReg(1) + ')';

  ComboBox1.Items.Insert(0, 'pt-br Português Brasil');
  ComboBox1.Items.Add('en-us English EUA');

{if FirstUse then begin
 FormLanguage.ShowModal;
 if FormLanguage.RadioPt.Checked then
  ComboBox1.ItemIndex:=0 else
   ComboBox1.ItemIndex:=1;
HoldAvisos.Strings.Clear;
HoldAvisos.Strings.Add(rs_PanAviCap);
HoldAvisos.Strings.Add(rs_PanAviFirstUse);
end;
}

  S := ConfigLerStr('ConfigTB', 'Idioma');
  for i := 0 to ComboBox1.Items.Count - 1 do
    if Pos(S, ComboBox1.Items[i]) > 0 then
      ComboBox1.ItemIndex := i;
  if pos('en-us', S) > 0 then SetDefaultLang('en-us')
  else
  if pos('pt-br', S) > 0 then SetDefaultLang('pt-br');

  ComboBox1Change(Self);

  HoldAvisos.Strings.Add(rs_PanAviCap);

  FoiAvisoCfg := False;

  //PastaDrop
  //PastaDrop := ConfigLerStr(CFGTB, 'PastaDrop');
  PastaDrop := LerRegistro('PastaDrop');
  DE8.Text := PastaDrop;
  if PastaDrop = '' then
  begin
    FoiAvisoCfg := True;
    HoldAvisos.Strings.Add(rs_AvisoConfig);
  end;

  PastaProj:=PastaDrop+PathDelim+'Projetos';
  if DirectoryExists(PastaProj) then begin
   Label29.Caption:='Ok';
   Label29.Font.Color:=clBlue;
  end;
  PastaDown:=PastaDrop+PathDelim+'Downloads';
  if DirectoryExists(PastaDown) then begin
    Label44.Caption:='Ok';
   Label44.Font.Color:=clBlue;
  end;
  STV1.Root := PastaDown;
  PastaModels:=PastaDrop+PathDelim+'Modelos';
  if DirectoryExists(PastaDown) then begin
   Label37.Caption:='Ok';
   Label37.Font.Color:=clBlue;
  end;

  Edit3.Text:=ConfigLerStr('ConfigTB','UserEmail');
  Edit7.Text:=ConfigLerStr('ConfigTB','UserPassw');

  //PastaDropAudio
  Ler_PastaAudios();
  if DirectoryExists(PastaDropAudio) then begin
   Label49.Caption:='Ok';
   Label49.Font.Color:=clBlue;
  end;

  //PastaDropAudio
  Ler_PastaAudios();
  if DirectoryExists(PastaDropAudio) then begin
   Label49.Caption:='Ok';
   Label49.Font.Color:=clBlue;
  end;

  Ler_Audios();
  j := 0;
  dh := DayOf(Date);
  mh := MonthOf(Date);
  ah := YearOf(Date);
  for i := 0 to LVAudio.Items.Count - 1 do
  begin
    S := LVAudio.Items[i].SubItems[1]; //Pega a data
    d := StrToInt(Copy(S, 9, 2));
    m := StrToInt(Copy(S, 6, 2));
    a := StrToInt(Copy(S, 1, 4));
    if (d = dh) and (m = mh) and (a = ah) then j := j + 1;
    if (d = dh - 1) and (m = mh) and (a = ah) then j := j + 1;
  end;
  if j > 0 then HoldAvisos.Strings.Add(rs_AudioGrav + IntToStr(j));

  //Notificações da agenda
  CheckBox4.Checked := True; //Tem que colocar aqui para pegar todos os dados da agenda
  LerAgendaMes();
  AjeitarTamanhoColunasAgenda;
  j := 0;
  dh := DayOf(Date);
  mh := MonthOf(Date);
  ah := YearOf(Date);
  for i := HoldSelect.Strings.Count - 1 downto 0 do
  begin
    S := HoldSelect.Strings[i]; //Pega a data
    d := StrToInt(Copy(S, 7, 2));
    m := StrToInt(Copy(S, 5, 2));
    a := StrToInt(Copy(S, 1, 4));
    S1 := Copy(S, 10, 2) + ':' + Copy(S, 12, 2);
    if S1 = '00:00' then S1 := rs_DiaTodo;
    if ((d = dh) and (m = mh) and (a = ah)) then
      HoldAvisos.Strings.Add(rs_AgendaHoje + S1 + '): ' + Copy(S, 15, Length(S)));
    if ((d = dh + 1) and (m = mh) and (a = ah)) then
      HoldAvisos.Strings.Add(rs_AgendaAmanha + S1 + '): ' + Copy(S, 15, Length(S)));
  end;

  CheckBox4.Checked := False;
  //Tem que colocar aqui para voltar pegar todos os dados da agenda

  //Notificações de Tarefas
  //Tarefas de hoje
  Qtemp.Close;
  Qtemp.SQL.Text := 'Select * from TarefasTB where Prazo>' + DTToJulian(
    Date, 0, 0, 0, 0, 0, 0, 0) + ' and Prazo<' + DTToJulian(Date + 1, 0, 0, 0, 0, 0, 0, 0) + ' and Situacao=1';
  QTemp.Open;
  while not QTemp.EOF do
  begin
    HoldAvisos.Strings.Add(rs_TarHoje + QTemp.FieldByName('Tarefa').AsString);
    QTemp.Next;
  end;
  //Tarefas de amanhã
  Qtemp.Close;
  Qtemp.SQL.Text := 'Select * from TarefasTB where Prazo>' + DTToJulian(
    Date + 1, 0, 0, 0, 0, 0, 0, 0) + ' and Prazo<' + DTToJulian(Date + 2, 0, 0, 0, 0, 0, 0, 0) + ' and Situacao=1';
  QTemp.Open;
  while not QTemp.EOF do
  begin
    HoldAvisos.Strings.Add(rs_TarAmanha + QTemp.FieldByName('Tarefa').AsString);
    QTemp.Next;
  end;

  CLBBusca.Clear;
  CLBBusca.Items.Add(rs_projetos);
  CLBBusca.Items.Add(rs_arqs);
  CLBBusca.Items.Add('E-mails');
  CLBBusca.Items.Add(rs_notes);
  CLBBusca.Items.Add(rs_Conts);
  CLBBusca.Items.Add(rs_Tars);
  CLBBusca.Items.Add(rs_Agenda);
  CLBBusca.Items.Add('Links');
  CLBBusca.CheckAll(cbChecked, False, False);

{if FirstUse then begin
 HoldAvisos.Strings.Clear;
 HoldAvisos.Strings.Add(rs_PanAviCap);
 HoldAvisos.Strings.Add(rs_PanAviFirstUse);
 SpBp1.Visible:=False;  //Não se sabe porquê eles ficam visíveis no primeiro uso
 SpBp2.Visible:=False;
 SpBp11.Visible:=False;
 SpBp12.Visible:=False;
 ATButton12Click(Self);
end;
}

  Panel127.Width:=45;

  TimerAvisos.Enabled := True;

end;

procedure TForm1.TimerDownTimer(Sender: TObject);
begin
  ATButton28Click(Sender);
  TimerDown.Enabled := False;
end;

procedure TForm1.TimerPanelTimer(Sender: TObject);
begin
Panel127.Width := Panel127.Width + 60;
  if Panel127.Width >= 450 then
    TimerPanel.Enabled := False;
end;

procedure TForm1.TLTimer(Sender: TObject);
begin
TLTime := TLTime + 1000;
Label25x.Caption := TimeToStr(IncMilliSecond(0, TLTime));
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Label16.Caption:='('+IntToStr(TrackBar1.Position)+')';
end;

procedure TForm1.TVaChange(Sender: TObject; Node: TTreeNode);
var
  i: integer;
begin
if (TVa.Items.Count > 0) and (Edit1.text='') then
 for i := 0 to TVa.Items.Count - 1 do
  if TV.Items[i].Text = Node.Text then begin
   TV.Selected := TV.Items[i];
   Break;
  end;
end;

procedure TForm1.TVaDragDrop(Sender, Source: TObject; X, Y: integer);
begin
  if Source = TVb then AcaoBut('1', TVb.Selected);
  if Source = TVc then AcaoBut('1', TVc.Selected);
end;

procedure TForm1.TVaDragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  if Source is TTreeView then Accept := True;
end;

procedure TForm1.TVbDragDrop(Sender, Source: TObject; X, Y: integer);
begin
  if Source = TVa then AcaoBut('2', TVa.Selected);
  if Source = TVc then AcaoBut('2', TVc.Selected);
end;

procedure TForm1.TVbDragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  if Source is TTreeView then Accept := True;
end;

procedure TForm1.TVcDragDrop(Sender, Source: TObject; X, Y: integer);
begin
  if Source = TVa then AcaoBut('3', TVa.Selected);
  if Source = TVb then AcaoBut('3', TVb.Selected);
end;

procedure TForm1.TVcDragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  if Source is TTreeView then Accept := True;
end;

procedure TForm1.MudarSituacao(NovaSituacao: integer);
var
  m, x, r: integer;
  SQLtmp: string;
  Bt, Tp: boolean;
begin
  m := TV.Selected.Index;
  if m = -1 then Exit;
  if TV.Selected = TV.BottomItem then Bt := True
  else
    Bt := False;
  if TV.Selected = TV.TopItem then Tp := True
  else
    Tp := False;
  r := QProj.RecNo;
  QProj.Edit;
  QProj.FieldByName('Situacao').AsInteger := NovaSituacao;
  if NovaSituacao = 1 then x := 0;
  if NovaSituacao = 2 then x := 27;
  if NovaSituacao = 3 then x := 28;
  QProj.FieldByName('Icons').AsInteger := x;
  QProj.FieldByName('Posicao').AsInteger := -1;
  QProj.Post;
  SQLtmp := QProj.SQL.Text;
  QProj.Close;
  QProj.SQL.Text := 'Select * from ProjsTB where Situacao=' + IntToStr(
    NovaSituacao) + ' order by Posicao';
  QProj.Open;
  RefazerPosicaoProj(); //Refazendo a nova situação
  QProj.Close;
  QProj.SQL.Text := SQLtmp;
  QProj.Open;
  RefazerPosicaoProj();//Refazendo a velha situação
  PopTV();

  ColorSpeedButton4.Caption := rs_Projs + ' (' + ContarReg(1) + ')';

  if Bt then TV.Selected := TV.BottomItem
  else
  if Tp then TV.Selected := TV.TopItem
  else
  begin
    TV.Selected := TV.Items[m];
    if QProj.RecordCount < m - 1 then
      QProj.RecNo := m - 1;
  end;

  AbrirProj();
  Edit1.Clear;
end;

function TForm1.ContarReg(Situacao: integer): string;
begin
  QTemp1.Close;
  QTemp1.SQL.Text := 'Select count(ProjName) from ProjsTB where Situacao=' +
    IntToStr(Situacao);
  QTemp1.Open;
  Result := IntToStr(QTemp1.Fields[0].AsInteger);
end;

procedure TForm1.TVChange(Sender: TObject; Node: TTreeNode);
begin
  if MudouMemos then  ATButton8Click(Self);
  if MudouMemos then ColorSpeedButton55Click(Self);
  MudouMemos := False;
  if TV.Selected = nil then Exit;
  AbrirProj();
end;

procedure TForm1.TVChanging(Sender: TObject; Node: TTreeNode; var AllowChange: boolean);
begin
  if (QTarAF.State = dsEdit) or (QTarAF.State = dsInsert) then QTarAF.Post;
  if (QTarFin.State = dsEdit) or (QTarFin.State = dsInsert) then QTarFin.Post;
end;

procedure TForm1.TVDragDrop(Sender, Source: TObject; X, Y: integer);
var
  Src, Dst: TTreeNode;
  iSrc, iDst: integer;
begin
  Src := TV.Selected;
  iSrc := Src.Index;
  Dst := TV.GetNodeAt(X, Y);
  iDst := Dst.Index;
  QProj.Edit;
  if iSrc > iDst then
    QProj.FieldByName('Posicao').AsInteger := iDst - 1
  else
    QProj.FieldByName('Posicao').AsInteger := iDst + 1;
  QProj.Post;
  QProj.Close;
  QProj.Open;
  RefazerPosicaoProj();
  PopTV();
  TV.Selected := TV.Items[iDst];
  TV.SetFocus;
end;

procedure TForm1.TVDragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
var
  Src, Dst: TTreeNode;
begin
  Src := TV.Selected;
  Dst := TV.GetNodeAt(X, Y);
  Accept := Assigned(Dst) and (Src <> Dst);
end;

procedure TForm1.Ler_ArqProj();
var
  F, P: string;
begin
  F := STV2.Root; //Único jeito de atualizar
  P := STV2.Path;
  STV2.Root := '';
  STV2.Root := F;
  STV2.Path := P;

  F := STV3.Root; //Único jeito de atualizar
  P := STV3.Path;
  STV3.Root := '';
  STV3.Root := F;
  STV3.Path := P;

end;

procedure TForm1.ContarNotas();
var
  i: integer;
begin
  Memo1.Lines.Text := QNotas.FieldByName('Nota1').AsString;
  Memo2.Lines.Text := QNotas.FieldByName('Nota2').AsString;
  Memo3.Lines.Text := QNotas.FieldByName('Nota3').AsString;
  Memo4.Lines.Text := QNotas.FieldByName('Nota4').AsString;
  MemoPj.Lines.Text := QProj.FieldByName('ProjInfo').AsString;
  i := 0;
  if Memo1.Lines.Text <> '' then i := i + 1;
  if Memo2.Lines.Text <> '' then i := i + 1;
  if Memo3.Lines.Text <> '' then i := i + 1;
  if Memo4.Lines.Text <> '' then i := i + 1;
  ColorSpeedButton8.Caption := 'Anotações (' + IntToStr(i) + ')';
end;

procedure TForm1.AbrirProj();
var
  S: string;
  begin
  if QProj.IsEmpty then Exit;
  if TV.Selected = nil then Exit;
  QProj.Locate('ProjName', TV.Selected.Text, []);

  S := PastaProj + PathDelim + QProj.FieldByName('ProjName').AsString;
  PastaProjAtual:=S;

  if (DirectoryExists(S) or (S = '') or (S = '/')) then begin
    STV2.Root := S;
    STV3.Root := S;
    Ler_ArqProj();
  end;

  if STV2.Root = '' then begin
    PastaLxWnVazia := True;
    STV2.Root := STV1.Root;
    STV3.Root := STV1.Root;
  end else PastaLxWnVazia := False;
  STV1.Items[0].Selected := True;
  STV2.Items[0].Selected := True;
  STV3.Items[0].Selected := True;
  STV2.Visible := True; //Ficou invisible lá no Create
  LV2.Visible := True;

  //Marcadores
  LerMarcsProj();

  //Tarefas a fazer
  LerTar();
  RefazerPosicoesTar(True, True);

  //Links
  AbrirLinks();

  //Para os memos
  CriarHistory;

  //Notas
  QNotas.Close;
  QNotas.SQL.Text := 'Select * from NotasTB where ProjID=' + IntToStr(
    QProj.FieldByName('ID_Proj').AsInteger);
  QNotas.Open;
  ContarNotas();

  //Contatos do Projeto
  LerContProj(' order by Nome COLLATE NOCASE ASC');

  //Ler emails --> Anexos e Pessoas são lidos pelo DSMail.DataChange
  LerEmail(' order by Data COLLATE NOCASE DESC');
  ColorSpeedButton13.Caption := 'Emails (' + IntToStr(QMail.RecordCount) + ')';
  if ColorSpeedButton13.Down then begin
    ColorSpeedButton13Click(self);
    CheckBox3.Checked:=False;
  end;

  //Ler Agenda do Projeto
  LerAgendaMes();

  //TimeLine
  Panel95.Visible := True;
  Salvar_tl;
  QTl.Close;
  QTl.SQL.Text := 'Select distinct strftime(''%Y'',Dia) from TimeLineTB';
  QTl.Open;
  ListBox1x.Clear;
  while not QTl.EOF do
  begin
    ListBox1x.Items.Add(QTl.Fields[0].AsString);
    QTl.Next;
  end;
  ;
  ListBox1x.ItemIndex := ListBox1x.Items.Count - 1;
  Ler_tl;

end;

procedure TForm1.PopTV();
var
  T: TTreeNode;
begin
  if QProj.Active = False then QProj.Open;
  QProj.DisableControls;

  TV.Items.Clear;
  QProj.Last;
  while not QProj.BOF do
  begin
    T := TV.Items.AddChildFirst(TV.Selected, QProj.FieldByName('ProjName').AsString);
    T.ImageIndex := QProj.FieldByName('Icons').AsInteger;
    T.SelectedIndex := QProj.FieldByName('Icons').AsInteger;
    T.StateIndex := QProj.FieldByName('Icons').AsInteger;
    QProj.Prior;
  end;
  QProj.EnableControls; //Não pode ficar depois do QProj.Open
  //if Edit1.Text='' then TV.SortType:=stNone else TV.SortType:=stText;
  if TV.Items.Count > 0 then TV.Selected := TV.Items[0];
end;

procedure TForm1.STV2DragDrop(Sender, Source: TObject; X, Y: integer);
var
  node: TTreeNode;
  S: string;
begin
  node := STV2.GetNodeAt(X, Y);
  S := Node.GetTextPath;

  //No Windows Node.GetTextPath retorna node com / ao invés de \.
  //https://forum.lazarus.freepascal.org/index.php?topic=29374.15
{$IFDEF Windows}
S:=StringReplace(S,'/','\',[rfReplaceAll]);
{$ENDIF}

  //if Checkbox10.Checked then
  // CopyFile(STV2.Path+LV2.ItemFocused.Caption,S+PathDelim+ExtractFileName(STV2.Path+LV2.ItemFocused.Caption))
  //  else begin
  CopyFile(STV2.Path + LV2.ItemFocused.Caption, S + PathDelim + ExtractFileName(
    STV2.Path + LV2.ItemFocused.Caption));
  DeleteFileUTF8(STV2.Path + LV2.ItemFocused.Caption);
  //  end;
  //ATButton36Click(Self);
end;

procedure TForm1.STV2DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: boolean);
begin
  Accept := False;
  if (Sender = STV2) and (Source = LV2) then Accept := True;
end;

procedure TForm1.PopTVx();
var
  i: integer;
  T: TTreeNode;
  S: string;
begin
  if RxSwitch1.StateOn = sw_on then
   S := 'order by Posicao' else
    S := 'order by ProjName COLLATE NOCASE';
  QSQx.Close;
  QSQx.SQL.Text := 'Select ProjName,ID_Proj,Situacao,Posicao from ProjsTB ' + S;
  QSQx.Open;
  TVa.Items.Clear;
  TVb.Items.Clear;
  TVc.Items.Clear;
  QSQx.Last;
  i := 0;
  while not QSQx.BOF do
  begin
    if QSQx.FieldByName('Situacao').AsInteger = 1 then
    begin
      T := TVa.Items.AddChildFirst(TVa.Selected, QSQx.FieldByName('ProjName').AsString);
      T.ImageIndex := 0;
      T.SelectedIndex := 0;
      T.StateIndex := 0;
    end;
    if QSQx.FieldByName('Situacao').AsInteger = 2 then
    begin
      T := TVb.Items.AddChildFirst(TVb.Selected, QSQx.FieldByName('ProjName').AsString);
      T.ImageIndex := 27;
      T.SelectedIndex := 27;
      T.StateIndex := 27;
    end;
    if QSQx.FieldByName('Situacao').AsInteger = 3 then
    begin
      T := TVc.Items.AddChildFirst(TVc.Selected, QSQx.FieldByName('ProjName').AsString);
      T.ImageIndex := 28;
      T.SelectedIndex := 28;
      T.StateIndex := 28;
    end;
    i := i + 1;
    QSQx.Prior;
  end;
  if TVa.Items.Count > 0 then TVa.Selected := TVa.Items[0];
  if TVb.Items.Count > 0 then TVb.Selected := TVb.Items[0];
  if TVc.Items.Count > 0 then TVc.Selected := TVc.Items[0];
  Panel64.Caption := rs_ProjAtivo + IntToStr(TVa.Items.Count)+')';
  Panel51.Caption := rs_ProjArquiv + IntToStr(TVb.Items.Count)+')';
  Panel52.Caption := rs_ProjLixo + IntToStr(TVc.Items.Count)+')';
end;

procedure TForm1.ConfigSalvarStr(CfgTb, Coluna: string; Valor: string);
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  if not QTemp.IsEmpty then
    QTemp.Edit else
     QTemp.Insert;
  QTemp.FieldByName(Coluna).AsString := Valor;
  QTemp.Post;
  QTemp.Close;
end;

procedure TForm1.ConfigSalvarBol(CfgTb, Coluna: string; Valor: boolean);
begin
  QTemp1.Close;
  QTemp1.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp1.Open;
  QTemp1.First;
  if not QTemp1.IsEmpty then QTemp1.Edit
  else
    QTemp1.Insert;
  if Valor then QTemp1.FieldByName(Coluna).AsInteger := 1
  else
    QTemp1.FieldByName(Coluna).AsInteger := 0;
  QTemp1.Post;
  QTemp1.Close;
end;

procedure TForm1.ConfigSalvarInt(CfgTb, Coluna: string; Valor: integer);
begin
  QTemp1.Close;
  QTemp1.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp1.Open;
  QTemp1.First;
  if not QTemp1.IsEmpty then QTemp1.Edit
  else
    QTemp1.Insert;
  QTemp1.FieldByName(Coluna).AsInteger := Valor;
  QTemp1.Post;
  QTemp1.Close;
end;

function TForm1.ConfigLerBol(CfgTb, Coluna: string): boolean;
var
  i: integer;
begin
  QTemp.Close;
  QTemp.SQL.Text := 'Select ' + Coluna + ' from ' + CfgTb;
  QTemp.Open;
  QTemp.First;
  i := QTemp.FieldByName(Coluna).AsInteger;
  if i = 0 then Result := False
  else
    Result := True;
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

function TForm1.criptografar(const key, texto: string): string;
var
  I: integer;
  C: byte;
begin
  Result := '';
  for I := 1 to Length(texto) do
  begin
    if Length(Key) > 0 then
      C := byte(Key[1 + ((I - 1) mod Length(Key))]) xor byte(texto[I])
    else
      C := byte(texto[I]);
    Result := Result + AnsiLowerCase(IntToHex(C, 2));
  end;
end;

function TForm1.descriptografar(const key, texto: string): string;
var
  I: integer;
  C: char;
begin
  Result := '';
  for I := 0 to Length(texto) div 2 - 1 do
  begin
    C := Chr(StrToIntDef('$' + Copy(texto, (I * 2) + 1, 2), Ord(' ')));
    if Length(Key) > 0 then
      C := Chr(byte(Key[1 + (I mod Length(Key))]) xor byte(C));
    Result := Result + C;
  end;
end;


procedure TForm1.Ler_PastaAudios();
var
  S: string;
begin
  S := PastaDrop + PathDelim + 'Aplicativos' + PathDelim + 'Easy Voice Recorder' + PathDelim;
  if not DirectoryExists(S) then
    S := PastaDrop + PathDelim + 'Apps' + PathDelim + 'Easy Voice Recorder' + PathDelim;
  if not DirectoryExists(S) then Exit;
  PastaDropAudio := S;
end;

procedure TForm1.Ler_Audios();
begin
  if PastaDropAudio = '' then Exit;
  AddFilesToLV(FLV3, LVAudio, PastaDropAudio);
  LVAudio.AutoSort := False;
  LVAudio.AutoSortIndicator := False;
  LVAudio.SortColumn := -1; //Precisa mudar para fazer efeito e ordenar pela coluna 2 (Data)
  LVAudio.SortColumn := 2;
  LVAudio.AutoSort := True;
  LVAudio.AutoSortIndicator := True;
end;

procedure TForm1.AddFilesToLV(FLV: TListViewFilterEdit; LV: TListView; FilePathName: string);
var
  D, R, K: integer;
  Idade, FileName, Tipo: string;
  SearchRec1: TSearchRec;
  FileListVideo: TStringList;
  ListItem: TListItem;
begin
  LV.Clear;
  FileListVideo := TStringList.Create;
  FileListVideo := FindAllFiles(FilePathName, '', False, faDirectory);
  R := 1;
  K := 0;
  ColorSpeedButton11.Caption := 'Arquivos (' + IntToStr(FileListVideo.Count) + ')';
  for D := 0 to FileListVideo.Count - 1 do
  begin  //No windows é <> e no Linux é =
 {$IFDEF Windows}
  if FindFirst(FilePathName, faAnyFile and faDirectory, SearchRec1)<>0 then
 {$ELSE}
    if FindFirst(FilePathName, faAnyFile and faDirectory, SearchRec1) = 0 then
 {$ENDIF}
    begin
      repeat
        with SearchRec1 do
        begin
          FileName := ExtractFileName(FileListVideo.Strings[D]);
          K := FileSize(FileListVideo.Strings[D]);
          Idade := FormatDateTime('YYYY-MM-DD hh:mm', FileDateToDateTime(
            FileAge(FileListVideo.Strings[D])));
          Tipo := ExtractFileExt(FileListVideo.Strings[D]);
          if (LV = LVAudio) and (Tipo = '.tmp') then Continue;
          if (ContainsText(FileName, FLV.Text)) or (ContainsText(Tipo, FLV.Text)) or
            (FLV.Text = '') then
          begin
            ListItem := LV.Items.Add;
            ListItem.Caption := FileName;
            ListItem.SubItems.Add(Tipo);
            ListItem.SubItems.Add(Idade);
            ListItem.SubItems.Add(nicenumber(IntToStr(K)));
            if (Tipo = '.txt') or (Tipo = '.ini') then ListItem.ImageIndex := 7
            else
            if (Tipo = '.jpg') or (Tipo = '.png') or (Tipo = '.bmp') then ListItem.ImageIndex := 0
            else
            if (Tipo = '.doc') or (Tipo = '.docx') then ListItem.ImageIndex := 8
            else
            if (Tipo = '.xls') or (Tipo = '.xlsx') then ListItem.ImageIndex := 6
            else
            if (Tipo = '.ppt') or (Tipo = '.pptx') then ListItem.ImageIndex := 5
            else
            if (Tipo = '.xoj') or (Tipo = '.xopp') then ListItem.ImageIndex := 13
            else
            if (Tipo = '.pdf') then ListItem.ImageIndex := 9
            else
            if (Tipo = '.zip') or (Tipo = '.gz') then ListItem.ImageIndex := 3
            else
            if (Tipo = '.htm') or (Tipo = '.html') then ListItem.ImageIndex := 2
            else
            if (Tipo = '.eml') then ListItem.ImageIndex := 1
            else
            if (Tipo = '.wav') then ListItem.ImageIndex := 17
            else
              ListItem.ImageIndex := 14;
          end;
          R := R + 1;
        end;
      until FindNext(SearchRec1) <> 0;
    end;
    FindClose(SearchRec1);
  end;
  FileListVideo.Free;
end;

procedure TForm1.CheckPastaLxWn();
begin
  if PastaLxWnVazia then
  begin
    MessageDlg(rs_ErroPastaArq, mtError, [mbOK], 0);
    Exit;
  end;
end;

procedure TForm1.RefazerPosicoesTar(AF, Fin: boolean);
var
  i: integer;
begin
  if AF then
  begin
    QTarAF.DisableControls;
    i := 0;
    if QTarAF.Active = False then QTarAF.Open;
    QTarAF.First;
    while not QTarAF.EOF do
    begin
      QTarAF.Edit;
      QTarAF.FieldByName('Posicao').AsInteger := i;
      QTarAF.Post;
      i := i + 1;
      QTarAF.Next;
    end;
    QTarAF.EnableControls;
    QTarAF.First;
  end;
  if Fin then
  begin
    QTarFin.DisableControls;
    i := 0;
    if QTarFin.Active = False then QTarFin.Open;
    QTarFin.First;
    while not QTarFin.EOF do
    begin
      QTarFin.Edit;
      QTarFin.FieldByName('Posicao').AsInteger := i;
      QTarFin.Post;
      i := i + 1;
      QTarFin.Next;
    end;
    QTarFin.EnableControls;
    QTarFin.First;
  end;
end;

procedure TForm1.LerTar();
begin
  QTarAF.Close;
  QTarAF.SQL.Text := 'SELECT * FROM TarefasTB WHERE ((ProjID="' + IntToStr(
    QProj.FieldByName('ID_Proj').AsInteger) + '") ' + 'and Situacao=1) order by Posicao';
  QTarAF.Open;

  QTarFin.Close;
  QTarFin.SQL.Text := 'SELECT * FROM TarefasTB WHERE ((ProjID="' + IntToStr(
    QProj.FieldByName('ID_Proj').AsInteger) + '") ' + 'and Situacao=2) order by Posicao';
  QTarFin.Open;

  ColorSpeedButton10.Caption := 'Tarefas (' + IntToStr(QTarAF.RecordCount) +
    '/' + IntToStr(QTarFin.RecordCount) + ')';
end;

procedure TForm1.CriarHistory;
begin
  History1 := THistory.Create(Memo1);
  actnCut1.OnExecute := @actnTextExecute;
  actnCopy1.OnExecute := @actnTextExecute;
  actnPaste1.OnExecute := @actnTextExecute;
  actnSelectAll1.OnExecute := @actnTextExecute;
  actnDelete1.OnExecute := @actnTextExecute;
  actnUndo1.OnExecute := @actnTextExecute;
  actnRedo1.OnExecute := @actnTextExecute;
  actnCut1.OnUpdate := @actnCutUpdate;
  actnUndo1.OnUpdate := @actnUndoUpdate;

  History2 := THistory.Create(Memo2);
  actnCut2.OnExecute := @actnTextExecute;
  actnCopy2.OnExecute := @actnTextExecute;
  actnPaste2.OnExecute := @actnTextExecute;
  actnSelectAll2.OnExecute := @actnTextExecute;
  actnDelete2.OnExecute := @actnTextExecute;
  actnUndo2.OnExecute := @actnTextExecute;
  actnRedo2.OnExecute := @actnTextExecute;
  actnCut2.OnUpdate := @actnCutUpdate;
  actnUndo2.OnUpdate := @actnUndoUpdate;

  History3 := THistory.Create(Memo3);
  actnCut3.OnExecute := @actnTextExecute;
  actnCopy3.OnExecute := @actnTextExecute;
  actnPaste3.OnExecute := @actnTextExecute;
  actnSelectAll3.OnExecute := @actnTextExecute;
  actnDelete3.OnExecute := @actnTextExecute;
  actnUndo3.OnExecute := @actnTextExecute;
  actnRedo3.OnExecute := @actnTextExecute;
  actnCut3.OnUpdate := @actnCutUpdate;
  actnUndo3.OnUpdate := @actnUndoUpdate;

  History4 := THistory.Create(Memo4);
  actnCut4.OnExecute := @actnTextExecute;
  actnCopy4.OnExecute := @actnTextExecute;
  actnPaste4.OnExecute := @actnTextExecute;
  actnSelectAll4.OnExecute := @actnTextExecute;
  actnDelete4.OnExecute := @actnTextExecute;
  actnUndo4.OnExecute := @actnTextExecute;
  actnRedo4.OnExecute := @actnTextExecute;
  actnCut4.OnUpdate := @actnCutUpdate;
  actnUndo4.OnUpdate := @actnUndoUpdate;

  HistoryP := THistory.Create(MemoPj);
  actnCutP.OnExecute := @actnTextExecute;
  actnCopyP.OnExecute := @actnTextExecute;
  actnPasteP.OnExecute := @actnTextExecute;
  actnSelectAllP.OnExecute := @actnTextExecute;
  actnDeleteP.OnExecute := @actnTextExecute;
  actnUndoP.OnExecute := @actnTextExecute;
  actnRedoP.OnExecute := @actnTextExecute;
  actnCutP.OnUpdate := @actnCutUpdate;
  actnUndoP.OnUpdate := @actnUndoUpdate;

  HistoryNM := THistory.Create(DBMemo2);
  actnCutNM.OnExecute := @actnTextExecute;
  actnCopyNM.OnExecute := @actnTextExecute;
  actnPasteNM.OnExecute := @actnTextExecute;
  actnSelectAllNM.OnExecute := @actnTextExecute;
  actnDeleteNM.OnExecute := @actnTextExecute;
  actnUndoNM.OnExecute := @actnTextExecute;
  actnRedoNM.OnExecute := @actnTextExecute;
  actnCutNM.OnUpdate := @actnCutUpdate;
  actnUndoNM.OnUpdate := @actnUndoUpdate;

  HistoryMail := THistory.Create(DBMemoMail);
  actnCutMail.OnExecute := @actnTextExecute;
  actnCopyMail.OnExecute := @actnTextExecute;
  actnPasteMail.OnExecute := @actnTextExecute;
  actnSelectAllMail.OnExecute := @actnTextExecute;
  actnDeleteMail.OnExecute := @actnTextExecute;
  actnUndoMail.OnExecute := @actnTextExecute;
  actnRedoMail.OnExecute := @actnTextExecute;
  actnCutMail.OnUpdate := @actnCutUpdate;
  actnUndoMail.OnUpdate := @actnUndoUpdate;
end;

procedure TForm1.actnTextExecute(Sender: TObject);
begin
  case (Sender as TAction).Name of
    'actnCut1': if Memo1.Focused then Memo1.CutToClipboard;
    'actnCopy1': if Memo1.Focused then Memo1.CopyToClipboard;
    'actnPaste1': if Memo1.Focused then History1.PasteText;
    'actnSelectAll1': if Memo1.Focused then Memo1.SelectAll;
    'actnDelete1': if Memo1.Focused then Memo1.SelText := '';
    'actnUndo1': if Memo1.Focused then History1.Undo;
    'actnRedo1': if Memo1.Focused then History1.Redo;

    'actnCut2': if Memo2.Focused then Memo2.CutToClipboard;
    'actnCopy2': if Memo2.Focused then Memo2.CopyToClipboard;
    'actnPaste2': if Memo2.Focused then History2.PasteText;
    'actnSelectAll2': if Memo2.Focused then Memo2.SelectAll;
    'actnDelete2': if Memo2.Focused then Memo2.SelText := '';
    'actnUndo2': if Memo2.Focused then History2.Undo;
    'actnRedo2': if Memo2.Focused then History2.Redo;

    'actnCut3': if Memo3.Focused then Memo3.CutToClipboard;
    'actnCopy3': if Memo3.Focused then Memo3.CopyToClipboard;
    'actnPaste3': if Memo3.Focused then History3.PasteText;
    'actnSelectAll3': if Memo3.Focused then Memo3.SelectAll;
    'actnDelete3': if Memo3.Focused then Memo3.SelText := '';
    'actnUndo3': if Memo3.Focused then History3.Undo;
    'actnRedo3': if Memo3.Focused then History3.Redo;

    'actnCut4': if Memo4.Focused then Memo4.CutToClipboard;
    'actnCopy4': if Memo4.Focused then Memo4.CopyToClipboard;
    'actnPaste4': if Memo4.Focused then History4.PasteText;
    'actnSelectAll4': if Memo4.Focused then Memo4.SelectAll;
    'actnDelete4': if Memo4.Focused then Memo4.SelText := '';
    'actnUndo4': if Memo4.Focused then History4.Undo;
    'actnRedo4': if Memo4.Focused then History4.Redo;

    'actnCutP': if MemoPj.Focused then MemoPj.CutToClipboard;
    'actnCopyP': if MemoPj.Focused then MemoPj.CopyToClipboard;
    'actnPasteP': if MemoPj.Focused then HistoryP.PasteText;
    'actnSelectAllP': if MemoPj.Focused then MemoPj.SelectAll;
    'actnDeleteP': if MemoPj.Focused then MemoPj.SelText := '';
    'actnUndoP': if MemoPj.Focused then HistoryP.Undo;
    'actnRedoP': if MemoPj.Focused then HistoryP.Redo;

    'actnCutNM': if DBMemo2.Focused then DBMemo2.CutToClipboard;
    'actnCopyNM': if DBMemo2.Focused then DBMemo2.CopyToClipboard;
    'actnPasteNM': if DBMemo2.Focused then HistoryNM.PasteText;
    'actnSelectAllNM': if DBMemo2.Focused then DBMemo2.SelectAll;
    'actnDeleteNM': if DBMemo2.Focused then DBMemo2.SelText := '';
    'actnUndoNM': if DBMemo2.Focused then HistoryNM.Undo;
    'actnRedoNM': if DBMemo2.Focused then HistoryNM.Redo;

    'actnCutMail': if DBMemoMail.Focused then DBMemoMail.CutToClipboard;
    'actnCopyMail': if DBMemoMail.Focused then DBMemoMail.CopyToClipboard;
    'actnPasteMail': if DBMemoMail.Focused then HistoryMail.PasteText;
    'actnSelectAllMail': if DBMemoMail.Focused then DBMemoMail.SelectAll;
    'actnDeleteMail': if DBMemoMail.Focused then DBMemoMail.SelText := '';
    'actnUndoMail': if DBMemoMail.Focused then HistoryMail.Undo;
    'actnRedoMail': if DBMemoMail.Focused then HistoryMail.Redo;
  end;
end;

procedure TForm1.actnCutUpdate(Sender: TObject);
begin
  actnCut1.Enabled := Memo1.SelLength > 0;
  actnCopy1.Enabled := actnCut1.Enabled;
  actnPaste1.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDelete1.Enabled := actnCut1.Enabled;

  actnCut2.Enabled := Memo2.SelLength > 0;
  actnCopy2.Enabled := actnCut2.Enabled;
  actnPaste2.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDelete2.Enabled := actnCut2.Enabled;

  actnCut3.Enabled := Memo3.SelLength > 0;
  actnCopy3.Enabled := actnCut3.Enabled;
  actnPaste3.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDelete3.Enabled := actnCut3.Enabled;

  actnCut4.Enabled := Memo4.SelLength > 0;
  actnCopy4.Enabled := actnCut4.Enabled;
  actnPaste4.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDelete4.Enabled := actnCut4.Enabled;

  actnCutP.Enabled := MemoPj.SelLength > 0;
  actnCopyP.Enabled := actnCutP.Enabled;
  actnPasteP.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDeleteP.Enabled := actnCutP.Enabled;

  actnCutNM.Enabled := DBMemo2.SelLength > 0;
  actnCopyNM.Enabled := actnCutNM.Enabled;
  actnPasteNM.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDeleteNM.Enabled := actnCutNM.Enabled;

  actnCutMail.Enabled := DBMemoMail.SelLength > 0;
  actnCopyMail.Enabled := actnCutMail.Enabled;
  actnPasteMail.Enabled := ClipBoard.HasFormat(CF_Text);
  actnDeleteMail.Enabled := actnCutMail.Enabled;
end;

procedure TForm1.actnUndoUpdate(Sender: TObject);
begin
  actnUndo1.Enabled := History1.CanUndo;
  actnRedo1.Enabled := History1.CanRedo;
  actnUndo2.Enabled := History2.CanUndo;
  actnRedo2.Enabled := History2.CanRedo;
  actnUndo3.Enabled := History3.CanUndo;
  actnRedo3.Enabled := History3.CanRedo;
  actnUndo4.Enabled := History4.CanUndo;
  actnRedo4.Enabled := History4.CanRedo;
  actnUndoP.Enabled := HistoryP.CanUndo;
  actnRedoP.Enabled := HistoryP.CanRedo;
  actnUndoNM.Enabled := HistoryNM.CanUndo;
  actnRedoNM.Enabled := HistoryNM.CanRedo;
  actnUndoMail.Enabled := HistoryMail.CanUndo;
  actnRedoMail.Enabled := HistoryMail.CanRedo;
end;

procedure TForm1.LerContAll(OrderBy: string);
begin
  QContAll.Close;
  if Edit4.Text = '' then
    QContAll.SQL.Text := 'Select * from ContatosTB ' + OrderBy
  else
    QContAll.SQL.Text :=
      'SELECT distinct ID_Contato,Nome,Email,Celular,Obs FROM ContatosTB where ((ContatosTB.Nome like "%'+
      Edit4.Text+'%") or (ContatosTB.Email like "%' + Edit4.Text + '%")) ' +
      'UNION SELECT distinct ID_Contato,Nome,Email,Celular,Obs FROM ContatosTB INNER JOIN (MarcsContTB INNER JOIN '+
      'ContMarcTBm ON MarcsContTB.ID_Marc = ContMarcTBm.MarcID) ON ContatosTB.ID_Contato = ContMarcTBm.ContID ' +
      'WHERE (MarcsContTB.Marcador Like "%' + Edit4.Text + '%") ' + OrderBy;
  QContAll.Open;
  LerMarcsCont();
end;

procedure TForm1.LerContProj(OrderBy: string);
var
  S: string;
begin
  QContProj.Close;
  if Edit5.Text = '' then
    S := ''
  else
    S := ' and (ContatosTB.Nome like "%' + Edit5.Text + '%") ';
  QContProj.SQL.Text :=
    'Select ContatosTB.Nome,ContatosTB.Email,ContatosTB.Celular,ContatosTB.OBS,ContatosTB.ID_Contato '+
    'from ContatosTB inner join ProjContTBm on ContatosTB.ID_Contato=ProjContTBm.ContID '+
    'WHERE (((ProjContTBm.ProjID)=' + IntToStr(QProj.FieldByName('ID_Proj').AsInteger) + ') '+S+') '+OrderBy;
  QContProj.Open;
  ColorSpeedButton9.Caption := 'Contatos (' + IntToStr(QContProj.RecordCount) +
    '/' + IntToStr(QContAll.RecordCount) + ')';
end;

procedure TForm1.AddMarker(Sender: TObject);
var
  ProjContID, S, TB, TBm, M, P, ID: string;
  Repetido: boolean;
begin
  if QProj.IsEmpty then Exit;
  if (Sender = ATButton7) or (Sender = DBGrid3) then
  begin
    TB := 'MarcsProjTB';
    TBm := 'ProjMarcTBm';
    ID := 'ID_Proj';
    ProjContID := 'ProjID';
    P := IntToStr(QProj.Fields[0].AsInteger);
  end;

  if (Sender = ATButton62) or (Sender = DBGrid1) then
  begin
    TB := 'MarcsContTB';
    TBm := 'ContMarcTBm';
    ;
    ID := 'ID_Contato';
    ProjContID := 'ContID';
    P := IntToStr(QContAll.Fields[0].AsInteger);
  end;
  QTemp.Close;
  QTemp.SQL.Text := 'Select Marcador from ' + TB + ' order by Marcador Desc';
  QTemp.Open;
  FormInsMarker.ComboBox1.Items.Clear;
  FormInsMarker.ComboBox1.Text := '';
  while not QTemp.EOF do
  begin
    FormInsMarker.ComboBox1.Items.Add(QTemp.Fields[0].AsString);
    QTemp.Next;
  end;
  FormInsMarker.Label1.Caption := rs_LabelMarkNome;

  if FormInsMarker.ShowModal <> mrOk then Exit;

  S := FormInsMarker.ComboBox1.Text;

  Repetido := False;
  //if Sender=ATButton7 then
  // if QMarcProj.Locate('Marcador',S,[]) then
  //  Repetido:=True;
  if Sender = ATButton62 then
    if QMarcCont.Locate('Marcador', S, []) then
      Repetido := True;

  if not Repetido then
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'INSERT INTO ' + TB + ' (Marcador) values ("' + S + '") ';
    QTemp.ExecSQL;
  end;
  QTemp.Close;
  QTemp.SQL.Text := 'Select ID_Marc,Marcador from ' + TB;
  QTemp.Open;
  QTemp.Locate('Marcador', S, []);
  M := IntToStr(QTemp.Fields[0].AsInteger);
  QTemp.Close;
  QTemp.SQL.Text := 'Select MarcID,' + ProjContID + ' from ' + TBm + ' where MarcID=' + M +
    ' and ' + ProjContID + '=' + P;
  QTemp.Open;
  if QTemp.IsEmpty then
  begin
    QTemp1.Close;
    QTemp1.SQL.Text := 'INSERT INTO ' + TBm + ' (' + ProjContID + ',MarcID) values (' + P + ',' + M + ') ';
    QTemp1.ExecSQL;
  end;
  QProj.Close;
  QProj.Open;
  AbrirProj();
  LerMarcsCont();
end;

//Filtro dos marcadores de contatos
procedure TForm1.ATButton15Click(Sender: TObject);
var
  i, j: integer;
  S: string;
begin
  FormMarc.Caption := rs_FiltCont;
  FormMarc.ATButton1.Visible := False;
  FormMarc.ATButton2.Visible := False;
  FormMarc.ATButton15.Visible := False;
  FormMarc.CLB.Clear;
  QTemp.Close;
  QTemp.SQL.Text := 'Select distinct Marcador from MarcsContTB order by Marcador COLLATE NOCASE';
  QTemp.Open;
  while not QTemp.EOF do
  begin
    FormMarc.CLB.Items.Add(QTemp.FieldByName('Marcador').AsString);
    QTemp.Next;
  end;

  ATButton15.Checkable := False;

  if ATButton15.Checked then
  begin
    QContAll.Close;
    QContAll.SQL.Text := 'Select * from ContatosTB';
    QContAll.Open;
    ATButton15.Checked := False;
    Exit;
  end;

  j := 0;

  FormMarc.Filtro := True;

  if FormMarc.ShowModal <> mrOk then
  begin
    ATButton15.Checked := False;
    Exit;
  end
  else
  begin
    S := '';
    for i := 0 to FormMarc.CLB.Items.Count - 1 do
      if FormMarc.CLB.Checked[i] = True then
      begin
        S := S + ' ((MarcsContTB.Marcador)="' + FormMarc.CLB.Items[i] + '") OR ';
        j := j + 1;
      end;
    S := Copy(S, 1, Length(S) - 3);
    if j = 0 then
    begin
      ATButton15.Checked := False;
      Exit;
    end
    else
    begin
      //  S:='SELECT distinct * '+ //Não funciona. Tem que discriminar todos os campos.
      S := 'SELECT distinct ContatosTB.ID_Contato,ContatosTB.Nome, ContatosTB.Email, ContatosTB.Celular,ContatosTB.Obs  '
        + 'FROM ContatosTB INNER JOIN (MarcsContTB INNER JOIN ContMarcTBm ON MarcsContTB.ID_Marc = ContMarcTBm.MarcID) ON ContatosTB.ID_Contato = ContMarcTBm.ContID ' + ' WHERE (' + S + ' ) order by ContatosTB.Nome COLLATE NOCASE';
      QContAll.Close;
      QContAll.SQL.Text := S;
      QContAll.Open;
      ATButton15.Checked := True;
    end;
  end;
end;

procedure TForm1.OrgMarker(Sender: TObject);
var
  TB, TBm, ProjMarcID: string;
  P, M: integer;
begin
  if (Sender = ATButton10) or (Sender = DBGrid3) then
  begin
    FormMarc.Caption := rs_AttMarcProj;
    TB := 'MarcsProjTB';
    ;
    TBm := 'ProjMarcTBm';
    ;
    ProjMarcID := 'ProjID';
    P := QProj.Fields[0].AsInteger;
  end;
  if (Sender = ATButton55) or (Sender = DBGrid1) then
  begin
    FormMarc.Caption := rs_AttMarcCont;
    TB := 'MarcsContTB';
    TBm := 'ContMarcTBm';
    ProjMarcID := 'ContID';
    P := QContAll.Fields[0].AsInteger;
  end;
  FormMarc.CLB.Clear;
  QTemp1.Close;
  //distinct não funciona. Group by funciona.
  //QTemp1.SQL.Text:='Select distinct '+TB+'.Marcador from '+TB+' order by '+TB+'.Marcador COLLATE NOCASE ASC';
  QTemp1.SQL.Text := 'Select * from ' + TB + ' group by ' + TB + '.Marcador order by ' +
    TB + '.Marcador COLLATE NOCASE ASC';
  QTemp1.Open;

  //Aqui apaga TBm para preencher de novo depois do ShowModal, mas se não
  //tiver modalresult, não preenche de novo e fica vazio...
  while not QTemp1.EOF do
  begin
    QTemp.Close;
    QTemp.SQL.Text := 'Select * from ' + TBm;
    QTemp.Open;
    FormMarc.CLB.Items.Add(QTemp1.FieldByName('Marcador').AsString);
    M := QTemp1.Fields[0].AsInteger;
    if QTemp.Locate('MarcID;' + ProjMarcID, VarArrayOf([M, P]), []) then
    begin
      FormMarc.CLB.Checked[FormMarc.CLB.Items.Count - 1] := True;
      //Tem que ser ExecuteDirect
      Conn.ExecuteDirect('Delete from ' + TBm + ' where (MarcID=' + IntToStr(
        M) + ') and (' + ProjMarcID + '=' + IntToStr(P) + ')');
    end;
    QTemp1.Next;
  end;

  //...Por isso, manda os parâmetros para o FormMarc e preenche de novo no onClose do FormaMarc
  FormMarc.fTB := TB;
  FormMarc.fTBm := TBm;
  FormMarc.fProjMarcID := ProjMarcID;
  FormMarc.fP := P;
  FormMarc.fM := M;

  if FormMarc.CLB.Items.Count > 0 then
    FormMarc.CLB.ItemIndex := 0;

  FormMarc.Filtro := False;
  FormMarc.ATButton1.Visible := True;
  FormMarc.ATButton2.Visible := True;
  FormMarc.ATButton15.Visible := True;

  FormMarc.ShowModal;

  AbrirProj();
  LerMarcsCont();
end;

procedure TForm1.LerMarcsProj();
begin
  QMarcProj.Close;
  QMarcProj.SQL.Text :=
    'SELECT MarcsProjTB.Marcador as Marcador, MarcsProjTB.ID_Marc FROM MarcsProjTB INNER JOIN ProjMarcTBm ON MarcsProjTB.ID_Marc = ProjMarcTBm.MarcID ' + 'WHERE (((ProjMarcTBm.ProjID)=' + IntToStr(QProj.FieldByName('ID_Proj').AsInteger) + ')) ORDER BY MarcsProjTB.Marcador COLLATE NOCASE ASC';
  QMarcProj.Open;
  QMarcProj.Fields[1].Visible := False;
end;


procedure TForm1.LerMarcsCont();
begin
  //Marcadores dos Contatos
  if not QContAll.IsEmpty then
  begin
    QMarcCont.Close;
    QMarcCont.SQL.Text :=
      'SELECT MarcsContTB.Marcador as Marcador, MarcsContTB.ID_Marc FROM MarcsContTB INNER JOIN ContMarcTBm ON MarcsContTB.ID_Marc = ContMarcTBm.MarcID ' + 'WHERE (((ContMarcTBm.ContID)=' + IntToStr(QContAll.FieldByName('ID_Contato').AsInteger) + ')) ORDER BY MarcsContTB.Marcador COLLATE NOCASE ASC';
    QMarcCont.Open;
  end;
end;

//Busca de texto em TMemo. Ficou lindo!
//http://lazplanet.blogspot.com/2013/04/search-text-all-words.html (Bugado)
//Misturado com
//https://forum.lazarus.freepascal.org/index.php?topic=45066.0
function TForm1.MyFindInMemo(AMemo: TCustomMemo; AString: string; arr: integer): integer;
var
  s, target_s: string;
  i, searchstart: integer;
begin
  searchstart := SearchAfterPos[arr] + 1;
  s := UpperCase(AMemo.Text);
  target_s := UpperCase(AString);
  i := PosEx(target_s, s, searchstart);
  if (i > 0) then
  begin
    AMemo.SelStart := UTF8Length(PChar(AMemo.Text), i - 1);
    AMemo.SelLength := length(target_s);
    AMemo.SetFocus;
    SearchAfterPos[arr] := i + Length(target_s) - 1;
  end
  else
  begin
    SearchAfterPos[arr] := 0;
  end;
end;

procedure TForm1.LerEmail(OrderBy: string);
var
  S,x: string;
begin
  x:='R';
  if ColorSpeedButton17.Down then x:=' and ER="R" ' else
   if ColorSpeedButton34.Down then x:=' and ER="E" ' else
    if ColorSpeedButton37.Down then x:=' and ER="L" ' else
     if ColorSpeedButton39.Down then x:=' '; //Todos

  QMail.Close;
  if Edit8.Text = '' then
    S := ''
  else
    S := ' and ((DePara like "%' + Edit8.Text + '%") or (Assunto like "%' +
      Edit8.Text + '%") or (Msg like "%' + Edit8.Text + '%")) ';
  QMail.SQL.Text := 'Select * from MailsTB where ProjID=' + IntToStr(
    QProj.FieldByName('ID_Proj').AsInteger) +x+ S + OrderBy;
  QMail.Open;
end;

procedure TForm1.LerRascuCont();
begin
  QRascuCont.Close;
  QRascuCont.SQL.Text := 'Select * from RascuContTB where RascuID=' +
    IntToStr(QRascu.Fields[0].AsInteger);
  QRascuCont.Open;
  ListBox1.Clear;
  while not QRascuCont.EOF do
  begin
    ListBox1.Items.Append(QRascuCont.FieldByName('Nome').AsString + '<' +
      QRascuCont.FieldByName('Email').AsString + '>');
    QRascuCont.Next;
  end;
end;

function TForm1.RemoveAspasDuplas(S: string): string;
var
  i: integer;
begin
  for i := 1 to length(S) - 1 do
    if Pos('"', S) > 0 then Delete(S, Pos('"', S), 1);
  Result := S;
end;

procedure TForm1.btnClickEvent(Sender: TObject);
begin
  OpenDocument(PastaProjAtual+PathDelim+ExtractFileName((Sender as TControl).Hint));
end;

procedure TForm1.LerRascu();
begin
  QRascu.Close;
  QRascu.SQL.Text := 'Select * from RascuTB';
  QRascu.Open;
  LerRascuCont();
  LerRascuAnx();
end;

procedure TForm1.LerRascuAnx();
begin
  QRascuAnx.Close;
  QRascuAnx.SQL.Text := 'Select * from RascuAnxTB where RascuID=' + IntToStr(
    QRascu.Fields[0].AsInteger);
  QRascuAnx.Open;
  ListBox2.Clear;
  while not QRascuAnx.EOF do
  begin
    ListBox2.Items.Append(QRascuAnx.FieldByName('Anexo').AsString);
    QRascuAnx.Next;
  end;
end;

procedure TForm1.AtualizarAnalogico(x: integer);
var
  Center: TPoint;
  Radius: integer;
  Bitmap: TBitmap;
begin
  //Timer analógico
  Bitmap := TBitmap.Create;
  Bitmap.Width := Image6.Width;
  Bitmap.Height := Image6.Height;
  Bitmap.PixelFormat := pf24bit;
  Bitmap.HandleType := bmDIB;
  //Bitmap.Canvas.Brush.Color := clBlack;
  Bitmap.TransparentColor := clBlack;
  Bitmap.Transparent := True;
  Bitmap.Canvas.Pen.Color := clHighlight;
  Bitmap.Canvas.Pen.Width := 10;
  Center := Point(Bitmap.Width div 2, Bitmap.Height div 2);
  Radius := 75;
  DrawPieSlice(Bitmap.Canvas, Center, Radius, 0, round(x * -3.6));
  Image6.Picture.Graphic := Bitmap;
  Bitmap.Free;
end;

procedure TForm1.FillCalendChose(); //É chamado nos botões Delete e Edit da Agenda
var
  SelProjs: string;
begin
  if not CheckBox4.Checked then
    SelProjs := ' and (ProjID=' + QProj.Fields[0].AsString + ') '
  else
    SelProjs := '';

  FormCalendChose.QAgChose.Close;
  FormCalendChose.QAgChose.SQL.Text :=
    'Select ID_Agenda,Data,Evento from AgendaTB where (Data >= ' +
    DTtoJulian(0, YearOf(DDate), MonthOf(DDate), DayOf(DDate), 0, 0, 0, 0) + ') and (Data <= ' +
    DTtoJulian(0, YearOf(DDate), MonthOf(DDate), DayOf(DDate), 23, 59, 59, 0) +
    ') ' + SelProjs + ' order by Data Desc';
  FormCalendChose.QAgChose.Open;
  if FormCalendChose.QAgChose.IsEmpty then Abort;
  //Tem que ser Abort, pois para também o Proc que o chamou.
  if FormCalendChose.QAgChose.RecordCount = 1 then PassaDireto := True
  else
    PassaDireto := False;
end;

function TForm1.DTtoJulian(D: System.TDateTime; Ano, Mes, Dia, H, Mn, Seg, mS: word): string;
var
  Dt: System.TDateTime;
begin
  DecimalSeparator := '.'; //Fica assim para sempre?
  if D <> 0 then
  begin
    Result := FloatToStr(DateTimeToJulianDate(D));
  end
  else
  begin
    Dt := EncodeDateTime(Ano, Mes, Dia, H, Mn, Seg, mS);
    Result := FloatToStr(DateTimeToJulianDate(Dt));
  end;
end;

procedure TForm1.LerAgendaMes();
var
  Y, M, D, H, Min: word;
  Ms, Ds, Hs, Mins: string;
  SelProjs: string;
begin
  if not CheckBox4.Checked then
    SelProjs := ' and (ProjID=' + QProj.Fields[0].AsString + ') '
  else
    SelProjs := '';

  Y := YearOf(DDate);
  M := MonthOf(DDate);
  if M <= 9 then Ms := '0' + IntToStr(M)
  else
    Ms := IntToStr(M);
  QAgenda.Close;
  QAgenda.SQL.Text := 'Select * from AgendaTB where (Data >= ' +
    DTtoJulian(0, Y, M, 1, 0, 0, 0, 0) + ') and (Data <= ' +
    DTtoJulian(0, Y, M, DaysInAMonth(Y, M), 23, 59, 59, 0) + ') ' + SelProjs + ' order by Data Desc';
  QAgenda.Open;
  HoldSelect.Clear;
  //É este Hold que vai guardar as informações que serão lidas a jato no OnDrawCell
  while not QAgenda.EOF do
  begin
    D := DayOf(QAgenda.FieldByName('Data').AsDateTime);
    if D <= 9 then Ds := '0' + IntToStr(D)
    else
      Ds := IntToStr(D);
    H := HourOf(QAgenda.FieldByName('Data').AsDateTime);
    if H <= 9 then Hs := '0' + IntToStr(H)
    else
      Hs := IntToStr(H);
    Min := MinuteOf(QAgenda.FieldByName('Data').AsDateTime);
    if Min <= 9 then Mins := '0' + IntToStr(Min)
    else
      Mins := IntToStr(Min);
    HoldSelect.Strings.Add(IntToStr(Y) + Ms + Ds + 'T' + Hs + Mins + ' ' + QAgenda.FieldByName(
      'Evento').AsString);
    QAgenda.Next;
  end;
  Panel93.Caption := IntToStr(DayOf(DDate)) + ' ' + IntToMes(MonthOf(DDate)) +
    ' ' + IntToStr(YearOf(DDate));
  DCal.Invalidate; //Recalcula OnDrawCell
  MemTempX.Lines := HoldSelect.Strings;

end;

function TForm1.IntToMes(i: integer): string;
var
  S: string;
begin
  case i of
    1: S := rs_Jan;
    2: S := rs_Fev;
    3: S := rs_Mar;
    4: S := rs_Abr;
    5: S := rs_Mai;
    6: S := rs_Jun;
    7: S := rs_Jul;
    8: S := rs_Ago;
    9: S := rs_Set;
    10: S := rs_Out;
    11: S := rs_Nov;
    12: S := rs_Dez;
  end;
  Result := S;
end;

procedure TForm1.AjeitarTamanhoColunasAgenda;
var
  i, h, w: integer;
begin
  w := DCal.Width div 7;
  h := DCal.Height div 7;
  for i := 0 to 6 do
  begin
    DCal.ColWidths[i] := w;
    DCal.RowHeights[i] := h;
  end;
end;

procedure TForm1.Salvar_Tl();
begin
  QTl.Close;
  QTl.SQL.Text := 'Select ProjID,Dia,Tempo from TimeLineTB where (ProjID=' +
    IntToStr(ProjAnterior) + ') and (Dia=' + DTToJulian(Date, 0, 0, 0, 0, 0, 0, 0) + ')';
  QTl.Open;
  if QTl.IsEmpty then QTl.Insert
  else
    QTl.Edit;
  QTl.Fields[0].AsInteger := ProjAnterior;
  QTl.Fields[1].AsDateTime := Date; //Tem que ter porque se estiver vazia será Insert
  QTl.Fields[2].AsInteger := QTl.Fields[2].AsInteger + TLTime;
  QTl.Post;
  TLTime := 0; //Zerando o acumulador
  TL.Enabled := False; //Abrindo e fechando para começar de novo
  TL.Enabled := True;
end;

procedure TForm1.Ler_Tl();
var
  Ano, Mes, Dia, n, i, j: integer;
  S, S1, anoS, mesS, diaS: string;
  dt, d: System.TDateTime;
  Cc: boolean;
begin
  if ComboBox1.Text = 'pt-br Português Brasil' then
  begin
    SGTl.Cells[0, 1] := 'D';
    SGTl.Cells[0, 2] := 'S';
    SGTl.Cells[0, 3] := 'T';
    SGTl.Cells[0, 4] := 'Q';
    SGTl.Cells[0, 5] := 'Q';
    SGTl.Cells[0, 6] := 'S';
    SGTl.Cells[0, 7] := 'S';
  end;
  if ComboBox1.Text = 'en-us English EUA' then
  begin
    SGTl.Cells[0, 1] := 'S';
    SGTl.Cells[0, 2] := 'M';
    SGTl.Cells[0, 3] := 'T';
    SGTl.Cells[0, 4] := 'W';
    SGTl.Cells[0, 5] := 'T';
    SGTl.Cells[0, 6] := 'F';
    SGTl.Cells[0, 7] := 'S';
  end;

  if RadioButton7x.Checked then
    S1 := ' and (ProjID=' + IntToStr(ProjAtual) + ')'
  else
    S1 := '';
  QTl.Close;
  QTl.SQL.Text := 'Select ProjID,Dia,Tempo from TimeLineTB where (strftime(''%Y'',Dia)="' +
    ListBox1x.Items[ListBox1x.ItemIndex] + '") ' + S1; //Aspas antes do ano são fundamentais
  QTl.Open;

  HoldTL.Strings.Clear;
  //SGTl.Clean; //Se botar não aparece o dia da semana.
  while not QTl.EOF do
  begin
    Dt := QTl.Fields[1].AsDateTime;
    Ano := YearOf(Dt);
    AnoS := IntToStr(Ano);
    Mes := MonthOf(Dt);
    Dia := DayOf(Dt);
    if Mes <= 9 then mesS := '0' + IntToStr(Mes)
    else
      mesS := IntToStr(Mes);
    if Dia <= 9 then diaS := '0' + IntToStr(Dia)
    else
      diaS := IntToStr(Dia);
    //2021/05/11=24000 É assim que fica no HoldTL
    HoldTL.Strings.Add(AnoS + '/' + MesS + '/' + DiaS + '=' + QTl.FieldByName('Tempo').AsString);
    QTl.Next;
  end;

  Ano := StrToInt(ListBox1x.Items[ListBox1x.ItemIndex]);
  d := EncodeDate(Ano, 1, 1);
  n := DayOfWeek(d);
  SGTl.Font.Size := 7;

  for j := 1 to 53 do
  begin
    Cc := False;
    for i := n to 7 do
    begin
      SGTl.Cells[j, i] := IntToStr(DayOf(d));
      if DayOf(d) = 7 then
      begin
        Cc := True;
        S := IntToLetra(d);
      end
      else
      begin
        S1 := IntToLetra(d);
      end;
      d := d + 1;
    end;
    if Cc then SGTl.Cells[j, 0] := S
    else
      SGTl.Cells[j, 0] := S1;
    n := 1;
  end;
end;

function TForm1.IntToLetra(M: System.TDate): string;
var
  Mn: integer;
  Ms: string;
begin
  Mn := MonthOf(M);
  if Mn = 1 then Ms := 'J';
  if Mn = 2 then Ms := 'F';
  if Mn = 3 then Ms := 'M';
  if Mn = 4 then Ms := 'A';
  if Mn = 5 then Ms := 'M';
  if Mn = 6 then Ms := 'J';
  if Mn = 7 then Ms := 'J';
  if Mn = 8 then Ms := 'A';
  if Mn = 9 then Ms := 'S';
  if Mn = 10 then Ms := 'O';
  if Mn = 11 then Ms := 'N';
  if Mn = 12 then Ms := 'D';
  Result := Ms;
end;

procedure TForm1.AtlzRegRascu();
var
  i, n: integer;
begin
  i := QRascu.RecordCount;
  n := QRascu.RecNo;
  Label30.Caption := IntToStr(n) + '/' + IntToStr(i);
end;

procedure TForm1.DoUserConsentGmail(const AURL: string; Out AAuthCode: string);
var S:String;
begin
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
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

procedure TForm1.DoUserConsentDrive(const AURL: string; Out AAuthCode: string);
var S:String;
begin
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
end;

procedure TForm1.TVFoldersSelectionChanged(Sender: TObject);
begin
  if (TVFolders.Selected=Nil) or (TVFolders.Selected.Data=Nil) then
    ShowFolder('root')
  else
    ShowFolder(TFile(TVFolders.Selected.Data).ID);
end;

procedure TForm1.ClearFileListView;
Var
  I : Integer;
begin
  With LVFiles.Items do
    begin
    BeginUpdate;
    try
      For I:=0 to Count-1 do
        TObject(Item[i].Data).Free;
      Clear;
    finally
      EndUpdate;
    end;
    end;
end;

procedure TForm1.ShowFolder(AFolderID : String);
var
  Entry: TFile;
  EN,es : String;
  i:integer;
  Q : TFilesListOptions;
  List : TFileList;
  Resource : TFilesResource;
  LI : TListItem;
begin
  ClearFileListView;
  Resource:=Nil;
  try
    Resource:=FDriveAPI.CreateFilesResource(Self);
    // Search for files of indicated folder only.
    Q.q:='mimeType != ''application/vnd.google-apps.folder'' and '''+AFolderId+''' in parents and trashed=false';
    Q.corpus:='';
    Q.pageToken:='';
    Q.pageSize:=50;
    Q.fields:='files(name,size,modifiedTime)';
    List:=Resource.list(Q);
    SaveRefreshToken('Drive');
    With LVFiles.Items do
      begin
      BeginUpdate;
      try
        Clear;
        if Assigned(List) then
          for i:= 0 to Length(List.files)-1 do
            begin
            Entry:=List.files[i];
            List.files[i]:=Nil;
            LI:=Add;
            LI.Caption:=ExtractFileName(Entry.Name);
            With LI.SubItems do
              begin
               es:=Entry.size;
               if es<>'' then
               begin
                if StrToInt(es)<1000 then Add(es+' kB') else
                if StrToInt(es)<1000000 then Add(FloatToStrF(StrToInt(es)/1000,ffFixed,8,1)+' kB') else
                 if StrToInt(es)<1000000000 then Add(FloatToStrF(StrToInt(es)/1000000,ffFixed,8,1)+' MB') else
                  if StrToInt(es)<1000000000000 then Add(FloatToStrF(StrToInt(es)/1000000000,fffixed,8,1)+' GB') else
               end else Add(' ');
               Add(ExtractFileExt(Entry.Name));
               Add(DateTimeToStr(Entry.modifiedTime));
              end;
            Li.Data:=Entry;
            end;
      finally
        EndUpdate;
      end;
      end;
  Finally
    Resource.Free;
  end;
end;

procedure TForm1.DoUserConsentPeop(const AURL: string; Out AAuthCode: string);
var S:String;
begin
//  try
  OpenUrl(AURL);
  if InputQuery('Entre com o código','Código do Google',S) then AAuthCode := S;
{  except on exception do begin
   ShowMessage('Falhou e as chaves de acesso serão reiniciadas.');
   QTemp.SQL.Text:='update ConfigTB set RefreshTokenPeop=""';
   QTemp.ExecSQL;
   QTemp.SQL.Text:='update ConfigTB set AccessTokenPeop=""';
   QTemp.ExecSQL;
  end;
  end;
}end;

procedure TForm1.TVGmailSelectionChanged(Sender: TObject);
begin
//  Screen.Cursor:=crHourGlass;
Memo5.Clear;
BRefreshFilesClick(Sender);
//  Screen.Cursor:=crDefault;
end;

procedure TForm1.LoadAuthConfig(scope: string);
var
  S: string;
  F: TGoogleClient;
begin
  if scope='Cal' then F:=FClientCal else
   if scope='Tasks' then F:=FClientTasks else
    if scope='Peop' then F:=FClientPeop else
     if scope='Gmail' then F:=FClientGmail else
      if scope='Drive' then F:=FClientDrive;


  F.AuthHandler.Config.ClientID := ConfigLerStr('ConfigTB', 'ClientId');
  F.AuthHandler.Config.ClientSecret := ConfigLerStr('ConfigTB', 'ClientSecret');

  if scope = 'Tasks' then S := 'https://www.googleapis.com/auth/tasks' else
   if scope = 'Cal' then S := 'https://www.googleapis.com/auth/calendar' else
    if scope = 'Peop' then S := 'https://www.googleapis.com/auth/contacts' else
     if scope = 'Gmail' then S := 'https://mail.google.com/' else
      if scope = 'Drive' then S := 'https://www.googleapis.com/auth/drive';

  F.AuthHandler.Config.AuthScope := S;
  F.AuthHandler.Config.RedirectUri := 'urn:ietf:wg:oauth:2.0:oob';
  F.AuthHandler.Session.RefreshToken := ConfigLerStr('ConfigTB', 'RefreshToken' + scope);
  F.AuthHandler.Session.AccessToken := ConfigLerStr('ConfigTB', 'AccessToken' + scope);
  F:=nil;
end;

procedure TForm1.SaveRefreshToken(scope: string);
begin
if scope='Gmail' then
 if FClientGmail.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope, FClientGmail.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientGmail.AuthHandler.Session.AccessToken);
 end;
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
if scope='Drive' then
 if FClientDrive.AuthHandler.Session.RefreshToken <> '' then begin
  ConfigSalvarStr('ConfigTB', 'RefreshToken' + scope,  FClientDrive.AuthHandler.Session.RefreshToken);
  ConfigSalvarStr('ConfigTB', 'AccessToken' + scope,  FClientDrive.AuthHandler.Session.AccessToken);
 end;

//   ConfigSalvarStr('ConfigTB','AuthTokenType',FClient.AuthHandler.Session.AuthTokenType);
// ConfigSalvarStr('ConfigTB','AuthExpires',FClient.AuthHandler.Session.AuthExpires);
//   ConfigSalvarInt('ConfigTB','AuthExpiryPeriod',FClient.AuthHandler.Session.AuthExpiryPeriod);
end;

function TForm1.ExtDiaSemana(D:System.TDate): String;
var S:String;
i: integer;
begin
i:=DayOfWeek(EncodeDate(YearOf(D),MonthOf(D),DayOf(D)));
case i of
 1: S:=rs_Domingo;
 2: S:=rs_Segunda;
 3: S:=rs_Terca;
 4: S:=rs_Quarta;
 5: S:=rs_Quinta;
 6: S:=rs_Sexta;
 7: S:=rs_Sabado;
end;
 result:=S;
end;

procedure TForm1.panCalMouseEnter(Sender: TObject);
begin
(Sender as TPanel).Color:=clSilver;
end;

procedure TForm1.panCalMouseLeave(Sender: TObject);
begin
(Sender as TPanel).Color:=$0046A25E;
end;


//https://lists.lazarus-ide.org/pipermail/lazarus/2020-June/238085.html
procedure TForm1.panCalDoubleClick(Sender: TObject);
var
  Entry, Insert: TEvent;
  start_e, end_e: TEventDateTime;
  D: System.TDate;
  id: String;
begin
if LBCalGoo.ItemIndex < 0 then Exit;
id:=(Sender as TPanel).Hint;
QTemp.Close;
QTemp.SQL.Text:='select id,data_ini,data_fim,desc,suma from AuxCalGoo where id="'+id+'"';
QTemp.Open;
FormCalend.ColorSpeedButton1.Visible:=True;
FormCalend.Edit1.Text:=QTemp.Fields[3].AsString;
FormCalend.Memo1.Text:=QTemp.Fields[4].AsString;
FormCalend.DTP1.Date:=QTemp.Fields[1].AsDateTime;
FormCalend.SpinEdit1.Value:=HourOf(QTemp.Fields[1].AsDateTime);
FormCalend.SpinEdit2.Value:=MinuteOf(QTemp.Fields[1].AsDateTime);
if HourOf(QTemp.Fields[1].AsDateTime)=0 then
 FormCalend.CheckBox1.Checked:=True else
  FormCalend.CheckBox1.Checked:=False;
case FormCalend.ShowModal of
 mrYes: begin
  //Apagar
   Screen.Cursor:=crHourGlass;
   FCalendarAPI.EventsResource.Delete(FCurrentCalendar.id,(Sender as TPanel).Hint);
   LBCalGooSelectionChange(Self,False);
   Screen.Cursor:=crDefault;
   Exit;
 end;
 mrOk: begin
  Screen.Cursor:=crHourGlass;
  start_e := TEventDateTime.Create();
  end_e := TEventDateTime.Create();
  D:=FormCalend.DTP1.Date;

  if FormCalend.CheckBox1.Checked then begin
   start_e.datetime:=EncodeDateTime(YearOf(D), MonthOf(D), DayOf(D),0,0,0,0);
   end_e.datetime := start_e.datetime;
   end else begin
    start_e.dateTime := EncodeDateTime(YearOf(D), MonthOf(D), DayOf(D), FormCalend.SpinEdit1.Value, FormCalend.SpinEdit2.Value, 0, 0);
    end_e.dateTime := IncHour(start_e.dateTime, 1);
   end;
  //start_e.timeZone := 'Europe/London'; //Não funciona
  //end_e.timeZone := 'Europe/London';  //Não funciona
  start_e.dateTime:=IncHour(start_e.dateTime, 3); //Nossa timezone
  end_e.dateTime:=IncHour(end_e.dateTime, 3); //Nossa timezone
  Entry := TEvent.Create();
  Entry.summary := FormCalend.Edit1.Text;
  Entry.description := FormCalend.Memo1.Text;
  Entry.start := start_e;
  Entry._end := end_e;
  Insert := FCalendarAPI.EventsResource.Update(FCurrentCalendar.id, id, Entry,'');
  SaveRefreshToken('Cal');
  Entry.Free;
  Entry := nil;
  Insert.Free;
  Insert := nil;
  FormCalend.ColorSpeedButton1.Visible:=False;
  LBCalGooSelectionChange(Self,False);
  Screen.Cursor:=crDefault;
 end;
 mrCancel: Exit;
 end;

end;

//Vim do W
procedure TForm1.MemTarKeyPress(Sender: TObject; var Key: char);
begin
(Sender as TMemo).Font.Style:=[fsItalic];
ColorSpeedButton80.Caption:='Atualizar';
end;

procedure TForm1.MemTarOnExit(Sender: TObject);
begin
(Sender as TMemo).Color:=clDefault;
end;

procedure TForm1.MemTarOnEnter(Sender: TObject);
begin
MemoTarGooStr:=(Sender as TMemo).Hint;
MemoTarGooInt:=(Sender as TMemo).Tag;
(Sender as TMemo).Color:=$00EFEFEF;
end;

procedure TForm1.ClearTreeViewGmail;
var
  i: Integer;
begin
  With TVGmail.Items do
    begin
    BeginUpdate;
    try
      For I:=0 to Count-1 do
        TObject(Item[i].Data).Free;
      Clear;
    finally
      EndUpdate;
    end;
    end;
end;

procedure TForm1.ClearTreeViewDrive;
var
  i: Integer;
begin
  With TVFolders.Items do
   begin
    BeginUpdate;
    try
      For I:=0 to Count-1 do
        TObject(Item[i].Data).Free;
      Clear;
    finally
      EndUpdate;
    end;
   end;
end;

procedure TForm1.AddLabels; //Gmail
var
  EF,Entry: googlegmail.TLabel;
  Resource: TUsersLabelsResource;
  EN: String;
  List : TListLabelsResponse;
  i: Integer;
  PN,N: TTreeNode;
  ShowThisLabel: boolean;
begin
  Screen.Cursor:=crHourGlass;
  Resource:=Nil;
  List:=Nil;
  Entry:=Nil;
  try
    try
      Resource:=FGmailAPI.CreateUsersLabelsResource(Self);
    except on exception do begin
      MessageDlg('É necessário solicitar nova autorização ao Google!',mtError,[mbOk],0);
      ConfigSalvarStr('ConfigTB', 'accessTokenCal', '');
      ConfigSalvarStr('ConfigTB', 'refreshTokenCal', '');
      Screen.Cursor:=crDefault;
      Panel127.Width:=45;
      Exit;
      end;
    end;
    // Search for folders of indicated folder only.
    List:=Resource.list('me');
    SaveRefreshToken('Gmail');
    With TVGmail.Items do
      begin
      BeginUpdate;
      try
        I:=0;
        if Assigned(List) then
          for Entry in List.Labels do
            begin
             List.Labels[i]:=Nil;
             Inc(I);
             ShowThisLabel:=False;
             Case lowercase(Entry.labelListVisibility) of
               'labelhide' : ShowThisLabel:=False;
               'labelshow' : ShowThisLabel:=True;
               'labelshowifunread' : ShowThisLabel:=Entry.messagesUnread>0; //Não muda nada
             end;
             if not ShowThisLabel then
              begin
               EF:=Entry;
               FreeAndNil(EF);
              end else
              begin
               N:=CreateNodeWithTextPath(Entry.Name);
               N.Data:=Entry;
              end;
            end;
       finally
         EndUpdate;
       end;
      end;
    Screen.Cursor:=crDefault;
    for i:=0 to TVGmail.Items.Count-1 do
     if TVGmail.Items[i].Text='INBOX' then begin
      // ShowLabelGmail(googlegmail.TLabel(TVGmail.Items[i].Data).id); Não precisa, pois é acionado automaticamente quando seleciona o item.
      TVGmail.Items[i].Selected:=True;
     end;
  finally
    FreeAndNil(List);
    FreeAndNil(Resource);
    Screen.Cursor:=crDefault;
  end;
end;

function TForm1.CreateNodeWithTextPath(TextPath: string): TTreeNode;
var
  p: SizeInt;
  CurText: String;
  AParent : TTreeNode;
begin
  Result:=nil;
  AParent:=Nil;
  repeat
    p:=System.Pos('/',TextPath);
    if p>0 then
      begin
      CurText:=LeftStr(TextPath,p-1);
      System.Delete(TextPath,1,p);
      end
    else
      begin
      CurText:=TextPath;
      TextPath:='';
      end;
    //debugln(['TTreeNodes.FindNodeWithTextPath CurText=',CurText,' Rest=',TextPath]);
    if AParent=nil then
      Result:=TVGmail.Items.FindTopLvlNode(CurText)
    else
      Result:=AParent.FindNode(CurText);
    if (Result=Nil) Then
      Result:=TVGmail.Items.AddChild(AParent,CurText);
    AParent:=Result;
  until (Result=nil) or (TextPath='');
end;

procedure TForm1.BRefreshFilesClick(Sender: TObject);
begin
  if (TVGmail.Selected=Nil) or (TVGmail.Selected.Data=Nil) then
//    ShowLabelGmail('root')  //Se deixar assim dá problema de Bad request
//   TVGmail.Items.Clear   //Se colocar isso dá um looping infinito
  else
   ShowLabelGmail(googlegmail.TLabel(TVGmail.Selected.Data).id);
//Screen.Cursor:=crDefault;
end;

procedure TForm1.ShowLabelGmail(ALabelID: String);
var
  Msg,Entry: Tmessage;
  EN : String;
  i,y:integer;
  Q : TUsersMessagesListOptions;
  Resource : TUsersMessagesResource;
  List : TListMessagesResponse;
  LI : TListItem;
  Desc : TMailDescription;
begin
  ClearMailListView;
  Resource:=Nil;
  try
    Resource:=FGmailAPI.CreateusersMessagesResource(Self);
    // Search for files of indicated folder only.
    Q.labelIds:=ALabelID;
    List:=Resource.list('me',Q);
    SaveRefreshToken('Gmail');
    y:=0;
    With LVMessages.Items do
      begin
  //    BeginUpdate;  Com isso não aparecem os email que entram on the fly.
      try
        Clear;
        if Assigned(List) then
          for Msg in List.messages do
            begin
            Inc(y);
            if y>TrackBar1.Position then Abort; //Limita número de emails
            Entry:=Resource.Get(Msg.id,'me','format=full');
            LI:=Add;
            CreateDescGmail(Entry,Desc);
            LI.Caption:=Desc.Subject;
            With LI.SubItems do
              begin
              Add(Desc.From);
              Add(Desc.Received);
              Add(Desc.Recipient);
              Add(Msg.id);
              //Add(Desc.Sender);
              Add(Desc.Snippet);
              end;
            Li.Data:=Entry;
          Application.ProcessMessages;
          Label16.Caption:='('+IntToStr(y)+'/'+IntToStr(TrackBar1.Position)+')';
            end;
      finally
  //      EndUpdate;  Com isso não aparecem os email que entram on the fly.
      end;
      end;
  finally begin
      Resource.Free;
  end;
  end;
end;

procedure TForm1.ClearMailListView;
var I : Integer;
begin
  With LVMessages.Items do
    begin
    BeginUpdate;
    try
      For I:=0 to Count-1 do
        TObject(Item[i].Data).Free;
      Clear;
    finally
      EndUpdate;
    end;
    end;
end;

procedure TForm1.AddFolders(AParent : TTreeNode; AFolderID : String);
var
  Entry: TFile;
  Resource : TFilesResource;
  EN : String;
  Q : TFilesListOptions;
  List : TFileList;
  i : integer;
  N : TTreeNode;
begin
  Resource:=Nil;
  try
    Resource:=FDriveAPI.CreateFilesResource(Self);

    // Search for folders of indicated folder only.
    Q.q:='mimeType = ''application/vnd.google-apps.folder'' and '''+AFolderId+''' in parents';
    Q.corpus:='';
    q.pageSize:=50;
    Q.pageToken:='';
    List:=Resource.list(Q);
    SaveRefreshToken('Drive');
    With TVFolders.Items do
      begin
      BeginUpdate;
      try
        if Assigned(List) then
          for i:= 0 to Length(List.files)-1 do
            begin
            Entry:=List.files[i];
            List.files[i]:=Nil;
            N:=AddChild(AParent,Entry.Name);
            N.Data:=Entry;
            end;
      finally
        EndUpdate;
      end;
      end;
    Application.ProcessMessages;
    if Assigned(AParent) then
      for I:=AParent.Count-1 downto 0 do
        AddFolders(AParent.Items[i],TFile(AParent.Items[i].Data).id)
    else if (TVFolders.Items.Count>0) then
      for I:=TVFolders.Items.Count-1 downto 0  do
        AddFolders(TVFolders.Items[i],TFile(TVFolders.Items[i].Data).id)
  finally
    FreeAndNil(Resource);
  end;
end;

end.

