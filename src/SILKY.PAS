program Silky;

{ The 1993 Asphyxia demo, written for Silky's eighteenth birthday.

  [re] Original program segment 1000, 4848 bytes, charted in docs/03-program.md.
  Routines are emitted in source order, so this file's order is fixed by the
  original's layout: WaitRetrace at 0000, gotoscnpos at 000e, DeltaPal at 002b. }

uses ModeX;

type
  { [re] Named by bin/BARS.INC, which declares Tmp : Array[1..16] of RGBt. }
  RGBt = record
    r, g, b : Byte;
  end;

var
  { [re] DGROUP 0x328 in the original, and DeltaPal's `lea si,t` points at its
    first byte. Zero-based but indexed from 1 by every routine that uses it,
    which is what puts T[1] at 0x32b and T[16] at 0x358. }
  T : array[0..255] of RGBt;
  { [re] DGROUP 0x62c. gotoscnpos adds 0xbb80 to it and hands the sum to the
    CRTC start address. Name is ours; BARS.INC does not declare it. }
  ScnPos : Word;
  { [re] DGROUP 0x320, named GlobCount by BARS.INC's rotpal. }
  GlobCount : Word;

{ [re] 1000:0000, 14 bytes. Called near by DeltaPal -- `e8` with no `push cs`
  at 1000:002e -- so it is a local procedure, not far. bin/BARS.INC calls it
  `waitretrace` but does not declare it. }
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

{ [re] 1000:002b, 39 bytes. bin/BARS.INC holds this routine and it does NOT
  match: the include writes `rep outsb` where the binary does lodsb / out /
  loop. Transcribed from the BINARY, which is the measurement target. The
  include is a variant -- see the barsinc-differs-from-binary investigation. }
procedure DeltaPal; assembler;
asm
  push ds
  push si
  push cx
  call WaitRetrace
  lea si, T
  mov cx, $0300
  mov dx, $03C8
  mov al, 0
  out dx, al
  inc dx
@Next:
  lodsb
  out dx, al
  loop @Next
  pop cx
  pop si
  pop ds
end;

{ [re] The four rotators and their dispatcher, TRANSCRIBED FROM bin/BARS.INC
  rather than from the bytes, deliberately: the include's structure already
  agrees with the reading in docs/04, so compiling it is the test of whether
  the include IS the source for these routines. Segment order is 015d RotPal2,
  01ff RotPal3, 02a1 RotPal0, 0449 RotPal1, 05f1 rotpal -- which is the order
  BARS.INC declares them in, and this file keeps it. }

Procedure RotPal2;
Var
    Loop,loop2 : Byte;
    Tmp : Array[1..16] of RGBt;
Begin
   For Loop := 1 to 16 do
   Tmp[Loop] := T[112+Loop];
   move(T[1],T[17],336);
   For Loop := 1 to 16 do
   T[Loop] := Tmp[17-Loop];
End;

Procedure RotPal3;
Var
    Loop,loop2 : Byte;
    Tmp : Array[1..16] of RGBt;
begin
   For Loop := 1 to 16 do
   Tmp[Loop] := T[Loop];
   move(T[17],T[1],336);
   For Loop := 1 to 16 do
   T[112+Loop] := Tmp[17-Loop];
end;

Procedure RotPal0;
Var
    Tmp : Rgbt;
Begin
   tmp := t[16];
   move(t[1],t[2],15*3);
   t[1] := tmp;

   tmp := t[32];
   move(t[17],t[18],15*3);
   t[17] := tmp;

   tmp := t[48];
   move(t[33],t[34],15*3);
   t[33] := tmp;

   tmp := t[64];
   move(t[49],t[50],15*3);
   t[49] := tmp;

   tmp := t[80];
   move(t[65],t[66],15*3);
   t[65] := tmp;

   tmp := t[96];
   move(t[81],t[82],15*3);
   t[81] := tmp;

   tmp := t[112];
   move(t[97],t[98],15*3);
   t[97] := tmp;

   tmp := t[128];
   move(t[113],t[114],15*3);
   t[113] := tmp;
End;

Procedure RotPal1;
Var
    Tmp : Rgbt;
Begin
   tmp := t[1];
   move(t[2],t[1],15*3);
   t[16] := tmp;

   tmp := t[17];
   move(t[18],t[17],15*3);
   t[32] := tmp;

   tmp := t[33];
   move(t[34],t[33],15*3);
   t[48] := tmp;

   tmp := t[49];
   move(t[50],t[49],15*3);
   t[64] := tmp;

   tmp := t[65];
   move(t[66],t[65],15*3);
   t[80] := tmp;

   tmp := t[81];
   move(t[82],t[81],15*3);
   t[96] := tmp;

   tmp := t[97];
   move(t[98],t[97],15*3);
   t[112] := tmp;

   tmp := t[113];
   move(t[114],t[113],15*3);
   t[128] := tmp;
End;

Procedure rotpal;
begin
   inc(GlobCount);
   case globcount of
        1..200 : rotpal0;
      201..320 : rotpal2;
      321..520 : rotpal1;
      521..640 : rotpal3;
   end;
   If GlobCount = 640 then GlobCount := 0;
end;

begin
  { [re] NOT the original main block, which is 1000:11ad and calls twenty-odd
    routines. This exists so the smart linker keeps what has been transcribed:
    with an empty main it dropped every routine here AND all of ModeX, and the
    built image held neither. Routines are emitted in source order, so their
    offsets from 0 stand while this grows downwards. }
  SetModeX;
  GotoScnPos;
  DeltaPal;
  rotpal;
end.
