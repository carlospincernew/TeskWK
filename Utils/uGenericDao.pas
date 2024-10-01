unit uGenericDao;

interface

Uses Db, Rtti, uAttributeEntity, TypInfo, SysUtils, udmConnection, uConstant,
  Datasnap.DBClient, Classes, System.Generics.Collections, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.StrUtils, uEntity, System.Variants;

type

  TGenericDAO = class(TObject)
  private
    class function Insert<T: class>(Obj: T): boolean;
    class function Update<T: class>(Obj: T): boolean;
    class function GetTableName<T: class>(Obj: T): String;
    class function GetDisplayLabel<T: class>(Obj: T; AFieldName: string; var AVisible: boolean): string;
  public
    // procedimentos para o crud
    class function Save<T: class>(Obj: T): boolean;
    class function Populate<T: class>(Obj: T; AFieldOrder: string; ACriteria: TCriteria = nil): TDataSet; overload;
    class function GetProp<T: class>(Obj: T; AFieldName: string): TRttiProperty;
    class function GetKeyField<T: class>(Obj: T): String;
    class function GetKeyValue<T: class>(Obj: T): Variant;
    class function Retrive<T: class>(Obj: T; AKeyValue: string): boolean;
    class function Delete<T: class>(Obj: T; ACriteria: TCriteria = nil): boolean;
    class function GetLastID<T: class>(Obj: T): Integer;
    class procedure Clear<T: class>(Obj: T);
  end;

implementation

class function TGenericDAO.GetKeyField<T>(Obj: T): String;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  isKey: boolean;
begin
  isKey := False;
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is KeyField) then
          isKey := True;

        if (isKey) and (Atributo is FieldName) then
          Exit(FieldName(Atributo).Name);
      end;
    end;
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.GetKeyValue<T>(Obj: T): Variant;
var
  Prop: TRttiProperty;
  sKeyValue: string;
begin
  sKeyValue := GetKeyField(Obj);
  Prop := GetProp(Obj, sKeyValue);
  if Prop <> nil then
    Result := Prop.GetValue(TObject(Obj)).AsVariant;
end;

class function TGenericDAO.GetProp<T>(Obj: T; AFieldName: string): TRttiProperty;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Atributo: TCustomAttribute;
  Prop: TRttiProperty;
begin
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is FieldName) and (UpperCase(FieldName(Atributo).Name) = UpperCase(AFieldName)) then
          Exit(Prop);
      end;
    end;
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.GetTableName<T>(Obj: T): String;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Atributo: TCustomAttribute;
  strTable: String;
begin
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    for Atributo in TypObj.GetAttributes do
    begin
      if Atributo is TableName then
        Exit(TableName(Atributo).Name);
    end;
  finally
    Contexto.Free;
  end;
end;

class procedure TGenericDAO.Clear<T>(Obj: T);
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  PropVal: TValue;
begin
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      case Prop.PropertyType.TypeKind of
        tkInt64, tkInteger:
          PropVal := 0;
        tkFloat:
          PropVal := 0;
        tkChar, tkString, tkWChar, tkLString,
          tkWString, tkVariant, tkUString:
          PropVal := '';
      else
        if Prop.PropertyType.TypeKind in [tkDynArray, tkClassRef, tkPointer, tkArray,
          tkProcedure, tkRecord, tkInterface, tkSet, tkClass, tkMethod, tkUnknown,
          tkEnumeration] then
          Continue;
      end;
      Prop.SetValue(TGenericEntity(Obj), PropVal);
    end;
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.Delete<T>(Obj: T; ACriteria: TCriteria = nil): boolean;
var
  sSQL, Table,
    sCriteria, Field: String;
  Value: Variant;
  I: Integer;
begin
  Result := False;
  Table := GetTableName(Obj);
  Field := GetKeyField(Obj);

  sCriteria := ' WHERE 1 = 1 ';
  if (ACriteria <> nil) and (ACriteria.Items[0].Attribute <> EmptyStr) then
  begin
    for I := 0 to ACriteria.Count - 1 do
    begin
      if ACriteria.Items[I].ValueFMT <> EmptyStr then
        sCriteria := sCriteria + 'AND ' + ACriteria.Items[I].Attribute +
          ACriteria.Items[I].ValueOperator +
          ACriteria.Items[I].ValueFMT +
          ACriteria.Items[I].LineEnd;
    end;
  end
  else begin
    Value := GetKeyValue(Obj);
    sCriteria := ' WHERE ' + Field + ' = ' + VarToStr(Value);
  end;

  sSQL := 'DELETE FROM ' + Table + sCriteria;

  Result := DM.execSql(sSQL);

end;

