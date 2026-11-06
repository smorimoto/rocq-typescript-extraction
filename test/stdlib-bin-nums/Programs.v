From Stdlib Require Import ZArith.
From TypeScriptExtraction Require Import BigInt.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition add := Z.add.
Definition mul := Z.mul.
Definition pow := Z.pow.
Definition div := Z.div.
Definition modulo := Z.modulo.
Definition quot := Z.quot.
Definition rem := Z.rem.
Definition of_nat := Z.of_nat.
Definition to_nat := Z.to_nat.
Definition pos_sub := Pos.sub.
Definition n_sub := N.sub.
Definition nat_add := Nat.add.

TypeScript Extraction "integers.ts"
  add mul pow div modulo quot rem of_nat to_nat pos_sub n_sub nat_add.
