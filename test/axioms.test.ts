import { expect, test } from "bun:test";

import { boxed, keyId, roundtrip, tokens } from "./axioms.ts";

const realise = "AXIOM TO BE REALIZED";

test("an axiom throws when it is called", () => {
  expect(() => roundtrip(1)).toThrow(realise);
  expect(() => boxed(4)).toThrow(realise);
  expect(() => tokens(1)).toThrow(realise);
});

test("no object a consumer writes has the type of an axiom", () => {
  // @ts-expect-error -- a symbol is not the brand of Key
  expect(() => keyId({ brand: Symbol("Key") })).toThrow(realise);
});
