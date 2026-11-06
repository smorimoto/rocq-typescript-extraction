import * as $Datatypes from "./datatypes.ts";
import * as $PlainNest from "./plain-nest.ts";

const { s } = $Datatypes;
const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

export const B = $PlainNest.F(A);
