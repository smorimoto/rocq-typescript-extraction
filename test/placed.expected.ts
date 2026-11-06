const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface S<T> {
  readonly z: T;
}

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export interface FNestedResult<T, T0> {
  readonly w: readonly [T, T0];
}

export interface FResult<T> {
  readonly Nested: <T0>(Y: S<T0>) => FNestedResult<T, T0>;
}

const F = <T>(X: S<T>): FResult<T> => {
  const Nested = <T0>(Y: S<T0>): FNestedResult<T, T0> => {
    const w0: readonly [T, T0] = pair(X.z, Y.z);

    return { w: w0 };
  };

  return { Nested };
};

export const FA = <T>(Y: S<T>): FResult<T> => F<T>(Y);
export const C = FA<number>(A);
export const CN = C.Nested<boolean>(A2);
export const w: readonly [number, boolean] = CN.w;
