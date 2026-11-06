From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Abstract types with parameters are type lambdas: a member that maps,
   a body function polymorphic over C.t A, and applications to list, to a
   type of two parameters, to a parameter, and through a constraint. *)
Module Type CONTAINER.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
  Parameter map : forall A B, (A -> B) -> t A -> t B.
End CONTAINER.

Module Type MAP.
  Parameter t : Type -> Type -> Type.
  Parameter empty : forall K V, t K V.
  Parameter add : forall K V, K -> V -> t K V -> t K V.
End MAP.

Module Use (C : CONTAINER).
  Inductive boxed := Box (b : C.t nat).
  Definition e : C.t nat := C.empty nat.
  Definition twice {A} (f : A -> A) (x : C.t A) : C.t A := C.map A A f (C.map A A f x).
  Definition succs : C.t nat := twice S e.
  Definition box : boxed := Box succs.
End Use.

Module Pairs (M : MAP).
  Definition one : M.t nat bool := M.add nat bool 1 true (M.empty nat bool).
End Pairs.

Module Again (C : CONTAINER).
  Module U := Use C.
  Definition again : C.t nat := U.e.
End Again.

Module Fixed (C : CONTAINER with Definition t := list).
  Definition xs : C.t nat := C.map nat nat S (cons 1 nil).
End Fixed.

Module L.
  Definition t := list.
  Definition empty (A : Type) : list A := nil.
  Fixpoint map {A B} (f : A -> B) (l : list A) : list B :=
    match l with nil => nil | cons x r => cons (f x) (map f r) end.
End L.

Module P.
  Definition t (K V : Type) := list (K * V).
  Definition empty (K V : Type) : t K V := nil.
  Definition add {K V} (k : K) (v : V) (m : t K V) : t K V := cons (k, v) m.
End P.

Module U := Use L.
Module PP := Pairs P.
Module AL := Again L.
Module FL := Fixed L.

Definition total : list nat := U.succs.
Definition boxed : U.boxed := U.box.
Definition ones : list (nat * bool) := PP.one.
Definition xs : list nat := FL.xs.

TypeScript Extraction "higher-kinded.ts" Use Pairs Again Fixed U PP AL FL total boxed ones xs.
