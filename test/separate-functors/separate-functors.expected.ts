import * as $App from "./app.ts";
import * as $Datatypes from "./datatypes.ts";
import * as $Fun from "./fun.ts";
import * as $Nat from "./nat.ts";
import * as $Sig from "./sig.ts";

const { negb, s } = $Datatypes;
const { map } = $App.B;
const { four } = $App;
const { add } = $Nat;
const C$z = false;
const C$next0 = (x: boolean): boolean => negb(x);
const C$map = (f: (_: boolean) => boolean, x: boolean): boolean => f(x);

const C = {
  map: C$map,
  next0: C$next0,
  z: C$z,
} as const;

export type DFull = $Fun.FFull<boolean>;

export type DEmpty = $Fun.FEmpty;

export type DBox = $Fun.FBox<boolean>;

export const D = $Fun.F<boolean>(C);

export interface HResult<T> {
  readonly GX: $Fun.FTResult<T>;
  readonly step: T;
}

export const H =
  <T>(X: $Sig.S<T>) =>
  (G: $Fun.FT): HResult<T> => {
    const GX = G<T>(X);
    const step: T = GX.twice(X.z);

    return { GX, step };
  };

export const HB = H<number>($Sig.A)($Fun.F);

export const boxed: $App.BBox = map(
  (x: number): number => s(x),
  $App.B.fill(s(0))
);

export const flipped: DBox = D.fill(D.mapped);
export const v: number = add(four, HB.step);
