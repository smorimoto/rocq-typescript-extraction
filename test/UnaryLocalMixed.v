From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition local_add (a b : nat) : nat :=
  (fix walk k := match k with O => b | S previous => S (walk previous) end) a.

TypeScript Extraction "unary-local-mixed.ts" local_add Nat.leb Nat.ltb.
