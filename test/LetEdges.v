From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* A local whose only parameter extraction erased takes none, and a type
   argument that nothing constrains is never. *)
Definition empty_pair : list nat * list bool := let e := @nil in (e nat, e bool).

TypeScript Extraction "let-edges.ts" empty_pair.
