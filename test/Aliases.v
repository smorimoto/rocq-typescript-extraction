From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Figure.
  Inductive t := Circle (r : nat) | Square (side : nat).
  Definition unit : t := Square 1.
  Definition area (s : t) : nat :=
    match s with Circle r => 3 * r * r | Square n => n * n end.
  Module Metrics.
    Record box := { width : nat; height : nat }.
    Definition perimeter (b : box) : nat := 2 * (width b + height b).
  End Metrics.
End Figure.

Module Fig := Figure.

Module Layout.
  Module M := Figure.Metrics.
  Definition frame : M.box := {| M.width := 2; M.height := 3 |}.
End Layout.

Definition doubled : Fig.t := Fig.Circle (2 * Fig.area Fig.unit).
Definition total : nat := Fig.area doubled + Layout.M.perimeter Layout.frame.

(* An alias of a module that holds an alias: a reference through both
   resolves to the module at the end of the chain. *)
Module D.
  Module E := Figure.
End D.
Module G := D.

Definition via : nat := G.E.area G.E.unit + G.E.Metrics.perimeter Layout.frame.

TypeScript Extraction "aliases.ts" Fig Layout total G via.
