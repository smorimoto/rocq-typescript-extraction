From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The same clash under a polymorphic module type, where the definition is
   a function of its type argument and the constructor a constant. *)
Module Type MAP.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
End MAP.

Module Tree <: MAP.
  Inductive tree (A : Type) := Empty | Node (x : A).
  Arguments Empty {A}.
  Arguments Node {A}.
  Definition t := tree.
  Definition empty (A : Type) : t A := Empty.
End Tree.

Module Use (M : MAP).
  Definition fresh : M.t nat := M.empty nat.
End Use.

Module U := Use Tree.

Definition fresh : Tree.t nat := U.fresh.

TypeScript Extraction "member-ctor-clash-poly.ts" Tree Use fresh.
