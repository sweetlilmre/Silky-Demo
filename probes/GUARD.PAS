{$G+}
{ WHAT THIS PROBE MEASURES.

  1000:09fb guards its body with SEVEN bytes:

      80 3e 22 03 01   cmp byte ptr [Fading], 1
      75 02            jne  +2      -> lands on the near jmp
      eb 03            jmp  +3      -> over the near jmp, into the body
      e9 9a 00         jmp  near epilogue

  Every construct tried here emits the COMPACT five instead -- one conditional
  straight over a near jmp, with no trampoline:

      cmp byte ptr [x], k
      74/75 03
      e9 xx xx

  So the extra `eb 03` does not come from the shape of the if, nor from the
  type of the thing tested. Ten variants have been run: if/begin-end,
  if-not-then-Exit, if with an empty else, if with a goto, double negation,
  a bare Boolean, Boolean compared with True, an enumerated type, a subrange,
  and a body ending in Exit. All ten compile to the compact form under both
  TP600 and TP601, which also produce byte-identical output for each other.

  Keep this probe. A negative result is only worth anything while the thing
  that produced it can be re-run. }

unit Guard;
interface
type
  TState = (sOff, sOn, sDone);
var
  Flag  : Byte;
  BFlag : Boolean;
  SFlag : TState;
  Sub   : 0..3;
  Sink  : Word;
procedure V1; procedure V2; procedure V3; procedure V4; procedure V5;
implementation

procedure V1;      { bare Boolean -- cmp against 0, still compact }
begin
  if BFlag then
  begin
    Sink := Sink + 1;
    Sink := Sink + 2;
    Sink := Sink + 3;
    Sink := Sink + 4;
    Sink := Sink + 5;
    Sink := Sink + 6;
    Sink := Sink + 7;
    Sink := Sink + 8;
    Sink := Sink + 9;
    Sink := Sink + 10;
    Sink := Sink + 11;
    Sink := Sink + 12;
    Sink := Sink + 13;
    Sink := Sink + 14;
    Sink := Sink + 15;
    Sink := Sink + 16;
    Sink := Sink + 17;
    Sink := Sink + 18;
    Sink := Sink + 19;
    Sink := Sink + 20;
    Sink := Sink + 21;
    Sink := Sink + 22;
    Sink := Sink + 23;
    Sink := Sink + 24;
    Sink := Sink + 25;
    Sink := Sink + 26;
    Sink := Sink + 27;
    Sink := Sink + 28;
    Sink := Sink + 29;
    Sink := Sink + 30;
    Sink := Sink + 31;
    Sink := Sink + 32;
    Sink := Sink + 33;
    Sink := Sink + 34;
    Sink := Sink + 35;
    Sink := Sink + 36;
    Sink := Sink + 37;
    Sink := Sink + 38;
    Sink := Sink + 39;
    Sink := Sink + 40;
    Sink := Sink + 41;
    Sink := Sink + 42;
    Sink := Sink + 43;
    Sink := Sink + 44;
    Sink := Sink + 45;
  end;
end;

procedure V2;      { Boolean compared with True -- cmp against 1, compact }
begin
  if BFlag = True then
  begin
    Sink := Sink + 1;
    Sink := Sink + 2;
    Sink := Sink + 3;
    Sink := Sink + 4;
    Sink := Sink + 5;
    Sink := Sink + 6;
    Sink := Sink + 7;
    Sink := Sink + 8;
    Sink := Sink + 9;
    Sink := Sink + 10;
    Sink := Sink + 11;
    Sink := Sink + 12;
    Sink := Sink + 13;
    Sink := Sink + 14;
    Sink := Sink + 15;
    Sink := Sink + 16;
    Sink := Sink + 17;
    Sink := Sink + 18;
    Sink := Sink + 19;
    Sink := Sink + 20;
    Sink := Sink + 21;
    Sink := Sink + 22;
    Sink := Sink + 23;
    Sink := Sink + 24;
    Sink := Sink + 25;
    Sink := Sink + 26;
    Sink := Sink + 27;
    Sink := Sink + 28;
    Sink := Sink + 29;
    Sink := Sink + 30;
    Sink := Sink + 31;
    Sink := Sink + 32;
    Sink := Sink + 33;
    Sink := Sink + 34;
    Sink := Sink + 35;
    Sink := Sink + 36;
    Sink := Sink + 37;
    Sink := Sink + 38;
    Sink := Sink + 39;
    Sink := Sink + 40;
    Sink := Sink + 41;
    Sink := Sink + 42;
    Sink := Sink + 43;
    Sink := Sink + 44;
    Sink := Sink + 45;
  end;
end;

