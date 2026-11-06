From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

(* The same member through an application to a module checked against the
   parameter's module type. *)
Module Type ORD. Parameter t : Type. End ORD.
Module Sorting (X : ORD).
  Definition sort (l : list X.t) : list X.t :=
    match l with nil => nil | cons x r => app r (cons x nil) end.
End Sorting.
Module NatOrd <: ORD. Definition t := nat. End NatOrd.

Module Sort := Sorting NatOrd.

Definition sorted (l : list nat) : list nat := Sort.sort l.

TypeScript Extraction "method-through-application.ts" sorted.
