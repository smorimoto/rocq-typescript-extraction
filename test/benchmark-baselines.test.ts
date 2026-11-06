import { expect, test } from "bun:test";

import * as bstBigIntPreset from "../bench/bigint/bst.ts";
import * as parityBigIntPreset from "../bench/bigint/even-odd.ts";
import { fibIter as fibIterBigIntPreset } from "../bench/bigint/fib.ts";
import * as integersBigIntPreset from "../bench/bigint/integers.ts";
import { powBin as powBinBigIntPreset } from "../bench/bigint/pow.ts";
import * as sortsBigIntPreset from "../bench/bigint/sorts.ts";
import * as bst from "../bench/bst.baseline.ts";
import * as bstBigInt from "../bench/bst.bigint-baseline.ts";
import type { List } from "../bench/data.ts";
import { nil, ofArray, toArray } from "../bench/data.ts";
import * as parity from "../bench/even-odd.baseline.ts";
import * as parityBigInt from "../bench/even-odd.bigint-baseline.ts";
import { fibIter } from "../bench/fib.baseline.ts";
import { fibIter as fibIterBigInt } from "../bench/fib.bigint-baseline.ts";
import * as integers from "../bench/integers.baseline.ts";
import * as integersBigInt from "../bench/integers.bigint-baseline.ts";
import * as bstNumberPreset from "../bench/number/bst.ts";
import * as parityNumberPreset from "../bench/number/even-odd.ts";
import { fibIter as fibIterNumberPreset } from "../bench/number/fib.ts";
import * as integersNumberPreset from "../bench/number/integers.ts";
import { powBin as powBinNumberPreset } from "../bench/number/pow.ts";
import * as sortsNumberPreset from "../bench/number/sorts.ts";
import { powBin } from "../bench/pow.baseline.ts";
import { powBin as powBinBigInt } from "../bench/pow.bigint-baseline.ts";
import * as sorts from "../bench/sorts.baseline.ts";
import * as sortsBigInt from "../bench/sorts.bigint-baseline.ts";

const freezeList = <A>(list: List<A>): List<A> => {
  let rest = list;

  while (rest.tag === "Cons") {
    Object.freeze(rest);
    rest = rest.arg1;
  }

  Object.freeze(rest);

  return list;
};

const sortCases = [
  [],
  [1],
  [3, 1, 2],
  [2, 1, 2, 0, 1, 0],
  [0, 1, 2, 3, 4, 5],
  [5, 4, 3, 2, 1, 0],
];

test("number sorts preserve frozen lists and match extracted structure", () => {
  for (const values of sortCases) {
    const input = freezeList(ofArray(values));
    const expected = ofArray(values.toSorted((a, b) => a - b));
    const result = sorts.mergeSort(input);
    expect(result).toStrictEqual(expected);
    expect(result).toStrictEqual(sortsNumberPreset.mergeSort(input));
    expect(toArray(input)).toStrictEqual(values);
  }
});

test("bigint sorts preserve frozen lists and match extracted structure", () => {
  for (const values of sortCases) {
    const input = freezeList(ofArray(values.map(BigInt)));
    const expected = ofArray(values.toSorted((a, b) => a - b).map(BigInt));
    const result = sortsBigInt.mergeSort(input);
    expect(result).toStrictEqual(expected);
    expect(result).toStrictEqual(sortsBigIntPreset.mergeSort(input));
    expect(toArray(input)).toStrictEqual(values.map(BigInt));
  }
});

test("merge retains the untouched suffix", () => {
  const suffix = freezeList(ofArray([2, 3]));
  expect(sorts.merge(nil, suffix)).toBe(suffix);
  const merged = sorts.merge(ofArray([1]), suffix);
  expect(merged.tag === "Cons" && merged.arg1).toBe(suffix);
});

interface TreeNode<A> extends Omit<
  bstNumberPreset.TreeSetRawNode,
  "arg1" | "arg2" | "arg3"
