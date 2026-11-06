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

export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

export const add = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m;
        break;
      }

      case "S": {
        depth += 1;
        n0 = n0.arg0;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(returned);
    }
  }
};

export interface Red {
  readonly tag: "Red";
}

export interface Green {
  readonly tag: "Green";
}

export interface Blue {
  readonly tag: "Blue";
}

export type Color = Red | Green | Blue;

export const red: Red = { tag: "Red" };
export const green: Green = { tag: "Green" };
export const blue: Blue = { tag: "Blue" };

export interface Leaf {
  readonly tag: "Leaf";
}

export interface Node<A> {
  readonly tag: "Node";
  readonly l: Tree<A>;
  readonly x: A;
  readonly r: Tree<A>;
}

export type Tree<A> = Leaf | Node<A>;

export const leaf: Leaf = { tag: "Leaf" };

export const node = <A>(l: Tree<A>, x: A, r: Tree<A>): Tree<A> => ({
  l,
  r,
  tag: "Node",
  x,
});

export interface Point {
  readonly px: Nat;
  readonly py: Nat;
}

export const size = <A>(t: Tree<A>): Nat => {
  const saved: [Tree<A>][] = [];
  let top = 0;
  const saved0: [Nat][] = [];
  let top0 = 0;
  const frames: [number][] = [];
  let depth = 0;
  let t0 = t;

  for (;;) {
    let returned: Nat;

    switch (t0.tag) {
      case "Leaf": {
        returned = o;
        break;
      }

      case "Node": {
        __writeCell(frames, depth, 0);
        depth += 1;
        __writeCell(saved, top, t0.r);
        top += 1;
        t0 = t0.l;
        continue;
      }

      default: {
        returned = t0 satisfies never;
      }
    }

    let resuming = true;

    while (resuming) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          top -= 1;
          const r: Tree<A> = __readCell(saved, top);
          __writeCell(frames, depth, 1);
          depth += 1;
          __writeCell(saved0, top0, returned);
          top0 += 1;
          t0 = r;
          resuming = false;
          continue;
        }

        default: {
          top0 -= 1;
          const returned0: Nat = __readCell(saved0, top0);
          returned = s(add(returned0, returned));
        }
      }
    }
  }
};

const evenOdd = {
  even: (n: Nat): Bool => {
    let n0 = n;

    for (;;) {
      switch (n0.tag) {
        case "O": {
          return true0;
        }

        case "S": {
          const n1: Nat = n0.arg0;

          switch (n1.tag) {
            case "O": {
              return false0;
            }

            case "S": {
              n0 = n1.arg0;
              continue;
            }

            default: {
              return n1 satisfies never;
            }
          }
        }

        default: {
          return n0 satisfies never;
        }
      }
    }
  },
  odd: (n: Nat): Bool => {
    let n0 = n;

    for (;;) {
      switch (n0.tag) {
        case "O": {
          return false0;
        }

        case "S": {
          const n1: Nat = n0.arg0;

          switch (n1.tag) {
            case "O": {
              return true0;
            }

            case "S": {
              n0 = n1.arg0;
              continue;
            }

            default: {
              return n1 satisfies never;
            }
          }
        }

        default: {
          return n0 satisfies never;
        }
      }
    }
  },
};

export const { even, odd } = evenOdd;

export const compose = <A, B, C>(g: (_: B) => C, f: (_: A) => B, x: A): C =>
  g(f(x));

export const swap = (p: Point): Point => ({ px: p.py, py: p.px });

export const bump = (p: Point): Tree<Nat> => {
  const q: Point = swap(p);

  return node<Nat>(leaf, q.px, leaf);
};

const M$two: Nat = s(s(o));

export const M = {
  two: M$two,
} as const;

export const four: Nat = add(M$two, M$two);
