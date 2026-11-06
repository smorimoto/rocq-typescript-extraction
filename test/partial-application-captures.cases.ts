import { print } from "./observe.ts";
import {
  collect,
  collectLocal,
  cons,
  leaf,
  nil,
  node,
  secondPlus,
  traverse,
  traverseLocal,
} from "./partial-application-captures.ts";

const items = cons(2n, cons(5n, cons(11n, nil)));

console.log("partial applications retain each iteration's arguments");

print({ actual: collect(items), expected: items });

print({ actual: collectLocal(items), expected: items });

print({ actual: collect(nil), expected: nil });

console.log("closures retain nested pattern narrowing");

print(secondPlus(items, 7n));

print(secondPlus(cons(2n, nil), 7n));

print(secondPlus(nil, 7n));

console.log(
  "partial recursive calls capture the current subtrees and continuation"
);

{
  const tree = node(node(leaf, 2n, leaf), 5n, node(leaf, 11n, leaf));

  print(traverse(tree, (n) => 3n * n, 7n));
  print(traverseLocal(tree, 7n));
  print(traverseLocal(leaf, 7n));
}
