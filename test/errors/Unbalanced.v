From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* The printer reads the structure of TypeScript code from its brackets and
   quotes, so code that does not balance them is rejected. *)
Parameter weight : nat -> nat.
Extract Constant weight => "(".
Definition heavy := weight 2.
Fail TypeScript Recursive Extraction heavy.

Extract Inductive option => "Option" [ "undefined" "((x: A): Option => x)" ] "(o".
Definition get (o : option nat) := match o with Some n => n | None => 0 end.
Fail TypeScript Recursive Extraction get.
