From TypeScriptExtraction Require Import Number.
From Corelib Require Import BinNums.PosDef.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The tests of the native positive contain &&, so a branch behind a test
   that fails does not run, and a scrutinee that the tests read twice is
   bound once. The axiom boom throws when it runs. *)
Axiom boom : nat -> nat.

Definition behind_and (p : positive) : nat :=
  match p with
  | xI _ => boom 0
  | xO _ => 2
  | xH => 0
  end.

Definition behind_and_stmt (p : positive) (b : bool) : nat :=
  match p with
  | xI _ => if b then boom 0 else 1
  | xO _ => 2
  | xH => 0
  end.

Definition guard (b : bool) (n : nat) : nat :=
  if b then match n with 0 => boom 0 | S k => k end else 0.

Definition pick_pos (n : nat) : positive :=
  if Nat.eqb n 0 then xH else xO xH.

Definition scrambled (n : nat) : nat :=
  match pick_pos (n + n) with
  | xI _ => 1
  | xO _ => 2
  | xH => 0
  end.

Definition bucket (n : nat) : nat :=
  let w := match n with 0 => 1 | S k => k + k end in w + w.

TypeScript Extraction "short-circuit.ts"
  behind_and behind_and_stmt guard pick_pos scrambled bucket.
