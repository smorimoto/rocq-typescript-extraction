From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive color := Red | Green | Blue.
Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.
Record point := { px : nat; py : nat }.
Fixpoint size {A} (t : tree A) : nat :=
  match t with Leaf => 0 | Node l _ r => S (size l + size r) end.
Fixpoint even (n : nat) : bool := match n with O => true | S n => odd n end
with odd (n : nat) : bool := match n with O => false | S n => even n end.
Definition compose {A B C} (g : B -> C) (f : A -> B) (x : A) : C := g (f x).
Definition swap (p : point) : point := {| px := py p; py := px p |}.
Definition bump (p : point) := let q := swap p in Node Leaf (px q) Leaf.
Module M. Definition two := 2. End M.
Definition four := M.two + M.two.

TypeScript Extraction "sample.ts"
  color tree point size even odd compose swap bump M four Nat.add.
