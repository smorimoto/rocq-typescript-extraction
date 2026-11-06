From TypeScriptExtraction Require Import Number.

Record bounds := { lo : nat; hi : nat }.
Record cell (A : Type) := { content : A; size : nat }.

Inductive span := Span (b : bounds).
Inductive wrapped (A : Type) := Wrap (x : A).
Extract Inductive span => "Bounds" [ "((b: Bounds): Bounds => b)" ]
  "(<R>(f: (b: Bounds) => R, s: Bounds): R => f(s))".
Extract Inductive wrapped => "Cell<$1>" [ "(<A>(x: A): Cell<A> => ({ content: x, size: 1 }))" ]
  "(<A, R>(f: (x: A) => R, w: Cell<A>): R => f(w.content))".
