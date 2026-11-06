From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* An implementation whose result is an inductive that mentions the
   functor argument. Stop ignores the argument and C carries it. *)
Module Type SIG.
  Parameter t : Type.
  Parameter z : t.
End SIG.

Module Type FT (X : SIG) := SIG.

Module Wrap (X : SIG) <: SIG.
  Inductive raw := C (x : X.t) | Stop.
  Definition t := raw.
  Definition z : t := Stop.
  Definition make (x : X.t) : t := C x.
End Wrap.

Module A.
  Definition t := nat.
  Definition z : t := 1.
End A.

Module Use (F : FT) (X : SIG).
  Module B := F X.
  Definition z : B.t := B.z.
End Use.

Module U := Use Wrap A.

TypeScript Extraction "inductive-result.ts" Use U Wrap.
