From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* A local cofix whose head is a match that must be a statement keeps the
   match in its lazy cell, alone or stored in a pair. The axiom boom
   throws when it runs. *)
Axiom boom : nat -> nat.

CoInductive stream := Cons (h : nat) (t : stream).

Inductive color := Red | Green | Blue.

Definition local_cofix (n : nat) (c : color) : stream :=
  let cofix s :=
    Cons (match c with Red => 1 | Green => 2 | Blue => n end) s
  in
  s.

Definition wrap (n : nat) (c : color) : nat * stream :=
  let cofix s :=
    Cons (match c with Red => 1 | Green => 2 | Blue => n end) s
  in
  (n, s).

Definition wrap_boom (c : color) : nat * stream :=
  let cofix s :=
    Cons (match c with Red => 1 | Green => 2 | Blue => boom 0 end) s
  in
  (0, s).

Definition force (s : stream) : nat := match s with Cons h _ => h end.

TypeScript Extraction "local-cofix.ts" local_cofix wrap wrap_boom force.
