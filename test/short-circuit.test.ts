import { expect, test } from "bun:test";

import { behindAnd, behindAndStmt, guard } from "./short-circuit.ts";

const boom = "AXIOM TO BE REALIZED";

test("a branch behind a failing && test does not run", () => {
  expect(behindAnd(1)).toBe(0);
  expect(behindAnd(2)).toBe(2);
  expect(() => behindAnd(3)).toThrow(boom);
  expect(behindAndStmt(1, true)).toBe(0);
  expect(behindAndStmt(3, false)).toBe(1);
  expect(() => behindAndStmt(3, true)).toThrow(boom);
});

test("a statement match runs only in the taken arm of a conditional", () => {
  expect(guard(false, 0)).toBe(0);
  expect(() => guard(true, 0)).toThrow(boom);
  expect(guard(true, 4)).toBe(3);
});
