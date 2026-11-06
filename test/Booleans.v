From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition xor (a b : bool) : bool := (a || b) && negb (a && b).
Definition choose {A} (b : bool) (x y : A) : A := if b then x else y.
Definition decide (n : nat) : {n = 0} + {n <> 0}.
Proof. destruct n; [left | right]; auto. Defined.
Definition is_zero (n : nat) : bool := if decide n then true else false.
Definition nothing : unit := tt.
Definition forget {A} (x : A) : unit := tt.

(* A two-branch match on a tagged type whose bodies are the boolean
   literals, in expression position, is its test or the negation. *)
Inductive token := Dot | Dash (len : nat).
Definition dot_and (t : token) (b : bool) : bool :=
  andb (match t with Dot => true | Dash _ => false end) b.
Definition dash_or (t : token) (b : bool) : bool :=
  orb (match t with Dot => false | Dash _ => true end) b.

(* The negation of a test that is the scrutinee itself: a variable, a
   field, a tuple element, a call, and a call that decides a sumbool.
   Corelib's xorb nests one in a match on its first argument. *)
Record box := { flag : bool; count : nat }.
Definition notb (b : bool) : bool := if b then false else true.
Definition unflagged (r : box) : bool := if flag r then false else true.
Definition second_off (p : bool * bool) : bool :=
  let (_, b) := p in if b then false else true.
Definition odd (n : nat) : bool := if Nat.even n then false else true.
Definition nonzero (n : nat) : bool := if decide n then false else true.

(* A let bound to a negation carries no annotation, since the linter
   infers boolean from the negation. *)
Definition twice (b : bool) : bool :=
  let r := match b with true => false | false => true end in andb r r.

TypeScript Extraction "booleans.ts"
  xor choose decide is_zero nothing forget dot_and dash_or
  notb unflagged second_off odd nonzero xorb twice.
