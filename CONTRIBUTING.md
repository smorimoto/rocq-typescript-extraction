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

`--with-test` adds Rocq Stdlib, `ppx_expect`, and cppo. `--with-dev-setup` adds ocamlformat, ocaml-lsp-server, and ocaml-index. The submodules supply the pinned Fiat Crypto and CompCert sources used by integration tests and benchmarks. Builds do not fetch dependencies after this setup.

## Tests

`opam exec -- dune test` runs OCaml expect tests and Cram transcripts, checks extraction against golden files, typechecks the generated TypeScript and its consumers, checks lint and formatting, runs the remaining Bun tests, and checks that the generated documentation matches the committed pages.

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

Edit `docs/getting-started.cpp.md` and `docs/encoding.cpp.md` for documentation prose, and the files they `#include` for code examples. `test/docs/dune` runs `cppo -n` to embed the tested source or freshly extracted TypeScript and compares the generated pages with their committed `.md` files. Run `opam exec -- dune build @test/docs/runtest`, review the diff, then run `opam exec -- dune promote docs/getting-started.md docs/encoding.md` and rerun the check. Commit the templates and generated pages together. The `.md` files remain directly readable on GitHub and Docs7; normal test runs do not update them.

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

## Releases

[Changesets](https://github.com/changesets/changesets) collects the changes for each release, and [opam-publish](https://github.com/ocaml-opam/opam-publish) submits the release to the `released` repository of the [Rocq opam archive](https://github.com/rocq-prover/opam). The release version is the `version` field in `package.json`. opam-publish takes the opam version from the release tag, so `dune-project` and the opam file carry no version.

Follow the [Changesets guide](https://github.com/changesets/changesets/blob/main/docs/intro-to-using-changesets.md).

On each push to `main`, the [Release workflow](.github/workflows/release.yml) gathers the changesets into a pull request titled `chore(release): version packages`. That pull request removes the changeset files, bumps `version` in `package.json`, and writes `CHANGELOG.md`. Do not edit the release version or changelog by hand. The pull request comes from `github-actions`, so GitHub holds its CI runs until you select **Approve workflows to run** on the pull request.

To release, merge that pull request. The workflow then tags `vX.Y.Z`, creates the GitHub release, and runs opam-publish, which opens a pull request on `rocq-prover/opam` that adds `released/packages/rocq-typescript-extraction/rocq-typescript-extraction.X.Y.Z/opam`. After the maintainers of that repository merge the pull request, users can install the release with opam from the `released` repository, which they add with `opam repo add rocq-released https://rocq-prover.org/opam/released`.

The workflow needs two things, which you set once. In the repository settings under **Actions**, then **General**, allow GitHub Actions to create and approve pull requests, so that the workflow can open the version pull request. Then add the repository secret `OPAM_PUBLISH_GH_TOKEN`, a classic personal access token with the `public_repo` and `workflow` scopes. opam-publish uses the token to push to the token owner's fork of `rocq-prover/opam`, whatever its name, creating the fork when the owner has none, and to open the pull request on `rocq-prover/opam`. The default `GITHUB_TOKEN` cannot write outside this repository.

If the job that submits to `rocq-prover/opam` fails after the tag exists, select **Re-run failed jobs** on the workflow run. The rerun keeps the tag and runs only that job. opam-publish then opens the pull request, or updates the one that is already open.

## Third-party dependencies

Stdlib, Fiat Crypto, and CompCert are test and benchmark dependencies. Their upstream sources and proofs remain unmodified, and generated programs stay in `_build`; they are not installed with the plugin.

The project's ISC license does not replace their licenses. Retain applicable notices and redistribution terms when distributing extracted programs. See the [Fiat Crypto](bench/fiat-crypto/README.md#licensing) and [CompCert](test/compcert/README.md#licensing) licensing notes; Rocq Stdlib is LGPL-2.1-only.
