{$G+}
{ [re] DOES A LABEL STOP THE COMPILER FOLDING THE BRANCH?

  A plain if never emits ClampDown's trampoline at any body length -- the
  sweep in SWEEP.PAS says so. Two goto shapes do. This asks the question in
  between: whether a LABEL, with no goto or with a goto that is not the
  guard, is enough on its own. A leftover label is an ordinary thing to find
  in code somebody was iterating on. }
unit Lbl;
interface
type RGBt = record r, g, b : Byte; end;
var
  Fading : Byte;
  Bright : Byte;
  Mark   : Byte;
  T      : array[0..255] of RGBt;
procedure L1; procedure L2; procedure L3; procedure L4; procedure L5;
implementation

{ L1 -- a label sitting at the head of the body, never jumped to }
procedure L1;
label
  Body;
var
  Loop : Byte;
begin
  Mark := 151;
  if Fading = 1 then
  begin
Body:
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
  end;
end;

{ L2 -- the label as the then-part itself }
procedure L2;
label
  Body;
var
  Loop : Byte;
begin
  Mark := 152;
  if Fading = 1 then
Body:
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

{ L3 -- a label at the head of the body, jumped to from inside it }
procedure L3;
label
  Body;
var
  Loop : Byte;
begin
  Mark := 153;
  if Fading = 1 then
  begin
Body:
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
    if Fading = 2 then goto Body;
  end;
end;

{ L4 -- a label after the if, jumped to from inside the body }
procedure L4;
label
  Done;
var
  Loop : Byte;
begin
  Mark := 154;
  if Fading = 1 then
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
    if Fading = 2 then goto Done;
  end;
Done:
end;

{ L5 -- the plain if, for reference }
procedure L5;
var
  Loop : Byte;
begin
  Mark := 155;
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

end.
