From Stdlib Require Import ZArith List.
From Crypto.Arithmetic Require Import ModOps.
From TypeScriptExtraction Require Import BigInt.
Set Warnings "+typescript-extraction-unchecked-casts".

Import ListNotations.
Local Open Scope Z_scope.

(** Two carry passes, followed by propagation from the wraparound limb.
    All arithmetic comes from the pinned upstream ModOps theory. *)
Definition carries : list nat := (seq 0 5 ++ seq 0 5 ++ [0%nat; 1%nat])%list.

Definition curve25519_mul (f g : list Z) :=
  carry_mulmod 51 1 (2^255) [(1, 19)] 5 carries f g.
Definition curve25519_square (f : list Z) :=
  carry_squaremod 51 1 (2^255) [(1, 19)] 5 carries f.
Definition curve25519_carry (f : list Z) :=
  carrymod 51 1 (2^255) [(1, 19)] 5 carries f.

Definition poly1305_mul (f g : list Z) :=
  carry_mulmod 26 1 (2^130) [(1, 5)] 5 carries f g.
Definition poly1305_square (f : list Z) :=
  carry_squaremod 26 1 (2^130) [(1, 5)] 5 carries f.
Definition poly1305_carry (f : list Z) :=
  carrymod 26 1 (2^130) [(1, 5)] 5 carries f.

TypeScript Extraction "fields.ts"
  curve25519_mul curve25519_square curve25519_carry
  poly1305_mul poly1305_square poly1305_carry.
