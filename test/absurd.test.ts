import { expect, test } from "bun:test";

import { ask, cons, head, nil } from "./absurd.ts";
import { ofNumber, toNumber } from "./support.ts";

test("an absurd branch throws only when reached", () => {
  expect(toNumber(head(cons(ofNumber(5), nil)))).toBe(5);
  expect(() => head(nil)).toThrow("absurd case");
});

test("a function-typed axiom throws when called, not when the module loads", () => {
  expect(() => ask(ofNumber(1))).toThrow("AXIOM TO BE REALIZED");
});
