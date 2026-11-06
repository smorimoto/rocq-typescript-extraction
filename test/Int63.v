From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From TypeScriptExtraction Require Import ExtrTsInt63.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimInt63.

TypeScript Extraction "int63.ts"
  lsl lsr asr land lor lxor add sub mul mulc div mod divs mods eqb ltb leb ltsb lesb
  addc addcarryc subc subcarryc diveucl diveucl_21 addmuldiv compare compares head0
  tail0.
