unit uPedido.Model;

interface

uses FireDAC.Comp.Client, System.SysUtils, FireDAC.Stan.Param, uProdutos.Model,
  uClientes.Model, System.Generics.Collections, uAttributeEntity,
  uEntity, FireDAC.Comp.DataSet, uConstant, Data.DB, Rtti;

Type

  [TableName('Pedidos_Produtos')]
  TPedidoProdutosModel = class(TGenericEntity)
  private
    FIDProduto: Integer;
    FQuantidade: Double;
    FUnitario: Double;
    FTotal: Double;
    FCodigo: Integer;
    FProduto: TProdutoModel;
    FIDPedido: Integer;
    FDescProduto: string;
    function GetProduto: TProdutoModel;
    function GetDescProduto: string;
  public
    [KeyField('ID')]
    [FieldName('ID')]
    [DisplayLabel('Código', False, 70)]
    property Codigo: Integer read FCodigo write FCodigo;
    [FieldName('id_produto')]
    [DisplayLabel('Produto', True, 70)]
    property IDProduto: Integer read FIDProduto write FIDProduto;
    [DisplayLabel('Descrição', True, 300)]
    property DescProduto: string read GetDescProduto write FDescProduto;
    [FieldName('id_pedido')]
    [DisplayLabel('Número Pedido', False, 70)]
    property IDPedido: Integer read FIDPedido write FIDPedido;
    [FieldName('Quantidade')]
    [DisplayLabel('Quantidade', True, 70)]
    property Quantidade: Double read FQuantidade write FQuantidade;
    [FieldName('valor_unitario')]
    [DisplayLabel('Vlr Unitário', True, 90)]
    property Unitario: Double read FUnitario write FUnitario;
    [FieldName('valor_total')]
    [DisplayLabel('Vlr Total', True, 90)]
    property Total: Double read FTotal write FTotal;
    property Produto: TProdutoModel read GetProduto write FProduto;
  end;

Type

  [TableName('Pedidos')]
  TPedidoModel = class(TGenericEntity)
  private
    FPedidoProdutos: TPedidoProdutosModel;
    FIdCliente: Integer;
    FData: TDate;
    FTotal: Double;
    FCodigo: Integer;
    FPedidoProdutosList: TObjectList<TPedidoProdutosModel>;
    FCliente: TClienteModel;
    function GetCliente: TClienteModel;
    function GetTotal: Double;
  public
    constructor Create();
    destructor Destroy; override;
    procedure LoadPedidoProdutosList;
    [KeyField('ID')]
    [FieldName('ID')]
    [DisplayLabel('Código')]
    property Codigo: Integer read FCodigo write FCodigo;
    [FieldName('id_cliente')]
    [DisplayLabel('Cód. Cliente')]
    property IdCliente: Integer read FIdCliente write FIdCliente;
    [FieldName('data_emissao', True, ftDate)]
    [DisplayLabel('Data')]
    property Data: TDate read FData write FData;
    [FieldName('valor_total')]
    [DisplayLabel('Vlr Total')]
    property Total: Double read GetTotal write FTotal;
    property Cliente: TClienteModel read GetCliente write FCliente;
    property PedidoProdutosList: TObjectList<TPedidoProdutosModel> read FPedidoProdutosList write FPedidoProdutosList;
  end;

implementation

uses uGenericDao;

{ TPedidoProdutos }

function TPedidoProdutosModel.GetDescProduto: string;
begin
  FDescProduto := EmptyStr;
  if Self.IDProduto > 0 then
  begin
    FDescProduto := Self.Produto.Descricao;
  end;
  Result := FDescProduto;
end;

function TPedidoProdutosModel.GetProduto: TProdutoModel;
begin
  if FProduto = nil then
  begin
    FProduto := TProdutoModel.Create;
    TGenericDAO.Retrive(FProduto, IDProduto.ToString);
  end;
  Result := FProduto;
end;

{ TPedido }

constructor TPedidoModel.Create;
begin
  inherited;
  FPedidoProdutos := TPedidoProdutosModel.Create;
  FPedidoProdutosList := TObjectList<TPedidoProdutosModel>.Create;
end;

destructor TPedidoModel.Destroy;
begin
  FPedidoProdutos.Free;
  FPedidoProdutosList.Free;
  inherited;
end;

function TPedidoModel.GetCliente: TClienteModel;
begin
  if FCliente = nil then
  begin
    FCliente := TClienteModel.Create;
    TGenericDAO.Retrive(FCliente, Self.IdCliente.ToString);
  end;
  Result := FCliente;
end;

function TPedidoModel.GetTotal: Double;
var
  I: Integer;
begin
  FTotal := 0;
  for I := 0 to FPedidoProdutosList.Count -1 do
  begin
    FTotal := FTotal + FPedidoProdutosList[I].Total;
  end;
  Result := FTotal;
end;

procedure TPedidoModel.LoadPedidoProdutosList;
var
  DataSet: TDataSet;
  I, Index: Integer;
  PropVal: TValue;
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  FFieldOrder: string;
begin
  FPedidoProdutosList.Clear;
  Criteria.Clear;
  Criteria.Add(ctEqualTo, 'ID_PEDIDO', ftInteger, [Self.Codigo]);
  DataSet := TGenericDAO.Populate(FPedidoProdutos, FFieldOrder, Criteria);
  Index := 0;
  while not DataSet.Eof do
  begin
    FPedidoProdutosList.Add(TPedidoProdutosModel.Create);
    for I := 0 to DataSet.FieldCount - 1 do
    begin
      Prop := TGenericDAO.GetProp(FPedidoProdutosList[Index], DataSet.Fields[I].FieldName);
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is FieldName) then
        begin
          if FieldName(Atributo).DataType = ftDate then
          begin
            PropVal := DataSet.Fields[I].AsDateTime;
          end
          else
            case Prop.PropertyType.TypeKind of
              tkInteger:
                PropVal := StrToInt(DataSet.Fields[I].AsString);
              tkFloat:
                PropVal := StrToFloat(DataSet.Fields[I].AsString);
              tkString:
                PropVal := DataSet.Fields[I].AsString;
            else
              PropVal := DataSet.Fields[I].AsString;
            end;
          Prop.SetValue(FPedidoProdutosList[Index], PropVal);
        end;
      end;
    end;
    inc(Index);
    DataSet.Next;
  end;
end;

end.
