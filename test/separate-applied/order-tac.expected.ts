import * as $Datatypes from "./datatypes.ts";
import type * as $OrderSig from "./order-sig.ts";

const { orb } = $Datatypes;

export interface MakeTacP<T> {
  readonly leTotal: (_0: T, _1: T) => boolean;
}

export interface MakeTacResult<T> {
  readonly cmp: (x: T, y: T) => boolean;
}

export const MakeTac =
  <T>(O: $OrderSig.EqLe<T>) =>
  (P: MakeTacP<T>): MakeTacResult<T> => {
    const cmp = (x: T, y: T): boolean => orb(O.le(x, y), P.leTotal(x, y));

    return { cmp };
  };
