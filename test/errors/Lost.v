From TypeScriptExtraction Require Import Number.
Set Extraction Output Directory ".".

(* A type that extraction loses, that the kernel gives no TypeScript form,
   and that the body does not give either, as a parameter that quantifies
   over types without being a function after them, leaves the declaration
   with no TypeScript type. *)
Definition empties (h : forall A, list A) : list nat * list bool := (h nat, h bool).

Redirect "Lost" Fail TypeScript Extraction "lost.ts" empties.

(* So does the alias of a type that quantifies over types, whose
   definition MiniML keeps lossy. *)
Definition poly := forall A, A -> A.

Definition use_poly (h : poly) (n : nat) : nat := h nat n.

Redirect "LostAlias" Fail TypeScript Extraction "lost-alias.ts" use_poly.
