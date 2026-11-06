import { expect, test } from "bun:test";

import { digits, first, plusSeven } from "./primitive-types.ts";

test("an operation on a primitive type stays an axiom without a preset", () => {
  expect(() => plusSeven(1n)).toThrow("AXIOM TO BE REALIZED");
  expect(() => first(digits)).toThrow("AXIOM TO BE REALIZED");
});
