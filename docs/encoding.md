# TypeScript reference

This page describes the API of generated modules. Examples use the `Number` preset. For commands and configuration, see the [extraction guide](extraction.md).

## Output format

Each generated file is an ES module. It exports the requested definitions, the types in their public signatures, and constructors for those types. Dependencies used only within the file stay private. Separate extraction also exports names referenced by other generated files.

Requesting a module exports its members through a module object. Requesting individual members exports the object with those members and any others needed by the generated code. Proofs are erased.

The output uses erasable TypeScript syntax and can run under Bun or Node with type stripping. It is checked with `--strict --isolatedModules --verbatimModuleSyntax --erasableSyntaxOnly`. It uses no `namespace`, `enum`, `declare`, or type assertions other than `as const`. Some extractions still need unchecked conversions; see [limitations](#limitations).

## Types

| Rocq | TypeScript |
| --- | --- |
| Type application `t A B` | `T<A, B>` |
| Function value `A -> B` | `(_: A) => B`; higher-order function values are curried |
| Type alias | `type T<A> = ...` |
| Polymorphic function argument `forall A, A -> A` | `<A>(_: A) => A` |
| Unconstrained type argument | `never` |
| Erased proof or type argument that remains in a value or type position | `undefined` |
| Abstract or opaque type | A branded interface; parameterized abstract types also distinguish their type arguments |
| Primitive `int`, `float`, `string`, `array A` | `bigint`, `number`, `string`, `PArray<A>` under either preset |

See [presets](extraction.md#presets) for standard integer and container mappings. `PArray<A>` has the form `{ readonly default: A; readonly items: readonly A[] }`. Primitive strings contain one UTF-16 code unit per Rocq byte.

The BigInt preset uses native bigint bitwise operators without truncating values to 32 bits. Signed right shifts round toward negative infinity, and a negative shift amount reverses the direction. Primitive 63-bit integers retain their wrapping and out-of-range shift rules under either preset.

### Dependent types

A type depending on a finite enumeration can become a conditional type. For example, a boolean-indexed payload can be represented as `type Payload<B extends boolean> = B extends true ? number : boolean`. A function `<B extends boolean>(b: B): Payload<B>` returns `number` for `true` and a union for a boolean known only at runtime.

This applies to enumerations without parameters or indices, with at least two constructors taking no arguments. With a custom mapping, the constructors must be literals and the type must be `boolean` or their union. Dependencies on other values, such as `nat`, become unions and accept more values than the Rocq type does.

Constructor fields can depend on an earlier enumeration field. The generated union retains that relationship, so testing the earlier field narrows the later one. A record field of sort `Type` instead becomes a type parameter, such as `Monoid<Carrier>`. Heterogeneous collections of these records and some functions returning them cannot be extracted; see [limitations](#limitations).

## Inductive types

Ordinary inductive types become discriminated unions with a `tag` property. For example, the [README tree](https://github.com/smorimoto/rocq-typescript-extraction#usage) becomes `Tree<A> = Leaf | Node<A>`. Use `t.tag` to narrow it, `leaf` for the constant constructor, and `node(left, value, right)` to construct a node.

Constructor interfaces remain available when a consumer needs a narrower type. A constant constructor has its own interface type, so `leaf` can be used in any `Tree<A>`. Other constructors return the union, using `never` for type parameters not mentioned by their arguments. A single-constructor type returns its interface.

Constructor fields use the Rocq binder names when they are all named, distinct, and retained by extraction. Otherwise they are `arg0`, `arg1`, and so on.

Records become interfaces with `readonly` properties. For example, a record with two natural-number fields and a function swapping them produces:

<!-- sample: point.ts -->

```ts
export interface Point {
  readonly px: number;
  readonly py: number;
}

export const swap = (p: Point): Point => ({ px: p.py, py: p.px });
```

Extraction may erase an inductive wrapper with only one computational field, leaving the field's type. Purely logical inductives produce no runtime data. Custom mappings replace the normal representation entirely.

Coinductive values are lazy: a stream has a type like `() => StreamCell<A>`. Calling the thunk exposes the next cell; corecursive cells are memoized.

### Unary comparisons

Some structural comparisons on unary inductives use cached immutable prefixes. Their generated constructors may freeze values and share previously constructed objects. The tagged representation is unchanged. Treat generated data as immutable and use structural equality rather than allocation identity.

This optimization applies to monomorphic types with a zero-like constructor and a successor-like constructor, when a recognized comparison is extracted. It is disabled for batches that also contain recursive operations accepting and returning the type, such as addition. Mutable inputs use the structural comparison when they cannot be safely cached.

## Terms

Named functions normally take their leading arguments together: a Rocq function of two arguments becomes `f(a, b)`. Function values and lambdas are curried. Partial applications are adapted automatically in generated code; TypeScript callers should follow the exported signature.

A definition written as `fun n => let t := ... in fun m => ...` becomes `f(n)(m)`, preserving the computation between applications. A generic value that is not a function may become a nullary generic function, such as `empty<number>()`. A function whose only parameters are proofs also remains nullary, so its body runs when called.

Recursive functions, including many mutually recursive functions, become loops with explicit stacks. These support deep inputs without growing the JavaScript call stack, subject to the exceptions under [limitations](#limitations).

When a continuation only increments a bigint or adds an already computed bigint, an exact accumulator can replace its saved frames and return loop. Callback evaluation order is preserved. Number addition keeps its original grouping because rounding can make reassociation change the result.

An unrealized axiom throws `AXIOM TO BE REALIZED (name)`. A function-typed axiom throws when called; other axioms throw when the module loads. Supply a [custom mapping](extraction.md#custom-extraction-directives) when the extracted program needs an implementation.

## Modules

| Rocq | TypeScript API |
| --- | --- |
| Module `M` | An object, accessed as `M.member` |
| Type `Geometry.Circle` | A top-level type named `GeometryCircle` |
| Module alias `Module M := N.` | An alias of the same object, with aliases for its types |
| Module type `S` | An interface parameterized by its abstract types, such as `S<T>` |
| Functor `F (X : S)` | A generic function taking a module object; multiple module arguments are curried |
| Application `Module B := F A.` | A call such as `F<number>(A)`, with aliases for result types |
| `with Definition t := nat` | Fixes the corresponding type parameter to `number` under `Number` |
| Sealed module or functor | Exposes the members listed by its signature |

Nested modules are object properties, while their types remain top-level names. Functor signatures and functor-valued parameters become generic function types.

Abstract types with parameters use the generated `TypeLambda` and `Kind` helpers (`Kind2` for two parameters, and so on). To supply such a type from TypeScript, define an interface extending the exported `TypeLambda`, with a `type` member using `this["Target"]` for its argument. Functor results whose abstract types depend on their inputs use the same encoding.

Separate extraction writes one file per library that retains declarations. Imports use relative `.ts` paths; dependencies used only as types use `import type`. Libraries mapped away entirely need no file or import.

## Names

Values, parameters, and constructor functions use lowerCamelCase; types and module objects use PascalCase. For example, `safe_pred` becomes `safePred`. Constructor tags keep the original constructor name, even when an interface or function must be renamed.

Name collisions and reserved identifiers receive numeric suffixes, so inspect the generated exports when a Rocq name conflicts with a JavaScript or TypeScript name. Module member names stay consistent with their interfaces. To satisfy the output's lint rules, `shape` in identifiers becomes `form` (`shape_area` becomes `formArea`); tags and filenames keep their original spelling.

## Limitations

The backend is experimental. Strict TypeScript checking does not establish that an extracted program preserves every property proved in Rocq. In particular, custom mappings are trusted and callers must respect the original input domains.

### Recursion

Some calls still use the JavaScript stack and can overflow on deep inputs:

- Polymorphic recursion, where a function calls itself at different type arguments.
- Functions whose saved state includes a generic local function.
- Calls back to an enclosing function from a local fixpoint that is generic, used as a value, or not the enclosing function's whole body.
- Calls through lambdas, lazy cells, or custom match-function branches, which start a separate invocation rather than continuing the enclosing loop.

Generated state machines have no branch-count limit. The project's lint configuration permits their control flow, preallocated arrays, indexed loops, and in-place operations on private buffers. Primitive strings contain bytes, so their realisers use code-unit access. These choices do not change the persistent semantics of extracted values.

### Types and conversions

Some types cannot be represented and cause extraction to fail with a diagnostic naming the declaration. These include polymorphic non-function values such as `forall A, list A`, aliases of quantified types, and custom-realized constants whose types depend on terms.

Records with a field of sort `Type` must have a type recoverable from their bodies. Heterogeneous collections such as `[nat_monoid; bool_monoid]`, recursive functions returning these records, and results selected by a non-enumeration argument are unsupported. Returning such records inside another type, such as `list monoid`, is also unsupported.

Local polymorphic functions with unused parameters may require an unchecked conversion through the generated `__magic` helper. The plugin reports these with `typescript-extraction-unchecked-casts`. A local binding to an application rather than a function is not generalized; conversions inherited from standard extraction can occur there without that warning.

Dependent types over non-enumeration values become broader unions. Constructor results using `never` for unused type parameters can also fail TypeScript checking when another constructor uses the same parameter contravariantly. For example, a `Run` constructor producing `Hb<number, never>` may not be assignable to `Hb<number, boolean>` if `Hb` also contains a function accepting that parameter.

### Modules and custom representations

A functor defined directly as another functor (`Module G (Y : S) := F.`) is unsupported. Extraction commands inside module types are also rejected.

Rocq drops custom directives inside sealed modules and functors when they close; see [custom extraction directives](extraction.md#custom-extraction-directives).

Primitive array literals cannot be extracted when `PrimArray.array` has a custom representation. Construct the array with `PrimArray.make` and `set` instead.
