import { group } from "mitata";

import { mergeSort as mergeSortBigIntPreset } from "./bigint/sorts.ts";
import { mergeSort as mergeSortNumberPreset } from "./number/sorts.ts";
import { mergeSort } from "./sorts.baseline.ts";
import { benchmarkComparison, lcg, ofArray, toArray } from "./support.ts";

const values = lcg({ count: 2000, modulus: 100 });
const expected = values.toSorted((a, b) => a - b);
const numberInput = ofArray(values);
const bigintInput = ofArray(values.map(BigInt));
const bigintExpected = expected.map(BigInt);

group("Stdlib merge sort, 2,000 persistent list elements below 100", () => {
  const handWritten = mergeSort;
  const number = mergeSortNumberPreset;
  const bigint = mergeSortBigIntPreset;

  benchmarkComparison({
    bigint: () => bigint(bigintInput),
    expected,
    expectedBigInt: bigintExpected,
    handWritten: () => handWritten(numberInput),
    name: "mergeSort",
    number: () => number(numberInput),
    observe: toArray,
    observeBigInt: toArray,
  });
});
