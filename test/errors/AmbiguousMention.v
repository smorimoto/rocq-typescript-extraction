From TypeScriptExtraction Require Import Number.
From Shapes Require Points Grid.

(* The code of route mentions Point, which this library does not declare
   and which points.ts and grid.ts both do, so the backend cannot tell
   which file the code refers to. *)
Axiom route : Type.
Extract Inlined Constant route => "readonly Point[]".

Definition both (p : Points.point) (q : Grid.point) (r : route) : route := r.

Redirect "AmbiguousMention" Fail TypeScript Separate Extraction both.
