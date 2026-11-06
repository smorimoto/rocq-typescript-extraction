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

export const size = <A>(t: Tree<A>): number => {
  const saved: [Tree<A>][] = [];
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
          const returned0: number = __readCell(saved0, top0);
          returned = s(add(returned0, returned));
        }
      }
    }
  }
};
