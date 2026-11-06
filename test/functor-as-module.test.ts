import { expect, test } from "bun:test";

import { both, IA, Id } from "./functor-as-module.ts";

test("a functor defined as its parameter returns its argument", () => {
  const argument = { z: "s" };
  expect(Id<string>(argument)).toBe(argument);
  expect(IA.z).toBe(true);
  expect(both).toMatchInlineSnapshot(`
    [
      0,
      true,
    ]
  `);
});
