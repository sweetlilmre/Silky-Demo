# The palette animation

Five routines in segment `1000` and one 768-byte buffer account for the whole of the demo's colour cycling. All of it hangs off **`t`, the palette buffer at DGROUP `0x328`** — the variable `bin/BARS.INC` names, recovered from `lea si,t` against `lea si,[0x328]`.

## Two System routines, and why there are two

Both take three arguments — a far source pointer, a far destination pointer, and a word count — and both `retf 0xa`.

| | `11a6:0776` | `11a6:09d3` |
|---|---|---|
| setup | `lds si,[bx+0xa]`, `les di,[bx+6]`, `cx=[bx+4]` | identical |
| body | `cld` / `rep movsb` — **forward only** | `cmp si,di`; if the source is below the destination it adds `cx` to both and copies **backward** |

`09d3` is the overlap-safe `Move`. `0776` is the plain forward copy the compiler emits where the operands cannot overlap.

**The choice between them is evidence, not noise.** Every 3-byte save and restore below goes between DGROUP and a stack local, which cannot overlap, and uses `0776`. Every block shift below moves a range onto itself with a 42-byte overlap, and uses `09d3`. The compiler picked the overlap-safe routine exactly where the reading says the ranges overlap.

## The two band rotators: `02a1` and `0449`

424 bytes each, 92% byte-identical, and the 34 differing bytes are the low bytes of `mov di,imm` DGROUP addresses. Each is **eight unrolled blocks of 51 bytes**, one per band, and the bands step 48 bytes — 16 colours:

| band | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| first colour at | `t+3` | `t+51` | `t+99` | `t+147` | `t+195` | `t+243` | `t+291` | `t+339` |
| last colour at | `t+48` | `t+96` | `t+144` | `t+192` | `t+240` | `t+288` | `t+336` | `t+384` |

Each block is three calls. For `02a1`, band 1:

```
Move(t+48, ss:[bp-4], 3)     save the band's LAST colour
Move(t+3,  t+6,      45)     shift colours 1..15 up one place   <- overlapping, so 09d3
Move(ss:[bp-4], t+3,  3)     the saved colour becomes the first
```

`0449` is the same block with the addresses rotated one position: it saves the band's **first** colour, shifts `t+6` down to `t+3`, and drops the saved colour into the band's last slot.

**So `02a1` rotates each of the eight bands forward and `0449` rotates them backward.** Together they cover colours 1 to 128; colour 0 is never touched.

## The two whole-range rotators: `015d` and `01ff`

162 bytes each, one block apiece, count `336` — which is 112 colours. `015d` moves `t+3` to `t+51`, `01ff` moves `t+51` to `t+3`. The step is 48 bytes, one whole band.

So this pair rotates the same 128-colour region **by a whole band of 16 at a time**, forward and backward, where the first pair rotates *within* each band by one.

## The dispatcher: `05f1`

```
inc  [0x320]                       the frame counter, zeroed by main at 11ce
ax = [0x320]
    1 ..  200   call 02a1          rotate within each band, forward
  201 ..  320   call 015d          rotate the whole range forward, a band at a time
  321 ..  520   call 0449          rotate within each band, backward
  521 ..  640   call 01ff          rotate the whole range backward
if [0x320] = 640 then [0x320] := 0
```

A **640-frame cycle in four phases** — 200, 120, 200, 120. `[0x320]` is the phase counter and `0x280` is its wrap point.

## How it reaches the screen

`1000:002b`, `DeltaPal`, waits for retrace on port `3da` and then pumps all 768 bytes of `t` out to the DAC through `3c8`/`3c9`. Nothing in the cyclers touches hardware; they rewrite the buffer and `DeltaPal` uploads it.

## Left unsettled

The 3-byte save and restore counts in `015d` and `01ff` were not recovered by the scan that found the `336`, so the exact save/restore slots in that pair are read from the pattern of the other pair rather than measured directly. The band arithmetic itself is measured.
