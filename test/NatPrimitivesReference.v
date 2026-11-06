From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition nat_even := Nat.even.
Definition nat_odd := Nat.odd.
Definition nat_div2 := Nat.div2.
Definition nat_pow := Nat.pow.

TypeScript Extraction "nat-primitives-reference.ts" nat_even nat_odd nat_div2 nat_pow.
