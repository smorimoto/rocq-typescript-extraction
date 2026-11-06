import { strictEqual } from "node:assert";

import { group } from "mitata";

import { bitwiseChecksum, byteChecksum } from "./runtime.support.ts";
import { arrayMake, byteMake } from "./runtime/primitives.ts";
import { checkedBench, lcg } from "./support.ts";

const defaultValue = { count: 7 };
const codes = lcg({ count: 4096, modulus: 256 });
const bytes = codes.map((code) => String.fromCharCode(code)).join("");
let byteTotal = 0n;

for (const code of codes) {
  byteTotal += BigInt(code);
}

const values = lcg({ count: 4096, modulus: 1_048_576 }).map(
  (value, i) => (i % 2 === 0 ? 1 : -1) * (value * 2 ** 32 + i)
);

let bitwiseTotal = 0n;

const mask = 6_004_799_503_160_661n;

for (const value of values) {
  bitwiseTotal = (bitwiseTotal & mask) | (BigInt(value) ^ mask);
}

const repeatedByte = "\u00FF".repeat(1024);

group("Runtime primitives", () => {
  for (const count of [1024, 65_536]) {
    const length = BigInt(count);
    checkedBench(
      `PrimArray.make ${count}`,
      () => arrayMake(length, defaultValue),
      (result) => {
        strictEqual(result.default, defaultValue);
        strictEqual(result.items.length, count);

        for (let i = 0; i < count; i += 1) {
          strictEqual(Object.hasOwn(result.items, i), true);
          strictEqual(result.items[i], defaultValue);
        }
      }
    );
  }

  checkedBench(
    "PrimString.get checksum 4096 bytes",
    () => byteChecksum(bytes),
    (result) => {
      strictEqual(result, byteTotal);
    }
  );
  checkedBench(
    "PrimString.make 1024 bytes",
    () => byteMake(1024n, 511n),
    (result) => {
      strictEqual(result, repeatedByte);
    }
  );
  checkedBench(
    "Number bitwise checksum 4096 integers",
    () => bitwiseChecksum(values),
    (result) => {
      strictEqual(result, Number(bitwiseTotal));
    }
  );
});
