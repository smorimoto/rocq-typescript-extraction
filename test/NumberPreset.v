From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import BinNums.PosDef BinNums.IntDef.

Fixpoint even (n : nat) : bool :=
  match n with O => true | S O => false | S (S m) => even m end.
Definition swap {A B} (p : A * B) : B * A := let (a, b) := p in (b, a).
Definition flip {A B} (p : A * B) : B * A := (snd p, fst p).
Definition halve (n : nat) : nat * bool := (Nat.div n 2, negb (even n)).
Definition tick (n : nat) : unit * nat := (tt, S n).

Fixpoint digits (p : positive) : nat :=
  match p with xI q => S (digits q) | xO q => S (digits q) | xH => 1 end.
Definition next (n : N) : N := match n with N0 => Npos xH | Npos p => Npos (Pos.succ p) end.
Definition magnitude (z : Z) : N := match z with Z0 => N0 | Zpos p | Zneg p => Npos p end.
Definition minus_six : Z := Zneg (xO (xI xH)).

Inductive tree (A : Type) := Leaf | Node (l : tree A) (x : A) (r : tree A).
Arguments Leaf {A}.
Arguments Node {A}.
Fixpoint size {A} (t : tree A) : nat :=
  match t with Leaf => 0 | Node l _ r => S (size l + size r) end.

(* Nat.add comes first in the structure and takes the name add, so this
   one is add0. *)
Definition add (a b : nat) : nat := a + b + b.

TypeScript Extraction "number-preset.ts"
  even swap flip halve tick digits next magnitude minus_six Z.add size Nat.add add.
