import * as $Outer from "./outer.ts";

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type CBox0 = $Outer.FGBox0<number, boolean>;

export type CBox = $Outer.FGBox<number, boolean>;

export const C = $Outer.B.G<boolean>(A2);

export const P = <T>(W: $Outer.S<T>): $Outer.FG2Result<number, boolean, T> =>
  $Outer.B.G2<boolean, T>(A2)(W);

export const Q = P<number>($Outer.A);

export type UseFXYBox0<T, T0> = $Outer.FTGBox0<T, T0>;

export type UseFXYBox<T, T0> = $Outer.FTGBox<T, T0>;

export interface UseResult<T, T0> {
  readonly FX: $Outer.FTResult<T>;
  readonly FXY: $Outer.FTGResult<T, T0>;
  readonly both: UseFXYBox<T, T0>;
}

export const Use =
  <T, T0>(FF: $Outer.FT) =>
  (X: $Outer.S<T>) =>
  (Y: $Outer.S<T0>): UseResult<T, T0> => {
    const FX = FF<T>(X);
    const FXY = FX.G<T0>(Y);
    const both: UseFXYBox<T, T0> = FXY.both;

    return { FX, FXY, both };
  };

export type UFXYBox0 = UseFXYBox0<number, boolean>;

export type UFXYBox = UseFXYBox<number, boolean>;

export const U = Use<number, boolean>($Outer.F)($Outer.A)(A2);
export const fromC: CBox = C.both;
export const fromQ: readonly [readonly [number, boolean], number] = Q.three;
export const fromU: UFXYBox = U.both;
