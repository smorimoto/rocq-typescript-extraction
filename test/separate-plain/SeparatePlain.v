From TypeScriptExtraction Require Import Number.
From FixLibs Require Import PlainNest.

Module A. Definition t := nat. Definition z : t := 1. End A.
Module B := F A.

TypeScript Separate Extraction F B.
