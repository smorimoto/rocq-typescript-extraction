import { describe, expect, it } from "bun:test";

import * as Monolithic from "./monolithic.ts";
import * as Separate from "./payloads.ts";

describe.each([
  ["monolithic", Monolithic],
  ["separate", Separate],
] as const)("%s", (_name, api) => {
  it("an empty branch's reconstructed type is available", () => {
    expect(api.read(true, 7n)).toBe(7n);
    // @ts-expect-error the false branch requires an inhabitant of Empty_set
    const impossible = () => api.read(false, 7n);
    expect(impossible).toThrow("absurd case");
  });
});
