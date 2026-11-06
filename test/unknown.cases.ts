import { print } from "./observe.ts";
import { toNumber } from "./support.ts";
import { cons, dep, false0, nil, pr, proofs, sized, true0 } from "./unknown.ts";

console.log(
  "a result whose type depends on the argument has the union of the branch types"
);

print(dep(true0));

print({ actual: dep(false0), expected: false0 });

console.log("a constant of a logical type is undefined");

print(pr);

console.log("a proof passed to a polymorphic function is undefined");

print(toNumber(sized));

print({ actual: proofs, expected: cons(undefined, cons(undefined, nil)) });
