unit uNumbers;
{$IFDEF FPC}
  {$MODE DELPHI}
  {$Optimization ON}
  {$Optimization RegVar}
  {$Optimization PEEPHOLE}
  {$Optimization CSE}
  {$Optimization ASMCSE}
{$Endif}
interface

uses SysUtils, Math;

const
  NUMBER_BASE = 10;
type
  TDigit = 0..NUMBER_BASE - 1;
  TDigits = packed array of byte;
  TNumber = packed record
    Length: integer;
    Digits: TDigits;
  end;
  TSumCar = record
             s,c : byte;
            end;
  TSumCarFeld = array[0..19] of TsumCar;             
const  
  SumCarFeld : TSumCarFeld =((s:0;c:0),(s:1;c:0),(s:2;c:0),(s:3;c:0),(s:4;c:0),
                             (s:5;c:0),(s:6;c:0),(s:7;c:0),(s:8;c:0),(s:9;c:0),
                             (s:0;c:1),(s:1;c:1),(s:2;c:1),(s:3;c:1),(s:4;c:1),
                             (s:5;c:1),(s:6;c:1),(s:7;c:1),(s:8;c:1),(s:9;c:1));
                             
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
  p,j,carry: integer;
begin
  Setlength(NewNum.Digits,OldNum.Length+1);
  NewNum.Length := OldNum.Length;
  carry := 0;
  j:= OldNum.Length-1;
  for p:= 0 to OldNum.Length-1 do 
    begin
    With SumCarFeld[OldNum.Digits[p] + OldNum.Digits[j] + carry] do
      begin
      NewNum.Digits[p] := s;
      Carry := c;
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

