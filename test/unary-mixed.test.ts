import { expect, test } from "bun:test";

import { add, leb, ltb, o, s, true0 } from "./unary-mixed.ts";

test("arithmetic mixed with comparison retains ordinary constructors", () => {
  const one = s(o);
  expect(Object.isFrozen(o)).toBe(false);
  expect(Object.isFrozen(one)).toBe(false);
  expect(s(o)).not.toBe(one);
  expect(add(one, one)).toStrictEqual(s(one));
  expect(leb(one, s(one))).toBe(true0);
  expect(ltb(one, s(one))).toBe(true0);
});
