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

const s = (n: bigint): bigint => n + 1n;

const pred: (_0: bigint) => bigint = (n: bigint): bigint =>
  n > 0n ? n - 1n : 0n;

const add: (_0: bigint, _1: bigint) => bigint = (
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

const eqb: (_0: bigint, _1: bigint) => boolean = (
  n: bigint,
  m: bigint
): boolean => n === m;

const leb: (_0: bigint, _1: bigint) => boolean = (
  n: bigint,
  m: bigint
): boolean => n <= m;

const ltb: (_0: bigint, _1: bigint) => boolean = (
  n: bigint,
  m: bigint
): boolean => n < m;

const max: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (n > m ? n : m);

const min: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (n < m ? n : m);

const div: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (m === 0n ? 0n : n / m);

const modulo: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => (m === 0n ? n : n % m);

const xO = (p: bigint): bigint => 2n * p;
const zneg = (p: bigint): bigint => -p;

export const fact = (n: bigint): bigint => {
  const saved: [bigint][] = [];
  let top = 0;
  let n0 = n;

  for (;;) {
    let returned: bigint;

    if (n0 === 0n) {
      returned = s(0n);
    } else {
      const p: bigint = n0 - 1n;
      __writeCell(saved, top, n0);
      top += 1;
      n0 = p;
      continue;
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const n00: bigint = __readCell(saved, top);
      returned = mul(n00, returned);
    }
  }
};

export const fib = (n: bigint): bigint => {
  const saved: [bigint][] = [];
  let top = 0;
  const frames: [number][] = [];
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: bigint;

    if (n0 === 0n) {
      returned = 0n;
    } else {
      const p: bigint = n0 - 1n;

      if (p === 0n) {
        returned = s(0n);
      } else {
        const q: bigint = p - 1n;
        __writeCell(frames, depth, 0);
        depth += 1;
        __writeCell(saved, top, q);
        top += 1;
        n0 = p;
        continue;
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
          const q: bigint = __readCell(saved, top);
          __writeCell(frames, depth, 1);
          depth += 1;
          __writeCell(saved, top, returned);
          top += 1;
          n0 = q;
          resuming = false;
          continue;
        }

        default: {
          top -= 1;
          const returned0: bigint = __readCell(saved, top);
          returned = add(returned0, returned);
        }
      }
    }
  }
};

export const between = (lo: bigint, n: bigint, hi: bigint): boolean =>
  andb(leb(lo, n), ltb(n, hi));

export const same = (x: bigint, x0: bigint): boolean => eqb(x, x0);

export const average = (a: bigint, b: bigint): bigint =>
  div(add(a, b), s(s(0n)));

export const remainder = (x: bigint, x0: bigint): bigint => modulo(x, x0);

export const distance = (a: bigint, b: bigint): bigint =>
  add(sub(a, b), sub(b, a));

export const clamp = (n: bigint): bigint =>
  min(s(s(s(s(s(s(s(s(s(s(0n)))))))))), max(s(s(0n)), n));

export const previous = (x: bigint): bigint => pred(x);
export const twice = (p: bigint): bigint => xO(p);
export const negate = (p: bigint): bigint => zneg(p);
