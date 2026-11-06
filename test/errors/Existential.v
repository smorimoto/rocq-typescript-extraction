From TypeScriptExtraction Require Import Number.
Set Extraction Output Directory ".".

(* A list of records whose field of sort Type differs from one to the next
   packs each with its own type, which TypeScript cannot write without
   unknown. *)
Record monoid := { carrier : Type; op : carrier -> carrier -> carrier; unit : carrier }.

Definition nat_monoid : monoid := {| carrier := nat; op := Nat.add; unit := 0 |}.
Definition bool_monoid : monoid := {| carrier := bool; op := andb; unit := true |}.

Definition both : list monoid := cons nat_monoid (cons bool_monoid nil).

Redirect "Existential" Fail TypeScript Extraction "existential.ts" both.

(* So does a function whose result is such a record when the field depends
   on an argument that is not a binder of an enumeration. *)
Definition by_size (n : nat) : monoid :=
  match n with O => nat_monoid | S _ => bool_monoid end.

Redirect "RecordResult" Fail TypeScript Extraction "record-result.ts" by_size.
