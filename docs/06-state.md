# Where the reconstruction has got to

`bin/SILKY.EXE` is 10,704 bytes. `run/OURS.EXE`, built from `src/` by Turbo Pascal 6.00 under DOSBox-X, is 10,704 bytes. This is what still differs between them and how each number was arrived at.

## The measurement

| instrument | what it says |
|---|---|
| `blockcmp blocks/1000.toml` | 28 of 29 blocks agree; **4848 of 4848 bytes** of segment `1000` transcribed |
| `mapcmp link.toml` | **5 units exact** — SILKY 4848, MODEX 208, PALETTE 128, Crt 1568, System 2576 |
| `units.toml` | MODEX and PALETTE **identical**, but for pending fixups |
| `dgimage link.toml` | the 800-byte initialised data group **identical** |
| `routines.py` | **11 of 11 locked**, 0 holes, 0 failing |
| MZ header | `minalloc` 2317 = 2317, `ss` 1926 = 1926 |

Compared straight, byte for byte:

```
SILKY 0x0000..0x0a0e                                   0 differ
everything from 0x12f0 on                              0 differ
   — MODEX, PALETTE, Crt, System, and the data group
SILKY 0x0a15..0x12f0, ours shifted by two             12 differ
header, outside the relocation table                   1 differs — 0x14, which is ip
```

## Everything that differs traces to two bytes

`ClampDown` at `1000:09fb` guards its body in seven bytes where our build emits five:

```
80 3e 22 03 01   cmp byte ptr [Fading], 1
75 02            jne  +2      -> onto the near jmp
eb 03            jmp  +3      -> over it, into the body
e9 9a 00         jmp  near epilogue
```

Its **body** is right — 156 bytes with nothing unexplained, and the near displacement `9a 00` is the original's, so the length is right as well as the content. The two-byte shortfall then accounts for the rest: the twelve later bytes are three `mov di,imm16` loading the CS-relative addresses of the `gold.Fnt`, `Check2.Cel` and `Asphyx.Cel` literals, and nine `e8` near-call displacements that cross the boundary. `ip` moves with it. So does every relocation-table entry above it.

**Sixteen source constructs have been put through the real compiler and none emits those seven bytes.** `probes/GUARD.PAS` lists them. The mechanism is understood: with a body under 127 bytes `if Flag = 1 then` emits a single short `jne` — the original's polarity — and at ClampDown's real 156 bytes the identical construct emits the compact five. `{$B+}` changes nothing, and TP600 and TP601 are byte-identical to each other across the whole run.

The surviving hypothesis is therefore **the compiler, not the source**: a TP6 patch level that is neither of the two installed here. Anyone holding another TP6 can settle it in one build.

## Three things that had to be right before any of this could be measured

**The uses clause runs backwards.** TP6 lays units out in reverse of the order the clause names them — code segments as well as DGROUP. `uses ModeX, Palette, Crt` produced `SILKY, CRT, PALETTE, MODEX`; writing it backwards put every segment start on the original's to the byte. This corrects the kit's own `dgroup-order-reverses-uses`, which said code runs forwards.

**Declaration order is the data layout.** Turbo Pascal allocates globals in the order they are declared, so `SILKY.PAS`'s `var` block *is* DGROUP, and the original's order is readable straight off the addresses in the binary.

**Smart linking makes an unreferenced transcription invisible.** An early `SILKY.PAS` with an empty `begin end.` compiled, linked, and produced an image containing none of its routines and none of `ModeX`. Nothing failed and nothing warned.

## What is not known

* **The 67-record table at DGROUP `0x717`** — and this one is closed as far as it can be. Nothing in the image reads it: a decode of all five segments finds the fold base `0x717` in exactly one instruction, the init loop itself. Its shape survives and its purpose does not, because there is no consumer to read a purpose from. See [02-units.md](02-units.md).
* **1,573 bytes of the palette unit's data**, declared by length alone because the linker fixes the total and nothing evidences the composition.
* **Five declared-and-unused locals** — `Drawit`'s `F`, `RotPal2`'s `loop2`, `ShowFont`'s 255, `Scroll`'s two spare words, `RunScroll`'s one. Each is real: the frame sizes require them.
* **Which of `Dummy`/`Spare` shapes `LoadFont`'s 260 spare bytes.** Only the total is recoverable from a frame size.

## It has been watched

On 4 Sep 2026 a person ran both binaries from `run/` and reported no difference between them. Recorded as `SILKY part matches R3` against `ORIG.EXE` — the highest rung the ladder grants, and the only one whose instrument is a person looking at a screen.

That is worth stating carefully, because it is a different kind of claim from everything above it. Every other number here is a byte comparison and can be recomputed on demand. This one cannot: it is a dated statement that somebody watched, and its whole value is that no tool invented it. `observe.py` exists to refuse a run nobody made.

The observation is **about this build**. It stores the commit and a fingerprint of the sources the harness depends on, so an edit to `src/` marks it stale rather than false — a gap in knowledge, not a regression.

## So where it stands

The structural strand is one compiler construct short of byte-identity. The behavioural strand is at **R3**: two binaries, watched side by side, no visible difference.

Neither settles the other. A demo can look right and differ in bytes, and byte-identity was never going to prove the screen. Both are now measured.