> {
  readonly arg1: Tree<A>;
  readonly arg2: A;
  readonly arg3: Tree<A>;
}

type Tree<A> = bstNumberPreset.TreeSetRawLeaf | TreeNode<A>;

const freezeTree = <A>(tree: Tree<A>): Tree<A> => {
  const pending = [tree];
  let current = pending.pop();

  while (current !== undefined) {
    Object.freeze(current);

    if (current.tag === "Node") {
      pending.push(current.arg1, current.arg3);
    }

    current = pending.pop();
  }

  return tree;
};

interface TreeInspection<A> {
  readonly blackHeight: number;
  readonly values: A[];
}

const inspectTree = <A extends number | bigint>(
  tree: Tree<A>
): TreeInspection<A> => {
  if (tree.tag === "Leaf") {
    return { blackHeight: 1, values: [] };
  }

  const left = inspectTree(tree.arg1);
  const right = inspectTree(tree.arg3);
  expect(left.blackHeight).toBe(right.blackHeight);

  if (tree.arg0.tag === "Red") {
    for (const child of [tree.arg1, tree.arg3]) {
      expect(child.tag === "Leaf" || child.arg0.tag === "Black").toBe(true);
    }
  }

  return {
    blackHeight: left.blackHeight + (tree.arg0.tag === "Black" ? 1 : 0),
    values: [...left.values, tree.arg2, ...right.values],
  };
};

interface TreeOperations<A> {
  readonly empty: Tree<A>;
  readonly insert: (key: A, tree: Tree<A>) => Tree<A>;
  readonly member: (key: A, tree: Tree<A>) => boolean;
}

const checkPersistentTree = <A extends number | bigint>(
  values: readonly A[],
  handwritten: TreeOperations<A>,
  extracted: TreeOperations<A>
): void => {
  let handwrittenTree = handwritten.empty;
  let extractedTree = extracted.empty;
  const present = new Set<A>();

  for (const value of values) {
    freezeTree(handwrittenTree);
    freezeTree(extractedTree);
    handwrittenTree = handwritten.insert(value, handwrittenTree);
    extractedTree = extracted.insert(value, extractedTree);
    present.add(value);
    expect(handwrittenTree).toStrictEqual(extractedTree);
    expect(handwritten.member(value, handwrittenTree)).toBe(true);
    expect(extracted.member(value, extractedTree)).toBe(true);
    expect(extractedTree.tag === "Node" && extractedTree.arg0.tag).toBe(
      "Black"
    );
    expect(inspectTree(extractedTree).values).toStrictEqual(
      [...present].toSorted((a, b) => Number(a > b) - Number(a < b))
    );
  }
};

test("red-black insertion preserves set membership and balances every rotation", () => {
  for (const values of [
    [3, 2, 1],
    [3, 1, 2],
    [1, 3, 2],
    [1, 2, 3],
    [5, 2, 8, 1, 3, 7, 9, 3, 5],
    Array.from({ length: 40 }, (_, i) => i),
    Array.from({ length: 40 }, (_, i) => 39 - i),
  ]) {
    checkPersistentTree(values, bst, bstNumberPreset);
    checkPersistentTree(values.map(BigInt), bstBigInt, bstBigIntPreset);
  }

  expect(bstNumberPreset.member(1, bstNumberPreset.empty)).toBe(false);
  expect(bstBigIntPreset.member(1n, bstBigIntPreset.empty)).toBe(false);
});

const duplicateTrees = <A extends number | bigint>(
  keys: readonly [A, A, A],
  implementation: TreeOperations<A>
) => {
  let tree = implementation.empty;

  for (const key of keys) {
    tree = implementation.insert(key, tree);
  }

  freezeTree(tree);

  return {
    duplicates: [keys[0], keys[1]].map((key) =>
      implementation.insert(key, tree)
    ),
    tree,
  };
};

