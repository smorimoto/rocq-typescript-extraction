import { expect, test } from "bun:test";

import type { Nat } from "./datatypes.ts";
import { false0, o, s, true0 } from "./datatypes.ts";
import { leb, ltb } from "./nat.ts";
import { below, strictlyBelow } from "./separate-unary.ts";

test("a separate comparator freezes and shares its imported constructors", () => {
  const one: Nat = s(o);
  expect(Object.isFrozen(o)).toBe(true);
  expect(Object.isFrozen(one)).toBe(true);
  expect(s(o)).toBe(one);
  expect(leb(one, s(one))).toBe(true0);
  expect(below(s(one), one)).toBe(false0);
  expect(ltb(one, s(one))).toBe(true0);
  expect(strictlyBelow(one, s(one))).toBe(true0);
  expect(strictlyBelow(one, one)).toBe(false0);
  expect(strictlyBelow(one, o)).toBe(false0);
});
