From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
Open Scope list_scope.

(* The module type names set, which a reserved word turns into set0, and
   the module has a set0 of its own. Both key set the same, so the
   functor calls the module's set. *)
Module Type S.
  Parameter t : Type.
  Parameter set : nat -> t -> t.
End S.

Module M <: S.
  Definition t := list nat.
  Definition set0 (n : nat) : t := n :: nil.
  Definition set (n : nat) (l : t) : t := n :: n :: l.
End M.

Module F (X : S).
  Definition go (l : X.t) : X.t := X.set 1 l.
End F.

Module G := F M.

Definition go : list nat := G.go (5 :: nil).

TypeScript Extraction "signature-rename.ts" M F go.
