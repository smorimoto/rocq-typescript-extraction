import {
  divide,
  inherited,
  inlineIdentity,
  keptIdentity,
  overridden,
  power,
  unrelated,
} from "./inherited-constants.ts";
import { print } from "./observe.ts";

console.log(
  "includes inherit the latest realiser without replacing explicit overrides"
);

print(inherited(10n));

print(overridden(10n));

print(unrelated(10n));

print(inlineIdentity(10n));

print(keptIdentity(10n));

console.log("integer includes preserve exact powers and floor division");

print({ actual: power(2n, 255n), expected: 2n ** 255n });

print(power(-2n, 5n));

print(power(2n, -1n));

print(divide(-7n, 2n));

print(divide(7n, -2n));

print(divide(7n, 0n));
