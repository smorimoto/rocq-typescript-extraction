import { expect, test } from "bun:test";

import { frshiftexp, ldshiftexp } from "./floats.ts";

const max = Number.MAX_VALUE;

const minSubnormal = Number.MIN_VALUE;

test("ldshiftexp undoes frshiftexp", () => {
  for (const f of [12, minSubnormal, max, -0.3, 2 ** -1023]) {
    const [mantissa, exponent] = frshiftexp(f);
    expect(ldshiftexp(mantissa, exponent)).toBe(f);
  }
});
