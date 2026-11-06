From TypeScriptExtraction Require Import BigInt.

Definition payload (b : bool) : Type := if b then nat else Empty_set.

Definition read (b : bool) (x : payload b) : nat :=
  match b return payload b -> nat with
  | true => fun n => n
  | false => fun e => match e with end
  end x.

Inductive token := Numbered (n : nat) | Unnumbered.

(* Neither parcel nor token occurs in inspect's MiniML body or type.
   Reconstructing choice discovers parcel; reconstructing its constructor
   in the next pass discovers token. *)
Inductive parcel := Parcel (b : bool) (x : if b then token else Empty_set).

Definition choice (b : bool) : Type := if b then parcel else Empty_set.
Definition inspect (b : bool) (_ : choice b) : bool := b.

Inductive marker := Marked | Unmarked.
Extract Inductive marker => "boolean" [ "true" "false" ].

Definition mapped (b : bool) : Type := if b then marker else Empty_set.
Definition mapped_read (b : bool) (x : mapped b) : bool :=
  match b return mapped b -> bool with
  | true => fun m => match m with Marked => true | Unmarked => false end
  | false => fun e => match e with end
  end x.

Inductive secret := SecretValue (n : nat) | NoSecret.

Module Type READER.
  Parameter read_secret : forall b : bool, (if b then secret else Empty_set) -> bool.
End READER.

Module Use (R : READER).
  Definition ready := R.read_secret true.
End Use.
