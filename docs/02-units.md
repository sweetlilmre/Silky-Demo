# The two small units: 112f and 113c

Both are read in full — 208 and 128 bytes, every instruction accounted for. Neither name is recovered from the image; both are this reconstruction's choice, and the linker map will record what *we* called them, which is not the same as what the authors called them.

Every routine in both units opens with `lcall 11a6:04df`, which is the runtime's stack check. `AX` carries the number of bytes of locals the routine is about to claim — `0` where there are none.

## 112f — the Mode X unit

`bin/README.1ST` says this demo was Asphyxia's first use of chain-4. This is that code.

### `0043` — set the unchained mode

`mov ax,0x13` / `int 10h` sets VGA mode 13h, and everything after it takes mode 13h apart:

| port | index | what it does |
|---|---|---|
| `3c4` Sequencer | `04` | read, `and 0xf7` clears bit 3 — **chain-4 off**; `or 0x04` sets odd/even disable |
| `3ce` Graphics | `05` | `and 0xef` clears bit 4, the odd/even mode |
| `3ce` Graphics | `06` | `and 0xfd` clears bit 1, chain odd/even |
| `3c4` Sequencer | `02` | `ax=0x0f02` — Map Mask to all four planes, so the clear below hits every plane at once |
| — | — | `es=0xa000`, `di=0`, `ax=0`, `cx=0x8000`, `rep stosw` — 64K cleared |
| `3d4` CRTC | `14` | `and 0xbf` clears bit 6, doubleword addressing |
| `3d4` CRTC | `17` | `or 0x40` sets bit 6 — byte mode |
| `3d4` CRTC | `13` | the Offset register, taken from DGROUP `[0x816]` |

`retf` with no parameters.

### `00a0` — select a plane

Takes one byte parameter, computes `ax = 1 shl plane`, and writes it to Sequencer index `02`, the Map Mask. `retf 2`. It writes the shifted value back over its own parameter slot at `[bp+6]` before using it, which is the compiler reusing the stack slot rather than anything meaningful.

### `0000` — PutPixel

Three parameters: `x` at `[bp+0xa]`, `y` at `[bp+8]`, colour at `[bp+6]`. `retf 6`.

- `x` is divided by 4 with `cwd`/`idiv cx` — a **signed** divide, so a negative x is handled as signed rather than wrapping.
- The remainder is pushed and `00a0` is called with it: `x mod 4` is the plane.
- `x div 4` replaces the parameter and becomes the column.
- The row is `[0x816] * y * 2`. The doubling is because CRTC `13` counts in words, so the byte stride per line is twice the Offset register — which is the same `[0x816]` written at `0043`. One value, two readers, consistent.
- `es = 0xa000`, `es:[di] = colour`.

**DGROUP `0x816` is the line width**, and both routines depend on it. Nothing in these 208 bytes writes it, so it is set elsewhere — the program, or the unit init this segment does not appear to have.

## 113c — the palette unit

### `0045` — SetPalette

Four byte parameters. Colour index at `[bp+0xc]` goes out to port `3c8`, the VGA DAC write index; then `dx` is incremented to `3c9` and three components go out from `[bp+0xa]`, `[bp+8]`, `[bp+6]`. `retf 8` — four byte parameters pushed as four words.

`bin/BARS.INC`, which shipped with the demo, drives the same ports in its `DeltaPal`: `mov dx,3c8h` … `inc dx` … `rep outsb`. The original source and the binary agree on the mechanism.

### `0067` — the unit init, and `0000` — the table fill

`0067` is what the program calls at `1000:11a8` during its init chain. It calls a System routine at `11a6:0815`, then calls `0000`.

`0000` claims 6 bytes of locals and loops a counter from 1 to `0x43` (67) inclusive. Each pass computes a DGROUP address of `0x717 + 0x101 * i`, builds a far pointer `ds:that`, and writes two fields:

- the **first word** of the record ← `0xffff`
- the byte at **`+0xfc`** ← `0`

So: 67 records, `0x101` = 257 bytes each, based at DGROUP `0x717`, running to `0x4a5a`.

**What that table is remains unread**, and the reconstruction now bounds it. The record is 257 bytes with a word at offset 0 and a flag byte at 252; the loop starts at 1 rather than 0, so either record 0 is skipped deliberately or the base is really `0x717 + 0x101`. Nothing here says which, and the fields the loop does *not* touch are untouched by this unit at all.

The linker settles the unit's total: Crt's lowest DGROUP operand is `0x5182` and `Tbl` starts at `0x818`, so this unit owns **18,794 bytes**. The init loop evidences 67 records of 257, which is 17,219, and the remaining **1,573 are declared by length alone** — inflating `Tbl` to `array[1..73]` fits the same arithmetic and contradicts the loop's bound of 67, so a separate array of unknown purpose is the honest declaration.

## A correction

An earlier note in this project claimed `113c:0079` held the load image's only virtual call site, a `CALLF [DI+cb]`, and inferred an object with a VMT. **That was wrong.** The bytes at `113c:0075` are `01 0e e8 86 ff 5d cb`: `e8 86 ff` is the `call rel16` to `0000` at offset `0x77`, then `5d` is `pop bp` and `cb` is `retf`. The scanner matched `ff 5d cb` across three instruction boundaries.

`survey.py` says this about itself — its frameless and virtual scans are byte searches and it prints them as "an UPPER BOUND, not a count". The claim was recorded as fact anyway. There is no VMT anywhere in this image, and no object.
