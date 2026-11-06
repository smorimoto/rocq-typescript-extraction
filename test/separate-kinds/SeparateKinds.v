From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From ThroughLibs Require Import Kinds.

(* A functor over a module type of another file whose abstract type takes
   a parameter, and applications of it and of a functor of that file to a
   module of that file. *)
Module Wrap (C : CONTAINER).
  Definition zeros : C.t bool := C.map nat bool (Nat.eqb 0) (C.empty nat).
End Wrap.

Module U := Use L.
Module W := Wrap L.

Definition total : list nat := U.twice S (cons 1 nil).

TypeScript Separate Extraction U Wrap W total.
