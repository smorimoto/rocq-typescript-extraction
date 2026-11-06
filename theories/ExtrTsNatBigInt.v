(** Extraction of [nat] to TypeScript's [bigint].

    Callers must pass nonnegative bigint values; these domains are not checked.

    The Number preset, [TypeScriptExtraction.Number], makes [nat] a
    [number]. Require this file after it, or alone, to make [nat] a
    [bigint] instead, which holds integers of any size. This file requires
    [ExtrTsNatNumber] and replaces each of its directives, so [bigint]
    wins whatever the order of the [Require] commands.

    The arithmetic below is the usual JavaScript arithmetic, adjusted where
    [nat] differs: subtraction and [pred] stop at zero, and dividing by
    zero gives [0] for [Nat.div] and the dividend for [Nat.modulo]. These
    realisations are not proved correct.

    This file also replaces the conversions of Corelib's [BinNums] to
    [nat], [Pos.to_nat] and [Z.to_nat], whose parameter is a [bigint]
    with [ExtrTsBinNumsBigInt] and a [number] without it, and requires
    [ExtrTsBinNumsNumber], which realises them, so that [positive] and
    [Z] are one of the two. Like [ExtrTsBasic], require this file only
    where you extract to TypeScript. *)

From TypeScriptExtraction Require ExtrTsNatNumber ExtrTsBinNumsNumber.
From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import BinNums PosDef IntDef.

Extract Inductive nat => "bigint" [ "0n" "((n: bigint): bigint => n + 1n)" ]
  "(<R>(fO: () => R, fS: (p: bigint) => R, n: bigint): R => (n === 0n ? fO() : fS(n - 1n)))".
TypeScript Extract Match nat => [ "$0 === 0n" ] [ "$0 > 0n" "$0 - 1n" ].

Extract Constant Nat.add => "((n: bigint, m: bigint): bigint => n + m)".
Extract Constant Nat.mul => "((n: bigint, m: bigint): bigint => n * m)".
Extract Constant Nat.sub => "((n: bigint, m: bigint): bigint => (n > m ? n - m : 0n))".
Extract Constant Nat.pred => "((n: bigint): bigint => (n > 0n ? n - 1n : 0n))".
Extract Constant Nat.eqb => "((n: bigint, m: bigint): boolean => n === m)".
Extract Constant Nat.leb => "((n: bigint, m: bigint): boolean => n <= m)".
Extract Constant Nat.ltb => "((n: bigint, m: bigint): boolean => n < m)".
Extract Constant Nat.max => "((n: bigint, m: bigint): bigint => (n > m ? n : m))".
Extract Constant Nat.min => "((n: bigint, m: bigint): bigint => (n < m ? n : m))".
Extract Constant Nat.div => "((n: bigint, m: bigint): bigint => (m === 0n ? 0n : n / m))".
Extract Constant Nat.modulo =>
  "((n: bigint, m: bigint): bigint => (m === 0n ? n : n % m))".
Extract Constant Nat.even => "((n: bigint): boolean => (n & 1n) === 0n)".
Extract Constant Nat.odd => "((n: bigint): boolean => (n & 1n) === 1n)".
Extract Constant Nat.div2 => "((n: bigint): bigint => n >> 1n)".
Extract Constant Nat.pow => "((n: bigint, m: bigint): bigint => n ** m)".

Extract Constant Pos.to_nat => "BigInt".
Extract Constant Z.to_nat => "((x): bigint => (x > 0 ? BigInt(x) : 0n))".
