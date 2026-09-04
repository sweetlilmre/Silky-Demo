{$G+}
{ [re] WHAT EMITS CLAMPDOWN'S SEVEN-BYTE GUARD?

      80 3e 22 03 01   cmp byte ptr [Fading], 1
      75 02            jne  +2      -> onto the near jmp
      eb 03            jmp  +3      -> over it, into the body
      e9 9a 00         jmp  near epilogue

  The distinguishing feature is the POLARITY. Every spelling tried so far
  inverts the test and falls through into the body -- cmp / je +3 / jmp near,
  five bytes. The original keeps jne and reaches the body by a short jump, so
  whatever generated it emitted the false jump and the true jump as a PAIR
  and did not fold them.

  V1 is BASM jumping to a Pascal label: it inverts as well, so BASM resizes.
  Two spellings do not compile at all -- jne @Done, and a @@Done in a trailing
  asm block, both Error 82: BASM's local labels do not cross blocks.

  The rest are shapes where the compiler has a reason to emit both jumps. }

unit Basmg;
interface
type RGBt = record r, g, b : Byte; end;
var
  Fading : Byte;
  Bright : Byte;
  Other  : Byte;
  T      : array[0..255] of RGBt;
procedure V1; procedure V2; procedure V3; procedure V4;
procedure V5; procedure V6; procedure V7; procedure V8;
implementation

{ V1 -- BASM to a Pascal label. }
procedure V1;
label Done;
var Loop : Byte;
begin
  asm
    cmp Fading, 1
    jne Done
  end;
  for Loop := 0 to 255 do
  begin
    if T[Loop].r > Bright then T[Loop].r := Bright;
    if T[Loop].g > Bright then T[Loop].g := Bright;
    if T[Loop].b > Bright then T[Loop].b := Bright;
  end;
  Dec(Bright);
Done:
end;

{ V2 -- goto out, condition in Pascal, keeping the source polarity. }
procedure V2;
label Body, Done;
var Loop : Byte;
begin
  if Fading = 1 then goto Body;
  goto Done;
Body:
  for Loop := 0 to 255 do
  begin
    if T[Loop].r > Bright then T[Loop].r := Bright;
    if T[Loop].g > Bright then T[Loop].g := Bright;
    if T[Loop].b > Bright then T[Loop].b := Bright;
  end;
  Dec(Bright);
Done:
end;

{ V3 -- the body reached from a nested if, so the true path is not adjacent. }
procedure V3;
var Loop : Byte;
begin
  if Fading = 1 then
    if Fading = 1 then
    begin
      for Loop := 0 to 255 do
      begin
        if T[Loop].r > Bright then T[Loop].r := Bright;
        if T[Loop].g > Bright then T[Loop].g := Bright;
        if T[Loop].b > Bright then T[Loop].b := Bright;
      end;
      Dec(Bright);
    end;
end;

{ V4 -- a compound condition whose second operand is another variable. }
procedure V4;
var Loop : Byte;
begin
  if (Fading = 1) and (Other = 1) then
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
  end;
end;

{ V5 -- or, which makes the first test jump TO the body rather than past it. }
procedure V5;
var Loop : Byte;
begin
  if (Fading = 1) or (Other = 1) then
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
  end;
end;

{ V6 -- an else arm, so the compiler owns two forward jumps. }
procedure V6;
var Loop : Byte;
begin
  if Fading = 1 then
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
  end
  else
    Inc(Other);
end;

{ V7 -- the test in BASM, the branch left to Pascal through a flag. }
procedure V7;
label Done;
var Loop : Byte;
begin
  asm
    mov al, Fading
    cmp al, 1
    jne Done
  end;
  for Loop := 0 to 255 do
  begin
    if T[Loop].r > Bright then T[Loop].r := Bright;
    if T[Loop].g > Bright then T[Loop].g := Bright;
    if T[Loop].b > Bright then T[Loop].b := Bright;
  end;
  Dec(Bright);
Done:
end;

{ V8 -- repeat-until-true wrapped in the if, which gives the body a label. }
procedure V8;
var Loop : Byte;
begin
  if Fading = 1 then
  repeat
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
  until True;
end;

end.
