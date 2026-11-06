From TypeScriptExtraction Require Import Number.

Inductive polygon := Triangle | Square.

Definition sides (p : polygon) : nat :=
  match p with Triangle => 3 | Square => 4 end.
