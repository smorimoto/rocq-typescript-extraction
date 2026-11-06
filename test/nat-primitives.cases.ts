import { natPow } from "./nat-primitives.ts";
import { print } from "./observe.ts";

console.log("BigInt powers retain exact large operands and results");

print(natPow(9_007_199_254_740_993n, 2n));

print(natPow(3n, 100n));
