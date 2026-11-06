From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

Module Nest (X : S).
  Module Inner. Definition t := nat. Definition z : t := 4. End Inner.
  Module AsNested (Y : S) := Inner.
End Nest.
