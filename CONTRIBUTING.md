# Contributing

The plugin adds a TypeScript backend to Rocq's standard extraction pipeline. It uses the MiniML intermediate representation, reconstructs TypeScript types, and emits ES modules. User-facing behavior is documented in the [extraction guide](docs/extraction.md) and [TypeScript reference](docs/encoding.md).

## Development setup

Use an opam switch with OCaml 5.1 or later. The opam dependencies are declared in `dune-project`; JavaScript dependencies are pinned by `package.json` and `bun.lock`. `mise.toml` pins Bun, Node, and the shell and workflow linters. The CompCert and Fiat Crypto dependency-manifest generators are TypeScript scripts run directly with Bun.

```sh
mise install
git submodule update --init --recursive --depth 1
opam install . --deps-only --with-test --with-dev-setup
bun install --frozen-lockfile
opam exec -- dune build
opam exec -- dune test
```

`--with-test` adds Rocq Stdlib and `ppx_expect`. `--with-dev-setup` adds ocamlformat, ocaml-lsp-server, and ocaml-index. The submodules supply the pinned Fiat Crypto and CompCert sources used by integration tests and benchmarks. Builds do not fetch dependencies after this setup.

## Tests

`opam exec -- dune test` runs OCaml expect tests and Cram transcripts, checks extraction against golden files, typechecks the generated TypeScript and its consumers, checks lint and formatting, runs the remaining Bun tests, and verifies the marked documentation examples against their source or generated output.

