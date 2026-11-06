From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module A. Definition t := nat. Definition z : t := 1. End A.

Module Q. Definition q : nat := 7. End Q.

Module F (X : S).
  Inductive wrapped := Wrap (x : X.t) | Empty.
  Definition w : X.t := X.z.
End F.

Module B := F A.

Module H (X : S).
  Module M. Definition q : X.t := X.z. End M.
  Module M' := M.
  Module C := F X.
  Module C' := C.
  Module Y := X.
End H.
