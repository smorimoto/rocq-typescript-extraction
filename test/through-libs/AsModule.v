From TypeScriptExtraction Require Import Number.
From ThroughLibs Require Import Outer.

Module M. Definition t := nat. Definition z : t := 7. End M.
Module G (Y : S) := M.
Module Id (Y : S) := Y.
