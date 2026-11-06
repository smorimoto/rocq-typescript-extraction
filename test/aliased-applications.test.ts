import { expect, test } from "bun:test";

import {
  B,
  Bʹ,
  Bʹʹ,
  F,
  G,
  H,
  HA,
  members,
  Q,
  through,
  wrapped,
} from "./aliased-applications.ts";
import type {
  BʹʹWrapped,
  BʹWrapped,
  BWrapped,
} from "./aliased-applications.ts";

test("an alias of an application, and of that alias, is its object", () => {
  expect(Bʹ).toBe(B);
  expect(Bʹʹ).toBe(B);
  expect(Bʹʹ.w).toBe(1);
  expect(through).toBe(4);

  const w: BWrapped = Bʹ.wrap(5);
  const same: BʹWrapped = w;
  const again: BʹʹWrapped = same;
  expect(again).toMatchInlineSnapshot(`
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

test("an alias of a functor is the functor", () => {
  expect(G).toBe(F);
  expect(G<string>({ N: { n: "n" }, z: "z" }).w).toBe("z");
});

test("an alias in a functor body is a member of the result", () => {
  expect(HA.Mʹ).toBe(HA.M);
  expect(HA.Cʹ).toBe(HA.C);
  expect(HA.CI).toBe(HA.C.Inner);
  expect(HA.B2).toBe(B);
  expect(HA.Q2).toBe(Q);
  expect(HA.Y.z).toBe(1);
  expect(HA.YN.n).toBe(2);
  expect(members).toBe(15);
});

test("a functor with aliases in its body at another argument", () => {
  const X = { N: { n: "n" }, z: "z" };
  const R = H<string>(X);
  expect(R.Y).toBe(X);
  expect(R.YN).toBe(X.N);
  expect(R.Mʹ.q).toBe("z");
  expect(R.both).toMatchInlineSnapshot(`
    [
      "z",
      8,
    ]
  `);
});
