import { expect, test } from "bun:test";

import { from0, stail } from "./streams.ts";
import { ofNumber } from "./support.ts";

test("a cell is computed once and then memoised", () => {
  const s = from0(ofNumber(0));
  expect(s()).toBe(s());
  expect(stail(s)).toBe(stail(s));
});
