import {
  add3,
  add4,
  addOne,
  addSucc,
  adders,
  applyTwice,
  false0,
  fullSum3,
  partialSum3,
  pick,
  pickFirst,
  plusN,
  staged,
  stagedValue,
  true0,
} from "./currying.ts";
import { print } from "./observe.ts";
import { ofNumber, toArray, toNumber } from "./support.ts";

console.log("partial applications of a two-argument function");

{
  print(toNumber(add3(ofNumber(4))));
  print(toNumber(plusN(ofNumber(2), ofNumber(5))));
  const [first, second] = toArray(adders);
  print(first && toNumber(first(ofNumber(5))));
  print(second && toNumber(second(ofNumber(5))));
}

console.log("a named function partially applied to a non-atomic argument");

print(toNumber(add4(ofNumber(1))));

console.log("a polymorphic higher-order function is called uncurried");

print(applyTwice((n: number) => n * 2, 3));

console.log("an eta-reduced definition keeps the arity of its callee");

print(toNumber(fullSum3));

print(toNumber(partialSum3(ofNumber(1), ofNumber(2), ofNumber(3))));

console.log("over-application of a function that returns a function");

print(toNumber(staged(ofNumber(3))(ofNumber(4))));

print(toNumber(stagedValue));

console.log("a polymorphic partial application keeps its type parameter");

print(pick(true0, "a", "b"));

print(pick(false0, "a", "b"));

print(pickFirst("a", "b"));

console.log("a partial application to a global or to a constructor of one");

print(toNumber(addOne(ofNumber(1))));

print(toNumber(addSucc(ofNumber(1))));
