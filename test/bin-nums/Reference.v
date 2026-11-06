From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From BinNumsOps Require Import Wrappers.

TypeScript Extraction "reference.ts" Ops.
