From Corelib Require Import BinNums IntDef.

Module Integers. Include Z. End Integers.
Module Source.
  Definition offset (n : nat) := n + 1.
  Definition identity (n : nat) := n.
End Source.
Module Earlier. Include Source. End Earlier.
Module Overridden. Include Source. End Overridden.
Module Kept. Include Source. End Kept.
Module Unrelated.
  Definition offset (n : nat) := n + 1.
End Unrelated.

From TypeScriptExtraction Require Import BigInt.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The different offsets make inheritance and explicit overrides observable. *)
Extract Constant Source.offset => "((n: bigint): bigint => n + 2n)".
Extract Inlined Constant Source.identity => "((n: bigint): bigint => n)".
Extract Constant Overridden.offset => "((n: bigint): bigint => n + 3n)".
Extraction NoInline Kept.identity.

Definition inherited := Earlier.offset.
Definition overridden := Overridden.offset.
Definition unrelated := Unrelated.offset.
Definition inline_identity (n : nat) := Earlier.identity n.
Definition kept_identity (n : nat) := Kept.identity n.
Definition power := Integers.pow.
Definition divide := Integers.div.

(* A temporary inheritance must not prevent the next command from using
   the latest mapping of the original. *)
TypeScript Extraction inherited.
Extract Constant Source.offset => "((n: bigint): bigint => n + 4n)".

TypeScript Extraction "inherited-constants.ts"
  inherited overridden unrelated inline_identity kept_identity power divide.
