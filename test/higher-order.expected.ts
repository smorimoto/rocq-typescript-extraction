const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T> {
  readonly z: T;
  readonly next0: (_0: T) => T;
}

export interface FTWrap<T> {
  readonly tag: "Wrap";
  readonly x: T;
}

export interface FTNothing {
  readonly tag: "Nothing";
}

export type FTW<T> = FTWrap<T> | FTNothing;

export interface FTResult<T> {
  readonly wrap: (x: T) => FTW<T>;
  readonly nothing: FTNothing;
  readonly wRect: <A>(_0: (_: T) => A, _1: A, _2: FTW<T>) => A;
  readonly wRec: <A>(_0: (_: T) => A, _1: A, _2: FTW<T>) => A;
  readonly twice: (_0: T) => T;
  readonly map: (_0: (_: T) => T, _1: FTW<T>) => FTW<T>;
}

export type FT = <T>(X: S<T>) => FTResult<T>;

export type HFXWrap<T> = FTWrap<T>;

export type HFXNothing = FTNothing;

export type HFXW<T> = FTW<T>;

export interface HResult<T> {
  readonly FX: FTResult<T>;
  readonly four: T;
  readonly wrapped: HFXW<T>;
}

export const H =
  <T>(X: S<T>) =>
  (F: FT): HResult<T> => {
    const FX = F<T>(X);
    const { map } = FX;
    const four: T = FX.twice(FX.twice(X.z));
    const wrapped: HFXW<T> = map((x: T): T => x, FX.wrap(X.z));

    return { FX, four, wrapped };
  };

export interface DoubleWrap<T> {
  readonly tag: "Wrap";
  readonly x: T;
}

export interface DoubleNothing {
  readonly tag: "Nothing";
}

export type DoubleW<T> = DoubleWrap<T> | DoubleNothing;

export interface DoubleResult<T> {
  readonly wrap: (x: T) => DoubleW<T>;
  readonly nothing: DoubleNothing;
  readonly wRect: <A>(wrap0: (_: T) => A, nothing0: A, w: DoubleW<T>) => A;
  readonly wRec: <A>(wrap0: (_: T) => A, nothing0: A, w: DoubleW<T>) => A;
  readonly twice: (x: T) => T;
  readonly map: (f: (_: T) => T, v0: DoubleW<T>) => DoubleW<T>;
}

export const Double = <T>(X: S<T>): DoubleResult<T> => {
  const wrap = (x: T): DoubleW<T> => ({ tag: "Wrap", x });
  const nothing: DoubleNothing = { tag: "Nothing" };

  const wRect = <A>(wrap0: (_: T) => A, nothing0: A, w: DoubleW<T>): A => {
    switch (w.tag) {
      case "Wrap": {
        return wrap0(w.x);
      }

      case "Nothing": {
        return nothing0;
      }

      default: {
        return w satisfies never;
      }
    }
  };

  const wRec = <A>(wrap0: (_: T) => A, nothing0: A, w: DoubleW<T>): A => {
    switch (w.tag) {
      case "Wrap": {
        return wrap0(w.x);
      }

      case "Nothing": {
        return nothing0;
      }

      default: {
        return w satisfies never;
      }
    }
  };

  const twice = (x: T): T => X.next0(X.next0(x));

  const map = (f: (_: T) => T, v0: DoubleW<T>): DoubleW<T> => {
    switch (v0.tag) {
      case "Wrap": {
        return wrap(f(v0.x));
      }

      case "Nothing": {
        return nothing;
      }

      default: {
        return v0 satisfies never;
      }
    }
  };

  return { map, nothing, twice, wRec, wRect, wrap };
};

const A$z = 0;
const A$next0 = (n: number): number => add(n, s(0));

const A = {
  next0: A$next0,
  z: A$z,
} as const;

export type BFXWrap = HFXWrap<number>;

export type BFXNothing = HFXNothing;

export type BFXW = HFXW<number>;

export const B = H<number>(A)(Double);
export const v: number = add(B.four, B.FX.twice(s(0)));

export type MAKE = <T>(X: S<T>) => S<T>;

export type IdT<T> = T;

export interface IdResult<T> {
  readonly z: T;
  readonly next0: (x: T) => T;
}

export const Id = <T>(X: S<T>): IdResult<T> => {
  const z: T = X.next0(X.z);
  const next0 = (x: T): T => X.next0(x);

  return { next0, z };
};

export type KMXT<T> = T;

export interface KResult<T> {
  readonly MX: S<T>;
  readonly z: T;
}

export const K =
  <T>(X: S<T>) =>
  (M: MAKE): KResult<T> => {
    const MX = M<T>(X);
    const z: T = MX.next0(MX.z);

    return { MX, z };
  };

export type CMXT = KMXT<number>;

export const C = K<number>(A)(Id);
