unit uClientes.Model;

interface

uses FireDAC.Comp.Client, System.SysUtils, FireDAC.Stan.Param,
  uAttributeEntity, uEntity;

Type

  [TableName('Clientes')]
  TClienteModel = class(TGenericEntity)
  private
    FNome: String;
    FCidade: String;
    FUF: String;
    FCodigo: Integer;
  public
    [KeyField('ID')]
    [FieldName('ID')]
    [DisplayLabel('Código')]
    property Codigo: Integer read FCodigo write FCodigo;
    [FieldName('Nome')]
    [DisplayLabel('Nome/Razão Social')]
    property Nome: String read FNome write FNome;
    [FieldName('Cidade')]
    [DisplayLabel('Cidade')]
    property Cidade: String read FCidade write FCidade;
    [FieldName('uf')]
    [DisplayLabel('UF')]
    property UF: String read FUF write FUF;
  end;

implementation

{ TClienteModel }

end.
