{$X+}
{ Extended syntax. RunScroll calls Crt's ReadKey as a statement and throws the
  key away, which Turbo Pascal refuses without this.

  [re] and it is required rather than stylistic. RunScroll
  calls Crt's ReadKey as a statement and throws the result away, which Turbo
  Pascal refuses without it -- 1144:030d is a FUNCTION, int 16h with ah=0
  returning the key in AL, and nothing at the call site consumes it. $X is a
  global directive and will not compile part-way down a file. }

{ WHICH NAMES ARE THE AUTHORS' AND WHICH ARE OURS, because a reader cannot
  tell by looking and it changes what a name is worth.

  RECOVERED. bin/BARS.INC shipped with the demo and declares DeltaPal, Drawit,
  PlayPal, RotPal0 to RotPal3, rotpal and StartPal, along with the types and
  variables RGBt, T, PalCol, GlobCount, Count/Count2/Count3 and
  Value/Value2/Value3. It also CALLS waitretrace and gotoscnpos without
  declaring them, so those two names are the authors' as well.

  OURS. Everything else, including the unit names ModeX and Palette and every
  routine not listed above -- ClampDown, FadeOut, Finish, LoadAsphyx,
  LoadCheck2, LoadFont, RunScroll, Scroll, ShowFont, SplitScreen, TextMode3
  and WhiteOut -- and every variable not listed above. They describe what the
  code does; they are not what anybody typed in 1993. }

program Silky;

{ The 1993 Asphyxia demo, written for Silky's eighteenth birthday.

  [re] Original program segment 1000, 4848 bytes, charted in docs/03-program.md.
  Routines are emitted in source order, so this file's order is fixed by the
  original's layout: WaitRetrace 0000, gotoscnpos 000e, then BARS.INC's own run
  from DeltaPal at 002b through StartPal at 095e -- the include's declaration
  order IS the segment order, which is one of the reasons to believe it. }

{ THE ORDER OF THIS CLAUSE IS NOT ARBITRARY. Turbo Pascal lays the units out
  backwards from the order they are named, so this line decides where each one
  lands in the executable. Tidying it changes the program's layout.

  [re] In reverse of the segment order, deliberately. Turbo
  Pascal 6 lays the units out backwards from the order they are named: with
  ModeX, Palette, Crt the map came out SILKY, CRT, PALETTE, MODEX, while the
  original is SILKY, MODEX, PALETTE, Crt. Naming them backwards puts them
  right. The wiki says this of typed constants in DGROUP; here it governs the
  CODE segments too, and getting it wrong misplaces every unit at once. }
uses Crt, Palette, ModeX;

type
  { One palette entry: red, green and blue, each 0 to 63 as the VGA's DAC
    wants them.

    [re] Named by BARS.INC, which declares Tmp : Array[1..16] of RGBt. }
  RGBt = record
    r, g, b : Byte;
  end;

  { The font: 59 characters, space through 'Z', each 16 by 16 pixels, one
    byte per pixel.

    [re] The bounds come from the blitter's folded subscript at 0cb1, which
    biases by 0x2011 = 32*256 + 1*16 + 1. 59 characters of 16 by 16 is 15104
    bytes, which is both SizeOf pushed to New at 0ac9 and the size of
    bin/GOLD.FNT on disk. Characters 32 to 90 is space through Z, which is the
    whole of what an all-caps scrolltext needs. }
  TFont = array[32..90, 1..16, 1..16] of Byte;

