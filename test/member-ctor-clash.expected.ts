const s = (n: number): number => n + 1;

interface MAP<T> {
  readonly empty: T;
}

export interface TreeEmpty {
  readonly tag: "Empty";
}

export interface TreeNode {
  readonly tag: "Node";
  readonly x: number;
}

export type TreeTree = TreeEmpty | TreeNode;

const Tree$empty0: TreeEmpty = { tag: "Empty" };
const Tree$node = (x: number): TreeTree => ({ tag: "Node", x });

const Tree$treeRect = <A>(empty: A, node: (_: number) => A, t: TreeTree): A => {
  switch (t.tag) {
    case "Empty": {
      return empty;
    }

    case "Node": {
      return node(t.x);
    }

    default: {
      return t satisfies never;
    }
  }
};

const Tree$treeRec = <A>(empty: A, node: (_: number) => A, t: TreeTree): A => {
  switch (t.tag) {
    case "Empty": {
      return empty;
    }

    case "Node": {
      return node(t.x);
    }

    default: {
      return t satisfies never;
    }
  }
};

export type TreeT = TreeTree;

const Tree$empty: TreeTree = Tree$node(s(s(s(s(s(s(s(0))))))));

export const Tree = {
  empty: Tree$empty,
  empty0: Tree$empty0,
  node: Tree$node,
  treeRec: Tree$treeRec,
  treeRect: Tree$treeRect,
} as const;

interface UseResult<T> {
  readonly fresh: T;
}

const Use = <T>(M: MAP<T>): UseResult<T> => {
  const fresh0: T = M.empty;

  return { fresh: fresh0 };
};

const U = Use<TreeTree>(Tree);
export const fresh: TreeTree = U.fresh;
