import {
  average,
  between,
  clamp,
  distance,
  fact,
  fib,
  negate,
  previous,
  remainder,
  same,
  twice,
} from "./big-nats.ts";
import { print } from "./observe.ts";

console.log("recursion on nat goes through the match function, on bigint");

print(fact(5n));

print(fact(20n));

print(fib(10n));

console.log("comparisons return boolean");

print(between(2n, 5n, 10n));

print(between(2n, 10n, 10n));

print(same(3n, 3n));

print(same(3n, 4n));

console.log("arithmetic keeps nat's meaning at zero");

print(average(3n, 6n));

print(remainder(17n, 5n));

print(remainder(7n, 0n));

print(distance(3n, 10n));

print(previous(0n));

print(previous(5n));

console.log("positive and Z are bigint too, exact beyond 2^53");

print(twice(2n ** 70n));

print(negate(5n));

console.log("min and max");

print(clamp(0n));

print(clamp(5n));

print(clamp(50n));
