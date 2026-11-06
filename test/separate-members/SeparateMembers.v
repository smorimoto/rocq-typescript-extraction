From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From MemberLibs Require Import Sorts Nests.

(* The members named like methods of an application of another file, read
   through its import, and a functor of another file whose body aliases a
   module nested in an application, applied here. *)
Module O := Outer NatOrd.

Definition twice (l : list nat) : list nat := Sort.sort (sorted l).
Definition dropped (l : list nat) : list nat := Sort.Inner.filter (O.drop l).

TypeScript Separate Extraction twice dropped.
