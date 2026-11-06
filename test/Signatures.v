From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The module type enters the structure because A is sealed by it. Nothing
   refers to its interface, so the output has no trace of it, but every
   member of A takes exactly the arrows of its declared type, aliases
   unexpanded, so that A stays assignable to the interface of S: f keeps
   one parameter where its body has two lambdas, and pick takes two where
   its body has one. A top-level value keeps the arity of its expanded
   type, so top takes two parameters. The elimination schemes of w into
   Type and Set, w_rect and w_rec, are members of A; those into Prop and
   SProp, w_ind and w_sind, which extraction erases, are not. *)
Module Type S.
  Parameter t : Type.
  Definition u := bool.
  Inductive w := W (x : t) | Nothing.
  Parameter z : w.
  Parameter f : t -> t.
  Parameter pick : u -> t -> t.
  Module Deep. Parameter d : t. End Deep.
End S.

Module A : S.
  Definition t := nat -> nat.
  Definition u := bool.
  Inductive w := W (x : t) | Nothing.
  Definition z : w := W (fun n => n).
  Definition f : t -> t := fun g x => g (g x).
  Definition pick (b : u) : t -> t := if b then f else (fun g => g).
  Module Deep. Definition d : t := fun n => n + 1. End Deep.
End A.

Definition fn := nat -> nat.
Definition top : fn -> fn := fun g x => g (g x).
Definition chosen : A.t :=
  match A.z with A.W g => A.pick true (A.f g) | A.Nothing => A.Deep.d end.

TypeScript Extraction "signatures.ts" A top chosen.
