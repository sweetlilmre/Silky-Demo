unit ModeX;

{ The unchained 256-colour mode and the two routines that draw in it.
  README.1ST calls this the first Asphyxia demo to use chain-4. }

interface

var
  { The CRTC Offset register's value, which counts in WORDS -- so the byte
    stride from one screen row to the next is twice this. SetModeX writes it
    to the hardware and PutPixel uses it to find a row; the program sets it
    before calling either. }
  LineWidth : Byte;

procedure PutPixel(x, y : Integer; col : Byte);
procedure SetModeX;

implementation


procedure SetPlane(plane : Byte); far; forward;

procedure PutPixel(x, y : Integer; col : Byte);
begin
  SetPlane(x mod 4);
  x := x div 4;
  { Doubled because LineWidth is the CRTC Offset, which counts in words. }
  Mem[$A000 : LineWidth * y * 2 + x] := col;
end;

procedure SetModeX; assembler;
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
  plane := 1 shl plane;
  { EQUIVALENT PASCAL, reference only:
        Port[$3C4] := 2;  Port[$3C5] := plane; }
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
