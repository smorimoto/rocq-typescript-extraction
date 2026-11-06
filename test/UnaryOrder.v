From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive counter := Tick (previous : counter) | Origin.
Inductive verdict := Within | Beyond.

Fixpoint within (left right : counter) : verdict :=
  match left with
  | Origin => Within
  | Tick before =>
      match right with
      | Origin => Beyond
      | Tick earlier => within before earlier
      end
  end.

Definition strictly_within (left right : counter) := within (Tick left) right.

Definition custom_within := within.
Extract Constant custom_within => "(_left, _right) => ({ tag: ""Beyond"" })".
Definition strictly_custom (left right : counter) := custom_within (Tick left) right.

Definition custom_tick := Tick.
Extract Constant custom_tick => "(previous) => ({ previous, tag: ""Tick"" })".
Definition custom_successor (left right : counter) := within (custom_tick left) right.

Definition counter_alias := counter.
Definition within_alias (left right : counter_alias) := within left right.

Fixpoint equal_counter (left right : counter) : bool :=
  match left, right with
  | Origin, Origin => true
  | Tick before, Tick earlier => equal_counter before earlier
  | _, _ => false
  end.

Definition successor_equal (left right : counter) := equal_counter (Tick left) right.
Definition twice_within (left right : counter) := within (Tick (Tick left)) right.
Definition swapped_within (left right : counter) := within (Tick right) left.

Definition __unaryOrder := Origin.
Definition unaryRanks := Tick Origin.

Inductive plain := Empty | More (prior : plain).
Fixpoint copy_plain (value : plain) : plain :=
  match value with Empty => Empty | More prior => More (copy_plain prior) end.

Module Type Input. Parameter value : nat. End Input.
Module Factory (X : Input).
  Inductive count := Reset | Next (previous : count).
  Fixpoint before (left right : count) : bool :=
    match left with
    | Reset => true
    | Next prior =>
        match right with Reset => false | Next earlier => before prior earlier end
    end.
  Definition strictly_before (left right : count) := before (Next left) right.
  Definition value := X.value.
End Factory.
Module Argument. Definition value := O. End Argument.
Module Instance := Factory Argument.

Module Type Comparison. Parameter compare : counter -> counter -> verdict. End Comparison.
Module Abstract (X : Comparison).
  Definition strict (left right : counter) := X.compare (Tick left) right.
End Abstract.

TypeScript Extraction "unary-order.ts"
  within strictly_within custom_within strictly_custom custom_successor within_alias
  equal_counter successor_equal twice_within swapped_within
  __unaryOrder unaryRanks copy_plain Nat.leb Nat.ltb Factory Instance Abstract.
