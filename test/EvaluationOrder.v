From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* A statement that leaves an expression runs where ML evaluates it, and
   nothing in a branch, a lambda, or a lazy cell runs before it would. The
   axiom boom throws when it runs. *)
Axiom boom : nat -> nat.

Inductive color := Red | Green | Blue.

Definition strict_branch (n : nat) (c : color) : nat :=
  Nat.add n (match c with Red => 1 | Green => 2 | Blue => boom 0 end).

Definition in_lambda (n : nat) : nat -> nat :=
  let k := n + n in
  fun m => Nat.add m (match k with O => boom 0 | S p => p end).

Definition in_branch (b : bool) (c : color) : nat :=
  if b then match c with Red => 1 | Green => 2 | Blue => boom 0 end else 0.

Definition partial_boom (n : nat) : nat -> nat :=
  Nat.add (match n with O => boom 0 | S k => k end).

Definition partial_ok (n : nat) : nat -> nat :=
  Nat.add (match n with O => 1 | S k => k end).

Definition two (c d : color) : nat :=
  Nat.add
    (match c with Red => 1 | Green => 2 | Blue => 3 end)
    (match d with Red => 4 | Green => 5 | Blue => boom 0 end).

Definition classify (n : nat) : color :=
  match n with O => Red | S O => Green | _ => Blue end.

Definition top_safe : nat :=
  S (match classify 0 with Red => 1 | Green => boom 0 | Blue => boom 0 end).

Definition shadow (n : nat) (c : color) : nat :=
  let result := n + n in
  Nat.add (result + result)
    (match c with Red => 1 | Green => 2 | Blue => 3 end).

CoInductive stream := Cons (h : nat) (t : stream).

CoFixpoint later (n : nat) : stream :=
  Cons (match n with O => boom 0 | S k => k end) (later n).

Definition force (s : stream) : nat := match s with Cons h _ => h end.

CoFixpoint lazy_let (n : nat) : stream :=
  Cons (let k := n + n in Nat.add k (match n with O => boom 0 | S _ => 0 end))
    (lazy_let n).

Inductive tok := A | C.
Extract Inductive tok => "boolean" [ "true" "false" ]
  "(<R>(onA: () => R, onC: () => R, t: boolean): R => (t ? onA() : onC()))".

Definition from_tok (n : nat) (t : tok) (c : color) : nat :=
  Nat.add n (match t with
             | A => match c with Red => 1 | Green => 2 | Blue => 3 end
             | C => let k := boom 0 in k
             end).

TypeScript Extraction "evaluation-order.ts"
  strict_branch in_lambda in_branch partial_boom partial_ok two classify top_safe
  shadow later force lazy_let from_tok.
