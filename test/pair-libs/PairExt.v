From TypeScriptExtraction Require Import Number.
From PairLibs Require Import Pair.

Definition swap_twice (p : nat * nat) : nat * nat := swap (swap p).
