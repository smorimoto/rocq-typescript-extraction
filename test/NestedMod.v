From TypeScriptExtraction Require Import Number.

(* A functor defined as a module of the same body returns that module. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module Nest (X : S).
  Module Inner. Definition t := nat. Definition z : t := 4. End Inner.
  Module AsNested (Y : S) := Inner.
End Nest.
Module A. Definition t := nat. Definition z : t := 1. End A.
Module NA := Nest A.
Module AN := NA.AsNested A2.
Definition nz : nat := AN.z.

TypeScript Extraction "nested-mod.ts" Nest NA AN nz.
