From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* Corelib's Nat.add and Nat.mul on Peano naturals call themselves at no
   tail, once per unit of their first argument. *)
Definition plus (n m : nat) : nat := Nat.add n m.
Definition times (n m : nat) : nat := Nat.mul n m.

TypeScript Extraction "stack-peano.ts" plus times.
