const s = (n: number): number => n + 1;

export type S = Record<never, never>;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type NestInnerT = number;

export interface NestInner {
  readonly z: number;
}

export type NestAsNestedT = number;

export interface NestAsNestedResult {
  readonly z: number;
}

export interface NestResult {
  readonly Inner: NestInner;
  readonly AsNested: (_Y: S) => NestAsNestedResult;
}

export const Nest = (_X: S): NestResult => {
  const Inner$z: number = s(s(s(s(0))));

  const Inner = {
    z: Inner$z,
  } as const;

  const AsNested = (_Y: S): NestAsNestedResult => Inner;

  return { AsNested, Inner };
};

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

export type NAInnerT = NestInnerT;

export const NA = Nest(A);

export type ANT = NestInnerT;

export const AN = NA.AsNested(A2);
export const nz: number = AN.z;
