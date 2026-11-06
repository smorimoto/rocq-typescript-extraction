import { o, sizes } from "./casts.ts";
import { print } from "./observe.ts";

console.log(
  "a let-bound function with one disagreeing use computes the right value"
);

print({ actual: sizes, expected: o });
