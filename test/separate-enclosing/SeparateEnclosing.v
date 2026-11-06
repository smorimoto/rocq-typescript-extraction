From TypeScriptExtraction Require Import Number.
From FixLibs Require Import Enclosing.

Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module NA := Nest A.
Module AO := NA.AsOuter A2.
Definition oz : nat := AO.z.

TypeScript Separate Extraction NA AO oz.
