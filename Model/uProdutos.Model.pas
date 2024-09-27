unit uProdutos.Model;

interface

uses FireDAC.Comp.Client, System.SysUtils, FireDAC.Stan.Param,
  uAttributeEntity, uEntity, uGenericDao;

Type
  [TableName('Produtos')]
  TProdutoModel = class(TGenericEntity)
  private
    FDescricao: String;
    FPrecoVenda: Double;
    FCodigo: integer;
  public
    [KeyField('ID')]
    [FieldName('ID')]
    [DisplayLabel('C�digo')]
    property Codigo: integer read FCodigo write FCodigo;
    [FieldName('Descricao')]
    [DisplayLabel('Descri��o')]
    property Descricao: String read FDescricao write FDescricao;
    [FieldName('Preco_Venda')]
    [DisplayLabel('Pre�o Venda')]
    property PrecoVenda: Double read FPrecoVenda write FPrecoVenda;
  end;

implementation

{ TProdutoModel }

{ TProdutoModel }

end.
