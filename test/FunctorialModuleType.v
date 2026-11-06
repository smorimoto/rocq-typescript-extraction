From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The same parameter type at the top level, applied to an application
   of the functor the module type includes. *)
Module Type LAT. Parameter t : Type. Parameter bot : t. End LAT.

Module Make (A : LAT).
  Definition get (_ : nat) : A.t := A.bot.
End Make.

Module Type T (A : LAT).
  Include (Make A).
End T.

Module Use (A : LAT) (I : T A).
  Definition run (n : nat) : A.t := I.get n.
End Use.

Module NatLat. Definition t := nat. Definition bot := 9. End NatLat.
Module M := Make NatLat.
Module U := Use NatLat M.

Definition go : nat := U.run 3.

TypeScript Extraction "functorial-module-type.ts" Use go.
