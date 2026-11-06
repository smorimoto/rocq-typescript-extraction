From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimInt63 PrimFloat PrimString PrimArray.

Open Scope uint63_scope.

(* The four primitive types extract without a preset: the backend
   represents them, and their operations stay axioms. *)
Definition answer : int := 42.
Definition half : float := 0.5%float.
Definition hello : string := "hello"%pstring.
Definition digits : array int := [| 1; 2; 3 | 0 |].
Definition wrap {A} (x : A) : array A := [| | x |].
Definition nested : array (array int) := [| digits | wrap 0 |].
Definition plus_seven (x : int) : int := let y := 7 in PrimInt63.add x y.
Definition first (a : array int) : int := PrimArray.get a 0.

Record cell := { count : int; label : string }.
Definition three : cell := {| count := 3; label := "three"%pstring |}.

TypeScript Extraction "primitive-types.ts"
  answer half hello digits wrap nested plus_seven first three.

Set Warnings "+extraction-axiom-to-realize".
Fail TypeScript Recursive Extraction plus_seven.
Fail TypeScript Recursive Extraction first.
