import {
  choose,
  dash,
  dashOr,
  decide,
  dot,
  dotAnd,
  forget,
  isZero,
  nonzero,
  notb,
  nothing,
  odd,
  secondOff,
  twice,
  unflagged,
  xor,
  xorb,
} from "./booleans.ts";
import { print } from "./observe.ts";

console.log("bool is boolean, with andb, orb, and negb as constants");

print(xor(true, false));

print(xor(true, true));

print(xor(false, false));

console.log("a match on bool goes through the match function");

print(choose(true, "a", "b"));

print(choose(false, "a", "b"));

console.log("sumbool is boolean too");

print(decide(0));

print(isZero(0));

print(isZero(1));

console.log("unit is undefined");

print(nothing);

print(forget(42));

console.log(
  "a two-branch match whose bodies are the boolean literals is its test"
);

print(dotAnd(dot, true));

print(dotAnd(dash(2), true));

print(dashOr(dot, false));

print(dashOr(dash(2), false));

console.log("the negation of a test that is the scrutinee itself");

print(notb(true));

print(notb(false));

print(unflagged({ count: 1, flag: true }));

print(unflagged({ count: 1, flag: false }));

print(secondOff([true, true]));

print(secondOff([true, false]));

print(odd(3));

print(odd(4));

print(nonzero(0));

print(nonzero(5));

print(xorb(true, true));

print(xorb(true, false));

print(xorb(false, true));

print(xorb(false, false));

console.log("a let bound to a negation");

print(twice(true));

print(twice(false));
