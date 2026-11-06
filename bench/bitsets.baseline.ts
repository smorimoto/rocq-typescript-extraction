import type { List } from "./data.ts";

export const subsetSums = (
  weights: List<bigint>,
  reachable: bigint
): bigint => {
  let rest = weights;
  let bits = reachable;

  while (rest.tag === "Cons") {
    bits |= bits << rest.arg0;
    rest = rest.arg1;
  }

  return bits;
};
