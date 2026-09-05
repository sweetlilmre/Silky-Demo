# SILKY.EXE, rebuilt from the executable

`bin/SILKY.EXE` is a 10,704-byte MS-DOS demo released by Asphyxia in 1993, written for Silky's eighteenth birthday and, by its own `README.1ST`, the first of their productions to use the VGA's chain-4 mode. This repository holds Turbo Pascal 6.0 source that compiles back to it.

## Where it stands

| measurement | instrument | result |
|---|---|---|
| **the whole file** | direct | **10,704 bytes, 0 differ** |
| the program, segment `1000` | `blockcmp` | 4848 of 4848 bytes, 29 of 29 blocks byte-identical |
| the two units | `mapcmp` | `MODEX` 202/202 and `PALETTE` 124/124, both exact |
| the initialised data | `dgimage` | 800 bytes, identical |
| the runtime, `Crt` and `System` | `mapcmp` | exact, and not ours to write |
| whole-binary identity | `artefact` | **R7 holds**, recomputed on every run rather than believed |
| running it | `observe` | R3, part `SILKY`, matches against the original |

The rebuild is the original: header, relocation table, all five segments and the data group. R7 is the top of the fidelity ladder, and it is stored as data so that a later edit which breaks it fails a check instead of going unnoticed.

The last two bytes took the longest and are worth recording, because the delay was a mistake and not a difficulty. `ClampDown` guards its body in seven bytes where a plain `if Fading = 1 then` compiles to five:

```
80 3e 22 03 01   cmp byte ptr [Fading], 1
75 02            jne  +2      -> onto the near jmp
eb 03            jmp  +3      -> over it, into the body
e9 9a 00         jmp  near epilogue
```

Twenty-nine spellings across three compilers failed to produce it, and that was read as a difference in the **code generator** -- a Turbo Pascal patch level nobody holds, which explains everything and can be checked by nobody. It was a difference in the **source**, and the bytes had said so all along. `jne +2` jumps over exactly two bytes; those two bytes are a short jump; so the then-part of that `if` compiled to a two-byte short jump, and in Turbo Pascal only `goto` does that:

```pascal
  if Fading = 1 then goto DoFade;
  Exit;
DoFade:
  ...
```

Reading the displacement first would have excluded twenty-nine of the thirty candidates without compiling any of them. That rule, and the withdrawn conclusion beside it, are now in the toolkit's wiki as [the branch says how big the statement was](kit/wiki/observations/branch-tells-you-the-statement-size/observation.md).

Two spellings of the guard compile identically -- `goto` to a label at the end, or `Exit` -- so no measurement separates them; the author of the demo said which he would have written, and that is recorded as testimony rather than promoted to a measurement. The label's name is ours: a label never reaches the code.

## The two copies of the source

`src/` is the **reconstruction of record**. Every address, operand delta and note on which instrument caught what is in it, in paragraphs tagged `[re]`, because that is what answers "how do we know this byte is right".

`src-clean/` is generated from it by `kit/tools/pascal/clean.py`, which removes those paragraphs. It is the copy to read to understand the *program*. It is not hand-maintained, it is not the record, and it builds an image identical to the annotated one -- which is the only check that catches a stripped comment changing what compiles.

A third tag, `[reading]`, marks a claim resting on a reading of the instructions rather than a measurement. It is deliberately **not** stripped, so the inferences stay visible and countable in the copy a reader sees.

## Layout

    bin/         the original, its four data files, its README.1ST, and BARS.INC
    src/         the reconstruction, annotated
    src-clean/   the same source with the apparatus stripped, generated
    docs/        what was measured and how, one file per area
    blocks/      the block and DGROUP configs the comparators read
    probes/      compiler experiments, each with the config that ran it
    kit/         the toolkit, a submodule -- it never names a target
    status.toml  the register: what is locked, what is planned

`bin/BARS.INC` is the authors' own Turbo Pascal source, which shipped with the demo. It is a build input, not something to reconstruct; `src/BARS.INC` is that file following the executable in the three places where the two disagree, each one marked.

## Building it

The build needs Turbo Pascal 6.0 and DOSBox-X. Where they live on a given machine goes in `kit.local.toml`, which is not committed; `kit.toml`, `build.toml` and `link.toml` are, and say what the build is rather than where the tools are.

    python kit/tools/pascal/build.py build.toml        # the annotated source
    python kit/tools/pascal/clean.py src src-clean     # regenerate the readable copy
    python kit/tools/pascal/build.py cleanbuild.toml   # and prove it still compiles the same
    python kit/tools/pascal/blockcmp.py blocks/1000.toml
    python kit/tools/pascal/artefact.py status.toml --check   # the R7 row, recomputed
    python kit/tools/pascal/ratchet.py status.toml

`build.py` also stages a `run/` directory with the original, the rebuild and the four data files, so the two can be run one after the other and watched. Since the two are now the same bytes, that comparison has stopped being able to fail -- which is the point of having reached it.

`probes/` holds the compiler experiments as they were run, including the ones that were wrong: `GUARD.PAS` with the sixteen spellings and the conclusion drawn from them, `SWEEP.PAS` sweeping a plain `if` across the short-jump boundary at twenty-four body lengths, `LBL.PAS` asking whether a label prevents the fold, and `BASMG.PAS` with the shapes that finally matched.
