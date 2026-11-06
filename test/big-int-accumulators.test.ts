import { expect, test } from "bun:test";

import { count, sumAfter, sumBefore } from "./big-int-accumulators.ts";
import { ofArray } from "./support.ts";

const identity = (x: bigint): bigint => x;

test("bigint accumulators retain large seeds and signed sums", () => {
  const large = 2n ** 200n;
  expect(count(0n, large)).toBe(large);
  expect(count(100_000n, large)).toBe(large + 100_000n);
  expect(sumBefore(identity, ofArray([]))).toBe(0n);
  expect(sumBefore(identity, ofArray([large, 1n, -large]))).toBe(1n);
  expect(sumBefore(identity, ofArray([-large, -large, 3n]))).toBe(
    -2n * large + 3n
  );

  const values = Array.from({ length: 100_000 }, (_, i) => BigInt(i));
  expect(sumBefore(identity, ofArray(values))).toBe(4_999_950_000n);
});

test("callbacks keep their order before and after recursive calls", () => {
  const seen: bigint[] = [];

  const observe = (x: bigint): bigint => {
    seen.push(x);

    return x;
  };

  const input = ofArray([1n, 2n, 3n]);
  expect(sumBefore(observe, input)).toBe(6n);
  expect(seen).toEqual([1n, 2n, 3n]);
  seen.length = 0;
  expect(sumAfter(observe, input)).toBe(6n);
  expect(seen).toEqual([3n, 2n, 1n]);
});

test("accumulators belong to each invocation, including reentry and exceptions", () => {
  const input = ofArray([1n, 2n, 3n]);
  expect(sumBefore((x) => sumBefore(identity, ofArray([x, x])), input)).toBe(
    12n
  );
  expect(() =>
    sumBefore((x) => {
      if (x === 2n) {
        throw new Error("stop");
      }

      return x;
    }, input)
  ).toThrow("stop");
  expect(sumBefore(identity, input)).toBe(6n);
});
