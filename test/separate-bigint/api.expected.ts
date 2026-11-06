import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { pair, s } = $Datatypes;
const { add } = $Nat;

export interface INPUT {
  readonly value: bigint;
}

export interface PairResult {
  readonly values: readonly [bigint, bigint];
  readonly total: bigint;
}

export const Pair = (X: INPUT): PairResult => {
  const values: readonly [bigint, bigint] = pair(X.value, s(X.value));
  const total0: bigint = add(X.value, s(X.value));

  return { total: total0, values };
};
