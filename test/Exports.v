From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Only measure is asked for. The figure it classifies stays private, with
   the constructor functions that classify builds and without box, which
   nothing builds. Its helper, the realisers of nat, and the match function
   of figure are private too, since no signature of measure names them. *)
Inductive figure := Dot | Line (n : nat) | Box (w h : nat).

Definition double (n : nat) : nat := n + n.

Definition classify (n : nat) : figure := match n with 0 => Dot | S k => Line k end.

Definition measure (n : nat) : nat :=
  match classify n with Dot => 0 | Line k => double k | Box w h => w * h end.

TypeScript Extraction "exports.ts" measure.
