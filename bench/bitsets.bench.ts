import { group } from "mitata";

import { subsetSums as extracted } from "./bigint/bitsets.ts";
import { subsetSums } from "./bitsets.baseline.ts";
import { reachableSums } from "./bitsets.support.ts";
import { benchmarkBigInt, identity, lcg, ofArray } from "./support.ts";

const weights = lcg({ count: 128, modulus: 63 }).map((weight) => weight + 1);
const input = ofArray(weights.map(BigInt));
const expected = reachableSums(weights);

group("Bitset subset-sum DP over 128 nonnegative weights", () => {
  benchmarkBigInt({
    bigint: () => extracted(input, 1n),
    expected,
    handWritten: () => subsetSums(input, 1n),
    name: "subset sums 128 weights",
    observe: identity,
  });
});
