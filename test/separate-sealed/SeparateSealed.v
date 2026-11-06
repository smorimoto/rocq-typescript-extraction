From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From SealedLibs Require Import SolverSig Solvers.

(* The sealed solvers of another file, applied in the body of a functor
   of this file and at its top level, where the alias type of each
   application is the argument's. *)
Module Nested (Z : LAT).
  Module O := Outer Z.
  Definition twice (n : nat) : Z.t := Z.lub (O.run n) (O.run n).
End Nested.

Module NatLat.
  Definition t := nat.
  Definition bot := 7.
  Definition lub (a b : nat) := a + b.
End NatLat.

Module S := Outer NatLat.
Module N := Nested NatLat.

Definition go : nat := S.run 3.
Definition twice : nat := N.twice 0.
Definition through : NatLat.t := N.O.run 1.

TypeScript Separate Extraction Nested go twice through.
