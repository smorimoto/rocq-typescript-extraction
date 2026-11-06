const add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

const even: (_0: bigint) => boolean = (n: bigint): boolean => (n & 1n) === 0n;
const odd: (_0: bigint) => boolean = (n: bigint): boolean => (n & 1n) === 1n;

const pow: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n ** m;

const div2: (_0: bigint) => bigint = (n: bigint): bigint => n >> 1n;
const Pos$toNat: (_0: bigint) => bigint = BigInt;
const Pos$ofSuccNat: (_0: bigint) => bigint = (n): bigint => BigInt(n) + 1n;
const Z$toNat: (_0: bigint) => bigint = (x): bigint => (x > 0 ? BigInt(x) : 0n);
const Z$ofNat: (_0: bigint) => bigint = BigInt;
export const fromPositive = (x: bigint): bigint => Pos$toNat(x);
export const fromInteger = (x: bigint): bigint => Z$toNat(x);
export const toPositive = (x: bigint): bigint => Pos$ofSuccNat(x);
export const toInteger = (x: bigint): bigint => Z$ofNat(x);
export const add0 = (x: bigint, x0: bigint): bigint => add(x, x0);
export const natEven = (x: bigint): boolean => even(x);
export const natOdd = (x: bigint): boolean => odd(x);
export const natDiv2 = (x: bigint): bigint => div2(x);
export const natPow = (x: bigint, x0: bigint): bigint => pow(x, x0);
