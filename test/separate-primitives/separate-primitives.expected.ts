import * as $PrimArray from "./prim-array.ts";

const { get0, make } = $PrimArray;
export const zeros = (n: bigint): $PrimArray.PArray<bigint> => make(n, 0n);
export const first = (a: $PrimArray.PArray<bigint>): bigint => get0(a, 0n);
