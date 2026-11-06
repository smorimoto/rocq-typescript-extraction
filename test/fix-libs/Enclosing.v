From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module Nest (X : S).
  Module AsOuter (Y : S) := X.
End Nest.
