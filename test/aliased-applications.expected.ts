const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface SN<T> {
  readonly n: T;
}

export interface S<T> {
  readonly z: T;
  readonly N: SN<T>;
}

const A$z: number = s(0);
const A$N$n: number = s(s(0));

const A = {
  N: {
    n: A$N$n,
  },
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

export interface FInner<T> {
  readonly k: T;
}

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
  readonly Inner: FInner<T>;
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
  const Inner$k: T = X.N.n;

  const Inner = {
    k: Inner$k,
  } as const;

  return { Inner, empty, w, wrap, wrappedRec, wrappedRect };
};

export type BWrapped = FWrapped<number>;

export const B = F<number>(A);

export type BʹWrapped = BWrapped;

export const Bʹ = B;

export type BʹʹWrapped = BWrapped;

export const Bʹʹ = B;
export const G = F;
const GA = F<number>(A);

export interface HMBx<T> {
  readonly tag: "Bx";
  readonly x: T;
}

export interface HMBy {
  readonly tag: "By";
}

export type HMB<T> = HMBx<T> | HMBy;

export interface HM<T> {
  readonly bx: (x: T) => HMB<T>;
  readonly by: HMBy;
  readonly bRect: <A>(bx: (_: T) => A, by: A, b: HMB<T>) => A;
  readonly bRec: <A>(bx: (_: T) => A, by: A, b: HMB<T>) => A;
  readonly q: T;
}

export type HCWrap<T> = FWrap<T>;

export type HCEmpty = FEmpty;

export type HCWrapped<T> = FWrapped<T>;

export interface HResult<T> {
  readonly M: HM<T>;
  readonly Mʹ: HM<T>;
  readonly Y: S<T>;
  readonly YN: S<T>["N"];
  readonly C: FResult<T>;
  readonly Cʹ: FResult<T>;
  readonly CI: FResult<T>["Inner"];
  readonly B2: typeof B;
  readonly Q2: typeof Q;
  readonly r: T;
  readonly both: readonly [T, number];
}

export const H = <T>(X: S<T>): HResult<T> => {
  const M$bx = (x: T): HMB<T> => ({ tag: "Bx", x });
  const M$by: HMBy = { tag: "By" };

  const M$bRect = <A>(bx: (_: T) => A, by: A, b: HMB<T>): A => {
    switch (b.tag) {
      case "Bx": {
        return bx(b.x);
      }

      case "By": {
        return by;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  const M$bRec = <A>(bx: (_: T) => A, by: A, b: HMB<T>): A => {
    switch (b.tag) {
      case "Bx": {
        return bx(b.x);
      }

      case "By": {
        return by;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  const M$q: T = X.z;

  const M = {
    bRec: M$bRec,
    bRect: M$bRect,
    bx: M$bx,
    by: M$by,
    q: M$q,
  } as const;

  const C = F<T>(X);
  const r: T = M$q;
  const both: readonly [T, number] = pair(C.w, add(B.w, Q$q));

  return {
    B2: B,
    C,
    CI: C.Inner,
    Cʹ: C,
    M,
    Mʹ: M,
    Q2: Q,
    Y: X,
    YN: X.N,
    both,
    r,
  };
};

export type HAMBx = HMBx<number>;

export type HAMBy = HMBy;

export type HAMB = HMB<number>;

export type HAMʹB = HAMB;

export type HAYT = number;

export type HACWrap = HCWrap<number>;

export type HACEmpty = HCEmpty;

export type HACWrapped = HCWrapped<number>;

export type HACʹWrapped = HACWrapped;

export type HAB2Wrapped = BWrapped;

export const HA = H<number>(A);
export const through: number = add(add(B.w, GA.w), B.Inner.k);
export const wrapped: BWrapped = B.wrap(s(s(0)));

export const members: number = add(
  add(add(add(add(add(HA.Mʹ.q, HA.Y.z), HA.YN.n), HA.Cʹ.w), HA.CI.k), HA.B2.w),
  HA.Q2.q
);

export const built: HAMʹB = HA.Mʹ.bx(s(s(s(0))));
export const boxed: HACʹWrapped = HA.Cʹ.wrap(s(s(s(s(0)))));
