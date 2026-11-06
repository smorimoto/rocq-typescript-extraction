const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface S<T> {
  readonly z: T;
}

export interface FGBox0<T, T0> {
  readonly tag: "Box";
  readonly x: T;
  readonly y: T0;
}

export type FGBox<T, T0> = FGBox0<T, T0>;

export interface FGHResult<T, T0, T1> {
  readonly three: readonly [readonly [T, T0], T1];
}

export interface FGResult<T, T0> {
  readonly box: (x: T, y: T0) => FGBox0<T, T0>;
  readonly boxRect: <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>) => A;
  readonly boxRec: <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>) => A;
  readonly both: FGBox<T, T0>;
  readonly H: <T1>(W: S<T1>) => FGHResult<T, T0, T1>;
}

export interface FResult<T> {
  readonly G: <T0>(Y: S<T0>) => FGResult<T, T0>;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const G = <T0>(Y: S<T0>): FGResult<T, T0> => {
    const box = (x: T, y: T0): FGBox0<T, T0> => ({ tag: "Box", x, y });

    const boxRect = <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const boxRec = <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const both: FGBox<T, T0> = box(X.z, Y.z);

    const H = <T1>(W: S<T1>): FGHResult<T, T0, T1> => {
      const three: readonly [readonly [T, T0], T1] = pair(pair(X.z, Y.z), W.z);

      return { three };
    };

    return { H, both, box, boxRec, boxRect };
  };

  return { G };
};

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export const B = F<number>(A);

export type CBox0 = FGBox0<number, boolean>;

export type CBox = FGBox<number, boolean>;

export const C = B.G<boolean>(A2);
export const D = C.H<number>(A);
export const fromC: CBox = C.both;
export const fromD: readonly [readonly [number, boolean], number] = D.three;

export interface F2G2Result<T, T0, T1> {
  readonly three: readonly [readonly [T, T0], T1];
}

export interface F2Result<T> {
  readonly G2: <T0, T1>(Y: S<T0>) => (W: S<T1>) => F2G2Result<T, T0, T1>;
}

export const F2 = <T>(X: S<T>): F2Result<T> => {
  const G2 =
    <T0, T1>(Y: S<T0>) =>
    (W: S<T1>): F2G2Result<T, T0, T1> => {
      const three: readonly [readonly [T, T0], T1] = pair(pair(X.z, Y.z), W.z);

      return { three };
    };

  return { G2 };
};

export const B2 = F2<number>(A);

export const P = <T>(W: S<T>): F2G2Result<number, boolean, T> =>
  B2.G2<boolean, T>(A2)(W);

export const Q = P<number>(A);
export const fromQ: readonly [readonly [number, boolean], number] = Q.three;

export interface FTGBox0<T, T0> {
  readonly tag: "Box";
  readonly x: T;
  readonly y: T0;
}

export type FTGBox<T, T0> = FTGBox0<T, T0>;

export interface FTGResult<T, T0> {
  readonly box: (x: T, y: T0) => FTGBox0<T, T0>;
  readonly boxRect: <A>(_0: (_: T) => (_: T0) => A, _1: FTGBox<T, T0>) => A;
  readonly boxRec: <A>(_0: (_: T) => (_: T0) => A, _1: FTGBox<T, T0>) => A;
  readonly both: FTGBox<T, T0>;
}

export type FTG<T> = <T0>(Y: S<T0>) => FTGResult<T, T0>;

export interface FTResult<T> {
  readonly G: FTG<T>;
}

export type FT = <T>(X: S<T>) => FTResult<T>;

export type UseFXYBox0<T, T0> = FTGBox0<T, T0>;

export type UseFXYBox<T, T0> = FTGBox<T, T0>;

export interface UseResult<T, T0> {
  readonly FX: FTResult<T>;
  readonly FXY: FTGResult<T, T0>;
  readonly both: UseFXYBox<T, T0>;
}

