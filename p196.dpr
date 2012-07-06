{$APPTYPE console}
program p196;

uses
  FastMM4,
  SysUtils,
  Windows,
  uNumbers in 'uNumbers.pas';

const
  MaxCyc = 241389;
//  MaxCyc = 100000;
var
  N1, N2: TNumber;
  Time1, Time2, Freq: Int64;
  Cycle: Cardinal;
  s: string;
begin
  repeat
    Write('Startzahl: ');
    ReadLn(s);
    if s='' then
      break;
    NumberFromString(N1, s);
    QueryPerformanceFrequency(Freq);
    Cycle:= 0; // das erste ist kein cycle...
    QueryPerformanceCounter(Time1);
    repeat
      NextNumber(N2, N1);
      inc(Cycle);
      if (Cycle>=MaxCyc) or checkpali(n2) then begin
        {Ergebnis immer in N1}
        N1 := N2;
        break;
      end;
      NextNumber(N1, N2);
      inc(Cycle);
      if (Cycle>=MaxCyc) or checkpali(n1) then break;
      if Cycle mod 10000 = 0 then begin
        QueryPerformanceCounter(Time2);
        WriteLn(Cycle:10,' it',N1.Length:10,' dig',(Time2-Time1)/freq:14:1,' s');
      end;
    until false;
    QueryPerformanceCounter(Time2);
    s := NumberToString(N1);
    WriteLn('=');
    if Length(s) > 50 then s:= Copy(s, 1, 25) + ' ... ' + Copy(s, length(s) - 24, 25);
    WriteLn(s);
    WriteLn(Cycle:10,' it',N1.Length:10,' dig',(Time2-Time1)/freq:14:6,' s');
    WriteLn;
  until false;
end.

