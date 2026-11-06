From Stdlib Require Import ZArith.BinInt Lists.List.
Local Open Scope Z_scope.

(** Bit [i] records whether a subset of the nonnegative weights sums to [i]. *)
Fixpoint subset_sums (weights : list Z) (reachable : Z) : Z :=
  match weights with
  | nil => reachable
  | cons weight rest =>
    subset_sums rest (Z.lor reachable (Z.shiftl reachable weight))
  end.

Example subset_sums_2_3 : subset_sums (cons 2 (cons 3 nil)) 1 = 45 := eq_refl.
