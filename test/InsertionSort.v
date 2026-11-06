From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
Local Open Scope list_scope.

Fixpoint insert (x : nat) (l : list nat) : list nat :=
  match l with
  | nil => x :: nil
  | y :: l' => if Nat.leb x y then x :: l else y :: insert x l'
  end.

Fixpoint insertion_sort (l : list nat) : list nat :=
  match l with
  | nil => nil
  | x :: l' => insert x (insertion_sort l')
  end.

TypeScript Extraction "insertion-sort.ts" insertion_sort.
