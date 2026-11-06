From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* Corelib's divmod behind Nat.div passes its divisor to every self call
   and reads it in one, so in a loop the divisor is a parameter that an
   assignment reads, and only-used-in-recursion has nothing to report. *)
Definition half (n : nat) : nat := Nat.div n 2.

TypeScript Extraction "peano-loops.ts" half.
