import { expect, test } from "bun:test";

import { B, Q } from "./aliased.ts";
import {
  boxed,
  Bʹ,
  Bʹʹ,
  HA,
  K,
  KA,
  through,
  wrapped,
} from "./separate-aliased.ts";
import type { BʹʹWrapped, HACʹWrapped } from "./separate-aliased.ts";

test("an alias of an application of another file is its object", () => {
  expect(Bʹ).toBe(B);
  expect(Bʹʹ).toBe(B);

  const w: BʹʹWrapped = Bʹ.wrap(5);
  expect(w).toMatchInlineSnapshot(`
    {
      "tag": "Wrap",
      "x": 5,
    }
  `);
  expect(wrapped).toMatchInlineSnapshot(`
    {
      "tag": "Wrap",
      "x": 2,
    }
  `);
});

test("the aliases in the body of a functor of another file are members", () => {
  expect(HA.Mʹ).toBe(HA.M);
  expect(HA.Cʹ).toBe(HA.C);

  const c: HACʹWrapped = HA.Cʹ.wrap(4);
  expect(c).toMatchInlineSnapshot(`
    {
      "tag": "Wrap",
      "x": 4,
    }
  `);
  expect(boxed).toMatchInlineSnapshot(`
    {
      "tag": "Wrap",
      "x": 3,
    }
  `);
});

test("a body that aliases modules of another file", () => {
  expect(KA.L).toBe(Q);
  expect(KA.BB).toBe(B);
  expect(K<string>({ z: "z" }).k).toBe(8);
  expect(through).toBe(18);
});
