import { expect, test } from "bun:test";

import { Figure } from "./plane.ts";
import { Fig } from "./separate-aliases.ts";
import type { FigT } from "./separate-aliases.ts";

test("an alias of a module of another file is its object", () => {
  expect(Fig).toBe(Figure);

  const c: FigT = Fig.circle(1);
  expect(Fig.area(c)).toBe(3);
});
