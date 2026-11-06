const Nat$add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

const Pos0$sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x > y ? x - y : 1n);

const N0$sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x > y ? x - y : 0n);

const Z$add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y;

const Z$mul: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x * y;

const Z$pow: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y < 0n ? 0n : x ** y);

const Z$toNat: (_0: bigint) => bigint = (x): bigint => (x > 0 ? BigInt(x) : 0n);
const Z$ofNat: (_0: bigint) => bigint = BigInt;

const Z$div: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => {
  if (b === 0n) {
    return 0n;
  }

  const q = a / b;

  return a < 0n !== b < 0n && a % b !== 0n ? q - 1n : q;
};

const Z$modulo: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => {
  if (b === 0n) {
    return a;
  }

  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? r + b : r;
};

const Z$quot: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => (b === 0n ? 0n : a / b);

const Z$rem: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => (b === 0n ? a : a % b);

export const add = (x: bigint, x0: bigint): bigint => Z$add(x, x0);
export const mul = (x: bigint, x0: bigint): bigint => Z$mul(x, x0);
export const pow = (x: bigint, x0: bigint): bigint => Z$pow(x, x0);
export const div = (x: bigint, x0: bigint): bigint => Z$div(x, x0);
export const modulo = (x: bigint, x0: bigint): bigint => Z$modulo(x, x0);
export const quot = (x: bigint, x0: bigint): bigint => Z$quot(x, x0);
export const rem = (x: bigint, x0: bigint): bigint => Z$rem(x, x0);
export const ofNat = (x: bigint): bigint => Z$ofNat(x);
export const toNat = (x: bigint): bigint => Z$toNat(x);
export const posSub = (x: bigint, x0: bigint): bigint => Pos0$sub(x, x0);
export const nSub = (x: bigint, x0: bigint): bigint => N0$sub(x, x0);
export const natAdd = (x: bigint, x0: bigint): bigint => Nat$add(x, x0);
