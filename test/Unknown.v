From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition dep (b : bool) : (if b then nat else bool) :=
  match b with true => 0 | false => false end.

Definition from_false (f : False) : nat := match f with end.

Definition fallback (f : False) : nat := from_false f.

Definition pr : True := I.

Definition size_of {A : Type} (x : A) : nat := 0.
Extraction NoInline size_of.

Definition sized : nat := size_of I.

Definition proofs : list True := I :: I :: nil.

TypeScript Extraction "unknown.ts" dep from_false fallback pr sized proofs.
