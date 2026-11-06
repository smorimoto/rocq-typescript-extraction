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

const map = <A, B>(f: (_: A) => B, l: List<A>): List<B> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<B>;

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
      const arg0: A = __readCell(saved, top);
      returned = cons(f(arg0), returned);
    }
  }
};

export type ORD = Record<never, never>;

export interface SortingInner<T> {
  readonly map: (x: (_: T) => T, x0: List<T>) => List<T>;
}

export interface SortingResult<T> {
  readonly sort: (l: List<T>) => List<T>;
  readonly Inner: SortingInner<T>;
}

export const Sorting = <T>(_X: ORD): SortingResult<T> => {
  const sort = (l: List<T>): List<T> => {
    switch (l.tag) {
      case "Nil": {
        return nil;
      }

      case "Cons": {
        return app(l.arg1, cons(l.arg0, nil));
      }

      default: {
        return l satisfies never;
      }
    }
  };

  const Inner$map = (x: (_: T) => T, x0: List<T>): List<T> => map(x, x0);

  const Inner = {
    map: Inner$map,
  } as const;

  return { Inner, sort };
};

const NatOrd = {} as const;
const Sort = Sorting<number>(NatOrd);
const { map: map0 } = Sort.Inner;
const Uses$twice = (l: List<number>): List<number> => Sort.sort(Sort.sort(l));

interface UsesResult {
  readonly twice: (l: List<number>) => List<number>;
}

const Uses = (_Y: ORD): UsesResult => ({ twice: Uses$twice });
const U = Uses(NatOrd);
export const sorted = (x: List<number>): List<number> => Sort.sort(x);

export const mapped = (l: List<number>): List<number> =>
  map0((x: number): number => s(x), l);

export const twice = (x: List<number>): List<number> => U.twice(x);
