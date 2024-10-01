unit uPedido.Control;

interface

uses uPedido.Model, System.SysUtils, System.Generics.Collections, Data.DB,
  Datasnap.DBClient, Vcl.Grids, System.Rtti, uAttributeEntity, uGenericDao,
  uConstant, uProdutos.Control, uProdutos.Model, uClientes.Model, uClientes.Control;

type
  TPedidoControl = class
  private
    FPedidoModel: TPedidoModel;
    FClienteControl: TClienteControl;
    FProdutoControl: TProdutoControl;
    FGridPedProd: TStringGrid;
    FContexto: TRttiContext;
    TypObj: TRttiType;
    FTotalPedido: Double;
    function LocateCliente(ACodigo: Integer): TClienteModel;
    function LocateProduto(ACodigo: Integer): TProdutoModel;
    function LocatePedido(ACodigo: Integer): TPedidoModel;
    function GetTotalPedido: Double;
  public
    Constructor Create(APedido: TPedidoModel; AGrid: TStringGrid = nil);
    Destructor Destroy; override;
    Procedure LoadGrid();
    procedure ChangeGrid();
    function Save(): boolean;
    function Delete(ANumPed: Integer): boolean;
    function DeletePedidoProduto(APedidoProdutos: TPedidoProdutosModel): boolean;
    procedure Cancel();
    procedure Clear;
    procedure AddPedidoProduto(APedidoProdutos: TPedidoProdutosModel);
    function LocateCadastro(ATipoConsulta: TConsulta; AValue: Integer): TObject;
    property TotalPedido: Double read GetTotalPedido write FTotalPedido;
  end;

implementation

uses udmConnection;

{ TPedidoControl }

function TPedidoControl.Save(): boolean;
var
  PedidoProdutos: TPedidoProdutosModel;
begin
  Result := False;
  // Valida cabecalho do pedido
  if FPedidoModel.IdCliente = 0 then
    raise Exception.Create('Cliente não imformado');

  DM.WKConexao.StartTransaction;
  try
    if FPedidoModel.StateMode in [smInsert, smEdit] then
      TGenericDAO.Save(FPedidoModel);

    for PedidoProdutos in FPedidoModel.PedidoProdutosList do
    begin
      case PedidoProdutos.StateMode of
        smInsert, smEdit: TGenericDAO.Save(PedidoProdutos);
        smDeleted: TGenericDAO.Delete(PedidoProdutos);
      end;
    end;
    DM.WKConexao.Commit;
    FPedidoModel.StateMode := smBrowse;
    Result := True;
  except
    on e: Exception do
    begin
      DM.WKConexao.Rollback;
    end;
  end;
end;

procedure TPedidoControl.AddPedidoProduto(APedidoProdutos: TPedidoProdutosModel);
begin
  if FPedidoModel.Codigo = 0 then
  begin
    FPedidoModel.StateMode := smInsert;
    FPedidoModel.Codigo := TGenericDAO.GetLastID(FPedidoModel);
  end;
  if (APedidoProdutos.IDProduto = 0) then
    raise Exception.Create('Produto não imformado');

  if (APedidoProdutos.Quantidade = 0) then
    raise Exception.Create('Quantidade não imformado');

  APedidoProdutos.IDPedido := FPedidoModel.Codigo;
  APedidoProdutos.StateMode := smInsert;
  FPedidoModel.PedidoProdutosList.Add(APedidoProdutos);
  TotalPedido := FPedidoModel.Total;
  if FGridPedProd <> nil then
    ChangeGrid;
end;

procedure TPedidoControl.Cancel;
begin
  FPedidoModel.Free;
  FPedidoModel := TPedidoModel.Create;
end;

procedure TPedidoControl.ChangeGrid();
var
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  iCol, iRow: Integer;
  PedidoProdutos: TPedidoProdutosModel;
begin
  if FGridPedProd = nil then
    Exit;

  FGridPedProd.RowCount := 2;
  FGridPedProd.Rows[1].Clear;
  iRow := 1;
  for PedidoProdutos in FPedidoModel.PedidoProdutosList do
  begin
    if PedidoProdutos.StateMode = smDeleted then
      Continue;

    TypObj := FContexto.GetType(PedidoProdutos.ClassInfo);
    iCol := 0;
    FGridPedProd.Objects[iCol, iRow] := PedidoProdutos;
    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if Atributo is DisplayLabel then
        begin
          if (DisplayLabel(Atributo).Visible) then
          begin
            case Prop.PropertyType.TypeKind of
              tkFloat:
                FGridPedProd.Cells[iCol, iRow] := FormatFloat('###,##0.00', Prop.GetValue(PedidoProdutos).AsExtended);
            else
              FGridPedProd.Cells[iCol, iRow] := Prop.GetValue(PedidoProdutos).AsVariant;
            end;
            inc(iCol);
          end;
          Break;
        end;
      end;
    end;
    inc(iRow);
    FGridPedProd.RowCount := iRow;
  end;
