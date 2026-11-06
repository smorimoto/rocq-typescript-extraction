From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

(* Methods that lint could mistake for built-in operations, such as
   Array#map, are bound once after a module application. Unrestricted
   names, such as sort, are called directly through the module. *)
Module Type ORD. Parameter t : Type. End ORD.

Module Sorting (X : ORD).
  Definition sort (l : list X.t) : list X.t :=
    match l with nil => nil | cons x r => app r (cons x nil) end.
  Module Inner.
    Definition map (f : X.t -> X.t) (l : list X.t) : list X.t := map f l.
  End Inner.
End Sorting.

Module NatOrd. Definition t := nat. End NatOrd.
Module Sort := Sorting NatOrd.

Module Uses (Y : ORD).
  Definition twice (l : list nat) : list nat := Sort.sort (Sort.sort l).
End Uses.

Module U := Uses NatOrd.

Definition sorted (l : list nat) : list nat := Sort.sort l.
Definition mapped (l : list nat) : list nat := Sort.Inner.map S l.
Definition twice (l : list nat) : list nat := U.twice l.

TypeScript Extraction "method-member.ts" Sorting sorted mapped twice.
