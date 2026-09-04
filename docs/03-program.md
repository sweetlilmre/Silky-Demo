# The program segment, 1000

4848 bytes. **23 code entities**: 17 routines the prologue scan finds, 5 frameless ones it cannot, and the main block. One prologue candidate is not a routine at all.

## What is a routine here, and how that was settled

`rtl.py entries` proposes 19 entry points by prologue shape. Only a `CALL` proves one — the wiki's `prologue-scan-endorses-data` — so every candidate was intersected with the near-call targets resolved out of the disassembly.

- **17 of 19 are called.**
- **`0039` is not called, and is not a routine.** It is the tail of the `scroll.col` string literal read as `ENTER $b003`. Exactly the failure that observation describes.
- **`11ad` is not called either, and *is* real.** It is the main block, reached by fall-through from the entry sequence rather than by a call. A candidate with no caller needs a reason, not a deletion.
- **5 routines are called but have no `PUSH BP`**: `000e`, `002b`, `10a1`, `10be`, `1194`. The prologue scan is blind to all five, and four of them are the most interesting code in the segment.

## The frameless five

| offset | bytes | what the instructions say |
|---|---:|---|
| `0000` | 14 | **WaitRetrace.** Reads port `3da`, spins while bit 3 is set, then spins until it is set. |
| `000e` | 29 | **SetStartAddress.** `bx = [0x62c] + 0xbb80`, then CRTC `0c` (start high) and `0d` (start low). This is how the demo scrolls and flips. |
| `002b` | 39 | **DeltaPal.** Calls `WaitRetrace`, then `lea si,[0x328]`, `cx=0x300`, index `0` out to `3c8`, and 768 bytes out to `3c9`. |
| `10a1` | 29 | **Split screen.** CRTC `18` (Line Compare) `= 0x64`; CRTC `07` bit 4 cleared and CRTC `09` bit 6 cleared, which are line-compare bits 8 and 9. **The split is at scanline 100.** |
| `10be` | 6 | **TextMode.** `mov ax,3` / `int 10h`. |

## DeltaPal is in the box, and it does not match

`bin/BARS.INC` shipped with the demo and contains `Procedure DeltaPal; assembler;`. Set against `1000:002b`, every instruction corresponds — the same three pushes, the same `call waitretrace`, the same `cx=768`, the same `dx=3c8h`, `al=0`, `out`, `inc dx` — with one difference:

| `bin/BARS.INC` | `1000:002b` |
|---|---|
| `rep outsb` | `lodsb` / `out dx,al` / `loop` |

Equivalent in effect, different in bytes. **So the source we hold is not the source this binary was built from** — it is a variant of it. Which came first is not settled here; a `rep outsb` to the DAC was known to be too fast for some cards, so either direction is a plausible edit.

The include also gives a name to a variable: `lea si,t` in the source is `lea si,[0x328]` in the binary, so **DGROUP `0x328` is `t`**, the 768-byte palette buffer. That is one original identifier recovered, and it did not come from reading bytes.

## The four file loaders, and how they name themselves

Turbo Pascal emits a string literal immediately before the routine that uses it. All four of the demo's data files are in `bin/`, and each filename sits directly against a routine:

| literal at | text | routine | System calls in it |
|---|---|---|---|
| `0047` | `scroll.col` | `0052` | `04a9` ×3, `0822`, `0850`, `093b` |
| `0ab1` | `gold.Fnt` | `0aba` | `04a9` ×3, `023f`, `0822`, `0850` |
| `0b25` | `Check2.Cel` | `0b30` | `04a9` ×4, `093b` ×2, `0822`, `0850` |
| `0be9` | `Asphyx.Cel` | `0bf4` | `04a9` ×4, `093b` ×2, `0822`, `0850` |

The shared `04a9` / `0822` / `0850` / `093b` group is the file-I/O family — assign, open, read, close — though which System offset is which is not yet settled.

## The entry sequence is not a routine

```
1000:1194  call 0xe / call 0x101c / call 0x10be / ret      <- the exit routine
1000:119e  lcall 11a6:0000     System init                 <- the MZ entry point
1000:11a3  lcall 1144:0000     Crt init
1000:11a8  lcall 113c:0067     the palette unit's init
1000:11ad  push bp ...                                     <- the main block
```

`CS:IP` in the MZ header points at `119e`, which is 15 bytes of unit-init chain that falls straight into `11ad`. The 10 bytes at `1194` immediately before it are a separate routine — the **exit** path, called once from `12e0`: restore the start address, call `101c`, then `TextMode(3)`.

## What main does, in order

```
11b7  call 0aba          load gold.Fnt          <- before the mode is set
11ba  [0x62c] = 0        the scroll offset SetStartAddress reads
11bf  [0x630] = 0
11c4  [0x632] = 0
11c9  [0x322] = 0
11ce  [0x320] = 0
11d3  [0x323] = 0x3f     63, the top of a VGA DAC component
11d8  [0x816] = 0xa0     160 -- the Mode X line width
11dd  lcall 112f:0043    set the unchained mode, which reads [0x816]
11e2  call 10c4
11e5  call 10df
11e8  call 10a1          split the screen at scanline 100
11eb  call 0cb1
11ee  call 0b30          load Check2.Cel
11f1  call 0052          load scroll.col
11f4  call 0bf4          load Asphyx.Cel
      ... two copy loops into [di+0x633] ...
12e0  call 1194          exit
```

`[0x816]` is written here and read by both Mode X routines — the only writer in the image, and it is the program rather than the unit that sets it.

## Still open

The two 424-byte routines at `02a1` and `0449` have the same shape — `System:0776` ×16 and `System:09d3` ×8 apiece — and are almost certainly a pair. Neither is identified.

Nothing in this segment references DGROUP `0x717..0x4a5a` by absolute address, so the 67-record table the palette unit initialises is still unaccounted for; if it is filled at all, it is through a computed pointer.
