import { print } from "./observe.ts";
import {
  cat,
  compare,
  eqb,
  get0,
  latin,
  length,
  make,
  maxLength,
  sub,
} from "./strings.ts";

console.log("make keeps the low byte of its character and caps the length");

print(maxLength);

print(make(3n, 97n));

print(make(3n, 353n));

print(make(0n, 97n));

print({ actual: length(make(16_777_216n, 97n)), expected: maxLength });

print({ actual: length(make(2n ** 63n - 1n, 97n)), expected: maxLength });

console.log("get reads a byte, and 0 out of range");

print(length("hello"));

print(get0("hello", 1n));

print(get0("hello", 5n));

print(get0("hello", 2n ** 63n - 1n));

print(get0("hello", 0n));

print(get0("", 0n));

console.log("sub clamps its length to the end and gives nothing past it");

print(sub("hello", 1n, 3n));

print(sub("hello", 1n, 10n));

print(sub("hello", 5n, 1n));

print(sub("hello", 6n, 1n));

print(sub("hello", 0n, 0n));

print(sub("hello", 2n ** 63n - 1n, 2n ** 63n - 1n));

print(sub("hello", 1n, 2n ** 63n - 1n));

print(sub("hello", 0n, 5n));

console.log("cat keeps the longest prefix of its second argument that fits");

{
  print(cat("ab", "cd"));
  print(cat("", "x"));

  const full = cat(make(maxLength, 97n), "xyz");
  print({ actual: length(full), expected: maxLength });
  print(get0(full, 16_777_210n));

  const nearlyFull = cat(make(16_777_210n, 97n), "xyz");
  print({ actual: length(nearlyFull), expected: maxLength });
  print(get0(nearlyFull, 16_777_210n));
  print(get0(nearlyFull, 16_777_209n));
}

console.log("compare orders by byte, and eqb switches over its result");

print(compare("a", "b"));

print(compare("b", "a"));

print(compare("a", "a"));

print(compare("", "a"));

print(compare("ab", "a"));

print(compare("Z", "a"));

print(compare("", ""));

print(eqb("ab", "ab"));

print(eqb("ab", "ac"));

print(eqb("", ""));

console.log("a literal holds one code unit per byte of its UTF-8");

print(length(latin));

print(get0(latin, 1n));

print(get0(latin, 2n));

print(compare(latin, "h~"));
