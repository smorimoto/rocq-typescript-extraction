From TypeScriptExtraction Require Import Number.
From Corelib Require Import BinNums IntDef.
Set Warnings "+typescript-extraction-unchecked-casts".

Fixpoint sum_right (xs : list Z) : Z :=
  match xs with nil => Z0 | cons x rest => Z.add x (sum_right rest) end.

TypeScript Extraction "number-accumulators.ts" sum_right.
