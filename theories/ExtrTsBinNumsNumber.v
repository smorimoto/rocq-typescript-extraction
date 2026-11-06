(** Extraction of [positive], [N], and [Z] to TypeScript's [number].

    These are the binary numbers of [Corelib.Numbers.BinNums]. Each
    constructor is the arithmetic it stands for: [xH] is [1], [xO p] is
    [2 * p], [xI p] is [2 * p + 1], [N0] and [Z0] are [0], [Npos p] and
    [Zpos p] are [p], and [Zneg p] is [-p]. A match takes the value apart
    again, inline: a match on a [positive] [p] tests [p > 1 && p % 2 === 1]
    for [xI], with [(p - 1) / 2], then [p % 2 === 0] for [xO], with
    [p / 2], and [1] is [xH], and a match on a [Z] [z] tests [z === 0],
    then [z > 0], with [z], and [z < 0] binds [-z]. The match functions
    stay declared for custom code that calls one.

    The operations of Corelib's [BinNums] directory, [Pos] in [PosDef],
    [N] in [NatDef], and [Z] in [IntDef], are realised with the [number]
    arithmetic and keep the semantics of their definitions: [Pos.sub] is
    [1] and [N.sub] is [0] where the difference is not positive, [Z.div]
    and [Z.modulo] round down and the remainder takes the sign of the
    divisor, [Z.quot] and [Z.rem] round toward zero, dividing by zero
    gives [0] and the remainder by zero is the dividend, and no operation
    returns [-0] for inputs that are not [-0]. [Object.is] and division
    tell [-0] from [0], but every test that the extraction writes reads
    it as [0]. Bitwise operations convert to [bigint] and back, retaining
    their signed 64-bit wrapping without allocating a typed array. The
    operations whose type mentions [Pos.mask], and [Pos.iter] and
    [Pos.iter_op], whose result has any type, keep their definitions.
    Stdlib's included copies of the realised Corelib operations inherit
    these realisers unless a copy has an explicit realiser of its own.
    These realisations are not proved correct.

    The conversions between [nat] and these types, [Pos.to_nat],
    [Pos.of_succ_nat], [Z.to_nat], and [Z.of_nat], are [Number] or leave
    the type of their parameter to the declaration, since [nat] may be a
    [bigint] where these types are a [number], or the other way round.
    This file requires [ExtrTsNatNumber], so that [nat] is one of the
    two; [ExtrTsNatBigInt] replaces the conversions to [nat], and
    [ExtrTsBinNumsBigInt] the conversions from it.

    A [number] holds every integer up to [2^53] exactly, so a value beyond
    it loses precision, and TypeScript does not stop a caller from passing
    a fractional [number], or one that is not positive where a [positive]
    is expected or negative where an [N] is. This file requires
    [ExtrTsBasic] for the [boolean], the comparison, and the pair that
    the operations return. The Number preset,
    [TypeScriptExtraction.Number], requires this file. Like [ExtrTsBasic],
    require it only where you extract to TypeScript, and require
    [ExtrTsBinNumsBigInt] instead to make these types [bigint]. *)

From TypeScriptExtraction Require ExtrTsNatNumber.
From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import BinNums PosDef NatDef IntDef.

Extract Inductive positive => "number"
  [ "((p: number): number => 2 * p + 1)" "((p: number): number => 2 * p)" "1" ]
  "(<R>(onXI: (p: number) => R, onXO: (p: number) => R, onXH: () => R, p: number): R => (p === 1 ? onXH() : (p % 2 === 1 ? onXI : onXO)(Math.floor(p / 2))))".
TypeScript Extract Match positive =>
  [ "$0 > 1 && $0 % 2 === 1" "($0 - 1) / 2" ] [ "$0 % 2 === 0" "$0 / 2" ] [ "$0 === 1" ].

Extract Inductive N => "number" [ "0" "((p: number): number => p)" ]
  "(<R>(onN0: () => R, onNpos: (p: number) => R, n: number): R => (n === 0 ? onN0() : onNpos(n)))".
