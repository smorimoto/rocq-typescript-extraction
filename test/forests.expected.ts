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

const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const orb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a || b;

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

const min: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (n < m ? n : m);

export interface Node {
  readonly tag: "Node";
  readonly x: number;
  readonly children: Forest;
}

export type Tree = Node;

export const node = (x: number, children: Forest): Node => ({
  children,
  tag: "Node",
  x,
});

export interface Nil {
  readonly tag: "Nil";
}

export interface Cons {
  readonly tag: "Cons";
  readonly t: Tree;
  readonly rest: Forest;
}

export type Forest = Nil | Cons;

export const nil: Nil = { tag: "Nil" };

export const cons = (t: Tree, rest: Forest): Forest => ({
  rest,
  t,
  tag: "Cons",
});

const mapMapForest = {
  map0: (f: (_: number) => number, t: Tree): Tree => {
    const saved: [(_: number) => number][] = [];
    let top = 0;
    const saved0: [Forest][] = [];
    let top0 = 0;
    const saved1: [number][] = [];
    let top1 = 0;
    const saved2: [Tree][] = [];
    let top2 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let f0 = f;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, f0);
          top += 1;
          __writeCell(saved1, top1, t0.x);
          top1 += 1;
          __writeCell(saved, top, f0);
          top += 1;
          __writeCell(saved0, top0, t0.children);
          top0 += 1;
          which = 1;
          continue;
        }

        default: {
          top0 -= 1;
          const c: Forest = __readCell(saved0, top0);
          top -= 1;
          const f1: (_: number) => number = __readCell(saved, top);
          let returned0: Forest;

          switch (c.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, f1);
              top += 1;
              __writeCell(saved0, top0, c.rest);
              top0 += 1;
              f0 = f1;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
        }
      }

      let resuming = true;

      while (resuming) {
        if (depth === 0) {
          top2 -= 1;

          return __readCell(saved2, top2);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top0 -= 1;
            const v: Forest = __readCell(saved0, top0);
            top1 -= 1;
            const x: number = __readCell(saved1, top1);
            top -= 1;
            const f00: (_: number) => number = __readCell(saved, top);
            __writeCell(saved2, top2, node(f00(x), v));
            top2 += 1;
            break;
          }

          case 1: {
            top2 -= 1;
            const v: Tree = __readCell(saved2, top2);
            top0 -= 1;
            const rest: Forest = __readCell(saved0, top0);
            top -= 1;
            const f1: (_: number) => number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved2, top2, v);
            top2 += 1;
            __writeCell(saved, top, f1);
            top += 1;
            __writeCell(saved0, top0, rest);
            top0 += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top0 -= 1;
            const v0: Forest = __readCell(saved0, top0);
            top2 -= 1;
            const v: Tree = __readCell(saved2, top2);
            __writeCell(saved0, top0, cons(v, v0));
            top0 += 1;
          }
        }
      }
    }
  },
  mapForest: (f: (_: number) => number, c: Forest): Forest => {
    const saved: [(_: number) => number][] = [];
    let top = 0;
    const saved0: [Tree][] = [];
    let top0 = 0;
    const saved1: [number][] = [];
    let top1 = 0;
    const saved2: [Forest][] = [];
    let top2 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let f0 = f;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const t: Tree = __readCell(saved0, top0);
          top -= 1;
          const f1: (_: number) => number = __readCell(saved, top);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, f1);
          top += 1;
          __writeCell(saved1, top1, t.x);
          top1 += 1;
          f0 = f1;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: Forest;

          switch (c0.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, f0);
              top += 1;
              __writeCell(saved2, top2, c0.rest);
              top2 += 1;
              __writeCell(saved, top, f0);
              top += 1;
              __writeCell(saved0, top0, c0.t);
              top0 += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
            }
          }

          __writeCell(saved2, top2, returned0);
          top2 += 1;
        }
      }

      let resuming = true;

      while (resuming) {
        if (depth === 0) {
          top2 -= 1;

          return __readCell(saved2, top2);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top2 -= 1;
            const v: Forest = __readCell(saved2, top2);
            top1 -= 1;
            const x: number = __readCell(saved1, top1);
            top -= 1;
            const f1: (_: number) => number = __readCell(saved, top);
            __writeCell(saved0, top0, node(f1(x), v));
            top0 += 1;
            break;
          }

          case 1: {
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            top2 -= 1;
            const rest: Forest = __readCell(saved2, top2);
            top -= 1;
            const f00: (_: number) => number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved0, top0, v);
            top0 += 1;
            f0 = f00;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top2 -= 1;
            const v0: Forest = __readCell(saved2, top2);
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            __writeCell(saved2, top2, cons(v, v0));
            top2 += 1;
          }
        }
      }
    }
  },
};

