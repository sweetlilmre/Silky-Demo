# The remaining program routines

What each of the larger routines in segment `1000` does, from its instructions. Together with [04-palette-animation.md](04-palette-animation.md) this accounts for every routine in the segment except the four file loaders and the twin pair already covered.

## `064b` — the palette builder, 787 bytes

No calls but the stack check; 140 `mov`, 66 `add`, 18 `shl`. It writes the palette buffer directly, indexed:

```
mov byte ptr [di + 0x328], cl / 0        R
mov byte ptr [di + 0x329], cl / 0        G
mov byte ptr [di + 0x32a], cl / 0        B
```

Six such stores write `cl` and six write a literal `0`, so each colour channel is either a computed value or forced dark. It reads base values from **`0x31c`, `0x31d`, `0x31e`** (nine references each) and **`0x324`, `0x325`, `0x326`** (three each) — two RGB triplets sitting just below `t` — and a table at `0x2d3` indexed by the loop counter.

So the 768-byte palette is **generated**, not loaded, from two base colours and a per-entry table.

## `095e` — the palette ramp, 157 bytes

```
call 000e                      set the start address
FillChar(ds:0x2d4, 5, 0)       via System:09f6
repeat 16 times:
    call 064b                  rebuild the palette
    call 05f1                  cycle it one frame
    call 002b                  DeltaPal -- wait retrace, upload 768 bytes
then ramp:  [0x2d5] up to 0x1e (30), [0x2d6] up by 2 to 0x28 (40), ...
```

`System:09f6` taking a pointer, a count and a fill byte is `FillChar`. The parameters this ramps at `0x2d4..0x2d8` are the same ones `064b` reads, so this is an animated fade: nudge the parameters, regenerate, upload, repeat.

## `0cb1` — the blitter, 700 bytes

Six `lcall 112f:0000` — six PutPixel sites — and all six are byte-identical in their final four instructions:

```
mov al, byte ptr es:[di - 0x2011]     read a source byte
xor ah, ah
add ax, word ptr [bp - 0xa]           add a colour offset
push ax                               ... as PutPixel's colour
lcall 112f:0000
```

The source is a **far pointer held at DGROUP `0x628`**, loaded with `les di, ptr [0x628]` and indexed `[bp-2] * 256 + [bp-1] * 16`. A pointer rather than an array is why nothing in the segment references the image data by absolute address.

**`- 0x2011` is a folded array subscript.** The wiki's `subscript-fold-names-the-bounds` says a constant folded into the displacement encodes the array's lower bounds, so this constant should name them. It does not decompose cleanly against the two strides seen here (`0x2011` is `32 * 256 + 17`, and 17 is not a multiple of the 16-byte stride), so a third term is in play and the bounds are **not yet read**.

Six identical sites plotting from one source with one colour offset is consistent with a symmetric figure drawn in six copies, which would match `README.1ST`'s account of the Asphyxia symbol coming out of "how to generate paths for a bouncing ball routine". That is a reading, not a measurement — what is measured is six identical call sites and a shared source pointer.

## `0f6d` — the VRAM block copy, 175 bytes

```
3ce <- 0x4105     Graphics Mode register 5 := 0x41 -- WRITE MODE 1
3c4 <- 0x0f02     Map Mask := all four planes
   ... the copy ...
3ce <- 0x4005     Graphics Mode register 5 := 0x40 -- back to write mode 0
```

Write mode 1 copies the VGA latches straight to memory, which is the standard Mode X video-to-video block move: one byte read and one byte written moves four pixels with no CPU involvement in the data. It touches `0x62c` — the value `000e` puts into the CRTC start address — plus `0x62e`, `0x62f`, `0x630`, `0x632`.

This is the scroll engine: copy within display memory, then move the start address.

## `09fb` and `10df`

`09fb` (191 bytes) reads `0x323` seven times and `0x322` once. Main sets `[0x323] := 0x3f` — 63, the top of a VGA DAC component — and `[0x322] := 0`, so this is fade-related, but it is not read further here.

`10df` (181 bytes) calls `002b` (DeltaPal) and has no absolute DGROUP references at all. Called from main at `11e5`, before the split screen is set up.

## The shape of the demo

| layer | routines |
|---|---|
| hardware setup | `112f:0043` unchained mode, `10a1` split screen at line 100, `10be` text mode |
| palette | `064b` build, `02a1`/`0449`/`015d`/`01ff` cycle, `05f1` dispatch, `002b` upload on retrace |
| drawing | `0cb1` blit from the heap pointer at `0x628`, `112f:0000` PutPixel |
| scrolling | `0f6d` VRAM copy in write mode 1, `000e` CRTC start address |
| data | four loaders for `scroll.col`, `gold.Fnt`, `Check2.Cel`, `Asphyx.Cel` |
