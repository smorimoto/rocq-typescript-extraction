# Extraction guide

Start with the [README example](https://github.com/smorimoto/rocq-typescript-extraction#usage) to generate and import a TypeScript module. This guide covers extraction options; the [TypeScript reference](encoding.md) describes the generated API.

## Commands

| Command | Effect |
| --- | --- |
| `TypeScript Extraction qualid.` | Print one definition or a whole module. |
| `TypeScript Recursive Extraction qualid ... .` | Print definitions and their dependencies. |
| `TypeScript Extraction "file.ts" qualid ... .` | Write definitions and their dependencies to one file. |
| `TypeScript Separate Extraction qualid ... .` | Write one file per Rocq library, with imports between them. |

Use `Set Extraction Output Directory "path".` to choose the output directory. Separate extraction uses kebab-case filenames: `ListDef` becomes `list-def.ts`. A filename given explicitly to `TypeScript Extraction` is used as written.

The commands work inside modules as well as at the top level, but not inside module types. A module type cannot itself be an extraction target; its interface is emitted when needed by a functor or sealed module. The commands work regardless of the current `Extraction Language` setting and leave that setting unchanged.

## Presets

Both presets load the plugin and provide mappings for standard types and operations:

| Rocq | `Number` | `BigInt` |
| --- | --- | --- |
| `bool`, `sumbool` | `boolean` | `boolean` |
| `unit` | `undefined` | `undefined` |
| `nat`, `positive`, `N`, `Z` | `number` | `bigint` |
| `prod A B` | `readonly [A, B]` | `readonly [A, B]` |
| `comparison` | `"Eq" \| "Lt" \| "Gt"` | `"Eq" \| "Lt" \| "Gt"` |
| primitive `int` | `bigint` | `bigint` |
| primitive `float` | `number` | `number` |
| primitive `string` | `string` | `string` |
| primitive `array A` | `PArray<A>` | `PArray<A>` |

Choose `Number` when standard integer values and intermediate results fit JavaScript's safe integer range, −(2^53 − 1) through 2^53 − 1. Choose `BigInt` when they may exceed it. Functions extracted with `BigInt` accept ordinary bigint literals, such as `add(9007199254740993n, 2n)`.

These presets were previously named `Native` and `Generic`. Replace `Require Import Native` with `Require Import Number`, and `Require Import Generic` with `Require Import BigInt`. Their numeric mappings are unchanged.

Neither preset checks input domains. Supply nonnegative integers for `nat` and `N`, strictly positive integers for `positive`, and integers for `Z`. Primitive integers remain bounded to 63 bits, and primitive floats retain binary64 semantics, even under `BigInt`. The handwritten mappings are trusted code; they are not proved correct.

`option` and `list` remain tagged unions in both presets. User-defined types keep their generated representations. See [data representations](encoding.md#inductive-types).

### Numeric and primitive operations

The mapped operations follow their Rocq definitions, including cases that differ from JavaScript operators:

- `Pos.sub` returns 1 when the difference is not positive; `N.sub` returns 0.
- `Z.div` and `Z.modulo` round down, with the remainder taking the divisor's sign. `Z.quot` and `Z.rem` round toward zero.
- Integer division by zero returns 0; the remainder by zero is the dividend.
- `PrimInt63` arithmetic wraps at 2^63.
- `PrimArray.get` outside the array returns its default. `set` returns a new array, and `make` caps its length at `max_length`.

The presets map Corelib operations and their aliases, including Stdlib's included copies of those operations. Other functions retain their extracted implementations. An explicit mapping on an alias takes precedence over the mapping inherited from its original; `Extraction NoInline` is also respected.

Closed binary integer constructor applications (`positive`, `N`, and `Z`) using the preset mappings can be emitted as literals. BigInt constants remain exact; Number constants are folded only within the safe integer range. This applies only to the exact pure constructor code supplied by the presets.

### Combining mappings

Mappings apply throughout the loaded environment, including through imports. Importing a preset does not reset earlier mappings: loading `BigInt` and `Number` in either order leaves standard integers mapped to `bigint`.

Keep extraction presets out of shared proof libraries. Use separate compilation environments and output directories for incompatible numeric APIs, and convert explicitly when connecting their generated modules.

For a selective configuration, import individual theories from `TypeScriptExtraction`:

| Theory | Mappings and dependencies |
| --- | --- |
| `ExtrTsBasic` | `bool`, `sumbool`, `unit`, `prod`, and `comparison` |
| `ExtrTsNatNumber` | `nat` as `number`; includes `ExtrTsBasic` |
| `ExtrTsBinNumsNumber` | `positive`, `N`, and `Z` as `number`; includes `ExtrTsNatNumber` |
| `ExtrTsNatBigInt` | `nat` as `bigint`; includes `ExtrTsBinNumsNumber` |
| `ExtrTsBinNumsBigInt` | `positive`, `N`, and `Z` as `bigint`; includes `ExtrTsBinNumsNumber` |

Import both bigint theories to map all four standard integer types to `bigint`. When overriding a mapping, keep its type, constructors, match selectors, and arithmetic operations consistent.

## Custom extraction directives

`Extract Inductive`, `Extract Constant`, `Extract Inlined Constant`, `Extraction Inline`, `Extraction NoInline`, and `Extraction Implicit` apply as in standard extraction, with TypeScript text in place of OCaml text. These settings are shared with the OCaml backend, so put TypeScript directives in a file imported only by TypeScript extractions.

| Directive | Effect |
| --- | --- |
| `Extract Inlined Constant c => "code".` | Replace each use of `c` with `code`. Suitable for identifiers, dotted paths, literals, and type mappings. |
| `Extract Constant c => "code".` | Declare `code` once when used, with the type of `c`. Function implementations take their arguments uncurried. |
| `Extract Constant t "A" "B" => "code".` | Map a type using `A` and `B` as its parameters. |
| `Extract Inductive t => "type" [ "c1" ... "cn" ].` | Map a type and its constructors. `$1`, `$2`, etc. in `type` stand for type arguments, as in `"readonly [$1, $2]"`; without placeholders, arguments are appended as `type<args>`. |
| `TypeScript Extract Match t => [ "test" "arg" ... ] ... .` | Define a match selector for each constructor; see below. |
| `Extract Inductive t => "type" [ ... ] "match".` | Supply a match function taking one branch function per constructor, followed by the matched value. Constructor arguments are passed uncurried; a constant constructor's branch is a thunk. |

A `TypeScript Extract Match` directive has one bracket group per constructor, in declaration order. Each group contains a test followed by an expression for each constructor argument. `$0` denotes the matched value: `"$0 === 0"` tests for zero, and `"$0 - 1"` reads a predecessor. The last constructor's test is ignored because it is the remaining case; use `_` for a single-constructor type. Without a selector or match function, matching a mapped type works only when all its constructors are constants.

When custom code refers to another Rocq definition, include that definition explicitly in the extraction command. Standard extraction cannot discover dependencies inside TypeScript strings. In separate extraction, generated names used by mappings must resolve unambiguously; rename a conflicting name or extract to a single file if the command reports an ambiguity.

An abstract type normally becomes a branded interface. If a custom operation returns a concrete value for that type, map the type too; for example, `Extract Constant key => "number".` allows implementations returning numbers.

Directives inside functor bodies apply to their applications, and `Include` preserves directives from the included module. However, Rocq drops directives inside sealed modules and functors when they close. Use `<: T` instead of `: T` when you need signature checking without sealing.

Custom implementations should preserve Rocq's pure behavior. Extraction can remove unused computations or change evaluation order, so effects in custom code are not guaranteed to run as written in the Rocq source.
