const s = (n: bigint): bigint => n + 1n;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export const naturals: readonly [readonly [bigint, bigint], bigint] = pair(
  pair(0n, s(0n)),
  s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0n)))))))))))))))))
);

export const positiveValue = 9_007_199_254_740_993n;
export const naturalValue = 18_446_744_073_709_551_617n;
export const integerValue = -18_446_744_073_709_551_617n;
export const dynamicSuccessor = (n: bigint): bigint => s(n);
const next0 = (n: bigint): bigint => n + 2n;
export const shiftedThree: bigint = next0(next0(next0(0n)));
