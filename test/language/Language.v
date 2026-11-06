From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Module Counter.
  Definition start : nat := 0.
  Definition step (n : nat) : nat := S n.
End Counter.

(* Extraction expands a module expression for Haskell, so Same is an alias
   of Counter only in the MiniML produced for OCaml. *)
Module Same := Counter.

Extraction Language Haskell.

TypeScript Extraction "counter.ts" Same.
Redirect "Counter" TypeScript Extraction Same.
TypeScript Separate Extraction Same.

(* Each command restores the language, so this extraction is Haskell. *)
Redirect "Haskell" Extraction Counter.step.
