From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Tuples Require Import Pairs.

Definition succ_both (p : nat * nat) : nat * nat := Pair.map S p.
Definition ordered (p : nat * nat) : nat * nat := Pair.sort p.
Definition total (p : nat * nat) : nat := Pair.reduce (fun a b => a + b) p.

TypeScript Separate Extraction succ_both ordered total.
