From TypeScriptExtraction Require Import BigInt.
From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import BinNums.PosDef BinNums.IntDef.

Definition from_positive := Pos.to_nat.
Definition from_integer := Z.to_nat.
Definition to_positive := Pos.of_succ_nat.
Definition to_integer := Z.of_nat.
Definition add := Nat.add.
Definition nat_even := Nat.even.
Definition nat_odd := Nat.odd.
Definition nat_div2 := Nat.div2.
Definition nat_pow := Nat.pow.

TypeScript Extraction "big-int-number.ts"
  from_positive from_integer to_positive to_integer add nat_even nat_odd nat_div2 nat_pow.
