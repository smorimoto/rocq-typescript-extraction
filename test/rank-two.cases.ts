import { print } from "./observe.ts";
import {
  applyPoly,
  cons,
  first,
  forward,
  lists,
  mkBoxed,
  nil,
  passed,
  passedGlobal,
  passedLam,
  twicePoly,
  useBoxed,
} from "./rank-two.ts";
import type { Boxed, List } from "./rank-two.ts";

const identity = <A>(x: A): A => x;

const nonEmpty = <A>(l: List<A>): number => (l.tag === "Nil" ? 0 : 1);

console.log("a parameter of a generic function type takes a generic function");

print(applyPoly(identity, 1, true));

print([passed(2, false), passedGlobal(3, true), passedLam(4, false)]);

print(forward(identity, 5));

print(twicePoly(3));

console.log("a generic function type over two parameters and over a list");

print(first(6, false));

print(lists(nonEmpty, cons(1, nil), nil));

console.log("a record field of a generic function type");

{
  const boxed: Boxed = { run: identity, size: 0 };
  print([useBoxed(boxed, 7), useBoxed(mkBoxed, 8)]);
}
