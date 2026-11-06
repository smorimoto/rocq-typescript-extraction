From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Self calls at the tails of a function are a loop, so a deep recursion
   does not grow the stack. *)
Fixpoint sum_to (n acc : nat) : nat :=
  match n with 0 => acc | S k => sum_to k (acc + n) end.

(* Each step updates three parameters, two of them from each other. *)
Fixpoint fib_iter (n a b : nat) : nat :=
  match n with 0 => a | S k => fib_iter k b (a + b) end.

(* The argument of the tail call is a match that must be a statement. *)
Inductive step := Up | Down | Stay.

Definition step_of (n : nat) : step :=
  match Nat.modulo n 3 with 0 => Up | 1 => Down | _ => Stay end.

Fixpoint drift (n pos : nat) : nat :=
  match n with
  | 0 => pos
  | S k => drift k (match step_of k with Up => pos + 2 | Down => pos - 1 | Stay => pos end)
  end.

(* A self call in a call argument, under a match, is no tail and stays a
   call. *)
Fixpoint halves (n : nat) : nat :=
  match n with 0 => 0 | S k => 1 + match k with 0 => 0 | S j => halves j end end.

(* A local fix loops in its own body. *)
Definition sum_local (n : nat) : nat :=
  let fix go (k acc : nat) : nat :=
    match k with 0 => acc | S k' => go k' (acc + k) end
  in go n 0.

(* The inner call is no tail, so only the outer one loops. *)
Inductive tree := Leaf | Node (l : tree) (x : nat) (r : tree).

Fixpoint tree_sum (t : tree) (acc : nat) : nat :=
  match t with Leaf => acc | Node l x r => tree_sum r (tree_sum l (acc + x)) end.

(* A fixpoint whose result is a function, curried at its definition. *)
Fixpoint count_into (n : nat) : nat -> nat :=
  match n with 0 => fun acc => acc | S k => fun acc => count_into k (S acc) end.

(* A parameter that every self call passes on is not copied, and a function
   that reads it may be built in the loop. *)
Definition twice (f : nat -> nat) (x : nat) : nat := f (f x).

Fixpoint add_each (d n acc : nat) : nat :=
  match n with 0 => acc | S k => add_each d k (twice (fun y => y + d) acc) end.

(* A function that reads a parameter that a self call changes would read a
   later value of a loop's copy, so this one recurses. *)
Fixpoint compose_n (n : nat) (k : nat -> nat) : nat -> nat :=
  match n with 0 => k | S m => compose_n m (fun x => k (x + n)) end.

TypeScript Extraction "loops.ts"
  sum_to fib_iter Up Down Stay drift halves sum_local Leaf Node tree_sum count_into
  add_each compose_n.
