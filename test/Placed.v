From TypeScriptExtraction Require Import Number.

(* A nested functor reached through a functor defined as an application
   is that nested functor, applied to the same arguments. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module F (X : S).
  Module Nested (Y : S).
    Definition w : X.t * Y.t := (X.z, Y.z).
  End Nested.
End F.
Module FA (Y : S) := F Y.
Module C := FA A.
Module CN := C.Nested A2.
Definition w : nat * bool := CN.w.

TypeScript Extraction "placed.ts" FA C CN w.
