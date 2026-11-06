From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A functor checked against a module type whose nested module is its
   parameter, applied in the body of another functor to that one's
   parameter: the alias's type under the outer application is the outer
   argument's. *)
Module Type LAT. Parameter t : Type. Parameter bot : t. End LAT.
Module Type SOLVER. Declare Module L : LAT. Parameter get : nat -> L.t. End SOLVER.

Module Inner (X : LAT) <: SOLVER with Module L := X.
  Module L := X.
  Definition get (_ : nat) : L.t := L.bot.
End Inner.

Module Solver (X : LAT).
  Module DS := Inner X.
  Definition run (n : nat) : X.t := DS.get n.
End Solver.

Module NatLat. Definition t := nat. Definition bot := 6. End NatLat.
Module S := Solver NatLat.

Definition go : nat := S.run 3.
Definition through : NatLat.t := S.DS.L.bot.

TypeScript Extraction "nested-checked-alias.ts" Solver go through.
