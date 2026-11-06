From TypeScriptExtraction Require Import Number.
From Stdlib Require Import ZArith.

Definition naturals := (0, 1, 17).
Definition positive_value : positive := 9007199254740991%positive.
Definition rounded_value : positive := 9007199254740993%positive.
Definition natural_value : N := 65537%N.
Definition integer_value : Z := (-65537)%Z.
Definition dynamic_successor (n : nat) := S n.

Inductive shifted := Zero | Next (p : shifted).
Extract Inductive shifted => "number"
  [ "0" "((n: number): number => n + 2)" ].
Definition shifted_three := Next (Next (Next Zero)).

Inductive signed_zero := Zero_z | Neg_z (p : signed_zero) | Double_z (p : signed_zero).
Extract Inductive signed_zero => "number"
  [ "0" "((p: number): number => -p)" "((p: number): number => 2 * p)" ].
Definition negative_zero := Neg_z Zero_z.
Definition doubled_negative_zero := Double_z (Neg_z Zero_z).
Definition restored_zero := Neg_z (Neg_z Zero_z).

TypeScript Extraction "numeric-constants-number.ts"
  naturals positive_value rounded_value natural_value integer_value
  dynamic_successor shifted_three negative_zero doubled_negative_zero restored_zero.