end;

procedure TPedidoControl.Clear;
begin
  FPedidoModel.PedidoProdutosList.Clear;
  TGenericDAO.Clear(FPedidoModel);
end;

constructor TPedidoControl.Create(APedido: TPedidoModel; AGrid: TStringGrid);
begin
  FPedidoModel := APedido;
  FContexto := TRttiContext.Create;
  FGridPedProd := AGrid;
  FClienteControl := TClienteControl.Create;
  FProdutoControl := TProdutoControl.Create;
  TotalPedido := 0;
end;

function TPedidoControl.Delete(ANumPed: Integer): boolean;
var
  PedidoProdutos: TPedidoProdutosModel;
begin
  Result := False;

  if (FPedidoModel <> nil) or (FPedidoModel.Codigo <> ANumPed) then
    FPedidoModel := TPedidoModel(LocateCadastro(csPedido, ANumPed));

  if (FPedidoModel <> nil) and (FPedidoModel.Codigo > 0) then
  begin
    DM.WKConexao.StartTransaction;
    try
      PedidoProdutos := FPedidoModel.PedidoProdutosList[0];
      if PedidoProdutos <> nil then
      begin
        PedidoProdutos.Criteria.Clear;
        PedidoProdutos.Criteria.Add(ctEqualTo, 'ID_PEDIDO', ftInteger, [FPedidoModel.Codigo]);
        Result := TGenericDAO.Delete(PedidoProdutos, PedidoProdutos.Criteria);
      end;

      if Result then
        Result := TGenericDAO.Delete(FPedidoModel);

      DM.WKConexao.Commit;
    except
      on e: Exception do
      begin
        DM.WKConexao.Rollback;
      end;
    end;
  end;
end;

function TPedidoControl.DeletePedidoProduto(APedidoProdutos: TPedidoProdutosModel): boolean;
var
  PedidoProdutos: TPedidoProdutosModel;
begin
  Result := False;
  if APedidoProdutos <> nil then
  begin
    for PedidoProdutos in FPedidoModel.PedidoProdutosList do
    begin
      if PedidoProdutos.Codigo = APedidoProdutos.Codigo then
      begin
        PedidoProdutos.StateMode := smDeleted;
        Break;
      end;
    end;
  end;
end;

destructor TPedidoControl.Destroy;
begin
  FContexto.Free;
  inherited;
end;

function TPedidoControl.GetTotalPedido: Double;
var
  I: Integer;
begin
  FTotalPedido := 0;
  for I := 0 to FPedidoModel.PedidoProdutosList.Count - 1 do
    FTotalPedido := FTotalPedido + FPedidoModel.PedidoProdutosList[I].Total;

  Result := FTotalPedido;
end;

Procedure TPedidoControl.LoadGrid();
var
  PedidoProdutos: TPedidoProdutosModel;
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  iCol: Integer;
begin
  if FGridPedProd = nil then
    Exit;

  PedidoProdutos := TPedidoProdutosModel.Create;
  try
    FGridPedProd.RowCount := 2;
    FGridPedProd.Rows[1].Clear;
    FGridPedProd.ColCount := 1;
    TypObj := FContexto.GetType(PedidoProdutos.ClassInfo);
    iCol := 0;
    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if Atributo is DisplayLabel then
        begin
          if (DisplayLabel(Atributo).Visible) then
          begin
            FGridPedProd.Cells[iCol, 0] := DisplayLabel(Atributo).Name;
            inc(iCol);
            FGridPedProd.ColCount := iCol;
            FGridPedProd.ColWidths[iCol - 1] := DisplayLabel(Atributo).Size;
          end;
          Break;
        end;
      end;
    end;
  finally
    FreeAndNil(PedidoProdutos);
  end;
end;

function TPedidoControl.LocateCadastro(ATipoConsulta: TConsulta; AValue: Integer): TObject;
begin
  Result := nil;
  case ATipoConsulta of
    csProduto:
      Result := LocateProduto(AValue);
    csCliente:
      Result := LocateCliente(AValue);
    csPedido:
      Result := LocatePedido(AValue);
  end;
end;

function TPedidoControl.LocateCliente(ACodigo: Integer): TClienteModel;
begin
  Result := FClienteControl.LocateCliente(ACodigo);
end;

function TPedidoControl.LocateProduto(ACodigo: Integer): TProdutoModel;
begin
  Result := FProdutoControl.LocateProduto(ACodigo);
end;

function TPedidoControl.LocatePedido(ACodigo: Integer): TPedidoModel;
begin
  Result := nil;
  if TGenericDAO.Retrive(FPedidoModel, ACodigo.ToString) then
  begin
    FPedidoModel.LoadPedidoProdutosList;
    Result := FPedidoModel;
  end;
end;

end.
