From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.
Module M. Definition t := nat. Definition z : t := 0. End M.

(* A functor defined as a module returns the module's object, typed by
   the interface of the functor's result signature; one defined as its
   parameter returns the parameter, typed by its interface; one sealed by
   a module type returns the module, typed by the module type's. A
   parameter the arrow never reads is marked unused. *)
Module G (Y : SIG) := M.
Module Id (Y : SIG) := Y.
Module GS (Y : SIG) : SIG := M.

(* An application aliases the types of the module it reaches: the
   functor's module, or the argument of a functor defined as its
   parameter. *)
Module A. Definition t := bool. Definition z : t := true. End A.
Module GA := G A.
Module IA := Id A.
Module GSA := GS A.

Definition both : GA.t * IA.t := (GA.z, IA.z).

TypeScript Extraction "functor-as-module.ts" G Id GS GA IA GSA both.
