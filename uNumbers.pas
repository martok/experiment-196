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
  TNumber = packed array of TDigit;                         // Rückwärts! Niederwertigste Stelle ist [0]

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
function NumberToString(var Number: TNumber): string;

procedure NumberAdd(var Number, Summand: TNumber);
procedure NumberReverse(var Reversed, Number: TNumber);
procedure NumberAddReversed(var Number: TNumber);

function NumberCompare(var A, B: TNumber): boolean;
function NumberCheckPalindrome(var Number: TNumber): boolean;

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
  last: PByte;
begin
  if Length(Number) < Length(Summand) then
    SetLength(Number, Length(Summand));

  //blind addieren
  last:= @Summand[high(Summand)];
  asm
    mov ebx, last          // last -> ebx
    mov ecx, Number        // @Number[0] -> ecx
    mov ecx, [ecx]
    mov edx, Summand       // @Summand[0] -> edx
    mov edx, [edx]

    jmp @@2                //while-kopf
    @@1:
    mov al, [edx]          // summand^
    add [ecx], al          // number^ += al
    inc ecx                // number++
    inc edx                // summand++
    @@2:                   //while
    cmp edx, ebx           // summand <= ebx repeat
    jbe @@1
  end;

  //alle überläufer weiterschieben
  last:= @Number[high(Number)];
  asm
      mov ebx, last                      // last -> ebx
      mov ecx, Number                    // @Number[0] -> ecx
      mov ecx, [ecx]

      jmp @@2                            //while-kopf
      @@1:
      cmp byte ptr [ecx], NUMBER_BASE    // number^ < BASE?
      jb @@nochg
      sub byte ptr [ecx], NUMBER_BASE    // number^-= BASE
      lea edx,[ecx+1]                    // byte danach
      inc byte ptr [edx]                 // [number+1]^+=1
      @@nochg:
      inc ecx                            // number++
      @@2:                               //while
      cmp ecx, ebx                       // summand < ebx repeat
      jb @@1
  end;

  //falls der letzte überlief, verlängern
  if last^ >= NUMBER_BASE then begin
    p:= Length(Number);
    SetLength(Number, p + 1);
    asm
      mov ebx, Number                    // @Number[0] -> ecx
      mov ebx, [ebx]
      add ebx, p                         // auf [p]
      mov byte ptr [ebx], 1              // 1 setzen
      dec ebx
      sub byte ptr [ebx], NUMBER_BASE    // [number-1]^-= BASE
    end;
  end;
end;

procedure NumberReverse(var Reversed, Number: TNumber);
var
  R: PByte;
begin
  SetLength(Reversed, Length(Number));
  R:= @Reversed[high(Reversed)];
  asm
    push ebx
    mov edx, R             // R -> edx
    mov ecx, Number        // @Number[0] -> ecx
    mov ecx, [ecx]
    mov ebx, Reversed      // @Reversed[0] -> ecx
    mov ebx, [ebx]

    jmp @@2                //while-kopf
    @@1:
    mov al, [ecx]          // number^ -> al
    mov [edx], al          // al -> rev^
    inc ecx                // number++
    dec edx                // rev--
    @@2:                   //while
    cmp edx, ebx           // rev>=reversed[0] repeat
    jge @@1
    pop ebx
  end;
end;

procedure NumberAddReversed(var Number: TNumber);
var
  p: Cardinal;
  last: PByte;
  rest: boolean;
begin
  asm
    push ebx
  end;
  last:= @Number[high(Number)];
  p:= (length(Number) div 2) div 4;
  asm
    mov ecx, Number                   // ecx links nach rechts
    mov ecx, [ecx]
    mov edx, last                     // edx rechts nach links
    sub edx, 3

    //erstmal in DWORD-schritten
    mov ebx, p
    jmp @@2                           //while-kopf
    @@1:
    mov eax, [edx]                    // 4 ziffern von hinten
    bswap eax
    add eax, [ecx]                    // 4 ziffern addieren

    mov dword ptr [ecx], eax          // wieder...
    bswap eax                         // ...richtigrum...
    mov dword ptr [edx], eax          // ...zurückschreiben

    add ecx, 4
    sub edx, 4

    dec ebx
    @@2:                              //while
    cmp ebx, 0                        // der von links kommt <= ebx repeat
    jg @@1

    @@single:
    add edx, 3

    // restliche stellen verarbeiten
    jmp @@20                           //while-kopf
    @@10:
    mov al, [edx]                     // al = rechts
    add al, [ecx]                     // al+= links

    mov byte ptr [ecx], al            // speichern in number
    mov byte ptr [edx], al            // ...

    inc ecx                           // number++
    dec edx                           // summand++

    @@20:                              //while
    cmp ecx, edx                      // der von links kommt <= ebx repeat
    jle @@10
  end;

  //alle überläufer weiterschieben
  last:= @Number[high(Number)];
  asm
      mov ecx, Number                    // @Number[0] -> ecx
      mov ecx, [ecx]

      xor eax,eax                        //carry direkt als summe!
      jmp @@2                            //while-kopf
      @@1:
        add al, byte ptr [ecx]           //stelle addieren
        lea edx, [SumCarFeld+eax*2]             //wo sind wir in der tabelle?
        mov al, byte ptr [edx]           //wert
        mov byte ptr [ecx], al
        mov al, byte ptr [edx+1]         //carry für nächste runde

        inc ecx
      @@2:                               //while
      cmp ecx, last                      // summand < ebx repeat
      jbe @@1

      mov rest, al                       //rausreichen
  end;

  //falls der letzte überlief, verlängern
  if rest then begin
    p:= Length(Number);
    SetLength(Number, p + 1);
    asm
      mov ebx, Number                    // @Number[0] -> ecx
      mov ebx, [ebx]
      add ebx, p                         // auf [p]
      mov byte ptr [ebx], 1              // 1 setzen
    end;
  end;
  asm
    pop ebx
  end;
end;

function NumberCompare(var A, B: TNumber): boolean;
begin
  Result:= (Length(A) = Length(B)) and
    CompareMem(@A[0], @B[0], Length(A));
end;

function NumberCheckPalindrome(var Number: TNumber): boolean;
var
  p: Cardinal;
  last, middle: PByte;
begin
  last:= @Number[high(Number)];
  p:= length(Number) div 2;
  if not odd(Length(Number)) then
    dec(p);
  middle:= @Number[p];
  asm
    mov ebx, middle                   // ebx > Ende
    mov ecx, Number                   // ecx links nach rechts
    mov ecx, [ecx]
    mov edx, last                     // edx rechts nach links

    jmp @@2                           //while-kopf
    @@1:
    mov al, [edx]                     // al = rechts
    xor al, [ecx]                     // al^= links
    test al,al                        // al=0? (rechts==links)
    je @@continue

    mov Result, false                 // result false
    jmp @@end

    @@continue:
    inc ecx                           // number++
    dec edx                           // summand++

    @@2:                              //while
    cmp ecx, ebx                      // der von links kommt <= ebx repeat
    jbe @@1

    mov Result, true
    @@end:
  end;
end;

end.

