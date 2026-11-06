import { expect, test } from "bun:test";

import { fibIter, sumTo } from "./big-loops.ts";

const deep = 100_000n;

const fib = (n: bigint): bigint => {
  let a = 0n;
  let b = 1n;

  for (let i = 0n; i < n; i += 1n) {
    [a, b] = [b, a + b];
  }

  return a;
};

test("an accumulator of bigint naturals loops at depth", () => {
  expect(sumTo(4n, 0n)).toBe(10n);
  expect(sumTo(deep, 0n)).toBe((deep * (deep + 1n)) / 2n);
});

test("the Fibonacci numbers of bigint naturals at depth", () => {
  expect([0n, 1n, 2n, 10n, 100n].map((n) => fibIter(n, 0n, 1n))).toStrictEqual([
    0n,
    1n,
    1n,
    55n,
    354_224_848_179_261_915_075n,
  ]);
  expect(fibIter(deep, 0n, 1n)).toBe(fib(deep));
});
