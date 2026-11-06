import { expect, test } from "bun:test";

import { addmuldiv, asr, land, lor, lsl, lsr, lxor, mulc } from "./int63.ts";

const max = 2n ** 63n - 1n;

const signedMin = 2n ** 62n;

test("every bit retains the unsigned 63-bit boundary", () => {
  for (let i = 0n; i < 63n; i += 1n) {
    const bit = 2n ** i;
    const complement = max - bit;
    expect(land(bit, complement)).toBe(0n);
    expect(lor(bit, complement)).toBe(max);
    expect(lxor(bit, complement)).toBe(max);
    expect(lsl(1n, i)).toBe(bit);
    expect(lsr(bit, i)).toBe(1n);
    expect(mulc(bit, bit)).toEqual([
      (bit * bit) / (max + 1n),
      (bit * bit) % (max + 1n),
    ]);
  }
});

test("signed shifts round down at negative odd values and extreme counts", () => {
  for (const x of [0n, 1n, 3n, signedMin - 1n, signedMin, max - 2n, max]) {
    const signed = x < signedMin ? x : x - max - 1n;

    for (const n of [0n, 1n, 31n, 32n, 62n, 63n, 64n]) {
      const divisor = 2n ** n;
      const quotient = signed / divisor;

      const rounded =
        signed < 0n && signed % divisor !== 0n ? quotient - 1n : quotient;

      expect(asr(x, n)).toBe(rounded < 0n ? rounded + max + 1n : rounded);
      expect(addmuldiv(n, x, max)).toBe(
        n > 63n ? 0n : ((x * 2n ** n) % (max + 1n)) + max / 2n ** (63n - n)
      );
    }

    expect(asr(x, signedMin - 1n)).toBe(signed < 0n ? max : 0n);
    expect(asr(x, signedMin)).toBe(0n);
    expect(asr(x, max)).toBe(0n);
  }
});
