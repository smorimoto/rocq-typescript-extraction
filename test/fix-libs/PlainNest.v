From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module F (X : S).
  Module Nested (Y : S).
    Definition twice (n : nat) : nat := n + n.
  End Nested.
End F.