TypeScript Extract Match N => [ "$0 === 0" ] [ "$0 > 0" "$0" ].

Extract Inductive Z => "number"
  [ "0" "((p: number): number => p)" "((p: number): number => -p)" ]
  "(<R>(onZ0: () => R, onZpos: (p: number) => R, onZneg: (p: number) => R, z: number): R => (z === 0 ? onZ0() : (z > 0 ? onZpos : onZneg)(Math.abs(z))))".
TypeScript Extract Match Z => [ "$0 === 0" ] [ "$0 > 0" "$0" ] [ "$0 < 0" "-$0" ].

Extract Constant Pos.succ => "((x: number): number => x + 1)".
Extract Constant Pos.add => "((x: number, y: number): number => x + y)".
Extract Constant Pos.add_carry => "((x: number, y: number): number => x + y + 1)".
Extract Constant Pos.pred_double => "((x: number): number => 2 * x - 1)".
Extract Constant Pos.pred_N => "((x: number): number => x - 1)".
Extract Constant Pos.sub => "((x: number, y: number): number => (x > y ? x - y : 1))".
Extract Constant Pos.mul => "((x: number, y: number): number => x * y)".
Extract Constant Pos.div2 => "((x: number): number => (x === 1 ? 1 : Math.floor(x / 2)))".
Extract Constant Pos.div2_up => "((x: number): number => Math.ceil(x / 2))".
Extract Constant Pos.compare_cont =>
  "((r: ""Eq"" | ""Lt"" | ""Gt"", x: number, y: number): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return r;
})".
Extract Constant Pos.compare =>
  "((x: number, y: number): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant Pos.eqb => "((x: number, y: number): boolean => x === y)".
Extract Constant Pos.leb => "((x: number, y: number): boolean => x <= y)".
Extract Constant Pos.sqrt =>
  "((x: number): number => {
  const s = Math.floor(Math.sqrt(x));

  return s * s > x ? s - 1 : s;
})".
Extract Constant Pos.Nsucc_double => "((x: number): number => 2 * x + 1)".
Extract Constant Pos.Ndouble => "((x: number): number => 2 * x)".
Extract Constant Pos.lor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y))))".
Extract Constant Pos.land =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y))))".
Extract Constant Pos.ldiff =>
  "((x: number, y: number): number =>
  x - Number(BigInt.asIntN(64, BigInt(x) & BigInt(y))))".
Extract Constant Pos.lxor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y))))".
Extract Constant Pos.to_nat => "Number".
Extract Constant Pos.of_succ_nat => "((n): number => Number(n) + 1)".

Extract Constant N.succ_double => "((x: number): number => 2 * x + 1)".
Extract Constant N.double => "((x: number): number => 2 * x)".
Extract Constant N.succ_pos => "((x: number): number => x + 1)".
Extract Constant N.sub => "((x: number, y: number): number => (x > y ? x - y : 0))".
Extract Constant N.compare =>
  "((x: number, y: number): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant N.leb => "((x: number, y: number): boolean => x <= y)".
Extract Constant N.pos_div_eucl =>
  "((a: number, b: number): readonly [number, number] => {
  if (b === 0) {
    return [2 ** (a.toString(2).length - 1) - 1, a];
  }

  return [Math.floor(a / b), a % b];
})".
Extract Constant N.lor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y))))".
Extract Constant N.land =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y))))".
Extract Constant N.ldiff =>
  "((x: number, y: number): number =>
  x - Number(BigInt.asIntN(64, BigInt(x) & BigInt(y))))".
Extract Constant N.lxor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y))))".

Extract Constant Z.double => "((x: number): number => 2 * x)".
Extract Constant Z.succ_double => "((x: number): number => 2 * x + 1)".
Extract Constant Z.pred_double => "((x: number): number => 2 * x - 1)".
Extract Constant Z.pos_sub => "((x: number, y: number): number => x - y)".
Extract Constant Z.add => "((x: number, y: number): number => x + y)".
Extract Constant Z.opp => "((x: number): number => 0 - x)".
Extract Constant Z.sub => "((x: number, y: number): number => x - y)".
Extract Constant Z.mul =>
  "((x: number, y: number): number => (x === 0 || y === 0 ? 0 : x * y))".
