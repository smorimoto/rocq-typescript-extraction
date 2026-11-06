From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From ThroughLibs Require Import Aliased.

(* An alias of an application of another file, and an alias of that
   alias. *)
Module B' := B.
Module B'' := B'.

(* An application of a functor of another file with aliases in its body,
   and a functor whose body aliases modules of another file. *)
Module HA := H A.

Module K (X : S).
  Module L := Q.
  Module BB := B''.
  Definition k : nat := L.q + BB.w.
End K.

Module KA := K A.

Definition through : nat := B''.w + HA.M'.q + HA.C'.w + KA.L.q + KA.k.
Definition wrapped : B''.wrapped := B'.Wrap 2.
Definition boxed : HA.C'.wrapped := HA.C'.Wrap 3.

TypeScript Separate Extraction B' B'' HA K KA through wrapped boxed.
