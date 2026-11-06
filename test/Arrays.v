From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From TypeScriptExtraction Require Import ExtrTsPArray.
Set Warnings "+typescript-extraction-unchecked-casts,+extraction-axiom-to-realize".
From Corelib Require Import PrimInt63 PrimArray.

Open Scope uint63_scope.

Definition digits : array int := [| 1; 2; 3 | 0 |].
Definition bumped : array int := set digits 1 9.
Definition third : int := get digits 2.
Definition beyond : int := get digits 5.

TypeScript Extraction "arrays.ts"
  max_length make get default set length copy digits bumped third beyond.
