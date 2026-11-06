From TypeScriptExtraction Require Import Number.

Record point := { px : nat; py : nat }.

Definition swap (p : point) : point := {| px := py p; py := px p |}.

TypeScript Extraction "point.ts" swap.
