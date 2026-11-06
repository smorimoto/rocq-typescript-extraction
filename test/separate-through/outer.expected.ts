import * as $Datatypes from "./datatypes.ts";

const { pair, s } = $Datatypes;

export interface S<T> {
  readonly z: T;
}

export interface FGBox0<T, T0> {
  readonly tag: "Box";
  readonly x: T;
  readonly y: T0;
}

export type FGBox<T, T0> = FGBox0<T, T0>;

export interface FGResult<T, T0> {
  readonly box: (x: T, y: T0) => FGBox0<T, T0>;
  readonly boxRect: <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>) => A;
  readonly boxRec: <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>) => A;
  readonly both: FGBox<T, T0>;
}

export interface FG2Result<T, T0, T1> {
  readonly three: readonly [readonly [T, T0], T1];
}

export interface FResult<T> {
  readonly G: <T0>(Y: S<T0>) => FGResult<T, T0>;
  readonly G2: <T0, T1>(Y: S<T0>) => (W: S<T1>) => FG2Result<T, T0, T1>;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const G = <T0>(Y: S<T0>): FGResult<T, T0> => {
    const box = (x: T, y: T0): FGBox0<T, T0> => ({ tag: "Box", x, y });

    const boxRect = <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const boxRec = <A>(box0: (_: T) => (_: T0) => A, b: FGBox<T, T0>): A =>
      box0(b.x)(b.y);

    const both: FGBox<T, T0> = box(X.z, Y.z);

    return { both, box, boxRec, boxRect };
  };

  const G2 =
    <T0, T1>(Y: S<T0>) =>
    (W: S<T1>): FG2Result<T, T0, T1> => {
      const three: readonly [readonly [T, T0], T1] = pair(pair(X.z, Y.z), W.z);

      return { three };
    };

  return { G, G2 };
};

const A$z: number = s(0);

export const A = {
  z: A$z,
} as const;

export const B = F<number>(A);

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
