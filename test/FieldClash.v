From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A field z beside a constructor Z. The field is the definition, C 4,
   and the constructor takes the suffix. *)
Module Type SIG.
  Parameter t : Type.
  Parameter z : t.
End SIG.

Module M <: SIG.
  Inductive raw := C (n : nat) | Z.
  Definition t := raw.
  Definition z : t := C 4.
End M.

Module F (X : SIG).
  Definition z : X.t := X.z.
End F.

Module B := F M.
Definition got := B.z.

TypeScript Extraction "field-clash.ts" F B got.
