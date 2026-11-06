From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A functor sealed with a module type whose nested module is its
   parameter, through an alias in the body. The alias has no type of its
   own, so the constraint gives its type, in the body and under each
   application, where the type is the argument's. *)
Module Type LAT. Parameter t : Type. Parameter bot : t. End LAT.
Module Type SOLVER. Declare Module L : LAT. Parameter run : nat -> L.t. End SOLVER.

Module Solver (X : LAT) : SOLVER with Module L := X.
  Module L := X.
  Definition run (_ : nat) : L.t := L.bot.
End Solver.

Module NatLat. Definition t := nat. Definition bot := 4. End NatLat.
Module S := Solver NatLat.

Definition go : nat := S.run 3.

TypeScript Extraction "sealed-param-alias.ts" Solver go.
