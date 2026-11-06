const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T0> {
  readonly z: T0;
  readonly next0: (_0: T0) => T0;
}

export interface T<T0> {
  readonly y: T0;
}

export interface FResult {
  readonly twice: (x: number) => number;
  readonly zero: number;
}

export const F = (X: S<number>): FResult => {
  const twice = (x: number): number => add(X.next0(X.next0(x)), s(0));
  const zero: number = X.z;

  return { twice, zero };
};

export interface GResult<T0> {
  readonly step: T0;
}

export const G =
  <T0>(X: S<T0>) =>
  (Y: T<T0>): GResult<T0> => {
    const step: T0 = X.next0(Y.y);

    return { step };
  };

const A$z = 0;
const A$next0 = (n0: number): number => add(n0, s(0));

const A = {
  next0: A$next0,
  z: A$z,
} as const;

const C$y: number = s(s(s(s(0))));

const C = {
  y: C$y,
} as const;

export const B = F(A);
export const D = G<number>(A)(C);

export type SN = S<number>;

export interface KResult {
  readonly q: number;
}

export const K = (X: SN): KResult => {
  const q: number = X.next0(X.z);

  return { q };
};

export const KA = K(A);

export interface SM {
  readonly k: number;
}

export interface HResult {
  readonly w: number;
}

export const H = (Y: SM): HResult => {
  const w: number = A$next0(Y.k);

  return { w };
};

const M$k: number = s(s(0));

const M = {
  Inner: A,
  k: M$k,
} as const;

export const HM = H(M);
export const n: number = add(add(add(B.twice(s(0)), D.step), KA.q), HM.w);
