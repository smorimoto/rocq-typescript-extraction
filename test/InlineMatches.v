From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* Each mapped type lowers its matches inline through TypeScript Extract
   Match, with no match function declared. *)
Extract Inductive bool => "boolean" [ "true" "false" ].
TypeScript Extract Match bool => [ "$0" ] [ "!$0" ].

Extract Inductive nat => "number" [ "0" "((n: number): number => n + 1)" ].
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].

Extract Inductive list => "readonly $1[]"
  [ "[]" "(<A>(x: A, xs: readonly A[]): readonly A[] => [x, ...xs])" ].
TypeScript Extract Match list => [ "$0.length === 0" ] [ "$0.length > 0" "(<Head>(items: readonly Head[]): Head => {
  const first = items.values().next();

  if (first.done) {
    throw new Error(""Empty list"");
  }

  return first.value;
})($0)" "$0.slice(1)" ].

Extract Inductive prod => "readonly [$1, $2]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ].
TypeScript Extract Match prod => [ _ "$0[0]" "$0[1]" ].

Inductive sign := Neg | Zero | Pos.
Extract Inductive sign => "number" [ "-1" "0" "1" ].
TypeScript Extract Match sign => [ "$0 < 0" ] [ "$0 === 0" ] [ "$0 > 0" ].

Definition pick (b : bool) (x y : nat) : nat := if b then x else y.
Definition square_if (b : bool) (n : nat) : nat := if b then let m := n + n in m * m else n.
Definition is_zero (n : nat) : bool := match n with O => true | S _ => false end.
Definition nonzero (n : nat) : bool := match n with O => false | S _ => true end.
Fixpoint even (n : nat) : bool :=
  match n with O => true | S O => false | S (S m) => even m end.
Definition pred_or_zero (n : nat) : nat := S (match n with O => O | S p => p end).
Definition first_or {A} (l : list A) (d : A) : A := match l with nil => d | cons x _ => x end.
Fixpoint sum (l : list nat) : nat := match l with nil => 0 | cons x xs => x + sum xs end.
Fixpoint last_or (l : list nat) (d : nat) : nat :=
  match l with nil => d | cons x xs => match xs with nil => x | cons _ _ => last_or xs d end end.
Definition swap {A B} (p : A * B) : B * A := let (a, b) := p in (b, a).
Definition negative (s : sign) : bool := match s with Neg => true | _ => false end.
Definition nonneg (s : sign) : bool := match s with Neg | Zero => false | Pos => true end.
Definition unsigned (s : sign) : nat := match s with Zero => 0 | _ => 1 end.
Definition flip (s : sign) : sign := match s with Neg => Pos | Zero => Zero | Pos => Neg end.
Definition total (s : sign) (n : nat) : nat :=
  match s with Neg => 0 | Zero => n | Pos => n + n end.
Definition max (x y : nat) : nat := if Nat.leb x y then y else x.
Definition bump (b : bool) (x y : nat) : nat := S (if b then x else y).
Definition after (l : list nat) : nat := match sum l with O => 0 | S p => p end.
Definition saturate (n : nat) : nat := match n with O => 1 | m => m end.

TypeScript Extraction "inline-matches.ts"
  pick square_if is_zero nonzero even pred_or_zero first_or sum last_or swap negative nonneg
  unsigned flip total max bump after saturate.
