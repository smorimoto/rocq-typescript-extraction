From TypeScriptExtraction Require Import BigInt.
Open Scope list_scope.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition prepend (x : nat) (k : list nat -> list nat) (xs : list nat) :=
  k (x :: xs).

Fixpoint collect_into (xs : list nat) (k : list nat -> list nat) : list nat -> list nat :=
  match xs with
  | nil => k
  | x :: rest => collect_into rest (prepend x k)
  end.

Definition collect (xs : list nat) := collect_into xs (fun ys => ys) nil.

Definition collect_local (xs : list nat) :=
  let fix go (ys : list nat) (k : list nat -> list nat) : list nat -> list nat :=
    match ys with
    | nil => k
    | x :: rest => go rest (prepend x k)
    end
  in go xs (fun ys => ys) nil.

Definition apply_nat (f : nat -> nat) (n : nat) := f n.
Extraction NoInline apply_nat.

Definition second_plus (xs : list nat) (n : nat) :=
  match xs with
  | _ :: y :: _ => apply_nat (fun u => y + u) n
  | _ => 0
  end.

Inductive tree := Leaf | Node (left : tree) (key : nat) (right : tree).

Definition add_key (key : nat) (k : nat -> nat) (n : nat) := k (key + n).

Fixpoint traverse (t : tree) (k : nat -> nat) (n : nat) : nat :=
  match t with
  | Leaf => k n
  | Node l key r => traverse l (add_key key (traverse r k)) n
  end.

Definition traverse_local (t : tree) (n : nat) :=
  let fix go (s : tree) (k : nat -> nat) (x : nat) : nat :=
    match s with
    | Leaf => k x
    | Node l key r => go l (add_key key (go r k)) x
    end
  in go t (fun x => x) n.

TypeScript Extraction "partial-application-captures.ts"
  collect collect_local second_plus traverse traverse_local.
