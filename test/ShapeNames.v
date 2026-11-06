From TypeScriptExtraction Require Import Number.

(* Anti-slop's no-shape-in-symbol-names rejects every identifier that
   contains "shape" in any case, so each kind of name below has the word
   replaced, while a tag, a string, keeps it. *)
Inductive shape := Shape (sides : nat) | Blob (shape : nat).

Definition shape_area (s : shape) : nat :=
  match s with Shape n => n * n | Blob k => k end.

Module Frame.
  Record t := { shape : nat; border : nat }.
  Definition inner (f : t) : nat := shape f - border f.
End Frame.

Inductive holder (shape : Type) := Hold (held : shape) | Empty.
Arguments Hold {shape}.
Arguments Empty {shape}.

Definition twice (shape : nat) : nat := shape + shape.

(* reshape becomes reform, which a later definition has, so that one
   takes the suffix. *)
Definition reshape (n : nat) : holder nat := Hold n.
Definition reform (n : nat) : nat := S n.

Definition SHAPES : list shape := cons (Shape 2) (cons (Blob 5) nil).

Module Shapes.
  Definition unit_square : shape := Shape 1.
End Shapes.

TypeScript Extraction "shape-names.ts"
  shape_area Frame twice reshape reform SHAPES Shapes.
