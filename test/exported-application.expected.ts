export interface S<T> {
  readonly z: T;
}

export type FBox<T> = T;

export interface FResult<T> {
  readonly boxRect: <A>(cell: (_: T) => A, x: T) => A;
  readonly boxRec: <A>(cell: (_: T) => A, x: T) => A;
  readonly w: T;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const boxRect = <A>(cell: (_: T) => A, x: T): A => cell(x);
  const boxRec = <A>(cell: (_: T) => A, x: T): A => cell(x);
  const w: T = X.z;

  return { boxRec, boxRect, w };
};

const A$z = 0;

const A = {
  z: A$z,
} as const;

export type BBox = FBox<number>;

export const B = F<number>(A);
