import { expect, test } from "bun:test";

import * as Monolithic from "./nested-mod.ts";
import { Nest } from "./separate-nested/nested-mod.ts";
import * as Separate from "./separate-nested/separate-nested.ts";

test.each([
  ["monolithic", Monolithic],
  ["separate", { ...Separate, Nest }],
] as const)(
  "%s: a functor returns the module from its own body",
  (_mode, api) => {
    const once = api.NA.AsNested({});
    expect(once.z).toBe(4);
    expect(api.NA.AsNested({})).toBe(once);
    expect(api.Nest({}).AsNested({}).z).toBe(4);
    expect(api.AN.z).toBe(4);
    expect(api.nz).toBe(4);
  }
);
