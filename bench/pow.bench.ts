import { group } from "mitata";

import { powBin as powBinBigIntPreset } from "./bigint/pow.ts";
import { powBin as powBinNumberPreset } from "./number/pow.ts";
import { powBin } from "./pow.baseline.ts";
import { powBin as powBinBigInt } from "./pow.bigint-baseline.ts";
import { benchmarkComparison, benchmarkBigInt, identity } from "./support.ts";

const handWritten = powBin;
const number = powBinNumberPreset;
const bigint = powBinBigIntPreset;
const handWrittenBigInt = powBinBigInt;

group("Stdlib binary exponentiation, 3 to the 30th", () => {
  benchmarkComparison({
    bigint: () => bigint(3n, 30n),
    expected: 205_891_132_094_649,
    expectedBigInt: 205_891_132_094_649n,
    handWritten: () => handWritten(3, 30),
    name: "powBin 3 30",
    number: () => number(3, 30),
    observe: identity,
    observeBigInt: identity,
  });
});

group("Stdlib binary exponentiation, 3 to the 1,000th (bigint only)", () => {
  benchmarkBigInt({
    bigint: () => bigint(3n, 1000n),
    expected: 3n ** 1000n,
    handWritten: () => handWrittenBigInt(3n, 1000n),
    name: "powBin 3 1000",
    observe: identity,
  });
});
