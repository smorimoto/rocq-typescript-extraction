From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimString.

Extract Inductive list => "readonly $1[]" [ "[]" "(<A>(x: A, xs: readonly A[]): readonly A[] => [x, ...xs])" ]
  "(<A, R>(onNil: () => R, onCons: (x: A, xs: readonly A[]) => R, l: readonly A[]): R => {
  const first = l.values().next();

  return first.done ? onNil() : onCons(first.value, l.slice(1));
})".

Extract Inductive prod => "readonly [$1, $2]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ]
  "(<A, B, R>(f: (a: A, b: B) => R, p: readonly [A, B]): R => f(p[0], p[1]))".

Parameter weight : nat -> nat.
Extract Constant weight => "(n: Nat): Nat => n".
Definition dup {A} (x : A) : list A := x :: x :: nil.
Parameter pick : forall {A}, list A -> A -> A.
Extract Constant pick => "<A>(xs: readonly A[], d: A): A => {
  const first = xs.values().next();

  return first.done ? d : first.value;
}".

Definition first_or {A} (l : list A) (d : A) : A := match l with nil => d | cons x _ => x end.
Definition apply_pair {A B} (p : (A -> B) * A) : B := let (f, x) := p in f x.
Definition diagonal {A} (x : A) : list (A * A) := (x, x) :: nil.
Definition chosen : nat := pick (dup 3) 0.
Definition heavy : nat := weight 2.
Parameter seed : nat.
Extract Inlined Constant seed => "weight(s(o))".
Definition plus_seed : nat -> nat := Nat.add seed.

(* Only custom code calls the realisers of span: its constructor after
   the dots of a spread, and its match function inside the hole of a
   template literal. *)
Inductive span := Span (lo hi : nat).
Extract Inductive span => "readonly [Nat, Nat]"
  [ "((lo: Nat, hi: Nat): readonly [Nat, Nat] => [lo, hi])" ]
  "(<R>(f: (lo: Nat, hi: Nat) => R, p: readonly [Nat, Nat]): R => f(p[0], p[1]))".
Extract Inlined Constant PrimString.string => "string".
Parameter unit_span : span.
Extract Constant unit_span => "[o, s(o)]".
Parameter ends : list nat.
Extract Constant ends => "[...span(o, s(o))]".
Parameter summary : PrimString.string.
Extract Constant summary => "`${matchSpan((_lo: Nat, hi: Nat): Nat => hi, unitSpan).tag} on top`".

(* A function type whose result is a union is one type, not a union of
   function types, so it is not split at its bars. *)
Parameter handler : Type.
Extract Inlined Constant handler =>
  "(request: string, response: string, context: string) => ""accepted"" | ""rejected"" | ""deferred""".
Parameter route : handler.
Extract Constant route =>
  "(request: string, response: string, context: string): ""accepted"" | ""rejected"" | ""deferred"" => (request === response && context === """" ? ""accepted"" : ""rejected"")".

TypeScript Extraction "customs.ts"
  dup first_or apply_pair diagonal chosen heavy plus_seed unit_span ends summary route.
