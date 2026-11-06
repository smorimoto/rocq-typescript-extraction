From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From ThroughLibs Require Import Outer.

Module A2. Definition t := bool. Definition z : t := true. End A2.

(* A functor of a body applied through an application of another file,
   in full and in part. *)
Module C := B.G A2.
Module P := B.G2 A2.
Module Q := P A.

(* A functor of a functor signature of another file, applied through an
   application of a parameter declared with the signature. *)
Module Use (FF : FT) (X : S) (Y : S).
  Module FX := FF X.
  Module FXY := FX.G Y.
  Definition both : FXY.box := FXY.both.
End Use.
Module U := Use F A A2.

Definition fromC : C.box := C.both.
Definition fromQ : nat * bool * nat := Q.three.
Definition fromU : U.FXY.box := U.both.

TypeScript Separate Extraction C P Q U fromC fromQ fromU.
