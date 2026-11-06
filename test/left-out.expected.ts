const s = (n: number): number => n + 1;

export interface Some<A> {
  readonly tag: "Some";
  readonly arg0: A;
}

export interface None {
  readonly tag: "None";
}

export type Option<A> = Some<A> | None;

export const some = <A>(arg0: A): Option<A> => ({ arg0, tag: "Some" });
export const none: None = { tag: "None" };

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

export interface GW0<T0> {
  readonly tag: "W";
  readonly x: T0;
}

export interface GV<T1> {
  readonly tag: "V";
  readonly y: T1;
}

export type GW<T0, T1> = GW0<T0> | GV<T1>;

export interface GResult<T0, T1> {
  readonly w: (x: T0) => GW<T0, T1>;
  readonly v0: (y: T1) => GW<T0, T1>;
  readonly wRect: <A>(w0: (_: T0) => A, v: (_: T1) => A, w1: GW<T0, T1>) => A;
  readonly wRec: <A>(w0: (_: T0) => A, v: (_: T1) => A, w1: GW<T0, T1>) => A;
  readonly step: T0;
  readonly other: T1;
  readonly wrapped: GW<T0, T1>;
}

export const G =
  <T0, T1>(X: S<T0>) =>
  (Y: T<T1>): GResult<T0, T1> => {
    const w = (x: T0): GW<T0, T1> => ({ tag: "W", x });
    const v0 = (y: T1): GW<T0, T1> => ({ tag: "V", y });

    const wRect = <A>(w0: (_: T0) => A, v: (_: T1) => A, w1: GW<T0, T1>): A => {
      switch (w1.tag) {
        case "W": {
          return w0(w1.x);
        }

        case "V": {
          return v(w1.y);
        }

        default: {
          return w1 satisfies never;
        }
      }
    };

    const wRec = <A>(w0: (_: T0) => A, v: (_: T1) => A, w1: GW<T0, T1>): A => {
      switch (w1.tag) {
        case "W": {
          return w0(w1.x);
        }

        case "V": {
          return v(w1.y);
        }

        default: {
          return w1 satisfies never;
        }
      }
    };

    const step: T0 = X.next0(X.z);
    const other: T1 = Y.y;
    const wrapped: GW<T0, T1> = w(step);

    return { other, step, v0, w, wRec, wRect, wrapped };
  };

export interface G3W0<T0> {
  readonly tag: "W";
  readonly x: T0;
}

export interface G3U<T2> {
  readonly tag: "U";
  readonly z: T2;
}

export type G3W<T0, T2> = G3W0<T0> | G3U<T2>;

export interface G3Result<T0, T2> {
  readonly w: (x: T0) => G3W<T0, T2>;
  readonly u: (z: T2) => G3W<T0, T2>;
  readonly wRect: <A>(w0: (_: T0) => A, u0: (_: T2) => A, w1: G3W<T0, T2>) => A;
  readonly wRec: <A>(w0: (_: T0) => A, u0: (_: T2) => A, w1: G3W<T0, T2>) => A;
  readonly last: G3W<T0, T2>;
}

export const G3 =
  <T0, T1, T2>(_X: S<T0>) =>
  (_Y: T<T1>) =>
  (Z: S<T2>): G3Result<T0, T2> => {
    const w = (x: T0): G3W<T0, T2> => ({ tag: "W", x });
    const u = (z: T2): G3W<T0, T2> => ({ tag: "U", z });

    const wRect = <A>(
      w0: (_: T0) => A,
      u0: (_: T2) => A,
      w1: G3W<T0, T2>
    ): A => {
      switch (w1.tag) {
        case "W": {
          return w0(w1.x);
        }

        case "U": {
          return u0(w1.z);
        }

        default: {
          return w1 satisfies never;
        }
      }
    };

    const wRec = <A>(
      w0: (_: T0) => A,
      u0: (_: T2) => A,
      w1: G3W<T0, T2>
    ): A => {
      switch (w1.tag) {
        case "W": {
          return w0(w1.x);
        }

        case "U": {
          return u0(w1.z);
        }

        default: {
          return w1 satisfies never;
        }
      }
    };

    const last: G3W<T0, T2> = u(Z.z);

    return { last, u, w, wRec, wRect };
  };

