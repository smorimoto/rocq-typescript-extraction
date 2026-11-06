From TypeScriptExtraction Require Import Number.

Record points_and_more := { px : nat; py : nat }.

Axiom outline : Type.
Extract Inlined Constant outline => "readonly PointsAndMore[]".

Axiom corners : points_and_more * points_and_more -> outline.
Extract Constant corners => "<A>(line: readonly [A, A]): readonly A[] => [...line]".

Record ends_type := { left : points_and_more; right : points_and_more }.

Axiom corners_record : points_and_more * points_and_more -> ends_type.
Extract Constant corners_record =>
"<A>(line: readonly [A, A]) => ({ left: line[0], right: line[1] })".

Definition use (p : points_and_more) := corners (p, p).
Definition use_record (p : points_and_more) := corners_record (p, p).

TypeScript Extraction "gap-again.ts" use use_record.
