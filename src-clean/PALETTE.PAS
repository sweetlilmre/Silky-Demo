{$G-}
{ 286 code generation is OFF for this unit, and deliberately -- the rest of
  the program is built with it on, so removing this line changes the code
  this unit emits. }

unit Palette;

{ The VGA DAC writer and the table its initialisation clears. }

interface

procedure SetPalette(col, r, g, b : Byte);

implementation

type
  { A 257-byte record. This unit sets only two of its fields and reads none
    of them back, and nothing else in the program touches the table at all --
    so the other fields have no recoverable meaning and are named for that
    rather than guessed at. }
  TEntry = record
    Head    : Word;                     { +$000 <- $FFFF }
    Unread1 : array[1..250] of Byte;    { +$002 }
    Flag    : Byte;                     { +$0FC <- 0 }
    Unread2 : array[1..4] of Byte;      { +$0FD }
  end;

var
  Tbl : array[1..67] of TEntry;

  { More of this unit's data, which nothing in the program reads. It is
    declared so that everything allocated after it lands where it should. }
  Unread : array[1..1573] of Byte;

procedure ClearTable; far;
var
  Loop : Word;
begin
  for Loop := 1 to 67 do
    with Tbl[Loop] do
    begin
      Head := $FFFF;
      Flag := 0;
    end;
end;

{ EQUIVALENT PASCAL, reference only:
    Port[$3C8] := col;  Port[$3C9] := r;  Port[$3C9] := g;  Port[$3C9] := b; }
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
  { Seeds the random number generator, then clears the table above. }
  Randomize;
  ClearTable;
end.
