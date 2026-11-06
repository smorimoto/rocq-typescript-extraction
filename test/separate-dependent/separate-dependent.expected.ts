import * as $Datatypes from "./datatypes.ts";
import * as $Dependent from "./dependent.ts";

const { s } = $Datatypes;
const Seed$n: number = s(s(s(0)));

const Seed = {
  n: Seed$n,
} as const;

export const Made = $Dependent.Make(Seed);
export const Applied = $Dependent.Use(Made);
export const three: number = Made.dep(true);
export const no: boolean = Made.dep(false);
