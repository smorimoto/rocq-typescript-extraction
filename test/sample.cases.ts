import { print } from "./observe.ts";
import {
  M,
  add,
  bump,
  compose,
  even,
  false0,
  four,
  leaf,
  node,
  odd,
  size,
  swap,
  true0,
} from "./sample.ts";
import type { Point, Tree } from "./sample.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log("M.two and four evaluate to Peano numerals");

print(toNumber(M.two));

print(toNumber(four));

print(toNumber(add(ofNumber(3), ofNumber(5))));

console.log("size counts the nodes of a tree of any element type");

{
  const t: Tree<string> = node(
    node(leaf, "a", leaf),
    "b",
    node(leaf, "c", leaf)
  );

  print(toNumber(size(t)));
  print(toNumber(size(leaf)));
}

console.log("even and odd are mutually recursive and return bool values");

print({ actual: even(ofNumber(10)), expected: true0 });

print({ actual: odd(ofNumber(10)), expected: false0 });

print(odd(ofNumber(7)).tag);

console.log("compose applies f then g");

print(
  compose(
    (n: number) => n + 1,
    (s: string) => s.length,
    "abcd"
  )
);

console.log("swap exchanges record fields and bump builds a one-node tree");

{
  const p: Point = { px: ofNumber(1), py: ofNumber(2) };
  const q = swap(p);
  print(toNumber(q.px));
  print(toNumber(q.py));
  const t = bump(p);
  print(t);
}
