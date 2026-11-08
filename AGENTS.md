# Rocq TypeScript Extraction

A Rocq plugin that extracts Rocq definitions to TypeScript ES modules, built as a new backend over the MiniML intermediate language of Rocq's standard extraction plugin. The OCaml backend is in `src/`, the Rocq presets in `theories/`, tests in `test/`, benchmarks in `bench/`, and user documentation in `docs/`. Each of those directories has its own `AGENTS.md` with the conventions that apply there; read it before changing files under it.

## Commands

Run OCaml, Dune, and Rocq commands through `opam exec --` in the repository's opam switch (`.envrc` uses `layout opam`). Bun scripts are in `package.json`; tool versions are pinned in `mise.toml`.

```sh
mise install
git submodule update --init --recursive --depth 1
opam install . --deps-only --with-test --with-dev-setup
bun install --frozen-lockfile

opam exec -- dune build      # plugin and theories
opam exec -- dune test       # everything CI runs
opam exec -- dune promote    # accept reviewed .corrected files and golden diffs

opam exec -- dune fmt        # OCaml
bun run format               # TypeScript and Markdown (rewrites)
bun run lint                 # TypeScript and Markdown (checks only)
shellcheck test/*.sh && shfmt -d test/*.sh
jactionlint

opam exec -- bun run bench   # all suites; pass suite names to select
```

`dune test` runs the OCaml expect tests, extraction goldens, Cram transcripts, one `tsc` over every generated and handwritten `.ts` file, lint and format checks on generated code, the Bun tests, and the documentation samples. Focused commands are in `test/AGENTS.md`.

## Rules

- A normal test run never updates an expectation. Review every promotion as a code change; a passing test after promotion does not show the new output is right.
- Generated TypeScript is checked, not only diffed: strict `tsc`, `oxlint --deny-warnings` with Ultracite's core and anti-slop presets, `oxfmt --check`, `test/no_assertions.sh`, and `test/no_unknown.sh`. When output trips a gate, fix the printer or the rule list in `oxlint.config.ts`; never post-process output after extraction.
- These files are generated and diffed by the tests; regenerate them instead of editing: `rocq-typescript-extraction.opam` (from `dune-project`), `test/tests.dune` (from `test/gen_dune.sh`), `submodules/*.dune` (from the two `gen-dune.ts` scripts), and Bun snapshots in `test/*.test.ts` (from `bun run test:update`).
- `Extract` directives share Rocq's tables with the OCaml backend. TypeScript directive text belongs only in files required where TypeScript is extracted (`theories/`, test and benchmark preludes), never in a shared proof library.
- Upstream sources under `submodules/` and Rocq Stdlib are never modified. Generated programs from them stay under `_build`.
- The default branch is `main`. Recent commits use `type(scope): summary` subjects, as in `test(loading): cover the default backtrace state when the plugin loads`.

## OCaml style

Jane Street's house style, enforced by `.ocamlformat` (`profile=janestreet`, `parse-docstrings=true`) and `ppx_js_style -check-doc-comments` on every library. It applies to `src/` and to the OCaml test libraries under `test/` alike.

### Formatting and naming

- `ocamlformat` decides layout; never hand-format. Lines are at most 90 characters.
- Identifiers use `snake_case`, including module names (`Ts_print`, `Ts_modpath_key`), never CamelCase. Directories use dashes (`type-unification`, `separate-modules`).
- Short-lived binders are short (`r`, `mp`, `ty`); long-lived ones are descriptive. Boolean functions are predicates (`is_modfile`, `asked_value`), not `check_*`.
- `unsafe` means memory-unsafe only. Use `unchecked` for an operation that may misbehave on bad input, as in `unchecked_casts`.
- Most modules define a single type `t` and take it as the first argument. Optional arguments go before it only when it is the sole positional argument.

### Interfaces and comments

- Document for users of the module, in the `.mli`, above the item. Write `[f x y] is ...` with `[]` around OCaml values, `{[ ]}` around blocks, and `{!Module.item}` for cross-references. A comment that only restates the type is a last resort.
- A comment in an `.ml` explains a constraint that the code cannot show: why Rocq drops a directive, why a copy is needed. It does not narrate what the code does.
- Prefer a signature include over a hand-written interface. `Ts_modpath_key` is `include Base.Hashtbl.Key.S with type t = Names.ModPath.t`.

### Opening modules and let-syntax

- Open only modules with a standard interface, at the top of the file, before any definition: `open Import`, then `open Names`, `open Extraction_plugin`, `open Miniml` as needed. Alias the rest, as `module P = Ts_print`.
- Keep a local open small and delimited: `Pp.(str "..." ++ int n)` over `let open Pp in`, unless the opened API is standard and widely understood.
- Use `let%bind` and `let%map` when binding a variable in a monad; infix operators only point-free.

### Defensive programming

- Annotate an ignored value: `ignore (f x : Pid.t)`. The same goes for `_` bindings unless the type is pinned by context.
- Label arguments of the same type that play different roles (`~key ~data`, `~source ~dest`).
- No catch-all `_ ->` over a variant you own or over Rocq's `Libobject.t`: list every constructor so a new one is a compile error. `replay_functor_directives` in `ts_extract.ml` is the model.
- Optional arguments only on functions called from many places, and not on functions absent from the `.mli`.
- Prefer returning an `option` or a variant to raising. A function that routinely raises ends in `_exn`. Never write code that depends on which exception was raised.

### Tests

- Every behavioural change has a test. Tests live in a separate library under `test/` against the exposed API, never in `src/`.
- `let%expect_test` is the default, with `[%expect_exact]` where whitespace is the contract. Quickcheck and property tests also go under `let%expect_test`.
- A printer or lowering regression belongs in `test/printing` or `test/miniml`; a new Rocq fixture is for behaviour that crosses the Rocq boundary.
