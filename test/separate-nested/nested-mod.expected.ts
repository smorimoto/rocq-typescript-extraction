import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export type S = Record<never, never>;

export type NestInnerT = number;

export interface NestInner {
  readonly z: number;
}

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
