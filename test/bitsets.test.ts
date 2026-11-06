import { expect, test } from "bun:test";

import { subsetSums as extracted } from "../bench/bigint/bitsets.ts";
import { subsetSums } from "../bench/bitsets.baseline.ts";
import { reachableSums } from "../bench/bitsets.support.ts";
import { ofArray } from "../bench/data.ts";

test("bitset subset sums agree with boolean-array DP across limb boundaries", () => {
  for (const weights of [
    [],
    [0, 0],
    [2, 3],
    [2, 2, 4],
    [31, 32, 63, 64, 65],
    [511, 1025],
    Array.from({ length: 128 }, (_, i) => (i * 17) % 63),
  ]) {
    const input = ofArray(weights.map(BigInt));
    const expected = reachableSums(weights);
    expect(extracted(input, 1n)).toBe(expected);
    expect(subsetSums(input, 1n)).toBe(expected);
  }
});

test("bitset DP extends an existing set of reachable sums", () => {
  const initial = reachableSums([64, 127]);
  const input = ofArray([3n, 5n]);
  const expected = reachableSums([64, 127, 3, 5]);
  expect(extracted(input, initial)).toBe(expected);
  expect(subsetSums(input, initial)).toBe(expected);
  expect(extracted(input, 0n)).toBe(0n);
});
