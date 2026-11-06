From TypeScriptExtraction Require Import Number.

Local Unset Elimination Schemes.
Module Box.
  Inductive box := Empty | Full (n : nat).
  Definition zero : nat := 0.
End Box.
Extract Inductive Box.box => "number" [ "-1" "((n: number): number => n)" ]
  "(<R>(empty: () => R, full: (n: number) => R, b: number): R => (b < 0 ? empty() : full(b)))".
