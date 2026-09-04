{$G+}
{ SOLVED -- SEE probes/BASMG.PAS. This probe's negative result was real and
  its conclusion was wrong. Sixteen spellings of `if Fading = 1 then` all
  emit the compact five bytes, and from that this file concluded the
  difference was in the CODE GENERATOR. It was in the source: the original's
  guard keeps the polarity of its test, which an `if` never needs to do and
  which `if Fading = 1 then goto Body; goto Done;` does exactly. Sixteen ways
  of writing one construct are one experiment, not sixteen. Kept because the
  negative result is still true and still useful, and because the wrong
  inference is worth being able to find again.

  WHAT THIS PROBE MEASURES, and it is a NEGATIVE result.

  1000:09fb guards its body with SEVEN bytes:

      80 3e 22 03 01   cmp byte ptr [Fading], 1
      75 02            jne  +2      -> onto the near jmp
      eb 03            jmp  +3      -> over it, into the body
      e9 9a 00         jmp  near epilogue

  Sixteen constructs have now been put through the real compiler and NOT ONE
  emits it. With a body under 127 bytes `if Flag = 1 then` emits a single
  short `jne` straight over the body -- the same POLARITY as the original,
  which is what made this look solvable. With a body of 156 bytes, which is
  what ClampDown really has, the same construct emits the compact five:

      80 3e xx xx 01   cmp
      74 03            je   +3
      e9 9a 00         jmp  near epilogue

  and the near displacement 9a 00 is the ORIGINAL'S, so the body length is
  right and only the branch differs. Tried across three passes: if/begin-end,
  if-not-then-Exit, empty else, goto, double negation, bare Boolean, Boolean
  against True, enumerated, subrange, body ending in Exit, single-arm case,
  compound condition, set membership, while-once, a redundant nested begin,
  and the comparison written the other way round.

  $B+ changes nothing. TP600 and TP601 produce byte-identical output for each
  other across the whole 2726-byte run, so the two patch levels installed here
  agree -- and neither emits this.

  A THIRD COMPILER, AND IT AGREES. Turbo Pascal 7.01 cannot have built the
  original -- the runtime's banner says 1990 -- but it was run against this
  same probe to ask whether ANY Borland compiler here emits the long form. It
  does not: all three of its guards come out `80 3e xx xx 01 / 74 03 /
  e9 9a 00`, the compact five, with the original's own near displacement. So
  three compilers spanning two major versions agree with each other and
  disagree with the original.

  WHAT THE SEVEN BYTES LOOK LIKE. `jne` onto a near jump, with a short jump
  inserted to hop over it, is a fixup pattern: a compiler that emits a short
  branch first and, on finding it out of range, patches it into a jump to a
  near jump rather than re-sizing the branch. Every compiler here sizes the
  branch correctly the first time. That is a difference in the code generator,
  not in the statement being compiled -- which is consistent with sixteen
  source constructs failing to move it.

  THE SURVIVING HYPOTHESIS is therefore the compiler rather than the source:
  the original may have been built with a TP6 patch level that is neither
  TP600 nor TP601. That is checkable by anyone holding another TP6, which is
  why the probe is kept rather than deleted. }

unit Guard2;
interface
type RGBt = record r, g, b : Byte; end;
var
  Flag : Byte;
  Lvl  : Byte;
  T    : array[0..255] of RGBt;
procedure V1; procedure V2; procedure V3;
implementation

procedure V1;      { the plain if, real body, over 127 bytes }
var Ix : Byte;
begin
  if Flag = 1 then
  begin
    for Ix := 0 to 255 do
    begin
      if T[Ix].r > Lvl then T[Ix].r := Lvl;
      if T[Ix].g > Lvl then T[Ix].g := Lvl;
      if T[Ix].b > Lvl then T[Ix].b := Lvl;
    end;
    Dec(Lvl);
  end;
end;

procedure V2;      { the same, with a redundant nested block }
var Ix : Byte;
begin
  if Flag = 1 then
  begin
    begin
    for Ix := 0 to 255 do
    begin
      if T[Ix].r > Lvl then T[Ix].r := Lvl;
      if T[Ix].g > Lvl then T[Ix].g := Lvl;
      if T[Ix].b > Lvl then T[Ix].b := Lvl;
    end;
    Dec(Lvl);
    end;
  end;
end;

procedure V3;      { the comparison written the other way round }
var Ix : Byte;
begin
  if 1 = Flag then
  begin
    for Ix := 0 to 255 do
    begin
      if T[Ix].r > Lvl then T[Ix].r := Lvl;
      if T[Ix].g > Lvl then T[Ix].g := Lvl;
      if T[Ix].b > Lvl then T[Ix].b := Lvl;
    end;
    Dec(Lvl);
  end;
end;

end.
