From TypeScriptExtraction Require Import Number.
(* The bigint theories replace the number mappings of the Number preset. *)
From TypeScriptExtraction Require Import ExtrTsNatBigInt.
Set Warnings "+typescript-extraction-unchecked-casts".

Fixpoint sum_to (n acc : nat) : nat :=
  match n with 0 => acc | S k => sum_to k (acc + n) end.

Fixpoint fib_iter (n a b : nat) : nat :=
  match n with 0 => a | S k => fib_iter k b (a + b) end.

TypeScript Extraction "big-loops.ts" sum_to fib_iter.
