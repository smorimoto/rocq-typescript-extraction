From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module F (X : S).
  Module G (Y : S).
    Inductive box := Box (x : X.t) (y : Y.t).
    Definition both : box := Box X.z Y.z.
  End G.
  Module G2 (Y : S) (W : S).
    Definition three : X.t * Y.t * W.t := (X.z, Y.z, W.z).
  End G2.
End F.

Module A. Definition t := nat. Definition z : t := 1. End A.
Module B := F A.

Module Type FT (X : S).
  Module G (Y : S).
    Inductive box := Box (x : X.t) (y : Y.t).
    Parameter both : box.
  End G.
End FT.
