{$G-}
{ [re] 286 code generation OFF for this unit, against the /$G+ on the command
  line. Measured: at 113c:0018 the original computes the record offset with
  `mov ax,$0101` then `mul`, which is 8086. With $G+ Turbo Pascal emits
  `imul di,[bp-2],$0101` instead, a 186 instruction, and the unit diverges
  there. Nothing else in these 124 bytes needs a 186 opcode either, whereas
  MODEX and the program both contain one -- so the directive really is
  per-unit here rather than project-wide. }

unit Palette;

{ The VGA DAC writer and the table its initialisation clears.

  [re] Original segment 113c, 128 bytes, read in full -- docs/02-units.md.
  Layout to match: the table fill at 0000, SetPalette at 0045, and the unit's
  initialisation section at 0067, which Turbo Pascal emits last. }

interface

procedure SetPalette(col, r, g, b : Byte);

implementation

type
  { [re] 0x101 = 257 bytes per record, from `mov ax,$0101` / `mul` at
    113c:0018. The only two fields the original touches are a word at +0 and
    a byte at +$fc; everything between is unread, so it is named Unread rather
    than guessed at. See the table-at-dgroup-0717 investigation. }
  TEntry = record
    Head    : Word;                     { +$000 <- $FFFF }
    Unread1 : array[1..250] of Byte;    { +$002 }
    Flag    : Byte;                     { +$0FC <- 0 }
    Unread2 : array[1..4] of Byte;      { +$0FD }
  end;

var
  { [re] 67 records. The original folds the 1-based subscript into the
    displacement, so its base constant is 0x717 and Tbl[1] lands at 0x818. }
  Tbl : array[1..67] of TEntry;

  { [re] 1575 MORE BYTES OF PALETTE DATA, and only their SIZE is evidenced.
    Crt's variables start at 0x5182 in the original -- the lowest DGROUP
    operand anywhere in its segment -- and Tbl starts at 0x818, so this unit
    owns 18794 bytes. The init loop evidences 67 records of 257, which is
    17219, and 1573 is the remainder -- 1575 overshot by two, which the
    +2 delta on all 82 Crt and System operands reported exactly. Nothing in the 124 bytes of PALETTE
    touches it, so its type and purpose are unknown and it is declared by
    length alone. Inflating Tbl to array[1..73] would also fit the arithmetic
    and would contradict the loop bound, which counts to 67. }
  Unread : array[1..1573] of Byte;

{ [re] 113c:0000. Called by the initialisation section below, which is why it
  is emitted first. Frames 6 bytes: a Word counter and a far pointer.
  FAR: it ends in retf, and the init at 113c:0076 pushes CS before the
  near call, which is how Borland reaches a far routine in its own
  segment. Declared near it ended in ret and diverged at +$44. }
procedure ClearTable; far;
var
  Loop : Word;
begin
  { [re] A WITH, not a pointer variable. The original computes the record's
    address once into DI, adds the fold constant, and stores DI:DS as a far
    pointer in a 4-byte local -- then reaches every field through
    `les di,[bp-6]`. That is exactly what Turbo Pascal emits for `with`, and
    the 6-byte frame is the 2-byte counter plus that hidden pointer. Writing
    it as an explicit `P := @Tbl[Loop]` produced `lea ax,[di+0]` and a detour
    through DX instead, and diverged at +$20. }
  for Loop := 1 to 67 do
    with Tbl[Loop] do
    begin
      Head := $FFFF;
      Flag := 0;
    end;
end;

{ EQUIVALENT PASCAL, reference only:
    Port[$3C8] := col;  Port[$3C9] := r;  Port[$3C9] := g;  Port[$3C9] := b;

  [re] That is not what the original emits: Port[] reloads DX for each port
  where the original loads it once and steps with `inc dx`, so the body below
  is transcribed rather than written. }
procedure SetPalette(col, r, g, b : Byte);
begin
  asm
    mov dx, $03C8   { the DAC write-index port }
    mov al, col     { which colour register to write }
    out dx, al      { select it; the DAC auto-increments after three writes }
    inc dx          { 3C9, the DAC data port }
    mov al, r       { red, 0..63 }
    out dx, al      { first of the triplet }
    mov al, g       { green }
    out dx, al      { second }
    mov al, b       { blue }
    out dx, al      { third -- the register is now complete }
  end;
end;

begin
  { [re] 113c:0067, the initialisation section. The System routine it calls
    first is RANDOMIZE: 11a6:0815 is b4 2c cd 21, which is DOS Get System
    Time, storing CX and DX into DGROUP 0x316 -- that four-byte value is
    RandSeed. Nothing else in the image calls it. }
  Randomize;
  ClearTable;
end.
