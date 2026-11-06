From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

Definition sizes : nat :=
  let size := fun (A B : Type) (_ : A * B) => 0 in
  size _ _ (@None bool, true) + size _ _ (Some 0, 0) + size _ _ (Some true, false).

TypeScript Extraction "casts.ts" sizes.
