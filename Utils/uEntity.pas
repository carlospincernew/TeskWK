unit uEntity;

interface

Uses Db, Rtti, uAttributeEntity, TypInfo, SysUtils, udmConnection, uConstant,
  Datasnap.DBClient, Classes, System.Generics.Collections, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.StrUtils;

type
  TGenValue = array of Variant;

  TCriterion = class(TCollectionItem)
  private
    FAttribute: string;
    FCriterionType: TCriterionType;
    FValue: TGenValue;
    FValueFMT: string;
    FValueOperator: string;
    FLineEnd: string;
    FValueType: TFieldType;
    function GetValueOperator: string;
    function GetValueFMT: string;
    function GetLineEnd: string;
    function GetFormatValue(AValue: Variant): string;
  published
    property Value: TGenValue read FValue write FValue;
    property Attribute: string read FAttribute write FAttribute;
    property CriterionType: TCriterionType read FCriterionType;
    property ValueType: TFieldType read FValueType write FValueType;
    property ValueOperator: string read GetValueOperator;
    property ValueFMT: string read GetValueFMT;
    property LineEnd: string read GetLineEnd;
  end;

  TCriteria = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCriterion;
    procedure SetItem(Index: Integer; const Value: TCriterion);
  public
    constructor Create(AOwner: TPersistent);
    function Add(ACriterionType: TCriterionType; AAttribute: string; AValueType: TFieldType; const AValue: array of Variant): TCriterion;
    property Items[Index: Integer]: TCriterion read GetItem write SetItem; default;
  end;

  TGenericEntity = class
  private
    FContexto: TRttiContext;
    FTypObj: TRttiType;
    FStateMode: TStateMode;
    FCriteria: TCriteria;
    FIsPersisted: Boolean;
    FIsChange: Boolean;
  public
    constructor Create();
    destructor Destroy; override;
    property Contexto: TRttiContext read FContexto write FContexto;
    property TypObj: TRttiType read FTypObj write FTypObj;
    property StateMode: TStateMode read FStateMode write FStateMode;
    property Criteria: TCriteria read FCriteria write FCriteria;
    property IsPersisted: Boolean read FIsPersisted write FIsPersisted;
    property IsChange: Boolean read FIsChange write FIsChange;
  end;

implementation


{ TGenericEntity }

constructor TGenericEntity.Create;
begin
  FContexto := TRttiContext.Create;
  FCriteria := TCriteria.Create(nil);
  IsPersisted := False;
  IsChange := True;
  StateMode := smBrowse;
end;

destructor TGenericEntity.Destroy;
begin
  Contexto.Free;
  if Assigned(FCriteria) then
    FCriteria.Free;
  inherited;
end;

{ TCriteria }

function TCriteria.Add(ACriterionType: TCriterionType; AAttribute: string; AValueType: TFieldType;
  const AValue: array of Variant): TCriterion;
var
  I: Integer;
begin
  Result := TCriterion(inherited Add);
  Result.FCriterionType := ACriterionType;
  Result.FAttribute := AAttribute;
  Result.FValueType := AValueType;
  SetLength(Result.FValue, High(AValue) + 1);
  for I := Low(AValue) to High(AValue) do
    Result.FValue[I] := AValue[I];
end;

constructor TCriteria.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCriterion);
end;

function TCriteria.GetItem(Index: Integer): TCriterion;
begin
  Result := TCriterion(inherited Items[Index]);
end;

procedure TCriteria.SetItem(Index: Integer; const Value: TCriterion);
begin
  Items[Index] := Value;
end;

function TCriterion.GetValueOperator: string;
begin
  case FCriterionType of
    ctEqualTo:
      FValueOperator := ' = ';
    ctLike:
      FValueOperator := ' LIKE ';
    ctGreaterOrEqualThan:
      FValueOperator := ' >= ';
    ctLessOrEqualThan:
      FValueOperator := ' <= ';
    ctBetween:
      FValueOperator := ' BETWEEN ';
    ctIn:
      FValueOperator := ' IN ( ';
    ctIsNull:
      FValueOperator := ' IS NULL ';
  end;
  Result := FValueOperator;
end;

function TCriterion.GetFormatValue(AValue: Variant): string;
begin
  case FValueType of
    ftString, ftFmtMemo, ftWideString, ftWideMemo, ftFixedWideChar:
      Result := QuotedStr(AValue);
    ftDate, ftTimeStamp, ftDateTime:
      Result := QuotedStr(FormatDateTime('dd.mm.yyyy', StrToDateDef(AValue, 0)));
  else
    Result := AValue;
  end;
end;

function TCriterion.GetLineEnd: string;
begin
  if FCriterionType = ctIn then
    Result := ')';
  FLineEnd := Result;
end;

function TCriterion.GetValueFMT: string;
var
  I: Integer;
begin
  case FCriterionType of
    ctLike:
      begin
        if Length(FValue) > 0 then
          FValueFMT := QuotedStr('%' + FValue[0] + '%');
      end;
    ctBetween:
      begin
        if Length(FValue) > 1 then
          FValueFMT := GetFormatValue(FValue[0]) + ' AND ' + GetFormatValue(FValue[1]);
      end;
    ctIn:
      begin
        for I := 0 to Length(FValue) do
        begin
          if I = 0 then
            FValueFMT := GetFormatValue(FValue[I])
          else
            FValueFMT := ',' + GetFormatValue(FValue[I]);
        end;
      end;
  else
    FValueFMT := GetFormatValue(FValue[0]);
  end;
  Result := FValueFMT;
end;


end.
