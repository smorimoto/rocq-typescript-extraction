From Stdlib Require Import Sorting.Mergesort Arith.PeanoNat.

Module Nat_order.
  Definition t := nat.
  Definition leb := Nat.leb.
  Lemma leb_total : forall x y, leb x y = true \/ leb y x = true.
  Proof. intros x y; unfold leb; rewrite !Nat.leb_le; apply Nat.le_ge_cases. Qed.
End Nat_order.

Module Nat_sort.
  Include Mergesort.Sort Nat_order.
End Nat_sort.

Definition merge_sort := Nat_sort.sort.
