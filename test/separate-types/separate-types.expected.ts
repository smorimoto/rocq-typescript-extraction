import type * as $Datatypes from "./datatypes.ts";
import * as $ListDef from "./list-def.ts";
import type * as $PrimArray from "./prim-array.ts";

const { map } = $ListDef;
export const same = (n: $Datatypes.Nat): $Datatypes.Nat => n;

export const keep = (
  a: $PrimArray.PArray<$Datatypes.Nat>
): $PrimArray.PArray<$Datatypes.Nat> => a;

export const sames = (
  l: $Datatypes.List<$Datatypes.Nat>
): $Datatypes.List<$Datatypes.Nat> => map(same, l);
