import {
  add,
  add0,
  digits,
  even,
  flip,
  halve,
  leaf,
  magnitude,
  minusSix,
  next0,
  node,
  size,
  swap,
  tick,
  Z,
} from "./number-preset.ts";
import { print } from "./observe.ts";

console.log("bool is boolean and nat is number");

print(even(10));

print(even(7));

console.log("a fixpoint on a tree counts in number");

{
  const t = node(node(leaf, "a", leaf), "b", leaf);
  print(size(t));
}

console.log(
  "prod is a readonly tuple, built and read by fst, snd, and a let pattern"
);

print(swap([1, 2]));

print(flip(["a", true]));

print(halve(7));

console.log("unit is undefined");

print(tick(1));

console.log("positive, N, and Z are number");

print(digits(1));

print(digits(6));

print(next0(0));

print(next0(41));

print(magnitude(-7));

print(magnitude(0));

print(minusSix);

console.log("Corelib's Z.add is the number addition");

print(Object.keys(Z).toSorted());

print(Z.add(-5, 3));

print(Z.add(5, -5));

print(Z.add(2 ** 40, 2 ** 40 - 1));

console.log("a definition named like a realiser takes the next free name");

print(add(2, 3));

print(add0(2, 3));
