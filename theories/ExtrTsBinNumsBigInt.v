(** Extraction of [positive], [N], and [Z] to TypeScript's [bigint].

    Callers must pass positive values for [positive], nonnegative values
    for [N], and any integer for [Z]. These domains are not checked.

    These are the binary numbers of [Corelib.Numbers.BinNums]. Each
    constructor is the arithmetic it stands for: [xH] is [1n], [xO p] is
    [2n * p], [xI p] is [2n * p + 1n], [N0] and [Z0] are [0n], [Npos p] and
    [Zpos p] are [p], and [Zneg p] is [-p]. A match takes the value apart
    again, inline, as [ExtrTsBinNumsNumber] describes, with [bigint]
    literals. The match functions stay declared for custom code that
    calls one.

    The operations of Corelib's [BinNums] directory are realised with the
    [bigint] arithmetic, including their aliases in Stdlib, with the semantics
    that [ExtrTsBinNumsNumber] describes and on integers of any size.
    Bitwise operations use native bigint operators, preserving arbitrary
    precision and signed two's-complement semantics. A negative shift amount
    reverses the direction, and right shifts round toward negative infinity.
    This file replaces the conversions from [nat], [Pos.of_succ_nat] and
    [Z.of_nat], whose
    parameter is a [bigint] with [ExtrTsNatBigInt] and a [number]
    without it; [ExtrTsNatBigInt] replaces the conversions to [nat].
    These realisations are not proved correct.

    The Number preset, [TypeScriptExtraction.Number], makes these types
    [number]. Require this file after it, or alone, to make them [bigint]
    instead, which holds integers of any size. This file requires
    [ExtrTsBinNumsNumber] and replaces each of its directives, so [bigint]
    wins whatever the order of the [Require] commands. Like [ExtrTsBasic],
    require this file only where you extract to TypeScript. *)

From TypeScriptExtraction Require ExtrTsBinNumsNumber.
From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import BinNums PosDef NatDef IntDef.

Extract Inductive positive => "bigint"
  [ "((p: bigint): bigint => 2n * p + 1n)" "((p: bigint): bigint => 2n * p)" "1n" ]
  "(<R>(onXI: (p: bigint) => R, onXO: (p: bigint) => R, onXH: () => R, p: bigint): R => (p === 1n ? onXH() : (p % 2n === 1n ? onXI : onXO)(p / 2n)))".
TypeScript Extract Match positive =>
  [ "$0 > 1n && $0 % 2n === 1n" "$0 / 2n" ] [ "$0 % 2n === 0n" "$0 / 2n" ] [ "$0 === 1n" ].

Extract Inductive N => "bigint" [ "0n" "((p: bigint): bigint => p)" ]
  "(<R>(onN0: () => R, onNpos: (p: bigint) => R, n: bigint): R => (n === 0n ? onN0() : onNpos(n)))".
TypeScript Extract Match N => [ "$0 === 0n" ] [ "$0 > 0n" "$0" ].

Extract Inductive Z => "bigint"
  [ "0n" "((p: bigint): bigint => p)" "((p: bigint): bigint => -p)" ]
  "(<R>(onZ0: () => R, onZpos: (p: bigint) => R, onZneg: (p: bigint) => R, z: bigint): R => (z === 0n ? onZ0() : (z > 0n ? onZpos : onZneg)(z > 0n ? z : -z)))".
TypeScript Extract Match Z => [ "$0 === 0n" ] [ "$0 > 0n" "$0" ] [ "$0 < 0n" "-$0" ].

Extract Constant Pos.succ => "((x: bigint): bigint => x + 1n)".
Extract Constant Pos.add => "((x: bigint, y: bigint): bigint => x + y)".
Extract Constant Pos.add_carry => "((x: bigint, y: bigint): bigint => x + y + 1n)".
Extract Constant Pos.pred_double => "((x: bigint): bigint => 2n * x - 1n)".
Extract Constant Pos.pred_N => "((x: bigint): bigint => x - 1n)".
Extract Constant Pos.sub => "((x: bigint, y: bigint): bigint => (x > y ? x - y : 1n))".
Extract Constant Pos.mul => "((x: bigint, y: bigint): bigint => x * y)".
Extract Constant Pos.div2 => "((x: bigint): bigint => (x === 1n ? 1n : x >> 1n))".
Extract Constant Pos.div2_up => "((x: bigint): bigint => (x + 1n) >> 1n)".
Extract Constant Pos.compare_cont =>
  "((r: ""Eq"" | ""Lt"" | ""Gt"", x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return r;
})".
Extract Constant Pos.compare =>
  "((x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant Pos.eqb => "((x: bigint, y: bigint): boolean => x === y)".
Extract Constant Pos.leb => "((x: bigint, y: bigint): boolean => x <= y)".
Extract Constant Pos.sqrt =>
  "((x: bigint): bigint => {
  let s = 2n ** BigInt(Math.ceil(x.toString(2).length / 2));
  let t = (s + x / s) / 2n;

  while (t < s) {
    s = t;
    t = (s + x / s) / 2n;
  }

  return s;
})".
Extract Constant Pos.Nsucc_double => "((x: bigint): bigint => 2n * x + 1n)".
Extract Constant Pos.Ndouble => "((x: bigint): bigint => 2n * x)".
Extract Constant Pos.lor => "((x: bigint, y: bigint): bigint => x | y)".
Extract Constant Pos.land => "((x: bigint, y: bigint): bigint => x & y)".
Extract Constant Pos.ldiff => "((x: bigint, y: bigint): bigint => x & ~y)".
Extract Constant Pos.lxor => "((x: bigint, y: bigint): bigint => x ^ y)".
Extract Constant Pos.of_succ_nat => "((n): bigint => BigInt(n) + 1n)".

