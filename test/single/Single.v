From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.

Fixpoint mirror {A} (t : tree A) : tree A :=
  match t with Leaf => Leaf | Node l x r => Node (mirror r) x (mirror l) end.

Redirect "Tree" TypeScript Extraction tree.
Redirect "Mirror" TypeScript Extraction mirror.
Redirect "Add" TypeScript Extraction Nat.add.
