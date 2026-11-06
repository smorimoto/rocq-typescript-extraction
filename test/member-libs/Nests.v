From TypeScriptExtraction Require Import Number.
From MemberLibs Require Import Sorts.

Module Outer (X : ORD).
  Module S := Sorting X.
  Module I := S.Inner.
  Definition drop (l : list X.t) : list X.t := I.filter l.
End Outer.
