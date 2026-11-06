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
const s = (n: bigint): bigint => n + 1n;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const fst: <A, B>(_0: readonly [A, B]) => A = <A, B>(p: readonly [A, B]): A =>
  p[0];

const snd: <A, B>(_0: readonly [A, B]) => B = <A, B>(p: readonly [A, B]): B =>
  p[1];

const pred: (_0: bigint) => bigint = (n: bigint): bigint =>
  n > 0n ? n - 1n : 0n;

export const add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

const mul: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n * m;

const sub: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (n > m ? n - m : 0n);

const div: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (m === 0n ? 0n : n / m);

const modulo: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (m === 0n ? n : n % m);

const npos = (p: bigint): bigint => p;
const Pos$succ: (_0: bigint) => bigint = (x: bigint): bigint => x + 1n;

const Z$add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y;

export const Z = {
  add: Z$add,
} as const;

const add0: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => BigInt.asUintN(63, x + y);

const add1: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

const cat: (_0: string, _1: string) => string = (
  s1: string,
  s2: string
): string => (s1 + s2).slice(0, 16_777_211);

export interface PArray<A> {
  readonly default: A;
  readonly items: readonly A[];
}

const get0: <A>(_0: PArray<A>, _1: bigint) => A = <A>(
  a: PArray<A>,
  i: bigint
): A => {
  if (i >= BigInt(a.items.length)) {
    return a.default;
  }

  const index = Number(i);
  const value = a.items[index];

  if (value !== undefined) {
    return value;
  }

  const present = a.items
    .slice(index, index + 1)
    .values()
    .next();

  return present.done ? a.default : present.value;
};

export const even = (n: bigint): boolean => {
  let n1 = n;

  for (;;) {
    if (n1 === 0n) {
      return true;
    }

    const n0: bigint = n1 - 1n;

    if (n0 === 0n) {
      return false;
    }

    const m: bigint = n0 - 1n;
    n1 = m;
  }
};

export const swap = <A, B>(p: readonly [A, B]): readonly [B, A] =>
  pair(p[1], p[0]);

export const flip = <A, B>(p: readonly [A, B]): readonly [B, A] =>
  pair(snd(p), fst(p));

export const halve = (n: bigint): readonly [bigint, boolean] =>
  pair(div(n, s(s(0n))), negb(even(n)));

export const tick = (n: bigint): readonly [undefined, bigint] =>
  pair(undefined, s(n));

export const digits = (p: bigint): bigint => {
  let pending = 0n;
  let p0 = p;

  for (;;) {
    if (p0 > 1n && p0 % 2n === 1n) {
      const q: bigint = p0 / 2n;
      pending += 1n;
      p0 = q;
      continue;
    }

    if (p0 % 2n === 0n) {
      const q: bigint = p0 / 2n;
      pending += 1n;
      p0 = q;
      continue;
    }

    const returned: bigint = s(0n);

    return returned + pending;
  }
};

export const next0 = (n: bigint): bigint => (n === 0n ? 1n : npos(Pos$succ(n)));

export const magnitude = (z: bigint): bigint => {
  if (z === 0n) {
    return 0n;
  }

  if (z > 0n) {
    return npos(z);
  }

  const p: bigint = -z;

  return npos(p);
};

export const minusSix = -6n;

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

export const size = <A>(t: Tree<A>): bigint => {
  const saved: [Tree<A>][] = [];
  let top = 0;
  const saved0: [bigint][] = [];
  let top0 = 0;
  const frames: [number][] = [];
  let depth = 0;
  let t0 = t;

  for (;;) {
    let returned: bigint;

    switch (t0.tag) {
      case "Leaf": {
        returned = 0n;
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
          const returned0: bigint = __readCell(saved0, top0);
          returned = s(add(returned0, returned));
        }
      }
    }
  }
};

export const twiceRight = (a: bigint, b: bigint): bigint => add(add(a, b), b);

export interface Origin {
  readonly tag: "Origin";
}

export interface Tick {
  readonly tag: "Tick";
  readonly previous: Counter;
}

export type Counter = Origin | Tick;

export const origin: Origin = { tag: "Origin" };

export const tick0 = (previous: Counter): Counter => ({
  previous,
  tag: "Tick",
});

export const count = (c: Counter): bigint => {
  let pending = 0n;
  let c0 = c;

  for (;;) {
    let returned: bigint;

    switch (c0.tag) {
      case "Origin": {
        returned = 0n;
        break;
      }

      case "Tick": {
        pending += 1n;
        c0 = c0.previous;
        continue;
      }

      default: {
        returned = c0 satisfies never;
      }
    }

    return returned + pending;
  }
};

export const subtract = (x: bigint, x0: bigint): bigint => sub(x, x0);
export const predecessor = (x: bigint): bigint => pred(x);
export const divide = (x: bigint, x0: bigint): bigint => div(x, x0);
export const remainder = (x: bigint, x0: bigint): bigint => modulo(x, x0);
export const multiply = (x: bigint, x0: bigint): bigint => mul(x, x0);
export const primitiveIntAdd = (x: bigint, x0: bigint): bigint => add0(x, x0);
export const primitiveFloatAdd = (x: number, x0: number): number => add1(x, x0);
export const primitiveStringCat = (x: string, x0: string): string => cat(x, x0);

export const primitiveArrayGet = <A>(x: PArray<A>, x0: bigint): A =>
  get0(x, x0);
