From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Extraction Output Directory ".".

(* A functor defined as another functor returns a functor, which has no
   TypeScript form. *)
Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.
Module F (X : SIG). Definition w : X.t := X.z. End F.
Module G (Y : SIG) := F.

Redirect "FunctorAsFunctor" Fail TypeScript Extraction "functor-as-functor.ts" G.
