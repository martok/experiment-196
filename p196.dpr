{$APPTYPE console}
program p196;

uses
  FastMM4,
  SysUtils, Windows, Math;

const
  NUMBER_BASE = 10;
type
  TDigit = 0..NUMBER_BASE - 1;
  TNumber = array of TDigit;                                // Rückwärts! Niederwertigste Stelle ist [0]

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
  for i:= 0 to High(Number) do
    Result[Length(Result) - i]:= Chr(Ord('0') + Number[i]);
end;

procedure NumberAdd(var Number, Summand: TNumber);
var
  p: integer;
  Sum, Dig, Carry: Word;
begin
  if Length(Number) < Length(Summand) then
    SetLength(Number, Length(Summand));
  Carry:= 0;
  for p:= 0 to high(Summand) do begin
    Sum:= Carry + Number[p] + Summand[p];
    DivMod(Sum, NUMBER_BASE, Carry, Dig);
    Number[p]:= Dig;
  end;
  for p:= high(Summand) + 1 to high(Number) do begin
    Sum:= Carry + Number[p];
    DivMod(Sum, NUMBER_BASE, Carry, Dig);
    Number[p]:= Dig;
  end;
  if Carry > 0 then begin
    SetLength(Number, Length(Number) + 1);
    Number[high(Number)]:= Carry;
  end;
end;

procedure NumberReverse(var Reversed, Number: TNumber);
var
  i: integer;
begin
  SetLength(Reversed, Length(Number));
  for i:= 0 to high(Number) do
    Reversed[high(Reversed) - i]:= Number[i];
end;

function NumberCompare(var A, B: TNumber): boolean;
begin
  Result:= (high(A) = high(B)) and
    CompareMem(@A[0], @B[0], Length(A));
end;

var
  Work, Rev: TNumber;
  Time1, Time2, Freq: Int64;
  Cycle: Cardinal;
  s: string;
begin
  repeat
    Write('Startzahl: ');
    ReadLn(s);
    if s='' then
      break;
    NumberFromString(Work, s);
    QueryPerformanceFrequency(Freq);
    Cycle:= 0; // das erste ist kein cycle...
    QueryPerformanceCounter(Time1);
    NumberReverse(Rev, Work);
    repeat
      NumberAdd(Work, Rev);
      NumberReverse(Rev, Work);
      inc(Cycle);
      if Cycle mod 100 = 0 then begin
        QueryPerformanceCounter(Time2);
        WriteLn(Cycle:10,' it',Length(Work):10,' dig',(Time2-Time1)/freq:14:1,' s');
      end;
    until NumberCompare(rev, Work);
    QueryPerformanceCounter(Time2);
    WriteLn('=');
    WriteLn(Cycle:10,' it',Length(Work):10,' dig',(Time2-Time1)/freq:14:6,' s');
    WriteLn(NumberToString(Work));
    WriteLn;
    WriteLn;
    WriteLn;
  until false;
end.

