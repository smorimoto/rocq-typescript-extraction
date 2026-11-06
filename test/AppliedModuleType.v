From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A parameter declared with a module type applied to another parameter.
   MiniML writes the members out under the parameter, so the parameter has
   an interface of its own, named after the functor, over the abstract
   types of the other parameter that the members mention. *)
Module Type EqLtLe. Parameter t : Type. End EqLtLe.
Module Type IsTotalOrder (O : EqLtLe).
  Parameter le_total : O.t -> O.t -> bool.
End IsTotalOrder.

Module MakeTac (O : EqLtLe) (P : IsTotalOrder O).
  Definition cmp (x y : O.t) : bool := P.le_total x y.
End MakeTac.

Module N. Definition t := nat. End N.
Module NP. Definition le_total (x y : nat) := Nat.leb x y. End NP.
Module T := MakeTac N NP.

Definition go : bool := T.cmp 1 2.

TypeScript Extraction "applied-module-type.ts" MakeTac go.