Write OCaml unit and regression tests with [`ppx_expect`](https://github.com/janestreet/ppx_expect) in separate test libraries. Add `(inline_tests)` and `(preprocess (pps ppx_expect ppx_js_style -check-doc-comments))` to the library's Dune stanza. Use named `let%expect_test` scenarios that call the module's exposed API, and place `[%expect]` blocks beside the operations whose output they check. Keep output deterministic and small enough to review. Use `[%expect_exact]` when whitespace is part of the contract, as in the [printer test](test/printing/printing.ml). The [unification tests](test/type-unification/unification.ml) show multiple checkpoints within a scenario.

Test individual formatting and lowering rules through the OCaml backend API. The [printer fixtures](test/printing/printing_cases.ml) supply both the named expect tests and the generated `test/layout-gaps/layout-gaps.ts` module. This library copies `src/import.ml` and `src/ts_print` so printer tests run without loading Rocq. The [tuple fixtures](test/miniml/tuple_cases.ml) supply declaration-level expect tests and the generated `test/miniml/tuples.ts` module. A separate expectation checks that the full module contains exactly those declarations in order, ignoring blank lines. Both generated modules still pass TypeScript, lint, formatting, and runtime checks. Keep the inputs shared so those checks exercise the same cases as the expectations.

Run the focused OCaml tests with:

```sh
opam exec -- dune runtest test/type-unification test/printing test/miniml
```

To add a test, start with an empty `[%expect {| |}]` block, run it, and inspect the output diff. A mismatch fails the test and produces a `.corrected` file. After checking that the output is correct, accept it with `opam exec -- dune promote path/to/test.ml`, then rerun the test. Review expectation changes as code changes; a passing test after promotion does not establish that the new behavior is correct.

Use [Dune Cram tests](https://dune.readthedocs.io/en/stable/reference/cram.html) for command output, diagnostics, and finite extraction examples. A `*.cases.ts` file calls the generated TypeScript and prints observations; its matching `*.t` file owns the expected output. These drivers retain consumer type annotations and generic calls, and the same `tsc` run checks them alongside the Bun tests. [exports.cases.ts](test/exports.cases.ts) and [exports.t](test/exports.t) are a small example. [gen-dune.t](test/gen-dune.t) tests command failures and their exit statuses. [reference.t](test/compcert/reference.t) compares TypeScript output with standard OCaml extraction.

Use `print` from [observe.ts](test/observe.ts) for values. It preserves distinctions such as bigint, `undefined`, sparse arrays, `NaN`, and negative zero. When an example compares two computed values, print both as `{ actual, expected }` so the transcript retains both observations and both typed call sites. Register each transcript's driver and transitive file dependencies in [test/cram.dune](test/cram.dune), or in the local `dune` file for a command test. Cram runs in a sandbox, so undeclared dependencies are unavailable.

Run the output examples with `opam exec -- dune build @test/output-tests`, or one transcript with `opam exec -- dune build @test/exports`. Review a changed transcript and accept it with `opam exec -- dune promote test/exports.t`, then rerun it. Normal test runs do not update expectations.

Keep Bun tests for reference identity, mutation and persistence, exception and callback timing, deep-stack behavior, and property or differential checks over many inputs. Keep all the operations of a stateful scenario together. A callback, a type annotation, or a computed expected value alone does not require a Bun test. The existing JavaScript runtime still executes every migrated extraction example; `ppx_expect` tests exercise the OCaml backend APIs directly.

Jane Street's [Testing with expectations](https://blog.janestreet.com/testing-with-expectations/), [Repeatable exploratory programming](https://blog.janestreet.com/repeatable-exploratory-programming/), and [What if writing tests was a joyful experience?](https://blog.janestreet.com/the-joy-of-expect-tests/) explain expectation-based testing. The standalone OCaml programs in `test/random-programs` and `test/compcert` generate inputs for cross-language checks.

Keep Rocq extraction fixtures for behavior that crosses the Rocq boundary, such as directives, presets, module resolution, and separate extraction. Representative end-to-end fixtures also check how backend rules work together. Create `test/Foo.v` and `test/foo.expected.ts` for these tests. Add `test/foo.cases.ts` and `test/foo.t` for finite output examples, or `test/foo.test.ts` for the Bun scenarios described above. A printer-only regression belongs in the OCaml tests instead of a new Rocq fixture. Put invalid consumer programs in `test/typechecks.ts`, which is typechecked without executing them. Keep runtime checks for intentional failures such as unrealized axioms and absurd branches. Run `opam exec -- dune build @test/runtest` to generate `test/tests.dune` and the golden output, inspect the diffs, and promote the intended files with `opam exec -- dune promote`.

For an intentional change to the remaining Bun inline snapshots, run `opam exec -- bun run test:update`. This updates those snapshots in the build directory and copies changed test sources back to `test/`. Review the diff; normal test runs reject missing or mismatched snapshots.

When changing documentation examples, keep their `<!-- sample: name -->` markers and the corresponding rules in `test/docs/dune` in sync. Run `opam exec -- dune build @test/docs/runtest` to check them.

See the [CompCert suite](test/compcert/README.md) for integration coverage and instructions for updating its source revision.

## Formatting and lint

Follow [AGENTS.md](AGENTS.md) for OCaml style. TypeScript uses the Ultracite presets configured in `oxlint.config.ts` and `oxfmt.config.ts`.

```sh
opam exec -- dune fmt
bun run lint
bun run format
shellcheck test/*.sh
shfmt -d test/*.sh
jactionlint
```

`bun run format` rewrites files; `bun run lint` only checks them. Generated code must pass its lint and formatting checks without a formatting pass after extraction.

## Benchmarks

See the [benchmark guide](bench/README.md) for workloads, measurement boundaries, and commands to run all or selected suites.

## Third-party dependencies

Stdlib, Fiat Crypto, and CompCert are test and benchmark dependencies. Their upstream sources and proofs remain unmodified, and generated programs stay in `_build`; they are not installed with the plugin.

The project's ISC license does not replace their licenses. Retain applicable notices and redistribution terms when distributing extracted programs. See the [Fiat Crypto](bench/fiat-crypto/README.md#licensing) and [CompCert](test/compcert/README.md#licensing) licensing notes; Rocq Stdlib is LGPL-2.1-only.
