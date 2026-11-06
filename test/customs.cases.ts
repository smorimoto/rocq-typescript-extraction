import {
  applyPair,
  chosen,
  diagonal,
  dup,
  ends,
  firstOr,
  heavy,
  plusSeed,
  route,
  summary,
  unitSpan,
} from "./customs.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log("a parameterised Extract Inductive with a match function");

print(dup("a"));

print(firstOr([], 5));

print(firstOr([7, 8], 5));

console.log(
  "placeholders put the type arguments in the Extract Inductive type"
);

print(applyPair([(n: number) => n + 1, 1]));

print(diagonal("a"));

console.log("Extract Constant gives typed constants called uncurried");

print(toNumber(chosen));

print(toNumber(heavy));

console.log("a partial application evaluates an inlined constant once");

print(toNumber(plusSeed(ofNumber(2))));

console.log(
  "custom code calls realisers after a spread and in a template hole"
);

print(unitSpan.map(toNumber));

print(ends.map(toNumber));

print(summary);

console.log("a function type whose result is a union is one type");

print(route("a", "a", ""));

print(route("a", "b", ""));
