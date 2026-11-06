import { expect, test } from "bun:test";

import { Counter, Same } from "./counter.ts";
import { o, s } from "./datatypes.ts";
import {
  Counter as SeparateCounter,
  Same as SeparateSame,
} from "./language.ts";

test("under Extraction Language Haskell, a module alias is the aliased object", () => {
  expect(Same).toBe(Counter);
  expect(Same.step(Same.start)).toStrictEqual(s(o));
});

test("a separate extraction under Extraction Language Haskell keeps the alias", () => {
  expect(SeparateSame).toBe(SeparateCounter);
  expect(SeparateSame.step(SeparateSame.start)).toStrictEqual(s(o));
});
