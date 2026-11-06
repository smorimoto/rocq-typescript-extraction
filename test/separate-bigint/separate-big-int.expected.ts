import * as $Api from "./api.ts";
import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { fst, s, snd } = $Datatypes;
const { add } = $Nat;
const Seed$value: bigint = s(s(s(0n)));

const Seed = {
  value: Seed$value,
} as const;

export const Made = $Api.Pair(Seed);

export const total = (p: readonly [bigint, bigint]): bigint =>
  add(fst(p), snd(p));

export const predOr = (d: bigint, n: bigint): bigint => {
  if (n === 0n) {
    return d;
  }

  const p: bigint = n - 1n;

  return p;
};
