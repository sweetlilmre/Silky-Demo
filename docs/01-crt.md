# Segment 1144 is Crt

**From our own bytes.** Six routines were read out of `1144` with `substrate/disasm.py`, and each one is a Crt export doing what only Crt does.

| offset | routine | what the instructions say |
|---|---|---|
| `0000` | unit init | Builds two records at DGROUP `0x5196` and `0x5296`, exactly `0x100` apart — the size of a Turbo Pascal `TextRec` — and hands each to a System routine. That is `Input` and `Output` being assigned. |
| `002e` | video setup | `mov ah,0x0f` + `int 10h` reads the current mode; mode 7 or anything ≤ 3 is accepted, anything else is forced to `TextMode(3)`. Then `mov ah,8` + `int 10h` reads the attribute at the cursor and stores it, masked with `0x7f`, as `TextAttr`. |
| `0180` | `Window` | Four **byte** parameters off `ss:[bx+4..0xa]`. Rejected if `X1 > X2` or `Y1 > Y2`; decremented to 0-based, so `0` is invalid; bounds-checked against `[0x5190]`/`[0x5191]`; stored to `[0x518a]` and `[0x518c]` — `WindMin` and `WindMax` — then `GotoXY(1,1)`. `retf 8` is four byte parameters pushed as four words. |
| `01c0` | `ClrScr` | `AX=0x600`, `BH` from `TextAttr` at `[0x5188]`, `CX`/`DX` the window bounds. |
| `02d4` | `Sound` | `in 0x61` / `or al,3` / `out 0x61` gates the speaker. `mov al,0xb6` / `out 0x43` programs 8253 channel 2 for a square wave. The divisor goes out to `0x42`, low byte then high. `retf 2`. |
| `02f4` | `NoSound` | `in 0x61` / `and al,0xfc` / `out 0x61`, no parameters. |
| `0156` | `ReadKey` | `mov ah,0` + `int 16h`. At `015c` the Ctrl-Break path writes `^` then `C` to the console and issues `int 23h`. |
| `0609` | the `int 10h` thunk | Preserves `si`, `di`, `bp`, `es` around the interrupt. |

A byte scan for opcodes over code over-reports, and two hits in this segment are artefacts: `int 3ah` at `0x01ab` is really the `3A 2E` of `cmp ch,[0x5191]`, and `in cdh` at `0x031a` is the `CD` of the `int 16h` at `0x031b`. The disassembly is what settles each routine; the scan only says where to look.

### The comparison that suggested it first, which is not the evidence

`verdiff.py` against the sibling consumer's Crt reports 1422 of 1568 bytes aligning, every difference one constant DGROUP shift of `+0x163e` across 73 words, plus three relocated segment bytes — `a6` against `f5` for System, `47` against `eb` for the data group — and concludes the unit's source is unchanged.

That comparison is what first produced the name. It was only possible because another target on this machine happens to link the same unit, **which is luck and not method**: a target with no sibling gets no such answer. The routines above are what any target can still read, and they are what the name now rests on. The comparison stands as corroboration and nothing more.

Either way it removes 1568 bytes — 15% of the load image — from what this reconstruction has to write.

