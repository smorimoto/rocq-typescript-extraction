import {
  beyond,
  default0,
  digits,
  get0,
  length,
  make,
  maxLength,
  third,
} from "./arrays.ts";
import { print } from "./observe.ts";

console.log("make fills the items with the default and caps the length");

print(maxLength);

print(make(3n, 7n));

print(make(0n, 7n));

print({ actual: length(make(4_194_303n, 7n)), expected: maxLength });

print({ actual: length(make(4_194_304n, 7n)), expected: maxLength });

print({ actual: length(make(2n ** 63n - 1n, 7n)), expected: maxLength });

console.log("get reads an item, and the default out of range");

print(get0(digits, 0n));

print(get0(digits, 2n));

print(get0(digits, 3n));

print(get0(digits, 2n ** 63n - 1n));

print(default0(digits));

print(length(digits));

print(third);

print(beyond);

print(get0(make(2n, 5n), 7n));

console.log("an array of a type with undefined values keeps its default apart");

{
  const holes = make(2n, undefined);
  print(Object.keys(holes.items));
  print(get0(holes, 0n));
  print(get0(holes, 5n));
  print(length(holes));
}
