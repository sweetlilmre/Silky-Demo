{$G+}
{ [re] DOES A PLAIN if EVER EMIT THE TRAMPOLINE, AT ANY BODY LENGTH?

  ClampDown's guard is cmp / jne +2 / jmp +3 / jmp near. Every plain if tried
  so far folds that to cmp / je +3 / jmp near, but all of them had one body
  length. This sweeps the length across the short-jump boundary: each
  procedure is the same if with a different number of filler statements, so
  the only variable is how far the jump has to reach. }
unit Sweep;
interface
var
  Fading : Byte;
  Bright : Byte;
  Mark   : Byte;
procedure S1; procedure S2; procedure S3; procedure S4; procedure S5; procedure S6;
procedure S7; procedure S8; procedure S9; procedure S10; procedure S11; procedure S12;
procedure S13; procedure S14; procedure S15; procedure S16; procedure S17; procedure S18;
procedure S19; procedure S20; procedure S21; procedure S22; procedure S23; procedure S24;
implementation

procedure S1;
begin
  Mark := 101;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S2;
begin
  Mark := 102;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S3;
begin
  Mark := 103;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S4;
begin
  Mark := 104;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S5;
begin
  Mark := 105;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S6;
begin
  Mark := 106;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S7;
begin
  Mark := 107;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S8;
begin
  Mark := 108;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S9;
begin
  Mark := 109;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S10;
begin
  Mark := 110;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S11;
begin
  Mark := 111;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S12;
begin
  Mark := 112;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S13;
begin
  Mark := 113;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S14;
begin
  Mark := 114;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S15;
begin
  Mark := 115;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S16;
begin
  Mark := 116;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S17;
begin
  Mark := 117;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S18;
begin
  Mark := 118;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S19;
begin
  Mark := 119;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S20;
begin
  Mark := 120;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S21;
begin
  Mark := 121;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S22;
begin
  Mark := 122;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S23;
begin
  Mark := 123;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

procedure S24;
begin
  Mark := 124;
  if Fading = 1 then
  begin
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
    Inc(Bright);
  end;
end;

end.
