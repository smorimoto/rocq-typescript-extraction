From TypeScriptExtraction Require Import Number.
From FixLibs Require Import Placed.

Module A. Definition t := nat. Definition z : t := 1. End A.
Module A2. Definition t := bool. Definition z : t := true. End A2.
Module C := FA A.
Module CN := C.Nested A2.
Definition w : nat * bool := CN.w.

TypeScript Separate Extraction C CN w.
