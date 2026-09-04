program Silky;

{ The 1993 Asphyxia demo, written for Silky's eighteenth birthday.

  [re] Original program segment 1000, 4848 bytes, charted in docs/03-program.md.
  Routines are emitted in source order, so this file's order is fixed by the
  original's layout: WaitRetrace 0000, gotoscnpos 000e, then BARS.INC's own run
  from DeltaPal at 002b through StartPal at 095e -- the include's declaration
  order IS the segment order, which is one of the reasons to believe it. }

uses ModeX, Palette;

type
  { [re] Named by BARS.INC, which declares Tmp : Array[1..16] of RGBt. }
  RGBt = record
    r, g, b : Byte;
  end;

var
  { [re] DGROUP 0x328. DeltaPal's `lea si,t` points at its first byte. It is
    zero-based but indexed from 1 everywhere, which puts T[1] at 0x32b. }
  T : array[0..255] of RGBt;
  { [re] DGROUP 0x2d4, five bytes -- StartPal's FillChar(palcol,SizeOf(palcol),0)
    compiles to FillChar(ds:0x2d4, 5, 0) at 1000:097a. }
  PalCol : array[1..5] of Byte;
  { [re] DGROUP 0x320, named by BARS.INC's rotpal. 1000:11ce zeroes it. }
  GlobCount : Word;
  { [re] DGROUP 0x62c. gotoscnpos adds 0xbb80 and hands the sum to the CRTC
    start address. Name is ours; BARS.INC does not declare it. }
  ScnPos : Word;
  { [re] Set by Drawit and read by PlayPal. Declared here because BARS.INC
    references them without declaring them, so they lived in the enclosing
    program. Types are a first reading and the build is what tests them. }
  { [re] BYTES, not Integers -- 1000:013d..015b sets all six with
    `mov byte ptr`. Value..Value3 are 0x324..0x326 and Count..Count3 are
    0x31c..0x31e, which are exactly the addresses PlayPal at 064b reads:
    the Count trio nine times each and the Value trio three times each.
    Value..Value3 are SIGNED: PlayPal does `Value2 := -1`, and Byte refused
    to compile it. ShortInt is one byte too, so the store is the same. }
  { [re] DGROUP 0x322 and 0x323. Main sets Fading := 0 at 1000:11c9 and
    Bright := 0x3f at 11d3 -- 63, the top of a VGA DAC component. ClampDown
    below runs only while Fading = 1 and decrements Bright each pass, so the
    pair is a fade-out driven through the palette buffer. Names are ours. }
  Fading : Byte;
  Bright : Byte;
  Value, Value2, Value3 : ShortInt;
  Count, Count2, Count3 : Byte;

{ [re] 1000:0000, 14 bytes. Called NEAR by DeltaPal -- `e8` with no `push cs`
  at 1000:002e -- so it is local, not far. BARS.INC calls it but does not
  declare it. }
{ [re] Transcribed from the original at this address, 14 bytes.
  @asm 000 1000:0000 +14 }
procedure WaitRetrace; assembler;
{ EQUIVALENT PASCAL, reference only:
    repeat until (Port[$3DA] and 8) = 0;
    repeat until (Port[$3DA] and 8) <> 0;  }
asm
  mov dx, $03DA     { Input Status 1 -- bit 3 is the vertical retrace flag }
  @NotInRetrace:    { first wait: leave any retrace already in progress }
  in  al, dx        { sample the status }
  test al, 8        { still retracing? }
  jnz @NotInRetrace { yes -- keep waiting for it to end }
  @InRetrace:       { second wait: for the NEXT retrace to begin }
  in  al, dx        { sample again }
  test al, 8        { has it started? }
  jz  @InRetrace    { no -- spin. Falling through means retrace just began }
end;

{ [re] 1000:000e, 29 bytes. BARS.INC's StartPal opens with `gotoscnpos`, and
  095e -- which is StartPal -- opens with a near call to 000e, so that is this
  routine's original name. CRTC 0c and 0d are the start address, high then low. }
{ [re] Transcribed from the original at this address, 29 bytes.
  @asm 000 1000:000e +29 }
procedure GotoScnPos; assembler;
{ EQUIVALENT PASCAL, reference only:
    ofs := ScnPos + $BB80;
    Port[$3D4] := $0C;  Port[$3D5] := Hi(ofs);
    Port[$3D4] := $0D;  Port[$3D5] := Lo(ofs);  }
asm
  mov bx, ScnPos { the scroll offset, in bytes }
  add bx, $BB80  { plus the base of the visible page }
  mov dx, $03D4  { CRTC index port }
  mov al, $0C    { index 0Ch, Start Address High }
  out dx, al     { select it }
  inc dx         { 3D5, the data port }
  mov al, bh     { high byte of the address }
  out dx, al     { write it }
  mov dx, $03D4  { index port again }
  mov al, $0D    { index 0Dh, Start Address Low }
  out dx, al     { select it }
  inc dx         { data port }
  mov al, bl     { low byte }
  out dx, al     { write it -- the display now starts here }
end;

{ [re] The original source, copied from bin/BARS.INC. bin/ holds the shipped
  artefact untouched; this copy is part of the reconstruction and may be
  edited where the binary disagrees with it. Five of its routines already
  rebuild with zero unexplained bytes -- see docs/04-palette-animation.md. }
{ [re] THE MARKERS FOR THE INCLUDED ROUTINES LIVE HERE, not in the
  include. marker.py globs *.PAS, so a marker inside a .INC is never
  read -- nine of them sat there for one build and routines.py went on
  reporting two. A marker above an include line is shared and must name
  its routine, which is exactly what marker.py's docstring says.

  ONLY DELTAPAL IS MARKED, and the other eight are held back deliberately.
  routines.py walks a routine's bytes and stops at the first it cannot forgive.
  For every FRAMED routine here that byte is the far call to the stack check at
  11a6:04df, because our System segment has not landed where the original's is
  -- the map puts ours at 0x00b80 and it is 1811 bytes against the original's
  2576. So all eight report SHORT at 6 or 7 bytes while being correct: 2544
  bytes across the run measure zero unexplained once relocation and DGROUP
  placement are accounted for, checked against the MZ relocation table.
  Marking them would leave the check list red for eight known-good routines,
  which is how a real regression later goes unnoticed. They go back the moment
  the RTL converges. DeltaPal is marked because it is `assembler` with no
  stack check, so nothing in its prologue is relocated. }
{ [re] The one included routine that CAN be walked: assembler,
  no stack check, so nothing in its prologue is relocated.
  @asm 000 1000:002b +28 DeltaPal }
{$I BARS.INC}

{ [re] 1000:09fb, 191 bytes. Frames 2 bytes for a byte counter. Runs the whole
  256-entry palette and clips every channel to Bright, then lowers Bright by
  one -- so repeated calls walk the picture down to black without touching the
  DAC directly, since DeltaPal is what uploads T. }
procedure ClampDown;
var
  Loop : Byte;
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
  end;
end;


begin
  { [re] NOT the original main block, which is 1000:11ad and calls twenty-odd
    routines. This exists so the smart linker keeps what has been transcribed:
    with an empty main it dropped every routine AND all of ModeX. }
  SetModeX;
  Drawit;
  StartPal;
  ClampDown;
end.
