import { expect, test } from "bun:test";

import { eqb, leb } from "./lists.ts";
import { ofNumber } from "./support.ts";

test("a comparison of Peano naturals loops at depth", () => {
  const deep = ofNumber(100_000);
  expect(eqb(deep, ofNumber(100_000)).tag).toBe("True");
  expect(eqb(deep, ofNumber(99_999)).tag).toBe("False");
  expect(leb(ofNumber(99_999), deep).tag).toBe("True");
});
