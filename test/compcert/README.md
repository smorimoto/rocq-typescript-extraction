# CompCert extraction tests

These tests extract the unchanged LGPL portions of CompCert at [`e26caf9fa6cd91665c9e8ee2b5194f413c796821`](https://github.com/AbsInt/CompCert/tree/e26caf9fa6cd91665c9e8ee2b5194f413c796821). They use the BigInt preset's exact bigint arithmetic and fixed x86-64 architecture parameters, independently of the host CPU.

## Coverage

| Component | Checks |
| --- | --- |
| `Ctyping.typecheck_program` | Reconstructed type annotations, multiple functions, calls, structure fields, switch cases, and errors with function and identifier context |
| `Ctyping` recursion | Expressions and statement sequences of depth 20,000; calls nested through argument lists to depth 20,000 |
| `Ctypes` | Structure and union layout, pointer alignment, nested arrays, duplicate definitions, and incomplete types |
| `Memory.Mem` | Integer wrapping, signed and unsigned loads, byte order and copying, bounds, alignment, partial frees, and permission changes |
| Persistent memory | Old states retain their contents and permissions; 128 partial frees retain distinct captured bounds |
| `Globalenvs.Genv` | Forward symbol references, pointer fragments, zero initialization, read-only data, and unresolved symbols |

`../compcert-theories/Programs.v` contains thin wrappers and shared observation cases. Its 18 observation cases run through both this backend and Rocq's standard OCaml extraction; `reference.t` compares their output. The handwritten TypeScript tests also assert independently specified ASTs, errors, layouts, and memory results. Neither backend's output is committed as a golden file.

`Errors.bind` and `Errors.bind2` are inlined, as in CompCert's own extraction configuration. This exposes recursive calls to the backend's loop conversion. The large mutually recursive expression/argument-list group also converts to a stack machine. Both its nested-call test and the other deep tests exercise converted loops. See the [encoding limitations](../../docs/encoding.md#limitations).

## Build and run

After the [development setup](../../CONTRIBUTING.md#development-setup), run from the repository root:

```sh
opam exec -- dune build @test/runtime @test/compcert/runtest
bun test _build/default/test/compcert
```

The full `opam exec -- dune test` also includes this suite, strict TypeScript checking, the no-assertions check, formatting, and lint. The three generated CompCert files use [generated.oxlint.ts](generated.oxlint.ts) to allow redundant boolean branches, identity assignments in continuation loops, and the `Ascii` constructor tag.

## Updating CompCert

After changing the pinned revision, review its licenses and regenerate the selected dependency manifest from the repository root:

```sh
opam exec -- bun test/compcert/gen-dune.ts > submodules/compcert.dune
opam exec -- dune test
```

The generator follows `Require` dependencies from `Ctyping`, `Memory`, and `Globalenvs`, checking each file against the allowed LGPL subset and its license header. Unknown dependencies or files outside that subset fail generation. The test suite checks the manifest against the selected sources.

Dune copies the selected sources into its build directory and compiles them and the bundled Flocq dependencies with their proofs. Builds do not download dependencies.

## Licensing

The complete CompCert repository has mixed licenses. This suite selects the LGPL-2.1-or-later option for its dual-licensed files: the selected `lib/` and `common/` files, `Ctypes.v`, `Cop.v`, `Csyntax.v`, `Csem.v`, `Ctyping.v`, `x86_64/Archi.v`, and `x86/Builtins1.v`. The bundled Flocq files are LGPL-3.0-or-later; the separately installed Rocq Stdlib is LGPL-2.1-only. Original copyright and license notices remain in the submodule and in source copies. See the pinned [CompCert LICENSE](https://github.com/AbsInt/CompCert/blob/e26caf9fa6cd91665c9e8ee2b5194f413c796821/LICENSE).

The non-commercial-only compiler passes, including `Kildall.v`, are not compiled or extracted. Recursive checkout may fetch CompCert's separate upstream test submodule, but this suite does not use it.

The upstream code, extracted TypeScript and OCaml, and reference executable are test dependencies only and are not installed with the plugin. Generated files stay under `_build`. The project's ISC license does not replace their licenses; separate distribution of extracted programs must retain applicable notices and satisfy the corresponding source and other redistribution requirements.
