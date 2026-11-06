From TypeScriptExtraction Require Import Number.
From NamingLibs Require Import Shapes.

(* The file of the library Shapes is shapes.ts, a file name, and its
   import alias, an identifier, is $Forms. *)
Definition corners (p : polygon) : nat := sides p.

TypeScript Separate Extraction corners.
