From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A constructor that ignores the functor argument is a function the
   scoping rule moves out of the arrow. *)
Module Type SIG.
  Parameter t : Type.
End SIG.

Module F (X : SIG).
  Inductive raw := C (n : nat) | Stop.
  Definition z : raw := C 1.
End F.

Module A.
  Definition t := nat.
End A.

Module B := F A.
Definition got := B.z.

TypeScript Extraction "constructor-scope.ts" F B got.
