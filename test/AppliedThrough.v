From TypeScriptExtraction Require Import Number.

(* A functor declared in the body of another is applied through an
   application of the outer one, at any depth, with the type arguments
   of its own parameters. *)

Module Type S. Parameter t : Type. Parameter z : t. End S.
Module F (X : S).
  Module G (Y : S).
    Inductive box := Box (x : X.t) (y : Y.t).
    Definition both : box := Box X.z Y.z.
    Module H (W : S).
      Definition three : X.t * Y.t * W.t := (X.z, Y.z, W.z).
    End H.
  End G.
End F.
Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module B := F A.
Module C := B.G A2.
Module D := C.H A.
Definition fromC : C.box := C.both.
Definition fromD : nat * bool * nat := D.three.

(* A partial application of a functor reached through an application,
   which an application of its own completes. *)
Module F2 (X : S).
  Module G2 (Y : S) (W : S).
    Definition three : X.t * Y.t * W.t := (X.z, Y.z, W.z).
  End G2.
End F2.
Module B2 := F2 A.
Module P := B2.G2 A2.
Module Q := P A.
Definition fromQ : nat * bool * nat := Q.three.

(* A functor declared in a functor signature, applied through an
   application of a parameter declared with the signature. *)
Module Type FT (X : S).
  Module G (Y : S).
    Inductive box := Box (x : X.t) (y : Y.t).
    Parameter both : box.
  End G.
End FT.
Module Use (FF : FT) (X : S) (Y : S).
  Module FX := FF X.
  Module FXY := FX.G Y.
  Definition both : FXY.box := FXY.both.
End Use.
Module U := Use F A A2.
Definition fromU : U.FXY.box := U.both.

(* A functor declared in the module type of a parameter, applied through
   the parameter, and a functor sealed by that module type. *)
Module Type HAS.
  Parameter u : Type.
  Module G (Y : S).
    Inductive box := Box (x : u) (y : Y.t).
    Parameter both : box.
  End G.
End HAS.
Module Through (X : HAS) (Y : S).
  Module XY := X.G Y.
  Definition both : XY.box := XY.both.
End Through.
Module K (Z : S) : HAS with Definition u := Z.t.
  Definition u := Z.t.
  Module G (Y : S).
    Inductive box := Box (x : Z.t) (y : Y.t).
    Definition both : box := Box Z.z Y.z.
  End G.
End K.
Module KA := K A.
Module T := Through KA A2.
Definition fromT : T.XY.box := T.both.

(* The same through a module nested in the module type. *)
Module Type HAS2.
  Parameter u : Type.
  Module Inner. Module G (Y : S). Parameter w : u * Y.t. End G. End Inner.
End HAS2.
Module Through2 (X : HAS2) (Y : S).
  Module XY := X.Inner.G Y.
  Definition w : X.u * Y.t := XY.w.
End Through2.

TypeScript Extraction "applied-through.ts"
  C D fromC fromD P Q fromQ Use U fromU Through K T fromT Through2.