test("duplicate inserts copy the root and share untouched subtrees", () => {
  for (const { tree, duplicates } of [
    duplicateTrees<number>([2, 1, 3], bst),
    duplicateTrees<number>([2, 1, 3], bstNumberPreset),
    duplicateTrees<bigint>([2n, 1n, 3n], bstBigInt),
    duplicateTrees<bigint>([2n, 1n, 3n], bstBigIntPreset),
  ]) {
    if (tree.tag !== "Node") {
      throw new Error("Expected a populated tree");
    }

    for (const duplicate of duplicates) {
      expect(duplicate).not.toBe(tree);

      if (duplicate.tag !== "Node") {
        throw new Error("Expected a populated tree");
      }

      expect(duplicate.arg1).toBe(tree.arg1);
      expect(duplicate.arg3).toBe(tree.arg3);
      expect(duplicate).toStrictEqual(tree);
    }
  }
});

test("Collatz fuel and counts agree at termination and exhaustion boundaries", () => {
  for (const fuel of [0, 1, 2, 10, 100, 200]) {
    for (const count of [0, 1, 2, 10, 27]) {
      expect(integers.collatzTotal(fuel, count)).toBe(
        integersNumberPreset.collatzTotal(fuel, count)
      );
      expect(integersBigInt.collatzTotal(BigInt(fuel), BigInt(count))).toBe(
        integersBigIntPreset.collatzTotal(BigInt(fuel), BigInt(count))
      );
    }
  }

  expect(integers.collatz(0, 27)).toBe(0);
  expect(integers.collatz(110, 27)).toBe(110);
  expect(integers.collatz(200, 27)).toBe(111);
  expect(integers.collatz(200, -1)).toBe(200);
  expect(integersBigInt.collatz(200n, -1n)).toBe(200n);
  expect(integers.collatzTotal(1, 10)).toBe(9);
  expect(integersBigInt.collatzTotal(1n, 10n)).toBe(9n);
});

test("Stdlib GCD handles zero and signed inputs with a nonnegative result", () => {
  for (const [a, b, expected] of [
    [0, 0, 0],
    [7, 0, 7],
    [-7, 0, 7],
    [0, -3, 3],
    [7, 3, 1],
    [-7, 3, 1],
    [7, -3, 1],
    [-7, -3, 1],
    [-6, 3, 3],
    [1071, 462, 21],
    [462, 1071, 21],
  ] satisfies [number, number, number][]) {
    expect(integers.gcd(a, b)).toBe(expected);
    expect(integersNumberPreset.gcd(a, b)).toBe(expected);
    expect(integersBigInt.gcd(BigInt(a), BigInt(b))).toBe(BigInt(expected));
    expect(integersBigIntPreset.gcd(BigInt(a), BigInt(b))).toBe(
      BigInt(expected)
    );
  }

  expect(integers.modulo(-7, 3)).toBe(2);
  expect(integers.modulo(7, -3)).toBe(-2);
  expect(integers.modulo(-6, 3)).toBe(0);
  expect(integers.modulo(7, 0)).toBe(7);
  expect(integersBigInt.modulo(-7n, 3n)).toBe(2n);
  expect(integersBigInt.modulo(7n, -3n)).toBe(-2n);
  expect(integersBigInt.modulo(7n, 0n)).toBe(7n);
});

test("power follows the extracted exponent-bit and multiplication order", () => {
  for (const base of [0, 1, 2, 3, 7]) {
    for (const exponent of [0, 1, 2, 3, 8, 15, 30, 35, 51, 100]) {
      expect(powBin(base, exponent)).toBe(powBinNumberPreset(base, exponent));
      expect(powBinBigInt(BigInt(base), BigInt(exponent))).toBe(
        powBinBigIntPreset(BigInt(base), BigInt(exponent))
      );
      expect(powBinBigInt(BigInt(base), BigInt(exponent))).toBe(
        BigInt(base) ** BigInt(exponent)
      );
    }
  }
});

