unit uNumbers;

interface

uses SysUtils, Math;

const
  NUMBER_BASE = 10;
type
  TDigit = 0..NUMBER_BASE - 1;
  TDigits = packed array of word;
  TNumber = packed record
    Length: integer;
    Digits: TDigits;
  end;

procedure NumberFromString(var Number: TNumber; Str: string);
function  NumberToString(var Number: TNumber): string;

procedure NextNumber(var NewNum, OldNum: TNumber);

function  CheckPali(var A: TNumber): boolean;

implementation

procedure NumberFromString(var Number: TNumber; Str: string);
var
  i: integer;
begin
  SetLength(Number.Digits, Length(Str));
  Number.Length:= Length(str);
  for i:= 0 to Length(Str) - 1 do begin
    Number.Digits[i]:= Ord(Str[Length(Str) - i]) - Ord('0');
  end;
end;

function NumberToString(var Number: TNumber): string;
var
  i: integer;
begin
  SetLength(Result, Number.Length);
  for i:= 0 to Number.Length-1 do begin
    Result[Length(Result) - i]:= Chr(Ord('0') + Number.Digits[i]);
  end;
end;

procedure NextNumber(var NewNum, OldNum: TNumber);
var
  p,j,sum,carry: integer;
begin
  Setlength(NewNum.Digits,OldNum.Length+1);
  NewNum.Length := OldNum.Length;
  carry := 0;
  j:= OldNum.Length-1;
  for p:= 0 to OldNum.Length-1 do begin
    Sum:= OldNum.Digits[p] + OldNum.Digits[j] + carry;
    if Sum >= NUMBER_BASE then begin
      NewNum.Digits[p]:= Sum-NUMBER_BASE;
      carry := 1;
    end
    else begin
      NewNum.Digits[p]:= Sum;
      carry := 0;
    end;
    dec(j);
  end;
  NewNum.Digits[NewNum.Length] := carry;
  if (carry<>0) then inc(NewNum.Length);
end;

function  CheckPali(var A: TNumber): boolean;
var
  p,j: integer;
begin
  p := 0;
  j := A.Length-1;
  result := false;
  while p<=j do begin
    if A.Digits[p]<>A.Digits[j] then exit;
    inc(p);
    dec(j);
  end;
  result := true;
end;

end.

