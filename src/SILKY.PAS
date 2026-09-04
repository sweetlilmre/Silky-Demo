program Silky;

{ The 1993 Asphyxia demo, written for Silky's eighteenth birthday.

  [re] Original program segment 1000, 4848 bytes, charted in docs/03-program.md.
  Routines are emitted in source order, so this file's order is fixed by the
  original's layout: WaitRetrace 0000, gotoscnpos 000e, then BARS.INC's own run
  from DeltaPal at 002b through StartPal at 095e -- the include's declaration
  order IS the segment order, which is one of the reasons to believe it. }

uses ModeX;

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
  Value, Value2, Value3 : Integer;
  Count, Count2, Count3 : Integer;

{ [re] 1000:0000, 14 bytes. Called NEAR by DeltaPal -- `e8` with no `push cs`
  at 1000:002e -- so it is local, not far. BARS.INC calls it but does not
  declare it. }
procedure WaitRetrace; assembler;
asm
  mov dx, $03DA
@NotInRetrace:
  in  al, dx
  test al, 8
  jnz @NotInRetrace
@InRetrace:
  in  al, dx
  test al, 8
  jz  @InRetrace
end;

{ [re] 1000:000e, 29 bytes. BARS.INC's StartPal opens with `gotoscnpos`, and
  095e -- which is StartPal -- opens with a near call to 000e, so that is this
  routine's original name. CRTC 0c and 0d are the start address, high then low. }
procedure GotoScnPos; assembler;
asm
  mov bx, ScnPos
  add bx, $BB80
  mov dx, $03D4
  mov al, $0C
  out dx, al
  inc dx
  mov al, bh
  out dx, al
  mov dx, $03D4
  mov al, $0D
  out dx, al
  inc dx
  mov al, bl
  out dx, al
end;

{ [re] The original source, copied from bin/BARS.INC. bin/ holds the shipped
  artefact untouched; this copy is part of the reconstruction and may be
  edited where the binary disagrees with it. Five of its routines already
  rebuild with zero unexplained bytes -- see docs/04-palette-animation.md. }
{$I BARS.INC}

begin
  { [re] NOT the original main block, which is 1000:11ad and calls twenty-odd
    routines. This exists so the smart linker keeps what has been transcribed:
    with an empty main it dropped every routine AND all of ModeX. }
  SetModeX;
  Drawit;
  StartPal;
end.
