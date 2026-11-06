From TypeScriptExtraction Require Import Number.
From ThroughLibs Require Import Dependent.
Set Warnings "+typescript-extraction-unchecked-casts".

(* An application of a functor of another file has the signature that its
   member of a dependent type has in the kernel, at its argument, and so
   does an application of a functor over a module type of that file. *)
Module Seed.
  Definition n : nat := 3.
End Seed.

Module Made := Make Seed.

Module Applied := Use Made.

Definition three : nat := Made.dep true.

Definition no : bool := Made.dep false.

TypeScript Separate Extraction Made Applied three no.
