From TypeScriptExtraction Require Import Number.
From Shapes Require Import Points.

(* The code of these types mentions Point, a type of points.ts. The code
   of their functions is generic, since paths.ts declares the functions,
   the code of a value is written as it is, and paths.ts declares no
   Point. *)
Axiom outline : Type.
Extract Inlined Constant outline => "readonly Point[]".
Axiom corners : segment -> outline.
Extract Constant corners => "<A>(line: readonly [A, A]): readonly A[] => line".

Axiom polyline : Type.
Extract Constant polyline => "readonly Point[]".
Axiom trace : segment -> polyline.
Extract Constant trace => "<A>(line: readonly [A, A]): readonly A[] => line".
