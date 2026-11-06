From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition outer : nat := 1.

(* Separate extraction from inside open modules writes them as closed so
   far: M holds x and N.y, and not after, which comes later. *)
Module M.
  Definition x : nat := 2.
  Module N.
    Definition y : nat := x + outer.
    TypeScript Separate Extraction y.
  End N.
  Definition after : nat := N.y.
End M.
