import {
  Inner,
  alternates,
  applied,
  evens,
  false0,
  firsts,
  ids,
  lengths,
  nested,
  nil,
  o,
  pair,
  picked,
  s,
  tagged,
  true0,
} from "./let-poly.ts";
import { print } from "./observe.ts";
import { ofArray, ofNumber, toNumber } from "./support.ts";

const nats = (xs: number[]) => ofArray(xs.map(ofNumber));

console.log("a local identity is used at two types");

print({ actual: ids(s(o), true0), expected: pair(s(o), true0) });

console.log("a local function over lists is used on two element types");

print({
  actual: firsts(nats([2, 3]), ofArray([false0, true0])),
  expected: pair(ofNumber(2), false0),
});

print({ actual: firsts(nil, nil), expected: pair(o, false0) });

console.log("a local fix is used on two list types");

print(toNumber(lengths(nats([1, 2, 3]), ofArray([true0, false0]))));

print(toNumber(lengths(nil, nil)));

console.log("a local mutual fix is used on two list types");

print({
  actual: evens(nats([1, 2]), ofArray([true0])),
  expected: pair(true0, false0),
});

console.log("a function of a group that omits a type parameter of the group");

print({
  actual: alternates(nats([1, 2]), ofArray([true0, false0, true0, true0])),
  expected: true0,
});

print({ actual: alternates(nats([1]), nil), expected: false0 });

console.log(
  "a generic local function reads a parameter of a generic definition"
);

print({
  actual: tagged("a", s(o), true0),
  expected: pair(pair("a", s(o)), pair("a", true0)),
});

console.log("a generic local function inside a lifted one");

print({
  actual: nested(s(o), true0),
  expected: pair(pair(s(o), o), pair(true0, o)),
});

console.log("a lifted let inside an expression");

print({ actual: picked(s(o), s(o), true0), expected: pair(s(s(o)), true0) });

print({ actual: picked(s(o), o, true0), expected: pair(s(o), false0) });

print({ actual: picked(o, o, false0), expected: pair(o, false0) });

console.log(
  "a module object holds its member and not the function lifted out of it"
);

print({ actual: Inner.both(s(o), false0), expected: pair(s(o), false0) });

print(Object.keys(Inner));

console.log(
  "a partial application used at two types computes through the cast"
);

print({ actual: applied(s(o), false0), expected: pair(s(o), false0) });
