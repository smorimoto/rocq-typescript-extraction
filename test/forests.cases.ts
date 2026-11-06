import {
  allZero,
  concat,
  cons,
  doubled,
  hasOwnProperty,
  map,
  mapForest,
  nil,
  node,
  reduce,
  sort,
  substr,
  toFixed,
} from "./forests.ts";
import { print } from "./observe.ts";

const leaf = (x: number) => node(x, nil);

const tree = node(1, cons(leaf(2), cons(node(3, cons(leaf(4), nil)), nil)));

console.log(
  "the members of a mutually recursive group named like array methods"
);

print({
  actual: doubled(tree),
  expected: node(2, cons(leaf(4), cons(node(6, cons(leaf(8), nil)), nil))),
});

print({
  actual: map((n: number): number => n + 1, leaf(1)),
  expected: leaf(2),
});

print({ actual: mapForest((n: number): number => n + 1, nil), expected: nil });

console.log("a local mutually recursive group named like array methods");

print(allZero(node(0, cons(leaf(0), nil))));

print(allZero(tree));

console.log("the members of groups named like the methods of built-ins");

print(reduce((a: number) => (b: number) => a + b, 0, tree));

print({
  actual: concat(tree),
  expected: cons(leaf(1), cons(leaf(2), cons(leaf(3), cons(leaf(4), nil)))),
});

print(hasOwnProperty(4, tree));

print(hasOwnProperty(5, tree));

print({
  actual: substr(1, tree),
  expected: node(1, cons(leaf(2), cons(leaf(3), nil))),
});

print({
  actual: sort(node(1, cons(leaf(3), cons(leaf(2), nil)))),
  expected: node(1, cons(leaf(2), cons(leaf(3), nil))),
});

print({
  actual: toFixed(2, tree),
  expected: node(1, cons(leaf(2), cons(node(2, cons(leaf(2), nil)), nil))),
});