Extract Constant Z.pow_pos => "((x: number, y: number): number => x ** y)".
Extract Constant Z.pow => "((x: number, y: number): number => (y < 0 ? 0 : x ** y))".
Extract Constant Z.compare =>
  "((x: number, y: number): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant Z.leb => "((x: number, y: number): boolean => x <= y)".
Extract Constant Z.ltb => "((x: number, y: number): boolean => x < y)".
Extract Constant Z.eqb => "((x: number, y: number): boolean => x === y)".
Extract Constant Z.max => "((x: number, y: number): number => (x < y ? y : x))".
Extract Constant Z.min => "((x: number, y: number): number => (x > y ? y : x))".
Extract Constant Z.to_nat => "((x): number => (x > 0 ? Number(x) : 0))".
Extract Constant Z.of_nat => "Number".
Extract Constant Z.of_N => "((x: number): number => x)".
Extract Constant Z.to_pos => "((x: number): number => (x > 0 ? x : 1))".
Extract Constant Z.pos_div_eucl =>
  "((a: number, b: number): readonly [number, number] => {
  if (b > 0) {
    return [Math.floor(a / b), a % b];
  }

  const top = 2 ** (a.toString(2).length - 1);

  return [2 * top - 1, a - top - b * (top - 1)];
})".
Extract Constant Z.div_eucl =>
  "((a: number, b: number): readonly [number, number] => {
  if (a === 0 || b === 0) {
    return [0, a];
  }

  const q = Math.floor(a / b);
  const r = a % b;

  if (r === 0) {
    return [q, 0];
  }

  return r < 0 === b < 0 ? [q, r] : [q, r + b];
})".
Extract Constant Z.div =>
  "((a: number, b: number): number => (a === 0 || b === 0 ? 0 : Math.floor(a / b)))".
Extract Constant Z.modulo =>
  "((a: number, b: number): number => {
  if (b === 0) {
    return a;
  }

  const r = a % b;

  if (r === 0) {
    return 0;
  }

  return r < 0 === b < 0 ? r : r + b;
})".
Extract Constant Z.quotrem =>
  "((a: number, b: number): readonly [number, number] => {
  if (b === 0) {
    return [0, a];
  }

  const q = Math.trunc(a / b);
  const r = a % b;

  return [q === 0 ? 0 : q, r === 0 ? 0 : r];
})".
Extract Constant Z.quot =>
  "((a: number, b: number): number => {
  if (b === 0) {
    return 0;
  }

  const q = Math.trunc(a / b);

  return q === 0 ? 0 : q;
})".
Extract Constant Z.rem =>
  "((a: number, b: number): number => {
  if (b === 0) {
    return a;
  }

  const r = a % b;

  return r === 0 ? 0 : r;
})".
Extract Constant Z.even => "((x: number): boolean => x % 2 === 0)".
Extract Constant Z.div2 => "((x: number): number => Math.floor(x / 2))".
Extract Constant Z.sqrtrem =>
  "((x: number): readonly [number, number] => {
  if (x <= 0) {
    return [0, 0];
  }

  const s = Math.floor(Math.sqrt(x));
  const t = s * s > x ? s - 1 : s;

  return [t, x - t * t];
})".
Extract Constant Z.shiftl =>
  "((a: number, n: number): number => {
  if (n < 0) {
    return Math.floor(a / 2 ** Math.min(-n, 1023));
  }

  return a === 0 ? 0 : a * 2 ** n;
})".
Extract Constant Z.shiftr =>
  "((a: number, n: number): number => {
  if (n > 0) {
    return Math.floor(a / 2 ** Math.min(n, 1023));
  }

  return a === 0 ? 0 : a * 2 ** -n;
})".
Extract Constant Z.lor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y))))".
Extract Constant Z.land =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y))))".
Extract Constant Z.lxor =>
  "((x: number, y: number): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y))))".
