import {
  after,
  bump,
  even,
  firstOr,
  flip,
  isZero,
  lastOr,
  max,
  negative,
  nonneg,
  nonzero,
  pick,
  predOrZero,
  saturate,
  squareIf,
  sum,
  swap,
  total,
} from "./inline-matches.ts";
import { print } from "./observe.ts";

console.log(
  "a match on a boolean is a conditional, in a body and in an argument"
);

print(pick(true, 1, 2));

print(pick(false, 1, 2));

print(bump(true, 1, 2));

print(max(3, 5));

print(max(5, 3));

print(squareIf(true, 3));

print(squareIf(false, 3));

console.log("a match of the boolean literals is its test or the negation");

print(isZero(0));

print(isZero(4));

print(nonzero(0));

print(nonzero(4));

print(negative(-1));

print(negative(1));

print(nonneg(-1));

print(nonneg(0));

print(nonneg(1));

console.log("a match on a number binds the predecessor once per branch");

print(even(10));

print(even(7));

print(predOrZero(0));

print(predOrZero(5));

print(after([1, 2, 3]));

print(after([]));

print(saturate(0));

print(saturate(9));

console.log("a match on an array reads the head in place and binds the tail");

print(firstOr([], 7));

print(firstOr([1, 2], 7));

print(sum([1, 2, 3, 4]));

print(lastOr([], 0));

print(lastOr([4, 5, 6], 0));

console.log("a match on a tuple reads its elements in place");

print(swap([1, "a"]));

console.log("a match on three constructors is a chain of ifs");

print(flip(-1));

print(flip(0));

print(flip(1));

print(total(-1, 4));

print(total(0, 4));

print(total(1, 4));
