From TypeScriptExtraction Require Import BigInt.
From Corelib Require Import BinNums IntDef.
Set Warnings "+typescript-extraction-unchecked-casts".

Fixpoint count (n seed : nat) : nat :=
  match n with O => seed | S p => S (count p seed) end.

Fixpoint sum_before (f : Z -> Z) (xs : list Z) : Z :=
  match xs with
  | nil => Z0
  | cons x rest => let y := f x in Z.add y (sum_before f rest)
  end.

Fixpoint sum_after (f : Z -> Z) (xs : list Z) : Z :=
  match xs with
  | nil => Z0
  | cons x rest => let tail := sum_after f rest in Z.add (f x) tail
  end.

Parameter combine : Z -> Z -> Z.
Extract Constant combine => "((x: bigint, y: bigint): bigint => x - y)".
Fixpoint differences (xs : list Z) : Z :=
  match xs with nil => Z0 | cons x rest => combine x (differences rest) end.

Inductive counter := Start | Tick (p : counter).
Extract Inductive counter => "bigint"
  [ "0n" "((n: bigint): bigint => n + 2n)" ].
Fixpoint ticks (n : nat) : counter :=
  match n with O => Start | S p => Tick (ticks p) end.

TypeScript Extraction "big-int-accumulators.ts"
  count sum_before sum_after differences ticks.
