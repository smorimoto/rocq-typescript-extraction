From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A type function defined by Fixpoint is a recursive alias, the union of
   its arms with each recursive call the alias itself. A lambda checked
   against the union takes the types of its one function member. *)
Fixpoint nary (n : nat) : Type := match n with 0 => nat | S m => nat -> nary m end.

Fixpoint sum (n : nat) (acc : nat) : nary n :=
  match n return nary n with 0 => acc | S m => fun x => sum m (acc + x) end.

Definition six : nat := sum 3 0 1 2 3.

(* A recursive call directly in the union adds nothing to it. *)
Fixpoint tower (n : nat) : Type := match n with 0 => bool | S m => tower m end.

Fixpoint top (n : nat) : tower n := match n return tower n with 0 => true | S m => top m end.

TypeScript Extraction "type-fixpoint.ts" sum six top.
