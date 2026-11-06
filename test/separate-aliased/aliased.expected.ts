import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export interface S<T> {
  readonly z: T;
}

const A$z: number = s(0);

export const A = {
  z: A$z,
} as const;

const Q$q: number = s(s(s(s(s(s(s(0)))))));

export const Q = {
  q: Q$q,
} as const;

export interface FWrap<T> {
  readonly tag: "Wrap";
  readonly x: T;
}

export interface FEmpty {
  readonly tag: "Empty";
}

export type FWrapped<T> = FWrap<T> | FEmpty;

export interface FResult<T> {
  readonly wrap: (x: T) => FWrapped<T>;
  readonly empty: FEmpty;
  readonly wrappedRect: <A>(
    wrap0: (_: T) => A,
    empty0: A,
    w0: FWrapped<T>
  ) => A;
  readonly wrappedRec: <A>(wrap0: (_: T) => A, empty0: A, w0: FWrapped<T>) => A;
  readonly w: T;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const wrap = (x: T): FWrapped<T> => ({ tag: "Wrap", x });
  const empty: FEmpty = { tag: "Empty" };

  const wrappedRect = <A>(
    wrap0: (_: T) => A,
    empty0: A,
    w0: FWrapped<T>
  ): A => {
    switch (w0.tag) {
      case "Wrap": {
        return wrap0(w0.x);
      }

      case "Empty": {
        return empty0;
      }

      default: {
        return w0 satisfies never;
      }
    }
  };

  const wrappedRec = <A>(wrap0: (_: T) => A, empty0: A, w0: FWrapped<T>): A => {
    switch (w0.tag) {
      case "Wrap": {
        return wrap0(w0.x);
      }

      case "Empty": {
        return empty0;
      }

      default: {
        return w0 satisfies never;
      }
    }
  };

  const w: T = X.z;

  return { empty, w, wrap, wrappedRec, wrappedRect };
};

export type BWrapped = FWrapped<number>;

export const B = F<number>(A);

export interface HM<T> {
  readonly q: T;
}

export type HCWrap<T> = FWrap<T>;

export type HCEmpty = FEmpty;

export type HCWrapped<T> = FWrapped<T>;

export interface HResult<T> {
  readonly M: HM<T>;
  readonly Mʹ: HM<T>;
  readonly C: FResult<T>;
  readonly Cʹ: FResult<T>;
  readonly Y: S<T>;
}

export const H = <T>(X: S<T>): HResult<T> => {
  const M$q: T = X.z;

  const M = {
    q: M$q,
  } as const;

  const C = F<T>(X);

  return { C, Cʹ: C, M, Mʹ: M, Y: X };
};
