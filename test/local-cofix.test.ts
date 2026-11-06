import { expect, test } from "bun:test";

import { blue, force0, red, wrapBoom } from "./local-cofix.ts";
import { toNumber } from "./support.ts";

test("the match of a local cofix in a pair runs only when forced", () => {
  const pending = wrapBoom(blue);
  expect(toNumber(pending.arg0)).toBe(0);
  expect(() => force0(pending.arg1)).toThrow("AXIOM TO BE REALIZED");
  expect(toNumber(force0(wrapBoom(red).arg1))).toBe(1);
});
