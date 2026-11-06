import { blue, red, shadow, topSafe } from "./evaluation-order.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log(
  "a top-level match runs only the case it takes when the module loads"
);

print(toNumber(topSafe));

console.log("a let named like the variable of a match is evaluated once");

print(toNumber(shadow(ofNumber(1), red)));

print(toNumber(shadow(ofNumber(1), blue)));
