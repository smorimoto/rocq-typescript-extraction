From TypeScriptExtraction Require Import Number.

Module Figure.
  Inductive t := Circle (r : nat) | Square (side : nat).
  Definition area (s : t) : nat :=
    match s with Circle r => 3 * r * r | Square n => n * n end.
End Figure.
