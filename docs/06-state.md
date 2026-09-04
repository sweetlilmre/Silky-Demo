# Where the reconstruction has got to

`bin/SILKY.EXE` is 10,704 bytes. `run/OURS.EXE`, built from `src/` by Turbo Pascal 6.00 under DOSBox-X, is 10,704 bytes. This is what still differs between them and how each number was arrived at.

## The measurement

| instrument | what it says |
|---|---|
| `blockcmp blocks/1000.toml` | **29 of 29 blocks agree**; 4848 of 4848 bytes of segment `1000` transcribed |
| `mapcmp link.toml` | **5 units exact** — SILKY 4848, MODEX 208, PALETTE 128, Crt 1568, System 2576 |
| `units.toml` | MODEX and PALETTE **identical**, but for pending fixups |
| `dgimage link.toml` | the 800-byte initialised data group **identical** |
| `routines.py` | **11 of 11 locked**, 0 holes, 0 failing |
| MZ header | `minalloc` 2317 = 2317, `ss` 1926 = 1926, `ip` equal |
| the whole file | **10,704 bytes, 0 differ** |

Compared straight, byte for byte: **0 differ, over all 10,704 bytes.** Header, relocation table, all five segments and the data group.

## The last two bytes, and how they were found

For a long stretch this section recorded a two-byte shortfall in one routine. `ClampDown` guards its body in seven bytes where every build of ours emitted five:

```
80 3e 22 03 01   cmp byte ptr [Fading], 1
75 02            jne  +2      -> onto the near jmp
eb 03            jmp  +3      -> over it, into the body
e9 9a 00         jmp  near epilogue
```

Sixteen spellings of `if Fading = 1 then` were put through the real compiler and every one inverted the test and fell through into the body — `cmp / je +3 / jmp near`, five bytes, carrying the original's own near displacement. Turbo Pascal 7.01 was tried as well, and inline assembler jumping to a Pascal label, and both did the same. From that this project concluded the difference was in the **code generator**, and hypothesised a TP6 patch level nobody here holds.

**That was wrong, and the author of the demo said so.** The demo was written with Turbo Pascal and inline assembler and nothing more exotic; there was no unusual toolchain. Which meant the difference had to be in the source, and the thing to look at was the one feature no `if` had reproduced: the original keeps the **polarity** of the test. It jumps `jne` away and reaches the body by a short jump, so the false jump and the true jump were emitted as a pair and never folded. A compiler folds them because it owns both sides of the branch. It cannot fold them if the source asked for both:

```pascal
  if Fading = 1 then goto Body;
  goto Done;
Body:
  ...
Done:
```

That emits the seven bytes exactly, near displacement included, and with it the file goes byte-identical.

**The encoding forces it, and that is a better argument than the shape hunt.** `jne +2` jumps over exactly two bytes; those two bytes are `eb 03`, a short jump; so the then-part of the `if` compiled to a two-byte short jump, and in Turbo Pascal the only statement that does is a `goto` to a label a few bytes ahead. The `e9 9a 00` behind it is the next statement, leaving for the end of the routine. Everything else — a compound statement, `Exit`, a `case`, an assignment — is longer or does not begin with `EB`.

Three measurements back it up. `probes/SWEEP.PAS` runs a plain `if` across the short-jump boundary, twenty-four body lengths: below it a short `jne`, above it the folded `je +3 / jmp near`, and never the long form. `probes/LBL.PAS` shows a label at the head of the body does not stop the folding either. And the long form occurs **once** in the whole 10,704-byte image, against nine folded ones — including one six lines further down the same routine, on the `for` loop's own back edge. Whatever it is, it is local to that statement.

Two spellings produce identical bytes — `goto Done` with the label at the routine's end, or a bare `Exit` — because both compile to one near jump to the same epilogue. No measurement can separate them. **The author settled it:** asked which he would have written, he said the `Exit` form, with the label named for what it does. That is testimony rather than measurement, and it is the best evidence there can be for a choice the bytes cannot make; the source is written that way, with the label spelled `DoFade`, and the label's own spelling is tagged `[reading]` because a label name never reaches the code.

**What the error was worth correcting.** A negative result across sixteen constructs and three compilers is strong evidence, and it was read as evidence for the wrong thing: "no source construct does this" was taken to mean the compiler differed, when it meant the constructs were all the same *kind* of construct. Sixteen ways of writing an `if` are one experiment, not sixteen. The distinguishing feature — the polarity — was in the bytes the whole time and named in this document, and it was treated as a curiosity rather than as the thing to reproduce.

## Three things that had to be right before any of this could be measured

**The uses clause runs backwards.** TP6 lays units out in reverse of the order the clause names them — code segments as well as DGROUP. `uses ModeX, Palette, Crt` produced `SILKY, CRT, PALETTE, MODEX`; writing it backwards put every segment start on the original's to the byte. This corrects the kit's own `dgroup-order-reverses-uses`, which said code runs forwards.

**Declaration order is the data layout.** Turbo Pascal allocates globals in the order they are declared, so `SILKY.PAS`'s `var` block *is* DGROUP, and the original's order is readable straight off the addresses in the binary.

**Smart linking makes an unreferenced transcription invisible.** An early `SILKY.PAS` with an empty `begin end.` compiled, linked, and produced an image containing none of its routines and none of `ModeX`. Nothing failed and nothing warned.

## What is not known

* **The 67-record table at DGROUP `0x717`** — and this one is closed as far as it can be. Nothing in the image reads it: a decode of all five segments finds the fold base `0x717` in exactly one instruction, the init loop itself. Its shape survives and its purpose does not, because there is no consumer to read a purpose from. See [02-units.md](02-units.md).
* **1,573 bytes of the palette unit's data**, declared by length alone because the linker fixes the total and nothing evidences the composition.
* **Five declared-and-unused locals** — `Drawit`'s `F`, `RotPal2`'s `loop2`, `ShowFont`'s 255, `Scroll`'s two spare words, `RunScroll`'s one. Each is real: the frame sizes require them.
* **Which of `Dummy`/`Spare` shapes `LoadFont`'s 260 spare bytes.** Only the total is recoverable from a frame size.

Each of these is tagged `[reading]` where it is declared in `src/`, and that tag is deliberately not stripped from `src-clean/`, so the four survive into the copy a reader reads rather than being quietly presented as measurements.

## It has been watched

On 4 Sep 2026 a person ran both binaries from `run/` and reported no difference between them. Recorded as `SILKY part matches R3` against `ORIG.EXE` — the highest rung the ladder grants, and the only one whose instrument is a person looking at a screen.

That is worth stating carefully, because it is a different kind of claim from everything above it. Every other number here is a byte comparison and can be recomputed on demand. This one cannot: it is a dated statement that somebody watched, and its whole value is that no tool invented it. `observe.py` exists to refuse a run nobody made.

The observation is **about this build**. It stores the commit and a fingerprint of the sources the harness depends on, so an edit to `src/` marks it stale rather than false — a gap in knowledge, not a regression.

## So where it stands

The structural strand is **complete**: the rebuild is the original, byte for byte, all 10,704 of them. The behavioural strand is at **R3**: two binaries, watched side by side, no visible difference.

Neither settles the other. A demo can look right and differ in bytes, and byte-identity was never going to prove the screen. Both are now measured.
