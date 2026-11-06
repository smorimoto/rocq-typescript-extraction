import { expect, test } from "bun:test";

import { get0, length, make } from "./strings.ts";

test("make and get preserve all byte values, including zero and high bytes", () => {
  for (let byte = 0; byte < 256; byte += 1) {
    const value = BigInt(byte);
    const text = make(2n, value + 256n);
    expect(length(text)).toBe(2n);
    expect(get0(text, 0n)).toBe(value);
    expect(get0(text, 1n)).toBe(value);
    expect(get0(text, 2n)).toBe(0n);
    expect(get0(text, 2n ** 63n - 1n)).toBe(0n);
  }
});
