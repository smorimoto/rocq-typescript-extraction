import { bitAnd, bitOr, bitXor, byteGet } from "./runtime/primitives.ts";

export const byteChecksum = (bytes: string): bigint => {
  let total = 0n;

  for (let i = 0; i < bytes.length; i += 1) {
    total += byteGet(bytes, BigInt(i));
  }

  return total;
};

export const bitwiseChecksum = (values: readonly number[]): number => {
  const mask = 6_004_799_503_160_661;
  let total = 0;

  for (const value of values) {
    total = bitOr(bitAnd(total, mask), bitXor(value, mask));
  }

  return total;
};
