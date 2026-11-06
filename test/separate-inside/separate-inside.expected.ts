import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { s } = $Datatypes;
const { add } = $Nat;
const outer: number = s(0);
const M$x: number = s(s(0));
const M$N$y: number = add(M$x, outer);

export const M = {
  N: {
    y: M$N$y,
  },
  x: M$x,
} as const;
