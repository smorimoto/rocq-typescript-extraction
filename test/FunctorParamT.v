From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A functor parameter named T, whose module type's abstract type t is the
   type parameter T too: the parameter takes the suffix, in a functor, a
   functor signature, and a partial application alike. *)
Module Type TREE.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
End TREE.

Module Props (T : TREE).
  Definition fresh (A : Type) : T.t A := T.empty A.
End Props.

Module Tree.
  Definition t (A : Type) := list A.
  Definition empty (A : Type) : t A := nil.
End Tree.

Module P := Props Tree.

Module Type ALG. Parameter t : Type. Parameter x : t. End ALG.
Module Type FT (T : ALG). Parameter y : nat -> T.t. End FT.

Module F (A : ALG) (T : ALG).
  Definition y (_ : nat) : A.t * T.t := (A.x, T.x).
End F.

Module N. Definition t := nat. Definition x := 3. End N.
Module Q := F N.
Module QN := Q N.

Module Use (G : FT).
  Module R := G N.
  Definition go : nat := R.y 0.
End Use.

Module G1 (T : ALG). Definition y (_ : nat) : T.t := T.x. End G1.
Module U := Use G1.

Definition go : list nat := P.fresh nat.
Definition both : nat * nat := QN.y 0.
Definition used : nat := U.go.

TypeScript Extraction "functor-param-t.ts" Props Q Use go both used.
