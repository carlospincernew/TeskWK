unit udmConnection;

interface

uses
  SysUtils, Classes, FMTBcd, DB, SqlExpr, forms, IniFiles, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Dialogs, System.UITypes;

type
  TDM = class(TDataModule)
    WKConexao: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    qryExec: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    // funções para o banco de dados
    function Conectar: boolean;
    function Desconectar: boolean;

    // funções para manipular as entidades
    function getDataSet(strQry: string): TFDQuery;
    function execSql(strQry: string): boolean;
  end;

var
  DM: TDM;

implementation

{$R *.dfm}

// funções para o banco de dados
function TDM.Conectar: boolean;
begin
  try
    WKConexao.Connected := true;
    result := true;
  except
    result := false;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  sArqCon: string;
  FileCon: TIniFile;
begin
  WKConexao.Connected := False;
  sArqCon := ExtractFilePath(Application.ExeName) + 'Connection.ini';
  if FileExists(sArqCon) then
  begin
    try
      FileCon := TIniFile.Create(sArqCon);
      WKConexao.Params.Database := FileCon.ReadString('Connection', 'Database', '');
      WKConexao.Params.Password := FileCon.ReadString('Connection', 'Password', '');
      WKConexao.Params.UserName := FileCon.ReadString('Connection', 'UserName', '');
      WKConexao.Params.Values['Port'] := FileCon.ReadString('Connection', 'Port', '3306');
      FDPhysMySQLDriverLink1.VendorLib := FileCon.ReadString('Connection', 'libdll', 'C:\Windows\SysWOW64\libmysql.dll')
    finally
      FreeAndNil(FileCon);
    end;
  end;
end;

function TDM.Desconectar: boolean;
begin
  try
    WKConexao.Connected := false;
    result := true;
  except
    result := false;
  end;
end;

// funções para manipular as entidades
function TDM.getDataSet(strQry: string): TFDQuery;
begin
  Result := TFDQuery.Create(self);
  try
    Result.Connection := WKConexao;
    Result.SQL.Text := strQry;
    Result.Open;
  except
    on E: Exception do
    begin
      raise Exception.Create(e.Message);
    end;
  end;
end;

function TDM.execSql(strQry: string): boolean;
begin
  result := false;
  try
    qryExec.SQL.Text := strQry;
    qryExec.execSql;
    result := true;
  except
    on e: Exception do
    begin
      raise Exception.Create(e.Message);
    end;
  end;
end;

end.
