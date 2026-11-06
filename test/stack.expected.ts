const __fail = (message: string): never => {
  throw new Error(message);
};

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

const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;
const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const fst: <A, B>(_0: readonly [A, B]) => A = <A, B>(p: readonly [A, B]): A =>
  p[0];

const snd: <A, B>(_0: readonly [A, B]) => B = <A, B>(p: readonly [A, B]): B =>
  p[1];

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

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const eqb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n === m;

const leb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n <= m;

export interface Leaf {
  readonly tag: "Leaf";
}

export interface Node {
  readonly tag: "Node";
  readonly l: Tree;
  readonly k: number;
  readonly r: Tree;
}

export type Tree = Leaf | Node;

export const leaf: Leaf = { tag: "Leaf" };

export const node = (l: Tree, k: number, r: Tree): Tree => ({
  k,
  l,
  r,
  tag: "Node",
});

export const size = (t: Tree): number => {
  const saved: [Tree][] = [];
  let top = 0;
  const saved0: [number][] = [];
  let top0 = 0;
  const frames: [number][] = [];
  let depth = 0;
  let t0 = t;

  for (;;) {
    let returned: number;

    switch (t0.tag) {
      case "Leaf": {
        returned = 0;
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
          const r: Tree = __readCell(saved, top);
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
          const returned0: number = __readCell(saved0, top0);
          returned = s(add(returned0, returned));
        }
      }
    }
  }
};

export const mirror = (t: Tree): Tree => {
  const saved: [Tree][] = [];
  let top = 0;
  const saved0: [number][] = [];
  let top0 = 0;
  const frames: [number][] = [];
  let depth = 0;
  let t0 = t;

  for (;;) {
    let returned: Tree;

    switch (t0.tag) {
      case "Leaf": {
        returned = leaf;
        break;
      }

      case "Node": {
        __writeCell(frames, depth, 0);
        depth += 1;
        __writeCell(saved, top, t0.l);
        top += 1;
        __writeCell(saved0, top0, t0.k);
        top0 += 1;
        t0 = t0.r;
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
          top0 -= 1;
          const k: number = __readCell(saved0, top0);
          top -= 1;
          const l: Tree = __readCell(saved, top);
          __writeCell(frames, depth, 1);
          depth += 1;
          __writeCell(saved, top, returned);
          top += 1;
          __writeCell(saved0, top0, k);
          top0 += 1;
          t0 = l;
          resuming = false;
          continue;
        }

        default: {
          top0 -= 1;
          const k: number = __readCell(saved0, top0);
          top -= 1;
          const returned0: Tree = __readCell(saved, top);
          returned = node(returned0, k, returned);
        }
      }
    }
  }
};

export const app = <A>(l: List<A>, m: List<A>): List<A> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<A>;

    switch (l0.tag) {
      case "Nil": {
        returned = m;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, l0.arg0);
        top += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: A = __readCell(saved, top);
      returned = cons(arg0, returned);
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

export const weigh = (c: Color, n: number): number => {
  let depth = 0;
  let c0 = c;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = 0;
    } else {
      const m: number = n0 - 1;
      let result: number;

      switch (c0.tag) {
        case "Red": {
          depth += 1;
          n0 = m;
          continue;
        }

        case "Green": {
          result = s(s(0));
          break;
        }

        case "Blue": {
          depth += 1;
          c0 = red;
          n0 = m;
          continue;
        }

        default: {
          result = c0 satisfies never;
        }
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

export const countFrom = (base: number, n: number): number => {
  const go = (k: number): number => {
    let depth = 0;
    let k0 = k;

    for (;;) {
      let returned: number;

      if (k0 === 0) {
        returned = base;
      } else {
        const j: number = k0 - 1;
        depth += 1;
        k0 = j;
        continue;
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

  return add(go(n), go(s(0)));
};

export const walk = (n: number, acc: number, b: boolean): number => {
  let depth = 0;
  let n0 = n;
  let acc0 = acc;
  let b0 = b;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = acc0;
    } else {
      const m: number = n0 - 1;

      if (b0) {
        n0 = m;
        acc0 = s(acc0);
        b0 = negb(b0);
        continue;
      }

      depth += 1;
      n0 = m;
      b0 = negb(b0);
      continue;
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
    k0 = (x: number): number => k1(add(x, s(0)));
  }
};

const evOd = {
  ev: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return true;
      }

      const m: number = n0 - 1;

      if (m === 0) {
        return false;
      }

      const m0: number = m - 1;
      n0 = m0;
    }
  },
  od: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return false;
      }

      const m: number = n0 - 1;

      if (m === 0) {
        return true;
      }

      const m0: number = m - 1;
      n0 = m0;
    }
  },
};

