From TypeScriptExtraction Require Import Number.

Record point := { px : nat; py : nat }.

Definition origin : point := {| px := 0; py := 0 |}.
