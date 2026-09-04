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

begin
  { [re] NOT the original main block, which is 1000:11ad and calls twenty-odd
    routines. This exists so the smart linker keeps what has been transcribed:
    with an empty main it dropped every routine here AND all of ModeX, and the
    built image held neither. Routines are emitted in source order, so their
    offsets from 0 stand while this grows downwards. }
  SetModeX;
  GotoScnPos;
  DeltaPal;
end.
