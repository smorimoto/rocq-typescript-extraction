import { print } from "../observe.ts";
import {
  flipped,
  inside,
  negativeOrZero,
  nested,
  pair,
  positive,
  second,
  swap,
  wild,
} from "./tuples.ts";

console.log("a tuple is an array");

print(pair(1, "a"));

print(nested(1, "a", true));

console.log("a tuple pattern reads the elements");

print(swap(1, "a"));

print(second(1, "a"));

print(wild(1, "a"));

print(inside(1, "a"));

console.log("a match on a tag inside a tuple is a conditional");

print({ actual: flipped(negativeOrZero, 1), expected: [positive, 1] });

print({ actual: flipped(positive, "a"), expected: [negativeOrZero, "a"] });
