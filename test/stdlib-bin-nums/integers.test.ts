import { expect, test } from "bun:test";

import {
  add,
  div,
  modulo,
  mul,
  natAdd,
  nSub,
  ofNat,
  posSub,
  pow,
  quot,
  rem,
  toNat,
} from "./integers.ts";

test("Stdlib integers preserve exact arithmetic beyond 2^53", () => {
  for (const n of [2n ** 53n + 1n, 2n ** 255n - 19n]) {
    expect(add(n, 2n)).toBe(n + 2n);
    expect(mul(n, -n)).toBe(-n * n);
    expect(pow(n, 3n)).toBe(n ** 3n);
    expect(natAdd(n, n)).toBe(n + n);
    expect(ofNat(n)).toBe(n);
    expect(toNat(n)).toBe(n);
    expect(toNat(-n)).toBe(0n);
  }

  expect(pow(-2n, 5n)).toBe(-32n);
  expect(pow(0n, 0n)).toBe(1n);
  expect(pow(2n, -1n)).toBe(0n);
  expect(posSub(3n, 5n)).toBe(1n);
  expect(nSub(3n, 5n)).toBe(0n);
});

const divisionValues = [-7n, -2n, -1n, 0n, 1n, 2n, 7n, 2n ** 255n - 19n];
const divisors = divisionValues.filter((b) => b !== 0n);

const divisionCases = divisionValues.flatMap((a) =>
  divisors.map((b) => ({ a, b }))
);

test.each(divisionCases)("Stdlib division of $a by $b", ({ a, b }) => {
  const q = div(a, b);
  const r = modulo(a, b);

  expect(a).toBe(b * q + r);

  if (b > 0n) {
    expect(r).toBeGreaterThanOrEqual(0n);
    expect(r).toBeLessThan(b);
  } else {
    expect(r).toBeLessThanOrEqual(0n);
    expect(r).toBeGreaterThan(b);
  }

  expect(quot(a, b)).toBe(a / b);
  expect(rem(a, b)).toBe(a % b);
});

test.each(divisionValues.map((a) => ({ a })))(
  "Stdlib division of $a by zero retains the dividend as the remainder",
  ({ a }) => {
    expect(div(a, 0n)).toBe(0n);
    expect(modulo(a, 0n)).toBe(a);
    expect(quot(a, 0n)).toBe(0n);
    expect(rem(a, 0n)).toBe(a);
  }
);
