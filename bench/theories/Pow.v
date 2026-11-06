From Stdlib Require Import NArith.BinNat setoid_ring.Ring_theory.

Definition pow_bin : nat -> N -> nat := @pow_N nat 1 Nat.mul.
