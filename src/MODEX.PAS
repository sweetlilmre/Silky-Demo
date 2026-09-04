unit ModeX;

{ The unchained 256-colour mode and the two routines that draw in it.
  README.1ST calls this the first Asphyxia demo to use chain-4.

  [re] Original segment 112f, 208 bytes, read in full -- docs/02-units.md.
  Layout to match: PutPixel at 0000, SetModeX at 0043, SetPlane at 00a0, so
  the implementation order below is fixed and SetPlane must be forward. }

interface

var
  { The CRTC Offset register's value, which counts in WORDS -- so the byte
    stride from one screen row to the next is twice this. SetModeX writes it
    to the hardware and PutPixel uses it to find a row; the program sets it
    before calling either.

    [re] DGROUP 0x816 in the original, written by the program at 1000:11d8
    with 0xa0, so it is the unit's and exported rather than local. }
  LineWidth : Byte;

procedure PutPixel(x, y : Integer; col : Byte);
procedure SetModeX;

implementation

{ [re] NO @asm MARKERS IN THIS UNIT, deliberately. A unit is measured by
  units.py against its own .TPU, and that reports this one identical over all
  202 bytes -- a stronger statement than any per-routine marker. Markers were
  tried and removed: routines.py searches the LINKED image for a routine's
  opening bytes, and PutPixel and SetPlane both open with a relocated far call
  to the stack check, which defeats the search and reports NOT FOUND for
  routines that are demonstrably present at 0x923 and 0x9db. SetModeX, whose
  prologue holds no fixup, was found. Markers belong on the PROGRAM's routines,
  which have no .TPU and so no other instrument. }

{ [re] Forward because PutPixel calls it, and FAR -- the call site proves it.
  112f:0014 pushes the argument, 112f:0015 is `push cs`, and only then comes
  `call 0xa0`. Pushing CS before a near call is how Borland reaches a FAR
  routine that happens to sit in the same segment, so the callee's retf finds
  a full return address. Reading the e8 on its own says near, and that was a
  wrong conclusion held for one build. }
procedure SetPlane(plane : Byte); far; forward;

procedure PutPixel(x, y : Integer; col : Byte);
begin
  { [re] BOTH Integer. y was read as Word for one build because the original
    multiplies with MUL rather than IMUL -- an unsound reading, since the low
    16 bits of a product are identical either way, so TP6 uses MUL for
    Integer*Integer too. Word mixed with Integer promoted the address
    expression to LongInt and emitted an ADC the original does not have. }
  SetPlane(x mod 4);
  x := x div 4;
  { Doubled because LineWidth is the CRTC Offset, which counts in words. }
  Mem[$A000 : LineWidth * y * 2 + x] := col;
end;

procedure SetModeX; assembler;
  { [re] Transcribed verbatim rather than re-expressed, because it is
    hand-written assembler -- WORKING.md section 6.

    EQUIVALENT PASCAL, reference only -- this is NOT what is compiled:

        TextMode(...);                        -- int 10h, mode 13h
        Seq[4]  := (Seq[4] and $F7) or $04;   -- chain-4 off
        Gfx[5]  := Gfx[5] and $EF;            -- odd/even off
        Gfx[6]  := Gfx[6] and $FD;            -- chain odd/even off
        Seq[2]  := $0F;                       -- all planes
        FillWord(Mem[$A000:0], $8000, 0);     -- clear 64K
        Crtc[$14] := Crtc[$14] and $BF;       -- doubleword off
        Crtc[$17] := Crtc[$17] or  $40;       -- byte mode
        Crtc[$13] := LineWidth;               -- the offset register }
asm
  mov ax, $0013     { BIOS set-mode function, mode 13h }
  int $10           { 320x200x256, chained -- the next 40 lines unchain it }
  mov dx, $03C4     { Sequencer index port }
  mov al, 4         { index 4, Memory Mode }
  out dx, al        { select it }
  inc dx            { 3C5, the Sequencer data port }
  in  al, dx        { read Memory Mode back }
  and al, $F7       { clear bit 3, Chain-4 -- THE point of this routine }
  or  al, $04       { set bit 2, Odd/Even disable, so planes are sequential }
  out dx, al        { write it back }
  mov dx, $03CE     { Graphics Controller index port }
  mov al, 5         { index 5, Graphics Mode }
  out dx, al        { select it }
  inc dx            { 3CF, the data port }
  in  al, dx        { read Graphics Mode }
  and al, $EF       { clear bit 4, the odd/even addressing mode }
  out dx, al        { write it back }
  dec dx            { back to the index port }
  mov al, 6         { index 6, Miscellaneous }
  out dx, al        { select it }
  inc dx            { data port again }
  in  al, dx        { read Miscellaneous }
  and al, $FD       { clear bit 1, chain odd/even }
  out dx, al        { write it back }
  mov dx, $03C4     { Sequencer index port once more }
  mov ax, $0F02     { AL=2 selects Map Mask, AH=0F opens all four planes }
  out dx, ax        { 16-bit out writes index and data together }
  mov ax, $A000     { the VGA display segment }
  mov es, ax        { ES addresses video memory }
  sub di, di        { DI := 0, the start of the segment }
  mov ax, 0         { the value to clear with }
  mov cx, $8000     { 32768 words -- the whole 64K }
  cld               { forwards }
  rep stosw         { with all four planes open this clears every one at once }
  mov dx, $03D4     { CRTC index port }
  mov al, $14       { index 14h, Underline Location }
  out dx, al        { select it }
  inc dx            { 3D5, the CRTC data port }
  in  al, dx        { read it }
  and al, $BF       { clear bit 6, doubleword addressing }
  out dx, al        { write it back }
  dec dx            { index port }
  mov al, $17       { index 17h, CRTC Mode Control }
  out dx, al        { select it }
  inc dx            { data port }
  in  al, dx        { read it }
  or  al, $40       { set bit 6 -- byte mode, not word mode }
  out dx, al        { write it back }
  mov dx, $03D4     { CRTC index port }
  mov al, $13       { index 13h, the Offset register }
  out dx, al        { select it }
  inc dx            { data port }
  mov al, LineWidth { the logical line width, in WORDS }
  out dx, al        { so the byte stride per line is twice this }
end;

procedure SetPlane;
begin
  { [re] The shift is compiler output and matched first time. The port writes
    are NOT: Port[$3C4] then Port[$3C5] emits a fresh `mov dx` for each, and
    the original walks the pair with `inc dx`. That is hand-written, so it is
    transcribed rather than re-expressed. }
  plane := 1 shl plane;
  { EQUIVALENT PASCAL, reference only:
        Port[$3C4] := 2;  Port[$3C5] := plane;

    [re] That is not what the original emits: Port[] reloads DX for each
    port where the original steps with `inc dx`, so the body below is
    transcribed rather than written. }
  asm
    mov dx, $03C4 { Sequencer index port }
    mov al, 2     { index 2, Map Mask }
    out dx, al    { select it }
    inc dx        { 3C5, the Sequencer data port }
    mov al, plane { the 1-shl-plane bit computed above }
    out dx, al    { only that plane will accept writes now }
  end;
end;

end.
