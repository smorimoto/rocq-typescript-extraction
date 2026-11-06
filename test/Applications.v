From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Parameter next : t -> t.
End S.

Module Type T.
  Parameter t : Type.
  Parameter y : t.
End T.

Module F (X : S).
  Inductive wrapped := Wrap (x : X.t) | Empty.
  Definition w : wrapped := Wrap X.z.
  Definition unwrap (d : wrapped) : X.t := match d with Wrap x => x | Empty => X.z end.
  Definition twice (x : X.t) : X.t := X.next (X.next x).
End F.

(* Two parameters, applied one at a time. *)
Module G (X : S) (Y : T).
  Definition step : X.t := X.next X.z.
  Definition other : Y.t := Y.y.
End G.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := n + 1.
End A.

Module C.
  Definition t := bool.
  Definition y : t := true.
End C.

Module Holder.
  Module Id (X : S). Definition same : X.t := X.z. End Id.
  Module B := Id A.
End Holder.

Module B := F A.
Module D := G A C.

Definition v : nat := B.unwrap B.w.
Definition three : B.wrapped := B.Wrap 3.
Definition count (d : B.wrapped) : nat := match d with B.Wrap x => B.twice x | B.Empty => D.step end.
Definition same : nat := Holder.B.same.

TypeScript Extraction "applications.ts" B D Holder v three count same.
