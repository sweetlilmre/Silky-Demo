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
| running it | `observe` | R3, part `SILKY`, matches against the original |

The rebuild is the original: header, relocation table, all five segments and the data group.

The last two bytes took the longest and are worth recording. `ClampDown`'s guard is seven bytes where a plain `if Fading = 1 then` compiles to five, and sixteen spellings of that `if`, across three compilers, all produced the five. The mistake was to read that as a difference in the code generator; it was a difference in the source. The original keeps the polarity of its test -- it jumps away on `jne` and reaches its body by a short jump, which a compiler never needs to do and a source asking for both jumps does:

```pascal
  if Fading = 1 then goto Body;
  goto Done;
Body:
  ...
Done:
```

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
    python kit/tools/pascal/ratchet.py status.toml

`build.py` also stages a `run/` directory with the original, the rebuild and the four data files, so the two can be run one after the other and watched.