export const { ev, od } = evOd;

const upEvenUpOdd = {
  upEven: (n: number): number => {
    let depth = 0;
    let n0 = n;

    for (;;) {
      let returned: number;

      if (n0 === 0) {
        returned = 0;
      } else {
        const m: number = n0 - 1;
        depth += 1;

        if (m === 0) {
          returned = s(0);
        } else {
          const m0: number = m - 1;
          depth += 1;
          n0 = m0;
          continue;
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
  },
  upOdd: (n: number): number => {
    let depth = 0;
    let n0 = n;

    for (;;) {
      let returned: number;

      if (n0 === 0) {
        returned = s(0);
      } else {
        const m: number = n0 - 1;
        depth += 1;

        if (m === 0) {
          returned = 0;
        } else {
          const m0: number = m - 1;
          depth += 1;
          n0 = m0;
          continue;
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
  },
};

export const { upEven, upOdd } = upEvenUpOdd;

const mod30Mod31Mod32 = {
  mod30: (n: number): number => {
    let n0 = n;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          if (n0 === 0) {
            return 0;
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 1;
          continue;
        }

        case 1: {
          if (n0 === 0) {
            return s(0);
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 2;
          continue;
        }

        default: {
          if (n0 === 0) {
            return s(s(0));
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 0;
          continue;
        }
      }
    }
  },
  mod31: (n: number): number => {
    let n0 = n;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          if (n0 === 0) {
            return 0;
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 1;
          continue;
        }

        case 1: {
          if (n0 === 0) {
            return s(0);
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 2;
          continue;
        }

        default: {
          if (n0 === 0) {
            return s(s(0));
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 0;
          continue;
        }
      }
    }
  },
  mod32: (n: number): number => {
    let n0 = n;
    let which = 2;

    for (;;) {
      switch (which) {
        case 0: {
          if (n0 === 0) {
            return 0;
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 1;
          continue;
        }

        case 1: {
          if (n0 === 0) {
            return s(0);
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 2;
          continue;
        }

        default: {
          if (n0 === 0) {
            return s(s(0));
          }

          const m: number = n0 - 1;
          n0 = m;
          which = 0;
          continue;
        }
      }
    }
  },
};

export const { mod30, mod31, mod32 } = mod30Mod31Mod32;

const levLod = {
  lev: (k: number): boolean => {
    let k0 = k;

    for (;;) {
      if (k0 === 0) {
        return true;
      }

      const j: number = k0 - 1;

      if (j === 0) {
        return false;
      }

      const j0: number = j - 1;
      k0 = j0;
    }
  },
  lod: (k: number): boolean => {
    let k0 = k;

    for (;;) {
      if (k0 === 0) {
        return false;
      }

      const j: number = k0 - 1;

      if (j === 0) {
        return true;
      }

      const j0: number = j - 1;
      k0 = j0;
    }
  },
};

export const localParity: (_: number) => boolean = levLod.lev;

export const mapNat = (
  f: (_: number) => number,
  l: List<number>
): List<number> => {
  const saved: [number][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<number>;

    switch (l0.tag) {
      case "Nil": {
        returned = nil;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, l0.arg0);
        top += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: number = __readCell(saved, top);
      returned = cons(f(arg0), returned);
    }
  }
};

export const foldTree = (f: (_: number) => number, t: Tree): number => {
  const saved: [Tree][] = [];
  let top = 0;
  const saved0: [number][] = [];
  let top0 = 0;
  const frames: [number][] = [];
  let depth = 0;
  let t0 = t;

  for (;;) {
    let returned: number;

    switch (t0.tag) {
      case "Leaf": {
        returned = 0;
        break;
      }

      case "Node": {
        __writeCell(frames, depth, 0);
        depth += 1;
        __writeCell(saved, top, t0.r);
        top += 1;
        __writeCell(saved0, top0, t0.k);
        top0 += 1;
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
          top0 -= 1;
          const k: number = __readCell(saved0, top0);
          top -= 1;
          const r: Tree = __readCell(saved, top);
          __writeCell(frames, depth, 1);
          depth += 1;
          __writeCell(saved0, top0, k);
          top0 += 1;
          __writeCell(saved0, top0, returned);
          top0 += 1;
          t0 = r;
          resuming = false;
          continue;
        }

        default: {
          top0 -= 1;
          const returned0: number = __readCell(saved0, top0);
          top0 -= 1;
          const k: number = __readCell(saved0, top0);
          returned = add(add(f(k), returned0), returned);
        }
      }
    }
  }
};

export interface RNode {
  readonly tag: "RNode";
  readonly k: number;
  readonly f: Forest;
}

export type Rose = RNode;

export const rNode = (k: number, f: Forest): RNode => ({ f, k, tag: "RNode" });

export interface FNil {
  readonly tag: "FNil";
}

export interface FCons {
  readonly tag: "FCons";
  readonly r: Rose;
  readonly f: Forest;
}

export type Forest = FNil | FCons;

export const fNil: FNil = { tag: "FNil" };
export const fCons = (r: Rose, f: Forest): Forest => ({ f, r, tag: "FCons" });

const roseSizeForestSize = {
  forestSize: (f: Forest): number => {
    const saved: [Rose][] = [];
    let top = 0;
    const saved0: [Forest][] = [];
    let top0 = 0;
    const saved1: [number][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let f0 = f;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top -= 1;
          const r: Rose = __readCell(saved, top);
          __writeCell(frames, depth, 0);
          depth += 1;
          f0 = r.f;
          which = 1;
          continue;
        }

        default: {
          let returned0: number;

          switch (f0.tag) {
            case "FNil": {
              returned0 = 0;
              break;
            }

            case "FCons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved0, top0, f0.f);
              top0 += 1;
              __writeCell(saved, top, f0.r);
              top += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = f0 satisfies never;
            }
          }

          __writeCell(saved1, top1, returned0);
          top1 += 1;
        }
      }

      let resuming = true;

      while (resuming) {
        if (depth === 0) {
          top1 -= 1;

          return __readCell(saved1, top1);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top1 -= 1;
            const v: number = __readCell(saved1, top1);
            __writeCell(saved1, top1, s(v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: number = __readCell(saved1, top1);
            top0 -= 1;
            const f1: Forest = __readCell(saved0, top0);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            f0 = f1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: number = __readCell(saved1, top1);
            top1 -= 1;
            const v: number = __readCell(saved1, top1);
            __writeCell(saved1, top1, add(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
  roseSize: (r: Rose): number => {
    const saved: [Forest][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let r0 = r;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, r0.f);
          top += 1;
          which = 1;
          continue;
        }

        default: {
          top -= 1;
          const f: Forest = __readCell(saved, top);
          let returned0: number;

          switch (f.tag) {
            case "FNil": {
              returned0 = 0;
              break;
            }

            case "FCons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, f.f);
              top += 1;
              r0 = f.r;
              which = 0;
              continue;
            }

            default: {
              returned0 = f satisfies never;
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
        }
      }

      let resuming = true;

      while (resuming) {
        if (depth === 0) {
          top0 -= 1;

          return __readCell(saved0, top0);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top0 -= 1;
            const v: number = __readCell(saved0, top0);
            __writeCell(saved0, top0, s(v));
            top0 += 1;
            break;
          }

          case 1: {
            top0 -= 1;
            const v: number = __readCell(saved0, top0);
            top -= 1;
            const f: Forest = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved0, top0, v);
            top0 += 1;
            __writeCell(saved, top, f);
            top += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top0 -= 1;
            const v0: number = __readCell(saved0, top0);
            top0 -= 1;
            const v: number = __readCell(saved0, top0);
            __writeCell(saved0, top0, add(v, v0));
            top0 += 1;
          }
        }
      }
    }
  },
};

export const { forestSize, roseSize } = roseSizeForestSize;

const roseSumForestSum = {
  forestSum: (f: Forest, acc: number): number => {
    const saved: [Rose][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    let depth = 0;
    let f0 = f;
    let acc0 = acc;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const acc1: number = __readCell(saved0, top0);
          top -= 1;
          const r: Rose = __readCell(saved, top);
          f0 = r.f;
          acc0 = add(acc1, r.k);
          which = 1;
          continue;
        }

        default: {
          let returned0: number;

          switch (f0.tag) {
            case "FNil": {
              returned0 = acc0;
              break;
            }

            case "FCons": {
              depth += 1;
              __writeCell(saved1, top1, f0.f);
              top1 += 1;
              __writeCell(saved, top, f0.r);
              top += 1;
              __writeCell(saved0, top0, acc0);
              top0 += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = f0 satisfies never;
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
        }
      }

      if (depth === 0) {
        top0 -= 1;

        return __readCell(saved0, top0);
      }

      depth -= 1;
      top0 -= 1;
      const v: number = __readCell(saved0, top0);
      top1 -= 1;
      const f1: Forest = __readCell(saved1, top1);
      f0 = f1;
      acc0 = v;
      which = 1;
      continue;
    }
  },
  roseSum: (r: Rose, acc: number): number => {
    const saved: [Forest][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    let depth = 0;
    let r0 = r;
    let acc0 = acc;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(saved, top, r0.f);
          top += 1;
          __writeCell(saved0, top0, add(acc0, r0.k));
          top0 += 1;
          which = 1;
          continue;
        }

        default: {
          top0 -= 1;
          const acc1: number = __readCell(saved0, top0);
          top -= 1;
          const f: Forest = __readCell(saved, top);
          let returned0: number;

          switch (f.tag) {
            case "FNil": {
              returned0 = acc1;
              break;
            }

            case "FCons": {
              depth += 1;
              __writeCell(saved, top, f.f);
              top += 1;
              r0 = f.r;
              acc0 = acc1;
              which = 0;
              continue;
            }

            default: {
              returned0 = f satisfies never;
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
        }
      }

      if (depth === 0) {
        top0 -= 1;

        return __readCell(saved0, top0);
      }

      depth -= 1;
      top0 -= 1;
      const v: number = __readCell(saved0, top0);
      top -= 1;
      const f: Forest = __readCell(saved, top);
      __writeCell(saved, top, f);
      top += 1;
      __writeCell(saved0, top0, v);
      top0 += 1;
      which = 1;
      continue;
    }
  },
};

export const { forestSum, roseSum } = roseSumForestSum;

export const twiceAfter = (n: number): number => {
  const saved: [(_0: number) => number][] = [];
  let top = 0;
  let n0 = n;

  for (;;) {
    let returned: number;
    const n1 = n0;

    if (n1 === 0) {
      returned = 0;
    } else {
      const m: number = n1 - 1;
      const f = (x: number): number => add(x, n1);
      __writeCell(saved, top, f);
      top += 1;
      n0 = m;
      continue;
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const f: (_0: number) => number = __readCell(saved, top);
      returned = f(f(returned));
    }
  }
};

export const merge = (l1: List<number>, l2: List<number>): List<number> => {
  const saved: [number][] = [];
  let top = 0;
  let l10 = l1;
  let l20 = l2;
  let which = 0;

  for (;;) {
    let returned: List<number>;

    switch (which) {
      case 0: {
        switch (l10.tag) {
          case "Nil": {
            returned = l20;
            break;
          }

          case "Cons": {
            switch (l20.tag) {
              case "Nil": {
                returned = l10;
                break;
              }

              case "Cons": {
                if (leb(l10.arg0, l20.arg0)) {
                  __writeCell(saved, top, l10.arg0);
                  top += 1;
                  l10 = l10.arg1;
                  continue;
                }

                __writeCell(saved, top, l20.arg0);
                top += 1;
                l20 = l20.arg1;
                which = 1;
                continue;
              }

              default: {
                returned = l20 satisfies never;
              }
            }

            break;
          }

          default: {
            returned = l10 satisfies never;
          }
        }

        break;
      }

      default: {
        switch (l10.tag) {
          case "Nil": {
            returned = l20;
            break;
          }

          case "Cons": {
            switch (l20.tag) {
              case "Nil": {
                returned = l10;
                break;
              }

              case "Cons": {
                if (leb(l10.arg0, l20.arg0)) {
                  __writeCell(saved, top, l10.arg0);
                  top += 1;
                  const l11: List<number> = l10.arg1;
                  l10 = l11;
                  continue;
                }

                __writeCell(saved, top, l20.arg0);
                top += 1;
                l20 = l20.arg1;
                continue;
              }

              default: {
                returned = l20 satisfies never;
              }
            }

            break;
          }

          default: {
            returned = l10 satisfies never;
          }
        }
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: number = __readCell(saved, top);
      returned = cons(arg0, returned);
    }
  }
};

const boom = (_unused: number): number =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Stack.Stack.boom)");

const bottom = (_unused: number): number =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Stack.Stack.bottom)");

export const order = (n: number): number => {
  const saved: [number][] = [];
  let top = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = bottom(0);
    } else {
      const m: number = n0 - 1;
      const x: number = eqb(m, s(s(0))) ? boom(m) : m;
      __writeCell(saved, top, x);
      top += 1;
      n0 = m;
      continue;
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const x: number = __readCell(saved, top);
      returned = add(x, returned);
    }
  }
};

export const savedValues = <A>(
  combine: (_: A) => (_: A) => A,
  n: number,
  x: A,
  y: A
): A => {
  const saved: [A][] = [];
  let top = 0;
  let n0 = n;
  let x0 = x;
  let y0 = y;

  for (;;) {
    let returned: A;

    if (n0 === 0) {
      returned = y0;
    } else {
      const m: number = n0 - 1;
      __writeCell(saved, top, x0);
      top += 1;
      const x1: A = y0;
      n0 = m;
      y0 = x0;
      x0 = x1;
      continue;
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const x00: A = __readCell(saved, top);
      returned = combine(x00)(returned);
    }
  }
};

const shuttleShuttleList = {
  shuttle: <A>(n: number, x: A, y: A): A => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [readonly [A, A]][] = [];
    let top0 = 0;
    const saved1: [A][] = [];
    let top1 = 0;
    const saved2: [List<A>][] = [];
    let top2 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let n0 = n;
    let x1 = x;
    let y0 = y;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          let returned0: A;

          if (n0 === 0) {
            returned0 = x1;
          } else {
            const m: number = n0 - 1;
            __writeCell(frames, depth, 0);
            depth += 1;
            __writeCell(saved1, top1, y0);
            top1 += 1;
            __writeCell(saved, top, m);
            top += 1;
            __writeCell(saved0, top0, pair(y0, x1));
            top0 += 1;
            which = 1;
            continue;
          }

          __writeCell(saved1, top1, returned0);
          top1 += 1;
          break;
        }

        default: {
          top0 -= 1;
          const xy: readonly [A, A] = __readCell(saved0, top0);
          top -= 1;
          const n1: number = __readCell(saved, top);
          let returned0: List<A>;

          if (n1 === 0) {
            returned0 = cons(snd(xy), nil);
          } else {
            const m: number = n1 - 1;
            const x0: A = fst(xy);
            __writeCell(frames, depth, 1);
            depth += 1;
            __writeCell(saved1, top1, x0);
            top1 += 1;
            n0 = m;
            x1 = snd(xy);
            y0 = fst(xy);
            which = 0;
            continue;
          }

          __writeCell(saved2, top2, returned0);
          top2 += 1;
        }
      }

      for (;;) {
        if (depth === 0) {
          top1 -= 1;

          return __readCell(saved1, top1);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top2 -= 1;
            const v: List<A> = __readCell(saved2, top2);
            top1 -= 1;
            const y00: A = __readCell(saved1, top1);
            __writeCell(saved1, top1, v.tag === "Nil" ? y00 : v.arg0);
            top1 += 1;
            break;
          }

          default: {
            top1 -= 1;
            const v: A = __readCell(saved1, top1);
            top1 -= 1;
            const x0: A = __readCell(saved1, top1);
            __writeCell(saved2, top2, cons(x0, cons(v, nil)));
            top2 += 1;
          }
        }
      }
    }
  },
  shuttleList: <A>(n: number, xy: readonly [A, A]): List<A> => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [A][] = [];
    let top0 = 0;
    const saved1: [List<A>][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let n0 = n;
    let xy0 = xy;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const y: A = __readCell(saved0, top0);
          top0 -= 1;
          const x: A = __readCell(saved0, top0);
          top -= 1;
          const n1: number = __readCell(saved, top);
          let returned0: A;

          if (n1 === 0) {
            returned0 = x;
          } else {
            const m: number = n1 - 1;
            __writeCell(frames, depth, 0);
            depth += 1;
            __writeCell(saved0, top0, y);
            top0 += 1;
            n0 = m;
            xy0 = pair(y, x);
            which = 1;
            continue;
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
          break;
        }

        default: {
          let returned0: List<A>;

          if (n0 === 0) {
            returned0 = cons(snd(xy0), nil);
          } else {
            const m: number = n0 - 1;
            const x: A = fst(xy0);
            __writeCell(frames, depth, 1);
            depth += 1;
            __writeCell(saved0, top0, x);
            top0 += 1;
            __writeCell(saved, top, m);
            top += 1;
            __writeCell(saved0, top0, snd(xy0));
            top0 += 1;
            __writeCell(saved0, top0, fst(xy0));
            top0 += 1;
            which = 0;
            continue;
          }

          __writeCell(saved1, top1, returned0);
          top1 += 1;
        }
      }

      for (;;) {
        if (depth === 0) {
          top1 -= 1;

          return __readCell(saved1, top1);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top1 -= 1;
            const v: List<A> = __readCell(saved1, top1);
            top0 -= 1;
            const y: A = __readCell(saved0, top0);
            __writeCell(saved0, top0, v.tag === "Nil" ? y : v.arg0);
            top0 += 1;
            break;
          }

          default: {
            top0 -= 1;
            const v: A = __readCell(saved0, top0);
            top0 -= 1;
            const x: A = __readCell(saved0, top0);
            __writeCell(saved1, top1, cons(x, cons(v, nil)));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { shuttle, shuttleList } = shuttleShuttleList;

const observedEvenObservedOdd = {
  observedEven: (
    visit: (_: number) => (_: List<number>) => List<number>,
    xs: List<number>
  ): boolean => {
    const saved: [(_: number) => (_: List<number>) => List<number>][] = [];
    let top = 0;
    const saved0: [List<number>][] = [];
    let top0 = 0;
    let visit0 = visit;
    let xs0 = xs;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          switch (xs0.tag) {
            case "Nil": {
              return true;
            }

            case "Cons": {
              __writeCell(saved, top, visit0);
              top += 1;
              __writeCell(saved0, top0, xs0.arg1);
              top0 += 1;
              __writeCell(
                saved0,
                top0,
                visit0(s(s(0)))(visit0(s(0))(xs0.arg1))
              );
              top0 += 1;
              which = 1;
              continue;
            }

            default: {
              return xs0 satisfies never;
            }
          }
        }

        default: {
          top0 -= 1;
          top0 -= 1;
          const xs1: List<number> = __readCell(saved0, top0);
          top -= 1;

          const visit1: (_: number) => (_: List<number>) => List<number> =
            __readCell(saved, top);

          switch (xs1.tag) {
            case "Nil": {
              return false;
            }

            case "Cons": {
              visit0 = visit1;
              xs0 = xs1.arg1;
              which = 0;
              continue;
            }

            default: {
              return xs1 satisfies never;
            }
          }
        }
      }
    }
  },
  observedOdd: (
    visit: (_: number) => (_: List<number>) => List<number>,
    xs: List<number>,
    _unused: List<number>
  ): boolean => {
    const saved: [(_: number) => (_: List<number>) => List<number>][] = [];
    let top = 0;
    const saved0: [List<number>][] = [];
    let top0 = 0;
    let visit0 = visit;
    let xs0 = xs;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const xs1: List<number> = __readCell(saved0, top0);
          top -= 1;

          const visit1: (_: number) => (_: List<number>) => List<number> =
            __readCell(saved, top);

          switch (xs1.tag) {
            case "Nil": {
              return true;
            }

            case "Cons": {
              visit0 = visit1;
              xs0 = xs1.arg1;
              visit1(s(s(0)))(visit1(s(0))(xs1.arg1));
              which = 1;
              continue;
            }

            default: {
              return xs1 satisfies never;
            }
          }
        }

        default: {
          switch (xs0.tag) {
            case "Nil": {
              return false;
            }

            case "Cons": {
              __writeCell(saved, top, visit0);
              top += 1;
              __writeCell(saved0, top0, xs0.arg1);
              top0 += 1;
              which = 0;
              continue;
            }

            default: {
              return xs0 satisfies never;
            }
          }
        }
      }
    }
  },
};

