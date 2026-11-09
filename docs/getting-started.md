# Getting started

## Install from source

From a checkout of this repository, in an opam switch with OCaml 5.1 or later:

```sh
git submodule update --init --recursive --depth 1
opam install .
```

This installs the plugin and its Rocq theories. Rocq 9.3 or later is required. For a development checkout, see [Contributing](https://github.com/smorimoto/rocq-typescript-extraction/blob/main/CONTRIBUTING.md).

## Usage

Save this as `Tree.v`:

<!-- sample: Tree.v -->

```coq
From TypeScriptExtraction Require Import Number.

Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.

Fixpoint size {A} (t : tree A) : nat :=
  match t with Leaf => 0 | Node l _ r => S (size l + size r) end.

TypeScript Extraction "tree.ts" size.
```

Compile it to generate `tree.ts`:

```sh
opam exec -- rocq compile Tree.v
```

Import the generated function, type, and constructors from TypeScript:

```ts
import type { Tree } from "./tree.ts";
import { leaf, node, size } from "./tree.ts";

const t: Tree<string> = node(leaf, "a", node(leaf, "b", leaf));
size(t); // 2
```

The `Number` preset maps standard integers (`nat`, `positive`, `N`, and `Z`) to JavaScript `number`. Use `From TypeScriptExtraction Require Import BigInt.` instead for exact `bigint` arithmetic. In either preset, callers must respect Rocq's input domains: for example, a `nat` must be a nonnegative integer.
