From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive word := New | Old.
Definition s (n : nat) : nat := S n.
Definition foo_bar : nat := 1.
Definition fooBar : nat := 2.
Inductive option_cfg := Cfg (default : nat) (max_depth : nat).
Definition depth (c : option_cfg) : nat := match c with Cfg _ d => d end.
Inductive tagged := Tagged (tag : nat) (value : nat).
Definition untag (t : tagged) : nat := match t with Tagged _ v => v end.
Inductive a : Type := MkA | MkB.
Inductive box (A : Type) := Box (contents : A) (other : a).
Arguments Box {A}.
Definition unbox {A} (b : box A) : A := match b with Box x _ => x end.
Module Word. Definition flip (w : word) : word := match w with New => Old | Old => New end. End Word.
Definition primed (n' : nat) : nat := n' + s n'.
Inductive klass := Klass (class : nat) (size : nat).
Definition klass_size (k : klass) : nat := match k with Klass _ n => n end.
Definition twice (o : nat) : nat := o + o.
Definition accent (né : nat) : nat := né + 1.
Module Tip. Inductive kind := Round | Pointed. End Tip.
Definition tip_kind : Type := Tip.kind.
Module Outer.
  Inductive t := Up | Down.
  Module Outer.
    Inductive u := Left | Right.
    Definition flip (x : u) : u := match x with Left => Right | Right => Left end.
  End Outer.
  Module Tip. Inductive size := Small | Large. End Tip.
  Inductive piece := Piece (kind : Naming.Tip.kind) (size : Tip.size).
  Definition swap (x : t) : t := match x with Up => Down | Down => Up end.
  Definition big_round : piece := Piece Naming.Tip.Round Tip.Large.
End Outer.
Definition _1 : nat := 0.
Definition x₁ : nat := 1.
Definition y½ : nat := 2.
Inductive indexed := Indexed (_2 : nat) (x₂ : nat).
Definition pick (_3 x₃ : nat) : nat := x₃ + _3.
Definition map (n : nat) : nat := n + n.
Definition date : Type := nat.
Definition set (d : date) : date := S d.
Inductive outcome := Ok (n : nat) | Error.
Inductive branch := Then | Else.
(* The parameter x of the inlined code is bound wherever the code is
   written out, so the constructor X takes a suffix. *)
Parameter same : nat -> nat.
Extract Inlined Constant same => "((x: Nat): Nat => x)".
Inductive axis := X | Y.
Definition is_x (ax : axis) : bool := match ax with X => true | Y => false end.
Definition horizontal : bool := is_x X.
Definition still (n : nat) : nat := same n.

TypeScript Extraction "naming.ts"
  word s foo_bar fooBar option_cfg depth tagged untag box unbox Word primed a
  klass klass_size twice accent Tip tip_kind Outer _1 x₁ y½ indexed pick
  map date set outcome branch axis horizontal still.
