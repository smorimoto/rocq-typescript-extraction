import { expect, test } from "bun:test";

import { discardRecord } from "./layout-gaps.ts";

test("discarded objects still evaluate each field once", () => {
  let calls = 0;

  const read = (): number => {
    calls += 1;

    return calls;
  };

  expect(discardRecord(read)).toBe(0);
  expect(calls).toBe(2);
  expect(() =>
    discardRecord(() => {
      throw new Error("field");
    })
  ).toThrow("field");
});
