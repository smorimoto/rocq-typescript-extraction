From TypeScriptExtraction Require Import Number.

(* A second point, whose interface is named Point in grid.ts as the one of
   Points is in points.ts. *)
Record point := { col : nat; row : nat }.
