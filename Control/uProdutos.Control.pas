unit uProdutos.Control;

interface

uses uProdutos.Model, System.SysUtils, uGenericDao;

Type
  TProdutoControl = class
  private
  public
    Constructor Create();
    function LocateProduto(ACodigo: Integer): TProdutoModel;
  end;

implementation

{ TProdutoControl }

function TProdutoControl.LocateProduto(ACodigo: Integer): TProdutoModel;
begin
  result := TProdutoModel.Create;
  TGenericDAO.Retrive(result, ACodigo.ToString);
  if (result = nil) or (result.Codigo = 0) then
    raise Exception.Create('Produto não localizado');
end;

constructor TProdutoControl.Create();
begin

end;

end.
