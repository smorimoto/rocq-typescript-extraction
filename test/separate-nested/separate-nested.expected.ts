import * as $Datatypes from "./datatypes.ts";
import * as $NestedMod from "./nested-mod.ts";

const { s } = $Datatypes;
const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type NAInnerT = $NestedMod.NestInnerT;

export const NA = $NestedMod.Nest(A);

export type ANT = $NestedMod.NestInnerT;

export const AN = NA.AsNested(A2);
export const nz: number = AN.z;
