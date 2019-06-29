unit uGeraClassesSimpleORM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, Vcl.CheckLst,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.DApt;

type
  TfrmGeradorClassesSimpleORM = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    script: TMemo;
    btnGerarClasses: TButton;
    edtCaminhoArquivos: TLabeledEdit;
    edtPrefixo: TLabeledEdit;
    edtCaminhoBanco: TLabeledEdit;
    edtUsuario: TLabeledEdit;
    edtSenha: TLabeledEdit;
    btnConectar: TButton;
    Panel5: TPanel;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    Panel6: TPanel;
    chkListaTabelas: TCheckListBox;
    Panel7: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure btnConectarClick(Sender: TObject);
    function EliminaBrancos(sTexto:String):String;
    function PrimeiraMaiuscula(Value: String): String;
    function maiusculas_sem_acento_e_cedilha(nome:string):string;
    procedure btnGerarClassesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGeradorClassesSimpleORM: TfrmGeradorClassesSimpleORM;
  caminho_banco : string;
  FConnection : TFDConnection;
  FQuery : TFDQuery;

implementation

{$R *.dfm}

procedure TfrmGeradorClassesSimpleORM.btnConectarClick(Sender: TObject);
var i : Integer;
begin
  caminho_banco := edtCaminhoBanco.Text;
  if not FileExists(caminho_banco) then
  begin
    ShowMessage('Base de dados n�o encontrada');
    Abort;
  end;
  try
    FConnection := TFDConnection.create(nil);
    FConnection.Params.Clear;
    FConnection.Params.Add('Password=masterkey');
    FConnection.Params.Add('User_Name=sysdba');
    FConnection.Params.Add('Database='+caminho_banco);
    FConnection.Params.Add('Server=localhost');
    FConnection.Params.Add('DriverID=FB');
    FConnection.Connected := True;
    FConnection.ResourceOptions.AutoReconnect := True;

    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := FConnection;

    FQuery.Close;
    FQuery.SQL.Clear;

    chkListaTabelas.Items.Clear();
    with FQuery do
    begin
      SQL.Text := 'select rdb$relation_name from rdb$relations where rdb$system_flag = 0;';
      Open();
      First();
      while not Eof do
      begin
        chkListaTabelas.Items.Add(EliminaBrancos(Fields[0].AsString));
        Next();
      end;
    end;

  for I := 0 to chkListaTabelas.Count -1 do
  begin
    chkListaTabelas.Checked[i] := True;
  end;
  finally
    FQuery.Free;
    FConnection.Free;
  end;

end;

procedure TfrmGeradorClassesSimpleORM.btnGerarClassesClick(Sender: TObject);
var tabela, campo : string;
    i, j : Integer;
