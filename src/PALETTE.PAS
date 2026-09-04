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

{ [re] 113c:0000. Called by the initialisation section below, which is why it
  is emitted first. Frames 6 bytes: a Word counter and a far pointer. }
procedure ClearTable;
var
  Loop : Word;
  P    : ^TEntry;
begin
  for Loop := 1 to 67 do
  begin
    P := @Tbl[Loop];
    P^.Head := $FFFF;
    P^.Flag := 0;
  end;
end;

{ EQUIVALENT PASCAL, reference only:
    Port[$3C8] := col;  Port[$3C9] := r;  Port[$3C9] := g;  Port[$3C9] := b;
  That is NOT what the original emits -- it loads DX once and steps to the
  data port with `inc dx`, so the body is transcribed rather than written. }
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
  { [re] 113c:0067, the initialisation section. It calls a System routine at
    11a6:0815 before ClearTable; that call is not yet identified, so nothing
    stands in for it here and the segment will be short by its length. }
  ClearTable;
end.
