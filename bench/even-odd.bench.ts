import { group } from "mitata";

import { even as evenBigIntPreset } from "./bigint/even-odd.ts";
import { isEven } from "./even-odd.baseline.ts";
import { even as evenNumberPreset } from "./number/even-odd.ts";
import { benchmarkComparison, identity } from "./support.ts";

const handWritten = isEven;
const number = evenNumberPreset;
const bigint = evenBigIntPreset;

group("Stdlib even/odd of 5,000", () => {
  benchmarkComparison({
    bigint: () => bigint(5000n),
    expected: true,
    expectedBigInt: true,
    handWritten: () => handWritten(5000),
    name: "even 5000",
    number: () => number(5000),
    observe: identity,
    observeBigInt: identity,
  });
});
