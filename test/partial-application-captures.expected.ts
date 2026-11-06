export interface Nil {
  readonly tag: "Nil";
}

export interface Cons<A> {
  readonly tag: "Cons";
  readonly arg0: A;
  readonly arg1: List<A>;
}

export type List<A> = Nil | Cons<A>;

export const nil: Nil = { tag: "Nil" };

export const cons = <A>(arg0: A, arg1: List<A>): List<A> => ({
  arg0,
  arg1,
  tag: "Cons",
});

const add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

const prepend = (
  x: bigint,
  k: (_: List<bigint>) => List<bigint>,
  xs: List<bigint>
): List<bigint> => k(cons(x, xs));

const collectInto = (
  xs: List<bigint>,
  k: (_: List<bigint>) => List<bigint>
): ((_: List<bigint>) => List<bigint>) => {
  let xs0 = xs;
  let k0 = k;

  for (;;) {
    const xs1 = xs0;
    const k1 = k0;

    switch (xs1.tag) {
      case "Nil": {
        return k1;
      }

      case "Cons": {
        xs0 = xs1.arg1;
        k0 = (x: List<bigint>): List<bigint> => prepend(xs1.arg0, k1, x);
        continue;
      }

      default: {
        return xs1 satisfies never;
      }
    }
  }
};

export const collect = (xs: List<bigint>): List<bigint> =>
  collectInto(xs, (ys: List<bigint>): List<bigint> => ys)(nil);

const go = (
  ys: List<bigint>,
  k: (_: List<bigint>) => List<bigint>
): ((_: List<bigint>) => List<bigint>) => {
  let ys0 = ys;
  let k0 = k;

  for (;;) {
    const ys1 = ys0;
    const k1 = k0;

    switch (ys1.tag) {
      case "Nil": {
        return k1;
      }

      case "Cons": {
        ys0 = ys1.arg1;
        k0 = (x: List<bigint>): List<bigint> => prepend(ys1.arg0, k1, x);
        continue;
      }

      default: {
        return ys1 satisfies never;
      }
    }
  }
};

export const collectLocal = (xs: List<bigint>): List<bigint> =>
  go(xs, (ys: List<bigint>): List<bigint> => ys)(nil);

const applyNat = (f: (_: bigint) => bigint): ((_: bigint) => bigint) => f;

export const secondPlus = (xs: List<bigint>, n: bigint): bigint => {
  switch (xs.tag) {
    case "Nil": {
      return 0n;
    }

    case "Cons": {
      const s0: List<bigint> = xs.arg1;

      switch (s0.tag) {
        case "Nil": {
          return 0n;
        }

        case "Cons": {
          return applyNat((u: bigint): bigint => add(s0.arg0, u))(n);
        }

        default: {
          return s0 satisfies never;
        }
      }
    }

    default: {
      return xs satisfies never;
    }
  }
};

export interface Leaf {
  readonly tag: "Leaf";
}

export interface Node {
  readonly tag: "Node";
  readonly left: Tree;
  readonly key: bigint;
  readonly right: Tree;
}

export type Tree = Leaf | Node;

export const leaf: Leaf = { tag: "Leaf" };

export const node = (left: Tree, key: bigint, right: Tree): Tree => ({
  key,
  left,
  right,
  tag: "Node",
});

const addKey = (key: bigint, k: (_: bigint) => bigint, n: bigint): bigint =>
  k(add(key, n));

export const traverse = (
  t: Tree,
  k: (_: bigint) => bigint,
  n: bigint
): bigint => {
  let t0 = t;
  let k0 = k;

  for (;;) {
    const t1 = t0;
    const k1 = k0;

    switch (t1.tag) {
      case "Leaf": {
        return k1(n);
      }

      case "Node": {
        const x0: (_: bigint) => bigint = (x: bigint): bigint =>
          traverse(t1.right, k1, x);

        t0 = t1.left;
        k0 = (x: bigint): bigint => addKey(t1.key, x0, x);
        continue;
      }

      default: {
        return t1 satisfies never;
      }
    }
  }
};

const go0 = (s0: Tree, k: (_: bigint) => bigint, x: bigint): bigint => {
  let s1 = s0;
  let k0 = k;

  for (;;) {
    const s2 = s1;
    const k1 = k0;

    switch (s2.tag) {
      case "Leaf": {
        return k1(x);
      }

      case "Node": {
        const x1: (_: bigint) => bigint = (x0: bigint): bigint =>
          go0(s2.right, k1, x0);

        s1 = s2.left;
        k0 = (x0: bigint): bigint => addKey(s2.key, x1, x0);
        continue;
      }

      default: {
        return s2 satisfies never;
      }
    }
  }
};

export const traverseLocal = (t: Tree, n: bigint): bigint =>
  go0(t, (x: bigint): bigint => x, n);
