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

const length = <A>(l: List<A>): number => {
  let depth = 0;
  let l0 = l;

  for (;;) {
    let returned: number;

    switch (l0.tag) {
      case "Nil": {
        returned = 0;
        break;
      }

      case "Cons": {
        depth += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
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

const app = <A>(l: List<A>, m: List<A>): List<A> => {
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

export type OT = Record<never, never>;

export interface InnerRaw<T> {
  readonly concat: (x: List<T>, x0: List<T>) => List<T>;
}

export interface InnerResult<T> {
  readonly Raw: InnerRaw<T>;
  readonly size: (x: List<T>) => number;
}

const Inner = <T>(_X: OT): InnerResult<T> => {
  const Raw$concat = (x: List<T>, x0: List<T>): List<T> => app(x, x0);

  const Raw = {
    concat: Raw$concat,
  } as const;

  const size = (x: List<T>): number => length(x);

  return { Raw, size };
};

export interface OuterResult<T> {
  readonly MSet: InnerResult<T>;
  readonly Raw: InnerResult<T>["Raw"];
  readonly join: (x: List<T>, x0: List<T>) => List<T>;
}

export const Outer = <T>(X: OT): OuterResult<T> => {
  const MSet = Inner<T>(X);
  const { concat } = MSet.Raw;
  const join = (x: List<T>, x0: List<T>): List<T> => concat(x, x0);

  return { MSet, Raw: MSet.Raw, join };
};

const NatOT = {} as const;
const M = Outer<number>(NatOT);
export const go: List<number> = M.join(cons(s(0), nil), cons(s(s(0)), nil));
