From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From AppliedLibs Require Import OrderSig OrderTac.

(* A functor of another file whose parameter is declared with a module
   type applied to another, applied in the body of a functor of this
   file and at its top level. *)
Module Twice (O : EqLe) (P : IsTotal O).
  Module T := MakeTac O P.
  Definition both (x y : O.t) : bool := andb (T.cmp x y) (T.cmp y x).
End Twice.

Module N.
  Definition t := nat.
  Definition le := Nat.leb.
  Definition le_total (x y : nat) := Nat.eqb x y.
End N.

Module T := MakeTac N N.
Module W := Twice N N.

Definition go : bool := T.cmp 3 1.
Definition both : bool := W.both 2 2.

TypeScript Separate Extraction Twice go both.
