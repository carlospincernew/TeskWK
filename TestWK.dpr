program TestWK;


uses
  Vcl.Forms,
  udmConnection in 'Utils\udmConnection.pas' {DM},
  uFunctions in 'Utils\uFunctions.pas',
  uClientes.Model in 'Model\uClientes.Model.pas',
  uClientes.Control in 'Control\uClientes.Control.pas',
  uProdutos.Model in 'Model\uProdutos.Model.pas',
  uProdutos.Control in 'Control\uProdutos.Control.pas',
  uPedido.Model in 'Model\uPedido.Model.pas',
  uPedido.Control in 'Control\uPedido.Control.pas',
  uGenericDao in 'Utils\uGenericDao.pas',
  uEntity in 'Utils\uEntity.pas',
  uAttributeEntity in 'Utils\uAttributeEntity.pas',
  uConstant in 'Utils\uConstant.pas',
  uFrmPedido.View in 'View\uFrmPedido.View.pas' {FrmPedido};

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPedido, FrmPedido);
  Application.Run;
end.
