From TypeScriptExtraction Require Import Number.

(* A map whose constructor Empty lowercases to its empty, and whose set0
   is the name a reserved word turns set into. *)
Module Assoc.
  Inductive tree (A : Type) := Empty | Node (k : nat) (v : A) (rest : tree A).
  Arguments Empty {A}.
  Arguments Node {A}.
  Definition t := tree.
  Definition empty (A : Type) : t A := Empty.
  Definition set0 {A} (k : nat) (v : A) : t A := Node k v Empty.
  Definition set {A} (k : nat) (v : A) (m : t A) : t A := Node k v m.
  Fixpoint get {A} (k : nat) (m : t A) : option A :=
    match m with
    | Empty => None
    | Node k' v rest => if Nat.eqb k k' then Some v else get k rest
    end.
End Assoc.
