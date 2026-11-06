import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";
import type * as $SolverSig from "./solver-sig.ts";
import * as $Solvers from "./solvers.ts";

const { s } = $Datatypes;
const { add } = $Nat;

export type NestedOLT<T> = T;

export interface NestedResult<T> {
  readonly O: $SolverSig.SOLVER<T>;
  readonly twice: (n: number) => T;
}

export const Nested = <T>(Z: $SolverSig.LAT<T>): NestedResult<T> => {
  const O = $Solvers.Outer<T>(Z);
  const twice0 = (n: number): T => Z.lub(O.run(n), O.run(n));

  return { O, twice: twice0 };
};

const NatLat$bot: number = s(s(s(s(s(s(s(0)))))));
const NatLat$lub = (x: number, x0: number): number => add(x, x0);

const NatLat = {
  bot: NatLat$bot,
  lub: NatLat$lub,
} as const;

const S = $Solvers.Outer<number>(NatLat);
const N = Nested<number>(NatLat);
export const go: number = S.run(s(s(s(0))));
export const twice: number = N.twice(0);
export const through: number = N.O.run(s(0));
