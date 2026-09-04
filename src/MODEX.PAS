unit ModeX;

{ The unchained 256-colour mode and the two routines that draw in it.
  README.1ST calls this the first Asphyxia demo to use chain-4.

  [re] Original segment 112f, 208 bytes, read in full -- docs/02-units.md.
  Layout to match: PutPixel at 0000, SetModeX at 0043, SetPlane at 00a0, so
  the implementation order below is fixed and SetPlane must be forward. }

interface

var
  { [re] DGROUP 0x816 in the original. The PROGRAM writes it (1000:11d8 sets
    it to 0xa0) and both routines here read it, so it is the unit's and
    exported rather than local. }
  LineWidth : Byte;

procedure PutPixel(x, y : Integer; col : Byte);
procedure SetModeX;

implementation

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
  { [re] The doubling is the CRTC Offset register counting in words, so the
    byte stride per line is twice LineWidth. }
  Mem[$A000 : LineWidth * y * 2 + x] := col;
end;

procedure SetModeX; assembler;
asm
  mov ax, $0013
  int $10

  { [re] Sequencer 04 -- clear bit 3 to turn chain-4 OFF, set bit 2 for
    sequential (odd/even disabled). This is the whole point of the unit. }
  mov dx, $03C4
  mov al, 4
  out dx, al
  inc dx
  in  al, dx
  and al, $F7
  or  al, $04
  out dx, al

  { [re] Graphics Controller 05 bit 4 and 06 bit 1 -- drop odd/even. }
  mov dx, $03CE
  mov al, 5
  out dx, al
  inc dx
  in  al, dx
  and al, $EF
  out dx, al
  dec dx
  mov al, 6
  out dx, al
  inc dx
  in  al, dx
  and al, $FD
  out dx, al

  { [re] Map Mask to all four planes, then clear 64K in one pass. }
  mov dx, $03C4
  mov ax, $0F02
  out dx, ax
  mov ax, $A000
  mov es, ax
  sub di, di
  mov ax, 0
  mov cx, $8000
  cld
  rep stosw

  { [re] CRTC 14 bit 6 off is doubleword addressing off; CRTC 17 bit 6 on is
    byte mode; CRTC 13 is the Offset register and takes LineWidth. }
  mov dx, $03D4
  mov al, $14
  out dx, al
  inc dx
  in  al, dx
  and al, $BF
  out dx, al
  dec dx
  mov al, $17
  out dx, al
  inc dx
  in  al, dx
  or  al, $40
  out dx, al

  mov dx, $03D4
  mov al, $13
  out dx, al
  inc dx
  mov al, LineWidth
  out dx, al
end;

procedure SetPlane;
begin
  { [re] The shift is compiler output and matched first time. The port writes
    are NOT: Port[$3C4] then Port[$3C5] emits a fresh `mov dx` for each, and
    the original walks the pair with `inc dx`. That is hand-written, so it is
    transcribed rather than re-expressed. }
  plane := 1 shl plane;
  asm
    mov dx, $03C4
    mov al, 2
    out dx, al
    inc dx
    mov al, plane
    out dx, al
  end;
end;

end.
