import { expect, test } from "bun:test";

import { plus, times } from "./stack-peano.ts";
import { ofNumber, toNumber } from "./support.ts";

test("Nat.add on Peano naturals a million deep", () => {
  expect(toNumber(plus(ofNumber(1_000_000), ofNumber(3)))).toBe(1_000_003);
  expect(toNumber(plus(ofNumber(0), ofNumber(2)))).toBe(2);
});

test("Nat.mul on Peano naturals, a million deep through Nat.add", () => {
  expect(toNumber(times(ofNumber(2), ofNumber(500_000)))).toBe(1_000_000);
  expect(toNumber(times(ofNumber(3), ofNumber(4)))).toBe(12);
});
