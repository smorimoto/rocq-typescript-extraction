From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Only the application is asked for. It exports its functor, whose
   signature exports the module type and the result interface, and the
   aliases of its types; the module it is applied to stays private. *)
Module Type S. Parameter t : Type. Parameter z : t. End S.
Module F (X : S).
  Inductive box := Cell (x : X.t).
  Definition w : box := Cell X.z.
End F.
Module A. Definition t := nat. Definition z : t := 0. End A.
Module B := F A.

TypeScript Extraction "exported-application.ts" B.
