import { print } from "../observe.ts";
import type { Tree } from "./tree.ts";
import { leaf, node, size } from "./tree.ts";

console.log("size counts the nodes of a tree");

{
  const t: Tree<string> = node(leaf, "a", node(leaf, "b", leaf));

  print(size(t));
  print(size<string>(leaf));
}
