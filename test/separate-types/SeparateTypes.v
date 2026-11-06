From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimArray ListDef.

Definition same (n : nat) : nat := n.
Definition keep (a : array nat) : array nat := a.
Definition sames (l : list nat) : list nat := map same l.

TypeScript Separate Extraction same keep sames.
