import type * as $Sig from "./sig.ts";

export interface FFull<T> {
  readonly tag: "Full";
  readonly x: T;
}

export interface FEmpty {
  readonly tag: "Empty";
}

export type FBox<T> = FFull<T> | FEmpty;

export interface FResult<T> {
  readonly full: (x: T) => FBox<T>;
  readonly empty: FEmpty;
  readonly boxRect: <A>(full0: (_: T) => A, empty0: A, b: FBox<T>) => A;
  readonly boxRec: <A>(full0: (_: T) => A, empty0: A, b: FBox<T>) => A;
  readonly twice: (x: T) => T;
  readonly mapped: T;
  readonly fill: (x: T) => FBox<T>;
  readonly map: (f: (_: T) => T, b: FBox<T>) => FBox<T>;
}

export const F = <T>(X: $Sig.S<T>): FResult<T> => {
  const { map } = X;
  const full = (x: T): FBox<T> => ({ tag: "Full", x });
  const empty: FEmpty = { tag: "Empty" };

  const boxRect = <A>(full0: (_: T) => A, empty0: A, b: FBox<T>): A => {
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

  const boxRec = <A>(full0: (_: T) => A, empty0: A, b: FBox<T>): A => {
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

  const twice = (x: T): T => X.next0(X.next0(x));
  const mapped: T = map(X.next0, X.z);
  const fill = (x: T): FBox<T> => full(x);

  const map0 = (f: (_: T) => T, b: FBox<T>): FBox<T> => {
    switch (b.tag) {
      case "Full": {
        return full(f(b.x));
      }

      case "Empty": {
        return empty;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  return { boxRec, boxRect, empty, fill, full, map: map0, mapped, twice };
};

export interface FTResult<T> {
  readonly twice: (_0: T) => T;
}

export type FT = <T>(X: $Sig.S<T>) => FTResult<T>;
