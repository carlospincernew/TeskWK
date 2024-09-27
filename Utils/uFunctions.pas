unit uFunctions;

interface

Uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Dialogs, Vcl.StdCtrls;

function GetStrNumberInt(const S: string): string;
function GetStrNumberDecimal(const S: string): string;

implementation

function GetStrNumberInt(const S: string): string;
var
  vText : PChar;
begin
  vText := PChar(S);
  Result := '';

  while (vText^ <> #0) do
  begin
    {$IFDEF UNICODE}
    if CharInSet(vText^, ['0'..'9']) then
    {$ELSE}
    if vText^ in ['0'..'9'] then
    {$ENDIF}
      Result := Result + vText^;

    Inc(vText);
  end;
end;

function GetStrNumberDecimal(const S: string): string;
var
  vText : PChar;
begin
  vText := PChar(S);
  Result := '';

  while (vText^ <> #0) do
  begin
    {$IFDEF UNICODE}
    if (CharInSet(vText^, ['0'..'9'])) or (vText^ = '.') or (vText^ = ',') then
    {$ELSE}
    if (vText^ in ['0'..'9']) or (vText^ = '.') or (vText^ = ',') then
    {$ENDIF}
      Result := Result + vText^;

    Inc(vText);
  end;
end;

end.
