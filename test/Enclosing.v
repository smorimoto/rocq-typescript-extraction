From TypeScriptExtraction Require Import Number.

(* A functor defined as a parameter of the functor around it returns that
   parameter, not the argument it is applied to. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module Nest (X : S).
  Module AsOuter (Y : S) := X.
End Nest.
Module NA := Nest A.
Module AO := NA.AsOuter A2.
Definition oz : nat := AO.z.

TypeScript Extraction "enclosing.ts" Nest NA AO oz.
