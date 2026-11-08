# Test Guide

`test/` holds every check that `opam exec -- dune test` runs. Root fixtures are driven by the generated `tests.dune` and the handwritten `cram.dune`; each subdirectory owns its `dune`. `../CONTRIBUTING.md` explains the rationale for each kind of test; this file covers how to add one.

## Commands

```sh
opam exec -- dune runtest test/type-unification test/printing test/miniml   # OCaml expect tests, no Rocq
opam exec -- dune build @test/runtest          # regenerate tests.dune and every golden
opam exec -- dune build @test/output-tests     # every root Cram transcript
opam exec -- dune build @test/exports          # one transcript, by stem
opam exec -- dune promote test/exports.t       # accept a reviewed transcript
opam exec -- dune build @test/runtime          # stage extracted modules for Bun
bun test _build/default/test/compcert          # one Bun directory, from the build tree
opam exec -- bun run test:update               # update Bun inline snapshots and copy sources back
```

Cram runs in a sandbox: every file a transcript reads must be listed in `cram.dune` for a root transcript, or in the local `dune` for a directory.

## Choosing the kind of test

| Behaviour | Where |
| --- | --- |
| A formatting or lowering rule of the printer | `printing/` expect test |
| A MiniML form the standard extraction never produces | `miniml/` expect test |
| Unification in the typed core | `type-unification/unification.ml` |
| Anything that crosses the Rocq boundary: directives, presets, modules, functors, separate extraction, naming | A root `.v` fixture with its golden |
| Finite observable output of a fixture | `foo.cases.ts` with `foo.t` |
| Reference identity, mutation and persistence, exception or callback timing, deep stacks, property checks over many inputs | `foo.test.ts` |
| A consumer program that must fail to typecheck | `typechecks.ts`, with `@ts-expect-error` on the line |
| A command that must fail, and its message | `errors/` |
| An intentional runtime failure, such as an unrealised axiom or an absurd branch | A `.test.ts` asserting the throw |

A callback, a type annotation, or a computed expected value alone does not need a Bun test; a Cram driver keeps those too.

## Root fixtures

- `Foo.v` extracts to `foo.ts` (kebab-case, as `Ts_names` writes file names) and is diffed against `foo.expected.ts`. `gen_dune.sh` writes the stanzas, and `tests.dune` is diffed against its output, so after adding a fixture run `dune build @test/runtest` and promote `tests.dune` with the golden. A fixture with `From Stdlib Require` gets the `Stdlib` theory added automatically.
- Open a fixture with `From TypeScriptExtraction Require Import Number.` or `BigInt`, then `Set Warnings "+typescript-extraction-unchecked-casts".` so an unchecked cast fails the build. A fixture that must run without a preset instead opens with `From Corelib Require Export extraction.Extraction.` and the two `Declare ML Module` lines, as `Absurd.v` does.
- Say in a comment what the fixture asks for, what stays private, and why. Goldens are reviewed as code.
- `foo.cases.ts` imports the generated module and prints with `print` from `observe.ts`, which keeps bigint, `undefined`, sparse arrays, `NaN`, and `-0` distinct. Precede each group of observations with a `console.log` line that names what is shown. When comparing two computed values, print `{ actual, expected }` so both call sites stay typed.
- `foo.test.ts` runs from `_build/default` with `CI=true`, so a missing snapshot fails. Keep every step of a stateful scenario in one test.
- `no_unknown.expected` pins how many times `unknown` occurs in each golden. The count may only fall; promote the pin with the golden that lowers it.
- `test/dune` lists the directories that one `tsc` run covers. A new subdirectory with `.ts` files goes in that `glob_files` list.

## Subdirectories

- A scenario that needs its own stanzas gets a directory: separate extraction (`separate-*`), printing to standard output (`single/`), language restoration (`language/`), plugin loading (`loading/`), negative tests (`errors/`), integration (`compcert/`, `stdlib-bin-nums/`, `bin-nums/`), and documentation samples (`docs/`). Copy the `no_assertions.sh`, `oxlint`, and `oxfmt` rules from `separate/dune`.
- `*-libs/`, `shapes/`, `tuples/`, `ranges/`, `containers/`, `figures/`, `mentions/`, and `bin-nums-ops/` hold only a `rocq.theory`. A `rocq.extraction` claims every directory under its own, and a theory and an extraction cannot share a directory, so a library that a fixture imports lives beside the fixture. The `dune` comment names the fixture that uses it.
- `printing/`, `miniml/`, `errors/`, `compcert/`, and `docs/` have their own `AGENTS.md`.
