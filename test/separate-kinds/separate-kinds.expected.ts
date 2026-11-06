import * as $Datatypes from "./datatypes.ts";
import * as $Kinds from "./kinds.ts";
import * as $Nat from "./nat.ts";

const { eqb } = $Nat;
const { cons, nil, s } = $Datatypes;

export interface WrapResult<T> {
  readonly zeros: $Kinds.Kind<T, boolean>;
}

export const Wrap = <T>(C: $Kinds.CONTAINER<T>): WrapResult<T> => {
  const { map } = C;

  const zeros: $Kinds.Kind<T, boolean> = map(
    (x: number): boolean => eqb(0, x),
    C.empty<number>()
  );

  return { zeros };
};

export interface LTLambda extends $Kinds.TypeLambda {
  readonly type: $Kinds.LT<this["Target"]>;
}

export const U = $Kinds.Use<LTLambda>($Kinds.L);
export const W = Wrap<LTLambda>($Kinds.L);

export const total: $Datatypes.List<number> = U.twice(
  (x: number): number => s(x),
  cons(s(0), nil)
);
