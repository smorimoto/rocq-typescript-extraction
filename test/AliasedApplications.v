From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Module N. Parameter n : t. End N.
End S.

Module A.
  Definition t := nat.
  Definition z : t := 1.
  Module N. Definition n : t := 2. End N.
End A.

Module Q. Definition q : nat := 7. End Q.

Module F (X : S).
  Inductive wrapped := Wrap (x : X.t) | Empty.
  Definition w : X.t := X.z.
  Module Inner. Definition k : X.t := X.N.n. End Inner.
End F.

(* An alias of an application, an alias of that alias, and an alias of a
   functor, applied. *)
Module B := F A.
Module B' := B.
Module B'' := B'.
Module G := F.
Module GA := G A.

(* Aliases in a functor body of each module it can name: a module of the
   body, the parameter and a module of it, an application in the body and
   a module of it, an application outside, and a plain module outside. *)
Module H (X : S).
  Module M.
    Inductive b := Bx (x : X.t) | By.
    Definition q : X.t := X.z.
  End M.
  Module M' := M.
  Module Y := X.
  Module YN := X.N.
  Module C := F X.
  Module C' := C.
  Module CI := C.Inner.
  Module B2 := B.
  Module Q2 := Q.
  Definition r : X.t := M'.q.
  Definition both : X.t * nat := (C'.w, B2.w + Q2.q).
End H.

Module HA := H A.

Definition through : nat := B''.w + GA.w + B'.Inner.k.
Definition wrapped : B''.wrapped := B'.Wrap 2.
Definition members : nat :=
  HA.M'.q + HA.Y.z + HA.YN.n + HA.C'.w + HA.CI.k + HA.B2.w + HA.Q2.q.
Definition built : HA.M'.b := HA.M'.Bx 3.
Definition boxed : HA.C'.wrapped := HA.C'.Wrap 4.

TypeScript Extraction "aliased-applications.ts"
  B' B'' G H HA through wrapped members built boxed.
