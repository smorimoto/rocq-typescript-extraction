const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export type S = Record<never, never>;

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const F$Nested$twice = (n: number): number => add(n, n);

export interface FNestedResult {
  readonly twice: (n: number) => number;
}

export interface FResult {
  readonly Nested: (_Y: S) => FNestedResult;
}

export const F = (_X: S): FResult => {
  const Nested = (_Y: S): FNestedResult => ({ twice: F$Nested$twice });

  return { Nested };
};

export const B = F(A);
