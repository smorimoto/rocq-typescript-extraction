import { expect, test } from "bun:test";

import { half } from "./peano-loops.ts";
import { ofNumber, toNumber } from "./support.ts";

test("Nat.div on Peano naturals loops at depth", () => {
  expect([0, 1, 2, 7].map((n) => toNumber(half(ofNumber(n))))).toStrictEqual([
    0, 0, 1, 3,
  ]);
  expect(toNumber(half(ofNumber(100_001)))).toBe(50_000);
});
