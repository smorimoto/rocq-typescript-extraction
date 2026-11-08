# Backend Guide

`src/` is the Dune library `rocq-typescript-extraction.backend` (OCaml name `typescript_extraction_plugin`): the TypeScript backend over the MiniML of `rocq-runtime.plugins.extraction`. `src/loader/` is the separate `rocq-typescript-extraction.plugin` library, whose only job is to load the backend without changing Rocq's backtrace setting; theories declare the loader first, then the backend.

## Pipeline

`g_typescript_extraction.mlg` declares the vernacular commands and nothing else. `Ts_extract` is the driver behind them. For every command it:

1. Selects `Extraction Language OCaml` under `Vernacstate.System.protect`, so the standard plugin produces MiniML and the user's language setting is restored whether the command returns or raises.
2. Replays directives that Rocq drops from closed functors and inherits `Extract Constant` realisers onto `Include`d aliases, inside a frozen summary (`with_directives`).
3. Runs `Extract_env.mono_environment` and `Modutil.optimize_struct`, then `Ts_alias.resolve`, `Ts_known.reduce`, `Ts_sig.create`, and `Ts_env.create`, looping until `Ts_env.missing_dependencies` is empty, since reconstruction can need globals extraction did not pull in.
4. Hands the structure to `Typescript.structure` (one module), `Typescript.files` (separate extraction, one module per Rocq library with `import * as $Dep from "./dep.ts"`), or `Typescript.declaration` (printing one global).

## Ownership

Each `.mli` opens with a comment that says what the module owns and what no other module does. Keep those statements true: when logic moves, move the sentence with it.

| Module | Owns |
| --- | --- |
| `Ts_type` | The type language of the typed core. The only reader of MiniML `ml_type`, through `of_ml`. Unifies as `Mlutil.mgu` does. |
| `Ts_kernel` | The only module that reads the kernel for types, recovering positions extraction wrote as `Tunknown`; dependent enumerations become conditional types. |
| `Ts_env` | Types and representations of every referenced global, including realised ones. A missing entry is an anomaly. |
| `Ts_sig` | Module types and the paths through which their members are reached; abstract types become type parameters of interfaces and functors. |
| `Ts_alias` | `Module M := N` resolution over the MiniML structure. |
| `Ts_known` | Removal of branches for constructors that TypeScript's narrowing already excludes. |
| `Ts_infer` | Type reconstruction over each body. Cannot fail as a whole: a failed unification becomes a `Cast`, printed as `__magic`, counted in `stats.unchecked_casts`, and reported by the `typescript-extraction-unchecked-casts` warning. |
| `Ts_anf` | Normalisation of recursive groups so `Ts_expr` can turn them into stack machines. |
| `Ts_expr` | The single translator from the typed core to `Ts_print` trees: statement and expression split, self-recursion to `for (;;)`, recursive groups to explicit-stack machines. |
| `Ts_repr` | The only place that decides how an inductive is represented and the only code that writes a tag, a field read, a constructor interface, or a laziness wrapper. |
| `Ts_names` | The only module that turns a Rocq name into text: lowerCamelCase values, PascalCase types, kebab-case files, `$`-joined flat names for module members, `shape` to `form` for the anti-slop lint. |
| `Ts_print` | The TypeScript AST subset and its renderer. The only writer of TypeScript text. Output already satisfies `oxfmt --check` and uses only erasable syntax and no type assertion. |
| `Typescript` | Module layout: which declarations are exported, private, or omitted; module objects, functors as curried generic arrows, interfaces. The driver's only entry point for producing text. |
| `Ts_primitives` | Representations of `PrimInt63`, `PrimFloat`, `PrimString`, and `PrimArray` when no preset realises them. |
| `Ts_match` | The `TypeScript Extract Match` directive and its persistence in `.vo` files. |

- `Import` is `include Base` and `include Stdio`. Every module starts with `open Import`, so `Stdlib` functions that Base shadows are written qualified, as `Stdlib.Filename` and `Stdlib.Not_found` are in `ts_extract.ml`.
- `Ts_print` must stay free of Rocq dependencies: `test/printing` and `test/random-programs` copy `ts_print.{ml,mli}` and `import.ml` and build them against `base` and `stdio` alone.
- `src/dune` lists every module under `per_module` for `ppx_jane ppx_js_style -check-doc-comments`; the `.mlg` gets `ppx_jane` only. A new module goes in that list and gets an `.mli` with a header comment.

## Errors and warnings

- A user-facing failure is `CErrors.user_err Pp.(...)`. Name the declaration or module and, where there is one, the supported alternative; `Ts_extract.subject` and `Ts_match` are the models. Messages are pinned by goldens in `test/errors`.
- A broken internal invariant is `CErrors.anomaly (Pp.str "Module.function: the fact that was assumed.")`, phrased as the fact, as in `"Ts_anf.bind: an application has a head."`.
- A warning is `CWarnings.create` under `CWarnings.CoreCategories.extraction` with a `typescript-extraction-` name, so fixtures can turn it into an error with `Set Warnings "+..."`.
- `Ts_type.Lost` and `Ts_expr.Unsupported` are the only exceptions. They are control flow inside the backend and are caught before a command returns. Do not add exceptions for callers to match on; return an `option` or a variant.
