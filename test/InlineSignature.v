From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A functor signature whose result is the signature written as its body,
   not an alias of another signature. Const ignores the argument and Same
   returns it. *)
Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.

Module Type FT (X : SIG).
  Parameter t : Type.
  Parameter z : t.
End FT.

Module Const (X : SIG) <: SIG.
  Definition t := nat.
  Definition z : t := 0.
End Const.

Module Same (X : SIG) <: SIG.
  Definition t := X.t.
  Definition z : t := X.z.
End Same.

Module A. Definition t := nat. Definition z : t := 4. End A.

Module Use (F : FT) (X : SIG).
  Module B := F X.
  Definition z : B.t := B.z.
End Use.

Module U1 := Use Const A.
Module U2 := Use Same A.

TypeScript Extraction "inline-signature.ts" Use U1 U2.
