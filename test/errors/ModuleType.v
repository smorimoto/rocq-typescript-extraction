From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Extraction Output Directory ".".

(* A module type has no value, so the command cannot name one; its
   interface is declared with a functor that takes it or a module sealed
   by it. *)
Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.

Redirect "ModuleType" Fail TypeScript Extraction "module-type.ts" SIG.