begin
  try
  caminho_banco := 'D:\SisCAV\Fontes\Fontes_DataSnap\SisCAV_Server\Win32\Debug\BANCO.GDB';
  if not FileExists(caminho_banco) then
  begin
    ShowMessage('Base de dados n�o encontrada');
    Abort;
  end;
  FConnection := TFDConnection.create(nil);
  FConnection.Params.Clear;
  FConnection.Params.Add('Password=masterkey');
  FConnection.Params.Add('User_Name=sysdba');
  FConnection.Params.Add('Database='+caminho_banco);
  FConnection.Params.Add('Server=localhost');
  FConnection.Params.Add('DriverID=FB');
  FConnection.Connected := True;
  FConnection.ResourceOptions.AutoReconnect := True;

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;

  for j := 0 to chkListaTabelas.Count -1 do
  begin
    Application.ProcessMessages;
    if chkListaTabelas.Checked[j] then
    begin
      tabela := chkListaTabelas.Items[j].Trim;

      FQuery.Close;
      FQuery.SQL.Clear;
      FQuery.SQL.Add('select * from '+tabela);
      FQuery.Open;

      script.lines.Clear;
      script.Lines.Add('{');
      script.Lines.Add('Gerador de classes para SIMPLEORM');
      script.Lines.Add('Desenvolvido por Alan Petry - APNET INFORMATICA LTDA');
      script.Lines.Add('Fone: (54)98415-0888');
      script.Lines.Add('Email: alanpetry@alnet.eti.br ou alanpetry@outlook.com');
      script.Lines.Add('}');
      script.Lines.Add('');
      script.Lines.Add('');
      script.Lines.Add('unit '+edtPrefixo.Text+'.'+maiusculas_sem_acento_e_cedilha(tabela)+';');
      script.Lines.Add('');
      script.Lines.Add('interface');
      script.Lines.Add('');
      script.Lines.Add('uses');
      script.Lines.Add('  System.Generics.Collections, System.Classes, Rest.Json, SimpleAttributes;');
      script.Lines.Add('');
      script.Lines.Add('type');
      script.Lines.Add('  [Tabela('+QuotedStr(maiusculas_sem_acento_e_cedilha(tabela))+')]');
      script.Lines.Add('  T'+maiusculas_sem_acento_e_cedilha(tabela)+' = class');
      script.Lines.Add('  private');
      for I := 0 to FQuery.FieldCount -1 do
      begin
        if FQuery.Fields[i].ClassName = 'TIntegerField' then
          campo := 'integer;'
        else if FQuery.Fields[i].ClassName = 'TSmallintField' then
          campo := 'integer;'
        else if FQuery.Fields[i].ClassName = 'TLargeintField' then
          campo := 'integer;'
        else if FQuery.Fields[i].ClassName = 'TIBStringField' then
          campo := 'string;'
        else if FQuery.Fields[i].ClassName = 'TDateField' then
          campo := 'string;'
        else if FQuery.Fields[i].ClassName = 'TIBBCDField' then
          campo := 'real;'
        else if FQuery.Fields[i].ClassName = 'TFMTBCDField' then
          campo := 'real;'
        else if FQuery.Fields[i].ClassName = 'TCurrencyField' then
          campo := 'real;'
        else if FQuery.Fields[i].ClassName = 'TSingleField' then
          campo := 'real;'
        else if FQuery.Fields[i].ClassName = 'TStringField' then
          campo := 'string;'
        else
          campo := 'string;'+ '   {'+FQuery.Fields[i].ClassName+'}';
        script.Lines.Add('    F'+maiusculas_sem_acento_e_cedilha(FQuery.Fields[i].FieldName)+': '+campo );

    //FQuery.Fields[i].ClassName+' - '+FQuery.Fields[i].Size.ToString
      end;

      script.Lines.Add('');
      script.Lines.Add('  public');
      script.Lines.Add('    constructor Create;');
      script.Lines.Add('    destructor Destroy; override;');
      script.Lines.Add('');
      script.Lines.Add('  published');
      script.Lines.Add('{verificar os atributos do campo de chave prim�ria}');
      script.Lines.Add('{Exemplo: [Campo('+QuotedStr('NOME_CAMPO')+'), PK, AutoInc] }');
      for I := 0 to FQuery.FieldCount -1 do
      begin
        if FQuery.Fields[i].ClassName = 'TIntegerField' then
          campo := 'integer'
        else if FQuery.Fields[i].ClassName = 'TSmallintField' then
          campo := 'integer'
        else if FQuery.Fields[i].ClassName = 'TLargeintField' then
          campo := 'integer'
        else if FQuery.Fields[i].ClassName = 'TIBStringField' then
          campo := 'string'
        else if FQuery.Fields[i].ClassName = 'TDateField' then
          campo := 'string'
        else if FQuery.Fields[i].ClassName = 'TIBBCDField' then
          campo := 'real'
        else if FQuery.Fields[i].ClassName = 'TFMTBCDField' then
          campo := 'real'
        else if FQuery.Fields[i].ClassName = 'TCurrencyField' then
          campo := 'real'
        else if FQuery.Fields[i].ClassName = 'TSingleField' then
          campo := 'real'
        else if FQuery.Fields[i].ClassName = 'TStringField' then
          campo := 'string'
        else
          campo := 'string';

        script.Lines.Add('    [Campo('+quotedstr(maiusculas_sem_acento_e_cedilha(FQuery.Fields[i].FieldName))+')]');
        script.Lines.Add('    property '+maiusculas_sem_acento_e_cedilha(FQuery.Fields[i].FieldName)
                                   +': '+campo+' read F'+maiusculas_sem_acento_e_cedilha(FQuery.Fields[i].FieldName)
                                   +' write F'+maiusculas_sem_acento_e_cedilha(FQuery.Fields[i].FieldName)+';');
      end;
      script.Lines.Add('');
      script.Lines.Add('');
      script.Lines.Add('    function ToJsonString: string;');
      script.Lines.Add('    class function FromJsonString(AJsonString: string): T'+maiusculas_sem_acento_e_cedilha(tabela)+';');
      script.Lines.Add('');
      script.Lines.Add('  end;');
      script.Lines.Add('');
      script.Lines.Add('implementation');
      script.Lines.Add('');
      script.Lines.Add('constructor T'+maiusculas_sem_acento_e_cedilha(tabela)+'.Create;');
      script.Lines.Add('begin');
      script.Lines.Add('');
      script.Lines.Add('end;');
      script.Lines.Add('');
      script.Lines.Add('destructor T'+maiusculas_sem_acento_e_cedilha(tabela)+'.Destroy;');
      script.Lines.Add('begin');
      script.Lines.Add('');
      script.Lines.Add('  inherited;');
      script.Lines.Add('end;');
      script.Lines.Add('');
      script.Lines.Add('function T'+maiusculas_sem_acento_e_cedilha(tabela)+'.ToJsonString: string;');
      script.Lines.Add('begin');
      script.Lines.Add('  result := TJson.ObjectToJsonString(self);');
      script.Lines.Add('end;');
      script.Lines.Add('');
      script.Lines.Add('class function T'+maiusculas_sem_acento_e_cedilha(tabela)+'.FromJsonString(AJsonString: string): T'+maiusculas_sem_acento_e_cedilha(tabela)+';');
      script.Lines.Add('begin');
      script.Lines.Add('  result := TJson.JsonToObject<T'+maiusculas_sem_acento_e_cedilha(tabela)+'>(AJsonString)');
      script.Lines.Add('end;');
      script.Lines.Add('');
      script.Lines.Add('end.');

      if not DirectoryExists(edtCaminhoArquivos.Text) then
        CreateDir(edtCaminhoArquivos.Text);
      script.Lines.SaveToFile(edtCaminhoArquivos.Text+'\'+edtPrefixo.Text+'.'+maiusculas_sem_acento_e_cedilha(tabela)+'.pas');

    end;
  end;
  finally
    FQuery.Free;
    FConnection.free;
  end;
  ShowMessage('Conclu�do');
end;

procedure TfrmGeradorClassesSimpleORM.Button1Click(Sender: TObject);
var
  i : integer;
begin
  for I := 0 to chkListaTabelas.Count -1 do
  begin
    chkListaTabelas.Checked[i] := True;
  end;
end;

procedure TfrmGeradorClassesSimpleORM.Button2Click(Sender: TObject);
var
  i : integer;
begin
  for I := 0 to chkListaTabelas.Count -1 do
  begin
    chkListaTabelas.Checked[i] := False;
  end;
end;

function TfrmGeradorClassesSimpleORM.EliminaBrancos(sTexto: String): String;
// Elimina todos os espa�os em branco da string
//(inclusive os espa�os entre as palavras)
var
nPos : Integer;
begin
  nPos := 1;
  while Pos(' ',sTexto) > 0 do
  begin
    nPos := Pos(' ',sTexto);
    (*Text[nPos] := ''; *)
    Delete(sTexto,nPos,1);
  end;
  Result := sTexto;
end;

procedure TfrmGeradorClassesSimpleORM.FormShow(Sender: TObject);
begin
  edtCaminhoArquivos.Text := ExtractFilePath(Application.ExeName)+'Entidades';
end;

function TfrmGeradorClassesSimpleORM.maiusculas_sem_acento_e_cedilha(nome: string): string;
var
  i : integer;
  aux, novo : string;
begin
  aux := AnsiUpperCase(nome);
    for i := 1 to length(aux) do
    begin
      case aux[i] of
      '�', '�', '�', '�', '�', '�', '�', '�', '�', '�': aux[i] := 'A';
      '�', '�', '�', '�', '�', '�', '�', '�', '&': aux[i] := 'E';
      '�', '�', '�', '�', '�', '�', '�', '�': aux[i] := 'I';
      '�', '�', '�', '�', '�', '�', '�', '�', '�', '�': aux[i] := 'O';
      '�', '�', '�', '�', '�', '�', '�', '�': aux[i] := 'U';
      '�', '�': aux[i] := 'C';
      '�', '�': aux[i] := 'N';
      '�', '�': aux[i] := 'Y';
      else
        if ord(aux[i]) > 127 then
          aux[i] := #32;
      end;
    end;
  maiusculas_sem_acento_e_cedilha := aux;
end;

function TfrmGeradorClassesSimpleORM.PrimeiraMaiuscula(Value: String): String;
var
P: Integer;
Word: String;
begin
Result := '';
Value := Trim(LowerCase(Value));
repeat
     P := Pos(' ', Value);
     if P <= 0 then
        begin
        P := Length(Value) + 1;
        end;
     Word := UpperCase(Copy(Value, 1, P-1));
     if (Length(Word) <= 2) or (Word = 'DAS') or (Word = 'DOS') then
        begin
        Result := Result + Copy(Value, 1, P-1)
        end
     else
        begin
        Result := Result + UpperCase(Value[1]) + Copy(Value, 2, P-2);
        end;
     Delete(Value, 1, P);
     if Value <> '' then
        begin
        Result := Result + ' ';
        end;
until Value = '';
end;

end.
