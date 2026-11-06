const s = (n: bigint): bigint => n + 1n;

const add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

const Integers$pow: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y < 0n ? 0n : x ** y);

const Integers$div: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => {
  if (b === 0n) {
    return 0n;
  }

  const q = a / b;

  return a < 0n !== b < 0n && a % b !== 0n ? q - 1n : q;
};

const Earlier$offset: (_0: bigint) => bigint = (n: bigint): bigint => n + 4n;
const Overridden$offset: (_0: bigint) => bigint = (n: bigint): bigint => n + 3n;
const Kept$identity: (_0: bigint) => bigint = (n: bigint): bigint => n;
const Unrelated$offset = (n0: bigint): bigint => add(n0, s(0n));
export const inherited = (x: bigint): bigint => Earlier$offset(x);
export const overridden = (x: bigint): bigint => Overridden$offset(x);
export const unrelated = (x: bigint): bigint => Unrelated$offset(x);

export const inlineIdentity = (x: bigint): bigint =>
  ((n: bigint): bigint => n)(x);

export const keptIdentity = (x: bigint): bigint => Kept$identity(x);
export const power = (x: bigint, x0: bigint): bigint => Integers$pow(x, x0);
export const divide = (x: bigint, x0: bigint): bigint => Integers$div(x, x0);
