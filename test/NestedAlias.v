From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* An alias in a functor body of a module nested in an application in the
   body. A member named like a method is bound from the nested module's
   object, MSet.Raw, not from the application's. *)
Module Type OT. Parameter t : Type. End OT.

Module Inner (X : OT).
  Module Raw.
    Definition concat (a b : list X.t) : list X.t := app a b.
  End Raw.
  Definition size (l : list X.t) : nat := length l.
End Inner.

Module Outer (X : OT).
  Module MSet := Inner X.
  Module Raw := MSet.Raw.
  Definition join (a b : list X.t) : list X.t := Raw.concat a b.
End Outer.

Module NatOT. Definition t := nat. End NatOT.
Module M := Outer NatOT.

Definition go : list nat := M.join (cons 1 nil) (cons 2 nil).

TypeScript Extraction "nested-alias.ts" Outer go.
