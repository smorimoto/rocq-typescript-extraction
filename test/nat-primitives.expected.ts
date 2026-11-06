const even: (_0: bigint) => boolean = (n: bigint): boolean => (n & 1n) === 0n;
const odd: (_0: bigint) => boolean = (n: bigint): boolean => (n & 1n) === 1n;

const pow: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n ** m;

const div2: (_0: bigint) => bigint = (n: bigint): bigint => n >> 1n;
export const natEven = (x: bigint): boolean => even(x);
export const natOdd = (x: bigint): boolean => odd(x);
export const natDiv2 = (x: bigint): bigint => div2(x);
export const natPow = (x: bigint, x0: bigint): bigint => pow(x, x0);