const A$z = 0;
const A$next0 = (n0: number): number => s(n0);

const A = {
  next0: A$next0,
  z: A$z,
} as const;

const C$y = true;

const C = {
  y: C$y,
} as const;

export const P = <T0>(Y: T<T0>): GResult<number, T0> => G<number, T0>(A)(Y);

export type DW0 = GW0<number>;

export type DV = GV<boolean>;

export type DW = GW<number, boolean>;

export const D = P<boolean>(C);

export const P3 =
  <T0, T1>(Y: T<T0>) =>
  (Z: S<T1>): G3Result<number, T1> =>
    G3<number, T0, T1>(A)(Y)(Z);

export type D3W0 = G3W0<number>;

export type D3U = G3U<number>;

export type D3W = G3W<number, number>;

export const D3 = P3<boolean, number>(C)(A);

export const isW = (d: DW): boolean => {
  switch (d.tag) {
    case "W": {
      return true;
    }

    case "V": {
      return false;
    }

    default: {
      return d satisfies never;
    }
  }
};

interface FResult<T0> {
  readonly twice: (x: T0) => T0;
}

const F = <T0>(X: S<T0>): FResult<T0> => {
  const twice = (x: T0): T0 => X.next0(X.next0(x));

  return { twice };
};

export type MInnerT = number;

const M$Inner$z: number = s(0);
const M$Inner$next0 = (n0: number): number => s(n0);

const M$Inner = {
  next0: M$Inner$next0,
  z: M$Inner$z,
} as const;

const M$B = F<number>(M$Inner);
const M$three: number = M$B.twice(M$Inner$z);

export const M = {
  B: M$B,
  Inner: M$Inner,
  three: M$three,
} as const;

export interface TAGGEDWrap<T0> {
  readonly tag: "Wrap";
  readonly x: T0;
}

export interface TAGGEDOther {
  readonly tag: "Other";
}

export type TAGGEDW<T0> = TAGGEDWrap<T0> | TAGGEDOther;

export interface TAGGED<T0> {
  readonly z: TAGGEDW<T0>;
}

type TaggedT = number;

const Tagged$wrapRect = <A>(mk: (_: number) => A, x: number): A => mk(x);
const Tagged$wrapRec = <A>(mk: (_: number) => A, x: number): A => mk(x);

interface TaggedWrap0 {
  readonly tag: "Wrap";
  readonly x: TaggedT;
}

interface TaggedOther {
  readonly tag: "Other";
}

type TaggedW = TaggedWrap0 | TaggedOther;

const Tagged$wrap = (x: TaggedT): TaggedW => ({ tag: "Wrap", x });
const Tagged$other0: TaggedOther = { tag: "Other" };

const Tagged$wRect = <A>(wrap: (_: number) => A, other: A, w: TaggedW): A => {
  switch (w.tag) {
    case "Wrap": {
      return wrap(w.x);
    }

    case "Other": {
      return other;
    }

    default: {
      return w satisfies never;
    }
  }
};

const Tagged$wRec = <A>(wrap: (_: number) => A, other: A, w: TaggedW): A => {
  switch (w.tag) {
    case "Wrap": {
      return wrap(w.x);
    }

    case "Other": {
      return other;
    }

    default: {
      return w satisfies never;
    }
  }
};

const Tagged$z: TaggedW = Tagged$wrap(s(0));

const Tagged = {
  other0: Tagged$other0,
  wRec: Tagged$wRec,
  wRect: Tagged$wRect,
  wrap: Tagged$wrap,
  wrapRec: Tagged$wrapRec,
  wrapRect: Tagged$wrapRect,
  z: Tagged$z,
} as const;

export interface Pick0Result<T0> {
  readonly v: Option<T0>;
}

export const Pick0 = <T0>(X: TAGGED<T0>): Pick0Result<T0> => {
  const v: Option<T0> = X.z.tag === "Wrap" ? some(X.z.x) : none;

  return { v };
};

export const PT = Pick0<number>(Tagged);
export const n: number = add(D.step, M$three);
