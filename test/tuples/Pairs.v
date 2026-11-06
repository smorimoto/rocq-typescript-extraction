From TypeScriptExtraction Require Import Number.

Module Pair.
  Definition map {A B} (f : A -> B) (p : A * A) : B * B := (f (fst p), f (snd p)).
  Definition reduce {A B} (f : A -> A -> B) (p : A * A) : B := f (fst p) (snd p).
  Definition sort (p : nat * nat) : nat * nat :=
    if Nat.leb (fst p) (snd p) then p else (snd p, fst p).
End Pair.
