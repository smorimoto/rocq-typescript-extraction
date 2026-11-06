import * as $Datatypes from "./datatypes.ts";

const { o, s } = $Datatypes;
const Counter$start: $Datatypes.Nat = o;
const Counter$step = (n: $Datatypes.Nat): $Datatypes.Nat => s(n);

export const Counter = {
  start: Counter$start,
  step: Counter$step,
} as const;

export const Same = Counter;
