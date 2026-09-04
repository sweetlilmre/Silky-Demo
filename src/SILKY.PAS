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

  { [re] The bounds come from the blitter's folded subscript at 0cb1, which
    biases by 0x2011 = 32*256 + 1*16 + 1. 59 characters of 16 by 16 is 15104
    bytes, which is both SizeOf pushed to New at 0ac9 and the size of
    bin/GOLD.FNT on disk. Characters 32 to 90 is space through Z, which is the
    whole of what an all-caps scrolltext needs. }
  TFont = array[32..90, 1..16, 1..16] of Byte;

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
  { [re] The scroller's state. 0x62e is set to 1 when a glyph runs out, 0x62f
    is the character being scrolled in, 0x630 its width and 0x632 how far into
    it the scroll has reached. Names are ours. }
  ScrollDone : Byte;
  Glyph      : Byte;
  Width      : Word;
  ScrollX    : Word;

  { [re] DGROUP 0x628, a FAR POINTER. 11a6:023f takes one word, calls the
    heap allocator and raises runtime error 203 -- heap overflow -- so it is
    the New helper: the compiler passes SizeOf and assigns the result. }
  Font : ^TFont;
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


{ [re] 1000:0aba, 118 bytes. Frame 0x184 = 388: the File is at bp-0x80 so it is
  declared first, and 260 bytes follow it that this routine never touches --
  the same shape as Drawit's unused F. A String plus a LongInt makes 260
  exactly; the composition is not recoverable from the frame size alone, only
  the total is. }
procedure LoadFont;
var
  F     : File;
  Dummy : String;
  Spare : LongInt;
begin
  New(Font);
  Assign(F,'gold.Fnt');
  Reset(F,1);
  BlockRead(F,Font^,15104);
  Close(F);
end;


{ [re] 1000:0b30, 196 bytes. Frame 0x4e4 = 1252, which decomposes exactly:
  File 128 at bp-0x80, then 800, then 320, then two words. The 800 is a CEL
  header plus its 768-byte palette, and 20000 - 800 is 19200 = 320 * 60, which
  is the 60 rows the outer loop counts. Line is ZERO-based: the fetch is
  [bp+di-0x4e0] with di starting at 0, and a 1-based array would fold to
  -0x4e1. Drawn 90 rows down. }
procedure LoadCheck2;
var
  F    : File;
  Hdr  : array[1..800] of Byte;
  Line : array[0..319] of Byte;
  Y, X : Integer;
begin
  Assign(F,'Check2.Cel');
  Reset(F,1);
  BlockRead(F,Hdr,800);
  for Y := 0 to 59 do
  begin
    BlockRead(F,Line,320);
    for X := 0 to 319 do
      PutPixel(X,Y+90,Line[X]);
  end;
  Close(F);
end;

{ [re] 1000:0bf4, 189 bytes. Frame 0x408 = 1032: File 128, the same 800-byte
  header, then only 100 and two words. 8800 - 800 is 8000 = 100 * 80, and the
  outer loop runs 5 to 84, which is those 80 rows. Line is ONE-based here,
  unlike Check2's: the fetch is [bp+di-0x405] with di = X-99, so index 1 lands
  on the base. It plots only where the cel is non-zero and always in colour 0,
  so this is a mask burnt into the picture rather than an image copied over it. }
procedure LoadAsphyx;
var
  F    : File;
  Hdr  : array[1..800] of Byte;
  Line : array[1..100] of Byte;
  Y, X : Integer;
begin
  Assign(F,'Asphyx.Cel');
  Reset(F,1);
  BlockRead(F,Hdr,800);
  for Y := 5 to 84 do
  begin
    BlockRead(F,Line,100);
    for X := 100 to 199 do
      if Line[X-99] <> 0 then PutPixel(X,Y,0);
  end;
  Close(F);
end;


{ [re] 1000:0cb1, 700 bytes. Renders EVERY glyph into video memory once and
  then frees the font -- 0f5b pushes the pointer and 0x3b00 to 11a6:0254,
  whose frame reads a size at bp+6 and a far pointer at bp+8, the Dispose
  helper matching the New at 023f. Each source row is drawn three screen rows
  tall, and the character set is split: 32..79 at y = Row*3, then X resets and
  80..90 go at y = Row*3+50. Six PutPixel sites, byte-identical to each other
  in their last four instructions, are those two groups of three.
  [bp-8] is set to 255 at the top and never read again -- the third
  declared-and-unused local in this program, after Drawit's F and RotPal2's
  loop2. }
procedure ShowFont;
var
  Row   : Byte;
  Ch    : Byte;
  X     : Integer;
  Col   : Integer;
  Spare : Integer;
  C     : Integer;
