From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The shape of CompCert's Kildall solvers: a sealed functor whose body
   applies another sealed one to the alias of its parameter, itself
   applied in the body of a third functor. Each application's alias type
   is its argument's, at every depth, and no reconstruction disagrees. *)
Module Type LAT.
  Parameter t : Type.
  Parameter bot : t.
  Parameter lub : t -> t -> t.
End LAT.

Module Type SOLVER.
  Declare Module L : LAT.
  Parameter run : nat -> L.t.
End SOLVER.

Module Inner (X : LAT) : SOLVER with Module L := X.
  Module L := X.
  Definition run (n : nat) : L.t :=
    match n with O => L.bot | S _ => L.lub L.bot L.bot end.
End Inner.

Module Outer (Y : LAT) : SOLVER with Module L := Y.
  Module L := Y.
  Module DS := Inner L.
  Definition run (n : nat) : L.t := L.lub (DS.run n) L.bot.
End Outer.

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

TypeScript Extraction "sealed-solvers.ts" Outer Nested go twice through.
