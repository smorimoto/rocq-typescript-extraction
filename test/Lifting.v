From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A lifted binder is named after the binder in PascalCase, apart from the
   types of the file. *)
Definition b : Type := nat.
Definition keep_b (x : b) : b := x.

Definition collide (b : bool) : if b then nat else bool :=
  match b with true => 0 | false => false end.

Definition snake (is_num : bool) : if is_num then nat else bool :=
  match is_num with true => 0 | false => false end.

(* A binder after others, after a type parameter, and two binders, one
   tested inside the other's branch. *)
Definition after_nat (n : nat) (b : bool) : if b then nat else bool :=
  match b with true => n | false => true end.

Definition call_after : nat := after_nat 5 true.

Definition poly_dep (A : Type) (x : A) (b : bool) : if b then A else bool :=
  match b with true => x | false => false end.

Definition call_poly : nat := poly_dep nat 7 true.

Definition two_flags (a b : bool) : if a then nat else if b then bool else list nat :=
  match a return if a then nat else if b then bool else list nat with
  | true => 3
  | false =>
    match b return if b then bool else list nat with
    | true => true
    | false => cons 1 nil
    end
  end.

Definition call_two : list nat := two_flags false false.

TypeScript Extraction "lifting.ts"
  keep_b collide snake after_nat call_after poly_dep call_poly two_flags call_two.
