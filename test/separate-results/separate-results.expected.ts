import * as $Datatypes from "./datatypes.ts";
import * as $ResultSigs from "./result-sigs.ts";

const { pair } = $Datatypes;

export type A2T = boolean;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type UseBT<R, T> = $ResultSigs.Kind<R, T>;

export type UseB2T<R> = $ResultSigs.Kind<R, A2T>;

export interface UseResult<R, T> {
  readonly B: $ResultSigs.SIG<UseBT<R, T>>;
  readonly B2: $ResultSigs.SIG<UseB2T<R>>;
  readonly both: readonly [UseBT<R, T>, UseB2T<R>];
}

export const Use =
  <R, T>(F: $ResultSigs.FT<R>) =>
  (X: $ResultSigs.SIG<T>): UseResult<R, T> => {
    const B = F<T>(X);
    const B2 = F<boolean>(A2);
    const both: readonly [UseBT<R, T>, UseB2T<R>] = pair(B.z, B2.z);

    return { B, B2, both };
  };

export interface ConstTLambda extends $ResultSigs.TypeLambda {
  readonly type: number;
}

export type U1BT = UseBT<ConstTLambda, number>;

export type U1B2T = UseB2T<ConstTLambda>;

export const U1 = Use<ConstTLambda, number>($ResultSigs.Const)($ResultSigs.A);

export interface SameTLambda extends $ResultSigs.TypeLambda {
  readonly type: this["Target"];
}

export type U2BT = UseBT<SameTLambda, number>;

export type U2B2T = UseB2T<SameTLambda>;

export const U2 = Use<SameTLambda, number>($ResultSigs.Same)($ResultSigs.A);
