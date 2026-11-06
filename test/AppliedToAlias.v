From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A functor applied, in the body of another, to an alias of that one's
   parameter: the types of the application name the parameter's. *)
Module Type LAT. Parameter t : Type. Parameter bot : t. End LAT.

Module Inner (X : LAT).
  Definition get (_ : nat) : X.t := X.bot.
End Inner.

Module Solver (X : LAT).
  Module L := X.
  Module DS := Inner L.
  Definition run (n : nat) : L.t := DS.get n.
End Solver.

Module NatLat. Definition t := nat. Definition bot := 5. End NatLat.
Module S := Solver NatLat.

Definition go : nat := S.run 3.

TypeScript Extraction "applied-to-alias.ts" Solver go.
