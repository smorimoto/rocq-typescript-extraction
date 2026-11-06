export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export interface MAP<T> {
  readonly empty: <A>() => Kind<T, A>;
}

export interface TreeEmpty {
  readonly tag: "Empty";
}

export interface TreeNode<A> {
  readonly tag: "Node";
  readonly x: A;
}

export type TreeTree<A> = TreeEmpty | TreeNode<A>;

const Tree$empty0: TreeEmpty = { tag: "Empty" };
const Tree$node = <A>(x: A): TreeTree<A> => ({ tag: "Node", x });

const Tree$treeRect = <A, B>(
  empty: B,
  node: (_: A) => B,
  t: TreeTree<A>
): B => {
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

const Tree$treeRec = <A, B>(empty: B, node: (_: A) => B, t: TreeTree<A>): B => {
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

export type TreeT<A> = TreeTree<A>;

const Tree$empty = <A>(): TreeTree<A> => Tree$empty0;

export const Tree = {
  empty: Tree$empty,
  empty0: Tree$empty0,
  node: Tree$node,
  treeRec: Tree$treeRec,
  treeRect: Tree$treeRect,
} as const;

export interface UseResult<T> {
  readonly fresh: Kind<T, number>;
}

export const Use = <T>(M: MAP<T>): UseResult<T> => {
  const fresh0: Kind<T, number> = M.empty<number>();

  return { fresh: fresh0 };
};

interface TreeTLambda extends TypeLambda {
  readonly type: TreeT<this["Target"]>;
}

const U = Use<TreeTLambda>(Tree);
export const fresh: TreeTree<number> = U.fresh;
