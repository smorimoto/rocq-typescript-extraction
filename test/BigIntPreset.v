From TypeScriptExtraction Require Import BigInt.
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

Definition twice_right (a b : nat) : nat := a + b + b.

Inductive counter := Origin | Tick (previous : counter).
Fixpoint count (c : counter) : nat :=
  match c with Origin => 0 | Tick p => S (count p) end.

Definition subtract := Nat.sub.
Definition predecessor := Nat.pred.
Definition divide := Nat.div.
Definition remainder := Nat.modulo.
Definition multiply := Nat.mul.

From Corelib Require Import PrimInt63 PrimFloat PrimString PrimArray.
Definition primitive_int_add := PrimInt63.add.
Definition primitive_float_add := PrimFloat.add.
Definition primitive_string_cat := PrimString.cat.
Definition primitive_array_get {A : Type} (a : PrimArray.array A) (i : PrimInt63.int) :=
  PrimArray.get a i.

TypeScript Extraction "big-int-preset.ts"
  even swap flip halve tick digits next magnitude minus_six Z.add size Nat.add twice_right
  count subtract predecessor divide remainder multiply
  primitive_int_add primitive_float_add primitive_string_cat primitive_array_get.
