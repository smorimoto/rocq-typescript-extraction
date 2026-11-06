import * as number from "./numeric-constants-number.ts";
import * as bigint from "./numeric-constants.ts";
import { print } from "./observe.ts";

console.log("integer constants retain their value and dynamic constructors");

print(bigint.naturals);

print(bigint.positiveValue);

print(bigint.naturalValue);

print(bigint.integerValue);

print(bigint.dynamicSuccessor(bigint.naturalValue));

print(number.naturals);

print({ actual: number.positiveValue, expected: Number.MAX_SAFE_INTEGER });

print({ actual: number.roundedValue, expected: 2 ** 53 });

print(number.naturalValue);

print(number.integerValue);

print(number.dynamicSuccessor(17));

console.log("custom constructors keep their arithmetic");

print(bigint.shiftedThree);

print(number.shiftedThree);

print(number.negativeZero);

print(number.doubledNegativeZero);

print(number.restoredZero);
