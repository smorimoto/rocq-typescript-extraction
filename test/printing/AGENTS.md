# Printer Tests

Expect tests for `Ts_print` that run without loading Rocq. `dune` copies `src/ts_print.{ml,mli}` and `src/import.ml` into the library `printing_cases`, which depends on `base` and `stdio` only.

- `printing_cases.ml` is the fixture module: named lists of `Ts_print` declarations (`function_types`, `array_types`, ...) and `render`. Each list feeds a `let%expect_test` in `printing.ml` and the generated `test/layout-gaps/layout-gaps.ts`, which `tsc`, `oxlint`, `oxfmt`, and `layout-gaps.test.ts` check. Add a case to the fixture, not inline in a test, so both consumers see it.
- Use `[%expect_exact {|...|}]`. Whitespace is the contract, since the rendered text must pass `oxfmt --check` unchanged.
- The loop is an empty `[%expect_exact ""]`, a run, a look at the `.corrected` diff, then `opam exec -- dune promote test/printing/printing.ml`.
- A change to line breaking, precedence, or parenthesisation also moves goldens across `test/`. Regenerate them with `dune build @test/runtest` in the same change, and run `test/random-programs`, which checks 1,500 random programs through the same copied `Ts_print` against `oxfmt`.
