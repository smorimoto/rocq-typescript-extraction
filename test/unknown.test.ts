import { expect, test } from "bun:test";

import { fallback, fromFalse } from "./unknown.ts";

test("a function whose only parameter is a proof is called with no argument", () => {
  expect(() => fromFalse()).toThrow("absurd case");
  expect(() => fallback()).toThrow("absurd case");
});
