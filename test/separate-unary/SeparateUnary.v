From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition below := Nat.leb.
Definition strictly_below (left right : nat) := Nat.leb (S left) right.

TypeScript Separate Extraction below strictly_below Nat.leb Nat.ltb.