class function TGenericDAO.GetDisplayLabel<T>(Obj: T; AFieldName: string; var AVisible: boolean): string;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Atributo: TCustomAttribute;
  Prop: TRttiProperty;
  isField: boolean;
begin
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    for Prop in TypObj.GetProperties do
    begin
      isField := False;
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is FieldName) and (UpperCase(FieldName(Atributo).Name) = UpperCase(AFieldName)) then
        begin
          AVisible := FieldName(Atributo).Visible;
          isField := True;
        end;

        if (isField) and (Atributo is DisplayLabel) then
          Exit(DisplayLabel(Atributo).Name);
      end;
    end;
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.Update<T>(Obj: T): boolean;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  sSQL, strSet: String;
  Atributo: TCustomAttribute;
  sTableName: string;
  sWhere, sKeyField: string;
  vKeyValue: Variant;
  sKeyValue, strFloat: string;
begin
  strSet := '';
  sTableName := GetTableName(Obj);

  sSQL := 'UPDATE ' + sTableName + ' SET ';
  sKeyField := GetKeyField(Obj);
  vKeyValue := GetKeyValue(Obj);
  sKeyValue := VarToStr(vKeyValue);
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);

    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is FieldName) and (FieldName(Atributo).Name <> sKeyField) then
        begin
          strSet := strSet + FieldName(Atributo).Name + ' = ';
          if FieldName(Atributo).DataType = ftDate then
          begin
            strSet := strSet + QuotedStr(FormatDateTime('yyyy-mm-dd', Prop.GetValue(TObject(Obj)).AsExtended)) + ',';
          end
          else begin
            case Prop.GetValue(TObject(Obj)).Kind of

              tkWChar, tkLString, tkWString, tkString,
                tkChar, tkUString:

                strSet := strSet +
                  QuotedStr(Prop.GetValue(TObject(Obj)).AsString) + ',';

              tkInteger, tkInt64:
                strSet := strSet +
                  IntToStr(Prop.GetValue(TObject(Obj)).AsInteger) + ',';

              tkFloat: begin
                strFloat := ReplaceStr(FloatToStr(Prop.GetValue(TObject(Obj)).AsExtended), '.', '');
                strFloat := ReplaceStr(strFloat, ',', '.');
                strSet := strSet + strFloat + ',';
              end;

            else
              raise Exception.Create('Type not Supported');
            end;
          end;
        end;
      end;
    end;
    System.Delete(strSet,Length(strSet), 1);
    sWhere := ' WHERE ' + sKeyField + ' =  ' + sKeyValue;
    sSQL := sSQL + strSet + sWhere;

    Result := DM.execSql(sSQL);
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.Insert<T>(Obj: T): boolean;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  sSQL, strFields, strValues: String;
  Atributo: TCustomAttribute;
  sTableName, strFloat: string;
begin
  strFields := '';
  strValues := '';
  sTableName := GetTableName(Obj);

  sSQL := 'INSERT INTO ' + sTableName;

  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);

    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if Atributo is FieldName then
        begin
          strFields := strFields + FieldName(Atributo).Name + ',';
          if FieldName(Atributo).DataType = ftDate then
          begin
            strValues := strValues + QuotedStr(FormatDateTime('yyyy-mm-dd', Prop.GetValue(TObject(Obj)).AsExtended)) + ',';
          end
          else begin

            case Prop.GetValue(TObject(Obj)).Kind of

              tkWChar, tkLString, tkWString, tkString,
                tkChar, tkUString:

                strValues := strValues +
                  QuotedStr(Prop.GetValue(TObject(Obj)).AsString) + ',';

              tkInteger, tkInt64:

                strValues := strValues +
                  IntToStr(Prop.GetValue(TObject(Obj)).AsInteger) + ',';

              tkFloat:
                begin
                  strFloat := ReplaceStr(FloatToStr(Prop.GetValue(TObject(Obj)).AsExtended), '.', '');
                  strFloat := ReplaceStr(strFloat, ',', '.');
                  strValues := strValues + strFloat + ',';
                end;

            else
              raise Exception.Create('Type not Supported');
            end;
          end;
        end;
      end;
    end;
    strFields := Copy(strFields, 1, Length(strFields) - 1);
    strValues := Copy(strValues, 1, Length(strValues) - 1);
    sSQL := sSQL + ' ( ' + strFields + ' )  VALUES ( ' + strValues + ' )';

    Result := DM.execSql(sSQL);
  finally
    Contexto.Free;
  end;
end;

class function TGenericDAO.GetLastID<T>(Obj: T): Integer;
var
  TableName: string;
  KeyField: string;
  QryKey: TFDQuery;
