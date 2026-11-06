From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* A local function used at two types is generic, and one that refers to
   no local is declared at the top level, under the name of the
   definition. *)
Definition ids (n : nat) (b : bool) : nat * bool :=
  let id := fun (A : Type) (x : A) => x in (id nat n, id bool b).

Definition firsts (ns : list nat) (bs : list bool) : nat * bool :=
  let first := fun (A : Type) (d : A) (l : list A) =>
    match l with nil => d | cons x _ => x end
  in (first nat 0 ns, first bool false bs).

Definition lengths (ns : list nat) (bs : list bool) : nat :=
  let length := fix length (A : Type) (l : list A) : nat :=
    match l with nil => 0 | cons _ t => S (length A t) end
  in length nat ns + length bool bs.

Definition evens (ns : list nat) (bs : list bool) : bool * bool :=
  let even := fix even (A : Type) (l : list A) : bool :=
    match l with nil => true | cons _ t => odd A t end
  with odd (A : Type) (l : list A) : bool :=
    match l with nil => false | cons _ t => even A t end
  for even
  in (even nat ns, even bool bs).

(* A function of a group that does not mention a type parameter of the
   group in its type does not take it. *)
Definition alternates (ns : list nat) (bs : list bool) : bool :=
  let f := fix f (A B : Type) (l : list A) : bool :=
    match l with nil => true | cons _ t => g A B t nil end
  with g (A B : Type) (l : list A) (m : list B) : bool :=
    match l with nil => false | cons _ t => f A B t end
  for f
  in andb (f nat bool ns) (f bool nat bs).

(* A generic local function that reads a local stays local, with type
   parameters named apart from those of the definition. *)
Definition tagged {A : Type} (a : A) (n : nat) (b : bool) : (A * nat) * (A * bool) :=
  let tag := fun (B : Type) (x : B) => (a, x) in (tag nat n, tag bool b).

Definition nested (n : nat) (b : bool) : (nat * nat) * (bool * nat) :=
  let outer := fun (A : Type) (x : A) =>
    let inner := fun (B : Type) (y : B) => (x, y) in fst (inner nat 0, inner bool true)
  in (outer nat n, outer bool b).

(* A lifted let inside an expression leaves its body there. *)
Definition picked (n m : nat) (b : bool) : nat * bool :=
  (n + m, andb b (let id := fun (A : Type) (x : A) => x in id bool (Nat.eqb (id nat n) m))).

(* A function lifted out of a module member is named after the member,
   and stays out of the module object. *)
Module Inner.
  Definition both (n : nat) (b : bool) : nat * bool :=
    let id := fun (A : Type) (y : A) => y in (id nat n, id bool b).
End Inner.

(* A partial application is no function, so it stays monomorphic, and a
   second use at another type goes through the cast that extraction
   inserts, as OCaml's Obj.magic does. *)
Definition apply_id (X : Type) (x : X) : X := x.

Definition applied (n : nat) (b : bool) : nat * bool :=
  let f := apply_id (forall A : Type, A -> A) (fun A x => x) in (f nat n, f bool b).

TypeScript Extraction "let-poly.ts"
  ids firsts lengths evens alternates tagged nested picked Inner applied.
