From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition head (l : list nat) : l <> nil -> nat :=
  match l return l <> nil -> nat with
  | nil => fun H => match H eq_refl with end
  | cons x _ => fun _ => x
  end.

Parameter oracle : nat -> nat.

Definition ask (n : nat) : nat := oracle (S n).

TypeScript Extraction "absurd.ts" head ask.
