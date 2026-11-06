import { expect, test } from "bun:test";

import type { List } from "./insertion-sort.ts";
import { cons, insertionSort, nil } from "./insertion-sort.ts";

const ofArray = (values: readonly number[]): List<number> => {
  let list: List<number> = nil;

  for (const value of values.toReversed()) {
    list = Object.freeze(cons(value, list));
  }

  return list;
};

const toArray = (list: List<number>): number[] => {
  const values: number[] = [];
  let rest = list;

  while (rest.tag === "Cons") {
    values.push(rest.arg0);
    rest = rest.arg1;
  }

  return values;
};

test("insertion around a recursive result preserves duplicates and frozen input", () => {
  for (const values of [[], [1], [3, 1, 2, 0, 2], [5, 4, 3, 2, 1]]) {
    const input = ofArray(values);
    expect(toArray(insertionSort(input))).toStrictEqual(
      values.toSorted((a, b) => a - b)
    );
    expect(toArray(input)).toStrictEqual(values);
  }
});

test("a call used as another recursive function's argument stays stack-safe", () => {
  const values = Array.from({ length: 20_000 }, (_, i) => i);
  expect(toArray(insertionSort(ofArray(values)))).toStrictEqual(values);
});
