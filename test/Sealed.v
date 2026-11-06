From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Parameter f : t -> t.
End S.

(* A functor sealed by a module type returns the interface of the module
   type, applied to the types its body defines, and only the members the
   module type lists; a member the body defines for itself alone is a
   local, and one that nothing needs is left out. *)
Module F (X : S) : S.
  Definition t := X.t.
  Definition helper (x : t) : t := X.f (X.f x).
  Definition z := helper X.z.
  Definition f := helper.
  Definition unused : nat := 0.
End F.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition f (x : t) : t := x + 1.
End A.

(* An application sealed by a module type has the members of the module
   type, typed by the functor's result. *)
Module B : S := F A.

Definition w : B.t := B.f B.z.

(* An application of an unsealed functor, sealed by a module type, has
   the members of the module type, typed by the functor's result
   interface. *)
Module G (X : S).
  Definition t := X.t.
  Definition z := X.z.
  Definition f := X.f.
  Definition extra := X.z.
End G.

Module C : S := G A.

Definition u : C.t := C.f C.z.

(* A body that defines the abstract type as an inductive, sealed by a
   module type with a constraint. *)
Module Type BOX.
  Parameter t : Type.
  Parameter box : Type.
  Parameter wrap : t -> box.
  Parameter unwrap : box -> t.
End BOX.

Module Boxes (X : S) : BOX with Definition t := X.t.
  Definition t := X.t.
  Inductive cell := Full (x : t) | Empty.
  Definition box := cell.
  Definition wrap (x : t) : box := Full x.
  Definition unwrap (b : box) : t := match b with Full x => x | Empty => X.z end.
End Boxes.

Module BA : BOX with Definition t := nat := Boxes A.

Definition v : nat := BA.unwrap (BA.wrap 3).

TypeScript Extraction "sealed.ts" F B G C Boxes BA w u v.