export const { observedEven, observedOdd } = observedEvenObservedOdd;

export const observedTail = (
  visit: (_: number) => number,
  n: number,
  _unused: number
): number => {
  let n0 = n;

  for (;;) {
    if (n0 === 0) {
      return 0;
    }

    const m: number = n0 - 1;
    visit(n0);
    n0 = m;
  }
};

export const dropClosure = (
  n: number,
  _x: number,
  _unused: (_: undefined) => number
): number => {
  let n0 = n;

  for (;;) {
    const n1 = n0;

    if (n1 === 0) {
      return 0;
    }

    const m: number = n1 - 1;
    n0 = m;
  }
};

export const dropLetClosure = (
  n: number,
  x: number,
  _unused: (_: undefined) => number
): number => {
  let n0 = n;
  let x0 = x;

  for (;;) {
    if (n0 === 0) {
      return 0;
    }

    const m: number = n0 - 1;
    add(x0, s(0));
    n0 = m;
    x0 = 0;
  }
};

export const dropClosureChain = (
  n: number,
  _x: number,
  _y: number,
  _unused: (_: undefined) => number
): number => {
  let n0 = n;

  for (;;) {
    const n1 = n0;

    if (n1 === 0) {
      return 0;
    }

    const m: number = n1 - 1;
    n0 = m;
  }
};

