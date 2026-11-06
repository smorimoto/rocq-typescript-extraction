From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Ranges Require Import Spans.

Definition clamp (b : bounds) : span := Span b.
Definition low (r : span) : nat := match r with Span b => lo b end.
Definition wrap_low (r : span) : wrapped nat := Wrap nat (low r).
Definition unwrap {A} (w : wrapped A) : A := match w with Wrap _ x => x end.

TypeScript Separate Extraction clamp low wrap_low unwrap cell.
