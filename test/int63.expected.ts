export interface C0<A> {
  readonly tag: "C0";
  readonly arg0: A;
}

export interface C1<A> {
  readonly tag: "C1";
  readonly arg0: A;
}

export type Carry<A> = C0<A> | C1<A>;

export const c0 = <A>(arg0: A): Carry<A> => ({ arg0, tag: "C0" });
export const c1 = <A>(arg0: A): Carry<A> => ({ arg0, tag: "C1" });

export const lsl: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y < 63n ? BigInt.asUintN(63, x << y) : 0n);

export const lsr: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y < 63n ? x >> y : 0n);

export const land: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & y;

export const lor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x | y;

export const lxor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x ^ y;

export const asr: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => {
  const sx = BigInt.asIntN(63, x);
  const sy = BigInt.asIntN(63, y);

  if (sy < 0n) {
    return 0n;
  }

  return BigInt.asUintN(63, sx >> sy);
};

export const add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x + y);

export const sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x - y);

export const mul: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x * y);

export const mulc: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  x: bigint,
  y: bigint
): readonly [bigint, bigint] => {
  const p = x * y;

  return [p >> 63n, BigInt.asUintN(63, p)];
};

export const div: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y === 0n ? 0n : x / y);

export const mod: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y === 0n ? x : x % y);

export const divs: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => {
  const sy = BigInt.asIntN(63, y);

  return sy === 0n ? 0n : BigInt.asUintN(63, BigInt.asIntN(63, x) / sy);
};

export const mods: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => {
  const sy = BigInt.asIntN(63, y);

  return sy === 0n ? x : BigInt.asUintN(63, BigInt.asIntN(63, x) % sy);
};

export const eqb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x === y;

export const ltb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x < y;

export const leb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x <= y;

export const ltsb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => BigInt.asIntN(63, x) < BigInt.asIntN(63, y);

export const lesb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => BigInt.asIntN(63, x) <= BigInt.asIntN(63, y);

export const addc: (_0: bigint, _1: bigint) => Carry<bigint> = (
  x: bigint,
  y: bigint
) => {
  const r = BigInt.asUintN(63, x + y);

  return r < x ? { arg0: r, tag: "C1" } : { arg0: r, tag: "C0" };
};

export const addcarryc: (_0: bigint, _1: bigint) => Carry<bigint> = (
  x: bigint,
  y: bigint
) => {
  const r = BigInt.asUintN(63, x + y + 1n);

  return r <= x ? { arg0: r, tag: "C1" } : { arg0: r, tag: "C0" };
};

export const subc: (_0: bigint, _1: bigint) => Carry<bigint> = (
  x: bigint,
  y: bigint
) => {
  const r = BigInt.asUintN(63, x - y);

  return y <= x ? { arg0: r, tag: "C0" } : { arg0: r, tag: "C1" };
};

export const subcarryc: (_0: bigint, _1: bigint) => Carry<bigint> = (
  x: bigint,
  y: bigint
) => {
  const r = BigInt.asUintN(63, x - y - 1n);

  return y < x ? { arg0: r, tag: "C0" } : { arg0: r, tag: "C1" };
};

export const diveucl: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  x: bigint,
  y: bigint
): readonly [bigint, bigint] => (y === 0n ? [0n, x] : [x / y, x % y]);

export const diveucl21: (
  _0: bigint,
  _1: bigint,
  _2: bigint
) => readonly [bigint, bigint] = (
  xh: bigint,
  xl: bigint,
  y: bigint
): readonly [bigint, bigint] => {
  if (y <= xh) {
    return [0n, 0n];
  }

  const n = (xh << 63n) + xl;

  return [n / y, n % y];
};

export const addmuldiv: (_0: bigint, _1: bigint, _2: bigint) => bigint = (
  p: bigint,
  x: bigint,
  y: bigint
): bigint => (p > 63n ? 0n : BigInt.asUintN(63, x << p) + (y >> (63n - p)));

export const compare: (_0: bigint, _1: bigint) => "Eq" | "Lt" | "Gt" = (
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

export const compares: (_0: bigint, _1: bigint) => "Eq" | "Lt" | "Gt" = (
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  const sx = BigInt.asIntN(63, x);
  const sy = BigInt.asIntN(63, y);

  if (sx < sy) {
    return "Lt";
  }

  if (sx > sy) {
    return "Gt";
  }

  return "Eq";
};

export const head0: (_0: bigint) => bigint = (x: bigint): bigint =>
  x === 0n ? 63n : 63n - BigInt(x.toString(2).length);

export const tail0: (_0: bigint) => bigint = (x: bigint): bigint => {
  if (x === 0n) {
    return 63n;
  }

  const digits = x.toString(2);

  return BigInt(digits.length - 1 - digits.lastIndexOf("1"));
};
