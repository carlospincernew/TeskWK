unit uClientes.Control;

interface

uses uClientes.Model, System.SysUtils, uGenericDao;

type
  TClienteControl = class
  private
  public
    function LocateCliente(ACodigo: Integer): TClienteModel;
    constructor Create();
  end;

implementation

{ TClienteControl }

constructor TClienteControl.Create();
begin

end;

function TClienteControl.LocateCliente(ACodigo: Integer): TClienteModel;
begin
  result := TClienteModel.create;
  TGenericDAO.Retrive(result, ACodigo.ToString) ;
  if (result = nil) or (result.Codigo = 0) then
    raise Exception.Create('Cliente não localizado');
end;

end.
