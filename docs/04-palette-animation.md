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

## The original names, recovered

`bin/BARS.INC` holds Pascal for all five of these routines. It was read **after** the reading above was derived from bytes, and every structural detail agrees — so this is a confirmation, not a source.

| segment offset | this document called it | `BARS.INC` calls it |
|---|---|---|
| `02a1` | rotate within each band, forward | `RotPal0` |
| `0449` | rotate within each band, backward | `RotPal1` |
| `015d` | rotate the whole range forward | `RotPal2` |
| `01ff` | rotate the whole range backward | `RotPal3` |
| `05f1` | the dispatcher | `rotpal` |
| `064b` | the palette builder | `PlayPal` |
| `095e` | the palette ramp | `StartPal` |
| `000e` | SetStartAddress | `gotoscnpos` |
| `[0x2d4]` | the ramp parameters | `PalCol`, `array[1..5] of Byte` |
| `[0x320]` | the phase counter | `GlobCount` |
| `[0x328]` | the palette buffer | `T`, an `array[0..255] of RGBt` |

The source confirms each measured number: `15*3` is the 45-byte band shift, `336` is the whole-range move, the bands are 16 colours, there are eight of them, and the `case` arms are `1..200`, `201..320`, `321..520`, `521..640` with the wrap at 640 — dispatching `rotpal0`, `rotpal2`, `rotpal1`, `rotpal3` in that order, which is exactly the order the call sites gave.

**The array is 0-based and used 1-based.** `T` sits at `0x328` and the code indexes `T[1]` upward, so `T[1]` is `0x32b` and `T[16]` is `0x358` — which is why the measured band addresses came out at `t+3` and `t+48`. `DeltaPal`'s `lea si,t` is `0x328`, the whole 256-colour buffer.

### A name I got wrong, corrected

The first version of this table said `064b` was `StartPal`. It is **`PlayPal`**, and `StartPal` is `095e`. The evidence is in both directions and I had already measured both halves without joining them up:

* `PlayPal` writes `T[150+Loop+count]`, and `064b` contains `add ax, 0x96` — 150.
* `StartPal` opens `gotoscnpos; FillChar(palcol,SizeOf(palcol),0)`, and `095e` opens `call 000e` then `FillChar(ds:0x2d4, 5, 0)`. So `PalCol` is five bytes at `0x2d4` and `000e` is `gotoscnpos`.
* `StartPal`'s loop is `repeat playpal; rotpal; deltapal; inc(Count); if Count > 15 then` — and `095e` is `call 064b; call 05f1; call 002b; inc [bp-6]; cmp [bp-6],0x0f; jbe`.
* `if palcol[2] < 30 then inc(palcol[2],1) else palcol[2] := 30` is `cmp byte [0x2d5],0x1e / jae / inc / mov [0x2d5],0x1e`, and 30 is `0x1e`. The `palcol[3]` arm is 40, which is `0x28`, incremented by 2.

The descriptions in [05-routines.md](05-routines.md) were right — `064b` builds and `095e` ramps. Only the two names were swapped, in the commit that introduced them.

### Tested: the include IS the source for these five

`BARS.INC` was compiled **unmodified** and the result compared against the original.

| routine | segment | bytes | System far pointers | DGROUP addresses | unexplained |
|---|---|---:|---:|---:|---:|
| `RotPal2` | `015d` | 162 | 4 | 4 | **0** |
| `RotPal3` | `01ff` | 162 | 4 | 4 | **0** |
| `RotPal0` | `02a1` | 424 | 25 | 32 | **0** |
| `RotPal1` | `0449` | 424 | 25 | 32 | **0** |
| `rotpal` | `05f1` | 90 | 1 | 4 | **0** |

**1,262 bytes, zero unexplained differing bytes.** Every difference is a far pointer into the System segment or a DGROUP variable address — relocation and placement, both of which converge as the reconstruction completes.

Two details rule out coincidence. `RotPal2` frames `0x32` bytes of locals in both builds, which is `Loop` and `loop2` as bytes plus `Tmp : Array[1..16] of RGBt` — so even the **unused** `loop2` is confirmed, since without it the frame would be 49. And `rotpal`'s relative call to `RotPal0`, `e8 92 fc`, is byte-identical, which means all four rotators compile to exactly the original sizes.

### So what is BARS.INC?

**The original source, at a different revision.** Three edits are known:

* `DeltaPal` writes `rep outsb` where the binary does `lodsb` / `out dx,al` / `loop`.
* `Drawit` declares `F : File`, never uses it, and has a conspicuous gap before its `End` — the `scroll.col` loading that `1000:0052` performs has been taken out.
* `Drawit` is also missing the loop at `1000:00af` that blacks out the eighty-nine colours the bars use, in the buffer and through `SetPalette` both, before anything is drawn in them.

`src/BARS.INC` is the include with all three put back, and each is marked where it happens.

The working rule is therefore: compile each routine and let the bytes decide. That is now cheap.
