const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T> {
  readonly z: T;
  readonly next0: (_0: T) => T;
}

export interface FInnerFull<T> {
  readonly tag: "Full";
  readonly x: T;
}

export interface FInnerEmpty {
  readonly tag: "Empty";
}

export type FInnerCell<T> = FInnerFull<T> | FInnerEmpty;

export interface FInner<T> {
  readonly full: (x: T) => FInnerCell<T>;
  readonly empty: FInnerEmpty;
  readonly cellRect: <A>(full: (_: T) => A, empty: A, c: FInnerCell<T>) => A;
  readonly cellRec: <A>(full: (_: T) => A, empty: A, c: FInnerCell<T>) => A;
  readonly fill: (x: T) => FInnerCell<T>;
  readonly first: FInnerCell<T>;
}

export interface FResult<T> {
  readonly Inner: FInner<T>;
  readonly unwrap: (c: FInnerCell<T>) => T;
  readonly twice: T;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const Inner$full = (x: T): FInnerCell<T> => ({ tag: "Full", x });
  const Inner$empty: FInnerEmpty = { tag: "Empty" };

  const Inner$cellRect = <A>(
    full: (_: T) => A,
    empty: A,
    c: FInnerCell<T>
  ): A => {
    switch (c.tag) {
      case "Full": {
        return full(c.x);
      }

      case "Empty": {
        return empty;
      }

      default: {
        return c satisfies never;
      }
    }
  };

  const Inner$cellRec = <A>(
    full: (_: T) => A,
    empty: A,
    c: FInnerCell<T>
  ): A => {
    switch (c.tag) {
      case "Full": {
        return full(c.x);
      }

      case "Empty": {
        return empty;
      }

      default: {
        return c satisfies never;
      }
    }
  };

  const Inner$fill = (x: T): FInnerCell<T> => Inner$full(x);
  const Inner$first: FInnerCell<T> = Inner$fill(X.z);

  const Inner = {
    cellRec: Inner$cellRec,
    cellRect: Inner$cellRect,
    empty: Inner$empty,
    fill: Inner$fill,
    first: Inner$first,
    full: Inner$full,
  } as const;

  const unwrap = (c: FInnerCell<T>): T => {
    switch (c.tag) {
      case "Full": {
        return c.x;
      }

      case "Empty": {
        return X.z;
      }

      default: {
        return c satisfies never;
      }
    }
  };

  const twice: T = X.next0(unwrap(Inner$first));

  return { Inner, twice, unwrap };
};

const A$z = 0;
const A$next0 = (n: number): number => s(n);

const A = {
  next0: A$next0,
  z: A$z,
} as const;

export type BInnerFull = FInnerFull<number>;

export type BInnerEmpty = FInnerEmpty;

export type BInnerCell = FInnerCell<number>;

export const B = F<number>(A);
export const v: number = add(B.unwrap(B.Inner.fill(s(s(s(s(0)))))), B.twice);

export interface FLAGGED<T> {
  readonly z: T;
}

const Flags$matchFlag = <R>(on: () => R, off: () => R, b: boolean): R =>
  b ? on() : off();

const Flags$flagRect = <A>(on0: A, off: A, f: boolean): A =>
  Flags$matchFlag(
    (): A => on0,
    (): A => off,
    f
  );

const Flags$flagRec = <A>(on0: A, off: A, f: boolean): A =>
  Flags$matchFlag(
    (): A => on0,
    (): A => off,
    f
  );

const Flags$toggle = (f: boolean): boolean =>
  Flags$matchFlag(
    (): boolean => false,
    (): boolean => true,
    f
  );

export interface FlagsResult<T> {
  readonly flagRect: <A>(on0: A, off: A, f: boolean) => A;
  readonly flagRec: <A>(on0: A, off: A, f: boolean) => A;
  readonly toggle: (f: boolean) => boolean;
  readonly pick: (f: boolean) => T;
}

export const Flags = <T>(X: FLAGGED<T>): FlagsResult<T> => {
  const pick = (f: boolean): T =>
    Flags$matchFlag(
      (): T => X.z,
      (): T => X.z,
      f
    );

  return {
    flagRec: Flags$flagRec,
    flagRect: Flags$flagRect,
    pick,
    toggle: Flags$toggle,
  };
};

export const FA = Flags<number>(A);

export const on: boolean = Flags$matchFlag(
  (): boolean => true,
  (): boolean => false,
  FA.toggle(false)
);
