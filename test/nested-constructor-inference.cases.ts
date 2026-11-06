import type { Color, Swatch } from "./nested-constructor-inference.ts";
import {
  blue,
  cons,
  nil,
  palette,
  red,
  swatches,
} from "./nested-constructor-inference.ts";
import { print } from "./observe.ts";

console.log(
  "custom tuple constructors retain the element union of heterogeneous lists"
);

print({
  actual: palette,
  expected: cons<readonly [bigint, Color]>(
    [1n, red],
    cons<readonly [bigint, Color]>([2n, blue], nil)
  ),
});

console.log("record literals retain the element union of heterogeneous lists");

print({
  actual: swatches,
  expected: cons<Swatch>(
    { number: 1n, shade: red },
    cons<Swatch>({ number: 2n, shade: blue }, nil)
  ),
});
