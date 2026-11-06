From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A parameter whose type quantifies over types is a generic function
   type, called without the type arguments that extraction erases, and
   an argument for it is a generic arrow: a local or a global function,
   or a lambda. *)
Definition apply_poly (h : forall A, A -> A) (n : nat) (b : bool) : nat * bool :=
  (h nat n, h bool b).

Definition passed (n : nat) (b : bool) : nat * bool :=
  let id := fun (A : Type) (x : A) => x in apply_poly id n b.

Definition global_id (A : Type) (x : A) : A := x.

Definition passed_global (n : nat) (b : bool) : nat * bool := apply_poly global_id n b.

Definition passed_lam (n : nat) (b : bool) : nat * bool := apply_poly (fun A x => x) n b.

Definition forward (h : forall A, A -> A) (n : nat) : nat * bool := apply_poly h n true.

(* A local function whose generic arrow captures nothing still goes to the
   top of the file. *)
Definition twice_poly (k : nat) : (nat * bool) * (nat * bool) :=
  let f := fun (m : nat) => apply_poly (fun A x => x) m true in (f k, f 1).

(* Two type parameters, and one under a type constructor. *)
Definition two (h : forall A B, A -> B -> A) (n : nat) (b : bool) : nat * bool :=
  (h nat bool n b, h bool nat b n).

Definition first (n : nat) (b : bool) : nat * bool := two (fun A B x _ => x) n b.

Definition lists (h : forall A, list A -> nat) (ns : list nat) (bs : list bool) : nat :=
  h nat ns + h bool bs.

(* A record field of such a type. *)
Record boxed := { run : forall A, A -> A; size : nat }.

Definition use_boxed (p : boxed) (n : nat) : nat := run p nat n.

Definition mk_boxed : boxed := {| run := fun A x => x; size := 0 |}.

TypeScript Extraction "rank-two.ts"
  apply_poly passed passed_global passed_lam forward twice_poly first lists use_boxed
  mk_boxed.
