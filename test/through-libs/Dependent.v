From TypeScriptExtraction Require Import Number.

(* A functor whose body has a member of a dependent type, and a module
   type with a specification of one, for ../separate-dependent. *)
Module Type SEED.
  Parameter n : nat.
End SEED.

Module Make (S : SEED).
  Definition dep (b : bool) : if b then nat else bool :=
    match b with true => S.n | false => false end.
End Make.

Module Type DEP.
  Parameter dep : forall b : bool, if b then nat else bool.
End DEP.

Module Use (D : DEP).
  Definition amount : nat := D.dep true.
End Use.
