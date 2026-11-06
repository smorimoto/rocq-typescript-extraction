From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* An abstract type left in the result of a functor signature is a type
   lambda of the abstract types of its parameters, which each
   implementation picks: Const ignores its argument and Same returns its
   type. A body applies the functor-typed parameter twice, a functor
   passes its own parameter on, and an application is partial. *)
Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.
Module Type FT (X : SIG) := SIG.

Module Const (X : SIG) <: SIG. Definition t := nat. Definition z : t := 0. End Const.
Module Same (X : SIG) <: SIG. Definition t := X.t. Definition z : t := X.z. End Same.

Module A. Definition t := nat. Definition z : t := 7. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.

Module Use (F : FT) (X : SIG).
  Module B := F X.
  Module B2 := F A2.
  Definition z : B.t := B.z.
  Definition both : B.t * B2.t := (B.z, B2.z).
End Use.

Module Again (G : FT) (X : SIG).
  Module U := Use G X.
  Definition again : U.B.t := U.z.
End Again.

Module U1 := Use Const A.
Module U2 := Use Same A.
Module P := Use Same.
Module AG := Again Same A.

TypeScript Extraction "functor-signature-result.ts" Use Again U1 U2 P AG.
