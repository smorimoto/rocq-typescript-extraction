From TypeScriptExtraction Require Import Number ExtrTsPArray ExtrTsPString.
From Corelib Require Import PrimArray PrimString IntDef.
Set Warnings "+typescript-extraction-unchecked-casts,+extraction-axiom-to-realize".

Definition array_make := @PrimArray.make.
Definition byte_get := PrimString.get.
Definition byte_make := PrimString.make.
Definition bit_and := Z.land.
Definition bit_or := Z.lor.
Definition bit_xor := Z.lxor.

TypeScript Extraction "primitives.ts"
  array_make byte_get byte_make bit_and bit_or bit_xor.
