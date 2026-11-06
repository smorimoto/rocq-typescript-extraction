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

(* A partial application of a functor with several parameters is a
   generic arrow over the parameters left, and applying it applies the
   rest. A type of the body is aliased by an application headed by the
   partial application as by one of the functor itself. *)
Module G (X : S) (Y : T).
  Inductive w := W (x : X.t) | V (y : Y.t).
  Definition step : X.t := X.next X.z.
  Definition other : Y.t := Y.y.
  Definition wrapped : w := W step.
End G.

Module G3 (X : S) (Y : T) (Z : S).
  Inductive w := W (x : X.t) | U (z : Z.t).
  Definition last : w := U Z.z.
End G3.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := S n.
End A.

Module C.
  Definition t := bool.
  Definition y : t := true.
End C.

Module P := G A.
Module D := P C.
Module P3 := G3 A.
Module D3 := P3 C A.

Definition is_w (d : D.w) : bool := match d with D.W _ => true | D.V _ => false end.

(* An application in a module to a module nested in it reads the flat
   object of the nested module. *)
Module F (X : S).
  Definition twice (x : X.t) : X.t := X.next (X.next x).
End F.

Module M.
  Module Inner.
    Definition t := nat.
    Definition z : t := 1.
    Definition next (n : t) : t := S n.
  End Inner.
  Module B := F Inner.
  Definition three : nat := B.twice Inner.z.
End M.

(* A module and its module type tag a constructor the same whatever the
   order of their inductives. *)
Module Type TAGGED.
  Parameter t : Type.
  Inductive w := Wrap (x : t) | Other.
  Inductive wrap := Mk (y : t).
  Parameter z : w.
End TAGGED.

Module Tagged.
  Definition t := nat.
  Inductive wrap := Mk (y : t).
  Inductive w := Wrap (x : t) | Other.
  Definition z : w := Wrap 1.
End Tagged.

Module Pick (X : TAGGED).
  Definition v : option X.t := match X.z with X.Wrap x => Some x | X.Other => None end.
End Pick.

Module PT := Pick Tagged.

Definition n : nat := D.step + M.three.

TypeScript Extraction "left-out.ts" G P D D3 M PT n is_w.
