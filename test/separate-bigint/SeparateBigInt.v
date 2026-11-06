From TypeScriptExtraction Require Import BigInt.
Set Warnings "+typescript-extraction-unchecked-casts".
From BigIntLibs Require Import Api.

Module Seed.
  Definition value : nat := 3.
End Seed.

Module Made := Pair Seed.
Definition total (p : nat * nat) : nat := fst p + snd p.
Definition pred_or (d n : nat) : nat := match n with O => d | S p => p end.

TypeScript Separate Extraction Pair Made total pred_or.
