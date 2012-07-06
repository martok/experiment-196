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
  last, middle: PByte;
begin
  asm
    push ebx
  end;
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
    add al, [ecx]                     // al+= links

    mov byte ptr [ecx], al            // speichern in number
    mov byte ptr [edx], al            // ...

    inc ecx                           // number++
    dec edx                           // summand++

    @@2:                              //while
    cmp ecx, ebx                      // der von links kommt <= ebx repeat
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

