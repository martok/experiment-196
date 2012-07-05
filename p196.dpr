{$APPTYPE console}
program p196;

uses
  FastMM4,
  SysUtils,
  Windows,
  uNumbers in 'uNumbers.pas';

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
{.$DEFINE TEST}
{$IFDEF TEST}
    NumberFromString(Rev, '1');
    NumberAdd(Work, Rev);
    WriteLn(NumberToString(Work));
    continue;
{$ENDIF}


    QueryPerformanceFrequency(Freq);
    Cycle:= 0; // das erste ist kein cycle...
    QueryPerformanceCounter(Time1);
    NumberReverse(Rev, Work);
    repeat
      NumberAdd(Work, Rev);
      NumberReverse(Rev, Work);
      inc(Cycle);
      if Cycle mod 200 = 0 then begin
        QueryPerformanceCounter(Time2);
        WriteLn(Cycle:10,' it',Length(Work):10,' dig',(Time2-Time1)/freq:14:1,' s');
      end;
      if Length(Work)>=20000 then break;
    until NumberCompare(rev, Work);
    QueryPerformanceCounter(Time2);
    WriteLn('=');
    WriteLn(Cycle:10,' it',Length(Work):10,' dig',(Time2-Time1)/freq:14:6,' s');
    s:= NumberToString(Work);
    if Length(s) > 50 then
      s:= Copy(s, 1, 25) + ' ... ' + Copy(s, length(s)-25, 25);
    WriteLn(s);
    WriteLn;
    WriteLn;
    WriteLn;
  until false;
end.

