From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From FunctorLibs Require Import Sig Fun App.

(* A module of this file applied to the functor of another file. *)
Module C.
  Definition t := bool.
  Definition z : t := false.
  Definition next (b : t) : t := negb b.
  Definition map (f : t -> t) (b : t) : t := f b.
End C.

Module D := F C.

(* A functor of this file over the module type and the functor signature
   of other files, applied to a module and a functor of other files. *)
Module H (X : S) (G : FT).
  Module GX := G X.
  Definition step : X.t := GX.twice X.z.
End H.

Module HB := H A F.

(* The members of an application of another file, one of them named like
   a method, and its types. *)
Definition boxed : B.box := B.map S (B.fill 1).
Definition flipped : D.box := D.fill D.mapped.
Definition v : nat := four + HB.step.

TypeScript Separate Extraction D HB boxed flipped v.
