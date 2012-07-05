unit uNumbers;

interface

uses SysUtils, Math;

const
  NUMBER_BASE = 10;
type
  {$IF NOT Defined(PtrUInt)}
  PtrUInt = Cardinal;
  {$IFEND}

  TDigit = 0..NUMBER_BASE - 1;
  TNumber = packed array of TDigit;                              // Rückwärts! Niederwertigste Stelle ist [0]

procedure NumberFromString(var Number: TNumber; Str: string);
function NumberToString(var Number: TNumber): string;

procedure NumberAdd(var Number, Summand: TNumber);
procedure NumberReverse(var Reversed, Number: TNumber);

function NumberCompare(var A, B: TNumber): boolean;

implementation

procedure NumberFromString(var Number: TNumber; Str: string);
var
  i: integer;
begin
  SetLength(Number, Length(Str));
  for i:= 0 to Length(Str) - 1 do
    Number[i]:= Ord(Str[Length(Str) - i]) - Ord('0');

end;

function NumberToString(var Number: TNumber): string;
var
  i: integer;
begin
  SetLength(Result, Length(Number));
  for i:= 0 to high(Number) do
    Result[Length(Result) - i]:= Chr(Ord('0') + Number[i]);

end;

procedure NumberAdd(var Number, Summand: TNumber);
var
  p: Cardinal;
  Numb, Summ, last: PByte;
begin
  if Length(Number) < Length(Summand) then
    SetLength(Number, Length(Summand));

  Numb:= @Number[0];
  Summ:= @Summand[0];

  //blind addieren
  last:= @Summand[high(Summand)];
  while PtrUInt(Summ)<=PtrUInt(last) do begin
    Inc(Numb^, Summ^);
    inc(Numb);
    Inc(Summ);
  end;

  //alle überläufer weiterschieben
  Numb:= @Number[0];
  last:= @Number[high(Number)];
  while PtrUInt(Numb)<PtrUInt(last) do begin
    if Numb^ >= NUMBER_BASE then begin
      dec(Numb^, NUMBER_BASE);
      inc(PByte(PtrUInt(Numb)+1)^);
    end;
    inc(Numb);
  end;
  //falls der letzte überlief, verlängern
  if Numb^ >= NUMBER_BASE then begin
    p:= Length(Number);
    SetLength(Number, p+1);
    Numb:= @Number[p-1]; // neu holen, der ist nach SetLength woanders
    dec(Numb^, NUMBER_BASE);
    inc(Numb);
    Numb^:= 1;
  end;
end;

procedure NumberReverse(var Reversed, Number: TNumber);
var
  i: integer;
  N, R: PByte;
begin
  SetLength(Reversed, Length(Number));
  N:= @Number[0];
  R:= @Reversed[high(Reversed)];
  for i:= high(Reversed) downto 0 do begin
    R^:= N^;
    Inc(N);
    Dec(R);
  end;
end;

function NumberCompare(var A, B: TNumber): boolean;
begin
  Result:= (Length(A) = Length(B)) and
    CompareMem(@A[0], @B[0], Length(A));
end;

end.

