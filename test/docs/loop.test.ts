import { expect, test } from "bun:test";

import { sumTo } from "./loop.ts";

test("sumTo runs deeper than a call per step allows", () => {
  expect(sumTo(100_000, 0)).toBe(5_000_050_000);
});
