From TypeScriptExtraction Require Import BigInt.
From Stdlib Require Import ZArith.

Definition naturals := (0, 1, 17).
Definition positive_value : positive := 9007199254740993%positive.
Definition natural_value : N := 18446744073709551617%N.
Definition integer_value : Z := (-18446744073709551617)%Z.
Definition dynamic_successor (n : nat) := S n.

Inductive shifted := Zero | Next (p : shifted).
Extract Inductive shifted => "bigint"
  [ "0n" "((n: bigint): bigint => n + 2n)" ].
Definition shifted_three := Next (Next (Next Zero)).

TypeScript Extraction "numeric-constants.ts"
  naturals positive_value natural_value integer_value dynamic_successor shifted_three.
