From Stdlib Require Import ZArith.BinInt ZArith.Zgcd_alt.
Local Open Scope nat_scope.

Fixpoint collatz (fuel : nat) (z : Z) : nat :=
  match fuel with
  | O => O
  | S fuel' =>
    if Z.eqb z (Zpos xH) then O
    else
      S (collatz fuel'
           (if Z.even z then Z.div2 z
            else Z.add (Z.mul (Zpos (xI xH)) z) (Zpos xH)))
  end.

Fixpoint collatz_from (fuel count : nat) (z : Z) : nat :=
  match count with
  | O => O
  | S count' => collatz fuel z + collatz_from fuel count' (Z.add z (Zpos xH))
  end.

Definition collatz_total (fuel count : nat) : nat :=
  collatz_from fuel count (Zpos xH).

Definition gcd := Zgcd_alt.

Example collatz_27 : collatz 200 (Z.of_nat 27) = 111 := eq_refl.
Example collatz_total_10 : collatz_total 100 10 = 67 := eq_refl.
Example gcd_1071_462 : gcd (Z.of_nat 1071) (Z.of_nat 462) = Z.of_nat 21 :=
  eq_refl.
