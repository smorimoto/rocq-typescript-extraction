From TypeScriptExtraction Require Import Number.

Module Type ORD. Parameter t : Type. End ORD.

Module Sorting (X : ORD).
  Definition sort (l : list X.t) : list X.t :=
    match l with nil => nil | cons x r => app r (cons x nil) end.
  Module Inner.
    Definition filter (l : list X.t) : list X.t :=
      match l with nil => nil | cons _ r => r end.
  End Inner.
End Sorting.

Module NatOrd. Definition t := nat. End NatOrd.
Module Sort := Sorting NatOrd.

Definition sorted (l : list nat) : list nat := Sort.sort l.
