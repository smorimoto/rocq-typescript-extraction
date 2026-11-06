From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A member of a functor body, and a specification of a module type, whose
   type depends on a term take the signature that the kernel gives them,
   read in the environment of the functor's parameters and the body's
   fields, so a call with a constructor argument needs no cast, through
   the functor's parameter and through an application alike. *)
Module Type SEED.
  Parameter n : nat.
End SEED.

Module Make (S : SEED).
  Definition dep (b : bool) : if b then nat else bool :=
    match b with true => S.n | false => false end.
  Definition zero : nat := dep true.
End Make.

Module Type DEP.
  Parameter dep : forall b : bool, if b then nat else bool.
End DEP.

Module Use (D : DEP).
  Definition amount : nat := D.dep true.
  Definition flag : bool := D.dep false.
End Use.

Module Seed.
  Definition n : nat := 3.
End Seed.

Module Made := Make Seed.

Module Applied := Use Made.

Definition three : nat := Made.dep true.

TypeScript Extraction "functor-dep.ts" Make Use Made Applied three.
