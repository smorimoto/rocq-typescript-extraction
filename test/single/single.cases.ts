import { print } from "../observe.ts";
import { leaf, mirror, node } from "./single.ts";
import type { Tree } from "./single.ts";

console.log(
  "the printed declarations of tree and mirror form a working module"
);

{
  const t: Tree<string> = node(node(leaf, "a", leaf), "b", leaf);
  print({
    actual: mirror(t),
    expected: node(leaf, "b", node(leaf, "a", leaf)),
  });
}
