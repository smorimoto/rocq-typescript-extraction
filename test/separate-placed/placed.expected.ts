import * as $Datatypes from "./datatypes.ts";

const { pair } = $Datatypes;

export interface S<T> {
  readonly z: T;
}

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