const dropMutualClosureDropMutualClosureOdd = {
  dropMutualClosure: (
    n: number,
    _x: number,
    _y: number,
    _unused: (_: undefined) => number
  ): number => {
    let n0 = n;

    for (;;) {
      const n1 = n0;

      if (n1 === 0) {
        return 0;
      }

      const m: number = n1 - 1;
      const n2: number = m;

      if (n2 === 0) {
        return 0;
      }

      const m0: number = n2 - 1;
      n0 = m0;
    }
  },
  dropMutualClosureOdd: (
    n: number,
    _x: number,
    _y: number,
    _unused: (_: undefined) => number
  ): number => {
    let n0 = n;

    for (;;) {
      const n1 = n0;

      if (n1 === 0) {
        return 0;
      }

      const m: number = n1 - 1;
      const n2: number = m;

      if (n2 === 0) {
        return 0;
      }

      const m0: number = n2 - 1;
      n0 = m0;
    }
  },
};

export const { dropMutualClosure, dropMutualClosureOdd } =
  dropMutualClosureDropMutualClosureOdd;

export const dropEffectClosure = (
  visit: (_: number) => number,
  n: number,
  _x: number,
  _unused: (_: undefined) => number
): number => {
  let n0 = n;

  for (;;) {
    const n1 = n0;

    if (n1 === 0) {
      return 0;
    }

    const m: number = n1 - 1;
    visit(n1);
    n0 = m;
  }
};

const loop = (n: number, _x: number, _unused: (_: never) => number): number => {
  let n0 = n;

  for (;;) {
    const n1 = n0;

    if (n1 === 0) {
      return 0;
    }

    const m: number = n1 - 1;
    n0 = m;
  }
};

export const dropLocalClosure = (n: number, x: number): number =>
  loop(n, x, (): number => x);
