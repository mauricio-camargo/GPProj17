unit Unitrs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring

  rs_FORM1CAPTION = 'GPProj - Gerenciador Pessoal de Projetos v1.7';
  rs_PathOutdated = 'O folder atribuído a este projeto não é mais válido. Atribua uma nova pasta para o projeto.';
  rs_RenProj = 'Renomear Projeto';
  rs_NNomeProj = 'Entre com o novo nome do Projeto:';
  rs_TransProjLix = 'Transferir o Projeto para a Lixeira?';
  rs_projs = 'Projetos';
  rs_ProjArquiv = 'Projetos arquivados (';
  rs_ProjLixo = 'Projetos na lixeira (';
  rs_AjudaConfig = 'Alguns aplicativos de celular gravam áudios e textos e enviam automaticamente para o Dropbox (ou qualquer outro serviço na nuvem). Informe a localização da pasta do Dropbox:';
  rs_NovasNotas = 'Novas notas do App: ';
  rs_ArqNInfo = 'Arquivo de notas no celular não foi informado. Por favor, verifique as configurações do programa.';
  rs_projetos = 'Projetos';
  rs_arqs = 'Arquivos';
  rs_notes = 'Anotações';
  rs_Conts = 'Contatos';
  rs_Tars = 'Tarefas';
  rs_Agenda = 'Agenda';
  rs_EdNot = 'Editar Notas';
  rs_cel = 'Celular';
  rs_Marc = 'Marcador';
  rs_Altera = 'Entre com as alterações: ';
  rs_NovaTarCel = 'Nova tarefa do celular';
  rs_NovaTar = 'Nova tarefa:';
  rs_ProjVazio = 'Nome do Projeto está vazio!';
  rs_ProjExists = 'Nome do Projeto já existe!';
  rs_AvisoSemPasta = 'Se você não informar uma pasta para armazenar os arquivos do Projeto, não será possível salvar os anexos dos e-mails.';
  rs_ErroPastaArq = 'Nenhuma pasta para armazenamento dos arquivos do Projeto foi informada.';
  rs_DelFile = 'Tem certeza que deseja apagar o arquivo ';
  rs_PastaModelos = 'Nenhuma pasta contendo modelos de arquivos foi encontrado. Entre na aba de configurações do programa e informe uma pasta que contenha os arquivos modelos.';
  rs_Rename = 'Renomear arquivo';
  rs_NovoNome = 'Novo nome: ';
  rs_EdOProj = 'Editar opções do Projeto ';
  rs_InsProj = 'Inserir um novo Projeto';
  rs_NomeProj = 'Nome do Projeto';
  rs_EnvGerArq = 'Pasta enviada pelo gerenciador de arquivos';
  rs_NovaPasta = 'Nova pasta';
  rs_NNovaPasta = 'Nome da nova pasta:';
  rs_RenameFolder = 'Renomear pasta';
  rs_NRenameFolder = 'Novo nome da pasta';
  rs_Mess6 = 'Todos os arquivos (se houver) da pasta serão apagados.';
  rs_Mess7 = 'Tem certeza que deseja apagar?';
  rs_mess8 = 'Tem certeza que deseja apagar o arquivo?';
  rs_NoTextInf = 'Nenhum texto informado.';
  rs_ProjAtivo = 'Projetos Ativos (';
  rs_LabelMarkNome = 'Nome do marcador:';
  rs_FiltCont = 'Filtrar contatos baseados nos marcadores';
  rs_MarkExists = 'Marcador já existe!';
  rs_DeleteMarkerCont = 'Deletar o marcador selecionado definitivamente?';
  rs_AttMarcCont = 'Atribuir marcadores ao contato';
  rs_DelCont1 = 'Apagar contato "';
  rs_NoProjAberto = 'Nenhum Projeto aberto para criar a lista de contatos.';
  rs_ContExProj = 'Contato já existe para este Projeto.';
  rs_FiltProj = 'Filtrar Projetos baseados nos marcadores';
  rs_AttMarcProj = 'Atribuir marcadores ao Projeto';
  rs_AllFiles = 'Todos os arquivos';
  rs_ErroSalvarArqEmail = 'Nenhuma pasta para armazenamento dos arquivos do Projeto foi informada e os arquivos em anexo do e-mail não foram salvos.';
  rs_DelEmail = 'Deletar e-mail?';
  rs_ContCopy = 'Contatos copiados com sucesso!';
  rs_MailSend = 'E-mail enviado com SUCESSO!!!';
  rs_MailNotSend = 'E-mail NÃO FOI enviado.';
  rs_Start = 'Iniciar';
  rs_Working = 'Trabalhando...';
  cs_Retorna = 'Retornar';
  rs_Time = 'Tempo';
  rs_Intervalo = 'Agora começa o intervalo de ';
  rs_Minute = ' minutos.';
  rs_InInterval = 'Em intervalo';
  rs_EndInterval = 'Final de intervalo! Reinicie o pomodoro para a próxima tarefa.';
  rs_TempoInt = 'Tempo até intervalo';
  rs_analogico = 'Analógico';
  rs_Jan = 'Janeiro';
  rs_Fev = 'Fevereiro';
  rs_Mar = 'Março';
  rs_Abr = 'Abril';
  rs_Mai = 'Maio';
  rs_Jun = 'Junho';
  rs_Jul = 'Julho';
  rs_Ago = 'Agosto';
  rs_Set = 'Setembro';
  rs_Out = 'Outubro';
  rs_Nov = 'Novembro';
  rs_Dez = 'Dezembro';
  rs_FormCalendCapInsert = 'Inserir novo registro';
  rs_Segunda = 'Segunda';
  rs_Terca = 'Terça';
  rs_Quarta = 'Quarta';
  rs_Quinta = 'Quinta';
  rs_Sexta = 'Sexta';
  rs_Sabado = 'Sabado';
  rs_Domingo = 'Domingo';
  rs_PanAviCap = '<<<<< GPProj - Painel de notificações do sistema >>>>>';
  rs_AvisoConfig = 'Preencha as configurações do programa';
  rs_AudioGrav = 'Novos áudios: ';
  rs_DiaTodo = 'Dia todo';
  rs_AgendaHoje = 'Agenda hoje (';
  rs_AgendaAmanha = 'Agenda amanhã (';
  rs_TarHoje = 'Tarefa para hoje: ';
  rs_TarAmanha = 'Tarefa para amanhã: ';
  rs_editing='Editando...';
  rs_inserting='Inserindo...';
  rs_mess4 = 'E-mail sem destinatários!';
const
 PSWKEY = 'maucam';

 {$IFDEF LINUX}
  ARQUIVOINI = 'gpprojl.ini';
  CFGTB = 'CfgLnxTB';
 {$ENDIF}
 {$IFDEF WINDOWS}
  ARQUIVOINI = 'gpprojw.ini';
  CFGTB = 'CfgWinTB';
 {$ENDIF}

implementation

end.

