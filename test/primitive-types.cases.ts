import { print } from "./observe.ts";
import {
  answer,
  digits,
  half,
  hello,
  nested,
  three,
  wrap,
} from "./primitive-types.ts";

console.log("the primitive literals are a bigint, a number, and a string");

print(answer);

print(half);

print(hello);

print(three);

console.log("a primitive array literal holds its items and its default");

print(digits);

print(wrap("x"));

print({ actual: nested.items, expected: [digits] });

print(nested.default);
