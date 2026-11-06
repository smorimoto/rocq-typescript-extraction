From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The function ignores the element, so extraction keeps no type for it.
   plain still has the declared arrow, and the value pins the argument. *)
Module Type C1.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
  Parameter map : forall A B, (A -> B) -> t A -> t B.
End C1.

Module Use (C : C1).
  Definition b : C.t bool := C.map nat bool (fun _ => true) (C.empty nat).
End Use.

Definition plain (f : nat -> bool) (n : nat) : bool := f n.
Definition gone : bool := plain (fun _ => true) 0.

TypeScript Extraction "ignored-element.ts" Use plain gone.
