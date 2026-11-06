import { group } from "mitata";

import { fibIter as fibIterBigIntPreset } from "./bigint/fib.ts";
import { fibIter } from "./fib.baseline.ts";
import { fibIter as fibIterBigInt } from "./fib.bigint-baseline.ts";
import { fibIter as fibIterNumberPreset } from "./number/fib.ts";
import { benchmarkComparison, benchmarkBigInt, identity } from "./support.ts";

const handWritten = fibIter;
const number = fibIterNumberPreset;
const bigint = fibIterBigIntPreset;
const handWrittenBigInt = fibIterBigInt;

group("iterative Fibonacci of 78, the largest exact in a number", () => {
  benchmarkComparison({
    bigint: () => bigint(78n),
    expected: 8_944_394_323_791_464,
    expectedBigInt: 8_944_394_323_791_464n,
    handWritten: () => handWritten(78),
    name: "fibIter 78",
    number: () => number(78),
    observe: identity,
    observeBigInt: identity,
  });
});

group("iterative Fibonacci of 1,000 (bigint only)", () => {
  benchmarkBigInt({
    bigint: () => bigint(1000n),
    expected:
      43_466_557_686_937_456_435_688_527_675_040_625_802_564_660_517_371_780_402_481_729_089_536_555_417_949_051_890_403_879_840_079_255_169_295_922_593_080_322_634_775_209_689_623_239_873_322_471_161_642_996_440_906_533_187_938_298_969_649_928_516_003_704_476_137_795_166_849_228_875n,
    handWritten: () => handWrittenBigInt(1000n),
    name: "fibIter 1000",
    observe: identity,
  });
});
