From TypeScriptExtraction Require Import Number.

Module Type SIG. Parameter t : Type. Parameter z : t. End SIG.
Module Type FT (X : SIG) := SIG.

Module Const (X : SIG) <: SIG. Definition t := nat. Definition z : t := 0. End Const.
Module Same (X : SIG) <: SIG. Definition t := X.t. Definition z : t := X.z. End Same.

Module A. Definition t := nat. Definition z : t := 7. End A.
