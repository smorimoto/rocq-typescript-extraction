const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};

const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};

const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const sub: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (n > m ? n - m : 0);

const modulo: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (m === 0 ? n : n % m);

export const sumTo = (n: number, acc: number): number => {
  let n0 = n;
  let acc0 = acc;

  for (;;) {
    if (n0 === 0) {
      return acc0;
    }

    const k: number = n0 - 1;
    acc0 = add(acc0, n0);
    n0 = k;
  }
};

export const fibIter = (n: number, a: number, b: number): number => {
  let n0 = n;
  let a0 = a;
  let b0 = b;

  for (;;) {
    if (n0 === 0) {
      return a0;
    }

    const k: number = n0 - 1;
    const b1: number = add(a0, b0);
    n0 = k;
    a0 = b0;
    b0 = b1;
  }
};

export interface Up {
  readonly tag: "Up";
}

export interface Down {
  readonly tag: "Down";
}

export interface Stay {
  readonly tag: "Stay";
}

type Step = Up | Down | Stay;

export const up: Up = { tag: "Up" };
export const down: Down = { tag: "Down" };
export const stay: Stay = { tag: "Stay" };

const stepOf = (n: number): Step => {
  const s0: number = modulo(n, s(s(s(0))));

  if (s0 === 0) {
    return up;
  }

  const n0: number = s0 - 1;

  return n0 === 0 ? down : stay;
};

export const drift = (n: number, pos: number): number => {
  let n0 = n;
  let pos0 = pos;

  for (;;) {
    if (n0 === 0) {
      return pos0;
    }

    const k: number = n0 - 1;
    const s0: Step = stepOf(k);
    let result: number;

    switch (s0.tag) {
      case "Up": {
        result = add(pos0, s(s(0)));
        break;
      }

      case "Down": {
        result = sub(pos0, s(0));
        break;
      }

      case "Stay": {
        result = pos0;
        break;
      }

      default: {
        result = s0 satisfies never;
      }
    }

    n0 = k;
    pos0 = result;
  }
};

export const halves = (n: number): number => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = 0;
    } else {
      const k: number = n0 - 1;
      let result: number;

      if (k === 0) {
        result = 0;
      } else {
        const j: number = k - 1;
        depth += 1;
        n0 = j;
        continue;
      }

      returned = add(s(0), result);
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      const result: number = returned;
      returned = add(s(0), result);
    }
  }
};

const go = (k: number, acc: number): number => {
  let k0 = k;
  let acc0 = acc;

  for (;;) {
    if (k0 === 0) {
      return acc0;
    }

    const kʹ: number = k0 - 1;
    acc0 = add(acc0, k0);
    k0 = kʹ;
  }
};

export const sumLocal = (n: number): number => go(n, 0);

export interface Leaf {
  readonly tag: "Leaf";
}

export interface Node {
  readonly tag: "Node";
  readonly l: Tree;
  readonly x: number;
  readonly r: Tree;
}

export type Tree = Leaf | Node;

export const leaf: Leaf = { tag: "Leaf" };

export const node = (l: Tree, x: number, r: Tree): Tree => ({
  l,
  r,
  tag: "Node",
  x,
});

export const treeSum = (t: Tree, acc: number): number => {
  const saved: [Tree][] = [];
  let top = 0;
  let t0 = t;
  let acc0 = acc;

  for (;;) {
    let returned: number;

    switch (t0.tag) {
      case "Leaf": {
        returned = acc0;
        break;
      }

      case "Node": {
        __writeCell(saved, top, t0.r);
        top += 1;
        acc0 = add(acc0, t0.x);
        t0 = t0.l;
        continue;
      }

      default: {
        returned = t0 satisfies never;
      }
    }

    if (top === 0) {
      return returned;
    }

    top -= 1;
    const r: Tree = __readCell(saved, top);
    t0 = r;
    acc0 = returned;
    continue;
  }
};

export const countInto = (n: number, acc: number): number => {
  let n0 = n;
  let acc0 = acc;

  for (;;) {
    if (n0 === 0) {
      return acc0;
    }

    const k: number = n0 - 1;
    n0 = k;
    acc0 = s(acc0);
  }
};

const twice = (f: (_: number) => number, x: number): number => f(f(x));

export const addEach = (d: number, n: number, acc: number): number => {
  let n0 = n;
  let acc0 = acc;

  for (;;) {
    if (n0 === 0) {
      return acc0;
    }

    const k: number = n0 - 1;
    n0 = k;
    acc0 = twice((y: number): number => add(y, d), acc0);
  }
};

export const composeN = (
  n: number,
  k: (_: number) => number
): ((_: number) => number) => {
  let n0 = n;
  let k0 = k;

  for (;;) {
    const n1 = n0;
    const k1 = k0;

    if (n1 === 0) {
      return k1;
    }

    const m: number = n1 - 1;
    n0 = m;
    k0 = (x: number): number => k1(add(x, n1));
  }
};
