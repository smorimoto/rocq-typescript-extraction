From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Definition pred_or (d n : nat) : nat := match n with O => d | S p => p end.
Definition pair_up (n : nat) : nat * nat := (n, S n).
Definition total (p : nat * nat) : nat := fst p + snd p.

(* Custom code that calls a match function keeps it declared and
   exported, though no match calls it. *)
Parameter describe : nat -> PrimString.string.
Extract Constant describe => "(n: number): string => matchNat(() => ""zero"", String, n)".

Local Unset Elimination Schemes.
Module Box.
  Inductive box := Empty | Full (n : nat).
  Inductive label := Label (n : nat).
  Definition open (b : box) (d : nat) : nat := match b with Empty => d | Full n => n end.
End Box.
Extract Inductive Box.box => "number" [ "-1" "((n: number): number => n)" ]
  "(<R>(empty: () => R, full: (n: number) => R, b: number): R => (b < 0 ? empty() : full(b)))".
Extract Inductive Box.label => "number" [ "((n: number): number => n)" ]
  "(<R>(f: (n: number) => R, l: number): R => f(l))".
Definition filled (n : nat) : Box.box := Box.Full n.

TypeScript Separate Extraction pred_or pair_up total describe Box filled.
