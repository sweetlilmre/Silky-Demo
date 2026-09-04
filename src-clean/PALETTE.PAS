{$G-}

unit Palette;

{ The VGA DAC writer and the table its initialisation clears. }

interface

procedure SetPalette(col, r, g, b : Byte);

implementation

type
  TEntry = record
    Head    : Word;                     { +$000 <- $FFFF }
    Unread1 : array[1..250] of Byte;    { +$002 }
    Flag    : Byte;                     { +$0FC <- 0 }
    Unread2 : array[1..4] of Byte;      { +$0FD }
  end;

var
  Tbl : array[1..67] of TEntry;

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
  Randomize;
  ClearTable;
end.
