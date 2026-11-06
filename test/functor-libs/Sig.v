From TypeScriptExtraction Require Import Number.

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Parameter next : t -> t.
  Parameter map : (t -> t) -> t -> t.
End S.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := S n.
  Definition map (f : t -> t) (x : t) : t := f x.
End A.
