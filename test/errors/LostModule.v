From TypeScriptExtraction Require Import Number.
Set Extraction Output Directory ".".

Module Type ACTION.
  Parameter action : (forall A : Type, list A) -> nat.
End ACTION.

Module Consume (X : ACTION).
  Definition run := X.action.
End Consume.

(* Module-type fields need not be registered in the global name table.
   The diagnostic must still identify the field with an unsupported type. *)
Redirect "LostModule" Fail TypeScript Extraction "lost-module.ts" Consume.
