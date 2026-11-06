import type {
  Black,
  Red,
  TreeSetRawLeaf as Leaf,
  TreeSetRawNode as Node,
  TreeSetRawTree as Tree,
} from "./number/bst.ts";

export type { TreeSetRawTree as Tree } from "./number/bst.ts";

const red: Red = { tag: "Red" };
const black: Black = { tag: "Black" };
export const empty: Leaf = { tag: "Leaf" };

const node = (
  color: Red | Black,
  left: Tree,
  key: number,
  right: Tree
): Tree => ({
  arg0: color,
  arg1: left,
  arg2: key,
  arg3: right,
  tag: "Node",
});

const balanceLeft = (left: Tree, key: number, right: Tree): Tree => {
  if (left.tag === "Node" && left.arg0.tag === "Red") {
    const ll = left.arg1;
    const lr = left.arg3;

    if (ll.tag === "Node" && ll.arg0.tag === "Red") {
      return node(
        red,
        node(black, ll.arg1, ll.arg2, ll.arg3),
        left.arg2,
        node(black, lr, key, right)
      );
    }

    if (lr.tag === "Node" && lr.arg0.tag === "Red") {
      return node(
        red,
        node(black, ll, left.arg2, lr.arg1),
        lr.arg2,
        node(black, lr.arg3, key, right)
      );
    }
  }

  return node(black, left, key, right);
};

const balanceRight = (left: Tree, key: number, right: Tree): Tree => {
  if (right.tag === "Node" && right.arg0.tag === "Red") {
    const rl = right.arg1;
    const rr = right.arg3;

    if (rl.tag === "Node" && rl.arg0.tag === "Red") {
      return node(
        red,
        node(black, left, key, rl.arg1),
        rl.arg2,
        node(black, rl.arg3, right.arg2, rr)
      );
    }

    if (rr.tag === "Node" && rr.arg0.tag === "Red") {
      return node(
        red,
        node(black, left, key, rl),
        right.arg2,
        node(black, rr.arg1, rr.arg2, rr.arg3)
      );
    }
  }

  return node(black, left, key, right);
};

export const insert = (key: number, tree: Tree): Tree => {
  const path: { readonly node: Node; readonly left: boolean }[] = [];
  let result = tree;

  while (result.tag === "Node") {
    if (key < result.arg2) {
      path.push({ left: true, node: result });
      result = result.arg1;
    } else if (key > result.arg2) {
      path.push({ left: false, node: result });
      result = result.arg3;
    } else {
      break;
    }
  }

  if (result.tag === "Leaf") {
    result = node(red, empty, key, empty);
  }

  for (let entry = path.pop(); entry !== undefined; entry = path.pop()) {
    const parent = entry.node;

    if (entry.left) {
      result =
        parent.arg0.tag === "Red"
          ? node(red, result, parent.arg2, parent.arg3)
          : balanceLeft(result, parent.arg2, parent.arg3);
    } else {
      result =
        parent.arg0.tag === "Red"
          ? node(red, parent.arg1, parent.arg2, result)
          : balanceRight(parent.arg1, parent.arg2, result);
    }
  }

  return result.tag === "Leaf"
    ? result
    : node(black, result.arg1, result.arg2, result.arg3);
};

export const member = (key: number, tree: Tree): boolean => {
  let rest = tree;

  while (rest.tag === "Node") {
    if (key < rest.arg2) {
      rest = rest.arg1;
    } else if (key > rest.arg2) {
      rest = rest.arg3;
    } else {
      return true;
    }
  }

  return false;
};
