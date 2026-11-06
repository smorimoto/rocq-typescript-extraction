From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Module Geometry.
  Inductive figure := Circle (r : nat) | Square (s : nat).
  Definition scale (k : nat) (s : figure) : figure :=
    match s with Circle r => Circle (k * r) | Square n => Square (k * n) end.
  Module Units.
    Definition unit_circle : figure := Circle 1.
    Record box := { width : nat; height : nat }.
    Definition unit_box : box := {| width := 1; height := 2 |}.
  End Units.
End Geometry.

Module Areas.
  Definition side (s : Geometry.figure) : nat :=
    match s with Geometry.Circle r => r | Geometry.Square n => n end.
  Definition doubled : Geometry.figure := Geometry.scale 2 Geometry.Units.unit_circle.
  Definition box_area (b : Geometry.Units.box) : nat :=
    Geometry.Units.width b * Geometry.Units.height b.
End Areas.

Module Type SIZED. Parameter size : nat. End SIZED.
Module Ten : SIZED. Definition size := 10. End Ten.

Definition total : nat :=
  Areas.side Areas.doubled + Areas.box_area Geometry.Units.unit_box + Ten.size.

TypeScript Extraction "modules.ts" Geometry Areas Ten total.
