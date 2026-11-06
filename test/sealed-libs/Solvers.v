From TypeScriptExtraction Require Import Number.
From SealedLibs Require Import SolverSig.

Module Inner (X : LAT) : SOLVER with Module L := X.
  Module L := X.
  Definition run (n : nat) : L.t :=
    match n with O => L.bot | S _ => L.lub L.bot L.bot end.
End Inner.

Module Outer (Y : LAT) : SOLVER with Module L := Y.
  Module L := Y.
  Module DS := Inner L.
  Definition run (n : nat) : L.t := L.lub (DS.run n) L.bot.
End Outer.
