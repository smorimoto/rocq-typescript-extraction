From TypeScriptExtraction Require Import Number.
Set Warnings "-declaration-outside-section".
Unset Extraction AccessOpaque.

Axiom key : Type.
Axiom make_key : nat -> key.
Axiom key_id : key -> nat.

Definition roundtrip (n : nat) : nat := key_id (make_key n).

Axiom box : Type -> Type.
Axiom wrap : forall A, A -> box A.
Axiom size : forall A, box A -> nat.

Definition boxed (n : nat) : nat := size nat (wrap nat n).

Axiom table : Type -> Type -> Type.
Axiom lookup : forall K V, table K V -> K -> option V.

(* Extraction names the parameters of an axiom itself, so these names do
   not reach the output. *)
Parameter tagged : forall (brand variance : Type), Type.
Parameter retag : forall B V, tagged B V -> tagged V B.

Axiom wide : Type -> Type -> Type -> Type -> Type -> Type -> Type -> Type.

Parameter elt : Type.
Parameter dup : elt -> elt * elt.

Variable token : Type.
Variable token_of : nat -> token.

Definition tokens (n : nat) : list token := cons (token_of n) nil.

Definition secret : Type.
Proof. exact nat. Qed.

Definition reveal (s : secret) : list secret := cons s nil.

TypeScript Extraction "axioms.ts"
  roundtrip make_key key_id boxed wrap size lookup retag wide dup tokens reveal.
