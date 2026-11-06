From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A constructor the command names asks for its constructor function,
   and a constructor of a mapped type asks for its realiser. The function
   builds a value of figure, so its signature exports the type, its
   constructor interfaces, and the other constructor functions, which
   build its values. *)
Inductive figure := Dot | Line (n : nat) | Box (w h : nat).

(* A const of a union type initialised by a constructor call keeps the
   union, since the call returns it, so a match on the const typechecks. *)
Inductive tile := Circle (r : nat) | Square (s : nat).
Definition sq := Square 2.
Definition area := match sq with Circle r => r | Square s => s * s end.

TypeScript Extraction "constructors.ts" Line S area.