begin
  Result := 0;
  try
    TableName := GetTableName(Obj);
    KeyField := GetKeyField(Obj);
    QryKey := DM.getDataSet('SELECT COALESCE(MAX(' + KeyField + '),0) + 1 KEYFIELD FROM ' + TableName);
    Result := QryKey.FieldByName('KEYFIELD').AsInteger;
  finally
    if Assigned(QryKey) then
      FreeAndNil(QryKey);
  end;
end;

// funções para manipular as entidades
class function TGenericDAO.Save<T>(Obj: T): boolean;
begin
  if TGenericEntity(Obj).StateMode = smEdit then
    Update<T>(Obj)
  else
    Insert<T>(Obj);
end;

class function TGenericDAO.Populate<T>(Obj: T; AFieldOrder: string; ACriteria: TCriteria): TDataSet;
var
  I: Integer;
  sSQL: string;
  sCriteria: string;
  Visible: boolean;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  Contexto: TRttiContext;
  FieldsArr: array of string;
  sFields: string;
begin
  sCriteria := ' WHERE 1 = 1 ';

  if AFieldOrder = EmptyStr then
    AFieldOrder := '1';

  if (ACriteria <> nil) and (ACriteria.Items[0].Attribute <> EmptyStr) then
  begin
    for I := 0 to ACriteria.Count - 1 do
    begin
      if ACriteria.Items[I].ValueFMT <> EmptyStr then
        sCriteria := sCriteria + 'AND ' + ACriteria.Items[I].Attribute +
          ACriteria.Items[I].ValueOperator +
          ACriteria.Items[I].ValueFMT +
          ACriteria.Items[I].LineEnd;
    end;
  end;
  Contexto := TRttiContext.Create;
  try
    TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
    I := 0;
    for Prop in TypObj.GetProperties do
    begin
      for Atributo in Prop.GetAttributes do
      begin
        if (Atributo is FieldName) then
        begin
          SetLength(FieldsArr, I + 1);
          FieldsArr[I] := FieldName(Atributo).Name;
          Inc(I);
        end;
      end;
    end;
  finally
    Contexto.Free;
  end;

  sFields := EmptyStr;
  for I := 0 to Length(FieldsArr) - 1 do
  begin
    sFields := sFields + ifthen(I = 0, '', ',') + FieldsArr[I];
  end;

  sSQL :=
    'SELECT ' + sFields +
    '  FROM ' + GetTableName(Obj) +
    sCriteria +
    ' ORDER BY ' + AFieldOrder;

  Result := DM.getDataSet(sSQL);

  for I := 0 to Result.FieldCount - 1 do
  begin
    Result.Fields[I].Name := FieldsArr[I];
    Result.Fields[I].DisplayLabel := GetDisplayLabel(Obj, Result.Fields[I].FieldName, Visible);
    Result.Fields[I].Visible := Visible;
  end;
end;

class function TGenericDAO.Retrive<T>(Obj: T; AKeyValue: string): boolean;
var
  I: Integer;
  sSQL: string;
  sCriteria: string;
  sKeyField: string;
  DataSet: TDataSet;
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Prop: TRttiProperty;
  Atributo: TCustomAttribute;
  PropVal: TValue;
begin
  Result := False;
  sKeyField := GetKeyField(Obj);
  sSQL :=
    'SELECT T1.* ' +
    '  FROM ' + GetTableName(Obj) + ' T1 ' +
    ' WHERE ' + sKeyField + ' = ' + AKeyValue;

  DataSet := DM.getDataSet(sSQL);

  if DataSet.RecordCount > 0 then
  begin
    Contexto := TRttiContext.Create;
    try
      TypObj := Contexto.GetType(TObject(Obj).ClassInfo);

      for I := 0 to DataSet.FieldCount - 1 do
      begin
        for Prop in TypObj.GetProperties do
        begin
          if Prop.Name = 'IsPersisted' then
          begin
            PropVal := True;
            Prop.SetValue(TObject(Obj), PropVal);
          end;

          for Atributo in Prop.GetAttributes do
          begin
            if (Atributo is FieldName) and (UpperCase(FieldName(Atributo).Name) = UpperCase(DataSet.Fields[I].FieldName)) then
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
                  tkString, tkUString:
                    PropVal := DataSet.Fields[I].AsString;
                else
                  PropVal := DataSet.Fields[I].AsString;
                end;
              Prop.SetValue(TObject(Obj), PropVal);
            end;
          end;
        end;
      end;
      for Prop in TypObj.GetProperties do
      begin
        if Prop.Name = 'IsChange' then
        begin
          PropVal := False;
          Prop.SetValue(TObject(Obj), PropVal);
          Break;
        end;
      end;
      Result := True;
    finally
      Contexto.Free;
    end;
  end;
end;

end.
