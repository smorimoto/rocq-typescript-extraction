From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From Corelib Require Import ListDef.
Set Warnings "+typescript-extraction-unchecked-casts".

Fixpoint double (n : nat) : nat :=
  match n with O => O | S p => S (S (double p)) end.

Definition both (b : bool) (n : nat) : bool * nat := (b, double n).

Definition doubles (l : list nat) : list nat := map double l.

Definition map {A B} (f : A -> B) (p : A * A) : B * B := (f (fst p), f (snd p)).

Definition twice (map : nat -> nat) (l : list nat) : list nat :=
  ListDef.map map (ListDef.map map l).

Module Geometry.
  Inductive figure := Dot | Line (n : nat).
  Definition len (s : figure) : nat := match s with Dot => O | Line n => n end.
End Geometry.

TypeScript Separate Extraction double both doubles map twice Geometry.
