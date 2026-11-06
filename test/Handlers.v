From TypeScriptExtraction Require Import Number.

(* Handle uses the parameter contravariantly, so a constant constructor
   typed with the union at never would fit no instance a consumer names. *)
Inductive handler (A : Type) := Idle | Handle (f : A -> nat).
Arguments Idle {A}.
Arguments Handle {A}.

Definition quiet : handler nat := Idle.

Definition run (h : handler nat) (x : nat) : nat :=
  match h with Idle => 0 | Handle f => f x end.

Definition handlers : list (handler nat) := cons Idle (cons (Handle S) nil).

Definition three : nat := run Idle 3.

TypeScript Extraction "handlers.ts" quiet run handlers three.
