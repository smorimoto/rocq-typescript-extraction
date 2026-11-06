From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A record with a field of sort Type is generic over it. A binder of the
   record's type takes a type parameter of its own, which a projection of
   the field is, and a constant of it reads the field off its value. *)
Record monoid := { carrier : Type; op : carrier -> carrier -> carrier; unit : carrier }.

Definition nat_monoid : monoid := {| carrier := nat; op := Nat.add; unit := 0 |}.

Fixpoint mconcat (m : monoid) (xs : list (carrier m)) : carrier m :=
  match xs with nil => unit m | cons x rest => op m x (mconcat m rest) end.

Definition total : nat := mconcat nat_monoid (cons 1 (cons 2 (cons 3 nil))).

Definition squared (m : monoid) : carrier m := op m (unit m) (unit m).

Fixpoint count (ms : list monoid) : nat :=
  match ms with nil => 0 | cons _ rest => S (count rest) end.

(* A function that returns such a record reads the field off its body: a
   record argument gives its own type parameter, a construction the type
   it is given, and a match on a binder of an enumeration a conditional
   over the branches. *)
Definition same (m : monoid) : monoid := m.

Definition doubled (m : monoid) : monoid :=
  {| carrier := carrier m; op := fun x y => op m (op m x y) y; unit := unit m |}.

Definition with_unit (n : nat) : monoid := {| carrier := nat; op := Nat.add; unit := n |}.

Definition pick (b : bool) : monoid :=
  if b then nat_monoid else {| carrier := bool; op := andb; unit := true |}.

Definition picked : nat := squared (pick true).

TypeScript Extraction "monoid.ts" nat_monoid mconcat total squared count same doubled with_unit pick picked.
