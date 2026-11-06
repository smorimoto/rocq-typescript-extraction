const s = (n: number): number => n + 1;

export type S = Record<never, never>;

const A$z = 0;

const A = {
  z: A$z,
} as const;

export type PT = number;

const P$z: number = s(0);

export const P = {
  z: P$z,
} as const;

export interface FP {
  readonly n: number;
}

export interface FResult {
  readonly P: FP;
  readonly n: number;
}

export const F = (_X: S): FResult => {
  const P$n: number = s(0);

  const P0 = {
    n: P$n,
  } as const;

  const n: number = P$n;

  return { P: P0, n };
};

export const B = F(A);
