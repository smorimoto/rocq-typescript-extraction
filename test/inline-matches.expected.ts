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
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const add = (n: number, m: number): number => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = m;
    } else {
      const p: number = n0 - 1;
      depth += 1;
      n0 = p;
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

const mul = (n: number, m: number): number => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = 0;
    } else {
      const p: number = n0 - 1;
      depth += 1;
      n0 = p;
      continue;
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = add(m, returned);
    }
  }
};

const leb = (n: number, m: number): boolean => {
  let n0 = n;
  let m0 = m;

  for (;;) {
    if (n0 === 0) {
      return true;
    }

    const nʹ: number = n0 - 1;

    if (m0 === 0) {
      return false;
    }

    const mʹ: number = m0 - 1;
    n0 = nʹ;
    m0 = mʹ;
  }
};

export const pick = (b: boolean, x: number, y: number): number => (b ? x : y);

export const squareIf = (b: boolean, n: number): number => {
  if (b) {
    const m: number = add(n, n);

    return mul(m, m);
  }

  return n;
};

export const isZero = (n: number): boolean => n === 0;
export const nonzero = (n: number): boolean => n !== 0;

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

export const predOrZero = (n: number): number => {
  if (n === 0) {
    return s(0);
  }

  const p: number = n - 1;

  return s(p);
};

export const firstOr = <A>(l: readonly A[], d: A): A => {
  if (l.length === 0) {
    return d;
  }

  const x: A = (<Head>(items: readonly Head[]): Head => {
    const first = items.values().next();

    if (first.done) {
      throw new Error("Empty list");
    }

    return first.value;
  })(l);

  return x;
};

export const sum = (l: readonly number[]): number => {
  const saved: [number][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: number;

    if (l0.length === 0) {
      returned = 0;
    } else {
      const x: number = (<Head>(items: readonly Head[]): Head => {
        const first = items.values().next();

        if (first.done) {
          throw new Error("Empty list");
        }

        return first.value;
      })(l0);

      const xs: readonly number[] = l0.slice(1);
      __writeCell(saved, top, x);
      top += 1;
      l0 = xs;
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

export const lastOr = (l: readonly number[], d: number): number => {
  let l0 = l;

  for (;;) {
    if (l0.length === 0) {
      return d;
    }

    const x: number = (<Head>(items: readonly Head[]): Head => {
      const first = items.values().next();

      if (first.done) {
        throw new Error("Empty list");
      }

      return first.value;
    })(l0);

    const xs: readonly number[] = l0.slice(1);

    if (xs.length === 0) {
      return x;
    }

    l0 = xs;
  }
};

export const swap = <A, B>(p: readonly [A, B]): readonly [B, A] =>
  pair(p[1], p[0]);

export const negative = (s0: number): boolean => s0 < 0;
export const nonneg = (s0: number): boolean => s0 > 0;
export const unsigned = (s0: number): number => (s0 === 0 ? 0 : s(0));

export const flip = (s0: number): number => {
  if (s0 < 0) {
    return 1;
  }

  if (s0 === 0) {
    return 0;
  }

  return -1;
};

export const total = (s0: number, n: number): number => {
  if (s0 < 0) {
    return 0;
  }

  if (s0 === 0) {
    return n;
  }

  return add(n, n);
};

export const max = (x: number, y: number): number => (leb(x, y) ? y : x);
export const bump = (b: boolean, x: number, y: number): number => s(b ? x : y);

export const after = (l: readonly number[]): number => {
  const s0: number = sum(l);

  if (s0 === 0) {
    return 0;
  }

  const p: number = s0 - 1;

  return p;
};

export const saturate = (n: number): number => (n === 0 ? s(0) : n);
