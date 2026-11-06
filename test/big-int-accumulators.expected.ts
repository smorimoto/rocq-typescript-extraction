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

const Z$add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y;

export const count = (n: bigint, seed: bigint): bigint => {
  let pending = 0n;
  let n0 = n;

  for (;;) {
    let returned: bigint;

    if (n0 === 0n) {
      returned = seed;
    } else {
      const p: bigint = n0 - 1n;
      pending += 1n;
      n0 = p;
      continue;
    }

    return returned + pending;
  }
};

export const sumBefore = (
  f: (_: bigint) => bigint,
  xs: List<bigint>
): bigint => {
  let pending = 0n;
  let xs0 = xs;

  for (;;) {
    let returned: bigint;

    switch (xs0.tag) {
      case "Nil": {
        returned = 0n;
        break;
      }

      case "Cons": {
        const y: bigint = f(xs0.arg0);
        pending += y;
        xs0 = xs0.arg1;
        continue;
      }

      default: {
        returned = xs0 satisfies never;
      }
    }

    return returned + pending;
  }
};

export const sumAfter = (
  f: (_: bigint) => bigint,
  xs: List<bigint>
): bigint => {
  const saved: [bigint][] = [];
  let top = 0;
  let xs0 = xs;

  for (;;) {
    let returned: bigint;

    switch (xs0.tag) {
      case "Nil": {
        returned = 0n;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, xs0.arg0);
        top += 1;
        xs0 = xs0.arg1;
        continue;
      }

      default: {
        returned = xs0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: bigint = __readCell(saved, top);
      returned = Z$add(f(arg0), returned);
    }
  }
};

const combine: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x - y;

export const differences = (xs: List<bigint>): bigint => {
  const saved: [bigint][] = [];
  let top = 0;
  let xs0 = xs;

  for (;;) {
    let returned: bigint;

    switch (xs0.tag) {
      case "Nil": {
        returned = 0n;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, xs0.arg0);
        top += 1;
        xs0 = xs0.arg1;
        continue;
      }

      default: {
        returned = xs0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: bigint = __readCell(saved, top);
      returned = combine(arg0, returned);
    }
  }
};

const tick = (n: bigint): bigint => n + 2n;

export const ticks = (n: bigint): bigint => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: bigint;

    if (n0 === 0n) {
      returned = 0n;
    } else {
      const p: bigint = n0 - 1n;
      depth += 1;
      n0 = p;
      continue;
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = tick(returned);
    }
  }
};