begin
  X := 320;
  Spare := 255;
  C := 0;
  for Ch := 32 to 79 do
  begin
    for Row := 1 to 16 do
      for Col := 0 to 15 do
      begin
        C := 0;
        if Font^[Ch,Row,Col+1] > 0 then C := 128;
        PutPixel(X+Col,Row*3,Font^[Ch,Row,Col+1]+C);
        PutPixel(X+Col,Row*3+1,Font^[Ch,Row,Col+1]+C);
        PutPixel(X+Col,Row*3+2,Font^[Ch,Row,Col+1]+C);
      end;
    Inc(X,20);
  end;
  X := 320;
  for Ch := 80 to 90 do
  begin
    for Row := 1 to 16 do
      for Col := 0 to 15 do
      begin
        C := 0;
        if Font^[Ch,Row,Col+1] > 0 then C := 128;
        PutPixel(X+Col,Row*3+50,Font^[Ch,Row,Col+1]+C);
        PutPixel(X+Col,Row*3+51,Font^[Ch,Row,Col+1]+C);
        PutPixel(X+Col,Row*3+52,Font^[Ch,Row,Col+1]+C);
      end;
    Inc(X,20);
  end;
  Dispose(Font);
end;


{ [re] 1000:0f6d, 175 bytes. The scroller, and it is hardware-accelerated:
  Graphics Controller register 5 is set to write mode 1 for the duration, which
  copies through the VGA latches so one byte moved shifts four pixels. Source
  and destination are BOTH in video memory -- ShowFont drew every glyph there
  and then freed the font, so this copies VRAM to VRAM.

  Frame is 6 bytes and only [bp-2] is used, so two words are declared and never
  touched. The other three variables it names are the program's.

  1000:0f82 is `mov dx,3`, overwritten by the very next instruction before it
  can be read. It is dead and it is transcribed anyway -- the wiki's
  the-original-does-nothing: a reconstruction never invents such a line, so
  leaving it out shifts every byte after it.

  EQUIVALENT PASCAL, reference only: there is none worth writing. The routine
  is latch-mode block copy and port programming from end to end. }
procedure Scroll;
var
  Dest  : Word;
  Spare : Word;
  Pad   : Word;
begin
  asm
    mov dx, $03CE               { Graphics Controller index port }
    mov ax, $4105               { register 5 := $41 -- WRITE MODE 1, the latch copy }
    out dx, ax                  { index and data in one 16-bit out }
    mov dx, 3                   { DEAD. Overwritten by the next line before any use; }
    mov dx, $03C4               { the original has it and so does this }
    mov ax, $0F02               { Map Mask := all four planes }
    out dx, ax                  { so one write reaches every plane }
    push es                     { es is borrowed twice below }
    mov ScrollDone, 0           { clear the wrapped flag }
    mov ax, SEG Glyph           { the data segment, as a relocated constant }
    mov es, ax                  { es addresses the width table }
    mov ax, 0                   { clear the high byte before loading the character }
    mov al, Glyph               { the character being scrolled in }
    sub ax, $0020               { space is the first entry }
    shl ax, 2                   { four bytes per entry }
    add ax, 2                   { and the second field is wanted, not the first }
    mov di, ax                  { index into the table }
    mov bx, es:[di]             { the glyph's source offset. NO BASE IS ADDED, }
    mov cx, ScrollX             { how far into the glyph the scroll has reached }
    shr cx, 2                   { four pixels per byte in an unchained plane }
    add bx, cx                  { so the source walks across the glyph }
    mov cx, es:[di+2]           { so the table sits at DGROUP offset 0: 59 }
    mov Width, cx               { kept for the wrap test at the end }
    mov word ptr [bp-2], $BBD0  { the destination, one row above the split }
    mov cx, ScnPos              { plus the current scroll offset }
    add [bp-2], cx              { so the column lands where the CRTC is looking }
    mov ax, $A000               { video memory }
    mov es, ax                  { for BOTH source and destination -- the glyphs were }
    mov cx, $0030               { drawn into VRAM by ShowFont. 48 rows }
    mov dx, $0140               { 320 bytes between rows }
    mov si, bx                  { source }
    mov di, [bp-2]              { destination }
    @Row:                       { one screen row per pass }
    cmp ScnPos, $0050           { past the halfway column? }
    jb  @Once                   { no -- a single copy will do }
    mov al, es:[si]             { read four pixels through the latches }
    mov es:[di], al             { write them }
    mov es:[di-$00A0], al       { and again a row up, to double the column }
    jmp @Next                   { done with this row }
    @Once:                      { the narrow case }
    mov al, es:[si]             { read }
    mov es:[di], al             { write }
    @Next:                      { step both pointers }
    add si, dx                  { one row down in the source }
    add di, dx                  { one row down in the destination }
    loop @Row                   { 48 times }
    pop es                      { restore }
    add ScrollX, 4              { four pixels of the glyph consumed }
    mov cx, ScrollX             { compare against the glyph's width }
    cmp Width, cx               { still inside it? }
    jg  @Done                   { yes -- nothing to reset }
    mov ScrollDone, 1           { no -- tell the caller to fetch the next character }
    mov ScrollX, 0              { and start the next glyph from its left edge }
    @Done:                      { }
    mov dx, $03CE               { Graphics Controller again }
    mov ax, $4005               { register 5 := $40 -- back to write mode 0 }
    out dx, ax                  { so ordinary writes work again }
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
  LoadFont;
  LoadCheck2;
  LoadAsphyx;
  ShowFont;
  Scroll;
end.
