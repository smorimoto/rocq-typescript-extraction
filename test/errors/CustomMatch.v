From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* A constructor with arguments cannot be told apart without a match
   function in TypeScript. *)
Extract Inductive option => "Option" [ "Some" "None" ].
Definition get (o : option nat) := match o with Some n => n | None => 0 end.

Fail TypeScript Recursive Extraction get.
