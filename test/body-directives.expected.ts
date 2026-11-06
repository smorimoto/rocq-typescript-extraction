const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T> {
  readonly z: T;
}

const F$double0: (_0: number) => number = (n) => 2 * n;

export interface FResult<T> {
  readonly double0: (_0: number) => number;
  readonly four: number;
  readonly keep: T;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const four: number = Math.abs(F$double0(s(s(0))));
  const keep: T = X.z;

  return { double0: F$double0, four, keep };
};

const A$z = 0;

const A = {
  z: A$z,
} as const;

export const B = F<number>(A);
export const ten: number = B.double0(s(s(s(s(s(0))))));
const G$pick: <T>(_0: T, _1: T) => T = (x, _y) => x;
const G$Inner$half: (_0: number) => number = (n) => Math.floor(n / 2);

export interface GInner {
  readonly half: (_0: number) => number;
}

export interface GResult<T> {
  readonly pick: (_0: T, _1: T) => T;
  readonly Inner: GInner;
  readonly chosen: T;
  readonly four: number;
}

export const G = <T>(X: S<T>): GResult<T> => {
  const Inner = {
    half: G$Inner$half,
  } as const;

  const chosen: T = G$pick(X.z, X.z);
  const four: number = G$Inner$half(s(s(s(s(s(s(s(s(s(0))))))))));

  return { Inner, chosen, four, pick: G$pick };
};

export const FA = <T>(Y: S<T>): FResult<T> => F<T>(Y);
export const C = FA<number>(A);
const I$double0: (_0: number) => number = (n) => 2 * n;
const I$triple: (_0: number) => number = (n) => 3 * n;

export interface IResult<T> {
  readonly double0: (_0: number) => number;
  readonly four: number;
  readonly keep: T;
  readonly triple: (_0: number) => number;
  readonly nine: number;
}

export const I = <T>(X: S<T>): IResult<T> => {
  const four: number = Math.abs(I$double0(s(s(0))));
  const keep: T = X.z;
  const nine: number = I$triple(s(s(s(0))));

  return { double0: I$double0, four, keep, nine, triple: I$triple };
};

export const IA = I<number>(A);
export const sum: number = add(add(C.four, IA.nine), IA.double0(s(0)));
