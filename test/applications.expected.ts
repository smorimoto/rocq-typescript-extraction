const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T0> {
  readonly z: T0;
  readonly next0: (_0: T0) => T0;
}

export interface T<T0> {
  readonly y: T0;
}

export interface FWrap<T0> {
  readonly tag: "Wrap";
  readonly x: T0;
}

export interface FEmpty {
  readonly tag: "Empty";
}

export type FWrapped<T0> = FWrap<T0> | FEmpty;

export interface FResult<T0> {
  readonly wrap: (x: T0) => FWrapped<T0>;
  readonly empty: FEmpty;
  readonly wrappedRect: <A>(
    wrap0: (_: T0) => A,
    empty0: A,
    w0: FWrapped<T0>
  ) => A;
  readonly wrappedRec: <A>(
    wrap0: (_: T0) => A,
    empty0: A,
    w0: FWrapped<T0>
  ) => A;
  readonly w: FWrapped<T0>;
  readonly unwrap: (d: FWrapped<T0>) => T0;
  readonly twice: (x: T0) => T0;
}

export const F = <T0>(X: S<T0>): FResult<T0> => {
  const wrap = (x: T0): FWrapped<T0> => ({ tag: "Wrap", x });
  const empty: FEmpty = { tag: "Empty" };

  const wrappedRect = <A>(
    wrap0: (_: T0) => A,
    empty0: A,
    w0: FWrapped<T0>
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

  const wrappedRec = <A>(
    wrap0: (_: T0) => A,
    empty0: A,
    w0: FWrapped<T0>
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

  const w: FWrapped<T0> = wrap(X.z);

  const unwrap = (d: FWrapped<T0>): T0 => {
    switch (d.tag) {
      case "Wrap": {
        return d.x;
      }

      case "Empty": {
        return X.z;
      }

      default: {
        return d satisfies never;
      }
    }
  };

  const twice = (x: T0): T0 => X.next0(X.next0(x));

  return { empty, twice, unwrap, w, wrap, wrappedRec, wrappedRect };
};

export interface GResult<T0, T1> {
  readonly step: T0;
  readonly other: T1;
}

export const G =
  <T0, T1>(X: S<T0>) =>
  (Y: T<T1>): GResult<T0, T1> => {
    const step: T0 = X.next0(X.z);
    const other: T1 = Y.y;

    return { other, step };
  };

const A$z = 0;
const A$next0 = (n: number): number => add(n, s(0));

const A = {
  next0: A$next0,
  z: A$z,
} as const;

const C$y = true;

const C = {
  y: C$y,
} as const;

export interface HolderIdResult<T0> {
  readonly same: T0;
}

const Holder$Id = <T0>(X: S<T0>): HolderIdResult<T0> => {
  const same0: T0 = X.z;

  return { same: same0 };
};

const Holder$B = Holder$Id<number>(A);

export const Holder = {
  B: Holder$B,
  Id: Holder$Id,
} as const;

export type BWrap = FWrap<number>;

export type BEmpty = FEmpty;

export type BWrapped = FWrapped<number>;

export const B = F<number>(A);
export const D = G<number, boolean>(A)(C);
export const v: number = B.unwrap(B.w);
export const three: BWrapped = B.wrap(s(s(s(0))));

export const count = (d: BWrapped): number => {
  switch (d.tag) {
    case "Wrap": {
      return B.twice(d.x);
    }

    case "Empty": {
      return D.step;
    }

    default: {
      return d satisfies never;
    }
  }
};

export const same: number = Holder$B.same;
