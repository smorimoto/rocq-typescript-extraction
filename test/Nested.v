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

(* A functor declared in the body of another is a generic arrow of its
   own, a member of the result, whose result interface takes the type
   parameters of both. *)
Module F (X : S).
  Module G (Y : T).
    Definition pair : X.t * Y.t := (X.next X.z, Y.y).
  End G.
  Module C.
    Definition t := bool.
    Definition y : t := true.
  End C.
  Module GC := G C.
  Definition both : X.t * bool := GC.pair.
End F.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := S n.
End A.

Module B := F A.

Definition v : nat * bool := B.both.

(* A functor defined as an application of another applies it to its
   arguments. *)
Module H (X : S) (Y : T).
  Definition step : X.t := X.next X.z.
  Definition other : Y.t := Y.y.
End H.

Module HA (Y : T) := H A Y.

Module D.
  Definition t := bool.
  Definition y : t := false.
End D.

Module HD := HA D.

Definition w : bool := HD.other.

(* A type of a functor declared in the body of another that names a type
   of the outer body takes the type parameters that one takes. *)
Module K (X : S).
  Definition u := X.t.
  Module G (Y : T).
    Inductive box := Box (x : u) (y : Y.t).
    Definition both : box := Box X.z Y.y.
  End G.
End K.

Module KB := K A.
Module KBD := KB.G D.

Definition boxed : KBD.box := KBD.both.

TypeScript Extraction "nested.ts" F B v HA HD w K boxed.
