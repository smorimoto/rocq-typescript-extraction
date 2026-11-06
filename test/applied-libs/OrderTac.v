From TypeScriptExtraction Require Import Number.
From AppliedLibs Require Import OrderSig.

Module MakeTac (O : EqLe) (P : IsTotal O).
  Definition cmp (x y : O.t) : bool := orb (O.le x y) (P.le_total x y).
End MakeTac.