const
  { Where each glyph ends up once ShowFont has drawn it. Ofs is its address
    in video memory and Wid is how far the scroll advances past it, so a
    narrow letter takes less room on screen than a wide one.

    [re] DGROUP 0x00..0xED. A leading Word, then one record per character --
    the scroller computes (Glyph-32)*4+2 and dereferences with NO base, so the
    array starts at offset 2 and the Word sits at 0. 2 + 59*4 = 238 = 0xEE,
    which is exactly where Line1 begins, so the three abut with nothing spare.
    Ofs is a real video-memory address: char 32 is 1040 = 320*3 + 80, the
    top-left of where ShowFont drew it, and every one of the 59 agrees with
    that placement. Values are read out of the original's initialised data. }
  Glyphs : array[32..90] of record
    Ofs, Wid : Word;
  end = (
    ( Ofs :  1040; Wid : 10 )   { ' ' },
    ( Ofs :  1045; Wid :  5 )   { '!' },
    ( Ofs :  1050; Wid : 17 )   { '"' },
    ( Ofs :  1055; Wid : 17 )   { '#' },
    ( Ofs :  1060; Wid : 17 )   { '$' },
    ( Ofs :  1065; Wid : 17 )   { '%' },
    ( Ofs :  1070; Wid : 17 )   { '&' },
    ( Ofs :  1075; Wid : 10 )   { "'" },
    ( Ofs :  1080; Wid : 17 )   { '(' },
    ( Ofs :  1085; Wid : 17 )   { ')' },
    ( Ofs :  1090; Wid : 17 )   { '*' },
    ( Ofs :  1095; Wid : 17 )   { '+' },
    ( Ofs :  1100; Wid : 10 )   { ',' },
    ( Ofs :  1105; Wid : 17 )   { '-' },
    ( Ofs :  1110; Wid :  7 )   { '.' },
    ( Ofs :  1115; Wid : 15 )   { '/' },
    ( Ofs :  1120; Wid : 17 )   { '0' },
    ( Ofs :  1125; Wid : 11 )   { '1' },
    ( Ofs :  1130; Wid : 17 )   { '2' },
    ( Ofs :  1135; Wid : 17 )   { '3' },
    ( Ofs :  1140; Wid : 17 )   { '4' },
    ( Ofs :  1145; Wid : 17 )   { '5' },
    ( Ofs :  1150; Wid : 17 )   { '6' },
    ( Ofs :  1155; Wid : 17 )   { '7' },
    ( Ofs :  1160; Wid : 17 )   { '8' },
    ( Ofs :  1165; Wid : 17 )   { '9' },
    ( Ofs :  1170; Wid :  6 )   { ':' },
    ( Ofs :  1175; Wid : 17 )   { ';' },
    ( Ofs :  1180; Wid : 17 )   { '<' },
    ( Ofs :  1185; Wid : 17 )   { '=' },
    ( Ofs :  1190; Wid : 17 )   { '>' },
    ( Ofs :  1195; Wid : 17 )   { '?' },
    ( Ofs :  1200; Wid : 17 )   { '@' },
    ( Ofs :  1205; Wid : 17 )   { 'A' },
    ( Ofs :  1210; Wid : 17 )   { 'B' },
    ( Ofs :  1215; Wid : 17 )   { 'C' },
    ( Ofs :  1220; Wid : 17 )   { 'D' },
    ( Ofs :  1225; Wid : 17 )   { 'E' },
    ( Ofs :  1230; Wid : 17 )   { 'F' },
    ( Ofs :  1235; Wid : 17 )   { 'G' },
    ( Ofs :  1240; Wid : 17 )   { 'H' },
    ( Ofs :  1245; Wid :  5 )   { 'I' },
    ( Ofs :  1250; Wid : 17 )   { 'J' },
    ( Ofs :  1255; Wid : 16 )   { 'K' },
    ( Ofs :  1260; Wid : 13 )   { 'L' },
    ( Ofs :  1265; Wid : 17 )   { 'M' },
    ( Ofs :  1270; Wid : 17 )   { 'N' },
    ( Ofs :  1275; Wid : 17 )   { 'O' },
    ( Ofs : 17040; Wid : 17 )   { 'P' },
    ( Ofs : 17045; Wid : 17 )   { 'Q' },
    ( Ofs : 17050; Wid : 17 )   { 'R' },
    ( Ofs : 17055; Wid : 17 )   { 'S' },
    ( Ofs : 17060; Wid : 17 )   { 'T' },
    ( Ofs : 17065; Wid : 17 )   { 'U' },
    ( Ofs : 17070; Wid : 17 )   { 'V' },
    ( Ofs : 17075; Wid : 17 )   { 'W' },
    ( Ofs : 17080; Wid : 17 )   { 'X' },
    ( Ofs : 17085; Wid : 17 )   { 'Y' },
    ( Ofs : 17090; Wid : 17 )   { 'Z' } );

  { The scrolltext, in six lines of eighty characters. Main copies them into
    Text end to end and RunScroll walks that, so the six read as one message
    with no break between them.

    [re] ONE ARRAY, not six separate constants. The originals sit 0x51 apart
    -- a length byte plus eighty characters, with NO padding between them --
    and six standalone String[80] constants come out 82 bytes each, because
    Turbo Pascal word-aligns the next item after an odd-sized one. Array
    elements pack, so the array reproduces the spacing. Main's code folds the
    subscript to a fixed base per line, which is why the disassembly shows
    0xee, 0x13f, 0x190, 0x1e1, 0x232 and 0x283 rather than an index.
    The text is read out of the ORIGINAL's initialised data, so the trailing
    spaces are the author's own. }
  Lines : array[1..6] of String[80] = (
    '                   HAPPY BIRTHDAY SILKY, HERE''S WISHING U A GR8 18TH!!! ALL THE ',
    'BEST FROM ASPHYXIA!!!         *   HEHE NOW U R LEGAL!!!   *                     ',
    'GREETS GO TO :-   SCHMUCK, EARWAX, NOBODY, SPLIT, JAVELIN AND ALL THE OTHERS.   ',
    'THIS DEMO WAS WRITTEN ESPECIALLY FOR SILKY ON HER EIGHTEEN BIRTHDAY ---------   ',
    ' BEST WISHES FOR ''93. HAVE A GOOD ONE.......... A S P H Y X I A   R U L Z !!!!!!',
    '                                                                                ' );

  { The five colours the bars are drawn in. StartPal clears this to zero
    before it is used, so the values written here never reach the screen.

    [re] A TYPED CONSTANT, not a var. bin/BARS.INC carries it commented out at
    the foot of the file -- PalCol : Array[1..5] of Byte = (0,30,40,50,60) --
    and the original's initialised data has exactly those bytes at 0x2d4,
    which is where Lines ends. Declared as a var it read as four zero bytes.
    StartPal FillChars it to zero at run time, which a typed constant permits. }
  PalCol : array[1..5] of Byte = (0,30,40,50,60);

var
  { The program's state, all of it. The counters and the three Value bytes
    drive the palette animation in BARS.INC; T is the palette itself, one
    entry per colour; Text is the scrolltext once the six lines have been
    copied into it, and the rest belongs to the scroller.

    THE ORDER OF THIS BLOCK IS NOT ARBITRARY, in the same way the uses clause
    is not: Turbo Pascal allocates globals in the order they are declared, so
    the list decides where each one lives. Rearranging it changes the program.

    [re] Declaration order is the original's DGROUP order, read straight off
    the addresses in the binary. Turbo Pascal allocates globals in the order
    they are declared, so this list IS the layout:

      031c Count, Count2, Count3   031f pad     0320 GlobCount
      0322 Fading   0323 Bright    0324 Value, Value2, Value3   0327 pad
      0328 T (768)                 0628 Font    062c ScnPos
      062e ScrollDone  062f Glyph  0630 Width   0632 ScrollX
      0634 Text (480)              0814 Loop    0816 LineWidth (ModeX's)

    [re] Getting this wrong costs nothing visible and everything measurable: the
    code is identical either way and every instruction that names a global
    carries a different displacement, so a correct routine reads as wrong. }
  Count, Count2, Count3 : Byte;
  GlobCount : Word;
  Fading : Byte;
  Bright : Byte;
  Value, Value2, Value3 : ShortInt;
  T : array[0..255] of RGBt;
  Font : ^TFont;
  ScnPos : Word;
  ScrollDone : Byte;
  Glyph : Byte;
  Width : Word;
  ScrollX : Word;
  Text : array[1..480] of Char;
  Loop : Word;

{ Waits for the start of the next vertical retrace, so a palette upload
  or a page flip lands in the gap between frames and does not tear.

  [re] 1000:0000, 14 bytes. Called NEAR by DeltaPal -- `e8` with no `push cs`
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

{ Points the CRTC at ScnPos, which is how the picture scrolls: the screen
  is wider than the display, and moving the start address moves the window.

  [re] 1000:000e, 29 bytes. BARS.INC's StartPal opens with `gotoscnpos`, and
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
{ [re] Transcribed against the original at this address, 267 bytes.
  @asm 000 1000:0052 +267 Drawit }
{ [re] Transcribed against the original at this address, 162 bytes.
  @asm 000 1000:015d +162 RotPal2 }
{ [re] Transcribed against the original at this address, 162 bytes.
  @asm 000 1000:01ff +162 RotPal3 }
{ [re] Transcribed against the original at this address, 424 bytes.
  @asm 000 1000:02a1 +424 RotPal0 }
{ [re] Transcribed against the original at this address, 424 bytes.
  @asm 000 1000:0449 +424 RotPal1 }
{ [re] Transcribed against the original at this address, 90 bytes.
  @asm 000 1000:05f1 +90 rotpal }
{ [re] Transcribed against the original at this address, 787 bytes.
  @asm 000 1000:064b +787 PlayPal }
{ [re] Transcribed against the original at this address, 157 bytes.
  @asm 000 1000:095e +157 StartPal }
{ [re] The one included routine that CAN be walked: assembler,
  no stack check, so nothing in its prologue is relocated.
  @asm 000 1000:002b +28 DeltaPal }
{$I BARS.INC}

{ One step of the fade-out. Clips every channel of all 256 colours to
  Bright, then lowers Bright, so repeated calls walk the picture down to
  black. It works on the buffer; DeltaPal is what reaches the hardware.
  Does nothing at all unless Fading has been set.

  THE GUARD IS WRITTEN WITH A GOTO AND THE ENCODING SAYS IT HAS TO BE.
  The original is `cmp / jne +2 / jmp +3 / jmp near`. The conditional jumps
  over exactly two bytes, and those two bytes are a short jump -- so the
  THEN-PART of the if compiled to a two-byte short jump, and in Turbo Pascal
  only `goto` does that. The near jump after it is the next statement,
  leaving for the end of the routine.

  Written as a plain `if Fading = 1 then begin ... end` the compiler owns
  both sides of the branch, inverts the test and falls through into the body:
  five bytes, not seven. It does that at every body length -- probes/SWEEP.PAS
  sweeps across the short-jump boundary and never once emits the long form --
  and a label at the head of the body does not change it either.

  WHICH OF THE TWO SPELLINGS, ON THE AUTHOR'S OWN WORD. `goto Done` with the
  label at the end of the routine and a bare `Exit` compile to the same near
  jump to the same epilogue, so no measurement can separate them. Asked, the
  author said the `Exit` form is the natural one and the label would have had
  a name that says what it is. That is testimony, not a measurement, and it
  is the best evidence available for a choice the bytes cannot make.

  [reading] The label's spelling is ours. `DoFade` says what the jump is for;
  what it was actually called is not in the executable, because a label's
  name never reaches the code.

  [re] 1000:09fb, 191 bytes. Frames 2 bytes for a byte counter. Runs the whole
  256-entry palette and clips every channel to Bright, then lowers Bright by
  one -- so repeated calls walk the picture down to black without touching the
  DAC directly, since DeltaPal is what uploads T. }
procedure ClampDown;
label
  DoFade;
var
  Loop : Byte;
begin
  if Fading = 1 then goto DoFade;
  Exit;
DoFade:
  for Loop := 0 to 255 do
  begin
    if T[Loop].r > Bright then T[Loop].r := Bright;
    if T[Loop].g > Bright then T[Loop].g := Bright;
    if T[Loop].b > Bright then T[Loop].b := Bright;
  end;
  Dec(Bright);
end;


{ Allocates the font and reads gold.Fnt into it.

  [re] 1000:0aba, 118 bytes. Frame 0x184 = 388: the File is at bp-0x80 so it is
  declared first, and 260 bytes follow it that this routine never touches --
  the same shape as Drawit's unused F.

  [reading] The file variable is the only local this routine uses. The rest of
  the frame is filled here by a string and a long integer, and that pairing is
  a guess: the total is measured, the way it divides up is not. }
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


{ Loads Check2.Cel and draws it 90 rows down. The file is a CEL: an
  800-byte header and palette, then one byte per pixel, 320 to a row.

  [re] 1000:0b30, 196 bytes. Frame 0x4e4 = 1252, which decomposes exactly:
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

{ Loads Asphyx.Cel and burns it into the picture as a MASK -- it plots
  only where the cel is non-zero, and always in colour 0, so it darkens
  a shape into whatever is already on screen rather than covering it.

  [re] 1000:0bf4, 189 bytes. Frame 0x408 = 1032: File 128, the same 800-byte
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


{ Draws every glyph of the font into video memory, three screen rows tall,
  and then frees the font. Nothing reads the font again: the scroller
  copies glyphs from video memory to video memory after this.

  [re] 1000:0cb1, 700 bytes. Renders EVERY glyph into video memory once and
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


{ Copies one column of the current glyph into the scroll area. Both the
  source and the destination are in video memory, so it runs in the VGA's
  latch mode: one byte moved shifts four pixels and the CPU never sees
  the data. Sets ScrollDone when the glyph runs out.

  [re] 1000:0f6d, 175 bytes. The scroller, and it is hardware-accelerated:
  Graphics Controller register 5 is set to write mode 1 for the duration, which
  copies through the VGA latches so one byte moved shifts four pixels. Source
  and destination are BOTH in video memory -- ShowFont drew every glyph there
  and then freed the font, so this copies VRAM to VRAM.

  [re] Frame is 6 bytes and only [bp-2] is used, so two words are declared
  and never touched. The other three variables it names are the program's.

  [reading] Only the first of the three locals is ever used. The other two are
  declared to fill out the frame, and any declaration of the same total size
  would compile to the same code -- so their number and their types are a
  guess, not a measurement.

  [re] The dead `mov dx,3` is at 1000:0f82, overwritten by the very next
  instruction before it can be read. Transcribed anyway -- the wiki's
  the-original-does-nothing: a reconstruction never invents such a line, so
  leaving it out shifts every byte after it.

  [re] EQUIVALENT PASCAL, reference only: there is none worth writing. The
  routine is latch-mode block copy and port programming from end to end. }
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
    mov dx, 3                   { DEAD -- DX is overwritten below before any use }
    mov dx, $03C4               { Sequencer index port }
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


{ The scrolltext, and the last thing the demo does. Each pass moves the
  scroll on by one column, cycles the palette and uploads it. A keypress
  does not quit: it sets Fading, and the loop ends when the fade reaches
  black.

  [re] 1000:101c, 133 bytes. The scrolltext loop, and the last thing the demo
  does. It drives every routine transcribed so far: Scroll for one column of
  the current glyph, then PlayPal, RotPal and ClampDown around a pusha/popa
  pair, then DeltaPal to upload, then the CRTC start address. A scancode on
  port $60 sets Fading, and the loop ends when Bright reaches zero -- so the
  keypress does not quit, it starts the fade that quits.

  [re] $X+ is required: ReadKey is a FUNCTION whose result is discarded here,
  which Turbo Pascal only accepts under extended syntax. Crt's routine at
  1144:030d is int 16h with ah=0 storing into its pending-key byte at 0x5193,
  and nothing consumes the value at the call site.

  [re] Frame is 2 bytes, set to zero and never read -- the fifth
  declared-and-unused local in this program.

  EQUIVALENT PASCAL, reference only: there is none. The control flow is a
  three-way loop with two continuation targets and a pusha/popa pair around
  three calls, and Pascal expresses none of that. }
procedure RunScroll;
var
  Spare : Word;
begin
  asm
    mov Spare, 0       { set and never read -- the fifth such local here }
    mov ScrollDone, 1  { force the first pass to fetch a character }
    push es            { balanced by the pop at @Finished }
    @Restart:          { the whole text has been consumed -- start again }
    push ds            { ds is about to be clobbered }
    lea di, Text       { the scrolltext buffer }
    mov ax, ds         { es := ds so the text is read through es:[di] }
    mov es, ax         { }
    pop ds             { ds back }
    mov cx, 420        { characters to scroll before wrapping }
    @Inner:            { advance to the next character }
    inc di             { }
    @Outer:            { re-entered per frame while a glyph is still scrolling }
    mov al, es:[di]    { the character }
    mov Glyph, al      { which Scroll reads }
    push di            { Scroll is Pascal and may use any of these }
    push es            { }
    push cx            { }
    call Scroll        { one column of the glyph into video memory }
    pop cx             { }
    pop es             { }
    pop di             { }
    pusha              { a 186 instruction, so this needs $G+ }
    call PlayPal       { rebuild the palette }
    call RotPal        { cycle it }
    call ClampDown     { and clip it, which fades once Fading is set }
    popa               { }
    call DeltaPal      { wait for retrace and upload }
    cmp ScnPos, 159    { at the end of the visible span? }
    jl  @Bump          { no -- step it }
    mov ScnPos, 0      { yes -- wrap to the start }
    jmp @Moved         { }
    @Bump:             { }
    add ScnPos, 1      { one pixel of hardware scroll }
    @Moved:            { }
    call GotoScnPos    { tell the CRTC where to start reading }
    push ax            { the port read below clobbers AX }
    in  al, $60        { the keyboard controller's scancode port }
    xor ah, ah         { }
    cmp al, 0          { anything pressed? }
    pop ax             { restore before branching }
    jle @NoKey         { no }
    mov Fading, 1      { yes -- start the fade, which ends the demo }
    @NoKey:            { }
    cmp Bright, 0      { has the fade reached black? }
    je  @Finished      { then stop }
    cmp ScrollDone, 0  { is this glyph finished? }
    je  @Outer         { no -- another column of the same character }
    loop @Inner        { yes -- next character, 420 of them }
    jmp @Restart       { text exhausted -- round again }
    @Finished:         { }
    pop es             { balance the push at the top }
  end;
  ReadKey;
end;


{ Splits the screen at scanline 100. Below the split the CRTC restarts at
  address zero and ignores the scroll offset, so the top half can scroll
  while the bottom half stays put.

  [re] 1000:10a1, 29 bytes, frameless -- an assembler procedure with no
  parameters gets no frame and no stack check.

  EQUIVALENT PASCAL, reference only:
    Crtc[$18] := 100;
    Crtc[$07] := Crtc[$07] and $EF;
    Crtc[$09] := Crtc[$09] and $BF;

  [re] Not what the original emits: it steps the index and data ports with
  inc/dec rather than reloading DX, so the body is transcribed. }
procedure SplitScreen; assembler;
asm
  mov dx, $03D4  { CRTC index port }
  mov al, $18    { index 18h, Line Compare -- the split scanline }
  out dx, al     { select it }
  inc dx         { 3D5, the data port }
  mov al, $64    { 100: the screen splits halfway down }
  out dx, al     { write it }
  dec dx         { back to the index }
  mov al, 7      { index 7, Overflow -- holds line compare bit 8 }
  out dx, al     { }
  inc dx         { }
  in  al, dx     { read it }
  and al, $EF    { clear bit 4, so bit 8 of the compare is 0 }
  out dx, al     { }
  dec dx         { }
  mov al, 9      { index 9, Max Scan Line -- holds line compare bit 9 }
  out dx, al     { }
  inc dx         { }
  in  al, dx     { }
  and al, $BF    { clear bit 6, so bit 9 is 0 as well }
  out dx, al     { the compare is therefore exactly 100 }
end;

{ Back to 80x25 text, which is where DOS was.

  [re] 1000:10be, 6 bytes, frameless.

  EQUIVALENT PASCAL, reference only: TextMode(CO80). That emits a Crt call
  and a good deal more, where this is the BIOS call and nothing else. }
procedure TextMode3; assembler;
asm
  mov ax, $0003  { BIOS mode 3 }
  int $10        { 80x25 colour text, which is where DOS was }
end;

{ Fills the whole palette with white, which is what the demo fades down
  from.

  [re] 1000:10c4, 27 bytes. Fills the whole palette buffer with 63 -- every
  channel at full -- so the screen is white before FadeOut walks it down. }
procedure WhiteOut;
begin
  FillChar(T,768,63);
end;

{ The opening fade. Sixty-four passes, each clipping every colour a little
  darker and uploading, so the screen falls from white to black.

  [re] 1000:10df, 181 bytes. Sixty-four passes clipping every channel of all
  256 colours to a ceiling that drops by one each time, uploading after each
  pass. The same shape as ClampDown but unconditional and self-driving, and
  the reason the demo opens by fading up from white. }
procedure FadeOut;
var
  Level : Byte;
  Ix    : Byte;
begin
  for Level := 63 downto 0 do
  begin
    for Ix := 0 to 255 do
    begin
      if T[Ix].r > Level then T[Ix].r := Level;
      if T[Ix].g > Level then T[Ix].g := Level;
      if T[Ix].b > Level then T[Ix].b := Level;
    end;
    DeltaPal;
  end;
end;

{ The closing sequence: point the CRTC at the scroll area, run the
  scrolltext until the fade ends it, then give the screen back to DOS.

  [re] 1000:1194, 10 bytes, frameless -- three near calls and a ret, which is
  an assembler procedure. Not an exit routine: RunScroll is the demo's last
  scene, and TextMode3 after it is the cleanup.

  EQUIVALENT PASCAL, reference only: the three calls as statements. Written
  that way it would carry a stack frame and a stack check, which this has
  not got. }
procedure Finish; assembler;
asm
  call GotoScnPos  { point the CRTC at the start of the scroll area }
  call RunScroll   { and run the scrolltext until the fade ends it }
  call TextMode3   { then hand the screen back to DOS }
end;


{ THE WHOLE DEMO, in the order it happens: read the font, go to Mode X, flash
  the screen white and fade it to black, split the screen so the top half can
  scroll, draw the font and the two pictures, join the six lines of scrolltext
  into one, start the colour bars and then scroll to the end. }
begin
  { [re] 1000:11ad, the original main block. }
  LoadFont;
  ScnPos := 0;
  Width := 0;
  ScrollX := 0;
  Fading := 0;
  GlobCount := 0;
  Bright := 63;
  LineWidth := 160;
  SetModeX;
  WhiteOut;
  FadeOut;
  SplitScreen;
  ShowFont;
  LoadCheck2;
  Drawit;
  LoadAsphyx;
  for Loop := 1 to 80 do Text[Loop] := Lines[1][Loop];
  for Loop := 1 to 80 do Text[Loop+80] := Lines[2][Loop];
  for Loop := 1 to 80 do Text[Loop+160] := Lines[3][Loop];
  for Loop := 1 to 80 do Text[Loop+240] := Lines[4][Loop];
  for Loop := 1 to 80 do Text[Loop+320] := Lines[5][Loop];
  for Loop := 1 to 80 do Text[Loop+400] := Lines[6][Loop];
  StartPal;
  Finish;
end.
