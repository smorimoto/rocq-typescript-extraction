From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* TypeScript narrows a const of a union type to its initialiser at every
   reference in its file, so each match below names constructors that
   the type of its scrutinee excludes there. Extraction keeps only the
   branch the scrutinee reaches. *)
Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.

Definition e : tree nat := Leaf.

Definition is_leaf : bool := match e with Leaf => true | Node _ _ _ => false end.

Definition grown : tree nat := match e with Leaf => Node Leaf O Leaf | Node l x r => r end.

Inductive figure := Dot | Line (n : nat) | Box (w : nat) (h : nat).

Definition origin : figure := Dot.
Definition alias : figure := origin.

(* Nat.mul is used only in a branch that is removed, so it is not
   written. *)
Definition area : nat :=
  match alias with Dot => O | Line n => n | Box w h => Nat.mul w h end.

Definition pick (b : bool) : nat :=
  let s := if b then Dot else Dot in
  match s with Dot => O | Line n => n | Box w h => w end.

TypeScript Extraction "narrowing.ts" e is_leaf grown alias area pick.
