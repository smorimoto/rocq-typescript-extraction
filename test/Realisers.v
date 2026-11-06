From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Asking for a type that Extract Inductive maps asks for its realisers:
   Box.box by name, Point through its module, and nat at the top level.
   The realisers of range name the generated interface Bounds in their
   code, which is exported with them. *)
Local Unset Elimination Schemes.
Module Box.
  Inductive box := Empty | Full (n : nat).
End Box.
Extract Inductive Box.box => "number" [ "-1" "((n: number): number => n)" ]
  "(<R>(empty: () => R, full: (n: number) => R, b: number): R => (b < 0 ? empty() : full(b)))".

Module Point.
  Inductive point := Point (x y : nat).
End Point.
Extract Inductive Point.point => "readonly [number, number]"
  [ "((x: number, y: number): readonly [number, number] => [x, y])" ]
  "(<R>(f: (x: number, y: number) => R, p: readonly [number, number]): R => f(p[0], p[1]))".

Record bounds := { lo : nat; hi : nat }.
Inductive range := Range (b : bounds).
Extract Inductive range => "Bounds" [ "((b: Bounds): Bounds => b)" ]
  "(<R>(f: (b: Bounds) => R, r: Bounds): R => f(r))".

TypeScript Extraction "realisers.ts" Box.box Point nat range.
