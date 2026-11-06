import { nested, ofRed, onlyBox } from "./known-custom.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

type Colour = Parameters<typeof nested>[0];

type Box = Parameters<typeof onlyBox>[0];

const red = { tag: "red" } satisfies Colour;

const mix = (n: number): Colour => ({ n: ofNumber(n), tag: "mix" });

const empty = { tag: "empty" } satisfies Box;

const box = (n: number): Box => ({ n: ofNumber(n), tag: "box" });

console.log(
  "a nested match on a custom inductive keeps every constructor callback"
);

print(toNumber(nested(red)));

print(toNumber(nested(mix(4))));

console.log("a nested match on a constant constructor is that branch");

print(toNumber(ofRed(red)));

print(toNumber(ofRed(mix(4))));

console.log("a nested match on the first constructor keeps every callback");

print(toNumber(onlyBox(box(4))));

print(toNumber(onlyBox(empty)));
