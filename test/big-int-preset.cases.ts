import {
  add,
  twiceRight,
  count,
  digits,
  divide,
  even,
  flip,
  halve,
  leaf,
  magnitude,
  minusSix,
  multiply,
  next0,
  node,
  origin,
  predecessor,
  primitiveArrayGet,
  primitiveFloatAdd,
  primitiveIntAdd,
  primitiveStringCat,
  remainder,
  size,
  subtract,
  swap,
  tick,
  tick0,
  Z,
} from "./big-int-preset.ts";
import { print } from "./observe.ts";

const large = 9_007_199_254_740_993n;

console.log(
  "BigInt alone accepts bigint literals, booleans, and readonly tuples"
);

print(even(10n));

print(even(7n));

print({ actual: swap([large, true]), expected: [true, large] });

print(flip(["a", false]));

print(halve(7n));

print({ actual: tick(large), expected: [undefined, large + 1n] });

console.log("standard arithmetic remains exact beyond the number boundary");

print(add(large, 2n));

print(twiceRight(large, 2n));

print(multiply(large, 3n));

print(Z.add(-large, -2n));

console.log("natural operations retain truncation and zero-divisor semantics");

print(subtract(0n, large));

print(subtract(large, large + 1n));

print(predecessor(0n));

print({ actual: predecessor(large), expected: large - 1n });

print(divide(large, 2n));

print(remainder(large, 2n));

print(divide(large, 0n));

print({ actual: remainder(large, 0n), expected: large });

console.log("recursive binary matches keep exact predecessors");

print(digits(large));

print(next0(0n));

print({ actual: next0(large), expected: large + 1n });

print({ actual: magnitude(-large), expected: large });

print(magnitude(0n));

print(minusSix);

console.log("user inductives remain tagged and recursive results use bigint");

{
  const counter = tick0(tick0(origin));
  print(counter.tag);
  print(count(counter));
  print(size(node(node(leaf, "a", leaf), "b", leaf)));
}

console.log("BigInt also realises all four primitive operation families");

print(primitiveIntAdd(2n ** 63n - 1n, 2n));

print(primitiveFloatAdd(1.5, 2.25));

print(primitiveStringCat("a", "b"));

print(primitiveArrayGet({ default: 9n, items: [3n, 4n] }, 1n));

print(primitiveArrayGet({ default: 9n, items: [3n, 4n] }, 5n));
