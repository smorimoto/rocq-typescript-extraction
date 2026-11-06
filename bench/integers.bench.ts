import { group } from "mitata";

import {
  collatzTotal as collatzTotalBigIntPreset,
  gcd as gcdBigIntPreset,
} from "./bigint/integers.ts";
import { collatzTotal, gcd } from "./integers.baseline.ts";
import {
  collatzTotal as collatzTotalNumberPreset,
  gcd as gcdNumberPreset,
} from "./number/integers.ts";
import { benchmarkComparison, identity } from "./support.ts";

group("Collatz steps of 1 to 1,000 on Z, fuel 200 per input", () => {
  const handWritten = collatzTotal;
  const number = collatzTotalNumberPreset;
  const bigint = collatzTotalBigIntPreset;

  benchmarkComparison({
    bigint: () => bigint(200n, 1000n),
    expected: 59_542,
    expectedBigInt: 59_542n,
    handWritten: () => handWritten(200, 1000),
    name: "collatzTotal 1000 fuel 200",
    number: () => number(200, 1000),
    observe: identity,
    observeBigInt: identity,
  });
});

group("Stdlib Euclidean GCD on Fibonacci numbers 78 and 77", () => {
  const handWritten = gcd;
  const number = gcdNumberPreset;
  const bigint = gcdBigIntPreset;

  benchmarkComparison({
    bigint: () => bigint(8_944_394_323_791_464n, 5_527_939_700_884_757n),
    expected: 1,
    expectedBigInt: 1n,
    handWritten: () =>
      handWritten(8_944_394_323_791_464, 5_527_939_700_884_757),
    name: "gcd F78 F77",
    number: () => number(8_944_394_323_791_464, 5_527_939_700_884_757),
    observe: identity,
    observeBigInt: identity,
  });
});
