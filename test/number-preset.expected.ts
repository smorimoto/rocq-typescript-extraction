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

export const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const div: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (m === 0 ? 0 : Math.floor(n / m));

const npos = (p: number): number => p;
const Pos$succ: (_0: number) => number = (x: number): number => x + 1;

const Z$add: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

export const Z = {
  add: Z$add,
} as const;

export const even = (n: number): boolean => {
  let n1 = n;

  for (;;) {
    if (n1 === 0) {
      return true;
    }

    const n0: number = n1 - 1;

    if (n0 === 0) {
      return false;
    }

    const m: number = n0 - 1;
    n1 = m;
  }
};

export const swap = <A, B>(p: readonly [A, B]): readonly [B, A] =>
  pair(p[1], p[0]);

export const flip = <A, B>(p: readonly [A, B]): readonly [B, A] =>
  pair(snd(p), fst(p));

export const halve = (n: number): readonly [number, boolean] =>
  pair(div(n, s(s(0))), negb(even(n)));

export const tick = (n: number): readonly [undefined, number] =>
  pair(undefined, s(n));

export const digits = (p: number): number => {
  let depth = 0;
  let p0 = p;

  for (;;) {
    let returned: number;

    if (p0 > 1 && p0 % 2 === 1) {
      const q: number = (p0 - 1) / 2;
      depth += 1;
      p0 = q;
      continue;
    }

    if (p0 % 2 === 0) {
      const q: number = p0 / 2;
      depth += 1;
      p0 = q;
      continue;
    }

    returned = s(0);

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(returned);
    }
  }
};

export const next0 = (n: number): number => (n === 0 ? 1 : npos(Pos$succ(n)));

export const magnitude = (z: number): number => {
  if (z === 0) {
    return 0;
  }

  if (z > 0) {
    return npos(z);
  }

  const p: number = -z;

  return npos(p);
};

export const minusSix = -6;

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

export const add0 = (a: number, b: number): number => add(add(a, b), b);
