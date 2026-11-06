import { expect, test } from "bun:test";

import * as Monolithic from "./enclosing.ts";
import { Nest } from "./separate-enclosing/enclosing.ts";
import * as Separate from "./separate-enclosing/separate-enclosing.ts";

test.each([
  ["monolithic", Monolithic],
  ["separate", { ...Separate, Nest }],
] as const)(
  "%s: an enclosing functor returns its outer parameter",
  (_mode, api) => {
    const outer = { z: 1 };
    const inner = { z: true };

    expect(api.Nest(outer).AsOuter(inner)).toBe(outer);
    expect(api.NA.AsOuter(inner).z).toBe(1);
    expect(api.AO.z).toBe(1);
    expect(api.oz).toBe(1);
  }
);
