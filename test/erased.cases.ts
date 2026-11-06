import {
  applied,
  appliedTwice,
  applyProof,
  asValue,
  fromOption,
  localErased,
  none,
  someThree,
  three,
} from "./erased.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log("a function whose only parameter is a proof is nullary");

print(toNumber(three()));

print(toNumber(asValue()));

console.log(
  "a function-typed parameter with an erased arrow is called with no argument"
);

print(toNumber(applyProof(three)));

print(toNumber(applyProof(() => ofNumber(7))));

print(toNumber(applied));

print(toNumber(appliedTwice));

console.log("a local function with an erased binder is nullary");

print(toNumber(localErased(ofNumber(2))));

console.log(
  "a field of a function type with an erased arrow is called with no argument"
);

print(toNumber(fromOption(someThree)));

print(toNumber(fromOption(none)));
