import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";
import type * as $OrderSig from "./order-sig.ts";
import * as $OrderTac from "./order-tac.ts";

const { andb, s } = $Datatypes;
const { eqb, leb } = $Nat;

export interface TwiceP<T> {
  readonly leTotal: (_0: T, _1: T) => boolean;
}

export interface TwiceResult<T> {
  readonly T: $OrderTac.MakeTacResult<T>;
  readonly both: (x: T, y: T) => boolean;
}

export const Twice =
  <T>(O: $OrderSig.EqLe<T>) =>
  (P: TwiceP<T>): TwiceResult<T> => {
    const T0 = $OrderTac.MakeTac<T>(O)(P);
    const both0 = (x: T, y: T): boolean => andb(T0.cmp(x, y), T0.cmp(y, x));

    return { T: T0, both: both0 };
  };

const N$le = (x: number, x0: number): boolean => leb(x, x0);
const N$leTotal = (x: number, x0: number): boolean => eqb(x, x0);

const N = {
  le: N$le,
  leTotal: N$leTotal,
} as const;

const T = $OrderTac.MakeTac<number>(N)(N);
const W = Twice<number>(N)(N);
export const go: boolean = T.cmp(s(s(s(0))), s(0));
export const both: boolean = W.both(s(s(0)), s(s(0)));
