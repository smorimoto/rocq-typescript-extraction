const orb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a || b;

const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;

export const classify: (
  _0: number
) =>
  | "PNormal"
  | "NNormal"
  | "PSubn"
  | "NSubn"
  | "PZero"
  | "NZero"
  | "PInf"
  | "NInf"
  | "NaN" = (f: number) => {
  if (Number.isNaN(f)) {
    return "NaN";
  }

  if (f === Infinity) {
    return "PInf";
  }

  if (f === -Infinity) {
    return "NInf";
  }

  if (f === 0) {
    return Object.is(f, -0) ? "NZero" : "PZero";
  }

  if (Math.abs(f) < 2 ** -1022) {
    return f > 0 ? "PSubn" : "NSubn";
  }

  return f > 0 ? "PNormal" : "NNormal";
};

export const abs: (_0: number) => number = (x: number): number => Math.abs(x);
export const sqrt: (_0: number) => number = (x: number): number => Math.sqrt(x);
export const opp: (_0: number) => number = (x: number): number => -x;

export const eqb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x === y;

export const ltb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x < y;

export const leb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x <= y;

export const compare: (
  _0: number,
  _1: number
) => "FEq" | "FLt" | "FGt" | "FNotComparable" = (
  x: number,
  y: number
): "FEq" | "FLt" | "FGt" | "FNotComparable" => {
  if (x < y) {
    return "FLt";
  }

  if (x > y) {
    return "FGt";
  }

  return x === y ? "FEq" : "FNotComparable";
};

const Leibniz$eqb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => Object.is(x, y);

export const Leibniz = {
  eqb: Leibniz$eqb,
} as const;

export const mul: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x * y;

export const add: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

export const sub: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x - y;

export const div: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x / y;

export const ofUint63: (_0: bigint) => number = Number;

export const normfrMantissa: (_0: number) => bigint = (f: number): bigint => {
  const m = Math.abs(f);

  return m >= 0.5 && m < 1 ? BigInt(m * 2 ** 53) : 0n;
};

export const frshiftexp: (_0: number) => readonly [number, bigint] = (
  f: number
): readonly [number, bigint] => {
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
};

export const ldshiftexp: (_0: number, _1: bigint) => number = (
  f: number,
  e: bigint
): number => {
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
};

export const nextUp: (_0: number) => number = (f: number): number => {
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
};

export const nextDown: (_0: number) => number = (f: number): number => {
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
};

export const infinity = Infinity;
export const negInfinity = -Infinity;
export const nan = Number.NaN;
export const one = 1;
export const zero = 0;
export const negZero = -0;
export const two = 2;
export const isNan = (f: number): boolean => negb(eqb(f, f));
export const isZero = (f: number): boolean => eqb(f, zero);
export const isInfinity = (f: number): boolean => eqb(abs(f), infinity);

export const isFinite0 = (x: number): boolean =>
  negb(orb(isNan(x), isInfinity(x)));

export const getSign = (f: number): boolean => {
  const f0: number = isZero(f) ? div(one, f) : f;

  return ltb(f0, zero);
};

export const isNanAppliedWhereTheArgumentAloneOverflows: boolean = isNan(
  Number.NaN
);
