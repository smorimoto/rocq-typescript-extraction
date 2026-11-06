From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Record point := { px : nat; py : nat }.

(* Each type below is mapped to code that mentions Point, and the
   signatures name Point only through that code, so it is exported
   because the code mentions it. *)
Inductive segment := Segment (a b : point).
Extract Inductive segment => "readonly [Point, Point]"
  [ "((a: Point, b: Point): readonly [Point, Point] => [a, b])" ]
  "(<R>(f: (a: Point, b: Point) => R, line: readonly [Point, Point]): R => f(line[0], line[1]))".

Axiom outline : Type.
Extract Inlined Constant outline => "readonly Point[]".
Axiom corners : segment -> outline.
Extract Constant corners => "(line: readonly [Point, Point]): readonly Point[] => [...line]".

Definition origin : point := {| px := 0; py := 0 |}.
Definition diagonal : segment := Segment origin {| px := 1; py := 1 |}.
Definition width (s : segment) : nat := match s with Segment a b => px b - px a end.
Definition ends (s : segment) : outline := corners s.

TypeScript Extraction "mapped-types.ts" diagonal width ends.
