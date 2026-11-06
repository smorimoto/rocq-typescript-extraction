import { expect, test } from "bun:test";

import * as reference from "./nat-primitives-reference.ts";
import { natDiv2, natEven, natOdd, natPow } from "./nat-primitives.ts";

const toNat = (n: bigint): reference.Nat => {
  let result: reference.Nat = reference.o;

  for (let i = 0n; i < n; i += 1n) {
    result = reference.s(result);
  }

  return result;
};

const ofNat = (n: reference.Nat): bigint => {
  let result = 0n;
  let rest = n;

  while (rest.tag === "S") {
    result += 1n;
    rest = rest.arg0;
  }

  return result;
};

test("BigInt parity and halving agree with the raw Rocq definitions", () => {
  for (let n = 0n; n <= 128n; n += 1n) {
    const raw = toNat(n);
    expect(natEven(n)).toBe(reference.natEven(raw).tag === "True");
    expect(natOdd(n)).toBe(reference.natOdd(raw).tag === "True");
    expect(natDiv2(n)).toBe(ofNat(reference.natDiv2(raw)));
  }
});

test("BigInt powers agree with the raw Rocq definition", () => {
  for (let n = 0n; n <= 8n; n += 1n) {
    for (let m = 0n; m <= 5n; m += 1n) {
      expect(natPow(n, m)).toBe(ofNat(reference.natPow(toNat(n), toNat(m))));
    }
  }
});

test("BigInt parity and halving remain exact beyond 2^53", () => {
  const cases = [
    [9_007_199_254_740_992n, true, 4_503_599_627_370_496n],
    [9_007_199_254_740_993n, false, 4_503_599_627_370_496n],
    [9_007_199_254_740_994n, true, 4_503_599_627_370_497n],
    [
      340_282_366_920_938_463_463_374_607_431_768_211_455n,
      false,
      170_141_183_460_469_231_731_687_303_715_884_105_727n,
    ],
    [
      340_282_366_920_938_463_463_374_607_431_768_211_456n,
      true,
      170_141_183_460_469_231_731_687_303_715_884_105_728n,
    ],
  ] as const;

  for (const [n, even, half] of cases) {
    expect(natEven(n)).toBe(even);
    expect(natOdd(n)).toBe(!even);
    expect(natDiv2(n)).toBe(half);
  }
});

test("BigInt powers preserve zero exponents and constant bases", () => {
  const large = 2n ** 128n + 1n;

  for (const n of [0n, 1n, 2n, large]) {
    expect(natPow(n, 0n)).toBe(1n);
  }

  for (const exponent of [1n, 2n, 9_007_199_254_740_993n, large]) {
    expect(natPow(0n, exponent)).toBe(0n);
    expect(natPow(1n, exponent)).toBe(1n);
  }
});
