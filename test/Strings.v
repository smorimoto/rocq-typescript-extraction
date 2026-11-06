From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From TypeScriptExtraction Require Import ExtrTsPString.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimInt63 PrimString.

Definition latin := "héllo"%pstring.

TypeScript Extraction "strings.ts"
  max_length make length get sub cat compare eqb latin.
