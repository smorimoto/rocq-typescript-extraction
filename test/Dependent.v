From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* A binder of an enumeration that a later type depends on is a type
   parameter bounded by the enumeration, a match on it in a type is a
   conditional type, and a type function over it is a generic alias. A
   call whose argument is a constructor reduces the conditional, so it
   needs no cast. *)
Definition payload (b : bool) : Type := if b then nat else bool.

Definition weigh (b : bool) (x : payload b) : nat :=
  match b return payload b -> nat with
  | true => fun n => n
  | false => fun c => if c then 1 else 0
  end x.

(* A constructor argument whose type depends on an earlier one makes the
   constructor's interface and function generic over it, and the type the
   union of the interface at each constructor of the bound, which a
   consumer narrows by the earlier argument. *)
Inductive packet := Packet (b : bool) (x : payload b).

Definition weight (p : packet) : nat := match p with Packet b x => weigh b x end.

Definition small : packet := Packet true 3.

Definition dep (b : bool) : if b then nat else bool :=
  match b with true => 0 | false => false end.

Definition zero := dep true.

Definition one : nat := S (dep true).

Definition flip (b : bool) : bool := negb (dep false && b).

(* A generic call over a dependent value instantiates its type parameters
   with the conditional, so a pair of them needs no cast. *)
Definition twice (b : bool) := (dep b, dep b).

(* A lambda in a branch of a dependent match takes its parameter types from
   the arm of the conditional that the branch picks. *)
Definition dep4 (b : bool) := if b then nat -> nat else nat -> bool.

Definition fn (b : bool) : dep4 b :=
  match b with true => fun n => n | false => fun _ => true end.

Definition applied : nat := fn true 4.

Definition heavy : nat := weigh true 3 + weigh false true.

TypeScript Extraction "dependent.ts" weigh packet weight small dep zero one flip twice fn applied heavy.
