From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From ThroughLibs Require Import Outer AsModule.

Module A2. Definition t := bool. Definition z : t := true. End A2.

(* Applications of the functors of another file defined as a module and
   as their parameter, and a functor of this file defined as a module of
   another file. *)
Module GA := G A2.
Module IA := Id A2.
Module H (Y : S) := Outer.A.
Module HA := H A2.

Definition all : GA.t * IA.t * HA.t := (GA.z, IA.z, HA.z).

TypeScript Separate Extraction GA IA H HA all.
