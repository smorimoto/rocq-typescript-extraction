# MiniML Tests

Expect tests that build MiniML terms the standard extraction never produces, such as `MLtuple` and `Ptuple`, and run them through `Typescript.declaration`. The library links `rocq-typescript-extraction.backend`, so it needs the plugin built but no Rocq theory.

- `tuple_cases.ml` constructs terms with the `Extraction_plugin.Miniml` constructors and exposes `declaration name`. `tuple_tests.ml` checks one declaration per `let%expect_test` with `[%expect_exact]`. `tuples.ml` prints the whole module to `tuples.ts`, which goes through `tsc`, lint, format, and `no_assertions.sh`; a separate expectation checks that the module holds exactly the fixture declarations in order, ignoring blank lines.
- Keep every case in `tuple_cases.ml` so the expect tests and the generated module exercise the same inputs.
- A constructor must be pushed to the extraction name table before it is used, since the backend names it after its entry there. The comment on `sign` in `tuple_cases.ml` shows the pattern.
