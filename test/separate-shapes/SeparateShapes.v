From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Shapes Require Import Points Paths.

Definition origin : point := {| px := 0; py := 0 |}.
Definition diagonal : segment := Segment origin {| px := 1; py := 1 |}.
Definition width (s : segment) : nat := match s with Segment a b => px b - px a end.
Definition ends (s : segment) : outline := corners s.
Definition traced (s : segment) : polyline := trace s.

TypeScript Separate Extraction diagonal width ends traced.
