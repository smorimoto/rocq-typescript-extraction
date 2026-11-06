import { expect, test } from "bun:test";

import {
  addEach,
  countInto,
  drift,
  fibIter,
  leaf,
  node,
  sumLocal,
  sumTo,
  treeSum,
} from "./loops.ts";
import type { Tree } from "./loops.ts";

const deep = 100_000;

const drifted = (n: number, pos: number): number => {
  let p = pos;

  for (let k = n - 1; k >= 0; k -= 1) {
    const step = k % 3;

    if (step === 0) {
      p += 2;
    } else if (step === 1) {
      p = Math.max(p - 1, 0);
    }
  }

  return p;
};

const spine = (n: number): Tree => {
  let t: Tree = leaf;

  for (let x = n; x > 0; x -= 1) {
    t = node(node(leaf, 1, leaf), x, t);
  }

  return t;
};

test("an accumulator loops at a depth a call per step overflows", () => {
  expect(sumTo(4, 0)).toBe(10);
  expect(sumTo(deep, 0)).toBe((deep * (deep + 1)) / 2);
});

test("updates that read each other's old values", () => {
  expect([0, 1, 2, 3, 10, 78].map((n) => fibIter(n, 0, 1))).toStrictEqual([
    0, 1, 1, 2, 55, 8_944_394_323_791_464,
  ]);
  expect(fibIter(deep, 3, 3)).toBe(Infinity);
  expect(fibIter(deep, 0, 0)).toBe(0);
});

test("a tail call whose argument is a match", () => {
  expect(drift(0, 5)).toBe(5);
  expect(drift(7, 0)).toBe(drifted(7, 0));
  expect(drift(deep, 1)).toBe(drifted(deep, 1));
});

test("a local fix loops in its own body", () => {
  expect(sumLocal(4)).toBe(10);
  expect(sumLocal(deep)).toBe((deep * (deep + 1)) / 2);
});

test("a function with tail and non-tail self calls loops on the tail ones", () => {
  expect(treeSum(leaf, 7)).toBe(7);
  expect(treeSum(spine(3), 0)).toBe(9);
  expect(treeSum(spine(deep), 0)).toBe((deep * (deep + 1)) / 2 + deep);
});

test("a fixpoint that returns a function takes both arguments", () => {
  expect(countInto(3, 4)).toBe(7);
  expect(countInto(deep, 0)).toBe(deep);
});

test("a function in the loop reads a parameter that every call passes on", () => {
  expect(addEach(3, 2, 1)).toBe(13);
  expect(addEach(1, deep, 0)).toBe(2 * deep);
});
