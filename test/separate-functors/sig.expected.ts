import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export interface S<T> {
  readonly z: T;
  readonly next0: (_0: T) => T;
  readonly map: (_0: (_: T) => T, _1: T) => T;
}

const A$z = 0;
const A$next0 = (n: number): number => s(n);
const A$map = (f: (_: number) => number, x: number): number => f(x);

export const A = {
  map: A$map,
  next0: A$next0,
  z: A$z,
} as const;
