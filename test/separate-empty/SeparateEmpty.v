From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition twice (f : nat -> nat) (n : nat) : nat := f (f n).
Definition pick (f : bool -> nat) (b : bool) : nat := f b.

TypeScript Separate Extraction twice pick.
