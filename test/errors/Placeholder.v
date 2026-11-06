From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* A placeholder of an Extract Inductive type names one of its type
   arguments, counted from 1. *)
Definition swap {A B} (p : A * B) : B * A := let (a, b) := p in (b, a).

Extract Inductive prod => "readonly [$1, $3]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ]
  "(<A, B, R>(f: (a: A, b: B) => R, p: readonly [A, B]): R => f(p[0], p[1]))".
Fail TypeScript Recursive Extraction swap.

Extract Inductive prod => "readonly [$0, $1]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ]
  "(<A, B, R>(f: (a: A, b: B) => R, p: readonly [A, B]): R => f(p[0], p[1]))".
Fail TypeScript Recursive Extraction swap.