export const Use =
  <T, T0>(FF: FT) =>
  (X: S<T>) =>
  (Y: S<T0>): UseResult<T, T0> => {
    const FX = FF<T>(X);
    const FXY = FX.G<T0>(Y);
    const both: UseFXYBox<T, T0> = FXY.both;

    return { FX, FXY, both };
  };

export type UFXYBox0 = UseFXYBox0<number, boolean>;

export type UFXYBox = UseFXYBox<number, boolean>;

export const U = Use<number, boolean>(F)(A)(A2);
export const fromU: UFXYBox = U.both;

export interface HASGBox0<U, T> {
  readonly tag: "Box";
  readonly x: U;
  readonly y: T;
}

export type HASGBox<U, T> = HASGBox0<U, T>;

export interface HASGResult<U, T> {
  readonly box: (x: U, y: T) => HASGBox0<U, T>;
  readonly boxRect: <A>(_0: (_: U) => (_: T) => A, _1: HASGBox<U, T>) => A;
  readonly boxRec: <A>(_0: (_: U) => (_: T) => A, _1: HASGBox<U, T>) => A;
  readonly both: HASGBox<U, T>;
}

export type HASG<U> = <T>(Y: S<T>) => HASGResult<U, T>;

export interface HAS<U> {
  readonly G: HASG<U>;
}

export type ThroughXYBox0<U, T> = HASGBox0<U, T>;

export type ThroughXYBox<U, T> = HASGBox<U, T>;

export interface ThroughResult<U, T> {
  readonly XY: HASGResult<U, T>;
  readonly both: ThroughXYBox<U, T>;
}

export const Through =
  <U, T>(X: HAS<U>) =>
  (Y: S<T>): ThroughResult<U, T> => {
    const XY = X.G<T>(Y);
    const both: ThroughXYBox<U, T> = XY.both;

    return { XY, both };
  };

export type KU<T> = T;

export interface KGBox0<T, T0> {
  readonly tag: "Box";
  readonly x: T;
  readonly y: T0;
}

export type KGBox<T, T0> = KGBox0<T, T0>;

interface KGResult<T, T0> {
  readonly box: (x: T, y: T0) => KGBox0<T, T0>;
  readonly boxRect: <A>(box0: (_: T) => (_: T0) => A, b: KGBox<T, T0>) => A;
  readonly boxRec: <A>(box0: (_: T) => (_: T0) => A, b: KGBox<T, T0>) => A;
  readonly both: KGBox<T, T0>;
}

export const K = <T>(Z: S<T>): HAS<T> => {
  const G = <T0>(Y: S<T0>): KGResult<T, T0> => {
    const box = (x: T, y: T0): KGBox0<T, T0> => ({ tag: "Box", x, y });

    const boxRect = <A>(box0: (_: T) => (_: T0) => A, b: KGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const boxRec = <A>(box0: (_: T) => (_: T0) => A, b: KGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const both: KGBox<T, T0> = box(Z.z, Y.z);

    return { both, box, boxRec, boxRect };
  };

  return { G };
};

const KA = K<number>(A);

export type TXYBox0 = ThroughXYBox0<number, boolean>;

export type TXYBox = ThroughXYBox<number, boolean>;

export const T = Through<number, boolean>(KA)(A2);
export const fromT: TXYBox = T.both;

export interface HAS2InnerGResult<U, T> {
  readonly w: readonly [U, T];
}

export type HAS2InnerG<U> = <T>(Y: S<T>) => HAS2InnerGResult<U, T>;

export interface HAS2Inner<U> {
  readonly G: HAS2InnerG<U>;
}

export interface HAS2<U> {
  readonly Inner: HAS2Inner<U>;
}

export interface Through2Result<U, T> {
  readonly XY: HAS2InnerGResult<U, T>;
  readonly w: readonly [U, T];
}

export const Through2 =
  <U, T>(X: HAS2<U>) =>
  (Y: S<T>): Through2Result<U, T> => {
    const XY = X.Inner.G<T>(Y);
    const w: readonly [U, T] = XY.w;

    return { XY, w };
  };
