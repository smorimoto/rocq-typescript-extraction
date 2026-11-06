From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module F (X : S).
  Module Nested (Y : S).
    Definition w : X.t * Y.t := (X.z, Y.z).
  End Nested.
End F.

Module FA (Y : S) := F Y.
