From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From PairLibs Require Import Pair PairExt.

Definition flipped (p : nat * nat) : nat * nat := swap p.
Definition same (p : nat * nat) : nat * nat := swap_twice p.

TypeScript Separate Extraction flipped same.
