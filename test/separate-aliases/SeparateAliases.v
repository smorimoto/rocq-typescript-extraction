From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Figures Require Import Plane.

Module Fig := Figure.

Definition unit_area : nat := Fig.area (Fig.Square 1).
Definition scaled (s : Fig.t) (k : nat) : nat := k * Fig.area s.

TypeScript Separate Extraction Fig scaled unit_area.
