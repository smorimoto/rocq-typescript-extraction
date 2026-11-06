import * as $Aliased from "./aliased.ts";
import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { add } = $Nat;
const { s } = $Datatypes;

export type BʹWrapped = $Aliased.BWrapped;

export const Bʹ = $Aliased.B;

export type BʹʹWrapped = $Aliased.BWrapped;

export const Bʹʹ = $Aliased.B;

export type HACWrap = $Aliased.HCWrap<number>;

export type HACEmpty = $Aliased.HCEmpty;

export type HACWrapped = $Aliased.HCWrapped<number>;

export type HACʹWrapped = HACWrapped;

export type HAYT = number;

export const HA = $Aliased.H<number>($Aliased.A);

export interface KResult {
  readonly L: typeof $Aliased.Q;
  readonly BB: typeof $Aliased.B;
  readonly k: number;
}

export const K = <T>(_X: $Aliased.S<T>): KResult => {
  const k: number = add($Aliased.Q.q, $Aliased.B.w);

  return { BB: $Aliased.B, L: $Aliased.Q, k };
};

export type KABBWrapped = $Aliased.BWrapped;

export const KA = K<number>($Aliased.A);

export const through: number = add(
  add(add(add($Aliased.B.w, HA.Mʹ.q), HA.Cʹ.w), KA.L.q),
  KA.k
);

export const wrapped: $Aliased.BWrapped = $Aliased.B.wrap(s(s(0)));
export const boxed: HACʹWrapped = HA.Cʹ.wrap(s(s(s(0))));
