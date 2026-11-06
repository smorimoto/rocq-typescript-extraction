From TypeScriptExtraction Require Import Number.

(* A function of a nested functor that reads nothing of the body is
   hoisted beside the outer functor, and the outer functor does not
   return it. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module A. Definition t := nat. Definition z : t := 1. End A.
Module F (X : S).
  Module Nested (Y : S).
    Definition twice (n : nat) : nat := n + n.
  End Nested.
End F.
Module B := F A.

TypeScript Extraction "plain-nest.ts" F B.
