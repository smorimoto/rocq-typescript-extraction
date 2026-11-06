import * as $AsModule from "./as-module.ts";
import * as $Datatypes from "./datatypes.ts";
import * as $Outer from "./outer.ts";

const { pair } = $Datatypes;

export type A2T = boolean;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type GAT = $AsModule.MT;

export const GA = $AsModule.G<boolean>(A2);

export type IAT = A2T;

export const IA = $AsModule.Id<boolean>(A2);

export interface HResult {
  readonly z: number;
}

export const H = <T>(_Y: $Outer.S<T>): HResult => $Outer.A;

export type HAT = $Outer.AT;

export const HA = H<boolean>(A2);

export const all: readonly [readonly [number, boolean], number] = pair(
  pair(GA.z, IA.z),
  HA.z
);
