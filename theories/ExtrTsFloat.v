(** Extraction of the primitive binary64 floats to TypeScript's [number].

    These are the operations of [Corelib.Floats.PrimFloat]. The type
    [float] is [number] whatever the preset, and this file realises every
    primitive on it with the semantics of the kernel's own implementation,
    [Float64] in rocq-runtime, which is IEEE 754 arithmetic as JavaScript's
    own: [eqb] is [===], so [NaN] differs from itself and [0] equals [-0],
    while [Leibniz.eqb] is [Object.is]. [classify] tells the sign of a zero
    with [Object.is] and a subnormal by its magnitude. [frshiftexp] reads
    the exponent off the bits of the number and [next_up] and [next_down]
    step them, through a [DataView], and [ldshiftexp] scales in steps as
    musl's [scalbn] does, so a result in the subnormal range is rounded
    once. [of_uint63] is [Number], which rounds to nearest.

    [float_comparison] is the union of the string literals ["FEq"],
    ["FLt"], ["FGt"], and ["FNotComparable"], and [float_class] of
    ["PNormal"], ["NNormal"], ["PSubn"], ["NSubn"], ["PZero"], ["NZero"],
    ["PInf"], ["NInf"], and ["NaN"], so a match on either is a [switch]
    over the strings. [frshiftexp] returns the tuple of [ExtrTsBasic],
    which this file requires with its [boolean]. Like [ExtrTsBasic],
    require this file only where you extract to TypeScript. *)

From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import PrimFloat FloatClass.

Extract Inductive float_comparison => """FEq"" | ""FLt"" | ""FGt"" | ""FNotComparable"""
  [ """FEq""" """FLt""" """FGt""" """FNotComparable""" ].

Extract Inductive float_class =>
  """PNormal"" | ""NNormal"" | ""PSubn"" | ""NSubn"" | ""PZero"" | ""NZero"" | ""PInf"" | ""NInf"" | ""NaN"""
  [ """PNormal""" """NNormal""" """PSubn""" """NSubn""" """PZero""" """NZero""" """PInf"""
    """NInf""" """NaN""" ].

Extract Constant PrimFloat.classify =>
  "((f: number) => {
  if (Number.isNaN(f)) {
    return ""NaN"";
  }

  if (f === Infinity) {
    return ""PInf"";
  }

  if (f === -Infinity) {
    return ""NInf"";
  }

  if (f === 0) {
    return Object.is(f, -0) ? ""NZero"" : ""PZero"";
  }

  if (Math.abs(f) < 2 ** -1022) {
    return f > 0 ? ""PSubn"" : ""NSubn"";
  }

  return f > 0 ? ""PNormal"" : ""NNormal"";
})".

Extract Constant PrimFloat.abs => "((x: number): number => Math.abs(x))".
Extract Constant PrimFloat.sqrt => "((x: number): number => Math.sqrt(x))".
Extract Constant PrimFloat.opp => "((x: number): number => -x)".

Extract Constant PrimFloat.eqb => "((x: number, y: number): boolean => x === y)".
Extract Constant PrimFloat.ltb => "((x: number, y: number): boolean => x < y)".
Extract Constant PrimFloat.leb => "((x: number, y: number): boolean => x <= y)".
Extract Constant PrimFloat.compare =>
  "((x: number, y: number): ""FEq"" | ""FLt"" | ""FGt"" | ""FNotComparable"" => {
  if (x < y) {
    return ""FLt"";
  }

  if (x > y) {
    return ""FGt"";
  }

  return x === y ? ""FEq"" : ""FNotComparable"";
})".
Extract Constant PrimFloat.Leibniz.eqb => "((x: number, y: number): boolean => Object.is(x, y))".

Extract Constant PrimFloat.mul => "((x: number, y: number): number => x * y)".
Extract Constant PrimFloat.add => "((x: number, y: number): number => x + y)".
Extract Constant PrimFloat.sub => "((x: number, y: number): number => x - y)".
Extract Constant PrimFloat.div => "((x: number, y: number): number => x / y)".

Extract Constant PrimFloat.of_uint63 => "Number".
Extract Constant PrimFloat.normfr_mantissa =>
  "((f: number): bigint => {
  const m = Math.abs(f);

  return m >= 0.5 && m < 1 ? BigInt(m * 2 ** 53) : 0n;
})".
Extract Constant PrimFloat.frshiftexp =>
  "((f: number): readonly [number, bigint] => {
  if (f === 0 || !Number.isFinite(f)) {
    return [f, 0n];
  }

  const subnormal = Math.abs(f) < 2 ** -1022;
  const view = new DataView(new ArrayBuffer(8));
  view.setFloat64(0, subnormal ? f * 2 ** 54 : f);
  const bits = view.getBigUint64(0);
  const biased = (bits / 2n ** 52n) % 2048n;
  view.setBigUint64(0, bits - (biased - 1022n) * 2n ** 52n);

  return [view.getFloat64(0), biased + 1079n - (subnormal ? 54n : 0n)];
})".
Extract Constant PrimFloat.ldshiftexp =>
  "((f: number, e: bigint): number => {
  let y = f;
  let n = Math.min(Number(e), 4202) - 2101;

  if (n > 1023) {
    y *= 2 ** 1023;
    n -= 1023;

    if (n > 1023) {
      y *= 2 ** 1023;
      n = Math.min(n - 1023, 1023);
    }
  } else if (n < -1022) {
    y *= 2 ** -969;
    n += 969;

    if (n < -1022) {
      y *= 2 ** -969;
      n = Math.max(n + 969, -1022);
    }
  }

  return y * 2 ** n;
})".
Extract Constant PrimFloat.next_up =>
  "((f: number): number => {
  if (Number.isNaN(f) || f === Infinity) {
    return f;
  }

  if (f === 0) {
    return Number.MIN_VALUE;
  }

  const view = new DataView(new ArrayBuffer(8));
  view.setFloat64(0, f);
  const bits = view.getBigUint64(0);
  view.setBigUint64(0, f > 0 ? bits + 1n : bits - 1n);

  return view.getFloat64(0);
})".
Extract Constant PrimFloat.next_down =>
  "((f: number): number => {
  if (Number.isNaN(f) || f === -Infinity) {
    return f;
  }

  if (f === 0) {
    return -Number.MIN_VALUE;
  }

  const view = new DataView(new ArrayBuffer(8));
  view.setFloat64(0, f);
  const bits = view.getBigUint64(0);
  view.setBigUint64(0, f > 0 ? bits - 1n : bits + 1n);

  return view.getFloat64(0);
})".
