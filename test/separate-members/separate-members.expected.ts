import type * as $Datatypes from "./datatypes.ts";
import * as $Nests from "./nests.ts";
import * as $Sorts from "./sorts.ts";

const { sorted } = $Sorts;
const { filter } = $Sorts.Sort.Inner;
const O = $Nests.Outer<number>($Sorts.NatOrd);

export const twice = (l: $Datatypes.List<number>): $Datatypes.List<number> =>
  $Sorts.Sort.sort(sorted(l));

export const dropped = (l: $Datatypes.List<number>): $Datatypes.List<number> =>
  filter(O.drop(l));
