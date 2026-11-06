From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* Only figure is asked for. Its constructor interfaces and constructor
   functions come with it, and so do nat, which a constructor's property
   names, and nat's constructors. *)
Inductive figure := Dot | Line (n : nat) | Box (w h : nat).

TypeScript Extraction "type-exports.ts" figure.
