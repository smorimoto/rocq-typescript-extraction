From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

Definition plus (n m : nat) : nat := n + m.
Definition add3 : nat -> nat := plus 3.
Definition plus_n (n : nat) : nat -> nat := plus n.
Definition adders : list (nat -> nat) := map plus (0 :: 1 :: nil).
Definition apply_twice {A} (f : A -> A) (x : A) : A := f (f x).
Definition add4 : nat -> nat := apply_twice (plus 2).
Definition sum3 (n m k : nat) : nat := n + m + k.
Definition partial_sum3 (n : nat) : nat -> nat -> nat := sum3 n.
Definition full_sum3 : nat := sum3 1 2 3.
Definition staged (n : nat) : nat -> nat := let t := n * n in fun m => t + m.
Definition staged_value : nat := staged 3 4.
Definition pick {A} (b : bool) (x y : A) : A := if b then x else y.
Definition pick_first {A} : A -> A -> A := pick true.
Definition one : nat := 1.
Definition add_one : nat -> nat := plus one.
Definition add_succ : nat -> nat := plus (S one).

TypeScript Extraction "currying.ts"
  plus add3 plus_n adders apply_twice add4 sum3 partial_sum3 full_sum3 staged staged_value
  pick pick_first one add_one add_succ.
