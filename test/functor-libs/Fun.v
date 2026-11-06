From TypeScriptExtraction Require Import Number.
From FunctorLibs Require Import Sig.

Module F (X : S).
  Inductive box := Full (x : X.t) | Empty.
  Definition twice (x : X.t) : X.t := X.next (X.next x).
  Definition mapped : X.t := X.map X.next X.z.
  Definition fill (x : X.t) : box := Full x.
  Definition map (f : X.t -> X.t) (b : box) : box :=
    match b with Full x => Full (f x) | Empty => Empty end.
End F.

Module Type FT (X : S).
  Parameter twice : X.t -> X.t.
End FT.
