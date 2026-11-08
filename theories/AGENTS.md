# Theories Guide

`theories/` is the Rocq theory `TypeScriptExtraction`, installed with the plugin. It holds the `Number` and `BigInt` presets and the `ExtrTs*` files they compose. User-facing tables are in `docs/extraction.md`.

## Layout

- `Number.v` and `BigInt.v` are one `Require Export` each, with a header comment that states the whole mapping table. `Number` is the default. `BigInt` differs only in `ExtrTsNatBigInt` and `ExtrTsBinNumsBigInt`.
- `ExtrTsBasic.v` loads the plugin (`Declare ML Module` for the loader, then the backend) and maps `bool`, `sumbool`, `unit`, `prod`, and `comparison`. The other files require it, except `ExtrTsPArray.v`, which loads the plugin itself.
- `ExtrTsInt63`, `ExtrTsFloat`, `ExtrTsPString`, and `ExtrTsPArray` realise the primitive types with the semantics of the kernel's own implementations (`Uint63`, `Float64`, `Pstring`, `Parray` in rocq-runtime). They apply under both presets.
- Each `*BigInt.v` requires its `*Number.v` counterpart and replaces every directive, so `bigint` wins whatever the `Require` order. When adding a directive for a standard integer operation, add it to both files.

## Writing directives

- Directive text is TypeScript, printed as written. An `Extract Constant` implementation is a parenthesised, uncurried arrow with every parameter and the result annotated: `"((n: number, m: number): number => (n > m ? n - m : 0))"`. Generic ones declare their type parameters first: `"(<A, B>(p: readonly [A, B]): A => p[0])"`.
- The text must already pass the gates applied to generated files: strict `tsc`, Ultracite's lint, `oxfmt --check`, and `test/no_assertions.sh`. No `as`, no `!`, no `any`, `===` only. Oxfmt will not reflow it, so keep it within 80 columns where possible, as the multi-line `PrimString.make` shows.
- `Extract Inductive t => "type" [ ctors ] "match"`: `$1`, `$2` in `type` are the type arguments; the optional match function takes one branch per constructor, uncurried, then the value. Pair it with `TypeScript Extract Match t => [ "test" "arg" ... ]` so matches lower inline. `$0` is the scrutinee, the last constructor's test is ignored, and a single constructor is written `[ _ ... ]`.
- A union of string literals is written with doubled quotes inside the Rocq string: `"""Eq"" | ""Lt"" | ""Gt"""`.
- Keep a type's representation, constructors, match selectors, and operations consistent with each other and with the Rocq definitions: `Nat.sub` stops at zero, division by zero gives `0` and the remainder gives the dividend, `Z.div` rounds down, and no operation returns `-0`. The header comment of each file lists these cases; update it with the directive.
- A realiser is trusted, not proved. State the input domain a caller must respect (`nat` nonnegative, `positive` strictly positive) in the header, and say that it is not checked.
- Directives persist in `.vo` files and apply to the whole loaded environment, including the OCaml backend's tables. Nothing here may be required from a shared proof library.

## Testing

- Preset behaviour is pinned by extraction fixtures under `test/` (`BigIntPreset.v`, `Primitives.v`, `PrimitiveTypes.v`, `bin-nums/`, `stdlib-bin-nums/`, `separate-primitives/`) and by `bench/`. A changed directive changes goldens; regenerate with `opam exec -- dune build @test/runtest` and review the diff before promoting.
- Update the preset and theory tables in `docs/extraction.md` in the same change.
