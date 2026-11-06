export interface S<T> {
  readonly z: T;
}

export interface NestResult<T> {
  readonly AsOuter: <T0>(_Y: S<T0>) => S<T>;
}

export const Nest = <T>(X: S<T>): NestResult<T> => {
  const AsOuter = <T0>(_Y: S<T0>): S<T> => X;

  return { AsOuter };
};