procedure V3;      { enumerated }
begin
  if SFlag = sOn then
  begin
    Sink := Sink + 1;
    Sink := Sink + 2;
    Sink := Sink + 3;
    Sink := Sink + 4;
    Sink := Sink + 5;
    Sink := Sink + 6;
    Sink := Sink + 7;
    Sink := Sink + 8;
    Sink := Sink + 9;
    Sink := Sink + 10;
    Sink := Sink + 11;
    Sink := Sink + 12;
    Sink := Sink + 13;
    Sink := Sink + 14;
    Sink := Sink + 15;
    Sink := Sink + 16;
    Sink := Sink + 17;
    Sink := Sink + 18;
    Sink := Sink + 19;
    Sink := Sink + 20;
    Sink := Sink + 21;
    Sink := Sink + 22;
    Sink := Sink + 23;
    Sink := Sink + 24;
    Sink := Sink + 25;
    Sink := Sink + 26;
    Sink := Sink + 27;
    Sink := Sink + 28;
    Sink := Sink + 29;
    Sink := Sink + 30;
    Sink := Sink + 31;
    Sink := Sink + 32;
    Sink := Sink + 33;
    Sink := Sink + 34;
    Sink := Sink + 35;
    Sink := Sink + 36;
    Sink := Sink + 37;
    Sink := Sink + 38;
    Sink := Sink + 39;
    Sink := Sink + 40;
    Sink := Sink + 41;
    Sink := Sink + 42;
    Sink := Sink + 43;
    Sink := Sink + 44;
    Sink := Sink + 45;
  end;
end;

procedure V4;      { subrange }
begin
  if Sub = 1 then
  begin
    Sink := Sink + 1;
    Sink := Sink + 2;
    Sink := Sink + 3;
    Sink := Sink + 4;
    Sink := Sink + 5;
    Sink := Sink + 6;
    Sink := Sink + 7;
    Sink := Sink + 8;
    Sink := Sink + 9;
    Sink := Sink + 10;
    Sink := Sink + 11;
    Sink := Sink + 12;
    Sink := Sink + 13;
    Sink := Sink + 14;
    Sink := Sink + 15;
    Sink := Sink + 16;
    Sink := Sink + 17;
    Sink := Sink + 18;
    Sink := Sink + 19;
    Sink := Sink + 20;
    Sink := Sink + 21;
    Sink := Sink + 22;
    Sink := Sink + 23;
    Sink := Sink + 24;
    Sink := Sink + 25;
    Sink := Sink + 26;
    Sink := Sink + 27;
    Sink := Sink + 28;
    Sink := Sink + 29;
    Sink := Sink + 30;
    Sink := Sink + 31;
    Sink := Sink + 32;
    Sink := Sink + 33;
    Sink := Sink + 34;
    Sink := Sink + 35;
    Sink := Sink + 36;
    Sink := Sink + 37;
    Sink := Sink + 38;
    Sink := Sink + 39;
    Sink := Sink + 40;
    Sink := Sink + 41;
    Sink := Sink + 42;
    Sink := Sink + 43;
    Sink := Sink + 44;
    Sink := Sink + 45;
  end;
end;

procedure V5;      { Byte, body ending in an explicit Exit }
begin
  if Flag = 1 then
  begin
    Sink := Sink + 1;
    Sink := Sink + 2;
    Sink := Sink + 3;
    Sink := Sink + 4;
    Sink := Sink + 5;
    Sink := Sink + 6;
    Sink := Sink + 7;
    Sink := Sink + 8;
    Sink := Sink + 9;
    Sink := Sink + 10;
    Sink := Sink + 11;
    Sink := Sink + 12;
    Sink := Sink + 13;
    Sink := Sink + 14;
    Sink := Sink + 15;
    Sink := Sink + 16;
    Sink := Sink + 17;
    Sink := Sink + 18;
    Sink := Sink + 19;
    Sink := Sink + 20;
    Sink := Sink + 21;
    Sink := Sink + 22;
    Sink := Sink + 23;
    Sink := Sink + 24;
    Sink := Sink + 25;
    Sink := Sink + 26;
    Sink := Sink + 27;
    Sink := Sink + 28;
    Sink := Sink + 29;
    Sink := Sink + 30;
    Sink := Sink + 31;
    Sink := Sink + 32;
    Sink := Sink + 33;
    Sink := Sink + 34;
    Sink := Sink + 35;
    Sink := Sink + 36;
    Sink := Sink + 37;
    Sink := Sink + 38;
    Sink := Sink + 39;
    Sink := Sink + 40;
    Sink := Sink + 41;
    Sink := Sink + 42;
    Sink := Sink + 43;
    Sink := Sink + 44;
    Sink := Sink + 45;
    Exit;
  end;
end;

end.