test("Fibonacci and parity match their extracted loops at small boundaries", () => {
  for (let n = 0; n <= 78; n += 1) {
    expect(fibIter(n)).toBe(fibIterNumberPreset(n));
    expect(fibIterBigInt(BigInt(n))).toBe(fibIterBigIntPreset(BigInt(n)));
    expect(parity.isEven(n)).toBe(parityNumberPreset.even(n));
    expect(parity.isOdd(n)).toBe(parityNumberPreset.odd(n));
    expect(parityBigInt.isEven(BigInt(n))).toBe(
      parityBigIntPreset.even(BigInt(n))
    );
    expect(parityBigInt.isOdd(BigInt(n))).toBe(
      parityBigIntPreset.odd(BigInt(n))
    );
  }
});

test("Stdlib merge sort stays stack-safe on long persistent lists", () => {
  const size = 20_000;
  const expected = Array.from({ length: size }, (_, i) => i);

  for (const values of [expected, expected.toReversed()]) {
    const input = freezeList(ofArray(values));
    expect(toArray(sorts.mergeSort(input))).toStrictEqual(expected);
    expect(toArray(sortsNumberPreset.mergeSort(input))).toStrictEqual(expected);
    const bigintInput = freezeList(ofArray(values.map(BigInt)));
    expect(toArray(sortsBigInt.mergeSort(bigintInput))).toStrictEqual(
      expected.map(BigInt)
    );
    expect(toArray(sortsBigIntPreset.mergeSort(bigintInput))).toStrictEqual(
      expected.map(BigInt)
    );
  }
});

test("red-black trees stay balanced after many ordered inserts", () => {
  let tree = bstNumberPreset.empty;
  let bigintTree = bstBigIntPreset.empty;
  let handwrittenTree: Tree<number> = bst.empty;
  let handwrittenBigintTree: bstBigInt.Tree = bstBigInt.empty;
  const size = 2000;

  for (let i = 0; i < size; i += 1) {
    tree = bstNumberPreset.insert(i, tree);
    bigintTree = bstBigIntPreset.insert(BigInt(i), bigintTree);
    handwrittenTree = bst.insert(i, handwrittenTree);
    handwrittenBigintTree = bstBigInt.insert(BigInt(i), handwrittenBigintTree);
  }

  expect(tree).toStrictEqual(handwrittenTree);
  expect(bigintTree).toStrictEqual(handwrittenBigintTree);
  expect(inspectTree(tree).values).toStrictEqual(
    Array.from({ length: size }, (_, i) => i)
  );
  expect(inspectTree(bigintTree).values).toStrictEqual(
    Array.from({ length: size }, (_, i) => BigInt(i))
  );
  freezeTree(tree);
  freezeTree(bigintTree);
  expect(bstNumberPreset.member(size, bstNumberPreset.insert(size, tree))).toBe(
    true
  );
  expect(
    bstBigIntPreset.member(
      BigInt(size),
      bstBigIntPreset.insert(BigInt(size), bigintTree)
    )
  ).toBe(true);
  expect(bstNumberPreset.member(size, tree)).toBe(false);
  expect(bstBigIntPreset.member(BigInt(size), bigintTree)).toBe(false);
});

test("scalar baselines remain stack-safe on deep recurrence inputs", () => {
  expect(parity.isEven(100_000)).toBe(parityNumberPreset.even(100_000));
  expect(parityBigInt.isOdd(100_001n)).toBe(parityBigIntPreset.odd(100_001n));
  expect(fibIterBigInt(20_000n)).toBe(fibIterBigIntPreset(20_000n));
  expect(integers.collatzTotal(1, 20_000)).toBe(
    integersNumberPreset.collatzTotal(1, 20_000)
  );
  expect(integersBigInt.collatzTotal(1n, 20_000n)).toBe(
    integersBigIntPreset.collatzTotal(1n, 20_000n)
  );
  const exponent = 2n ** 20_000n;
  expect(powBinBigInt(1n, exponent)).toBe(powBinBigIntPreset(1n, exponent));
});
