From TypeScriptExtraction Require Import BigInt.
Open Scope list_scope.
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive color := Red | Blue.

Definition palette : list (nat * color) := (1, Red) :: (2, Blue) :: nil.

Record swatch := { number : nat; shade : color }.
Definition swatches : list swatch :=
  {| number := 1; shade := Red |} :: {| number := 2; shade := Blue |} :: nil.

TypeScript Extraction "nested-constructor-inference.ts" palette swatches.
