From TypeScriptExtraction Require Import Number.

(* The shapes of a term that TypeScript narrows to some constructors of
   its type, each matched on every constructor. *)
Inductive colour := Red | Green | Mix (n : nat).

Definition name (c : colour) : nat :=
  match c with Red => 0 | Green => 1 | Mix n => n end.

(* A local bound to a constant constructor, in a body and in an
   expression; the parameter only the removed branch read is unused. *)
Definition local (k : nat) : nat :=
  let c := Green in match c with Red => k | Green => name c | Mix n => n end.

Definition nested (k : nat) : nat :=
  k + (let c := Red in match c with Red => name c | Green => 1 | Mix n => n end).

(* A conditional of two constant constructors, bound to a local and to a
   global, and a match that extraction factors into one. *)
Definition either (b : bool) : nat :=
  let c := if b then Red else Green in
  match c with Red => 0 | Green => name c | Mix n => n end.

Definition chosen : colour := if Nat.eqb (name Green) 1 then Red else Green.

Definition of_chosen : nat :=
  match chosen with Red => 0 | Green => 1 | Mix n => n end.

Definition swapped (c0 : colour) : nat :=
  let c := match c0 with Red => Green | Green => Red | Mix _ => Red end in
  match c with Red => name c | Green => 1 | Mix n => n end.

(* A member of a module, inside it and outside. *)
Module Palette.
  Definition base : colour := Green.
  Definition inside : nat := match base with Red => 0 | Green => 1 | Mix n => n end.
End Palette.

Definition outside : nat :=
  match Palette.base with Red => 0 | Green => 1 | Mix n => n end.

(* A match on a variable that an enclosing branch narrows: to the
   constructor of its case, to the constructors no other branch names in
   a wildcard, and inside a function, which keeps the narrowing of a
   parameter but not that of a pattern variable, a property of the
   scrutinee. *)
Definition again (c : colour) : nat :=
  match c with
  | Red => match c with Red => 0 | Green => 1 | Mix n => n end
  | Green => 2
  | Mix n => n
  end.

Definition rest (c : colour) : nat :=
  match c with
  | Red => 0
  | _ => match c with Red => 1 | Green => 2 | Mix n => n end
  end.

Definition twice (f : nat -> nat) (n : nat) : nat := f (f n).

Definition later (c : colour) : nat :=
  match c with
  | Red => twice (fun k => match c with Red => S k | Green => 0 | Mix n => n end) 0
  | Green => 1
  | Mix n => n
  end.

Definition deeper (o : option colour) : nat :=
  match o with
  | Some c =>
    match c with
    | Red => twice (fun k => match c with Red => S k | Green => 0 | Mix n => n end) 0
    | _ => 0
    end
  | None => 0
  end.

(* comparison is a union of string literals, whose constants narrow too. *)
Definition below : comparison := Lt.

Definition rank : nat := match below with Eq => 0 | Lt => 1 | Gt => 2 end.

(* A conditional with a constructor function, and a global bound to one,
   are not narrowed, so their matches stay whole. *)
Definition mixed (b : bool) : nat :=
  let c := if b then Red else Mix 3 in
  match c with Red => name c | Green => 1 | Mix n => n end.

Definition four : colour := Mix 4.

Definition of_four : nat := match four with Red => 0 | Green => 1 | Mix n => n end.

TypeScript Extraction "narrowing-shapes.ts"
  local nested either of_chosen swapped Palette outside again rest later deeper rank
  mixed of_four.
