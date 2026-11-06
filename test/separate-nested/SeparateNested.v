From TypeScriptExtraction Require Import Number.
From FixLibs Require Import NestedMod.

Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module NA := Nest A.
Module AN := NA.AsNested A2.
Definition nz : nat := AN.z.

TypeScript Separate Extraction NA AN nz.
