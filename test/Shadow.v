From TypeScriptExtraction Require Import Number.

(* A module in a functor body named like a top-level module takes a local
   that does not shadow it. The field keeps the name from Rocq. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module A. Definition t := nat. Definition z : t := 0. End A.
Module P. Definition t := nat. Definition z : t := 1. End P.
Module F (X : S).
  Module P. Definition n : nat := 1. End P.
  Definition n : nat := P.n.
End F.
Module B := F A.

TypeScript Extraction "shadow.ts" P F B.
