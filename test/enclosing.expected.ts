const s = (n: number): number => n + 1;

export interface S<T> {
  readonly z: T;
}

export type AT = number;

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export interface NestResult<T> {
  readonly AsOuter: <T0>(_Y: S<T0>) => S<T>;
}

export const Nest = <T>(X: S<T>): NestResult<T> => {
  const AsOuter = <T0>(_Y: S<T0>): S<T> => X;

  return { AsOuter };
};

export const NA = Nest<number>(A);

export type AOT = AT;

export const AO = NA.AsOuter<boolean>(A2);
export const oz: number = AO.z;
