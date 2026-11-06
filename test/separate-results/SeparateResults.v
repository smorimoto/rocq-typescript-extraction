From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From ThroughLibs Require Import ResultSigs.

(* A functor over a functor signature of another file whose result leaves
   an abstract type, applied twice in its body and applied to the
   implementations of that file. *)
Module A2. Definition t := bool. Definition z : t := true. End A2.

Module Use (F : FT) (X : SIG).
  Module B := F X.
  Module B2 := F A2.
  Definition both : B.t * B2.t := (B.z, B2.z).
End Use.

Module U1 := Use Const A.
Module U2 := Use Same A.

TypeScript Separate Extraction Use U1 U2.
