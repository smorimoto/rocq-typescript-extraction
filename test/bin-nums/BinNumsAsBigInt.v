From TypeScriptExtraction Require Import Number ExtrTsBinNumsBigInt.
Set Warnings "+typescript-extraction-unchecked-casts".
From BinNumsOps Require Import Wrappers.

TypeScript Extraction "bin-nums-as-big-int.ts"
  Ops.pos_to_nat Ops.pos_of_succ_nat Ops.z_to_nat Ops.z_of_nat.
