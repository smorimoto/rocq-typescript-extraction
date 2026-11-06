From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

Definition safe_head {A} (l : list A) : option A :=
  match l with nil => None | cons x _ => Some x end.

Definition swap_pair {A B} (p : A * B) : B * A := (snd p, fst p).

Fixpoint sum (l : list nat) : nat :=
  match l with nil => 0 | cons x r => x + sum r end.

Definition firsts : list nat := map fst ((1, true) :: (2, false) :: nil).
Definition doubled : list nat := map Nat.double (seq 0 4).
Definition middle : list nat := firstn 2 (skipn 1 (seq 10 5)).
Definition third : nat := nth 2 (seq 10 5) 0.
Definition next_head : option nat := option_map S (safe_head (seq 3 2)).
Definition total : nat := length (app (repeat true 2) (false :: nil)).
Definition order : comparison := Nat.compare 3 5.
Definition empty {A} : list A := nil.
Definition preds : list nat :=
  map (fun q => match q with (a, b) => match a + b with 0 => b | S k => k end end)
    ((1, 2) :: (0, 0) :: nil).

TypeScript Extraction "lists.ts"
  safe_head swap_pair sum firsts doubled middle third next_head total order empty
  preds Nat.eqb Nat.leb Nat.max.
