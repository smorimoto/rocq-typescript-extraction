import { expect, test } from "bun:test";

import { leb, localAdd, ltb, o, s, true0 } from "./unary-local-mixed.ts";

test("a captured local recursive producer retains ordinary constructors", () => {
  const one = s(o);
  expect(Object.isFrozen(o)).toBe(false);
  expect(Object.isFrozen(one)).toBe(false);
  expect(s(o)).not.toBe(one);
  expect(localAdd(one, one)).toStrictEqual(s(one));
  expect(leb(one, s(one))).toBe(true0);
  expect(ltb(one, s(one))).toBe(true0);
});
