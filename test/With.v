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

(* A constraint on a parameter fixes the type parameter of its interface,
   so the functor is not generic over it and its application passes no
   type argument. *)
Module F (X : S with Definition t := nat).
  Definition twice (x : nat) : nat := X.next (X.next x) + 1.
  Definition zero : X.t := X.z.
End F.

(* A constraint naming the abstract type of an earlier parameter. *)
Module G (X : S) (Y : T with Definition t := X.t).
  Definition step : X.t := X.next Y.y.
End G.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := n + 1.
End A.

Module C.
  Definition t := nat.
  Definition y : t := 4.
End C.

Module B := F A.
Module D := G A C.

(* A module type defined with a constraint is an alias of the
   instantiated interface. *)
Module Type SN := S with Definition t := nat.
Module K (X : SN).
  Definition q : nat := X.next X.z.
End K.
Module KA := K A.

(* A module constraint fixes the abstract types of the nested module to
   those of the module it names, and the body reads that module's
   values. *)
Module Type SM.
  Parameter k : nat.
  Declare Module Inner : S.
End SM.

Module H (Y : SM with Module Inner := A).
  Definition w : nat := Y.Inner.next Y.k.
End H.

Module M.
  Definition k := 2.
  Module Inner := A.
End M.

Module HM := H M.

Definition n : nat := B.twice 1 + D.step + KA.q + HM.w.

TypeScript Extraction "with.ts" F G B D K KA H HM n.
