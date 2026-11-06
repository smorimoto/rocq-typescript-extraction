From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The module defines empty beside a constructor Empty, which lowercases
   to the same name. The definition keeps it, so the functor reads the
   definition. *)
Module Type MAP.
  Parameter t : Type.
  Parameter empty : t.
End MAP.

Module Tree <: MAP.
  Inductive tree := Empty | Node (x : nat).
  Definition t := tree.
  Definition empty : t := Node 7.
End Tree.

Module Use (M : MAP).
  Definition fresh : M.t := M.empty.
End Use.

Module U := Use Tree.

Definition fresh : Tree.t := U.fresh.

TypeScript Extraction "member-ctor-clash.ts" Tree fresh.
