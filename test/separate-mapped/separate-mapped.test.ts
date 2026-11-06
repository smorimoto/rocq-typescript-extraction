import { expect, test } from "bun:test";

import { clamp, low, unwrap, wrapLow } from "./separate-mapped.ts";
import type { Bounds, Cell } from "./spans.ts";

test("a file builds and matches types mapped to generated types", () => {
  const b: Bounds = { hi: 5, lo: 2 };
  const w: Cell<number> = wrapLow(b);
  expect(clamp(b)).toBe(b);
  expect(low(b)).toBe(2);
  expect(w).toMatchInlineSnapshot(`
    {
      "content": 2,
      "size": 1,
    }
  `);
  expect(unwrap(w)).toBe(2);
});
