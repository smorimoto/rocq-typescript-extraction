From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
Open Scope list_scope.
From KeyLibs Require Import KeySig KeyImpl.

(* A functor of this file over the module type of one file, applied to
   the module of another, reads each member under the key the module
   type gives it. *)
Module Props (M : MAP).
  Fixpoint of_list {A} (l : list (nat * A)) : M.t A :=
    match l with
    | nil => M.empty A
    | (k, v) :: rest => M.set _ k v (of_list rest)
    end.
End Props.

Module P := Props Assoc.

Definition built : Assoc.t bool := P.of_list ((1, true) :: (2, false) :: nil).
Definition found : option bool := Assoc.get 2 built.

TypeScript Separate Extraction Props P built found.
