From TypeScriptExtraction Require Import Number.

Record point := { px : nat; py : nat }.

Inductive segment := Segment (a b : point).
Extract Inductive segment => "readonly [Point, Point]"
  [ "((a: Point, b: Point): readonly [Point, Point] => [a, b])" ]
  "(<R>(f: (a: Point, b: Point) => R, line: readonly [Point, Point]): R => f(line[0], line[1]))".
