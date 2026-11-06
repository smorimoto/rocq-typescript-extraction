(** Extraction of [nat] to TypeScript's [number].

    The arithmetic below is the usual JavaScript arithmetic, adjusted where
    [nat] differs: subtraction and [pred] stop at zero, division rounds
    down, and dividing by zero gives [0] for [Nat.div] and the dividend for
    [Nat.modulo]. A match on a [nat] is written inline, as
    [n === 0 ? x : y] or as an [if] on [n === 0] whose other branch binds
    [n - 1]. These realisations are not proved correct. A [number]
    holds every integer up to [2^53] exactly, so a [nat] beyond it loses
    precision, and TypeScript does not stop a caller from passing a
    negative or fractional [number] where a [nat] is expected. The Number
    preset, [TypeScriptExtraction.Number], requires this file. Like
    [ExtrTsBasic], require it only where you extract to TypeScript, and
    require [ExtrTsNatBigInt] instead to make [nat] a [bigint]. *)

From TypeScriptExtraction Require Import ExtrTsBasic.

Extract Inductive nat => "number" [ "0" "((n: number): number => n + 1)" ]
  "(<R>(fO: () => R, fS: (p: number) => R, n: number): R => (n === 0 ? fO() : fS(n - 1)))".
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].

Extract Constant Nat.add => "((n: number, m: number): number => n + m)".
Extract Constant Nat.mul => "((n: number, m: number): number => n * m)".
Extract Constant Nat.sub => "((n: number, m: number): number => (n > m ? n - m : 0))".
Extract Constant Nat.pred => "((n: number): number => (n > 0 ? n - 1 : 0))".
Extract Constant Nat.eqb => "((n: number, m: number): boolean => n === m)".
Extract Constant Nat.leb => "((n: number, m: number): boolean => n <= m)".
Extract Constant Nat.ltb => "((n: number, m: number): boolean => n < m)".
Extract Constant Nat.max => "((n: number, m: number): number => (n > m ? n : m))".
Extract Constant Nat.min => "((n: number, m: number): number => (n < m ? n : m))".
Extract Constant Nat.div =>
  "((n: number, m: number): number => (m === 0 ? 0 : Math.floor(n / m)))".
Extract Constant Nat.modulo => "((n: number, m: number): number => (m === 0 ? n : n % m))".
