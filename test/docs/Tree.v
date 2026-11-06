From TypeScriptExtraction Require Import Number.

Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.

Fixpoint size {A} (t : tree A) : nat :=
  match t with Leaf => 0 | Node l _ r => S (size l + size r) end.

TypeScript Extraction "tree.ts" size.
