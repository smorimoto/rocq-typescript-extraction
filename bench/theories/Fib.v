(** Fibonacci numbers by an accumulating loop, against the naive
    specification. *)

Fixpoint fib (n : nat) : nat :=
  match n with
  | O => 0
  | S m => match m with O => 1 | S k => fib k + fib m end
  end.

Fixpoint fib_loop (n a b : nat) : nat :=
  match n with
  | O => a
  | S m => fib_loop m b (a + b)
  end.

Definition fib_iter (n : nat) : nat := fib_loop n 0 1.

Lemma fib_loop_fib : forall n k, fib_loop n (fib k) (fib (S k)) = fib (n + k).
Proof.
  induction n as [|n IH]; intros k.
  - reflexivity.
  - change (fib_loop n (fib (S k)) (fib (S (S k))) = fib (S (n + k))).
    rewrite IH, plus_n_Sm. reflexivity.
Qed.

Theorem fib_iter_fib : forall n, fib_iter n = fib n.
Proof.
  intros n. change (fib_loop n (fib 0) (fib 1) = fib n).
  rewrite fib_loop_fib, <- plus_n_O. reflexivity.
Qed.
