From TypeScriptExtraction Require Import Number.
From KnownLibs Require Import Origin.

(* An imported const keeps its declared type, which TypeScript does not
   narrow, so a match on it stays whole; a const of this file is
   narrowed, so a match on it is its branch. *)
Definition from_origin : nat := match origin with Dot => 0 | Line n => n end.

Definition dot : figure := Dot.

Definition from_dot : nat := match dot with Dot => 0 | Line n => n end.

TypeScript Separate Extraction from_origin from_dot.
