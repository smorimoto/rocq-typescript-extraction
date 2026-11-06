import { group } from "mitata";

import * as bigint from "./bigint/bst.ts";
import * as handWritten from "./bst.baseline.ts";
import * as number from "./number/bst.ts";
import { benchmarkComparison, identity, lcg } from "./support.ts";

const draws = lcg({ count: 2000, modulus: 1000 });
const keys = draws.slice(0, 1000);
const probes = draws.slice(1000);
const bigintKeys = keys.map(BigInt);
const bigintProbes = probes.map(BigInt);
const present = new Set(keys);
const expected = probes.filter((key) => present.has(key)).length;

const workload = <K, T>(
  implementation: {
    readonly empty: T;
    readonly insert: (key: K, tree: T) => T;
    readonly member: (key: K, tree: T) => boolean;
  },
  inputKeys: readonly K[],
  inputProbes: readonly K[]
): (() => number) => {
  const { empty, insert, member } = implementation;

  return () => {
    let tree = empty;

    for (const key of inputKeys) {
      tree = insert(key, tree);
    }

    let hits = 0;

    for (const key of inputProbes) {
      if (member(key, tree)) {
        hits += 1;
      }
    }

    return hits;
  };
};

group(
  "Stdlib persistent red-black tree, 1,000 inserts and 1,000 lookups",
  () => {
    benchmarkComparison({
      bigint: workload(bigint, bigintKeys, bigintProbes),
      expected,
      expectedBigInt: expected,
      handWritten: workload(handWritten, keys, probes),
      name: "red-black set",
      number: workload(number, keys, probes),
      observe: identity,
      observeBigInt: identity,
    });
  }
);
