From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type BASE.
  Parameter t : Type.
  Parameter value : t.
End BASE.

Module Type WRAPPED.
  Declare Module Base : BASE.
  Inductive wrapper := Empty | Wrapped (value : Base.t).
End WRAPPED.

Module Use (W : WRAPPED).
  (* The dependency on Base.t is reached through W.wrapper. *)
  Inductive result := NoResult | Result (value : W.wrapper).

  (* A reference below a functor parameter still captures that parameter. *)
  Definition read (_ : nat) : W.Base.t := W.Base.value.
End Use.

Module Values.
  Module Base.
    Definition t := nat.
    Definition value : t := 13.
  End Base.
  Inductive wrapper := Empty | Wrapped (value : Base.t).
End Values.

Module Applied := Use Values.

TypeScript Extraction "nested-type-dependencies.ts" Use Values Applied.
