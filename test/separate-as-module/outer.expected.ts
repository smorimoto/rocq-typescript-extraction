import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export interface S<T> {
  readonly z: T;
}

export type AT = number;

const A$z: number = s(0);

export const A = {
  z: A$z,
} as const;
