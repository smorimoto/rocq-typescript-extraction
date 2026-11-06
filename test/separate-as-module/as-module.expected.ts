import * as $Datatypes from "./datatypes.ts";
import type * as $Outer from "./outer.ts";

const { s } = $Datatypes;

export type MT = number;

const M$z: number = s(s(s(s(s(s(s(0)))))));

const M = {
  z: M$z,
} as const;

export interface GResult {
  readonly z: number;
}

export const G = <T>(_Y: $Outer.S<T>): GResult => M;
export const Id = <T>(Y: $Outer.S<T>): $Outer.S<T> => Y;
