import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export interface SIG<T> {
  readonly z: T;
}

export type FT<R> = <T>(X: SIG<T>) => SIG<Kind<R, T>>;

export interface ConstResult {
  readonly z: number;
}

export const Const = <T>(_X: SIG<T>): ConstResult => {
  const z = 0;

  return { z };
};

export interface SameResult<T> {
  readonly z: T;
}

export const Same = <T>(X: SIG<T>): SameResult<T> => {
  const z: T = X.z;

  return { z };
};

const A$z: number = s(s(s(s(s(s(s(0)))))));

export const A = {
  z: A$z,
} as const;
