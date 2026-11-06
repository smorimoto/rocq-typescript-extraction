From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A dependency on a term other than a binder is the union of what the
   term may give: a type function applied to it is applied to the bound,
   and a match on it is the union of its arms. The binder is then no type
   parameter, and nat, which TypeScript cannot distribute over, never
   is. *)
Definition payload (b : bool) : Type := if b then nat else bool.

Definition weigh_neg (b : bool) (x : payload (negb b)) : nat :=
  match negb b as c return payload c -> nat with
  | true => fun n => n
  | false => fun c => if c then 1 else 0
  end x.

Definition inline_neg (b : bool) : if negb b then nat else bool :=
  match negb b as c return if c then nat else bool with
  | true => 1
  | false => false
  end.

Definition nat_dep (n : nat) : match n with 0 => nat | S _ => bool end :=
  match n with 0 => 0 | S _ => true end.

TypeScript Extraction "unliftable.ts" weigh_neg inline_neg nat_dep.
