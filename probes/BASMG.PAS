{$G+}
{ [re] TWELVE SHAPES AGAINST CLAMPDOWN'S SEVEN-BYTE GUARD.

      80 3e 22 03 01 / 75 02 / eb 03 / e9 9a 00

  The question is not which shapes emit it -- one already does -- but whether
  the one that does is the only one, because a shape that reproduces bytes is
  not thereby the shape somebody wrote. Every procedure here carries the same
  156-byte body, so any difference is the guard. }
unit Basmg;
interface
type RGBt = record r, g, b : Byte; end;
var
  Fading : Byte;
  Bright : Byte;
  Skip   : Boolean;
  Mark   : Byte;
  T      : array[0..255] of RGBt;
procedure V1; procedure V2; procedure V3; procedure V4;
procedure V5; procedure V6; procedure V7; procedure V8;
procedure V9; procedure V10; procedure V11; procedure V12;
implementation

{ V1 -- if-then-goto-Body plus goto-Done, the shape that matched }
procedure V1;
label
  Body, Done;
var
  Loop : Byte;
begin
  Mark := 201;   { [re] tags this procedure in the object code }
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

{ V2 -- the same written as one if-then-else of two gotos }
procedure V2;
label
  Body, Done;
var
  Loop : Byte;
begin
  Mark := 202;   { [re] tags this procedure in the object code }
  if Fading = 1 then goto Body else goto Done;
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

{ V3 -- if-then-goto over an Exit, so only one label is needed }
procedure V3;
label
  Body;
var
  Loop : Byte;
begin
  Mark := 203;   { [re] tags this procedure in the object code }
  if Fading = 1 then goto Body;
  Exit;
Body:
  for Loop := 0 to 255 do
  begin
    if T[Loop].r > Bright then T[Loop].r := Bright;
    if T[Loop].g > Bright then T[Loop].g := Bright;
    if T[Loop].b > Bright then T[Loop].b := Bright;
  end;
  Dec(Bright);
end;

{ V4 -- a case on the byte, single arm }
procedure V4;
var
  Loop : Byte;
begin
  Mark := 204;   { [re] tags this procedure in the object code }
  case Fading of
    1 :
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
end;

{ V5 -- a case with an else arm }
procedure V5;
var
  Loop : Byte;
begin
  Mark := 205;   { [re] tags this procedure in the object code }
  case Fading of
    1 :
      begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
      end;
  else
  end;
end;

{ V6 -- while used as a guard, leaving by assignment }
procedure V6;
var
  Loop : Byte;
begin
  Mark := 206;   { [re] tags this procedure in the object code }
  while Fading = 1 do
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
    Fading := 2;
  end;
end;

{ V7 -- the plain if, but the routine also contains a label and a goto }
procedure V7;
label
  Done;
var
  Loop : Byte;
begin
  Mark := 207;   { [re] tags this procedure in the object code }
  if Fading = 1 then
  begin
    for Loop := 0 to 255 do
    begin
      if T[Loop].r > Bright then T[Loop].r := Bright;
      if T[Loop].g > Bright then T[Loop].g := Bright;
      if T[Loop].b > Bright then T[Loop].b := Bright;
    end;
    Dec(Bright);
    goto Done;
  end;
Done:
end;

{ V8 -- if-then-else where the else is a goto to the end }
procedure V8;
label
  Done;
var
  Loop : Byte;
begin
  Mark := 208;   { [re] tags this procedure in the object code }
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
  else goto Done;
Done:
end;

{ V9 -- the condition through a Boolean variable }
procedure V9;
var
  Loop : Byte;
begin
  Mark := 209;   { [re] tags this procedure in the object code }
  Skip := Fading <> 1;
  if not Skip then
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

{ V10 -- repeat-until-true wrapping the if }
procedure V10;
var
  Loop : Byte;
begin
  Mark := 210;   { [re] tags this procedure in the object code }
  repeat
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
  until True;
end;

{ V11 -- if-then-else with the body in the else arm }
procedure V11;
var
  Loop : Byte;
begin
  Mark := 211;   { [re] tags this procedure in the object code }
  if Fading <> 1 then
  else
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

{ V12 -- the plain if, for reference }
procedure V12;
var
  Loop : Byte;
begin
  Mark := 212;   { [re] tags this procedure in the object code }
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
