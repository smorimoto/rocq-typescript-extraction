From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A binder of an enumeration of three constructors is a type parameter
   bounded by its union, and a match on it a chain of conditional types,
   each nested one a step deeper. *)
Inductive color := Red | Green | Blue.

Definition shade (c : color) : Type :=
  match c with Red => nat | Green => bool | Blue => list nat end.

Definition produce (c : color) : shade c :=
  match c with Red => 7 | Green => true | Blue => cons 1 nil end.

Definition consume (c : color) (x : shade c) : nat :=
  match c return shade c -> nat with
  | Red => fun n => n
  | Green => fun b => if b then 1 else 0
  | Blue => fun xs => match xs with nil => 0 | cons h _ => h end
  end x.

Definition red_val : nat := produce Red.
Definition green_val : bool := produce Green.
Definition total : nat := consume Red 5 + consume Green true.

TypeScript Extraction "three-way.ts" produce consume red_val green_val total.
