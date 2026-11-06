From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From Corelib Require Import PrimInt63 PrimArray.

Open Scope uint63_scope.

(* A primitive array literal is the backend's PArray<A>, which a mapping
   of array replaces. *)
Extract Constant PrimArray.array "a" => "readonly a[]".
Definition digits : array int := [| 1; 2 | 0 |].

Fail TypeScript Recursive Extraction digits.
