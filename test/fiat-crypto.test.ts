import { describe, expect, it, test } from "bun:test";

import {
  checkResults,
  decode,
  encode,
  fields,
  ofArray,
  toArray,
  values,
  workloads,
} from "../bench/fiat-crypto.support.ts";

describe.each(fields)("$name", (field) => {
  const xs = values(field);

  it("multiplication agrees with BigInt for every input pair", () => {
    for (const x of xs) {
      for (const y of xs) {
        expect(() =>
          checkResults(
            field,
            [field.mul(encode(field, x), encode(field, y))],
            [(x * y) % field.modulus]
          )
        ).not.toThrow();
      }
    }
  }, 60_000);

  it("square agrees with multiplication", () => {
    for (const x of xs) {
      const input = encode(field, x);
      checkResults(field, [field.square(input)], [(x * x) % field.modulus]);
      expect(decode(field, field.square(input)) % field.modulus).toBe(
        decode(field, field.mul(input, input)) % field.modulus
      );
    }
  });

  it("carries propagate across every limb and wrap around the modulus", () => {
    const radix = 2n ** field.limbBits;

    const inputs = [
      ofArray(Array.from({ length: 5 }, () => 3n * (radix - 1n))),
      ofArray([0n, 0n, 0n, 0n, radix]),
      encode(field, field.modulus),
    ];

    for (const input of inputs) {
      const result = field.carry(input);
      checkResults(field, [result], [decode(field, input) % field.modulus]);
      expect(toArray(field.carry(result))).toStrictEqual(toArray(result));
    }
  });

  it("the result gate rejects missing, wrong and malformed outputs", () => {
    expect(() => checkResults(field, [], [1n])).toThrow("wrong result count");
    expect(() => checkResults(field, [encode(field, 0n)], [1n])).toThrow(
      "incorrect result"
    );
    expect(() => checkResults(field, [ofArray([1n])], [1n])).toThrow(
      "incorrect result"
    );
  });
});

test("every timed workload passes the result gate", () => {
  for (const { field, expected, run } of workloads) {
    expect(() => checkResults(field, run(), expected)).not.toThrow();
  }
});
