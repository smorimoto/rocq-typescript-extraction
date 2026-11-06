From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* An inline match that must be a statement, in every place an expression
   can hold it: a chain of tests that returns, or that assigns with an
   else for each test. *)
Extract Inductive bool => "boolean" [ "true" "false" ].
TypeScript Extract Match bool => [ "$0" ] [ "!$0" ].

Extract Inductive nat => "number" [ "0" "((n: number): number => n + 1)" ].
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].

Extract Inductive prod => "readonly [$1, $2]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ].
TypeScript Extract Match prod => [ _ "$0[0]" "$0[1]" ].

Definition swap_sum (p : nat * nat) : nat * nat := (snd p, fst p).

Definition bucket (n : nat) : nat :=
  let w := match n with 0 => 10 | 1 => 20 | S (S k) => k + k end in w + w.

Definition bucket_wide (n m : nat) : nat :=
  Nat.add (m + m) (match n with 0 => 10 | 1 => 20 | S (S k) => k end).

Definition predecessor_in_cond (b : bool) (n : nat) : nat :=
  if b then S (match n with 0 => 0 | S p => p end) else n.

Definition pair_in_partial (n : nat) : nat -> nat :=
  Nat.add (match swap_sum (n, S n) with (a, b) => a + b end).

TypeScript Extraction "inline-statements.ts" bucket bucket_wide predecessor_in_cond pair_in_partial.
