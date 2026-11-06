const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];
const xI = (p: number): number => 2 * p + 1;

export const naturals: readonly [readonly [number, number], number] = pair(
  pair(0, s(0)),
  s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))
);

export const positiveValue = 9_007_199_254_740_991;
export const roundedValue: number = xI(4_503_599_627_370_496);
export const naturalValue = 65_537;
export const integerValue = -65_537;
export const dynamicSuccessor = (n: number): number => s(n);
const next0 = (n: number): number => n + 2;
export const shiftedThree: number = next0(next0(next0(0)));
const negZ = (p: number): number => -p;
const doubleZ = (p: number): number => 2 * p;
export const negativeZero = -0;
export const doubledNegativeZero: number = doubleZ(-0);
export const restoredZero: number = negZ(-0);
