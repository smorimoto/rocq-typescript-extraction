import * as $Datatypes from "./datatypes.ts";
import * as $Placed from "./placed.ts";

const { s } = $Datatypes;
const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export const C = $Placed.FA<number>(A);
export const CN = C.Nested<boolean>(A2);
export const w: readonly [number, boolean] = CN.w;
