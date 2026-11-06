From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From TypeScriptExtraction Require Import ExtrTsPArray.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimInt63 PrimArray.

Open Scope uint63_scope.

Module PA := PrimArray.

Definition zeros (n : int) : array int := PA.make n 0.
Definition first (a : array int) : int := PA.get a 0.

TypeScript Separate Extraction zeros first.
