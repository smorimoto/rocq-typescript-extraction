const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

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

export interface SW0<T> {
  readonly tag: "W";
  readonly x: T;
}

export interface SNothing {
  readonly tag: "Nothing";
}

export type SW<T> = SW0<T> | SNothing;

export interface SDeep<T> {
  readonly d: T;
}

export interface S<T, U> {
  readonly w0: (x: T) => SW<T>;
  readonly z: T;
  readonly f: (_0: T) => U;
  readonly g: (_0: U) => T;
  readonly pick: (_0: boolean, _1: SW<T>) => T;
  readonly Deep: SDeep<T>;
}

export interface COUNTED {
  readonly count: number;
}

export type NOTHING = Record<never, never>;

export interface FResult<T, U> {
  readonly twice: (x: T) => T;
  readonly w: U;
  readonly both: readonly [T, U];
  readonly deep: T;
}

export const F = <T, U>(X: S<T, U>): FResult<T, U> => {
  const twice = (x: T): T => X.g(X.f(x));
  const w: U = X.f(X.z);
  const both: readonly [T, U] = pair(X.z, w);
  const deep: T = X.pick(true, X.w0(X.Deep.d));

  return { both, deep, twice, w };
};

export interface BoxesFull<T> {
  readonly tag: "Full";
  readonly x: T;
}

export interface BoxesEmpty {
  readonly tag: "Empty";
}

export type BoxesBox<T> = BoxesFull<T> | BoxesEmpty;

const Boxes$evenOdd = {
  even: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return true;
      }

      const k: number = n0 - 1;

      if (k === 0) {
        return false;
      }

      const k0: number = k - 1;
      n0 = k0;
    }
  },
  odd: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return false;
      }

      const k: number = n0 - 1;

      if (k === 0) {
        return true;
      }

      const k0: number = k - 1;
      n0 = k0;
    }
  },
};

const { even: Boxes$even, odd: Boxes$odd } = Boxes$evenOdd;

export interface BoxesResult<T> {
  readonly full: (x: T) => BoxesBox<T>;
  readonly empty: BoxesEmpty;
  readonly boxRect: <A>(full0: (_: T) => A, empty0: A, b: BoxesBox<T>) => A;
  readonly boxRec: <A>(full0: (_: T) => A, empty0: A, b: BoxesBox<T>) => A;
  readonly some: BoxesBox<T>;
  readonly get0: (b: BoxesBox<T>) => T;
  readonly even: (n: number) => boolean;
  readonly odd: (n: number) => boolean;
}

export const Boxes = <T, U>(X: S<T, U>): BoxesResult<T> => {
  const full = (x: T): BoxesBox<T> => ({ tag: "Full", x });
  const empty: BoxesEmpty = { tag: "Empty" };

  const boxRect = <A>(full0: (_: T) => A, empty0: A, b: BoxesBox<T>): A => {
    switch (b.tag) {
      case "Full": {
        return full0(b.x);
      }

      case "Empty": {
        return empty0;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  const boxRec = <A>(full0: (_: T) => A, empty0: A, b: BoxesBox<T>): A => {
    switch (b.tag) {
      case "Full": {
        return full0(b.x);
      }

      case "Empty": {
        return empty0;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  const some: BoxesBox<T> = full(X.z);

  const get0 = (b: BoxesBox<T>): T => {
    switch (b.tag) {
      case "Full": {
        return b.x;
      }

      case "Empty": {
        return X.z;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  return {
    boxRec,
    boxRect,
    empty,
    even: Boxes$even,
    full,
    get0,
    odd: Boxes$odd,
    some,
  };
};

export interface LISTS<T> {
  readonly z: T;
  readonly xs: List<T>;
  readonly map: (_0: (_: T) => T, _1: List<T>) => List<T>;
  readonly sort: (_0: List<T>, _1: T) => List<T>;
}

export const map = (n: number): number => n;

export interface SortedResult<T> {
  readonly ys: List<T>;
}

export const Sorted = <T>(L: LISTS<T>): SortedResult<T> => {
  const { map: map0 } = L;

  const ys: List<T> = L.sort(
    map0((x: T): T => x, L.xs),
    L.z
  );

  return { ys };
};

export interface CounterResult {
  readonly next0: number;
}

export const Counter =
  (_N: NOTHING) =>
  (C: COUNTED): CounterResult => {
    const next0: number = add(C.count, s(0));

    return { next0 };
  };

export interface HolderIdResult<T> {
  readonly same: T;
}

const Holder$Id = <T, U>(X: S<T, U>): HolderIdResult<T> => {
  const same: T = X.z;

  return { same };
};

export const Holder = {
  Id: Holder$Id,
} as const;
