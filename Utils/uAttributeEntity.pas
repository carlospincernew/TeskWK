unit uAttributeEntity;

interface

uses Data.DB;

//atributo para determinar o nome da tabela na entidade a ser usada
type //nome da tabela
  TableName = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(aName: String);
    property Name: String read FName write FName;
  end;

type //determinar se o campo é um campo chave
  KeyField = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(aName: String);
    property Name: String read FName write FName;
  end;

type  //nome do campo na tabela
  FieldName = class(TCustomAttribute)
  private
    FName: String;
    FVisible: Boolean;
    FDataType: TFieldType;
  public
    constructor Create(aName: String; aVisible: Boolean = True; aDataType: TFieldType = ftUnknown);
    property Name: String read FName write FName;
    property Visible: Boolean read FVisible write FVisible;
    property DataType: TFieldType read FDataType write FDataType;
  end;

type
  DisplayLabel = class(TCustomAttribute)
  private
    FName: String;
    FSize: integer;
    FVisible: Boolean;
  public
    constructor Create(aName: String; aVisible: Boolean = true; aSize: Integer = 0);
    property Name: String read FName write FName;
    property Size: integer read FSize write FSize;
    property Visible: Boolean read FVisible write FVisible;
  end;


implementation

constructor TableName.Create(aName: String);
begin
  FName := aName
end;

constructor KeyField.Create(aName: String);
begin
  FName := aName;
end;

constructor FieldName.Create(aName: String; aVisible: Boolean; aDataType: TFieldType);
begin
  FName := aName;
  FVisible := aVisible;
  FDataType := aDataType;
end;

constructor DisplayLabel.Create(aName: String; aVisible: Boolean; aSize: Integer);
begin
  FName := aName;
  FSize := aSize;
  FVisible := aVisible;
end;


end.
