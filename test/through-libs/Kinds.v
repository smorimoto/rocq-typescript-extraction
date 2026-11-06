From TypeScriptExtraction Require Import Number.

Module Type CONTAINER.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
  Parameter map : forall A B, (A -> B) -> t A -> t B.
End CONTAINER.

Module Use (C : CONTAINER).
  Definition e : C.t nat := C.empty nat.
  Definition twice {A} (f : A -> A) (x : C.t A) : C.t A := C.map A A f (C.map A A f x).
End Use.

Module L.
  Definition t := list.
  Definition empty (A : Type) : list A := nil.
  Fixpoint map {A B} (f : A -> B) (l : list A) : list B :=
    match l with nil => nil | cons x r => cons (f x) (map f r) end.
End L.
