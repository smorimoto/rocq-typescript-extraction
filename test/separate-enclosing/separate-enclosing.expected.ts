import * as $Datatypes from "./datatypes.ts";
import * as $Enclosing from "./enclosing.ts";

const { s } = $Datatypes;

export type AT = number;

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export const NA = $Enclosing.Nest<number>(A);

export type AOT = AT;

export const AO = NA.AsOuter<boolean>(A2);
export const oz: number = AO.z;