export const { map0: map, mapForest } = mapMapForest;

export const doubled = (t: Tree): Tree =>
  map((n: number): number => add(n, n), t);

const all = (p: (_: number) => boolean, t: Tree): boolean => {
  const everyEveryForest = {
    every0: (t0: Tree): boolean => {
      const saved: [Forest][] = [];
      let top = 0;
      const saved0: [number][] = [];
      let top0 = 0;
      const saved1: [boolean][] = [];
      let top1 = 0;
      const frames: [number][] = [];
      let depth = 0;
      let t1 = t0;
      let which = 0;

      for (;;) {
        switch (which) {
          case 0: {
            __writeCell(frames, depth, 0);
            depth += 1;
            __writeCell(saved0, top0, t1.x);
            top0 += 1;
            __writeCell(saved, top, t1.children);
            top += 1;
            which = 1;
            continue;
          }

          default: {
            top -= 1;
            const c: Forest = __readCell(saved, top);
            let returned0: boolean;

            switch (c.tag) {
              case "Nil": {
                returned0 = true;
                break;
              }

              case "Cons": {
                __writeCell(frames, depth, 1);
                depth += 1;
                __writeCell(saved, top, c.rest);
                top += 1;
                t1 = c.t;
                which = 0;
                continue;
              }

              default: {
                returned0 = c satisfies never;
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
              const v: boolean = __readCell(saved1, top1);
              top0 -= 1;
              const x: number = __readCell(saved0, top0);
              __writeCell(saved1, top1, andb(p(x), v));
              top1 += 1;
              break;
            }

            case 1: {
              top1 -= 1;
              const v: boolean = __readCell(saved1, top1);
              top -= 1;
              const rest: Forest = __readCell(saved, top);
              __writeCell(frames, depth, 2);
              depth += 1;
              __writeCell(saved1, top1, v);
              top1 += 1;
              __writeCell(saved, top, rest);
              top += 1;
              which = 1;
              resuming = false;
              continue;
            }

            default: {
              top1 -= 1;
              const v0: boolean = __readCell(saved1, top1);
              top1 -= 1;
              const v: boolean = __readCell(saved1, top1);
              __writeCell(saved1, top1, andb(v, v0));
              top1 += 1;
            }
          }
        }
      }
    },
    everyForest: (c: Forest): boolean => {
      const saved: [Tree][] = [];
      let top = 0;
      const saved0: [number][] = [];
      let top0 = 0;
      const saved1: [Forest][] = [];
      let top1 = 0;
      const saved2: [boolean][] = [];
      let top2 = 0;
      const frames: [number][] = [];
      let depth = 0;
      let c0 = c;
      let which = 1;

      for (;;) {
        switch (which) {
          case 0: {
            top -= 1;
            const t0: Tree = __readCell(saved, top);
            __writeCell(frames, depth, 0);
            depth += 1;
            __writeCell(saved0, top0, t0.x);
            top0 += 1;
            c0 = t0.children;
            which = 1;
            continue;
          }

          default: {
            let returned0: boolean;

            switch (c0.tag) {
              case "Nil": {
                returned0 = true;
                break;
              }

              case "Cons": {
                __writeCell(frames, depth, 1);
                depth += 1;
                __writeCell(saved1, top1, c0.rest);
                top1 += 1;
                __writeCell(saved, top, c0.t);
                top += 1;
                which = 0;
                continue;
              }

              default: {
                returned0 = c0 satisfies never;
              }
            }

            __writeCell(saved2, top2, returned0);
            top2 += 1;
          }
        }

        let resuming = true;

        while (resuming) {
          if (depth === 0) {
            top2 -= 1;

            return __readCell(saved2, top2);
          }

          depth -= 1;

          switch (__readCell(frames, depth)) {
            case 0: {
              top2 -= 1;
              const v: boolean = __readCell(saved2, top2);
              top0 -= 1;
              const x: number = __readCell(saved0, top0);
              __writeCell(saved2, top2, andb(p(x), v));
              top2 += 1;
              break;
            }

            case 1: {
              top2 -= 1;
              const v: boolean = __readCell(saved2, top2);
              top1 -= 1;
              const rest: Forest = __readCell(saved1, top1);
              __writeCell(frames, depth, 2);
              depth += 1;
              __writeCell(saved2, top2, v);
              top2 += 1;
              c0 = rest;
              which = 1;
              resuming = false;
              continue;
            }

            default: {
              top2 -= 1;
              const v0: boolean = __readCell(saved2, top2);
              top2 -= 1;
              const v: boolean = __readCell(saved2, top2);
              __writeCell(saved2, top2, andb(v, v0));
              top2 += 1;
            }
          }
        }
      }
    },
  };

  return everyEveryForest.every0(t);
};

export const allZero = (t: Tree): boolean =>
  all((n: number): boolean => eqb(n, 0), t);

const reduceReduceForest = {
  reduce0: (
    f: (_: number) => (_: number) => number,
    acc: number,
    t: Tree
  ): number => {
    const saved: [(_: number) => (_: number) => number][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    let depth = 0;
    let f0 = f;
    let acc0 = acc;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(saved, top, f0);
          top += 1;
          __writeCell(saved0, top0, f0(acc0)(t0.x));
          top0 += 1;
          __writeCell(saved1, top1, t0.children);
          top1 += 1;
          which = 1;
          continue;
        }

        default: {
          top1 -= 1;
          const c: Forest = __readCell(saved1, top1);
          top0 -= 1;
          const acc1: number = __readCell(saved0, top0);
          top -= 1;

          const f1: (_: number) => (_: number) => number = __readCell(
            saved,
            top
          );

          let returned0: number;

          switch (c.tag) {
            case "Nil": {
              returned0 = acc1;
              break;
            }

            case "Cons": {
              depth += 1;
              __writeCell(saved, top, f1);
              top += 1;
              __writeCell(saved1, top1, c.rest);
              top1 += 1;
              f0 = f1;
              acc0 = acc1;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
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
      const rest: Forest = __readCell(saved1, top1);
      top -= 1;
      const f1: (_: number) => (_: number) => number = __readCell(saved, top);
      __writeCell(saved, top, f1);
      top += 1;
      __writeCell(saved0, top0, v);
      top0 += 1;
      __writeCell(saved1, top1, rest);
      top1 += 1;
      which = 1;
      continue;
    }
  },
  reduceForest: (
    f: (_: number) => (_: number) => number,
    acc: number,
    c: Forest
  ): number => {
    const saved: [(_: number) => (_: number) => number][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Tree][] = [];
    let top1 = 0;
    const saved2: [Forest][] = [];
    let top2 = 0;
    let depth = 0;
    let f0 = f;
    let acc0 = acc;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top1 -= 1;
          const t: Tree = __readCell(saved1, top1);
          top0 -= 1;
          const acc1: number = __readCell(saved0, top0);
          top -= 1;

          const f1: (_: number) => (_: number) => number = __readCell(
            saved,
            top
          );

          f0 = f1;
          acc0 = f1(acc1)(t.x);
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: number;

          switch (c0.tag) {
            case "Nil": {
              returned0 = acc0;
              break;
            }

            case "Cons": {
              depth += 1;
              __writeCell(saved, top, f0);
              top += 1;
              __writeCell(saved2, top2, c0.rest);
              top2 += 1;
              __writeCell(saved, top, f0);
              top += 1;
              __writeCell(saved0, top0, acc0);
              top0 += 1;
              __writeCell(saved1, top1, c0.t);
              top1 += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
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
      top2 -= 1;
      const rest: Forest = __readCell(saved2, top2);
      top -= 1;
      const f00: (_: number) => (_: number) => number = __readCell(saved, top);
      f0 = f00;
      acc0 = v;
      c0 = rest;
      which = 1;
      continue;
    }
  },
};

export const { reduce0: reduce } = reduceReduceForest;

const append = (c: Forest, d: Forest): Forest => {
  const saved: [Tree][] = [];
  let top = 0;
  let c0 = c;

  for (;;) {
    let returned: Forest;

    switch (c0.tag) {
      case "Nil": {
        returned = d;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, c0.t);
        top += 1;
        c0 = c0.rest;
        continue;
      }

      default: {
        returned = c0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const t: Tree = __readCell(saved, top);
      returned = cons(t, returned);
    }
  }
};

const concatConcatForest = {
  concat0: (t: Tree): Forest => {
    const saved: [Forest][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved0, top0, t0.x);
          top0 += 1;
          __writeCell(saved, top, t0.children);
          top += 1;
          which = 1;
          continue;
        }

        default: {
          top -= 1;
          const c: Forest = __readCell(saved, top);
          let returned0: Forest;

          switch (c.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, c.rest);
              top += 1;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
            }
          }

          __writeCell(saved, top, returned0);
          top += 1;
        }
      }

      let resuming = true;

      while (resuming) {
        if (depth === 0) {
          top -= 1;

          return __readCell(saved, top);
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            top -= 1;
            const v: Forest = __readCell(saved, top);
            top0 -= 1;
            const x: number = __readCell(saved0, top0);
            __writeCell(saved, top, cons(node(x, nil), v));
            top += 1;
            break;
          }

          case 1: {
            top -= 1;
            const v: Forest = __readCell(saved, top);
            top -= 1;
            const rest: Forest = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved, top, v);
            top += 1;
            __writeCell(saved, top, rest);
            top += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top -= 1;
            const v0: Forest = __readCell(saved, top);
            top -= 1;
            const v: Forest = __readCell(saved, top);
            __writeCell(saved, top, append(v, v0));
            top += 1;
          }
        }
      }
    }
  },
  concatForest: (c: Forest): Forest => {
    const saved: [Tree][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top -= 1;
          const t: Tree = __readCell(saved, top);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved0, top0, t.x);
          top0 += 1;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: Forest;

          switch (c0.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved1, top1, c0.rest);
              top1 += 1;
              __writeCell(saved, top, c0.t);
              top += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
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
            const v: Forest = __readCell(saved1, top1);
            top0 -= 1;
            const x: number = __readCell(saved0, top0);
            __writeCell(saved1, top1, cons(node(x, nil), v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: Forest = __readCell(saved1, top1);
            top1 -= 1;
            const rest: Forest = __readCell(saved1, top1);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: Forest = __readCell(saved1, top1);
            top1 -= 1;
            const v: Forest = __readCell(saved1, top1);
            __writeCell(saved1, top1, append(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { concat0: concat } = concatConcatForest;

const hasOwnPropertyHasOwnPropertyForest = {
  hasOwnProperty0: (x: number, t: Tree): boolean => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Forest][] = [];
    let top0 = 0;
    const saved1: [boolean][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let x1 = x;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          const x0: boolean = eqb(x1, t0.x);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved1, top1, x0);
          top1 += 1;
          __writeCell(saved, top, x1);
          top += 1;
          __writeCell(saved0, top0, t0.children);
          top0 += 1;
          which = 1;
          continue;
        }

        default: {
          top0 -= 1;
          const c: Forest = __readCell(saved0, top0);
          top -= 1;
          const x0: number = __readCell(saved, top);
          let returned0: boolean;

          switch (c.tag) {
            case "Nil": {
              returned0 = false;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, x0);
              top += 1;
              __writeCell(saved0, top0, c.rest);
              top0 += 1;
              x1 = x0;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
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
            const v: boolean = __readCell(saved1, top1);
            top1 -= 1;
            const x0: boolean = __readCell(saved1, top1);
            __writeCell(saved1, top1, orb(x0, v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: boolean = __readCell(saved1, top1);
            top0 -= 1;
            const rest: Forest = __readCell(saved0, top0);
            top -= 1;
            const x0: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            __writeCell(saved, top, x0);
            top += 1;
            __writeCell(saved0, top0, rest);
            top0 += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: boolean = __readCell(saved1, top1);
            top1 -= 1;
            const v: boolean = __readCell(saved1, top1);
            __writeCell(saved1, top1, orb(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
  hasOwnPropertyForest: (x: number, c: Forest): boolean => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Tree][] = [];
    let top0 = 0;
    const saved1: [boolean][] = [];
    let top1 = 0;
    const saved2: [Forest][] = [];
    let top2 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let x1 = x;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const t: Tree = __readCell(saved0, top0);
          top -= 1;
          const x0: number = __readCell(saved, top);
          const x2: boolean = eqb(x0, t.x);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved1, top1, x2);
          top1 += 1;
          x1 = x0;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: boolean;

          switch (c0.tag) {
            case "Nil": {
              returned0 = false;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, x1);
              top += 1;
              __writeCell(saved2, top2, c0.rest);
              top2 += 1;
              __writeCell(saved, top, x1);
              top += 1;
              __writeCell(saved0, top0, c0.t);
              top0 += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
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
            const v: boolean = __readCell(saved1, top1);
            top1 -= 1;
            const x2: boolean = __readCell(saved1, top1);
            __writeCell(saved1, top1, orb(x2, v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: boolean = __readCell(saved1, top1);
            top2 -= 1;
            const rest: Forest = __readCell(saved2, top2);
            top -= 1;
            const x10: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            x1 = x10;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: boolean = __readCell(saved1, top1);
            top1 -= 1;
            const v: boolean = __readCell(saved1, top1);
            __writeCell(saved1, top1, orb(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { hasOwnProperty0: hasOwnProperty } =
  hasOwnPropertyHasOwnPropertyForest;

const substrSubstrForest = {
  substr0: (n: number, t: Tree): Tree => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Forest][] = [];
    let top0 = 0;
    const saved1: [Tree][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let n0 = n;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, t0.x);
          top += 1;
          __writeCell(saved, top, n0);
          top += 1;
          __writeCell(saved0, top0, t0.children);
          top0 += 1;
          which = 1;
          continue;
        }

        default: {
          top0 -= 1;
          const c: Forest = __readCell(saved0, top0);
          top -= 1;
          const n1: number = __readCell(saved, top);
          let returned0: Forest;

          if (n1 === 0) {
            returned0 = nil;
          } else {
            const k: number = n1 - 1;

            switch (c.tag) {
              case "Nil": {
                returned0 = nil;
                break;
              }

              case "Cons": {
                __writeCell(frames, depth, 1);
                depth += 1;
                __writeCell(saved, top, n1);
                top += 1;
                __writeCell(saved0, top0, c.rest);
                top0 += 1;
                n0 = k;
                t0 = c.t;
                which = 0;
                continue;
              }

              default: {
                returned0 = c satisfies never;
              }
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
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
            top0 -= 1;
            const v: Forest = __readCell(saved0, top0);
            top -= 1;
            const x: number = __readCell(saved, top);
            __writeCell(saved1, top1, node(x, v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            top0 -= 1;
            const rest: Forest = __readCell(saved0, top0);
            top -= 1;
            const n1: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            __writeCell(saved, top, n1);
            top += 1;
            __writeCell(saved0, top0, rest);
            top0 += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top0 -= 1;
            const v0: Forest = __readCell(saved0, top0);
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            __writeCell(saved0, top0, cons(v, v0));
            top0 += 1;
          }
        }
      }
    }
  },
  substrForest: (n: number, c: Forest): Forest => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Tree][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let n0 = n;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const t: Tree = __readCell(saved0, top0);
          top -= 1;
          const n1: number = __readCell(saved, top);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, t.x);
          top += 1;
          n0 = n1;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: Forest;

          if (n0 === 0) {
            returned0 = nil;
          } else {
            const k: number = n0 - 1;

            switch (c0.tag) {
              case "Nil": {
                returned0 = nil;
                break;
              }

              case "Cons": {
                __writeCell(frames, depth, 1);
                depth += 1;
                __writeCell(saved, top, n0);
                top += 1;
                __writeCell(saved1, top1, c0.rest);
                top1 += 1;
                __writeCell(saved, top, k);
                top += 1;
                __writeCell(saved0, top0, c0.t);
                top0 += 1;
                which = 0;
                continue;
              }

              default: {
                returned0 = c0 satisfies never;
              }
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
            const v: Forest = __readCell(saved1, top1);
            top -= 1;
            const x: number = __readCell(saved, top);
            __writeCell(saved0, top0, node(x, v));
            top0 += 1;
            break;
          }

          case 1: {
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            top1 -= 1;
            const rest: Forest = __readCell(saved1, top1);
            top -= 1;
            const n00: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved0, top0, v);
            top0 += 1;
            n0 = n00;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: Forest = __readCell(saved1, top1);
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            __writeCell(saved1, top1, cons(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { substr0: substr } = substrSubstrForest;
const root = (t: Tree): number => t.x;

const insert = (t: Tree, c: Forest): Forest => {
  const saved: [Tree][] = [];
  let top = 0;
  let c0 = c;

  for (;;) {
    let returned: Forest;

    switch (c0.tag) {
      case "Nil": {
        returned = cons(t, nil);
        break;
      }

      case "Cons": {
        if (leb(root(t), root(c0.t))) {
          returned = cons(t, c0);
        } else {
          __writeCell(saved, top, c0.t);
          top += 1;
          c0 = c0.rest;
          continue;
        }

        break;
      }

      default: {
        returned = c0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const t0: Tree = __readCell(saved, top);
      returned = cons(t0, returned);
    }
  }
};

const sortSortForest = {
  sort: (t: Tree): Tree => {
    const saved: [Forest][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Tree][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved0, top0, t0.x);
          top0 += 1;
          __writeCell(saved, top, t0.children);
          top += 1;
          which = 1;
          continue;
        }

        default: {
          top -= 1;
          const c: Forest = __readCell(saved, top);
          let returned0: Forest;

          switch (c.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, c.rest);
              top += 1;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
            }
          }

          __writeCell(saved, top, returned0);
          top += 1;
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
            top -= 1;
            const v: Forest = __readCell(saved, top);
            top0 -= 1;
            const x: number = __readCell(saved0, top0);
            __writeCell(saved1, top1, node(x, v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            top -= 1;
            const rest: Forest = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            __writeCell(saved, top, rest);
            top += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top -= 1;
            const v0: Forest = __readCell(saved, top);
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            __writeCell(saved, top, insert(v, v0));
            top += 1;
          }
        }
      }
    }
  },
  sortForest: (c: Forest): Forest => {
    const saved: [Tree][] = [];
    let top = 0;
    const saved0: [number][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top -= 1;
          const t: Tree = __readCell(saved, top);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved0, top0, t.x);
          top0 += 1;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: Forest;

          switch (c0.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved1, top1, c0.rest);
              top1 += 1;
              __writeCell(saved, top, c0.t);
              top += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
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
            const v: Forest = __readCell(saved1, top1);
            top0 -= 1;
            const x: number = __readCell(saved0, top0);
            __writeCell(saved, top, node(x, v));
            top += 1;
            break;
          }

          case 1: {
            top -= 1;
            const v: Tree = __readCell(saved, top);
            top1 -= 1;
            const rest: Forest = __readCell(saved1, top1);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved, top, v);
            top += 1;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: Forest = __readCell(saved1, top1);
            top -= 1;
            const v: Tree = __readCell(saved, top);
            __writeCell(saved1, top1, insert(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { sort } = sortSortForest;

const toFixedToFixedForest = {
  toFixed0: (d: number, t: Tree): Tree => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Forest][] = [];
    let top0 = 0;
    const saved1: [Tree][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let d0 = d;
    let t0 = t;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          const x: number = min(t0.x, d0);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, x);
          top += 1;
          __writeCell(saved, top, d0);
          top += 1;
          __writeCell(saved0, top0, t0.children);
          top0 += 1;
          which = 1;
          continue;
        }

        default: {
          top0 -= 1;
          const c: Forest = __readCell(saved0, top0);
          top -= 1;
          const d1: number = __readCell(saved, top);
          let returned0: Forest;

          switch (c.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, d1);
              top += 1;
              __writeCell(saved0, top0, c.rest);
              top0 += 1;
              d0 = d1;
              t0 = c.t;
              which = 0;
              continue;
            }

            default: {
              returned0 = c satisfies never;
            }
          }

          __writeCell(saved0, top0, returned0);
          top0 += 1;
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
            top0 -= 1;
            const v: Forest = __readCell(saved0, top0);
            top -= 1;
            const x: number = __readCell(saved, top);
            __writeCell(saved1, top1, node(x, v));
            top1 += 1;
            break;
          }

          case 1: {
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            top0 -= 1;
            const rest: Forest = __readCell(saved0, top0);
            top -= 1;
            const d1: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved1, top1, v);
            top1 += 1;
            __writeCell(saved, top, d1);
            top += 1;
            __writeCell(saved0, top0, rest);
            top0 += 1;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top0 -= 1;
            const v0: Forest = __readCell(saved0, top0);
            top1 -= 1;
            const v: Tree = __readCell(saved1, top1);
            __writeCell(saved0, top0, cons(v, v0));
            top0 += 1;
          }
        }
      }
    }
  },
  toFixedForest: (d: number, c: Forest): Forest => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [Tree][] = [];
    let top0 = 0;
    const saved1: [Forest][] = [];
    let top1 = 0;
    const frames: [number][] = [];
    let depth = 0;
    let d0 = d;
    let c0 = c;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top0 -= 1;
          const t: Tree = __readCell(saved0, top0);
          top -= 1;
          const d1: number = __readCell(saved, top);
          const x: number = min(t.x, d1);
          __writeCell(frames, depth, 0);
          depth += 1;
          __writeCell(saved, top, x);
          top += 1;
          d0 = d1;
          c0 = t.children;
          which = 1;
          continue;
        }

        default: {
          let returned0: Forest;

          switch (c0.tag) {
            case "Nil": {
              returned0 = nil;
              break;
            }

            case "Cons": {
              __writeCell(frames, depth, 1);
              depth += 1;
              __writeCell(saved, top, d0);
              top += 1;
              __writeCell(saved1, top1, c0.rest);
              top1 += 1;
              __writeCell(saved, top, d0);
              top += 1;
              __writeCell(saved0, top0, c0.t);
              top0 += 1;
              which = 0;
              continue;
            }

            default: {
              returned0 = c0 satisfies never;
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
            const v: Forest = __readCell(saved1, top1);
            top -= 1;
            const x: number = __readCell(saved, top);
            __writeCell(saved0, top0, node(x, v));
            top0 += 1;
            break;
          }

          case 1: {
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            top1 -= 1;
            const rest: Forest = __readCell(saved1, top1);
            top -= 1;
            const d00: number = __readCell(saved, top);
            __writeCell(frames, depth, 2);
            depth += 1;
            __writeCell(saved0, top0, v);
            top0 += 1;
            d0 = d00;
            c0 = rest;
            which = 1;
            resuming = false;
            continue;
          }

          default: {
            top1 -= 1;
            const v0: Forest = __readCell(saved1, top1);
            top0 -= 1;
            const v: Tree = __readCell(saved0, top0);
            __writeCell(saved1, top1, cons(v, v0));
            top1 += 1;
          }
        }
      }
    }
  },
};

export const { toFixed0: toFixed } = toFixedToFixedForest;