Extract Constant N.succ_double => "((x: bigint): bigint => 2n * x + 1n)".
Extract Constant N.double => "((x: bigint): bigint => 2n * x)".
Extract Constant N.succ_pos => "((x: bigint): bigint => x + 1n)".
Extract Constant N.sub => "((x: bigint, y: bigint): bigint => (x > y ? x - y : 0n))".
Extract Constant N.compare =>
  "((x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant N.leb => "((x: bigint, y: bigint): boolean => x <= y)".
Extract Constant N.pos_div_eucl =>
  "((a: bigint, b: bigint): readonly [bigint, bigint] => {
  if (b === 0n) {
    return [2n ** BigInt(a.toString(2).length - 1) - 1n, a];
  }

  return [a / b, a % b];
})".
Extract Constant N.lor => "((x: bigint, y: bigint): bigint => x | y)".
Extract Constant N.land => "((x: bigint, y: bigint): bigint => x & y)".
Extract Constant N.ldiff => "((x: bigint, y: bigint): bigint => x & ~y)".
Extract Constant N.lxor => "((x: bigint, y: bigint): bigint => x ^ y)".

Extract Constant Z.double => "((x: bigint): bigint => 2n * x)".
Extract Constant Z.succ_double => "((x: bigint): bigint => 2n * x + 1n)".
Extract Constant Z.pred_double => "((x: bigint): bigint => 2n * x - 1n)".
Extract Constant Z.pos_sub => "((x: bigint, y: bigint): bigint => x - y)".
Extract Constant Z.add => "((x: bigint, y: bigint): bigint => x + y)".
Extract Constant Z.opp => "((x: bigint): bigint => -x)".
Extract Constant Z.sub => "((x: bigint, y: bigint): bigint => x - y)".
Extract Constant Z.mul => "((x: bigint, y: bigint): bigint => x * y)".
Extract Constant Z.pow_pos => "((x: bigint, y: bigint): bigint => x ** y)".
Extract Constant Z.pow => "((x: bigint, y: bigint): bigint => (y < 0n ? 0n : x ** y))".
Extract Constant Z.compare =>
  "((x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant Z.leb => "((x: bigint, y: bigint): boolean => x <= y)".
Extract Constant Z.ltb => "((x: bigint, y: bigint): boolean => x < y)".
Extract Constant Z.eqb => "((x: bigint, y: bigint): boolean => x === y)".
Extract Constant Z.max => "((x: bigint, y: bigint): bigint => (x < y ? y : x))".
Extract Constant Z.min => "((x: bigint, y: bigint): bigint => (x > y ? y : x))".
Extract Constant Z.of_nat => "BigInt".
Extract Constant Z.of_N => "((x: bigint): bigint => x)".
Extract Constant Z.to_pos => "((x: bigint): bigint => (x > 0n ? x : 1n))".
Extract Constant Z.pos_div_eucl =>
  "((a: bigint, b: bigint): readonly [bigint, bigint] => {
  if (b > 0n) {
    return [a / b, a % b];
  }

  const top = 2n ** BigInt(a.toString(2).length - 1);

  return [2n * top - 1n, a - top - b * (top - 1n)];
})".
Extract Constant Z.div_eucl =>
  "((a: bigint, b: bigint): readonly [bigint, bigint] => {
  if (b === 0n) {
    return [0n, a];
  }

  const q = a / b;
  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? [q - 1n, r + b] : [q, r];
})".
Extract Constant Z.div =>
  "((a: bigint, b: bigint): bigint => {
  if (b === 0n) {
    return 0n;
  }

  const q = a / b;

  return a < 0n !== b < 0n && a % b !== 0n ? q - 1n : q;
})".
Extract Constant Z.modulo =>
  "((a: bigint, b: bigint): bigint => {
  if (b === 0n) {
    return a;
  }

  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? r + b : r;
})".
Extract Constant Z.quotrem =>
  "((a: bigint, b: bigint): readonly [bigint, bigint] => (b === 0n ? [0n, a] : [a / b, a % b]))".
Extract Constant Z.quot => "((a: bigint, b: bigint): bigint => (b === 0n ? 0n : a / b))".
Extract Constant Z.rem => "((a: bigint, b: bigint): bigint => (b === 0n ? a : a % b))".
Extract Constant Z.even => "((x: bigint): boolean => (x & 1n) === 0n)".
Extract Constant Z.div2 => "((x: bigint): bigint => x >> 1n)".
Extract Constant Z.sqrtrem =>
  "((x: bigint): readonly [bigint, bigint] => {
  if (x <= 0n) {
    return [0n, 0n];
  }

  let s = 2n ** BigInt(Math.ceil(x.toString(2).length / 2));
  let t = (s + x / s) / 2n;

  while (t < s) {
    s = t;
    t = (s + x / s) / 2n;
  }

  return [s, x - s * s];
})".
Extract Constant Z.shiftl => "((a: bigint, n: bigint): bigint => a << n)".
Extract Constant Z.shiftr => "((a: bigint, n: bigint): bigint => a >> n)".
Extract Constant Z.lor => "((x: bigint, y: bigint): bigint => x | y)".
Extract Constant Z.land => "((x: bigint, y: bigint): bigint => x & y)".
Extract Constant Z.lxor => "((x: bigint, y: bigint): bigint => x ^ y)".
