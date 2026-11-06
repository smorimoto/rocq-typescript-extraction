From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* A match that must be a statement, in every place an expression can
   hold it. *)
Inductive shift := Early | Late | Night.

Definition weight (s : shift) : nat :=
  match s with Early => 1 | Late => 2 | Night => 3 end.

Definition shift_of (n : nat) : shift :=
  match n with 0 => Early | 1 => Late | _ => Night end.

Definition three_in_cond (b : bool) (s : shift) (n : nat) : nat :=
  if b then Nat.add (match s with Early => 1 | Late => 2 | Night => 3 end) n else 0.

Definition three_under_call (b : bool) (s : shift) (n : nat) : nat :=
  Nat.add (if b then Nat.mul (match s with Early => 1 | Late => 2 | Night => 3 end) n else 0) n.

Definition let_in_match_in_call (n m : nat) : nat :=
  Nat.add (match n with O => m | S p => let k := p + p in k + m end) m.

Definition wide_context (n m : nat) : nat :=
  Nat.add (n + n) (match m with O => n | S O => m | S (S p) => p end).

Definition two_matches (s t : shift) : nat :=
  Nat.add (match s with Early => 1 | Late => 2 | Night => 3 end)
    (match t with Early => 4 | Late => 5 | Night => 6 end).

Definition bound_match (s : shift) (n : nat) : nat :=
  let w := match s with Early => n | Late => n + n | Night => 0 end in w + w.

Definition bound_wide (s : shift) (n : nat) : nat :=
  let w := match s with Early => n | Late => n + n | Night => 0 end in w + (w + n).

Definition bound_statement (s : shift) (n : nat) : nat :=
  let w := match s with Early => n | Late => n + n | Night => 0 end in
  let v := w + w in v + n.

(* A constructor applied to atoms is not an atom, so a context that holds
   one reads a variable that the cases assign. *)
Definition constructor_context (s : shift) (n : nat) : nat * nat :=
  (S n, match s with Early => n | Late => n + n | Night => 0 end).

Definition constructor_body (s : shift) (n : nat) : list nat :=
  let w := match s with Early => n | Late => n + n | Night => 0 end in cons w (cons 1 nil).

Definition match_on_match (s : shift) (n : nat) : nat :=
  match match s with Early => n | Late => S n | Night => 0 end with
  | O => 7
  | S k => k
  end.

Definition partial_of_pair (p : nat * nat) : nat -> nat :=
  Nat.add (let (a, b) := p in a + b).

Definition night_weight : nat :=
  S (match shift_of 2 with Early => 1 | Late => 2 | Night => 3 end).

Definition opening : shift := Early.

Definition opening_weight : nat :=
  match opening with Early => 1 | Late => 2 | Night => 3 end.

CoInductive stream := SCons (h : nat) (t : stream).

CoFixpoint doubles (n : nat) : stream :=
  SCons (let k := n + n in k + k) (doubles (S n)).

Definition shead (s : stream) : nat := match s with SCons h _ => h end.

TypeScript Extraction "statements.ts"
  weight shift_of three_in_cond three_under_call let_in_match_in_call wide_context
  two_matches bound_match bound_wide bound_statement constructor_context
  constructor_body match_on_match partial_of_pair
  night_weight opening_weight doubles shead.
