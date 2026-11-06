From TypeScriptExtraction Require Import Number.
(* The bigint theories replace the number mappings of the Number preset. *)
From TypeScriptExtraction Require Import ExtrTsNatBigInt ExtrTsBinNumsBigInt.
From Corelib Require Import BinNums.
Set Warnings "+typescript-extraction-unchecked-casts".

Fixpoint fact (n : nat) : nat := match n with 0 => 1 | S p => n * fact p end.
Fixpoint fib (n : nat) : nat :=
  match n with 0 => 0 | S p => match p with 0 => 1 | S q => fib p + fib q end end.
Definition between (lo n hi : nat) : bool := Nat.leb lo n && Nat.ltb n hi.
Definition same (n m : nat) : bool := Nat.eqb n m.
Definition average (a b : nat) : nat := Nat.div (a + b) 2.
Definition remainder (a b : nat) : nat := Nat.modulo a b.
Definition distance (a b : nat) : nat := (a - b) + (b - a).
Definition clamp (n : nat) : nat := Nat.min 10 (Nat.max 2 n).
Definition previous (n : nat) : nat := Nat.pred n.
Definition twice (p : positive) : positive := xO p.
Definition negate (p : positive) : Z := Zneg p.

TypeScript Extraction "big-nats.ts"
  fact fib between same average remainder distance clamp previous twice negate.
