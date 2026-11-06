From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A module type that includes a functor applied to its parameter, used
   for a parameter of a functor that another applies in its body, as
   MenhirLib's parser does. *)
Module Type LAT. Parameter t : Type. Parameter bot : t. End LAT.

Module Make (A : LAT).
  Definition get (_ : nat) : A.t := A.bot.
End Make.

Module Type T (A : LAT).
  Include (Make A).
End T.

Module Correct (A : LAT) (I : T A).
  Definition checked (n : nat) : A.t := I.get n.
End Correct.

Module Main (A : LAT).
  Module I := Make A.
  Module C := Correct A I.
  Definition run (n : nat) : A.t := C.checked n.
End Main.

Module NatLat. Definition t := nat. Definition bot := 8. End NatLat.
Module M := Main NatLat.

Definition go : nat := M.run 3.

TypeScript Extraction "functorial-type-applied.ts" Correct Main go.
