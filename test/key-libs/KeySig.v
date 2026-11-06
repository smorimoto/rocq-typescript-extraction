From TypeScriptExtraction Require Import Number.

Module Type MAP.
  Parameter t : Type -> Type.
  Parameter empty : forall A, t A.
  Parameter set : forall A, nat -> A -> t A -> t A.
  Parameter get : forall A, nat -> t A -> option A.
End MAP.
