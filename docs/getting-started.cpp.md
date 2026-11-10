<!-- Generated from getting-started.cpp.md; do not edit directly. -->

# Getting started

## Install from source

From a checkout of this repository, in an opam switch with OCaml 5.1 or later:

```sh
git submodule update --init --recursive --depth 1
opam install .
```

This installs the plugin and its Rocq theories. Rocq 9.3 or later is required.

## Usage

Save this as `Tree.v`:

```coq
#include "../test/docs/Tree.v"
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
