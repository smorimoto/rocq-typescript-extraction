From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Containers Require Import Boxes.

Definition filled (n : nat) : Box.box := Box.Full n.
Definition contents (b : Box.box) : nat :=
  match b with Box.Empty => Box.zero | Box.Full n => n end.
Definition bigger (b : Box.box) : Box.box := Box.Full (S (contents b)).

TypeScript Separate Extraction filled contents bigger.
