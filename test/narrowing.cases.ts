import {
  alias,
  area,
  dot,
  e,
  false0,
  grown,
  isLeaf,
  leaf,
  node,
  o,
  pick,
  true0,
} from "./narrowing.ts";
import type { Figure, Tree } from "./narrowing.ts";
import { print } from "./observe.ts";
import { toNumber } from "./support.ts";

const describe = (f: Figure): string => {
  switch (f.tag) {
    case "Dot": {
      return "dot";
    }

    case "Line": {
      return "line";
    }

    case "Box": {
      return "box";
    }

    default: {
      return f satisfies never;
    }
  }
};

const size = <A>(t: Tree<A>): number => (t.tag === "Leaf" ? 0 : 1);

console.log("a match on a constant is the branch of its constructor");

print({ actual: e, expected: leaf });

print({ actual: isLeaf, expected: true0 });

print({ actual: grown, expected: node(leaf, o, leaf) });

console.log("a match through a chain of constants and on a local");

print({ actual: alias, expected: dot });

print(toNumber(area));

print(toNumber(pick(true0)));

print(toNumber(pick(false0)));

console.log("a consumer matches an imported constant on every constructor");

print(describe(alias));

print(size(e));

print(size(grown));
